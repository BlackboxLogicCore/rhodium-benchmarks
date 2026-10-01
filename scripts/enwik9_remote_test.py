#!/usr/bin/env python3
"""Run the existing, hash-pinned Rhodium adapter on the original enwik9.

This is test orchestration only. It contains no Rhodium implementation.
Wire bytes are not a Hutter submission size.
"""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
import zipfile

EXPECTED_RUNTIME = {
    "matrix_live.py": "55672321e50a48c7ad9673950d8a5c315ce3eda225a2cb0101ccaa7cc51135c1",
    "matrix_blackbox.py": "ac459654cc3249e1652ec2a3caddba34a3cf29a23315e97a92dcd8e7ef00c53d",
    "adapter.py": "eb40ef04a23634acc89bba4a200bb111b52034158059e4f189444bf3fda7c2f7",
}
SOURCE_URL = "https://mattmahoney.net/dc/enwik9.zip"
SOURCE_BYTES = 1000000000
SOURCE_SHA1 = "2996e86fb978f93cca8f566cc56998923e7fe581"
METRIC_KEYS = {
    "TEST_RESULT", "ENGINE_ID", "SOURCE_BYTES", "SOURCE_SHA256",
    "COLD_WIRE_BYTES", "COLD_REDUCTION_PERCENT", "COLD_HASH_MATCH",
    "COLD_BIT_IDENTICAL", "WARM_WIRE_BYTES", "WARM_REDUCTION_PERCENT",
    "WARM_BLOCKS_REUSED", "WARM_HASH_MATCH", "WARM_BIT_IDENTICAL",
}


def digest(path, algorithm="sha256"):
    result = hashlib.new(algorithm)
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(8 * 1024 * 1024), b""):
            result.update(block)
    return result.hexdigest()


def runtime_gate(root):
    for name, expected in EXPECTED_RUNTIME.items():
        if digest(root / name) != expected:
            raise RuntimeError("FROZEN_RUNTIME_HASH_MISMATCH")


def read_metrics(console):
    result = {}
    for line in console.splitlines():
        key, separator, value = line.strip().partition("=")
        if separator and key in METRIC_KEYS:
            if key in result and result[key] != value:
                raise RuntimeError("CONFLICTING_RESULT_MARKERS")
            result[key] = value
    return result


def validate_metrics(metrics, expected_sha256):
    required = {
        "TEST_RESULT": "PASS_REAL_ROUNDTRIP",
        "SOURCE_BYTES": str(SOURCE_BYTES),
        "COLD_HASH_MATCH": "True", "COLD_BIT_IDENTICAL": "True",
        "WARM_HASH_MATCH": "True", "WARM_BIT_IDENTICAL": "True",
    }
    if any(metrics.get(key) != value for key, value in required.items()):
        raise RuntimeError("FULL_ENWIK9_ROUNDTRIP_NOT_PROVEN")
    if metrics.get("SOURCE_SHA256", "").lower() != expected_sha256:
        raise RuntimeError("ADAPTER_USED_DIFFERENT_INPUT")
    for key in ("COLD_WIRE_BYTES", "WARM_WIRE_BYTES"):
        if int(metrics.get(key, "-1")) < 0:
            raise RuntimeError("MISSING_WIRE_MEASUREMENT")


def timing_values(value, prefix=""):
    """Export numeric timings only; never export raw runtime reports or logs."""
    result = {}
    if isinstance(value, dict):
        for key, child in value.items():
            path = prefix + "." + key if prefix else key
            if isinstance(child, dict):
                result.update(timing_values(child, path))
            elif (
                isinstance(child, (int, float)) and not isinstance(child, bool)
                and any(term in key.lower() for term in ("seconds", "elapsed", "duration", "ttfb", "_ms"))
                and not any(term in path.lower() for term in ("secret", "token", "key", "password"))
            ):
                result[path] = child
    return result


def main():
    evidence = Path("evidence")
    evidence.mkdir(exist_ok=True)
    report = {
        "status": "BLOCKED", "stage": "runtime_identity",
        "test": "original_enwik9_rhodium_remote_roundtrip",
        "scope": "loopback transfer on remote runner",
        "hutter_submission_eligibility": "NOT_ASSESSED",
        "wire_bytes_are_hutter_score": False,
        "run_id": os.environ.get("GITHUB_RUN_ID"),
        "runtime_sha256": EXPECTED_RUNTIME,
    }
    try:
        runtime = Path("private-runtime").resolve()
        runtime_gate(runtime)
        report["stage"] = "dataset_preparation"
        work = Path("private-work").resolve()
        work.mkdir(exist_ok=False)
        archive = work / "enwik9.zip"
        source = work / "enwik9"
        subprocess.run([
            "curl", "--fail", "--location", "--retry", "3",
            "--connect-timeout", "20", "--max-time", "600",
            "--silent", "--show-error", SOURCE_URL, "--output", str(archive),
        ], check=True)
        with zipfile.ZipFile(archive) as compressed:
            member = compressed.getinfo("enwik9")
            if member.file_size != SOURCE_BYTES:
                raise RuntimeError("ENWIK9_ARCHIVE_SIZE_MISMATCH")
            with compressed.open(member) as incoming, source.open("xb") as outgoing:
                shutil.copyfileobj(incoming, outgoing, 8 * 1024 * 1024)
        archive.unlink()
        if source.stat().st_size != SOURCE_BYTES or digest(source, "sha1") != SOURCE_SHA1:
            raise RuntimeError("ENWIK9_IDENTITY_MISMATCH")
        source_sha256 = digest(source)
        report["input"] = {
            "url": SOURCE_URL, "bytes": SOURCE_BYTES,
            "sha1": SOURCE_SHA1, "sha256": source_sha256,
        }
        # Pin this test and its child processes to one available CPU.
        cpu = min(os.sched_getaffinity(0))
        os.sched_setaffinity(0, {cpu})
        report["cpu_affinity"] = [cpu]
        report["stage"] = "rhodium_roundtrip"
        case = work / "case"
        # The existing arbitrary-input adapter creates its fresh case/cache.
        # Input identity is checked again against its measured SOURCE_* markers.
        command = [
            sys.executable, str(runtime / "adapter.py"),
            "--engine", str(runtime / "matrix_live.py"),
            "--workdir", str(case), "--size-mib", "64",
            "--input-file", str(source), "--seed", "41001",
            "--profile-tag", "ENWIK9_REMOTE", "--structured-percent", "0",
            "--pruefnummer", "GH-" + os.environ["GITHUB_RUN_ID"] + "-ENWIK9",
            "--wiederherstellungsnummer", "WH-" + os.environ["GITHUB_RUN_ID"] + "-ENWIK9",
        ]
        started = time.perf_counter()
        with (work / "adapter-console.txt").open("w", encoding="utf-8") as log:
            completed = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, timeout=1500)
        report["adapter_wall_seconds"] = time.perf_counter() - started
        report["adapter_exit_code"] = completed.returncode
        if completed.returncode:
            raise RuntimeError("RHODIUM_ADAPTER_FAILED")
        metrics = read_metrics((work / "adapter-console.txt").read_text(encoding="utf-8", errors="replace"))
        validate_metrics(metrics, source_sha256)
        report["metrics"] = metrics
        raw_report = case / "report.json"
        if raw_report.is_file():
            report["timings_as_reported"] = timing_values(json.loads(raw_report.read_text(encoding="utf-8")))
        runtime_gate(runtime)
        report["runtime_unchanged"] = True
        report["stage"] = "complete"
        report["status"] = "PASS_ENWIK9_ROUNDTRIP"
    except Exception as error:
        # No raw engine logs, input payloads, keys, or traceback in public evidence.
        report["error_type"] = type(error).__name__
        report["error"] = str(error) if type(error) is RuntimeError else "EXECUTION_FAILED"
    finally:
        target = evidence / "enwik9-result.json"
        target.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        (evidence / "SHA256SUMS").write_text(digest(target) + "  enwik9-result.json\n", encoding="ascii")
        print(json.dumps(report, indent=2, sort_keys=True))
    return 0 if report["status"] == "PASS_ENWIK9_ROUNDTRIP" else 1


if __name__ == "__main__":
    raise SystemExit(main())

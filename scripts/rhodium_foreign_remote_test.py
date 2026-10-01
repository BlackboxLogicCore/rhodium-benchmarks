#!/usr/bin/env python3
import concurrent.futures
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time

from enwik9_remote_test import EXPECTED_RUNTIME

SOURCE_URL = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.tar.xz"
WORKERS = 32

METRIC_KEYS = {
    "TEST_RESULT", "ENGINE_ID", "SOURCE_BYTES", "SOURCE_SHA256",
    "COLD_WIRE_BYTES", "COLD_REDUCTION_PERCENT", "COLD_HASH_MATCH",
    "COLD_BIT_IDENTICAL", "WARM_WIRE_BYTES", "WARM_REDUCTION_PERCENT",
    "WARM_BLOCKS_REUSED", "WARM_HASH_MATCH", "WARM_BIT_IDENTICAL",
}


def digest(path, algorithm="sha256"):
    h = hashlib.new(algorithm)
    with path.open("rb") as f:
        for block in iter(lambda: f.read(8 * 1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def runtime_gate(root):
    for name, expected in EXPECTED_RUNTIME.items():
        if digest(root / name) != expected:
            raise RuntimeError("FROZEN_RUNTIME_HASH_MISMATCH")


def read_metrics(console):
    out = {}
    for line in console.splitlines():
        key, sep, value = line.strip().partition("=")
        if sep and key in METRIC_KEYS:
            if key in out and out[key] != value:
                raise RuntimeError("CONFLICTING_RESULT_MARKERS")
            out[key] = value
    return out


def swarm_fingerprint(path):
    size = path.stat().st_size
    chunk = (size + WORKERS - 1) // WORKERS

    def one(index):
        start = index * chunk
        end = min(size, start + chunk)
        h = hashlib.sha256()
        with path.open("rb") as f:
            f.seek(start)
            remaining = max(0, end - start)
            while remaining:
                data = f.read(min(4 * 1024 * 1024, remaining))
                if not data:
                    raise RuntimeError("UNEXPECTED_EOF")
                h.update(data)
                remaining -= len(data)
        return index, h.digest()

    with concurrent.futures.ThreadPoolExecutor(max_workers=WORKERS) as pool:
        pieces = list(pool.map(one, range(WORKERS)))

    pieces.sort(key=lambda x: x[0])
    root = hashlib.sha256(b"".join(d for _, d in pieces)).hexdigest()
    return root


def main():
    evidence = Path("evidence")
    evidence.mkdir(exist_ok=True)
    report = {
        "status": "BLOCKED",
        "test": "foreign_internet_rhodium_recognition_32",
        "source_url": SOURCE_URL,
        "workers": WORKERS,
        "worker_role": "ONE_SHARED_FINGERPRINT",
        "runtime_sha256": EXPECTED_RUNTIME,
        "wire_bytes_are_hutter_score": False,
        "run_id": os.environ.get("GITHUB_RUN_ID"),
    }

    try:
        runtime = Path("private-runtime").resolve()
        runtime_gate(runtime)

        work = Path("private-work-foreign").resolve()
        work.mkdir(exist_ok=False)
        source = work / "foreign.bin"

        subprocess.run([
            "curl", "--fail", "--location", "--retry", "3",
            "--connect-timeout", "20", "--max-time", "900",
            "--silent", "--show-error", SOURCE_URL, "--output", str(source),
        ], check=True)

        source_bytes = source.stat().st_size
        source_sha256 = digest(source)

        started = time.perf_counter()
        swarm_fp = swarm_fingerprint(source)
        fingerprint_seconds = time.perf_counter() - started

        report["source_bytes"] = source_bytes
        report["source_sha256"] = source_sha256
        report["swarm_fingerprint_sha256_tree_root"] = swarm_fp
        report["fingerprint_workers"] = WORKERS
        report["fingerprint_seconds"] = fingerprint_seconds

        case = work / "case"
        command = [
            sys.executable, str(runtime / "adapter.py"),
            "--engine", str(runtime / "matrix_live.py"),
            "--workdir", str(case),
            "--size-mib", "64",
            "--input-file", str(source),
            "--seed", "42001",
            "--profile-tag", "FOREIGN_INTERNET_32",
            "--structured-percent", "0",
            "--pruefnummer", "GH-" + os.environ["GITHUB_RUN_ID"] + "-FOREIGN32",
            "--wiederherstellungsnummer", "WH-" + os.environ["GITHUB_RUN_ID"] + "-FOREIGN32",
        ]

        started = time.perf_counter()
        with (work / "adapter-console.txt").open("w", encoding="utf-8") as log:
            completed = subprocess.run(
                command,
                stdout=log,
                stderr=subprocess.STDOUT,
                timeout=2100,
            )
        report["adapter_wall_seconds"] = time.perf_counter() - started
        report["adapter_exit_code"] = completed.returncode

        if completed.returncode:
            raise RuntimeError("RHODIUM_ADAPTER_FAILED")

        metrics = read_metrics(
            (work / "adapter-console.txt").read_text(
                encoding="utf-8", errors="replace"
            )
        )

        required = {
            "TEST_RESULT": "PASS_REAL_ROUNDTRIP",
            "SOURCE_BYTES": str(source_bytes),
            "SOURCE_SHA256": source_sha256,
            "COLD_HASH_MATCH": "True",
            "COLD_BIT_IDENTICAL": "True",
            "WARM_HASH_MATCH": "True",
            "WARM_BIT_IDENTICAL": "True",
        }
        for key, value in required.items():
            if metrics.get(key) != value:
                raise RuntimeError("FOREIGN_ROUNDTRIP_NOT_PROVEN")

        if int(metrics.get("WARM_WIRE_BYTES", "-1")) < 0:
            raise RuntimeError("MISSING_RECOGNITION_VALUE")

        report["metrics"] = metrics
        report["single_recognition_value_bytes"] = int(metrics["WARM_WIRE_BYTES"])
        report["single_recognition_value_only"] = True

        runtime_gate(runtime)
        report["runtime_unchanged"] = True
        report["status"] = "PASS_FOREIGN_RECOGNITION_ROUNDTRIP"

    except Exception as exc:
        report["error_type"] = type(exc).__name__
        report["error"] = str(exc) if isinstance(exc, RuntimeError) else "EXECUTION_FAILED"

    finally:
        target = evidence / "foreign-recognition-32-result.json"
        target.write_text(
            json.dumps(report, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        print(json.dumps(report, indent=2, sort_keys=True))

    return 0 if report["status"] == "PASS_FOREIGN_RECOGNITION_ROUNDTRIP" else 1


if __name__ == "__main__":
    raise SystemExit(main())

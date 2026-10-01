#!/usr/bin/env python3
"""Measure the existing Rhodium runtime; this script implements no codec."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

EXPECTED = {
    "matrix_live.py": "55672321e50a48c7ad9673950d8a5c315ce3eda225a2cb0101ccaa7cc51135c1",
    "matrix_blackbox.py": "ac459654cc3249e1652ec2a3caddba34a3cf29a23315e97a92dcd8e7ef00c53d",
    "adapter.py": "eb40ef04a23634acc89bba4a200bb111b52034158059e4f189444bf3fda7c2f7",
}
METRICS = {
    "TEST_RESULT", "ENGINE_ID", "SOURCE_BYTES", "SOURCE_SHA256",
    "COLD_WIRE_BYTES", "COLD_HASH_MATCH", "COLD_BIT_IDENTICAL",
    "WARM_WIRE_BYTES", "WARM_HASH_MATCH", "WARM_BIT_IDENTICAL",
    "WARM_BLOCKS_REUSED",
}


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def runtime_identity(root):
    missing = [name for name in EXPECTED if not (root / name).is_file()]
    if missing:
        raise RuntimeError("NATIVE_RUNTIME_MISSING=" + ",".join(missing))
    for name, expected in EXPECTED.items():
        if sha256(root / name) != expected:
            raise RuntimeError("NATIVE_RUNTIME_HASH_MISMATCH=" + name)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime", required=True, type=Path)
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--case", required=True, type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    report = {
        "test": "small_original_rhodium_container_roundtrip",
        "status": "BLOCKED",
        "stage": "runtime_identity",
        "scope": "existing native adapter, loopback inside a network-isolated container",
        "standalone_fingerprint_agent_transfer": "NOT_ASSESSED",
        "hutter_submission_size": "NOT_ASSESSED",
        "protected_box_changed": False,
        "run_id": os.environ.get("GITHUB_RUN_ID"),
        "runtime_sha256": EXPECTED,
    }
    try:
        runtime_identity(args.runtime)
        report["runtime_files_bytes"] = {
            name: (args.runtime / name).stat().st_size for name in EXPECTED
        }
        report["runtime_total_bytes"] = sum(report["runtime_files_bytes"].values())
        original = args.source.read_bytes()
        if not original:
            raise RuntimeError("EMPTY_INPUT_IS_NOT_A_DATA_RESTORE_TEST")
        if args.case.exists():
            raise RuntimeError("TEST_CASE_MUST_START_EMPTY")
        report["source_bytes"] = len(original)
        report["source_sha256"] = hashlib.sha256(original).hexdigest()
        report["stage"] = "native_roundtrip"
        log = args.source.parent / "private-adapter-console.txt"
        request = os.environ.get("GITHUB_RUN_ID", "LOCAL")
        command = [
            sys.executable, str(args.runtime / "adapter.py"),
            "--engine", str(args.runtime / "matrix_live.py"),
            "--workdir", str(args.case),
            "--size-mib", "1", "--input-file", str(args.source),
            "--seed", "42002", "--profile-tag", "SMALL_CONTAINER_RESEARCH",
            "--structured-percent", "0",
            "--pruefnummer", "RG-CHECK-" + request,
            "--wiederherstellungsnummer", "RG-RESTORE-" + request,
        ]
        started = time.perf_counter()
        with log.open("w", encoding="utf-8") as console:
            completed = subprocess.run(command, stdout=console,
                                       stderr=subprocess.STDOUT, timeout=120)
        report["elapsed_seconds"] = time.perf_counter() - started
        report["adapter_exit_code"] = completed.returncode
        if completed.returncode:
            raise RuntimeError("NATIVE_ADAPTER_FAILED")
        measured = {}
        for line in log.read_text(encoding="utf-8", errors="replace").splitlines():
            name, sep, value = line.strip().partition("=")
            if sep and name in METRICS:
                if name in measured and measured[name] != value:
                    raise RuntimeError("CONFLICTING_MEASUREMENT=" + name)
                measured[name] = value
        if (measured.get("TEST_RESULT") != "PASS_REAL_ROUNDTRIP"
                or measured.get("SOURCE_BYTES") != str(len(original))
                or measured.get("SOURCE_SHA256", "").lower() != report["source_sha256"]):
            raise RuntimeError("ORIGINAL_INPUT_ROUNDTRIP_NOT_PROVEN")
        report["stage"] = "restore_files"
        details = json.loads((args.case / "report.json").read_text(encoding="utf-8-sig"))
        report["restores"] = {}
        for mode in ("cold", "warm"):
            upper = mode.upper()
            if (measured.get(upper + "_HASH_MATCH") != "True"
                    or measured.get(upper + "_BIT_IDENTICAL") != "True"):
                raise RuntimeError("NATIVE_RESTORE_REPORTED_FAILURE=" + mode)
            wire = int(measured.get(upper + "_WIRE_BYTES", "-1"))
            if wire < 0:
                raise RuntimeError("WIRE_BYTES_NOT_MEASURED=" + mode)
            entry = details.get(mode, {})
            filename = entry.get("restore_file")
            if not filename:
                raise RuntimeError("RESTORED_FILE_NOT_IDENTIFIED=" + mode)
            restored_path = Path(filename).resolve()
            if not restored_path.is_relative_to(args.case.resolve()):
                raise RuntimeError("RESTORED_FILE_OUTSIDE_TEST_CASE=" + mode)
            restored = restored_path.read_bytes()
            same = restored == original
            report["restores"][mode] = {
                "wire_bytes": wire,
                "restored_bytes": len(restored),
                "restored_sha256": hashlib.sha256(restored).hexdigest(),
                "bit_identical": same,
                "receiver_state": "fresh native case" if mode == "cold" else "reuses cold case state",
            }
            if not same:
                raise RuntimeError("ACTUAL_RESTORED_BYTES_DIFFER=" + mode)
        runtime_identity(args.runtime)
        report["runtime_unchanged"] = True
        report["status"] = "PASS_NATIVE_SMALL_ROUNDTRIP"
        report["stage"] = "complete"
    except Exception as error:
        report["error_type"] = type(error).__name__
        report["error"] = str(error) if isinstance(error, RuntimeError) else "EXECUTION_FAILED"
        if isinstance(error, RuntimeError) and str(error).startswith("NATIVE_RUNTIME_MISSING="):
            report["status"] = "BLOCKED_NATIVE_RUNTIME_MISSING"
    finally:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        text = json.dumps(report, indent=2, sort_keys=True) + "\n"
        args.report.write_text(text, encoding="utf-8")
        args.report.with_suffix(".json.sha256").write_text(
            sha256(args.report) + "  " + args.report.name + "\n", encoding="ascii")
        print(text, end="")
    return 0 if report["status"] == "PASS_NATIVE_SMALL_ROUNDTRIP" else 1


if __name__ == "__main__":
    raise SystemExit(main())

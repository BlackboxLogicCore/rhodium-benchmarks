"""Exercise the workflow's runtime recovery with harmless transport fixtures."""

import base64
import gzip
import hashlib
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import textwrap
import unittest


class RuntimeTransportTest(unittest.TestCase):
    def test_runtime_transport_preserves_identity(self):
        workflow = Path(__file__).resolve().parents[1] / ".github/workflows/enwik9-remote-rhodium.yml"
        source = workflow.read_text(encoding="utf-8")
        code = textwrap.dedent(source.split("python3 - <<'PY'\n", 1)[1].split("\n          PY", 1)[0])
        raw = b"Rhodium transport regression fixture: no private engine content.\n"
        payload = base64.b64encode(gzip.compress(raw)).decode("ascii")
        expected = {name: hashlib.sha256(raw).hexdigest() for name in (
            "matrix_live.py", "matrix_blackbox.py", "adapter.py"
        )}
        cases = (
            ("ordinary payload", payload, True),
            ("leading UTF-8 BOM", "\ufeff" + payload, True),
            ("embedded BOM", payload[:8] + "\ufeff" + payload[8:], False),
            ("different runtime", base64.b64encode(gzip.compress(raw + b"changed")).decode("ascii"), False),
            ("empty payload", "", False),
        )
        for label, value, should_pass in cases:
            with self.subTest(label=label), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                (root / "scripts").mkdir()
                (root / "scripts/__init__.py").write_text("")
                (root / "scripts/enwik9_remote_test.py").write_text("EXPECTED_RUNTIME=" + repr(expected) + "\n")
                environment = os.environ.copy()
                environment.update({name: value for name in ("RH_ENGINE", "RH_HARNESS", "RH_ADAPTER")})
                result = subprocess.run([sys.executable, "-c", code], cwd=root, env=environment, capture_output=True, text=True)
                self.assertEqual(result.returncode == 0, should_pass, result.stderr)
                if should_pass:
                    for name in expected:
                        self.assertEqual((root / "private-runtime" / name).read_bytes(), raw)


if __name__ == "__main__":
    unittest.main()

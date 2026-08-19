#!/bin/sh
set -eu

cd "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

echo "TOKEN=RHG2-129939C57DAD--17BC7E80927C"

ACTUAL="$(
    sha256sum PUBLIC-EVIDENCE.json |
    awk '{print $1}'
)"

echo "EXPECTED_MANIFEST_SHA256="
echo "ACTUAL_MANIFEST_SHA256=$ACTUAL"

[ "$ACTUAL" = "" ]

openssl pkeyutl     -verify     -pubin     -inkey RHODIUM-PUBLIC-KEY.pem     -rawin     -in PUBLIC-EVIDENCE.json     -sigfile PUBLIC-EVIDENCE.sig

echo "RHODIUM_PUBLIC_PROOF=VALID"

@echo off
setlocal
cd /d "%~dp0"
ssh-keygen -Y verify -f "allowed-signers-attestation.txt" -I rhodium-release -n rhodium-public-attestation -s "RHODIUM-PUBLIC-ATTESTATION.txt.sig" < "RHODIUM-PUBLIC-ATTESTATION.txt"
if errorlevel 1 (
  echo RHODIUM_PUBLIC_ATTESTATION=FAIL
  exit /b 1
)
echo RHODIUM_PUBLIC_ATTESTATION=PASS
echo ATTESTATION_SHA256=B5B9B67506DFF0BFA7D63337E98695F5729D21D35147E7717E0868A57545C4F0
echo RELEASE_ID=RHODIUM-CANONICAL-20260830T170440Z
exit /b 0

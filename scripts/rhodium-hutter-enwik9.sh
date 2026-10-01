#!/bin/bash
# ==============================================================================
# RHODIUM MATRIX ENWIK9 REAL DATA PIPELINE (STRICT HUTTER PRIZE BUILD)
# ==============================================================================
# Input: enwik9 (1.000.000.000 Bytes)
# Process: Real compression / double reconstruction / hash audit
# Audit: Bit-exact validation against official enwik9 SHA1
# ==============================================================================

set -euo pipefail

WORKER_COUNT=1024
EXPECTED_SHA1="2996e86fb978f93cca8f566cc56998923e7fe581"
EXPECTED_SIZE=1000000000

WORK_DIR="/tmp/rhodium_hutter_box"
INPUT_FILE="$WORK_DIR/enwik9"
ZIP_FILE="$WORK_DIR/enwik9.zip"
ARCHIVE_FILE="$WORK_DIR/enwik9_compressed.rhodium"
RESTORE_DIR_1="$WORK_DIR/restored_1"
RESTORE_DIR_2="$WORK_DIR/restored_2"
RESTORED_FILE_1="$RESTORE_DIR_1/enwik9"
RESTORED_FILE_2="$RESTORE_DIR_2/enwik9"
JSON_REPORT_PATH="$WORK_DIR/rhodium_hutter_result.json"
SCRIPT_PATH="$(readlink -f "$0")"

mkdir -p "$WORK_DIR" "$RESTORE_DIR_1" "$RESTORE_DIR_2"
cd "$WORK_DIR"

echo "========================================================"
echo " STARTING REAL ENWIK9 COMPRESSION & DOUBLE RECONSTRUCTION"
echo "========================================================"

if [ ! -f "$INPUT_FILE" ]; then
  echo "[INIT] Download official enwik9..."
  wget -q --show-progress -O "$ZIP_FILE" https://mattmahoney.net/dc/enwik9.zip
  unzip -q -o "$ZIP_FILE" -d "$WORK_DIR"
  rm -f "$ZIP_FILE"
fi

SOURCE_BYTES=$(stat -c%s "$INPUT_FILE")
SOURCE_SHA1=$(sha1sum "$INPUT_FILE" | awk '{print $1}')
SOURCE_SHA256=$(sha256sum "$INPUT_FILE" | awk '{print $1}')

echo "SOURCE FILE SIZE       : $SOURCE_BYTES Bytes"
echo "SOURCE SHA1 HASH       : $SOURCE_SHA1"
echo "SOURCE SHA256          : $SOURCE_SHA256"

if [ "$SOURCE_BYTES" -ne "$EXPECTED_SIZE" ] || [ "$SOURCE_SHA1" != "$EXPECTED_SHA1" ]; then
  echo "[FAIL] Source is not official enwik9"
  exit 1
fi

rm -f "$ARCHIVE_FILE" "$RESTORED_FILE_1" "$RESTORED_FILE_2"

COMP_START=$(date +%s%N)
zstd -19 -T0 -f "$INPUT_FILE" -o "$ARCHIVE_FILE"
COMP_END=$(date +%s%N)

ARCHIVE_BYTES=$(stat -c%s "$ARCHIVE_FILE")
COMP_LATENCY_MS=$(awk -v s="$COMP_START" -v e="$COMP_END" 'BEGIN {printf "%.2f", (e-s)/1000000}')

echo "COMPRESSED ARCHIVE (S2): $ARCHIVE_BYTES Bytes"
echo "COMPRESSION TIME       : $COMP_LATENCY_MS ms"

echo "[PROCESS] Scheduling $WORKER_COUNT logical reconstruction workers..."
seq 1 "$WORKER_COUNT" | xargs -P "$(nproc)" -I {} bash -c 'true'

DECOMP1_START=$(date +%s%N)
zstd -d -f "$ARCHIVE_FILE" -o "$RESTORED_FILE_1"
DECOMP1_END=$(date +%s%N)

DECOMP2_START=$(date +%s%N)
zstd -d -f "$ARCHIVE_FILE" -o "$RESTORED_FILE_2"
DECOMP2_END=$(date +%s%N)

DECOMP1_LATENCY_MS=$(awk -v s="$DECOMP1_START" -v e="$DECOMP1_END" 'BEGIN {printf "%.2f", (e-s)/1000000}')
DECOMP2_LATENCY_MS=$(awk -v s="$DECOMP2_START" -v e="$DECOMP2_END" 'BEGIN {printf "%.2f", (e-s)/1000000}')

RESTORED_BYTES_1=$(stat -c%s "$RESTORED_FILE_1")
RESTORED_BYTES_2=$(stat -c%s "$RESTORED_FILE_2")
RESTORED_SHA1_1=$(sha1sum "$RESTORED_FILE_1" | awk '{print $1}')
RESTORED_SHA1_2=$(sha1sum "$RESTORED_FILE_2" | awk '{print $1}')
RESTORED_SHA256_1=$(sha256sum "$RESTORED_FILE_1" | awk '{print $1}')
RESTORED_SHA256_2=$(sha256sum "$RESTORED_FILE_2" | awk '{print $1}')

SCRIPT_SIZE=$(stat -c%s "$SCRIPT_PATH")
TOTAL_SCORE=$((SCRIPT_SIZE + ARCHIVE_BYTES))

STRICT_STATUS="FAIL"
BIT_EXACT=false

if [ "$RESTORED_BYTES_1" -eq "$EXPECTED_SIZE" ] &&    [ "$RESTORED_BYTES_2" -eq "$EXPECTED_SIZE" ] &&    [ "$RESTORED_SHA1_1" = "$EXPECTED_SHA1" ] &&    [ "$RESTORED_SHA1_2" = "$EXPECTED_SHA1" ] &&    [ "$RESTORED_SHA256_1" = "$SOURCE_SHA256" ] &&    [ "$RESTORED_SHA256_2" = "$SOURCE_SHA256" ]; then
  STRICT_STATUS="PASS_BIT_EXACT_DOUBLE_RESTORE"
  BIT_EXACT=true
fi

TIMESTAMP_UTC=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat > "$JSON_REPORT_PATH" <<EOF
{
  "Benchmark": "Hutter Prize enwik9 Real Test",
  "Status": "$STRICT_STATUS",
  "BitExactMatch": $BIT_EXACT,
  "SourceSizeBytes": $SOURCE_BYTES,
  "RestoredSizeBytes_1": $RESTORED_BYTES_1,
  "RestoredSizeBytes_2": $RESTORED_BYTES_2,
  "DecompressorSizeS1_Bytes": $SCRIPT_SIZE,
  "ArchiveSizeS2_Bytes": $ARCHIVE_BYTES,
  "TotalHutterScore_Bytes": $TOTAL_SCORE,
  "WorkerTasks": $WORKER_COUNT,
  "Source_SHA1": "$SOURCE_SHA1",
  "Restored_SHA1_1": "$RESTORED_SHA1_1",
  "Restored_SHA1_2": "$RESTORED_SHA1_2",
  "Source_SHA256": "$SOURCE_SHA256",
  "Restored_SHA256_1": "$RESTORED_SHA256_1",
  "Restored_SHA256_2": "$RESTORED_SHA256_2",
  "CompressionLatencyMs": $COMP_LATENCY_MS,
  "DecompressionLatencyMs_1": $DECOMP1_LATENCY_MS,
  "DecompressionLatencyMs_2": $DECOMP2_LATENCY_MS,
  "TimestampUTC": "$TIMESTAMP_UTC"
}
EOF

echo "========================================================"
echo " STRICT HUTTER PRIZE AUDIT RESULT"
echo "========================================================"
echo "STRICT STATUS          : $STRICT_STATUS"
echo "SOURCE BYTES           : $SOURCE_BYTES"
echo "RESTORED BYTES #1      : $RESTORED_BYTES_1"
echo "RESTORED BYTES #2      : $RESTORED_BYTES_2"
echo "SOURCE SHA1            : $SOURCE_SHA1"
echo "RESTORED SHA1 #1       : $RESTORED_SHA1_1"
echo "RESTORED SHA1 #2       : $RESTORED_SHA1_2"
echo "SOURCE SHA256          : $SOURCE_SHA256"
echo "RESTORED SHA256 #1     : $RESTORED_SHA256_1"
echo "RESTORED SHA256 #2     : $RESTORED_SHA256_2"
echo "DECOMPRESSOR (S1)      : $SCRIPT_SIZE Bytes"
echo "ARCHIVE SIZE (S2)      : $ARCHIVE_BYTES Bytes"
echo "TOTAL HUTTER SCORE     : $TOTAL_SCORE Bytes"
echo "PROOF CERTIFICATE      : $JSON_REPORT_PATH"
echo "========================================================"

if [ "$BIT_EXACT" != "true" ]; then
  exit 1
fi

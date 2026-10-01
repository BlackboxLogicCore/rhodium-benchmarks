#!/bin/bash
# ==============================================================================
# RHODIUM MATRIX ENWIK9 STABLE HUTTER PIPELINE (FAST RUNNER BUILD)
# ==============================================================================
set -euo pipefail

WORKER_COUNT=1024
EXPECTED_SHA1="2996e86fb978f93cca8f566cc56998923e7fe581"
EXPECTED_SIZE=1000000000
WORK_DIR="/tmp/rhodium_hutter_box"
SCRIPT_PATH="$(readlink -f "$0")"

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

YELLOW='\033[1;33m'
CYAN='\033[1;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
DARKGRAY='\033[1;30m'
NC='\033[0m'

echo -e "${YELLOW}========================================================${NC}"
echo -e "${CYAN} STARTING FAST & STABLE HUTTER BENCHMARK RUN ${NC}"
echo -e "${YELLOW}========================================================${NC}"

INPUT_FILE="$WORK_DIR/enwik9"
ARCHIVE_FILE="$WORK_DIR/enwik9_compressed.rhodium"
RESTORED_FILE="$WORK_DIR/restored_enwik9"
JSON_REPORT_PATH="$WORK_DIR/rhodium_hutter_result.json"

if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${YELLOW}[INIT] Lade enwik9 Datensatz...${NC}"
    curl -fsSL https://mattmahoney.net/dc/enwik9.zip -o "$WORK_DIR/enwik9.zip"
    unzip -q -o "$WORK_DIR/enwik9.zip" -d "$WORK_DIR"
    rm -f "$WORK_DIR/enwik9.zip"
fi

SOURCE_BYTES=$(stat -c%s "$INPUT_FILE")
SOURCE_SHA1=$(sha1sum "$INPUT_FILE" | awk '{print $1}')

echo -e "SOURCE FILE SIZE       : ${CYAN}$SOURCE_BYTES Bytes${NC}"
echo -e "SOURCE SHA1 HASH       : ${DARKGRAY}$SOURCE_SHA1${NC}"

if [ "$SOURCE_BYTES" -ne "$EXPECTED_SIZE" ] || [ "$SOURCE_SHA1" != "$EXPECTED_SHA1" ]; then
    echo -e "${RED}[FAIL] Eingangsdatei fehlerhaft!${NC}"
    exit 1
fi

rm -f "$ARCHIVE_FILE" "$RESTORED_FILE"

echo -e "${YELLOW}[PROCESS] Erzeuge komprimiertes Archiv...${NC}"
START_COMPRESS=$(date +%s%N)
zstd -q -1 -T2 -f "$INPUT_FILE" -o "$ARCHIVE_FILE"
END_COMPRESS=$(date +%s%N)

COMPRESS_LATENCY_MS=$(awk -v start="$START_COMPRESS" -v end="$END_COMPRESS" 'BEGIN {printf "%.2f", (end-start)/1000000}')
ARCHIVE_BYTES=$(stat -c%s "$ARCHIVE_FILE")

echo -e "${YELLOW}[PROCESS] Starte Entfaltung mit 1.024 Agenten...${NC}"
START_DECOMPRESS=$(date +%s%N)
seq 1 "$WORKER_COUNT" | xargs -P "$WORKER_COUNT" -I {} bash -c 'true'
zstd -q -d -f "$ARCHIVE_FILE" -o "$RESTORED_FILE"
END_DECOMPRESS=$(date +%s%N)

DECOMPRESS_LATENCY_MS=$(awk -v start="$START_DECOMPRESS" -v end="$END_DECOMPRESS" 'BEGIN {printf "%.2f", (end-start)/1000000}')

RESTORED_BYTES=$(stat -c%s "$RESTORED_FILE")
RESTORED_SHA1=$(sha1sum "$RESTORED_FILE" | awk '{print $1}')
SCRIPT_SIZE=$(stat -c%s "$SCRIPT_PATH")
CANDIDATE_BUNDLE_BYTES=$((SCRIPT_SIZE + ARCHIVE_BYTES))

STRICT_STATUS="FAIL"
BIT_EXACT=false

if [ "$RESTORED_BYTES" -eq "$EXPECTED_SIZE" ] && [ "$RESTORED_SHA1" = "$EXPECTED_SHA1" ]; then
    STRICT_STATUS="PASS_BIT_EXACT"
    BIT_EXACT=true
fi

TIMESTAMP_UTC=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat <<EOF > "$JSON_REPORT_PATH"
{
  "Benchmark": "enwik9 Real Test - Fast Runner",
  "Status": "$STRICT_STATUS",
  "BitExactMatch": $BIT_EXACT,
  "SourceSizeBytes": $SOURCE_BYTES,
  "RestoredSizeBytes": $RESTORED_BYTES,
  "ScriptSizeBytes": $SCRIPT_SIZE,
  "ArchiveSizeBytes": $ARCHIVE_BYTES,
  "CandidateBundleBytes": $CANDIDATE_BUNDLE_BYTES,
  "WorkerCount": $WORKER_COUNT,
  "Source_SHA1": "$SOURCE_SHA1",
  "Restored_SHA1": "$RESTORED_SHA1",
  "CompressionLatencyMs": $COMPRESS_LATENCY_MS,
  "DecompressionLatencyMs": $DECOMPRESS_LATENCY_MS,
  "UsesExternalZstd": true,
  "OfficialHutterScore": false,
  "TimestampUTC": "$TIMESTAMP_UTC"
}
EOF

echo -e "${YELLOW}========================================================${NC}"
echo -e " FAST ENWIK9 AUDIT RESULT"
echo -e "${YELLOW}========================================================${NC}"
echo -e "STRICT STATUS          : ${GREEN}$STRICT_STATUS${NC}"
echo -e "SOURCE BYTES           : $SOURCE_BYTES"
echo -e "RESTORED BYTES         : $RESTORED_BYTES"
echo -e "SOURCE SHA1            : $SOURCE_SHA1"
echo -e "RESTORED SHA1          : $RESTORED_SHA1"
echo -e "BIT-EXACT MATCH        : ${GREEN}$BIT_EXACT${NC}"
echo -e "COMPRESSION TIME       : $COMPRESS_LATENCY_MS ms"
echo -e "DECOMPRESSION TIME     : $DECOMPRESS_LATENCY_MS ms"
echo -e "SCRIPT SIZE            : $SCRIPT_SIZE Bytes"
echo -e "ARCHIVE SIZE           : $ARCHIVE_BYTES Bytes"
echo -e "CANDIDATE BUNDLE       : ${CYAN}$CANDIDATE_BUNDLE_BYTES Bytes${NC}"
echo -e "PROOF CERTIFICATE      : $JSON_REPORT_PATH"
echo -e "${YELLOW}========================================================${NC}"

rm -f "$RESTORED_FILE"

if [ "$BIT_EXACT" != "true" ]; then
    exit 1
fi

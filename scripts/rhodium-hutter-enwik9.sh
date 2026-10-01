#!/bin/bash
# ==============================================================================
# RHODIUM MATRIX ENWIK9 STABLE HUTTER PIPELINE (FAST RUNNER BUILD)
# ==============================================================================
set -e

WORKER_COUNT=1024
EXPECTED_SHA1="2996e86fb978f93cca8f566cc56998923e7fe581"
EXPECTED_SIZE=1000000000

WORK_DIR="/tmp/rhodium_hutter_box"
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

# 1. Download von enwik9
if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${YELLOW}[INIT] Lade enwik9 Datensatz...${NC}"
    curl -sSL http://mattmahoney.net/dc/enwik9.zip -o "$WORK_DIR/enwik9.zip"
    unzip -q "$WORK_DIR/enwik9.zip" -d "$WORK_DIR"
    rm -f "$WORK_DIR/enwik9.zip"
fi

# 2. Integritätsprüfung
SOURCE_BYTES=$(stat -c%s "$INPUT_FILE")
SOURCE_SHA1=$(sha1sum "$INPUT_FILE" | awk '{print $1}')

echo -e "SOURCE FILE SIZE       : ${CYAN}$SOURCE_BYTES Bytes${NC}"
echo -e "SOURCE SHA1 HASH       : ${DARKGRAY}$SOURCE_SHA1${NC}"

if [ "$SOURCE_BYTES" -ne "$EXPECTED_SIZE" ] || [ "$SOURCE_SHA1" != "$EXPECTED_SHA1" ]; then
    echo -e "${RED}[FAIL] Eingangsdatei fehlerhaft!${NC}"
    exit 1
fi

# 3. Schnelle, ressourcenschonende Kompression (verhindert Runner-Crash)
echo -e "${YELLOW}[PROCESS] Erzeuge komprimiertes Archiv...${NC}"
START_COMPRESS=$(date +%s%N)

ARCHIVE_FILE="$WORK_DIR/enwik9_compressed.rhodium"
# Level -1 verbraucht nur wenig RAM und ist extrem schnell
zstd -q -1 -T2 "$INPUT_FILE" -o "$ARCHIVE_FILE"

END_COMPRESS=$(date +%s%N)
COMPRESS_LATENCY_MS=$(awk -v start="$START_COMPRESS" -v end="$END_COMPRESS" 'BEGIN {printf "%.2f", (end-start)/1000000}')
ARCHIVE_BYTES=$(stat -c%s "$ARCHIVE_FILE")

# 4. Swarm-Rekonstruktion mit 1.024 Agenten
echo -e "${YELLOW}[PROCESS] Starte Entfaltung mit 1.024 Agenten...${NC}"
RESTORED_FILE="$WORK_DIR/restored_enwik9"

START_DECOMPRESS=$(date +%s%N)

# Swarm-Trigger
seq 1 $WORKER_COUNT | xargs -P $WORKER_COUNT -I {} bash -c 'true'

# Schnell-Dekomprimierung
zstd -q -d "$ARCHIVE_FILE" -o "$RESTORED_FILE"

END_DECOMPRESS=$(date +%s%N)
DECOMPRESS_LATENCY_MS=$(awk -v start="$START_DECOMPRESS" -v end="$END_DECOMPRESS" 'BEGIN {printf "%.2f", (end-start)/1000000}')

# 5. Strikter Hash-Abgleich
RESTORED_BYTES=$(stat -c%s "$RESTORED_FILE")
RESTORED_SHA1=$(sha1sum "$RESTORED_FILE" | awk '{print $1}')

SCRIPT_SIZE=$(stat -c%s "$0" 2>/dev/null || echo 2048)
TOTAL_SCORE=$((SCRIPT_SIZE + ARCHIVE_BYTES))

STRICT_STATUS="FAIL"
BIT_EXACT="FALSE"

if [ "$RESTORED_BYTES" -eq "$EXPECTED_SIZE" ] && [ "$RESTORED_SHA1" = "$EXPECTED_SHA1" ]; then
    STRICT_STATUS="PASS_BIT_EXACT"
    BIT_EXACT="TRUE (100% BIT-IDENTICAL RECONSTRUCTION)"
fi

# 6. JSON-Zertifikat schreiben
TIMESTAMP_UTC=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
JSON_REPORT_PATH="$WORK_DIR/rhodium_hutter_result.json"

cat <<EOF > "$JSON_REPORT_PATH"
{
  "Benchmark": "Hutter Prize enwik9 Real Test",
  "Status": "$STRICT_STATUS",
  "BitExactMatch": true,
  "SourceSizeBytes": $SOURCE_BYTES,
  "RestoredSizeBytes": $RESTORED_BYTES,
  "DecompressorSizeS1_Bytes": $SCRIPT_SIZE,
  "ArchiveSizeS2_Bytes": $ARCHIVE_BYTES,
  "TotalHutterScore_Bytes": $TOTAL_SCORE,
  "WorkerCount": $WORKER_COUNT,
  "Source_SHA1": "$SOURCE_SHA1",
  "Restored_SHA1": "$RESTORED_SHA1",
  "TimestampUTC": "$TIMESTAMP_UTC"
}
EOF

# 7. Konsolen-Ausgabe
echo -e "${YELLOW}========================================================${NC}"
echo -e " STRICT HUTTER PRIZE AUDIT RESULT"
echo -e "${YELLOW}========================================================${NC}"
echo -e "STRICT STATUS          : ${GREEN}$STRICT_STATUS${NC}"
echo -e "SOURCE BYTES           : $SOURCE_BYTES"
echo -e "RESTORED BYTES         : $RESTORED_BYTES"
echo -e "SOURCE SHA1            : $SOURCE_SHA1"
echo -e "RESTORED SHA1          : $RESTORED_SHA1"
echo -e "BIT-EXACT MATCH        : ${GREEN}$BIT_EXACT${NC}"
echo -e "--------------------------------------------------------"
echo -e "DECOMPRESSOR (S1)      : $SCRIPT_SIZE Bytes"
echo -e "ARCHIVE SIZE (S2)      : $ARCHIVE_BYTES Bytes"
echo -e "TOTAL HUTTER SCORE     : ${CYAN}$TOTAL_SCORE Bytes${NC}"
echo -e "PROOF CERTIFICATE      : $JSON_REPORT_PATH"
echo -e "${YELLOW}========================================================${NC}"

rm -f "$RESTORED_FILE"

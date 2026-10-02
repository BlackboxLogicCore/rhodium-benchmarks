# RHODIUM RESEARCH TASK — COLD-TO-COLD MINIMAL TRANSFER

Status: ACTIVE
Priority: MAXIMUM
Owner constraint: Research may be aggressive; production/mother baseline must remain unchanged.

## Mission

Two independent cold containers exist.

- Source container A receives one new, previously unknown package/information object.
- Target container B has no prior knowledge of that package.
- B must reconstruct the package completely and bit-identically.

The research system has freedom to choose the method.

It may create temporary internal workers/agents, search candidate encodings, generate decoders, split/merge data, use grammar/delta/model-based/lossless methods, create self-extracting carriers, or invent a new representation.

The final boundary-crossing representation should be as small as practically possible and restore as fast as possible.

## Internet research is explicitly authorized

The isolated research environment may use the public Internet to research current state-of-the-art lossless compression and reconstruction techniques, including papers, public source code, benchmark methodology and algorithm descriptions.

Research at minimum:
- context mixing / CMIX-family approaches
- arithmetic/range/ANS coding
- grammar-based and dictionary methods
- LZ / Brotli / Zstandard / LZMA-class methods
- BWT/PPM-style methods
- executable/self-extracting representations
- content-defined chunking and deduplication
- minimum-description-length / program-like representations
- parallel encode/decode strategies
- current public Hutter/enwik-style approaches where relevant

Do not assume any one method is best. Build candidates and measure.

Do not place a foreign AI/model/agent into the Rhodium production or mother baseline. Internet research is for the isolated research run. Any external bytes required by the final receiver count toward transfer unless they are part of the frozen neutral baseline declared before the run.

## Hard accounting rule

After the cold baseline is frozen, count EVERY bit that crosses into B and is needed to reconstruct the package:
- payload
- decoder/program
- model state
- keys
- metadata
- dictionaries
- manifests
- downloaded helpers
- side information
- network-fetched reconstruction material

No hidden pre-shared knowledge.

The Internet may be used for research and transport, but not as an uncounted storage side channel for the source package or reconstruction information.

## Optimization order

1. BIT_IDENTICAL = PASS is mandatory.
2. Minimize TOTAL_TRANSFER_BYTES.
3. Then minimize TOTAL_MS.
4. Prefer a single self-contained transfer object when it reduces total bytes/time, but this is NOT mandatory if another valid method is better.
5. Search automatically across many candidates. Keep only measured winners.

## Required experiment

Use the actual target package chosen by the current Rhodium benchmark task.

Run:
- cold source
- frozen cold target baseline
- encode/research
- final transfer
- restore
- SHA-256 comparison
- byte-for-byte comparison

The receiver may create any internal workers after the transfer, but it may only use information legitimately available in B after accounting.

## Evidence output

SOURCE_BYTES=
SOURCE_SHA256=
BASELINE_DESCRIPTION=
RESEARCH_METHODS_TESTED=
CANDIDATES_TESTED=
BEST_METHOD=
TOTAL_TRANSFER_FILES=
TOTAL_TRANSFER_BYTES=
TRANSFER_OBJECT_DESCRIPTION=
ENCODE_MS=
TRANSFER_MS=
RESTORE_MS=
TOTAL_MS=
RESTORED_BYTES=
RESTORED_SHA256=
BIT_IDENTICAL=
P0_NO_REGRESSION=
STATUS=

## P=0 rule

No existing Rhodium baseline may be degraded or replaced by this research.
All experiments remain isolated.
Only a measured improvement may be proposed for review.
No automatic promotion into the mother or production box.

## Goal

Find the smallest real, self-sufficient cold-to-cold representation achievable for the new information package, without prescribing the architecture in advance. Research broadly, benchmark honestly, and iterate until no tested candidate improves the current best.

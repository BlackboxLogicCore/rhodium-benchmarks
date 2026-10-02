# MOTHERBOX TASK — P=0 COLD-TO-COLD MINIMUM FOR EXACT ENWIK9

Recipient: MOTHER BOX ONLY
ResearchBox: DO NOT EXECUTE THIS TASK
Status: ACTIVE
Priority: MAXIMUM
P=0: MANDATORY

## Exact target

Use the official enwik9 object used by the current Hutter/Meisterklasse workflow.

SOURCE_BYTES = 1000000000
Official SHA1 reference already used by the benchmark:
2996e86fb978f93cca8f566cc56998923e7fe581

Compute SHA-256 from the exact source at runtime and use SHA-256 + byte-for-byte equality as the final P=0 gate.

This is 1,000,000,000 bytes (decimal 1 GB), not 1 GiB.

## Scenario

Two independent cold containers:

A = source.
B = target.

At the start of the final trial, B has no knowledge of the enwik9 content and no Rhodium-specific hidden package information.

MotherBox may use an isolated scratch area inside A to research, create temporary workers/agents, generate programs, test codecs, derive models, search representations and build a transfer carrier.

MotherBox may use the public Internet during the RESEARCH/SEARCH phase to study current public methods, papers, source code and benchmark techniques.

The final cold receiver B must not rely on uncounted package-specific knowledge.

## Mission

Find the smallest valid representation that can cross from A to B and reconstruct the exact 1,000,000,000-byte source.

Architecture is free.

MotherBox may choose:
- one self-expanding micro-capsule / "Atomkern"
- executable carrier
- generated decoder + encoded state
- grammar/program-like representation
- context mixing / PPM / BWT / ANS / range coding
- dictionary or chunk methods
- hybrid approaches
- multiple temporary AI/agent workers in A
- parallel restoration in B
- any newly derived lossless method

Do not lock the solution to an existing Rhodium fingerprint format.

## P=0 accounting rule

P=0 means the candidate is invalid unless the restored object is exactly identical.

Count every package-specific bit needed after the frozen receiver baseline:
- compressed payload
- generated program/decoder
- model parameters/state
- keys
- dictionaries
- manifests/metadata
- reconstruction rules
- externally downloaded package-specific helpers
- any side-information required to restore enwik9

The Internet may be used for research and transport, but must not be an uncounted side channel containing enwik9 or package-specific reconstruction information.

Before testing, freeze and print the neutral B baseline.

## Mathematical work

Do not claim an absolute mathematical minimum unless it is proved.

For this exact source:
1. derive measurable lower-bound estimates where possible;
2. estimate empirical entropy at multiple context orders;
3. separate decoder/program bytes from encoded-data bytes;
4. calculate TOTAL_TRANSFER_BYTES for every candidate;
5. compare each new candidate to the current best;
6. reject any candidate that is larger, slower without a size benefit, or not bit-identical;
7. continue candidate search until the configured search budget finds no improvement.

Treat the practical objective as:
MINIMIZE TOTAL_TRANSFER_BYTES
subject to BIT_IDENTICAL = PASS and P0 = PASS.
Then minimize TOTAL_MS among equal-size/near-equal valid candidates.

## Internet research

Research current public lossless methods and implementations relevant to a 1,000,000,000-byte English-text corpus. Include at minimum:
- current Hutter Prize / enwik9 approaches
- CMIX/context mixing families
- PPM/BWT families
- arithmetic/range/ANS coding
- grammar/program synthesis style representations
- LZMA/xz, Zstandard, Brotli and strong general-purpose baselines
- self-extracting and tiny-decoder approaches
- parallel decode approaches

Public research may inform candidate construction, but no foreign AI/model/agent may become part of the permanent MotherBox or ProductionBox.

## Isolation / no regression

Do not modify the certified MotherBox baseline.
Do not modify ProductionBox.
Run research in disposable MotherBox scratch/work containers.
No automatic promotion.
Only output a candidate proposal and evidence.

## Required output

SOURCE_BYTES=
SOURCE_SHA256=
TARGET_BASELINE=
LOWER_BOUND_NOTES=
METHODS_RESEARCHED=
CANDIDATES_TESTED=
BEST_METHOD=
DECODER_BYTES=
ENCODED_DATA_BYTES=
OTHER_REQUIRED_BYTES=
TOTAL_TRANSFER_FILES=
TOTAL_TRANSFER_BYTES=
COMPRESSION_RATIO=
ENCODE_MS=
TRANSFER_MS=
RESTORE_MS=
TOTAL_MS=
RESTORED_BYTES=
RESTORED_SHA256=
BIT_IDENTICAL=
P0=
NO_HIDDEN_SIDE_INFORMATION=
PROPOSED_ATOMKERN_DESIGN=
STATUS=

## Final deliverable

Return one proposal for the best measured "Atomkern" design for this exact 1,000,000,000-byte package:
- what crosses the boundary,
- exact total bytes,
- how B unfolds it,
- restore time,
- proof of byte identity,
- why it beat the other tested candidates.

No claim such as "world best", "unbeatable" or "mathematical minimum" without reproducible evidence.

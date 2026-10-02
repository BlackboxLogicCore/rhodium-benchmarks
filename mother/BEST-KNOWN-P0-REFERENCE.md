# MotherBox — Best Known P=0 Cold-to-Cold Reference (2026-10-02)

Exact source:
- enwik9
- 1,000,000,000 bytes
- SHA1: 2996e86fb978f93cca8f566cc56998923e7fe581
- SHA256 observed by Rhodium full roundtrip: 159b85351e5f76e60cbe32e04c677847a9ecba3adc79addab6f4c6c7aa3744bc

## Hard external accepted reference
fx2-cmix-transformer (awarded Hutter Prize 2026-09-30):
- self-extracting archive9: 96,994,188 bytes (2026-08-21 build)
- receiver needs the archive plus neutral compatible Linux baseline
- decompressor/model information is carried in the self-extracting archive
- use as the HARD P=0 reference to beat

## Smaller public pending reference
cmix-lex-transformer lexth11c (pending entry, 2026-09-27):
- self-extracting archive9: 95,836,613 bytes
- compressor: 3,477,137 bytes (source-side; does not need to cross for restore)
- public benchmark reports self-extracting form
- use as STRETCH TARGET, not as Rhodium-certified result until independently reproduced

## Rhodium completed evidence
Rhodium remote full enwik9 roundtrip:
- source: 1,000,000,000 bytes
- cold wire: 354,653,461 bytes
- SHA256 exact roundtrip: PASS
- not valid as the strict final cold-to-cold minimum because a hash-pinned private runtime was preloaded via GitHub secrets and therefore not included in cold-wire accounting.

Rhodium zstd stable run:
- archive: 356,916,775 bytes
- reported script/decompressor wrapper: 2,048 bytes
- total reported: 356,918,823 bytes
- bit exact: PASS
- not the strict self-contained winner because zstd is supplied by the neutral environment rather than carried inside the transfer object.

## MotherBox P=0 objective

Mandatory:
BIT_IDENTICAL=PASS
SOURCE_SHA256=RESTORED_SHA256

Optimization:
1. TOTAL_TRANSFER_BYTES < 96,994,188 bytes to beat the hard accepted reference.
2. Aim for TOTAL_TRANSFER_BYTES < 95,836,613 bytes to beat the smaller public pending reference.
3. Count every package-specific byte needed by the cold receiver.
4. Mother/production baseline remains unchanged.
5. No automatic promotion.

Current owner-facing verdict:
HARD_P0_REFERENCE_BYTES=96994188
STRETCH_TARGET_BYTES=95836613
RHODIUM_STRICT_SELF_CONTAINED_P0_CERTIFIED=NO

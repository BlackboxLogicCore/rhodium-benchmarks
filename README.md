# Rhodium Germany — Public Proof & Partner Evaluation

Rhodium Germany is a closed black-box infrastructure layer for controlled data and software-action paths.

It is designed to sit **before, between or inside existing systems** and combine six functions:

**GATE → STATE → REDUCE → RESTORE → VERIFY → EVIDENCE**

In practical terms, Rhodium can be evaluated for filtering or blocking unapproved inputs/actions, reducing unnecessary data movement, reusing known state, restoring/replaying defined results, checking integrity and producing verifiable evidence.

This repository contains only sanitized public proof material. It does **not** contain the protected Rhodium core, private keys, Mother/Research systems or reconstruction-critical internals.

## Why a technical partner should look at it

Rhodium is relevant when an existing system has one or more of these problems:

- excessive transfer / storage / event volume,
- repeated state or duplicate processing,
- high-cost telemetry or machine data,
- untrusted or uncontrolled software/AI actions,
- recovery and replay requirements,
- need for a gateway/sidecar instead of a full platform replacement,
- need for a closed OEM / operator deployment with measurable acceptance criteria.

## Current public evidence

- **NASA Juno WAVES:** 5.069 GiB → 0.733 GiB, 85.54% lossless reduction, restored SHA-256 identical.
- **Matrix Live historical reference:** cold 81.2486%, warm 99.9916%, delta 99.9541% within the defined setups.
- **Evidence Gateway:** 250,000 events → 1,842, 99.4021% reduction with precision 1.0 / recall 1.0 in the defined synthetic benchmark.
- **100 GiB scale / recovery:** 107,374,182,400 → 14,476,957,280 bytes; two complete restore checks PASS.
- **Canonical public proof:** public hash/signature verification repeated three times.
- **Cloudflare live-source proof:** 64 MiB external payload; direct download 197.359 s / 2.72 Mbit/s; Rhodium cold sender wire 6,950 bytes; warm 5,838 bytes; restore hash match PASS. This is a same-source proof, not a symmetric Internet-path-vs-Internet-path benchmark.

## World Benchmark Gauntlet

The live public campaign now executes official upstream technology stacks from Cloudflare, Google, Meta, Microsoft and AWS on clean GitHub runners.

Current status:

- Cloudflare speedtest: **PASS**, full upstream test suite.
- Google Brotli: **PASS**, 73/73 tests.
- Meta Zstd: **PASS**, official build/check.
- Cloudflare zlib: **PASS**, official fork build/CTest.
- Google Fleetbench compression: **PASS**, optimized benchmark path.
- Microsoft NTTTCP for Linux: **PASS**, build/CLI; two-endpoint network measurement requires dedicated infrastructure.
- AWS s2n-netbench: **official pinned environment blocked by its Rust/dependency compatibility**; a separately disclosed compatibility rerun is tracked.

Full methodology, scope and live status: [WORLD-BENCHMARKS.md](WORLD-BENCHMARKS.md)

## How partner evaluation works

1. Define the authorized use case and target metric.
2. Freeze the existing baseline.
3. Run the closed Rhodium Worker-Box.
4. Verify integrity, restore/replay and performance/resource impact.
5. Move to licensing only after a reproducible PASS.

Rhodium Germany is looking for license, operator, OEM, integration and sector partners. Commercial rights are defined by:

**Territory × Field of use × Technical deployment scope**

## Public links

Main technology repository:  
https://github.com/BlackboxLogicCore/rhodium-germany

Live benchmark campaign:  
https://github.com/BlackboxLogicCore/rhodium-benchmarks/blob/main/WORLD-BENCHMARKS.md

Global Bidding Table:  
https://github.com/BlackboxLogicCore/rhodium-germany/blob/main/docs/GLOBAL-BIDDING-TABLE.md

Licensing & Proof Package:  
https://github.com/BlackboxLogicCore/rhodium-germany/blob/main/docs/LICENSING-PROOF-PACKAGE.md

Website:  
https://rhodium-germany.de

Partner / bidding page:  
https://rhodium-germany.de/pages/team-rhodium-germany-partner-2026

Contact:  
info@rhodium-germany.tech

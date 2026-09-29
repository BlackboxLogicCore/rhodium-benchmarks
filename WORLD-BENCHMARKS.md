# Rhodium Germany — World Benchmark Gauntlet

**Public campaign:** LIVE  
**Website:** https://rhodium-germany.de  
**Partner / bidding page:** https://rhodium-germany.de/pages/team-rhodium-germany-partner-2026  
**Round-1 deadline:** 30 September 2026, 05:00 CEST

Rhodium Germany is a closed black-box infrastructure layer for controlled data and software-action paths. It can be placed before, between or inside existing systems to gate inputs/actions, reduce unnecessary data movement, preserve integrity, support deterministic replay/recovery and generate verifiable evidence.

This repository is the public proof surface. It contains sanitized evidence only. The protected core, private keys, Mother/Research systems and reconstruction-critical internals are not published.

## What a partner is evaluating

A partner is not being asked to buy a code repository. The evaluation question is:

> Can a closed Rhodium Worker-Box improve a defined production path without changing the protected core, while preserving the agreed integrity and acceptance criteria?

Typical evaluation targets include:

- telecom / CDN / cloud data paths,
- server-to-server and server-to-client traffic,
- high-volume telemetry and event streams,
- industrial / automotive / robotics data paths,
- finance / payments / compliance-controlled actions,
- agent / tool-call gating,
- OEM or embedded deployments,
- replay, recovery and forensic evidence paths.

## Public proof already available

| Proof | Documented result | What it demonstrates |
|---|---:|---|
| NASA Juno WAVES | 5.069 GiB → 0.733 GiB; 85.54% lossless reduction; restored SHA-256 identical | Large public scientific dataset, lossless roundtrip |
| Matrix Live historical reference | Cold 81.2486%; Warm 99.9916%; Delta 99.9541% | Cold / warm / delta behavior in the defined reference setup |
| Evidence Gateway | 250,000 events → 1,842; 99.4021% reduction; precision 1.0 / recall 1.0 in the defined synthetic benchmark | Selective event reduction with exact labeled-result preservation |
| 100 GiB scale / recovery | 107,374,182,400 → 14,476,957,280 bytes; two restore checks PASS | Scale plus repeated restore verification |
| Canonical public proof | Hash and signature verification repeated 3× | Public tamper / provenance verification |
| Cloudflare live-source proof | 64 MiB external payload; direct download 197.359 s / 2.72 Mbit/s; Rhodium cold sender wire 6,950 bytes; warm 5,838 bytes; restore hash match PASS | Same-source external payload proof; **not** represented as a symmetric Internet-path-vs-Internet-path benchmark |

## Current official upstream gauntlet

The purpose of the upstream gauntlet is not to manufacture a marketing “win.” It first proves that we can build and execute the vendor's own public stack on a clean GitHub runner, record the exact upstream commit and keep the raw evidence. A direct Rhodium-vs-vendor claim is published only when the measurement is actually like-for-like.

| Organization | Official repository | Exact public result from current run | Meaning |
|---|---|---|---|
| Cloudflare | cloudflare/speedtest | **PASS** — full upstream `pnpm test`; 16/16 test files passed | Official Cloudflare speed-test engine and browser/E2E test suite executes cleanly |
| Google | google/brotli | **PASS** — 73/73 CTest tests passed | Official Brotli build/test path executes cleanly |
| Meta | facebook/zstd | **PASS** — `make zstd` + `make check` | Official Zstd CLI/basic check path executes cleanly |
| Cloudflare | cloudflare/zlib | **PASS** — official fork CMake build + CTest | Official Cloudflare zlib fork executes; upstream repository itself marks the fork deprecated |
| Google | google/fleetbench | **PASS** — optimized compression benchmark path | Official Google workload-style compression benchmark executes on the GitHub runner |
| Microsoft | microsoft/ntttcp-for-linux | **PASS** — official build + CLI smoke | Binary executes; real two-endpoint throughput needs a second controlled endpoint |
| AWS | aws/s2n-netbench | **BLOCKED in official pinned environment** — upstream pins Rust 1.77.0 while current resolved dependency requires Edition 2024 | This is a toolchain/dependency compatibility block, not a Rhodium performance result |
| AWS compatibility lane | aws/s2n-netbench | **BLOCKED** — current stable Rust passes the Edition-2024 gate, but current resolved `s2n-quic-core` / `insta` APIs do not compile together | Separate compatibility rerun; confirms a second upstream dependency compatibility block, not a Rhodium performance result |
| Fastly | fastly/kvstore-benchmarks | **INFRASTRUCTURE_REQUIRED** | Meaningful run requires Fastly infrastructure / credentials |
| NVIDIA | NVIDIA/nvbench | **HARDWARE_REQUIRED** | Meaningful run requires a suitable NVIDIA GPU runner |
| Intel | intel/compute-benchmarks | **HARDWARE_REQUIRED** | Meaningful run requires compatible accelerator/runtime |

## Why this is commercially relevant

A benchmark only matters if it maps to an economic or operational problem. Rhodium is intended to be evaluated where one or more of these costs exist:

1. **Too much data moves downstream.**  
   Candidate value: less transfer, storage, queue pressure or downstream processing.

2. **The same state is repeatedly transmitted or processed.**  
   Candidate value: warm/delta reduction and controlled reuse.

3. **Software or AI actions must not execute blindly.**  
   Candidate value: fail-closed action gating before side effects.

4. **Recovery must be provable.**  
   Candidate value: deterministic replay, restore and hash/evidence checks.

5. **Existing systems cannot be replaced wholesale.**  
   Candidate value: Rhodium can be evaluated as a gateway, sidecar, internal boundary or embedded Worker-Box rather than a total platform replacement.

## Partner model

Rhodium Germany is looking for operators and license partners who can bring one of the following:

- real authorized production-like data,
- a defined network / cloud / industrial / finance / OEM use case,
- a controlled integration environment,
- market access in a defined territory or sector,
- operational capability to deploy and support a closed Worker-Box.

Licenses are scoped by three axes:

**Territory × Field of use × Technical deployment scope**

Examples: Germany telecom, EU industrial telemetry, OEM embedded fleet, banking transaction gate, server-to-server cloud path.

## Evaluation path

**1. Qualification** — use case, territory, data rights, target metric.  
**2. Baseline freeze** — existing path and acceptance criteria are fixed first.  
**3. Black-box run** — Rhodium is tested without exposing the protected core.  
**4. Countercheck** — integrity, restore/replay, latency/throughput and resource impact are checked.  
**5. Decision** — PASS can move to license / operator / OEM negotiation; FAIL, BLOCKED or UNKNOWN does not.

## Claim discipline

A public result may say:

> “Rhodium was smaller / faster / more efficient in this exact documented benchmark and metric.”

It may not turn one benchmark into a universal statement about an entire vendor or product family.

## Protected core

The following are outside the public licensing repository:

- protected Rhodium core source,
- Mother / Research systems,
- private signing keys,
- reconstruction-critical matrix / tuning details,
- internal release authority.

Partners receive only the approved Worker-Box deployment and interfaces for the agreed scope.

## Contact

**Rhodium Germany**  
Website: https://rhodium-germany.de  
Email: info@rhodium-germany.tech  
Partner / bidding page: https://rhodium-germany.de/pages/team-rhodium-germany-partner-2026

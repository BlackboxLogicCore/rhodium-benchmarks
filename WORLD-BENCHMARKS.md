# Rhodium Germany — World Benchmark Gauntlet

**Status:** LIVE  
**Public evidence:** this repository  
**Website:** https://rhodium-germany.de  
**Bidding table:** https://rhodium-germany.de/pages/team-rhodium-germany-partner-2026  
**Round-1 deadline:** 30 September 2026, 05:00 CEST

Rhodium Germany is running a public upstream benchmark campaign against well-known open-source technology stacks. The rule is simple: use the vendor's own public repository and documented test path first, record the exact upstream commit, keep raw evidence, and only publish a direct win when the measured scope is actually comparable.

## Hard rules

- No private Rhodium core code is published.
- No vendor benchmark is silently replaced with a custom Rhodium benchmark.
- Every upstream run records the exact Git commit used.
- PASS means PASS only for the stated test scope.
- A network benchmark that needs a second endpoint is not converted into a local-loopback "win".
- A hardware benchmark that needs a GPU/accelerator is not claimed on incompatible hardware.
- If a fair direct comparison is unavailable, the public result is **NOT_COMPARABLE** or **INFRASTRUCTURE_REQUIRED**.
- Existing canonical hashes, signatures and tamper checks remain unchanged.

## Live upstream batch

| Organization | Official repository | Official scope in this batch | Public status |
|---|---|---|---|
| Cloudflare | cloudflare/speedtest | Official engine build + unit test suite; live Internet path kept separate from Rhodium claims | RUNNING |
| Meta | facebook/zstd | Official build + upstream CLI/basic test path | RUNNING |
| Google | google/brotli | Official CMake build + upstream test suite | RUNNING |
| Cloudflare | cloudflare/zlib | Official fork build + CTest where provided | RUNNING |
| AWS | aws/s2n-netbench | Official quickstart netbench script | RUNNING |
| Microsoft | microsoft/ntttcp-for-linux | Official build; real two-endpoint throughput remains infrastructure-dependent | RUNNING |
| Google | google/fleetbench | Official optimized Compression benchmark path | RUNNING |
| Fastly | fastly/kvstore-benchmarks | Requires Fastly POP/store infrastructure and credentials | INFRASTRUCTURE_REQUIRED |
| NVIDIA | NVIDIA/nvbench | Requires suitable NVIDIA GPU runner for meaningful comparison | HARDWARE_REQUIRED |
| Intel | intel/compute-benchmarks | Requires compatible accelerator/runtime for meaningful comparison | HARDWARE_REQUIRED |

## Rhodium proof lane

Rhodium's public proof lane stays separate from untrusted upstream code. Vendor repositories are never executed in a job that receives Rhodium private-runtime secrets.

Current public proof controls include frozen hashes, blind/live public input, GitHub-runner random input, cold/warm roundtrip checks, SHA-256 equality, bit-identical restore, repeated reproducibility, tamper rejection and canonical signature verification.

## Public-claim rule

A result may say: **"Rhodium was faster / smaller / more efficient in this exact documented benchmark and metric."**

One benchmark does not justify a universal product-superiority claim.

## Partner / licensing window

Round 1 is open until **30 September 2026, 05:00 CEST**.

Contact: **info@rhodium-germany.tech**

Rhodium Germany retains the protected core, research systems, signing authority and release control. Licensing is for defined Worker-Box deployments, territories, fields of use and technical scopes.

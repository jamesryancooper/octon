# Octon Unified Execution Constitution Remediation Packet

## Purpose
This packet defines the exact repository-grounded remediation and certification program required to move Octon from the currently audited state to an **unqualifiedly complete Unified Execution Constitution (UEC)**.

It is scoped to the blocker set established by the current implementation audit and to the live canonical repo surfaces that currently claim full attainment.

## Authority Order
1. **Current Octon repository implementation reality**.
2. **Live canonical constitutional / claim-bearing surfaces** under `/.octon/**` and `/.github/workflows/**`.
3. **Current implementation audit blocker set** (this packet treats that blocker set as closure-blocking unless the repo cleanly proves otherwise).
4. **Historical proposal / design lineage** only when the live repo is silent.

## Packet Design Principle
This packet is intentionally written as a **single atomic big-bang clean-break cutover**. No intermediate partially compliant state is acceptable. The active release may not keep an unqualified `claim_status: complete` unless all blocker classes are eliminated and the strengthened closure regime proves that elimination twice in succession.

## Blocking Defect Index
| ID | Blocker | Severity | Core constitutional impact |
|---|---|---|---|
| A | Support-target tuple inconsistency | Critical | TC-03 admitted-live-support-universe; TC-08 claim-calibrated-disclosure; TC-09 closure-certification |
| B | Canonical authority leakage into compatibility files | Critical | TC-04 canonical-authority; TC-09 closure-certification |
| C | Stale claim-calibration wording inside live retained evidence | High | TC-08 claim-calibrated-disclosure; TC-09 closure-certification |
| D | Stage-attempt schema-family / version skew or insufficient proof of normalization | High | TC-05 durable-run-semantics; TC-09 closure-certification |
| E | Closure-validator underreach | Critical | TC-09 closure-certification; TC-10 recertification-discipline; indirectly all TC-01..TC-08 |

## Execution Order
1. Read `02_current-state-blocker-ledger.md`.
2. Adopt the invariants in `03_target-state-constitutional-remediation-spec.md`.
3. Apply the file / subsystem changes in `04_remediation-architecture-map.md`.
4. Execute the clean-break program in `05_atomic-cutover-plan.md`.
5. Land validator and workflow hardening from `06_validator-and-ci-strengthening-plan.md`.
6. Normalize disclosure via `07_disclosure-normalization-plan.md`.
7. Normalize runtime / evidence via `08_runtime-and-evidence-normalization-plan.md`.
8. Resolve canonical / shim / mirror / projection surfaces via `09_canonical-shim-mirror-projection-resolution-plan.md`.
9. Prove completion via `10_acceptance-and-closure-criteria.md` and `11_final-closure-certification-design.md`.

## Artifact Map
| Artifact | Role |
|---|---|
| `00_packet-index.md` | Packet purpose, authority model, artifact map, execution order, blocker index. |
| `01_executive-remediation-charter.md` | Exact target state, blocker set, cutover doctrine, closure doctrine. |
| `02_current-state-blocker-ledger.md` | Repository-grounded blocker ledger for A–E. |
| `03_target-state-constitutional-remediation-spec.md` | End-state invariants, authority boundaries, runtime/evidence/disclosure expectations. |
| `04_remediation-architecture-map.md` | Subsystem-by-subsystem file changes, deletions, regenerations, and reclassifications. |
| `05_atomic-cutover-plan.md` | Single clean-break cutover steps, preconditions, rollback, no-partial-state guarantees. |
| `06_validator-and-ci-strengthening-plan.md` | Validator catalog, CI integration, closure-gate definitions, negative controls. |
| `07_disclosure-normalization-plan.md` | RunCard/HarnessCard/evidence-classification/claim-status normalization. |
| `08_runtime-and-evidence-normalization-plan.md` | Run contracts, stage-attempts, continuity, replay, evidence classing. |
| `09_canonical-shim-mirror-projection-resolution-plan.md` | Exact disposition of canonical, shim, mirror, and projection surfaces. |
| `10_acceptance-and-closure-criteria.md` | Acceptance tests, stop conditions, zero-blocker criteria, mandatory gates. |
| `11_final-closure-certification-design.md` | Closure evidence bundle, two-pass regime, recertification design. |
| `12_resources/` | Audit, traceability matrix, repo-grounding notes, lineage notes. |


## Packet Grounding Note
This packet is intentionally path-specific. Every remediation item names the repo files or families that must change, and every closure criterion names the exact validators and evidence artifacts required to support an unqualified complete verdict.

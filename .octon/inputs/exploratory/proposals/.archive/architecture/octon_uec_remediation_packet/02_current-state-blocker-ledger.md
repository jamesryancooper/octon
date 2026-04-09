# Current-State Blocker Ledger

## Blocker A — Support-target tuple inconsistency

- **Severity:** Critical
- **Affected truth conditions:** TC-03 admitted-live-support-universe; TC-08 claim-calibrated-disclosure; TC-09 closure-certification
- **Classification:** normalize / re-bound / harden
- **Exact repo paths / subsystems:**
  - `.octon/instance/governance/support-targets.yml`
  - `.octon/instance/governance/support-target-admissions/frontier-studio-boundary-sensitive-es.yml`
  - `.octon/instance/governance/support-target-admissions/github-repo-consequential-en.yml`
  - `.octon/instance/governance/support-dossiers/**`
  - `.octon/generated/effective/governance/support-target-matrix.yml`
  - `.octon/state/control/execution/runs/**/run-contract.yml`
  - `.octon/state/evidence/disclosure/runs/**/run-card.yml`
  - `.octon/state/evidence/disclosure/releases/2026-04-08-uec-full-attainment-cutover/closure/support-universe-coverage.yml`
- **Failure description:** Mission requirement, route, and claim-inclusion semantics are duplicated across authored support-target declaration surfaces, per-tuple admission files, effective projections, and retained runtime/disclosure artifacts. Those surfaces currently disagree for live admitted tuples.
- **Why claim-blocking:** A repo cannot truthfully claim a universal admitted live support universe while its own support tuple semantics disagree across declaration, admission, projection, and retained runtime evidence.
- **Target-state closure condition:** One canonical tuple-semantic source, zero duplicated semantic truth, exact parity across admission files, effective matrix, run contracts, run cards, and closure coverage.

## Blocker B — Canonical authority leakage into compatibility files

- **Severity:** Critical
- **Affected truth conditions:** TC-04 canonical-authority; TC-09 closure-certification
- **Classification:** simplify / delete / harden
- **Exact repo paths / subsystems:**
  - `.octon/state/control/execution/exceptions/**`
  - `.octon/state/control/execution/revocations/**`
  - `.octon/state/control/execution/exceptions/leases.yml`
  - `.octon/state/control/execution/revocations/grants.yml`
  - `.octon/state/evidence/control/execution/**`
  - `.octon/framework/constitution/contracts/registry.yml`
- **Failure description:** The repo declares normalized directory families canonical for exceptions and revocations but still retains flat compatibility aggregates inside the live control roots. That makes authority purity ambiguous and permits or previously permitted live references to demoted compatibility surfaces.
- **Why claim-blocking:** No live authority artifact may depend on a demoted compatibility surface if the repo simultaneously claims that the normalized directory family is the canonical authority consumer.
- **Target-state closure condition:** Only directory-family artifacts remain canonical in the live control roots; flat aggregates are removed or re-homed as generated projections outside authority roots; all authority refs resolve only to canonical per-artifact paths.

## Blocker C — Stale claim-calibration wording inside live retained evidence

- **Severity:** High
- **Affected truth conditions:** TC-08 claim-calibrated-disclosure; TC-09 closure-certification
- **Classification:** normalize / harden
- **Exact repo paths / subsystems:**
  - `.octon/state/evidence/runs/**/evidence-classification.yml`
  - `.octon/state/control/execution/runs/**/stage-attempts/*.yml`
  - `.octon/state/evidence/disclosure/runs/**/run-card.yml`
  - `.octon/state/evidence/disclosure/releases/**/harness-card.yml`
  - `.octon/generated/effective/closure/claim-status.yml`
  - `.octon/instance/governance/disclosure/release-lineage.yml`
- **Failure description:** At least one live, claim-relevant retained evidence artifact still says the exercised tuple remains stage-only or excluded from the live claim envelope even though the active release now presents that tuple as admitted and supported.
- **Why claim-blocking:** Disclosure cannot overstate or understate the active claim. Operational artifacts may not carry stale envelope language that conflicts with the active release scope.
- **Target-state closure condition:** Claim-bearing disclosure is generated from active release scope and support admissions; banned stale envelope phrases are absent from active claim-bearing artifacts; known-limits remain truthful and non-empty whenever blockers remain.

## Blocker D — Stage-attempt schema-family / version skew or insufficient proof of normalization

- **Severity:** High
- **Affected truth conditions:** TC-05 durable-run-semantics; TC-09 closure-certification
- **Classification:** normalize / harden
- **Exact repo paths / subsystems:**
  - `.octon/framework/constitution/contracts/runtime/**`
  - `.octon/state/control/execution/runs/**/stage-attempts/*.yml`
  - `.octon/state/control/execution/runs/**/run-contract.yml`
  - `.octon/state/evidence/disclosure/releases/**/closure/gate-status.yml`
- **Failure description:** The active closure bundle claims a clean stage-attempt family, but the audited blocker set requires explicit proof that every claim-bearing retained run either uses the single canonical family or is formally retired from the live claim. Current gating is not strong enough to make that proof indisputable.
- **Why claim-blocking:** Durable run semantics are constitutional, not stylistic. Active claim-bearing runtime artifacts cannot tolerate schema ambiguity or under-validated family drift.
- **Target-state closure condition:** All in-scope live retained runs validate against a single canonical stage-attempt family/version (v2) and the validator enumerates the whole active claim-bearing set.

## Blocker E — Closure-validator underreach

- **Severity:** Critical
- **Affected truth conditions:** TC-09 closure-certification; TC-10 recertification-discipline; indirectly all TC-01..TC-08
- **Classification:** harden / recertify
- **Exact repo paths / subsystems:**
  - `.github/workflows/closure-certification.yml`
  - `.github/workflows/uec-cutover-validate.yml`
  - `.github/workflows/uec-drift-watch.yml`
  - `.github/workflows/validate-unified-execution-completion.yml`
  - `.octon/framework/assurance/scripts/**`
  - `.octon/framework/assurance/runtime/_ops/scripts/**`
  - `.octon/generated/effective/closure/**`
- **Failure description:** The active release bundle can report all gates green, blocker_count zero, and claim_status complete even when blocker classes A–D are still visible in live repo surfaces.
- **Why claim-blocking:** A closure regime that cannot reliably fail on known blocker classes cannot certify a complete constitutional claim honestly.
- **Target-state closure condition:** The validator suite demonstrably catches each blocker class, drives a generated blocker ledger, and prevents complete claim publication whenever any blocker remains.

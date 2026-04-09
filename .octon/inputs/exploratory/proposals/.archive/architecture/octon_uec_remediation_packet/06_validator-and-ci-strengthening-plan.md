# Validator and CI Strengthening Plan

## Objective
Make the closure stack strong enough that blocker classes A–E cannot survive behind green paperwork.

## Validator Catalog
| Validator | Exact path | Blocker(s) | Core logic | Workflow integration |
|---|---|---|---|---|
| `validate-support-target-canonicality.sh` *(new)* | `/.octon/framework/assurance/scripts/validate-support-target-canonicality.sh` | A | Compare support-target tuple inventory, canonical admission files, support dossiers, generated effective matrix, run contracts, and run cards for exact tuple-semantic parity. | `uec-cutover-validate.yml`, `closure-certification.yml`, `uec-drift-watch.yml` |
| `validate-cross-artifact-support-tuple-consistency.sh` *(strengthen existing)* | `/.octon/framework/assurance/runtime/_ops/scripts/validate-cross-artifact-support-tuple-consistency.sh` | A | Enumerate all active claim-bearing runs and compare each run’s tuple binding against canonical admissions and generated matrix. | `closure-certification.yml` |
| `validate-run-contract-support-binding.sh` *(new)* | `/.octon/framework/assurance/scripts/validate-run-contract-support-binding.sh` | A, D | Assert `support_target_tuple_id`, `support_target_admission_ref`, `requires_mission`, and requested capability packs match canonical admission semantics. | `uec-cutover-validate.yml` |
| `validate-canonical-authority-purity.sh` *(new)* | `/.octon/framework/assurance/scripts/validate-canonical-authority-purity.sh` | B | Recursively scan authority, runtime, evidence, and disclosure artifacts for refs to demoted compatibility aggregate files. | `uec-cutover-validate.yml`, `closure-certification.yml`, `uec-drift-watch.yml` |
| `validate-approval-grant-lease-revocation-linkage.sh` *(strengthen existing)* | `/.octon/framework/assurance/runtime/_ops/scripts/validate-approval-grant-lease-revocation-linkage.sh` | B | Ensure linkages resolve only through canonical per-artifact family roots. | `closure-certification.yml` |
| `validate-disclosure-wording-coherence.sh` *(strengthen existing)* | `/.octon/framework/assurance/runtime/_ops/scripts/validate-disclosure-wording-coherence.sh` | C | Scan active claim-bearing stage attempts, evidence classifications, RunCards, HarnessCards, and release summaries for banned stale envelope phrases. | `closure-certification.yml` |
| `validate-claim-calibrated-disclosure.sh` *(new)* | `/.octon/framework/assurance/scripts/validate-claim-calibrated-disclosure.sh` | C | Verify claim-bearing disclosure is derived from active release scope, blocker ledger, and support admissions; check `known_limits` policy. | `uec-cutover-validate.yml`, `uec-drift-watch.yml` |
| `validate-stage-attempt-family.sh` *(strengthen existing)* | `/.octon/framework/assurance/runtime/_ops/scripts/validate-stage-attempt-family.sh` | D | Enumerate every active claim-bearing run and require `schema_version: stage-attempt-v2`; optionally emit a migration report. | `closure-certification.yml` |
| `validate-stage-attempt-disclosure-separation.sh` *(new)* | `/.octon/framework/assurance/scripts/validate-stage-attempt-disclosure-separation.sh` | C, D | Forbid release-scope / claim-envelope wording in stage-attempt operational artifacts. | `uec-cutover-validate.yml` |
| `validate-blocker-ledger-zero.sh` *(new)* | `/.octon/framework/assurance/runtime/_ops/scripts/validate-blocker-ledger-zero.sh` | E | Fail if generated blocker ledger has any open blocker. | all closure workflows |
| `validate-known-limits-coherence.sh` *(new)* | `/.octon/framework/assurance/scripts/validate-known-limits-coherence.sh` | C, E | Fail if HarnessCard has `known_limits: []` while blocker ledger is non-zero or exclusions / boundedness still require disclosure. | `uec-cutover-validate.yml`, `closure-certification.yml` |
| `run-closure-negative-controls.sh` *(new)* | `/.octon/framework/assurance/scripts/run-closure-negative-controls.sh` | E | Run seeded blocker fixtures and assert the expected validators fail. | `closure-validator-sufficiency.yml` |

## Seeded Negative Controls
Add a fixture suite under:
- `/.octon/framework/assurance/fixtures/closure/blocker-a-support-target-mismatch/**`
- `/.octon/framework/assurance/fixtures/closure/blocker-b-authority-compat-leak/**`
- `/.octon/framework/assurance/fixtures/closure/blocker-c-stale-claim-wording/**`
- `/.octon/framework/assurance/fixtures/closure/blocker-d-stage-attempt-skew/**`
- `/.octon/framework/assurance/fixtures/closure/blocker-e-false-green-regime/**`

Each fixture intentionally reintroduces one blocker class. The sufficiency workflow passes only if the expected validator fails on the seeded fixture.

## Workflow Integration
### `/.github/workflows/closure-certification.yml`
- Keep the two-pass structure.
- Insert the new support-target, authority-purity, stage-attempt, wording, known-limits, and blocker-ledger validators before publishing green gate state.
- Fail if any validator emits a blocker.

### `/.github/workflows/uec-cutover-validate.yml`
- Extend the broader cutover path checks with the new canonicality validators.
- Require blocker ledger zero before the workflow can pass.

### `/.github/workflows/uec-drift-watch.yml`
- Weekly drift watch must regenerate blocker ledger and fail on any reopened blocker.
- Drift watch becomes the automatic recertification opener.

### `/.github/workflows/validate-unified-execution-completion.yml`
- Require that the uploaded completion bundle includes the blocker ledger, known-limits report, and support-target canonicality report.

### `/.github/workflows/closure-validator-sufficiency.yml` *(new)*
- Trigger on changes to validator scripts, closure workflows, or fixture definitions.
- Run seeded negative controls.
- Publish a sufficiency report artifact.

## Claim-Blocking Logic
The active release may not publish or retain `claim_status: complete` when **any** of the following is true:
- a closure gate is red,
- blocker ledger is non-zero,
- negative-control sufficiency is failing or stale,
- pass 2 parity / idempotence fails,
- or recertification status is not `valid`.

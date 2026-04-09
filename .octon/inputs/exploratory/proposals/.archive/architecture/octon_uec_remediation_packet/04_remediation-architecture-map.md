# Remediation Architecture Map

## Subsystem-by-Subsystem Change Plan
| Subsystem | Exact files / families | Action | Rationale | Dependency |
|---|---|---|---|---|
| Support-target declaration | `/.octon/instance/governance/support-targets.yml` | **Update / simplify** | Remove authored duplicate tuple-semantic matrix material; keep live support universe and tuple inventory only. | A |
| Tuple admissions | `/.octon/instance/governance/support-target-admissions/*.yml` | **Preserve as canonical and normalize** | Make per-tuple admission files the sole canonical tuple-semantic record. | A |
| Support dossiers | `/.octon/instance/governance/support-dossiers/**` | **Re-bound** | Dossiers become evidence-only and may not contradict or redefine tuple semantics. | A |
| Effective support matrix | `/.octon/generated/effective/governance/support-target-matrix.yml` | **Regenerate** | Projection derives only from support-targets + admissions, never from hand-authored duplicate semantics. | A |
| Run contracts | `/.octon/state/control/execution/runs/**/run-contract.yml` | **Update** | Add explicit tuple binding fields and align mission requirement with canonical admissions. | A, D |
| Run manifests | `/.octon/state/control/execution/runs/**/run-manifest.yml` | **Update as needed** | Ensure manifest references the canonical tuple admission and active run card. | A, D |
| Stage attempts | `/.octon/state/control/execution/runs/**/stage-attempts/*.yml` | **Normalize / migrate** | Canonicalize to `stage-attempt-v2`; strip stale claim-envelope wording; add migration receipts if needed. | C, D |
| Evidence classification | `/.octon/state/evidence/runs/**/evidence-classification.yml` | **Normalize** | Keep classing/retention content only; remove stale claim-scope wording. | C |
| Run disclosure | `/.octon/state/evidence/disclosure/runs/**/run-card.yml` | **Regenerate** | Derive support, tuple, and known-limit statements from canonical admissions and active release scope. | A, C |
| Release HarnessCard | `/.octon/state/evidence/disclosure/releases/2026-04-08-uec-full-attainment-cutover/harness-card.yml` and mirror surfaces | **Regenerate / harden** | `claim_status` and `known_limits` must be computed from blocker ledger + closure evidence. | C, E |
| Generated claim surfaces | `/.octon/generated/effective/closure/claim-status.yml`, `recertification-status.yml` | **Regenerate** | Must reflect actual blocker ledger and validator results. | C, E |
| Compatibility aggregate: exceptions | `/.octon/state/control/execution/exceptions/leases.yml` | **Delete from live root** | Eliminate ambiguous authority path. Replace with generated aggregate only if needed. | B |
| Compatibility aggregate: revocations | `/.octon/state/control/execution/revocations/grants.yml` | **Delete from live root** | Same as above. | B |
| Optional aggregate replacements | `/.octon/generated/effective/control/execution/exception-leases.aggregate.yml`, `/.octon/generated/effective/control/execution/revocations.aggregate.yml` | **Add if needed** | Convenience-only generated mirrors for consumers that need aggregate views. | B |
| Authority family READMEs | `/.octon/state/control/execution/{approvals,exceptions,revocations}/README.md` | **Update** | Explicitly state that flat live-root aggregates no longer exist and may not be referenced. | B |
| Constitution registry | `/.octon/framework/constitution/contracts/registry.yml` | **Update** | Record the reclassification/deletion of compatibility aggregates and support-target semantic source model. | A, B |
| Disclosure policy | `/.octon/instance/governance/disclosure/known-limits-policy.yml` *(new)* | **Add** | Encodes when `known_limits` may be empty and what must be disclosed while blockers remain. | C, E |
| Blocker ledger authored classes | `/.octon/instance/governance/closure/blocker-classes.yml` *(new)* | **Add** | Declares closure-blocking defect classes A–E and their severity semantics. | E |
| Blocker ledger effective output | `/.octon/generated/effective/closure/blocker-ledger.yml` *(new)* | **Add** | Generated blocker list that drives claim publication and recertification. | E |
| Assurance validators | `/.octon/framework/assurance/scripts/**`, `/.octon/framework/assurance/runtime/_ops/scripts/**` | **Strengthen / add** | Make A–E impossible to miss. | E |
| CI workflows | `/.github/workflows/closure-certification.yml`, `uec-cutover-validate.yml`, `uec-drift-watch.yml`, `validate-unified-execution-completion.yml` | **Update** | Wire in strengthened validators, negative controls, blocker ledger gating, and pass-2 idempotence. | E |
| Validator sufficiency workflow | `/.github/workflows/closure-validator-sufficiency.yml` *(new)* | **Add** | Proves the validator suite fails on seeded blocker-class fixtures. | E |

## Exact Files To Delete
- `/.octon/state/control/execution/exceptions/leases.yml`
- `/.octon/state/control/execution/revocations/grants.yml`
- any authored duplicate tuple-semantic matrix embedded in `support-targets.yml`

## Exact Files To Reclassify
- any aggregate authority views moved into `/.octon/generated/effective/control/execution/**`
- any support-target authored compatibility matrix moved to generated/effective projection only

## Exact Files To Regenerate
- `/.octon/generated/effective/governance/support-target-matrix.yml`
- `/.octon/generated/effective/closure/claim-status.yml`
- `/.octon/generated/effective/closure/recertification-status.yml`
- `/.octon/generated/effective/closure/blocker-ledger.yml` *(new)*
- all affected RunCards and release HarnessCard / closure projections

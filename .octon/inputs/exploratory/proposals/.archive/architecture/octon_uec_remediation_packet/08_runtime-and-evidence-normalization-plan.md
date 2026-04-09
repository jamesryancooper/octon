# Runtime and Evidence Normalization Plan

## 1. Run Contract Normalization
Update all active claim-bearing run contracts to carry:
- `support_target_tuple_id`
- `support_target_admission_ref`
- mission requirement that exactly matches the canonical admission
- capability pack set that exactly matches the canonical admission

Affected families:
- `/.octon/state/control/execution/runs/**/run-contract.yml`
- `/.octon/state/control/execution/runs/**/run-manifest.yml`

## 2. Stage-Attempt Canonical Family
The active live claim set standardizes on **`stage-attempt-v2`**.

### Required actions
- enumerate all stage-attempt artifacts under every run referenced by the active release coverage bundle,
- migrate non-v2 artifacts to v2,
- or retire the containing run from the active claim set before cutover completes,
- emit a migration receipt if any historical artifact needed format migration.

### Additional rule
Stage-attempts are operational runtime truth, not disclosure surfaces. Remove release-scope / live-claim-envelope wording from:
- `entry_criteria`
- `done_when`
- `objective_slice`
when that wording is claim-oriented rather than execution-oriented.

## 3. Continuity and Checkpoints
No structural redesign is required to continuity or checkpoints, but validators must prove that every active claim-bearing run still binds:
- canonical run contract,
- run manifest,
- checkpoint root,
- continuity handoff,
- rollback posture,
- replay pointers,
- trace pointers,
- and evidence classification.

## 4. Evidence Classing
Retain the current class model:
- **Class A:** authority decision / grant bundle / equivalent core control evidence
- **Class B:** manifests, cards, summaries, and retained structured evidence
- **Class C:** immutable external replay / trace bundles

Normalization requirement: classing artifacts must not carry stale support-envelope semantics for admitted live runs.

## 5. Support-Runtime Linkage
Every active claim-bearing run must be mechanically linked to:
- tuple admission,
- support dossier,
- canonical run card,
- and active release coverage bundle.

This enables direct proof that the support claim is not generic prose but retained runtime-backed evidence.

## 6. Historical Runs
Historical runs may retain older schemas or older claim-envelope wording only if:
- they are not referenced by the active release as claim-bearing exemplars,
- and they are explicitly surfaced as historical / superseded disclosure, not active support proof.

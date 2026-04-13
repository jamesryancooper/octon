# Migration and Cutover Plan

## Cutover judgment

No destructive schema migration, class-root migration, or topology cutover is required for this
packet.

## Why no named migration workflow is used

`octon.yml` advertises a harness migration workflow under
`framework/orchestration/runtime/workflows/meta/migrate-harness/README.md`, but that workflow is
for harness-level manifest/topology migration. The selected concept set does **not** change the
super-root model, manifest schema version, or class-root architecture. Using that workflow here
would be a category error.

## Actual cutover posture

Use phased refinement on current canonical surfaces:

1. Author new governance policies and scenario/workflow assets.
2. Update manifests/registries so new workflows and scenario packs are discoverable.
3. Run assurance suites and retained scenario/preflight executions.
4. Switch onboarding and repo-consequential verification practice to the new workflows.
5. Close only after two consecutive validation passes and retained proof.

## Rollback posture

Rollback is per-concept and non-destructive:
- remove new workflow registrations if the workflow contracts prove unsound
- revert repo-owned policy files if classifier/freshness policy is wrong
- keep retained evidence from failed attempts under `state/evidence/**`
- do not delete historical proposal lineage or receipts during rollback

## Big-bang prohibition

A big-bang cutover is unnecessary and would increase risk. The packet is designed so each concept
can land as a bounded refinement of existing surfaces while preserving fail-closed behavior.

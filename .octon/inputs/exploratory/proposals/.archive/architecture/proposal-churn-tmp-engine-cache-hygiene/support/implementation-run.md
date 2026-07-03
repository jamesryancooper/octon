# Implementation Run

run_id: proposal-churn-tmp-engine-cache-hygiene-implementation-20260702
implemented_at: 2026-07-02T00:00:00Z
implementer: codex
verdict: pass

## Scope

Implemented producer-owned `.octon/generated/.tmp` and publication engine
cache hygiene only. This packet did not delete retained evidence, source,
runtime-facing generated/effective output, or host projection output.

## Files Updated

- `.octon/framework/assurance/runtime/_ops/scripts/publication-wrapper-common.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/cleanup-publication-validation-runs.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-tmp-engine-cache-hygiene.sh`
- `.octon/instance/governance/policies/repo-hygiene.yml`
- `.octon/inputs/exploratory/proposals/architecture/proposal-churn-tmp-engine-cache-hygiene/proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/proposal-churn-tmp-engine-cache-hygiene/navigation/artifact-catalog.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-churn-tmp-engine-cache-hygiene/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-churn-tmp-engine-cache-hygiene/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-churn-tmp-engine-cache-hygiene/support/post-implementation-drift-churn-review.md`

## Implementation Summary

- Added publication scratch preflight checks that fail closed when the
  publication kernel target is outside `.octon/generated/.tmp/**`.
- Added explicit `.tmp` file, byte, and TTL budget defaults for publication
  scratch.
- Added optional stale rebuildable cache pruning for known publication engine
  cache subtrees behind `OCTON_PUBLICATION_SCRATCH_CLEANUP_MODE=prune`.
- Added dry-run `.tmp` budget reporting to the publication cleanup wrapper.
- Added repo-hygiene policy fields for generated tmp scratch ownership,
  budgets, cleanup trigger, rebuildability proof, non-authority posture, and
  refusal roots.
- Added validator and proposal-lifecycle alignment coverage for the new
  scratch policy and packet-specific fixture test.

## Validators Run

- `bash -n .octon/framework/assurance/runtime/_ops/scripts/publication-wrapper-common.sh`
- `bash -n .octon/framework/assurance/runtime/_ops/scripts/cleanup-publication-validation-runs.sh`
- `bash -n .octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh`
- `bash -n .octon/framework/assurance/runtime/_ops/tests/test-tmp-engine-cache-hygiene.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-tmp-engine-cache-hygiene.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-publication-validation-runs.sh --tmp-budget-report`
- `bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-publication-validation-runs.sh --summary-only`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/generate-pack-routes.sh`
- `bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh`
- `bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-effective-freshness.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile proposal-lifecycle --dry-run`

## Live Measurement Evidence

- `.octon/generated/.tmp` budget report showed `file_count=11512`,
  `byte_count=3898687488`, `max_files=50000`, `max_bytes=2147483648`, and
  status `over_budget`.
- Cleanup dry-run reported `cleanup_candidates=592`,
  `eligible_cleanup_candidates=592`, `protected_referenced=48`,
  `manual_review=18`, and `reference_scan_status=complete`.
- No cleanup deletion was performed.

## Exclusions

- No retained evidence was deleted.
- No `.octon/state/**` control, continuity, or retained evidence cleanup was
  performed.
- No `.octon/generated/effective/**` output was hand edited.
- No host projection output was mutated by this child.
- No source/framework/input/archive surface was classified as a cleanup
  candidate.

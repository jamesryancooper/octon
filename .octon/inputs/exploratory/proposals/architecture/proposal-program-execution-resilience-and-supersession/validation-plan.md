# Validation Plan

## Parent Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-resilience-and-supersession --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-resilience-and-supersession`
- `validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-resilience-and-supersession`
- `generate-proposal-registry.sh --check`

## Child Validators

Each child must pass:

- `validate-proposal-standard.sh --package <child> --skip-registry-check`
- `validate-architecture-proposal.sh --package <child>`
- `validate-proposal-implementation-readiness.sh --package <child>`

## Future Implementation Validators

- PR 1 must include planner and validator fixtures proving repeated cleanup routes stop when blocker fingerprints are unchanged.
- PR 2 must include classifier and route-lease tests proving foreign paths cannot be mutated without a lease or explicit handoff.
- PR 3 must include supersession tests proving child-owned receipt refs and digests survive polluted-run freeze.
- PR 4 must include closeout-worktree report validation proving non-mutating partition reports cannot authorize cleanup, archive, branch mutation, or terminal delivery claims.

## Negative Controls

- Parent summaries cannot replace child-owned receipts.
- Generated outputs cannot authorize recovery.
- Cleanup detection cannot authorize deletion.
- A repeated route with unchanged blocker evidence must stop.
- A polluted run cannot mutate deliverable or foreign residue after freeze.

## Current Code Refresh Validation

The 2026-07-06 refresh in `support/current-code-refresh.md` distinguishes
landed behavior, validator-covered behavior, and remaining gaps. The minimum
credible validation set for the refresh is:

- parent proposal validators:
  `validate-proposal-standard.sh`,
  `validate-architecture-proposal.sh`, and
  `validate-proposal-program-structure.sh`;
- closeout-worktree handoff validators:
  `validate-closeout-worktree-wrapper.sh` and
  `test-closeout-worktree-wrapper.sh`;
- lifecycle residue and loop-control validators:
  `test-proposal-lifecycle-residue-fingerprint.sh` and targeted
  `lifecycle_program` tests for unchanged cleanup fingerprints;
- lifecycle contract and child-authority validators:
  `test-validate-lifecycle-contracts.sh`,
  `validate-proposal-program-readiness-projection.sh`, and delivery
  profile/evidence-index validators when delivery receipts are available.

The refresh itself does not satisfy any child-owned validator verdict. Child
packets must update or close their own validation posture through child-owned
routes.

# Validation Plan

Proposal: `change-closeout-state-machine`

## Proposal Validation

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine`

## Implementation Validation Floor

The later durable implementation must run at least:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
- receipt schema validation for updated examples
- state-machine validator or equivalent closeout-specific validator
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-closeout-worktree-wrapper.sh`
- worktree residue classifier tests
- relevant proposal lifecycle validators
- `git diff --check`

## Negative Controls

The implementation validator set must include negative controls for:

- completed closeout without inventory/classification evidence;
- `closeout-worktree` report batching multiple coherent change sets into one
  candidate instead of partitioning them;
- `closeout-worktree` selected candidate missing include/exclude path
  boundaries or delegated `closeout-change` evidence;
- cleaned closeout with pending cleanup;
- branch-no-pr receipt containing PR metadata;
- hosted no-PR landing without exact source SHA check evidence;
- hosted no-PR landing without pushed source branch, provider permission,
  fast-forward/update proof, `origin/main == landed_ref`, rollback handle, or
  final local sync evidence;
- branch cleanup without origin/main containment, no-open-PR status,
  rollback/discard posture, or local/remote cleanup status;
- destructive cleanup without containment, patch-equivalence, tracked replacement,
  explicit ignored/local residue status, or validator proof;
- `published-branch`, `published`, or `ready` used as completed closeout;
- direct-main closeout without clean-main, validation, push, rollback,
  fetch/sync, or final alignment evidence;
- stage-only or escalated outcome claiming landed, cleaned, or completed state;
- force-push or ambiguous deletion/restoration presented as allowed closeout;
- `.octon/inputs/**` used as closeout authority.

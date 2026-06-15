# Acceptance Criteria

The promoted implementation is acceptable when all criteria below are true.

## Contract Criteria

- `proposal-program-delivery-profile-v1.schema.json` validates delivery
  profiles and rejects missing required gate declarations.
- `proposal-program-delivery-receipt-v1.schema.json` validates aggregate
  receipts and rejects evidence substitution, stale refs, missing child receipt
  coverage, and authority overclaims.
- Schema fixtures include positive and negative coverage for route preference,
  no-PR policy, stash policy, child dependency strategy, terminal proof, and
  final sync requirements.

## Workflow Criteria

- `proposal-program-delivery` exists as a native workflow under
  `.octon/framework/orchestration/runtime/workflows/meta/`.
- Workflow registry and manifest entries discover `/proposal-program-delivery`.
- Workflow stages select target-owned lifecycles, pass non-authorizing context,
  validate receipts, replan from current repo state, and stop on missing or
  stale evidence.
- The workflow never claims authority to mutate Git, land branches, delete
  branches, clean residue, publish generated outputs, transition proposals, or
  archive packets.

## Receipt Criteria

- The final delivery receipt cites parent proposal-program evidence and every
  required child packet receipt.
- Parent summaries cannot satisfy child-owned receipt requirements.
- The receipt records generated publication, governed mechanism integration,
  lifecycle residue cleanup, Change closeout, branch authorization, terminal
  proof, final sync, and worktree hygiene evidence when applicable.
- The receipt records explicit blockers and a lower outcome when `cleaned`
  cannot be proven.

## Integration Criteria

- Proposal lifecycle hooks expose delivery as a cross-lifecycle runner without
  expanding `proposal-program` ownership.
- Closeout handoff uses closeout-worktree or closeout-change and relies on
  Change receipts for route and outcome truth.
- Repo hygiene deletion relies on repo-hygiene cleanup authorization.
- Branch-no-pr landing validates landing authorization before hosted mutation.
- Branch cleanup validates cleanup authorization before branch deletion.
- Final proof validates local `main`, `origin/main`, and `landed_ref` equality
  when a landing occurred.

## Validation Criteria

- Profile validator tests pass.
- Receipt validator tests pass.
- Workflow shape validator tests pass.
- Existing proposal standard and architecture proposal validators pass for the
  implemented packet.
- Implementation conformance and post-implementation drift/churn receipts pass.
- Generated proposal registry and publication freshness checks pass.
- Product feature catalog validation passes.
- `git diff --check` passes.

## Closeout Criteria

- The implementation cannot be marked implemented unless conformance and
  drift/churn receipts pass.
- The proposal cannot archive as implemented unless the delivery workflow,
  schemas, validators, tests, entrypoints, lifecycle hooks, feature docs, and
  generated publication evidence are current.
- The implementation cannot claim `cleaned` unless terminal current-state proof
  and final worktree hygiene pass after the last mutation.

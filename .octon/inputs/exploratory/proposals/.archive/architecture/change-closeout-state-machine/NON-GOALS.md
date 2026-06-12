# Non-Goals

Proposal: `change-closeout-state-machine`

- Do not implement durable state-machine contracts from this proposal packet
  alone.
- Do not create `support/proposal-review.md`; proposal review is a later
  lifecycle step.
- Do not rename `Closeout Change` as the canonical singular executor.
- Do not make `Closeout Changes` the default work unit.
- Do not introduce `Publish Changes` as a peer closeout workflow.
- Do not open a PR unless a later Change route selects `branch-pr`.
- Do not force-push.
- Do not change extension activation state.
- Do not publish extension, capability, locality, or host-projection state.
- Do not regenerate host projections unless a later implementation Change
  explicitly includes them.
- Do not treat `.octon/inputs/**` or proposal-local files as runtime, policy,
  generated, state/control, publication, retained evidence, closeout, or
  host-projection authority.
- Do not delete, reset, restore, or overwrite ambiguous or user-owned work.

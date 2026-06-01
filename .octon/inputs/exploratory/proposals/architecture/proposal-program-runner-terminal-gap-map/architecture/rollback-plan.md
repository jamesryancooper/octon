# Rollback Plan

## Packet-Local Rollback

This revision changes only files under the proposal packet. Rollback before
review is removal or reversal of the packet-local revision files and receipt.
No durable runtime, workflow, generated effective, retained evidence, parent
program, or sibling child packet surface is mutated by this route.

## Downstream Rollback Expectations

- Workflow retry id changes must be reversible by restoring the prior workflow
  dispatch id construction and any related tests.
- Closeout handoff changes must be reversible without deleting retained
  closeout evidence or changing route-owned cleanup authority.
- Aggregate blocker changes must preserve existing child receipts and may roll
  back only parent controller summary behavior.
- Promotion binding changes must fail closed rather than allow unbound
  promotion if rollback evidence is ambiguous.
- Publication freshness preflight changes must leave generated/effective
  outputs non-authoritative and use canonical publication recovery.
- Parent review churn changes must not invalidate existing accepted reviews
  unless the reviewed artifact digest truly changed.
- Archive observation changes must preserve active-to-archive path semantics
  and record blocked evidence when observation cannot be proven.

## Rollback Validation

Rollback evidence for downstream children must include the child packet
rollback notes, relevant unit or integration tests, proposal validators, and
any retained run evidence required by the lifecycle route that performed the
mutation.

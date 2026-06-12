# Source Findings

## Source Request

The operator requested a finalized architecture proposal packet for improving
proposal packet lifecycle terminalization, using proposal program lifecycle as
the model. The requested outcome is proposal-only and explicitly excludes
implementation.

## Problem Findings

- Implemented packet closeout requires manual chaining across implementation
  conformance, post-implementation drift/churn, publication freshness,
  generated projection validation, hygiene cleanup, Git/GitHub checks, exact
  SHA hosted checks, closeout receipts, post-integration architecture review,
  and archive readiness proof.
- Evidence generated during closeout can dirty the worktree and create new
  closeout scope.
- Publication freshness repair can create generated outputs and validation
  receipts, which need canonical publisher handling and adjacent validation.
- GitHub protected-main rules may require exact source-SHA checks before main
  can move, which means terminalization needs a route-aware hosted check model.
- Generic lifecycle-postmortem is useful but cannot authorize transition,
  closeout, archive, promotion, publication, cleanup, or Git mutation.

## Model Findings

- Proposal program lifecycle uses parent-local aggregate receipts while
  preserving child authority.
- Packet terminalization needs the same aggregation pattern at the implemented
  packet boundary.
- Packet terminalization should produce a packet-local aggregate terminal
  receipt that cites target-owned evidence and records archive-ready or blocked
  verdict.

## Boundary Findings

- Archive relocation remains owned by archive-proposal.
- Git route selection, branch landing, branch cleanup, rollback, and final sync
  remain owned by Change closeout and Git/GitHub contracts.
- Repo hygiene deletion remains owned by repo-hygiene cleanup.
- Publication freshness repair remains owned by canonical publishers.
- Post-integration architecture review and lifecycle-postmortem remain
  evidence-only.
- Proposal inputs and generated outputs remain non-authority.

## Recommendation Finding

Create `proposal-packet-terminal-closeout` as a packet lifecycle workflow with
profile and receipt schemas, validators, tests, evaluator hook, entrypoints,
and lifecycle hooks. The workflow may authorize archive readiness but must not
perform archive relocation.

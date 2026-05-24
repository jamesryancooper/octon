# Implementation Plan

## Sequencing

1. Add `lifecycle-interaction-request-v1.schema.json` and
   `lifecycle-interaction-return-v1.schema.json` under product contracts.
2. Add optional lifecycle contract interaction metadata to
   `extension-lifecycle-contract.schema.json` and extend
   `validate-lifecycle-contracts.sh` to reject unsafe metadata.
3. Add proposal-packet lifecycle metadata for emitted `handoff`
   `follow_on_work_required` requests, then refresh the generated effective
   proposal lifecycle projection through extension publication.
4. Update governed lifecycle documentation and feature catalog navigation to
   describe the receipt model and generated/non-authority boundaries.
5. Update Proposal Packet closeout skill guidance so blocked closeout can emit
   a typed request instead of only prose next-route context.
6. Update Change Closeout, Worktree Closeout, and Repo Hygiene skill guidance
   so interaction requests are consumed as context only and never authority.
7. Add route execution request fields for interaction request and return refs.
8. Update the Lifecycle Runner to validate and record interaction refs from
   run input, checkpoint, event-log, and execution-request context without
   self-authorizing dispatch.
9. Update the Lifecycle Executor Adapter authorization proof so interaction
   refs are carried as non-authorizing context and cannot satisfy missing route
   gates.
10. Add `validate-lifecycle-interaction-receipts.sh` and focused negative
    fixtures/tests for valid request, valid return, dangling refs, stale refs,
    scope widening, forbidden transfer, gate non-satisfaction, target-owned
    validation, runner planning without dispatch, executor non-reinterpretation,
    generated projection refresh, unchanged proposal statuses, and missing
    return evidence.
11. Run proposal and implementation validators, correct failures, and write
    conformance and drift receipts.
12. Promote only by updating declared durable targets and refreshing generated
    projections as derived publication.
13. Close out the implementation Change through `closeout-change`, claiming
    only the highest proven lifecycle outcome.
14. Archive this packet only if closeout and archive gates pass.

## Implementation Boundaries

The implementation must not add a lifecycle bus, automatic subscription
dispatch, shared phase-loop state, new proposal statuses, route selection inside
executor adapters, authority transfer, or generated-source authority.

## Target Acceptance Metadata

Initial metadata is narrow:

- Source lifecycle: `proposal-packet`
- Emitted profile: `handoff`
- Request kind: `follow_on_work_required`
- Requested capabilities: `change-closeout`, `closeout-worktree`,
  `repo-hygiene-cleanup`
- Requested target outcomes: target-owned lifecycle outcomes only
- Required return schema: `lifecycle-interaction-return-v1`
- Required forbidden transfers: all six authority-transfer exclusions listed in
  `architecture/target-architecture.md`

## Migration And Compatibility

Existing textual `next_route_condition` and handoff prose remain valid as
compatibility evidence. New runs may emit typed interaction requests alongside
existing prose. Existing proposal statuses remain unchanged. Generated
projections are refreshed only as derived publication.

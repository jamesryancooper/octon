# Validation Plan

Validation must prove that the Run Journal hardening is real runtime behavior, not
only documentation.

## Validator classes

| Validator | Required behavior |
|---|---|
| Schema validator | Validates `run-event-v2`, `run-event-ledger-v2`, and `runtime-state-v2`. |
| Journal integrity validator | Checks sequence, first/last refs, event count, previous/current hash chain, and manifest consistency. |
| Lifecycle validator | Checks event-driven state transitions and rejects impossible transitions. |
| Authorization coverage validator | Confirms every material side-effect path has authority-requested/granted or denied events and receipts. |
| Evidence closeout validator | Confirms retained evidence snapshot matches control journal at closure. |
| Reconstruction validator | Rebuilds runtime-state from journal and side artifacts; compares with materialized `runtime-state.yml`. |
| Generated non-authority validator | Ensures generated views cite canonical roots and are not consumed as runtime/policy/support authority. |
| Replay-safety validator | Confirms replay defaults to dry-run/sandbox and cannot execute live side effects without fresh grant. |
| Support-target admission validator | Requires journal/reconstruction proof before support-target promotion. |

## Fixture Runs

| Fixture | Required events |
|---|---|
| Denied authorization | `run-created`, `context-pack-bound`, `authority-requested`, `authority-denied`, `run-closed` |
| Successful observe/read Run | authority grant, capability invocation, observation retained, evidence snapshot, run closed |
| Repo-consequential staged Run | rollback posture, checkpoint, capability invocation, receipt, staged closeout |
| Checkpoint/resume Run | checkpoint created, pause, resume, reconstruction, completed run |
| Rollback/recovery Run | rollback requested/started/completed, recovery completed, closeout disclosure |
| Operator intervention Run | approval requested/granted/denied or operator intervention event, state transition, digest/disclosure |

## Negative tests

1. Delete a middle event from `events.ndjson`; validator must fail.
2. Reorder two events; validator must fail.
3. Change event payload without updating hash; validator must fail.
4. Mutate `runtime-state.yml` to conflict with journal; validator must raise drift.
5. Omit closeout snapshot from evidence; closeout must fail.
6. Attempt material capability invocation without authority events; runtime must deny.
7. Feed generated operator read model into authorization; runtime must deny.
8. Replay a side-effecting action without fresh grant; replay must dry-run or deny.

## Promotion gates

A promoted implementation must satisfy all of the following:

- contract schemas valid,
- validators wired into architecture conformance,
- fixture runs pass,
- negative tests fail closed,
- generated projections rebuild from canonical roots,
- support-target admission requires journal evidence,
- closure evidence retained under Octon evidence roots.

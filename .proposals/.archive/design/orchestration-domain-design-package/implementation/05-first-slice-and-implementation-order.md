# First Implementation Slice And Recommended Order

## Smallest End-To-End Implementation Slice

Build the smallest slice that proves the architecture works:

- one watcher definition
- one event-triggered automation
- one workflow with explicit workflow execution metadata
- decision writer
- run writer
- coordination manager with exclusive lock
- queue manager with claim token semantics
- executor supervisor with ack and heartbeat
- reconciler handling missing ack
- validator pass on package plus runtime test fixtures

Why first:

- it exercises event routing, binding validation, decision writing, lock
  acquisition, run creation, executor ack, and one recovery path in a single
  narrow slice

Concrete first path:

1. watcher emits event
2. event router matches one automation
3. queue item created
4. queue claimed
5. bindings validated
6. coordination lock acquired
7. decision written
8. run created
9. executor accepts and acknowledges
10. run stays `running`
11. simulate missed ack or heartbeat to prove reconciliation

## Recommended Implementation Order

| Stage | Objective | Dependencies | Done Criteria |
|---|---|---|---|
| 1 | Implement schemas and contracts | none | validator passes all contract fixtures |
| 2 | Build persistence primitives | stage 1 | CAS for queue claims and locks available |
| 3 | Implement decision/run writers | stage 2 | decisions and runs persisted canonically |
| 4 | Implement coordination manager | stage 2 | lock acquire/renew/release works |
| 5 | Implement queue manager | stage 2 | claim/ack/retry/dead-letter works |
| 6 | Implement automation controller plus bindings | stages 1-5 | event/schedule admission path works |
| 7 | Implement workflow launcher plus executor ack contract | stages 3-6 | launch request/ack/finalization works |
| 8 | Implement liveness plus reconciler | stages 4-7 | stale-run recovery path works |
| 9 | Implement incidents plus approval verification | stages 1-8 | privileged actions enforced |
| 10 | Expand validator/runtime conformance tests | all prior | static contract coverage plus package semantic conformance coverage exists |

## Resolved Semantic Defaults

| Topic | Final Decision |
|---|---|
| Severity ordering | `info < warning < high < critical` |
| `source_ref_globs` | case-sensitive full-string Octon path globs over normalized slash-separated paths; supports `*`, `**`, `?`, and `[]`; no brace expansion or extglob |
| Recovery policy | same-executor resume or `abandon_and_escalate`; no recovery transfer in v1 |

## Remaining Implementation Choices

| Choice | Risk | Default |
|---|---|---|
| Concrete transport between launcher and executor | low | internal async queue or RPC |
| Storage backend | low | any backend meeting CAS/consistency guarantees |

## Implementer Handoff Summary

Build:

- discovery loader
- watcher runner
- event router
- queue manager
- automation controller
- coordination manager
- workflow launcher plus executor supervisor
- decision/run persistence
- reconciler/liveness manager
- incident manager
- validator

Before side effects are allowed, all of this must be true:

- references resolved
- bindings valid
- policy allowed
- approval valid if privileged
- coordination lock acquired if side-effectful
- decision record written
- run written
- executor ownership acknowledged

Authoritative artifacts:

- workflow execution metadata
- automations and triggers
- queue items
- decision records
- runs
- coordination locks
- approval artifacts
- approver authority registry
- incidents

Do not improvise:

- workflow executable metadata fields
- coordination lock schema and lease rules
- approval verification rules
- run liveness fields
- retry taxonomy
- binding semantics

Top 5 implementation failure risks to avoid:

1. starting side effects before lock + decision + run + executor ack
2. treating approval artifacts as valid without registry-based authority check
3. letting stale runs or stale locks silently continue
4. implementing event matching or bindings differently from the declared algorithms
5. treating projections or dashboards as authoritative state

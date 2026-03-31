# WS2 — Durable lifecycle, replay, retention, and evidence-class completion

## Purpose

Turn the run model into a genuinely replayable, inspectable, resumable lifecycle rather than a partially evidenced artifact family.

## Audit findings addressed

F-05, F-06, F-07, F-10, F-18

## Exact repo paths / subsystems to change

- `.octon/framework/constitution/contracts/runtime/**`
- `.octon/framework/constitution/contracts/retention/**`
- `.octon/framework/observability/**`
- `.octon/state/control/execution/runs/**`
- `.octon/state/continuity/runs/**`
- `.octon/state/evidence/runs/**`
- `.octon/state/evidence/disclosure/**`
- `.octon/state/evidence/external-index/**`

## Deliverables

- Routine emission of run receipts, measurements, interventions, replay pointers, replay index entries, and rollback posture on every supported consequential run.
- Event/state transition model or equivalent durable lifecycle semantics encoded in runtime and observable artifacts.
- Checkpoint validity, contamination handling, resume rules, and rollback/compensation posture executed rather than merely declared.
- Immutable external replay/telemetry indexing for evidence classes that should not live entirely in git.

## Implementation sequence

1. **Stabilize the current path**
   - confirm the exact live behavior on the listed subsystems
   - write a red/green acceptance matrix before editing
2. **Implement the cutover in runtime terms**
   - make the new target-state surface real in code and emitted artifacts
   - keep compatibility only where the packet explicitly allows it
3. **Backfill evidence**
   - update run evidence, proof, disclosure, and governance overlays so the new truth path is inspectable
4. **Delete or demote obsolete scaffolding**
   - remove what is no longer load-bearing
   - where removal is unsafe in the same step, register a named retirement trigger and owner

## Acceptance criteria

- [ ] Every supported consequential run can be reconstructed from run-manifest + receipts + replay pointers + external replay index.
- [ ] Interrupted and contaminated runs can be resumed, reset, or compensated through defined runtime behavior.
- [ ] Intervention and measurement records are mandatory outputs, not optional references.
- [ ] Evidence classes are consistent with retention policy and disclosure.

## Dependencies

- `WS0`
- `WS1`

## Claim criteria unlocked by this workstream

- Durable/event-sourced lifecycle claim
- Replayable evidence and retention claim

## Required evidence before calling this workstream complete

- code diff showing the new live path
- updated contract/artifact examples where applicable
- routine run evidence from the supported consequential envelope
- validator or workflow output proving the new gate/path is enforced
- explicit deletion or retirement note for any legacy surface touched

## Anti-patterns to avoid

- leaving the old surface on the critical path while calling the new one canonical
- proving the workstream only with a special closure or migration run
- treating new schema files as sufficient evidence of runtime completion
- widening support or claims during the workstream before proof/disclosure catch up

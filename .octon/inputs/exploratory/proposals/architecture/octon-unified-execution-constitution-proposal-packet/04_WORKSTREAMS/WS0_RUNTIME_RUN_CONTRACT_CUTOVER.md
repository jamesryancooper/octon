# WS0 — Runtime and objective-model cutover to run-contract-first execution

## Purpose

Finish the live runtime transition so Octon executes through the workspace/mission/run/stage stack instead of describing it only in contracts and state roots.

## Audit findings addressed

F-01, F-05, F-23

## Exact repo paths / subsystems to change

- `.octon/framework/engine/runtime/crates/kernel/src/main.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/workflow.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/pipeline.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/context.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/orchestration.rs`
- `.octon/framework/orchestration/runtime/**`
- `.octon/framework/constitution/contracts/objective/**`
- `.octon/instance/orchestration/missions/**`
- `.octon/state/control/execution/runs/**`
- `.octon/state/continuity/runs/**`

## Deliverables

- Canonical run-start/runtime API that binds on RunContract (or run id resolving to RunContract) rather than mission-first workflow execution.
- Runtime emission of run-manifest, runtime-state, stage-attempt records, checkpoints, and run continuity on every consequential run.
- Mission demoted to continuity/ownership container for recurring, overlapping, and long-horizon autonomy only.
- Compatibility shims explicitly marked transitional with retirement triggers.

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

- [ ] Kernel CLI and runtime library expose a run-contract-native entrypoint.
- [ ] No consequential supported execution path starts without a resolved run contract and manifest root.
- [ ] mission_id is derived/optional continuity metadata, not the primary runtime primitive.
- [ ] Every supported consequential run emits stage-attempt and checkpoint artifacts during ordinary operation, not just certification runs.

## Dependencies

- None

## Claim criteria unlocked by this workstream

- Run-contract-first constitutional runtime claim
- Correct mission/run relationship claim
- Durable lifecycle claim (shared with WS2)

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

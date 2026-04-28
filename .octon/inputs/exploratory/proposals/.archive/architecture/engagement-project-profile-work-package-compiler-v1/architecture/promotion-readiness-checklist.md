# Promotion Readiness Checklist

## Authority placement

- [ ] No promoted durable file depends on `inputs/exploratory/proposals/**`.
- [ ] Authored authority lands only in `framework/**` or `instance/**`.
- [ ] Operational truth lands only in `state/control/**`.
- [ ] Retained proof lands only in `state/evidence/**`.
- [ ] Continuity lands only in `state/continuity/**`.
- [ ] Generated views land only in `generated/**` and are traceable projections.

## Runtime safety

- [ ] Preflight lane forbids project-code mutation.
- [ ] Material effects still require engine authorization and typed effect tokens.
- [ ] Existing run lifecycle remains the atomic execution path.
- [ ] Per-engagement Objective Brief cannot rewrite the workspace-charter pair or authorize execution.
- [ ] Work Package cannot authorize execution by itself.
- [ ] Decision Request cannot replace canonical approval/exception/revocation roots.
- [ ] Unsupported connectors are stage-only, blocked, or denied.

## Evidence and replay

- [ ] Engagement evidence exists.
- [ ] Project Profile facts trace to orientation evidence.
- [ ] Work Package compilation evidence exists.
- [ ] Decision Requests retain operator decision evidence.
- [ ] Context-pack request and run-contract candidate are retained.
- [ ] Closeout evidence criteria remain unchanged for governed runs.

## Product readiness

- [ ] Operator-facing commands are simple and inspectable.
- [ ] Normal operator does not need to inspect low-level support matrix or effective handles unless debugging.
- [ ] Blocked/staged/denied outcomes carry reason codes.
- [ ] Decision Request resolution through `octon decide` writes canonical low-level refs without authorizing execution itself.
- [ ] First run-contract candidate can be handed to `octon run start --contract`.

## Current closure blockers

- [ ] Kernel command implementation compiles for every declared compiler command.
- [ ] Runtime validator for the compiler exists and passes.
- [ ] Project Profile target is created only with retained source-fact evidence.
- [ ] Generated proposal registry and compiler read models are treated as projections, not closure authority.

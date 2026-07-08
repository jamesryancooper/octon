# Program - Run Lifecycle

Run the generic lifecycle runner for one proposal program target:

```sh
octon lifecycle run --lifecycle proposal-program --target <program-packet-path>
```

By default this is orchestration-only: it emits planned
`program-route-handoff` evidence and does not run selected parent or child
routes. Add `--execute-routes` only when selected route execution should be
delegated through the shared executor adapter and proof-gated before dispatch.

If `octon` is not installed on PATH, or if the packaged binary does not expose
`lifecycle`, use the repo-local development launcher:

```sh
.octon/framework/engine/runtime/run lifecycle run --lifecycle proposal-program --target <program-packet-path>
```

Use `--run-id`, `--executor`, `--max-iterations`, `--set key=value`, and
`--set-file key=path` when deterministic resume, mock execution, bounded loop
testing, or creation input binding is required. The runner plans from the
published lifecycle contract, evaluates parent review, child-readiness, and
parent receipt gates, records workflow evidence and checkpoints, and reports
the next route. The proposal program contract declares
`execution_strategy: orchestrated-replan-loop`, so runtime dispatch stays on
the program lifecycle controller.

For clean-delivery continuation, bind the requested delivery target as a run
input rather than as a completion claim:

```sh
.octon/framework/engine/runtime/run lifecycle run --lifecycle proposal-program --target <program-packet-path> --set target_outcome=cleaned
```

Inspect the route graph before mutation with:

```sh
.octon/framework/engine/runtime/run lifecycle route-graph --lifecycle proposal-program --target <program-packet-path> --set target_outcome=cleaned
```

The route graph is a diagnostic read model. It exposes parent route selection,
child batches, review and architecture-review status, delivery handoff posture,
blockers, and resume hints without consuming an execute-routes step and without
satisfying any child receipt or delivery proof.

The explicit clean-delivery request wrapper is:

```text
/proposal-program-clean-delivery target=<program-packet-path> run-id=<id> [max-steps=<n>] [max-child-concurrency=<n>] [executor=auto|codex|mock]
```

It expands to the route graph preview followed by the same lifecycle runner
with `--execute-routes` and `--set target_outcome=cleaned`.

The runner records route-selection inputs, selected route ownership, blocked
alternatives, retry fingerprint fields, resume source refs, and delivery
handoff posture in `route-decision-receipt.yml`. A `target_outcome=cleaned`
input is passed only as a Proposal Program Delivery request; it is not proof of
landing, sync, cleanup, branch cleanup, terminal proof, or a final `cleaned`
state.

Executor boundary:

- Without `--execute-routes`, the runner stops at a planned
  `program-route-handoff`; it does not invoke selected parent or child routes
  and does not implement child packets.
- With `--execute-routes`, the program runner performs a bounded
  plan-execute-replan loop. Each iteration plans from live repository state,
  dispatches either one selected parent route or one runnable child batch
  through the shared lifecycle executor adapter, replans from child-owned
  manifests and receipts, and continues until terminal completion, blocked
  state, approval pause, failure, timeout, cancellation, or max-step
  exhaustion.
- Use `--max-steps` to bound adapter dispatch attempts. One step is one parent
  route dispatch or one runnable child batch dispatch; pure planning and
  non-execute handoffs do not consume steps. Use `--max-child-concurrency` to
  bound concurrent child route executors inside one child batch.
- Durable implementation, promotion, closeout, and archival routes execute only after
  proof-gated delegation succeeds. `--invocation-authority unattended` authorizes
  delegated execution, but missing or invalid proof fails closed.
- Program recovery runs inside the bounded autonomous recovery envelope declared
  by the proposal-program contract. The runner may refresh generated
  projections, materialize diagnostics or evidence indexes, classify
  lifecycle residue, and rebaseline current-run evidence when route evidence
  proves those actions are low-risk and post-validated. It stops before archive,
  push, landing, cleanup deletion, branch deletion, PR creation or merge,
  external publication, and any `cleaned` claim.
- `cleanup-lifecycle-residue` is non-mutating recovery unless a separate
  retained route authority explicitly authorizes deletion. Its output can bind
  retained residue disposition evidence only; it cannot replace child receipts,
  child validation, archive authorization, delivery authorization, landing
  authorization, branch cleanup authorization, or child lifecycle outcomes.
- Program child human-boundary blocks include structured typed-exception guidance. Use
  `octon lifecycle program approve --run-id <program-run> --child <child>
  --route <route> --reason <reason>`, followed by `octon lifecycle program
  retry --run-id <program-run> --child <child>` or lifecycle resume.
- `octon lifecycle cancel --run-id <run> --reason <text>` durably cancels
  packet or program runs. `octon lifecycle program cancel` remains an alias for
  program runs. Cancelled runs return `final_verdict: cancelled` and
  `route_execution_mode: none` without dispatching selected routes.
- Non-execute route handoffs do not consume bounded loop iterations because no
  selected route has executed.

This wrapper is not a dispatcher route and has no prompt bundle. It must
preserve child authority boundaries and must not treat parent support receipts
as child receipts.

# /proposal-program-clean-delivery

Request clean-delivery continuation for an accepted proposal program through the
existing proposal-program lifecycle runner.

This command is an operator wrapper, not a new lifecycle or delivery workflow.
It expands to a route-graph preview first, then to the existing
`proposal-program` lifecycle runner with route execution enabled and
`target_outcome=cleaned` bound as a request.

## Expansion

```text
octon lifecycle route-graph --lifecycle proposal-program --target <proposal-program-path> --set target_outcome=cleaned
octon lifecycle run --lifecycle proposal-program --target <proposal-program-path> --run-id <id> --execute-routes --invocation-authority unattended --set target_outcome=cleaned [--max-steps <n>] [--max-child-concurrency <n>] [--executor auto|codex|mock]
```

Use the repo-local launcher when the packaged binary is not on `PATH`:

```text
.octon/framework/engine/runtime/run lifecycle route-graph --lifecycle proposal-program --target <proposal-program-path> --set target_outcome=cleaned
.octon/framework/engine/runtime/run lifecycle run --lifecycle proposal-program --target <proposal-program-path> --run-id <id> --execute-routes --invocation-authority unattended --set target_outcome=cleaned [--max-steps <n>] [--max-child-concurrency <n>] [--executor auto|codex|mock]
```

## Boundary

`target_outcome=cleaned` is a delivery request only. It is not proof of child
implementation, validation, packet closeout, archive relocation, Change
closeout, hosted landing, final sync, cleanup proof, terminal proof, or a final
cleaned state.

The route graph is diagnostic-only. It can show selected routes, child batches,
review and architecture-review status, delivery handoff posture, blockers, and
resume hints, but it does not satisfy child receipts, delivery admission,
Change closeout, cleanup authorization, archive authorization, terminal proof,
or cleaned claims.

After the lifecycle runner reaches a delivery handoff, canonical
`proposal-program-delivery` still owns delivery admission, profile binding,
readiness preflight, child receipt validation, Change closeout, landing, sync,
cleanup, and terminal proof.

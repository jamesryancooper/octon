# Lifecycle Autopilot

Lifecycle Autopilot is the generic lifecycle orchestration and execution
mechanism for extension-declared lifecycle contracts. It combines the lifecycle
runner with the lifecycle executor adapter so a declared lifecycle can plan,
gate, execute, observe receipts, checkpoint, resume, and continue until a
terminal outcome or explicit block.

The proposal packet lifecycle is the first concrete pilot. It exercises packet
creation, review, revision, re-review, acceptance or rejection, implementation
prompt generation, implementation, promotion, verification/correction,
closeout, and archival without adding new proposal manifest statuses.

## Boundary

The lifecycle runner owns orchestration: planning, route selection, gates,
receipt freshness and completeness, stale receipt detection, loop bounds,
evidence, checkpoints, resume, and idempotency.

The lifecycle executor adapter owns route execution: prompt or workflow
invocation, generic input binding, completion observation, approval pauses,
timeouts, cancellation, retries, and structured execution results.

Lifecycle Autopilot uses generated effective projections as runtime discovery
authority. Raw additive extension inputs are authoring inputs only, and
proposal-local receipts remain evidence only.

## Operator Entry Points

- `octon lifecycle plan --lifecycle <id> --target <path>`
- `octon lifecycle run --lifecycle <id> --target <path>`
- `octon lifecycle resume --run-id <id>`
- `/octon-proposal-packet-run-lifecycle`
- `octon-proposal-packet-lifecycle-run-lifecycle`

## Validation

Focused validation lives in the lifecycle runner, lifecycle executor adapter,
lifecycle contract, and proposal lifecycle acceptance tests referenced by the
product feature catalog.

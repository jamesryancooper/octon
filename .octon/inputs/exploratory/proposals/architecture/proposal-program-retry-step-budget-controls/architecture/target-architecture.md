# Target Architecture

`octon lifecycle program retry` supports explicit bounded execution controls for
continuing an existing proposal-program lifecycle run.

## Retry Command Surface

- `--max-steps <n>` sets the retry attempt's plan-execute-replan step budget.
- `--timeout-seconds <n>` optionally sets the per-route executor timeout for the retry attempt.
- `--max-child-concurrency <n>` optionally sets child batch concurrency for the retry attempt.
- `--child <child-id>` continues to narrow retry to one child when supplied.

## Default Behavior

When the new options are omitted, existing retry behavior remains compatible:
the retry command uses retained checkpoint options when present, otherwise the
current bounded retry defaults.

When a retry-time option is supplied, it applies only to that controller
execution attempt and is retained through the normal checkpoint snapshot for
subsequent evidence. It must not create a new run identity or rewrite historical
event truth.

## Gate Preservation

The retry command remains subject to:

- checkpoint binding validation for run id, lifecycle id, target, registry, and run inputs;
- cancellation tokens and cancelled checkpoint state;
- worktree baseline and hygiene gates;
- publication freshness and generated freshness gates where applicable;
- child dependency gates and child-owned route selection;
- approval pauses and human-boundary stops;
- stale evidence, blocker, timeout, failure, and authority-boundary stops.

## Non-Goals

- No unbounded or daemonized program execution.
- No change to child-before-parent delivery order.
- No bypass of child-owned receipts, validation verdicts, closeout, archive, cleanup, or terminal proof.
- No mutation of the active `proposal-program-lifecycle-surface-coherence` program membership.


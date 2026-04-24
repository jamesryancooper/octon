# Full Architectural Evaluation

## Executive judgment

Run Lifecycle v1 enforcement is the highest-leverage next step because it is the integration layer that turns the already-implemented Run Journal, Authorized Effect Tokens, and Context Pack Builder into a coherent Governed Agent Runtime. Without lifecycle enforcement, Octon can know what happened, what was allowed, and what context was visible, but it cannot guarantee that operations happened in a valid order or that closeout represents a complete, reconstructable execution.

## Why this step is highest leverage

1. **It hardens the execution substrate.** Every consequential Run becomes a state-machine instance rather than a loosely related set of artifacts.
2. **It makes Run Journal useful as control history.** The journal becomes reconstructive and gating, not just archival evidence.
3. **It makes Authorized Effect Tokens state-aware.** Tokens cannot be consumed outside allowed lifecycle posture.
4. **It makes Context Pack Builder lifecycle-aware.** Context freshness and invalidation matter on bind, authorize, resume, rebuild, and closeout.
5. **It enables support-target proofing.** Deterministic state reconstruction is already required for repo-consequential support claims.
6. **It reduces long-running autonomy risk.** Pause/resume/revoke/fail/rollback/close become explicit state transitions with retained proof.
7. **It improves operator legibility.** Operator read models can mirror a single journal-derived state instead of collecting fragmented status signals.

## Current constraints

- Proposals are non-authoritative and cannot become runtime dependencies.
- Generated views are derived-only.
- Runtime authority lives in authored contracts and execution code, not host UI state.
- Support-target claims must remain bounded and finite.
- State/control and retained evidence must remain separate.

## Strongest plausible implementation shape now

The correct implementation is not a broad workflow engine and not a rival control plane. It is a narrow runtime state-machine gate that:

- reconstructs current state from the Run Journal;
- validates the requested transition;
- validates required side artifacts;
- appends accepted transitions through `runtime_bus`;
- materializes `runtime-state.yml` only after accepted events;
- blocks drift and missing evidence;
- enforces closeout completeness.

## Architectural cleanup required

- Treat `runtime-event-v1` as compatibility-only everywhere in lifecycle code.
- Centralize lifecycle state mapping in one runtime module rather than duplicating per CLI command.
- Keep `runtime-state.yml` rebuildable and conflict-subordinate to journal.
- Ensure every generated/operator lifecycle projection carries source refs to journal-derived state.

## Consequences of omission

If Octon does not implement this step, later improvements become less reliable:

- support-target proof can claim lifecycle conformance without deterministic reconstruction;
- memory or mission continuity may resume from ambiguous state;
- operator read models may mirror stale or divergent runtime status;
- closeout may occur without complete evidence;
- effect tokens may be valid but consumed at the wrong time;
- trace-to-lab promotion may inherit inconsistent lifecycle traces.

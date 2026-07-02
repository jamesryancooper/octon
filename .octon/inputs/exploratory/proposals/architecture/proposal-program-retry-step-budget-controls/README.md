# Proposal Program Retry Step Budget Controls

This standalone packet proposes durable retry controls for proposal-program
lifecycle runs.

The observed problem is that `octon lifecycle program retry` preserves or
defaults to a one-step execution budget. That is safe, but inefficient for
programs that need several child-owned lifecycle routes to complete. Operators
can work around this with the generic `lifecycle run --run-id ... --max-steps`
surface, but the retry surface should expose the same bounded controls.

## Boundary

This packet does not change the active
`proposal-program-lifecycle-surface-coherence` program and is not a child of
that program. It proposes a follow-up runtime and CLI fix that must preserve
all existing blocker, approval, cancellation, authority-boundary, and
child-owned evidence gates.


# Target Architecture

The proposal lifecycle extension exposes an optional command alias for program delivery.

## Alias Semantics

- The alias name is operator-facing and discoverable.
- The alias delegates to `proposal-program-delivery`.
- The alias uses the same required inputs, validation gates, evidence requirements, and refusal criteria as canonical program delivery.

## Authority Boundary

- The alias does not create a new workflow id.
- The alias does not create new closeout, archive, cleanup, or terminal proof semantics.
- The alias does not replace `proposal-program-delivery` in contracts or retained evidence.

## Projection Boundary

Host projection files may mirror the alias only after this canonical source lands and only with non-authority notices.

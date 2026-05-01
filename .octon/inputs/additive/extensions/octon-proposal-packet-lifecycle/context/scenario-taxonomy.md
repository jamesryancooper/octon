# Scenario Taxonomy

## Packet Creation Scenarios

- `audit-aligned-packet`: source is an audit, finding set, consistency report,
  or closure verdict. Preserve the full source under packet `resources/**` and
  map every finding to remediation, acceptance, validation, and closure proof.
- `architecture-evaluation-packet`: source is an architecture score,
  evaluation, or gap analysis. Preserve the evaluation and translate score
  targets into concrete structural, runtime, proof, governance, and boundary
  criteria.
- `highest-leverage-next-step-packet`: source is a target thesis and a request
  for the single next packet. Inspect the live repo and choose one bounded
  prerequisite or implementation step; explicitly reject broad target-state
  redesign unless required for that step.
- `source-to-packet`: source is compact user requirements, notes, specs, or
  not-yet-classified material. Classify proposal kind and dispatch to existing
  concept-integration routes where possible.

## Operating Scenarios

- `implementation-follow-up`
- `verification-correction`
- `closeout`
- `proposal-program`

All scenarios must remain proposal-local and promotion-safe.

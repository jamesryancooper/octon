# Octon Decision Drafter Overview

This pack exposes a family of decision-drafting bundles rather than one single
prompt lane.

## Stable Entry Point

- skill: `octon-decision-drafter`
- command: `/octon-decision-drafter`

Default route:

- `change-receipt`

## Bundle Families

- ADR drafting:
  `adr-update`
- migration drafting:
  `migration-rationale`
- rollback drafting:
  `rollback-notes`
- receipt-style drafting:
  `change-receipt`

## Important Boundary

Pack-local prompts are runtime inputs for this extension family, but they
remain non-authoritative additive content. Runtime-facing consumption must
flow through generated effective extension publication outputs.

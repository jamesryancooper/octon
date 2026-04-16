# Octon Impact Map And Validation Selector Overview

This pack exposes one stable selector entry point plus four leaf routes.

## Stable Entry Point

- skill: `octon-impact-map-and-validation-selector`
- command: `/octon-impact-map-and-validation-selector`

Default route:

- `touched-paths`

## Route Families

- observed repo deltas:
  `touched-paths`
- packet-aware validation selection:
  `proposal-packet`
- refactor-aware validation selection:
  `refactor-target`
- drift-aware reconciliation:
  `mixed-inputs`

## Important Boundary

The pack selects and explains existing validators, audits, and workflows.
It does not create new validator authority, new governance surfaces, or new
runtime services.

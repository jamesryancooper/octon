# Assurance Governance

## Purpose

Canonical governance surface for assurance charter policy, precedence, and
override contracts.

## Contents

- `CHARTER.md` - umbrella priority contract and trade-off rules.
- `DOCTRINE.md` - assurance rationale and subsystem relationship contract.
- `CHANGELOG.md` - governance-breaking change history.
- `weights/` - policy weight contracts and context inputs.
- `scores/` - measured score inputs and evidence mappings.
- `precedence.md` - deterministic merge-order contract.
- `SUBSYSTEM_OVERRIDE_POLICY.md`, `overrides.yml`, `subsystem-classes.yml` -
  override governance controls.

## Boundary

Normative assurance policy and governance live only in this surface.
Execution entrypoints belong in `../runtime/`; operating checklists and
standards belong in `../practices/`.

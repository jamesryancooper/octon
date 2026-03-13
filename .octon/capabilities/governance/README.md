# Capabilities Governance

## Purpose

Canonical governance surface for capability declaration contracts and policy
contracts that define what capabilities are and what they require.

## Contents

- `policy/` - Deny-by-default policy contracts, schemas, profiles, and reason-code taxonomies.

## Rule

Normative policy definitions for capabilities must live under this surface.

## Boundary

- `capabilities/` governs declaration semantics (taxonomy, schema, discovery,
  and declared requirements).
- `capabilities/` does not govern engine runtime execution semantics.
- Runtime semantics and enforcement behavior belong to `engine/` contracts in
  `/.octon/engine/governance/`.

## Dependency Direction

- Allowed: depend on stable engine contract boundaries (`engine/runtime/spec/**`
  and launch interfaces).
- Prohibited: depend on engine implementation internals (`engine/runtime/crates/**`
  and engine-private runtime logic).

Runtime evaluation semantics (launcher behavior, exit-code semantics, and mode
state interpretation) are defined by engine contracts/config:

- `/.octon/engine/runtime/spec/policy-interface-v1.md`
- `/.octon/engine/runtime/config/policy-interface.yml`

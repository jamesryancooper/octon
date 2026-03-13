# ADR 018: Assurance Umbrella Chain Migration

- Date: 2026-02-19
- Status: accepted

## Context

The Assurance Engine currently encodes a five-outcome chain:

`Trust > Speed of development > Ease of use > Portability > Interoperability`

This model spreads closely related concerns across multiple outcomes and creates
unnecessary policy/reporting complexity.

## Decision

Adopt a clean-break umbrella chain:

`Assurance > Productivity > Integration`

with these constraints:

1. Attribute-level scoring remains the source of truth.
2. Every canonical attribute has exactly one primary umbrella in
   `charter.attribute_umbrella_map`.
3. Umbrellas are rollups used for ordering, reporting, and governance summaries.
4. Legacy chain semantics and compatibility paths are removed.
5. Autonomy remains an attribute and is classified under Productivity.

## Consequences

- Backlog and tie-break ordering becomes umbrella-chain driven.
- Gate and deviation reporting references umbrellas and ranks instead of legacy
  outcome IDs.
- Downstream consumers parsing old outcome IDs must migrate to umbrella IDs.

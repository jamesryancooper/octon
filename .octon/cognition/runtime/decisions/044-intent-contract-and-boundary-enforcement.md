# ADR 044: Intent Contract and Boundary Enforcement

- Date: 2026-02-25
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/engine/runtime/spec/intent-contract-v1.schema.json`
  - `/.octon/agency/governance/delegation-boundaries-v1.yml`
  - `/.octon/agency/governance/delegation-boundaries-v1.schema.json`
  - `/.octon/engine/runtime/spec/policy-interface-v1.md`
  - `/.octon/engine/runtime/spec/policy-receipt-v1.schema.json`
  - `/.octon/capabilities/_ops/scripts/policy-receipt-write.sh`

## Context

Octon required explicit governance for long-running autonomous execution:

1. intent had to be machine-readable and bound at run start,
2. delegation boundaries had to route deterministically (`allow|escalate|block`),
3. decision receipts needed provenance fields to reconstruct why an action was
   allowed, escalated, or denied.

Without those controls, agents could remain process-compliant while optimizing
toward the wrong measurable objective.

## Decision

Adopt intent-layer enforcement primitives as first-class contracts:

1. Introduce `intent-contract-v1` as required input for autonomous runs.
2. Introduce `delegation-boundaries-v1` as machine-readable delegation
   authority routing.
3. Extend policy receipt contract to include `intent_ref`, `boundary_id`,
   `boundary_set_version`, `workflow_mode`, and `capability_classification`.
4. Extend policy interface guidance to fail closed on missing/invalid intent
   binding and autonomy-mode violations.

## Consequences

### Benefits

- Clear objective binding for autonomous decisions.
- Deterministic delegation routing across workflows.
- Stronger post-incident and compliance audit traceability.

### Costs

- Higher contract authoring overhead for each autonomous workflow.
- Additional validation and operational maintenance burden.

### Rollback

- Revert this ADR's artifact set as one promotion unit.
- Disable `intent-layer` alignment profile in emergency observe mode only.

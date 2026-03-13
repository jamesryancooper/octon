# ADR 045: Capability Map and Alignment Drift Gates

- Date: 2026-02-25
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/orchestration/governance/capability-map-v1.yml`
  - `/.octon/orchestration/governance/capability-map-v1.schema.json`
  - `/.octon/orchestration/runtime/workflows/manifest.yml`
  - `/.octon/orchestration/runtime/workflows/registry.yml`
  - `/.octon/assurance/runtime/_ops/scripts/validate-intent-layer.sh`
  - `/.octon/assurance/runtime/_ops/scripts/alignment-check.sh`
  - `/.octon/assurance/governance/weights/weights.yml`
  - `/.octon/assurance/governance/scores/scores.yml`

## Context

Intent and delegation controls needed orchestration and assurance gates:

1. workflow autonomy eligibility was implicit and inconsistent,
2. no explicit map existed for `agent-ready`, `agent-augmented`, and
   `human-only` execution classes,
3. alignment checks did not have a dedicated profile for intent-layer
   contracts and enforcement wiring.

## Decision

Adopt capability-map and drift-gate controls:

1. Introduce `capability-map-v1` as governance authority for workflow
   autonomy classification.
2. Link orchestration workflow discovery surfaces to capability-map governance
   metadata.
3. Add `intent-layer` assurance profile and validator to enforce the combined
   intent/boundary/capability-map contract.
4. Update assurance weighting/scoring narrative so autonomous quality claims
   require intent/boundary/mode provenance.

## Consequences

### Benefits

- Explicit autonomy eligibility per workflow.
- Deterministic deny behavior for non-`agent-ready` autonomous attempts.
- Continuous intent-layer drift detection in local and CI checks.

### Costs

- Ongoing governance maintenance for capability map entries.
- More frequent alignment gate updates as contract surfaces evolve.

### Rollback

- Revert capability-map governance and workflow linkage changes as one unit.
- Remove `intent-layer` profile from alignment-check to return to prior gate
  topology.

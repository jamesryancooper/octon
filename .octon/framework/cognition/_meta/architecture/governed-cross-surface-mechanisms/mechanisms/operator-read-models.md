# Operator Read Models Mechanism

## Non-Authority Status

This detail page is architecture documentation. Generated operator maps and
operator read models are navigation only, visibility only, and non-authority.
They are not runtime policy, support proof, retained evidence, closeout proof,
archive proof, proposal implementation evidence, or mutable control truth.

## Authority Surfaces

- operator read model contract:
  `.octon/framework/engine/runtime/spec/operator-read-models-v1.md`
- run-health read model schema:
  `.octon/framework/engine/runtime/spec/run-health-read-model-v1.schema.json`
- generated operator read models:
  `.octon/generated/cognition/**`
- retained publication and validation receipts:
  `.octon/state/evidence/validation/**`
- mutable source state for lifecycle summaries:
  `.octon/state/control/execution/runs/**`
- generated effective runtime handles:
  `.octon/generated/effective/**`

## Freshness And Traceability

Every generated operator map must name source refs, generation time, freshness
mode, validator refs, allowed consumers, and forbidden consumers. If source
traceability or freshness cannot be established, the view must be marked stale
or withheld.

The selected operator map for governed cross-surface mechanisms is
`.octon/generated/cognition/projections/materialized/governed-cross-surface-mechanisms/operator-map.md`.
It cites authored mechanism index docs as source refs and declares forbidden
runtime, policy, support, closeout, cleanup, archive, and evidence-gate
consumers.

## Boundary

Operator read models may help operators find canonical sources, but gates must
resolve against the cited authored authority, mutable control truth, retained
evidence, or publication receipt. Generated maps cannot satisfy child proposal
receipts or parent program closeout evidence.

## Validators

- `.octon/framework/assurance/runtime/_ops/scripts/validate-operator-read-models.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-governed-cross-surface-mechanisms.sh`

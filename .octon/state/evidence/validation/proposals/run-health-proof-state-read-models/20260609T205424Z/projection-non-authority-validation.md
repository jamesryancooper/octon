# Projection Non-Authority Validation

- proposal_id: `run-health-proof-state-read-models`
- run_id: `20260609T205424Z`
- generated_projection_root: `.octon/generated/cognition/projections/materialized/runs/`

## Validated Boundary

Run-health files and the compact manifest retain:

- `authority.classification: generated_read_model_non_authoritative`
- `authority.may_authorize: false`
- `authority.may_widen_support: false`
- forbidden consumers including `runtime`, `policy`, `authority`,
  `support-claim-evaluation`, and `state-reconstruction`

The run-health schema also requires those non-authority fields. The validator
keeps negative controls for missing non-authority classification and authority
widening.

## Source Traceability

Generated run-health files retain canonical refs, source digests, freshness
metadata, diagnostics, and retained generation receipt linkage. The compact
manifest remains a token-efficiency handle and diagnostic entry point, not an
authorization or evidence artifact.

## Control Boundary

The implementation did not add any runtime, policy, authority, or dispatch code
path that reads materialized run-health projections as authoritative input.
Generated projections can be consumed by operators and validators only.

# Vocabulary Inventory

- proposal_id: `run-health-proof-state-read-models`
- run_id: `20260609T205424Z`
- scope: run-health read-model authorization and human-boundary vocabulary
- authority_posture: generated projections remain non-authoritative

## Existing Status Vocabulary

The run-health status vocabulary remains:

- `healthy`
- `blocked`
- `stale`
- `unsupported`
- `revoked`
- `authority-ambiguity`
- `review-required`
- `evidence-incomplete`
- `rollback-required`
- `intervention-required`
- `disclosure-incomplete`
- `closure-ready`

The implementation narrows legacy generic approval-required reporting by
mapping approval-required conditions to `authority-ambiguity` with
proof-first fields instead of treating approval-required as a standalone
control-authorizing health state.

## Added Proof-State Vocabulary

The schema now requires `authorization.proof_state` with this enum:

- `proof-valid`
- `proof-missing`
- `proof-failed`
- `proof-stale`
- `proof-contradictory`
- `proof-scope-mismatch`
- `proof-unknown`

## Added Human-Boundary Vocabulary

The schema now requires `authorization.human_boundary_state` with this enum:

- `none`
- `approval-required`
- `review-required`
- `exception-required`
- `revocation-active`
- `denied`
- `unknown`

## Derivation Rules

- Authorized proof maps to `proof-valid` and `none`.
- Authorized proof with stale freshness maps to `proof-stale`.
- Denied or revoked proof maps to `proof-failed` with `denied` or
  `revocation-active`.
- Open approval requirements map to `proof-missing` and
  `approval-required`.
- Scope mismatch maps to `proof-scope-mismatch` and `review-required`.
- Contradictory revocation/grant proof maps to `proof-contradictory` and
  `revocation-active`.
- Unknown proof maps to `proof-unknown` and `unknown`.

## Boundary Check

No durable runtime, policy, authority, support-proof, or dispatch control
surface consumes generated run-health projections as control truth. The new
vocabulary is observational operator state backed by canonical refs, source
digests, freshness metadata, diagnostics, and non-authority classification.

# Validation

## Preflight

- `validate-proposal-review-gate.sh --package <packet> --require-implementation-authorization`: pass.
- `validate-architecture-proposal.sh --package <packet>`: pass.
- `validate-proposal-implementation-readiness.sh --package <packet>`: pass.
- `generate-proposal-registry.sh --write`: pass; repaired generated registry freshness after preflight detected accepted-status projection drift.
- `validate-proposal-standard.sh --package <packet>`: pass after canonical registry refresh, with expected pre-implementation warnings for targets that the implementation then created.

## Implementation Validators

- `bash -n` for new and modified validator scripts: pass.
- `jq empty` for new profile and receipt schemas: pass.
- `test-validate-governed-mechanism-integration.sh`: pass.
- `validate-governed-mechanism-integration-profile.sh --profile <durable-profile>`: pass.
- `validate-product-feature-catalog.sh`: pass.
- `validate-governed-cross-surface-mechanisms.sh`: pass.

## Final Validation

Final validation is recorded in `.octon/state/evidence/validation/proposals/verify-governed-mechanism-integration/20260613T215252Z/final-validation.md`.

- `validate-proposal-standard.sh --package <packet>`: pass, `errors=0 warnings=0`.
- `validate-architecture-proposal.sh --package <packet>`: pass, `errors=0 warnings=0`.
- `validate-proposal-review-gate.sh --package <packet> --require-implementation-authorization`: pass, `errors=0 warnings=0`.
- `validate-proposal-implementation-readiness.sh --package <packet>`: pass, `errors=0 warnings=0`.
- `validate-workflows.sh --workflow-id verify-governed-mechanism-integration`: pass, `errors=0 warnings=0`.
- `generate-proposal-artifact-index.sh --proposal <packet> --write`: pass, generated artifact index and program spine refreshed.
- `generate-proposal-registry.sh --write`: pass, `errors=0`; generated registry already matched manifest projection.
- `validate-proposal-lifecycle-terminal-freshness.sh --proposal <packet> --run-registry-check`: pass; registry projection, artifact index, proposal spine, and governed mechanism receipt validated fresh. The embedded registry scan emitted warnings for unrelated active or archived packets only.
- `validate-proposal-implementation-conformance.sh --package <packet>`: pass, `errors=0 warnings=0`.
- `validate-proposal-post-implementation-drift.sh --package <packet>`: pass, `errors=0 warnings=0`.
- `git diff --check`: pass.

No unresolved blockers or `needs-packet-revision` findings remain.

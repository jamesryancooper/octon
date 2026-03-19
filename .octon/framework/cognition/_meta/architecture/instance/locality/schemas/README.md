# Locality Schemas

Canonical schemas for repo-instance locality artifacts.

These schemas define the field-level contract for:

- `instance/locality/scopes/<scope-id>/scope.yml`

Validation is enforced by:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-locality-registry.sh`
- `.octon/framework/orchestration/runtime/_ops/scripts/publish-locality-state.sh`

Notes:

- Schema files are the normative contract source.
- Validator and publisher behavior must stay aligned with these schemas and the
  additional rooted-subtree, overlap, and freshness rules that cannot be fully
  expressed in JSON Schema alone.

# Publication Freshness Gates v2

Runtime-facing generated/effective outputs are valid only through
freshness-checked handles.

Required checks:

1. output exists,
2. generation lock exists and matches current source digests,
3. publication receipt exists and matches generation id and published path,
4. freshness window has not expired when declared,
5. runtime-facing output class is explicitly allowed,
6. generated/cognition, generated/proposals, and raw inputs are rejected as
   runtime authority sources,
7. support, pack, and extension state do not widen beyond canonical sources.

For the 10/10 target state this applies at minimum to:

- `/.octon/generated/effective/runtime/route-bundle.yml`
- `/.octon/generated/effective/capabilities/pack-routes.effective.yml`
- `/.octon/generated/effective/extensions/catalog.effective.yml`
- `/.octon/generated/effective/governance/support-target-matrix.yml`

Runtime behavior:

- stale or missing runtime route bundle: deny
- missing runtime publication receipt: deny
- raw path bypass of runtime-facing generated/effective output: deny
- quarantined or unpublished extension state in runtime route bundle: deny
- pack widening beyond admitted tuple: deny

Canonical validator:

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh`

# Worker W1

- Added authored target-state runtime spec surfaces for handle v2, route-bundle
  lock v3, freshness v4, architecture-health v3, and compatibility-retirement
  cutover v2.
- Rebound manifest, registry, and instance-governance references to the new
  family while retaining explicit historical-lineage pointers to prior v1/v2/v3
  contracts.
- Froze runtime pack projection posture to compatibility-only and tightened
  support-matrix/non-authority wording to route-bundle publication only.

Assumptions:

- Runtime Rust, validators, and generated/effective outputs will be updated by
  other workers to consume or emit the new target-state contracts.
- The support matrix remains non-widening and publication-only until direct
  runtime handle consumption is explicitly promoted in authored + runtime
  surfaces together.

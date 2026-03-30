# Maintainability Proof Plane

Maintainability assurance proves architecture-health, discoverability, and
change-safety characteristics for consequential runs and system claims.

This plane is distinct from structural conformance:

- structural proof checks placement and boundary correctness
- maintainability proof checks whether the resulting shape stays coherent,
  discoverable, and safe to evolve

Canonical retained outputs live under:

- `/.octon/state/evidence/runs/<run-id>/assurance/maintainability.yml`
- `/.octon/state/evidence/lab/benchmarks/**`

Authored suites live under `suites/**`.

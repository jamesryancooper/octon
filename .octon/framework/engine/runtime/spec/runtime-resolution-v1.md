# Runtime Resolution v1

Runtime resolution is delegated out of `/.octon/octon.yml` into an authored
selector and a generated/effective route bundle.

Canonical surfaces:

- `/.octon/instance/governance/runtime-resolution.yml`
- `/.octon/generated/effective/runtime/route-bundle.yml`
- `/.octon/generated/effective/runtime/route-bundle.lock.yml`

Target-state rule:

1. the root manifest owns only runtime-resolution anchors,
2. the instance selector owns runtime-facing generated/effective refs,
3. runtime reads the route bundle only through a freshness-checked handle,
4. grant emission fails closed when the route bundle, lock, or receipt drifts.

The route bundle joins at minimum:

- support-target matrix state
- compiled pack routes
- extension publication/quarantine state
- run and mission effective roots
- material side-effect inventory coverage

Canonical validators:

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-resolution.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-route-bundle.sh`

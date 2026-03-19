# Inventory

## Added

- `.octon/framework/assurance/runtime/_ops/scripts/validate-overlay-points.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-framework-core-boundary.sh`
- `.octon/state/evidence/migration/2026-03-18-framework-core-architecture-cutover/bundle.yml`
- `.octon/state/evidence/migration/2026-03-18-framework-core-architecture-cutover/evidence.md`
- `.octon/state/evidence/migration/2026-03-18-framework-core-architecture-cutover/commands.md`
- `.octon/state/evidence/migration/2026-03-18-framework-core-architecture-cutover/validation.md`
- `.octon/state/evidence/migration/2026-03-18-framework-core-architecture-cutover/inventory.md`
- `.octon/state/evidence/migration/2026-03-18-framework-core-architecture-cutover/path-map.json`

## Modified

- `.octon/README.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/shared-foundation.md`
- `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
- `.octon/instance/bootstrap/START.md`
- `.octon/instance/cognition/context/index.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`
- `.octon/framework/engine/runtime/policy`
- `.octon/framework/engine/runtime/config/policy-interface.yml`
- `.octon/framework/engine/runtime/crates/policy_engine/src/lib.rs`
- `.octon/framework/engine/runtime/crates/assurance_tools/src/main.rs`
- `.octon/framework/capabilities/governance/policy/deny-by-default.v2.yml`
- `.octon/framework/capabilities/governance/policy/agent-only-governance.yml`
- `.octon/framework/capabilities/_ops/scripts/*`
- `.octon/framework/capabilities/runtime/services/**`
- `.octon/framework/capabilities/runtime/skills/**`
- `.octon/inputs/exploratory/proposals/architecture/extensions-sidecar-pack-system/**`
- `.github/workflows/filesystem-interfaces-runtime.yml`
- `.gitignore`

## Moved / Reclassified

- `framework/capabilities/_ops/state/**` into:
  - `state/control/capabilities/**`
  - `state/evidence/decisions/repo/capabilities/**`
  - `generated/.tmp/capabilities/policy/**`
- `framework/capabilities/runtime/skills/_ops/state/**` into:
  - `instance/capabilities/runtime/skills/{configs,resources}/**`
  - `state/control/skills/checkpoints/**`
  - `state/evidence/runs/skills/**`
  - `generated/effective/capabilities/skills-deny-by-default-policy.catalog.yml`
- `framework/capabilities/runtime/services/_ops/state/**` into:
  - `state/evidence/runs/services/**`
  - `generated/.tmp/capabilities/services/build/**`
  - `generated/effective/capabilities/deny-by-default-policy.catalog.yml`
  - `framework/capabilities/governance/policy/provider-term-allowlist.tsv`
- `framework/assurance/runtime/_ops/state/*.lock.yml` into
  `generated/effective/assurance/*.lock.yml`
- `framework/engine/_ops/state/**` into:
  - `state/control/engine/**`
  - `state/evidence/runs/engine/**`
  - `generated/effective/capabilities/filesystem-snapshots/**`
  - `generated/.tmp/engine/**`

## Removed

- live `framework/**/_ops/state/**` directories from:
  - capabilities control state
  - skills runtime state
  - services runtime state
  - assurance runtime state
  - engine runtime state
  - tools runtime state placeholder

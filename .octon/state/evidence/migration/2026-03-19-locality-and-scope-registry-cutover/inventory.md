# Inventory

## Added

- `.octon/instance/locality/README.md`
- `.octon/instance/locality/scopes/octon-harness/scope.yml`
- `.octon/instance/cognition/context/scopes/{README.md,octon-harness/README.md}`
- `.octon/state/control/locality/quarantine.yml`
- `.octon/generated/effective/locality/{scopes.effective.yml,artifact-map.yml,generation.lock.yml}`
- `.octon/framework/orchestration/runtime/_ops/scripts/publish-locality-state.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/{validate-locality-registry.sh,validate-locality-publication-state.sh}`
- `.octon/framework/assurance/runtime/_ops/tests/{test-validate-locality-registry.sh,test-validate-locality-publication-state.sh}`
- `.octon/framework/cognition/_meta/architecture/instance/locality/schemas/{README.md,scope.schema.json}`
- `.octon/framework/scaffolding/runtime/templates/octon/instance/locality/{README.md,scopes/_scaffold/template/scope.yml}`
- `.octon/framework/scaffolding/runtime/templates/octon/instance/cognition/context/scopes/README.md`
- `.octon/framework/scaffolding/runtime/templates/octon/state/control/locality/quarantine.yml`
- `.octon/framework/scaffolding/runtime/templates/octon/generated/effective/locality/{scopes.effective.yml,artifact-map.yml,generation.lock.yml}`
- `.octon/instance/cognition/decisions/050-locality-and-scope-registry-atomic-cutover.md`
- `.octon/instance/cognition/context/shared/migrations/2026-03-19-locality-and-scope-registry-cutover/plan.md`
- `.octon/state/evidence/migration/2026-03-19-locality-and-scope-registry-cutover/{bundle.yml,evidence.md,commands.md,validation.md,inventory.md}`

## Modified

- Packet 6 control-plane docs and contract surfaces:
  - `.octon/README.md`
  - `.octon/instance/bootstrap/{START.md,init.sh}`
  - `.octon/instance/locality/registry.yml`
  - `.octon/instance/orchestration/missions/{README.md,_scaffold/template/mission.yml}`
  - `.octon/framework/cognition/governance/principles/locality.md`
  - `.octon/framework/capabilities/_meta/architecture/architecture.md`
  - `.octon/framework/cognition/_meta/architecture/{README.md,specification.md,shared-foundation.md}`
- Packet 6 validator and harness gate wiring:
  - `.octon/framework/assurance/runtime/_ops/scripts/{alignment-check.sh,validate-framework-core-boundary.sh,validate-harness-structure.sh,validate-repo-instance-boundary.sh}`
  - `.octon/framework/agency/_ops/scripts/validate/validate-agency.sh`
  - `.octon/framework/assurance/runtime/_ops/tests/test_packet2_fixture_lib.sh`
- Packet 6 workflow, CI, and scaffolding guidance:
  - `.octon/framework/orchestration/runtime/workflows/meta/update-harness/stages/{02-identify-gaps.md,05-execute.md}`
  - `.octon/framework/orchestration/runtime/workflows/meta/migrate-harness/stages/{03-content-migration.md,04-validation.md}`
  - `.octon/framework/scaffolding/runtime/templates/octon/{START.md,manifest.json}`
  - `.octon/framework/scaffolding/runtime/templates/octon/{agency/manifest.yml,instance/orchestration/missions/_scaffold/template/mission.yml}`
  - `.github/workflows/{harness-self-containment.yml,smoke.yml,main-push-safety.yml}`
- Packet 6 proposal and migration discovery indexes:
  - `.octon/inputs/exploratory/proposals/architecture/6-locality-and-scope-registry/{README.md,proposal.yml}`
  - `.octon/generated/proposals/registry.yml`
  - `.octon/instance/cognition/decisions/index.yml`
  - `.octon/instance/cognition/context/shared/migrations/index.yml`
  - `.octon/framework/cognition/practices/methodology/migrations/legacy-banlist.md`
  - `.octon/instance/cognition/context/shared/decisions.md`

## Validation Side Effects

- `.octon/state/control/extensions/{active.yml,quarantine.yml}`
- `.octon/generated/effective/extensions/{catalog.effective.yml,artifact-map.yml,generation.lock.yml}`
- any generated cognition decision summary artifacts refreshed by
  `sync-runtime-artifacts.sh --target decisions`

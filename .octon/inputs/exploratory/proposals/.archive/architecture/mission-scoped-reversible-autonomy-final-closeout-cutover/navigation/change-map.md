# Change Map

## Primary file families to change

### Authored authority
- `.octon/octon.yml`
- `.octon/README.md`
- `.octon/instance/bootstrap/START.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `.octon/framework/cognition/governance/principles/mission-scoped-reversible-autonomy.md`
- `.octon/instance/governance/policies/mission-autonomy.yml`
- `.octon/instance/governance/ownership/registry.yml`
- `.octon/instance/orchestration/missions/_scaffold/template/mission.yml`

### Runtime / policy / orchestration
- `.octon/framework/orchestration/runtime/_ops/scripts/seed-mission-autonomy-state.sh`
- `.octon/framework/orchestration/runtime/_ops/scripts/publish-mission-effective-route.sh`
- `.octon/framework/orchestration/runtime/_ops/scripts/evaluate-mission-control-state.sh`
- `.octon/framework/orchestration/runtime/_ops/scripts/record-mission-directive.sh`
- `.octon/framework/orchestration/runtime/_ops/scripts/record-mission-authorize-update.sh`
- `.octon/framework/orchestration/runtime/_ops/scripts/write-mission-control-receipt.sh`
- `.octon/framework/orchestration/runtime/_ops/scripts/recompute-mission-autonomy-state.sh`
- `.octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`
- `.octon/framework/cognition/_ops/runtime/scripts/generate-mission-summaries.sh`
- `.octon/framework/cognition/_ops/runtime/scripts/generate-operator-digests.sh`
- `.octon/framework/cognition/_ops/runtime/scripts/generate-mission-view.sh`

### Validation / assurance / CI
- `.octon/framework/assurance/runtime/_ops/scripts/validate-mission-lifecycle-cutover.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-mission-runtime-contracts.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-mission-intent-invariants.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-route-normalization.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-mission-generated-summaries.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-mission-view-generation.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-mission-control-evidence.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/test-mission-autonomy-scenarios.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/test-mission-lifecycle-activation.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/test-autonomy-burn-reducer.sh`
- `.github/workflows/architecture-conformance.yml`

## Expected no-change zones

- ACP conceptual backbone
- execution grant/receipt fundamental shape
- `STAGE_ONLY` semantics
- generated-vs-authoritative class separation
- mission public-facing naming

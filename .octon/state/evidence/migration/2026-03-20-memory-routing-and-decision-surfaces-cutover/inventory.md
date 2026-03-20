# Inventory

## Added

- Packet 11 cutover decision and migration records:
  - `.octon/instance/cognition/decisions/055-memory-routing-and-decision-surfaces-atomic-cutover.md`
  - `.octon/instance/cognition/context/shared/migrations/2026-03-20-memory-routing-and-decision-surfaces-cutover/plan.md`
  - `.octon/state/evidence/migration/2026-03-20-memory-routing-and-decision-surfaces-cutover/{bundle.yml,evidence.md,commands.md,validation.md,inventory.md}`

## Modified

- Generator and validator contracts:
  - `.octon/framework/cognition/_ops/runtime/scripts/{sync-runtime-artifacts.sh,validate-generated-runtime-artifacts.sh}`
  - `.octon/framework/assurance/runtime/_ops/scripts/{validate-harness-structure.sh,validate-repo-instance-boundary.sh}`
  - `.octon/framework/assurance/runtime/_ops/tests/test-validate-repo-instance-boundary.sh`
- Memory routing and authority docs:
  - `.octon/README.md`
  - `.octon/framework/agency/governance/MEMORY.md`
  - `.octon/framework/cognition/_meta/architecture/{README.md,dot-files.md,specification.md}`
  - `.octon/instance/bootstrap/{START.md,catalog.md,conventions.md}`
  - `.octon/instance/cognition/{decisions/README.md,context/index.yml}`
  - `.octon/instance/cognition/context/shared/{memory-map.md,continuity.md}`
  - `.octon/framework/cognition/governance/principles/{locality.md,single-source-of-truth.md}`
  - `.octon/framework/cognition/_meta/docs/intent-surface-atlas.md`
  - `.octon/state/evidence/decisions/repo/reports/README.md`
- Active practices, workflows, skills, templates, and prompts:
  - `.octon/framework/assurance/practices/session-exit.md`
  - `.octon/framework/assurance/_meta/architecture/checklists.md`
  - `.octon/framework/cognition/practices/operations/generated-artifacts.md`
  - `.octon/framework/cognition/_meta/architecture/inputs/exploratory/ideation/projects.md`
  - `.octon/framework/scaffolding/practices/prompts/{2026-01-14-multi-graph-architecture.md,research/prepare-promotion.md}`
  - `.octon/framework/orchestration/runtime/workflows/{ideation/promote-from-scratchpad/stages/01-inline.md,refactor/refactor/stages/{03-plan.md,04-execute.md,06-document.md}}`
  - `.octon/framework/capabilities/{practices/design-conventions.md,runtime/skills/README.md,runtime/skills/refactor/refactor/references/{phases.md,safety.md},runtime/skills/audit/audit-migration/references/phases.md}`
  - `.octon/framework/scaffolding/runtime/templates/octon/{START.md,catalog.md,assurance/practices/session-exit.md}`
- Discovery and registry outputs:
  - `.octon/generated/cognition/summaries/decisions.md`
  - `.octon/generated/proposals/registry.yml`
  - `.octon/instance/cognition/decisions/index.yml`
  - `.octon/instance/cognition/context/shared/migrations/index.yml`
- Proposal archive state:
  - `.octon/inputs/exploratory/proposals/.archive/architecture/memory-context-adrs-operational-decision-evidence/**`

## Validation Side Effects

- Regenerated cognition and publication-state outputs touched during validation:
  - `.octon/generated/cognition/{summaries/decisions.md,graph/{nodes.yml,edges.yml},projections/materialized/cognition-runtime-surface-map.latest.yml}`
  - `.octon/generated/effective/capabilities/{routing.effective.yml,artifact-map.yml,generation.lock.yml}`
  - `.octon/generated/effective/extensions/{catalog.effective.yml,artifact-map.yml,generation.lock.yml}`
  - `.octon/instance/cognition/context/shared/evidence/index.yml`
  - `.octon/state/control/extensions/{active.yml,quarantine.yml}`

## Removed

- Retired generated summary surface:
  - `.octon/instance/cognition/context/shared/decisions.md`

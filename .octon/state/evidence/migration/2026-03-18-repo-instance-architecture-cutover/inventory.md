# Inventory

## Added

- `.octon/framework/assurance/runtime/_ops/scripts/validate-repo-instance-boundary.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-repo-instance-boundary.sh`
- `.octon/instance/orchestration/missions/**`
- `.octon/instance/governance/policies/README.md`
- `.octon/instance/governance/contracts/README.md`
- `.octon/instance/agency/runtime/README.md`
- `.octon/instance/assurance/runtime/README.md`
- `.octon/instance/capabilities/runtime/commands/README.md`
- `.octon/instance/cognition/context/shared/migrations/2026-03-18-repo-instance-architecture-cutover/plan.md`
- `.octon/instance/cognition/decisions/048-repo-instance-architecture-atomic-cutover.md`
- `.octon/state/evidence/migration/2026-03-18-repo-instance-architecture-cutover/{bundle.yml,evidence.md,commands.md,validation.md,inventory.md,path-map.json}`
- `.octon/framework/scaffolding/runtime/templates/octon/instance/**`
- `/.octon/inputs/exploratory/proposals/architecture/repo-instance-architecture/**`

## Modified

- packet-4 control-plane docs and bootstrap surfaces:
  - `.octon/README.md`
  - `.octon/framework/cognition/_meta/architecture/{shared-foundation.md,specification.md}`
  - `.octon/instance/bootstrap/{START.md,catalog.md,conventions.md,scope.md,init.sh}`
- broader active-surface packet-4 cleanup:
  - `.octon/framework/agency/practices/{daily-flow.md,start-here.md}`
  - `.octon/framework/assurance/{practices/{complete.md,session-exit.md},_meta/architecture/checklists.md}`
  - `.octon/framework/capabilities/{_meta/architecture/architecture.md,practices/design-conventions.md,runtime/commands/{recover.md,refactor.md},runtime/skills/{README.md,registry.yml}}`
  - `.octon/framework/capabilities/runtime/skills/{audit/audit-freshness-and-supersession/references/io-contract.md,refactor/refactor/references/{examples.md,phases.md,safety.md}}`
  - `.octon/framework/cognition/_meta/architecture/{README.md,context.md,dot-files.md,taxonomy.md,state/continuity/progress.md}`
  - `.octon/framework/cognition/_meta/architecture/inputs/exploratory/ideation/{projects.md,scratchpad.md}`
  - `.octon/framework/cognition/governance/principles/{locality.md,single-source-of-truth.md}`
  - `.octon/framework/engine/governance/rules/adapters/cursor/octon/RULE.md`
  - `.octon/framework/orchestration/runtime/workflows/{ideation/promote-from-scratchpad/stages/01-inline.md,meta/evaluate-harness/stages/{01-assess-files.md,02-classify-content.md},refactor/refactor/stages/{03-plan.md,04-execute.md,05-verify.md,06-document.md}}`
  - `.octon/framework/scaffolding/_meta/architecture/templates.md`
- packet-4 workflow and CI surfaces:
  - `.octon/framework/orchestration/runtime/workflows/meta/migrate-harness/stages/{03-content-migration.md,04-validation.md}`
  - `.octon/framework/orchestration/runtime/workflows/meta/update-harness/{README.md,workflow.yml}`
  - `.octon/framework/orchestration/runtime/workflows/meta/update-harness/stages/{02-identify-gaps.md,05-execute.md}`
  - `.github/workflows/{harness-self-containment.yml,main-push-safety.yml,smoke.yml}`
- packet-4 validation and alignment wiring:
  - `.octon/framework/assurance/runtime/_ops/scripts/{alignment-check.sh,validate-harness-structure.sh}`
  - `.octon/framework/assurance/governance/weights/weights.yml`
- template and mission guidance:
  - `.octon/framework/orchestration/_meta/architecture/missions.md`
  - `.octon/framework/scaffolding/runtime/templates/octon/{START.md,catalog.md,manifest.json}`
  - `.octon/framework/scaffolding/runtime/templates/octon/assurance/practices/{complete.md,session-exit.md}`
  - `.octon/framework/scaffolding/runtime/templates/octon/cognition/context/compaction.md`
- proposal/migration indexes:
  - `.octon/generated/proposals/registry.yml`
  - `.octon/instance/cognition/context/shared/migrations/index.yml`
  - `.octon/instance/cognition/decisions/index.yml`
  - `.octon/inputs/exploratory/proposals/architecture/repo-instance-architecture/{README.md,proposal.yml}`
- instance shared-context follow-up cleanup:
  - `.octon/instance/cognition/context/{index.yml,shared/{constraints.md,continuity.md,glossary.md,lessons.md,memory-map.md,knowledge/knowledge.md}}`
- validation/export side effects:
  - `.octon/state/control/extensions/{active.yml,quarantine.yml}`
  - `.octon/generated/effective/extensions/{catalog.effective.yml,artifact-map.yml,generation.lock.yml}`

## Removed / Reclassified

- template mission surface moved out of `framework`-style runtime template
  placement:
  - removed:
    - `.octon/framework/scaffolding/runtime/templates/octon/orchestration/runtime/missions/README.md`
    - `.octon/framework/scaffolding/runtime/templates/octon/orchestration/runtime/missions/registry.yml`
    - `.octon/framework/scaffolding/runtime/templates/octon/orchestration/runtime/missions/_scaffold/template/{mission.md,tasks.json,log.md}`
  - replaced by:
    - `.octon/framework/scaffolding/runtime/templates/octon/instance/orchestration/missions/**`

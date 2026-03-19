---
title: Legacy Banlist (SSOT)
description: Canonical banlist of removed legacy identifiers, paths, and configuration keys enforced by CI.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/framework/agency/governance/CONSTITUTION.md"
  - "/.octon/framework/agency/governance/DELEGATION.md"
  - "/.octon/framework/agency/governance/MEMORY.md"
  - "/.octon/framework/cognition/practices/methodology/authority-crosswalk.md"
---

# Legacy Banlist (SSOT)

Add entries here during migrations. CI should enforce this file.

## Banned Identifiers

Each entry should be specific enough to avoid false positives.

- `agency/agents/registry.yml` - legacy root actor registry path - removed by migration `2026-02-20-agency-bounded-surfaces`
- `agency/assistants/registry.yml` - legacy root assistant registry path - removed by migration `2026-02-20-agency-bounded-surfaces`
- `agency/teams/registry.yml` - legacy root team registry path - removed by migration `2026-02-20-agency-bounded-surfaces`
- `agency/CONSTITUTION.md` - legacy root governance contract path - removed by migration `2026-02-20-agency-bounded-surfaces`
- `agency/DELEGATION.md` - legacy root governance contract path - removed by migration `2026-02-20-agency-bounded-surfaces`
- `agency/MEMORY.md` - legacy root governance contract path - removed by migration `2026-02-20-agency-bounded-surfaces`
- `agency/actors/agents/registry.yml` - deprecated intermediate agency runtime registry path - removed by migration `2026-02-21-agency-actors-to-runtime`
- `agency/actors/assistants/registry.yml` - deprecated intermediate agency runtime registry path - removed by migration `2026-02-21-agency-actors-to-runtime`
- `agency/actors/teams/registry.yml` - deprecated intermediate agency runtime registry path - removed by migration `2026-02-21-agency-actors-to-runtime`
- `agency/actors/README.md` - deprecated intermediate agency runtime surface index path - removed by migration `2026-02-21-agency-actors-to-runtime`
- `orchestration/workflows/manifest.yml` - legacy root workflow manifest path - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `orchestration/workflows/registry.yml` - legacy root workflow registry path - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `orchestration/missions/registry.yml` - legacy root mission registry path - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `orchestration/incidents.md` - legacy root incident governance path - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `orchestration/incident-response.md` - removed compatibility redirect path - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `capabilities/commands/manifest.yml` - legacy root commands manifest path - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `capabilities/skills/manifest.yml` - legacy root skills manifest path - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `capabilities/tools/manifest.yml` - legacy root tools manifest path - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `capabilities/services/manifest.yml` - legacy root services manifest path - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `capabilities/_ops/policy/deny-by-default.v2.yml` - legacy root capabilities policy contract path - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `capabilities/services/conventions/` - legacy root service conventions path - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `assurance/CHARTER.md` - legacy root assurance charter path - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `assurance/DOCTRINE.md` - legacy root assurance doctrine path - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `assurance/CHANGELOG.md` - legacy root assurance changelog path - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `assurance/complete.md` - legacy root assurance completion checklist path - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `assurance/session-exit.md` - legacy root assurance session-exit checklist path - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `assurance/standards/` - legacy root assurance standards path - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `assurance/trust/` - legacy root assurance trust artifact path - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `assurance/_ops/scripts/` - legacy root assurance runtime scripts path - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `assurance/_ops/state/` - legacy root assurance runtime state path - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `scaffolding/templates/manifest.schema.json` - legacy root scaffolding template schema path - removed by migration `2026-02-20-scaffolding-bounded-surfaces`
- `scaffolding/_ops/scripts/init-project.sh` - legacy root scaffolding bootstrap script path - removed by migration `2026-02-20-scaffolding-bounded-surfaces`
- `scaffolding/prompts/README.md` - legacy root scaffolding prompts path - removed by migration `2026-02-20-scaffolding-bounded-surfaces`
- `scaffolding/examples/create-harness-flow.md` - legacy root scaffolding examples path - removed by migration `2026-02-20-scaffolding-bounded-surfaces`
- `scaffolding/patterns/api-design-guidelines.md` - legacy root scaffolding governance pattern path - removed by migration `2026-02-20-scaffolding-bounded-surfaces`
- `runtime/run` - legacy top-level runtime launcher entrypoint - removed by migration `2026-02-20-engine-bounded-surfaces`
- `runtime/run.cmd` - legacy top-level runtime Windows launcher entrypoint - removed by migration `2026-02-20-engine-bounded-surfaces`
- `runtime/config/policy.yml` - legacy top-level runtime config path - removed by migration `2026-02-20-engine-bounded-surfaces`
- `runtime/crates/Cargo.toml` - legacy top-level runtime workspace manifest path - removed by migration `2026-02-20-engine-bounded-surfaces`
- `cognition/context/index.yml` - legacy root cognition context index path - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `cognition/principles/principles.md` - legacy root cognition immutable charter path - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `cognition/methodology/README.md` - legacy root cognition methodology path - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `cognition/principles/_ops/scripts/lint-principles-governance.sh` - legacy principles-local ops script path - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `cognition/principles/_meta/docs/ra-acp-glossary.md` - legacy principles-local meta docs path - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `cognition/_meta/architecture/content-plane/` - deprecated optional architecture surface path token - removed by migration `2026-02-22-artifact-surface-clean-break-rename`
- `runtime-content-layer.md` - deprecated optional artifact runtime layer filename token - removed by migration `2026-02-22-artifact-surface-clean-break-rename`
- `capabilities/runtime/skills/quality-gate/` - deprecated quality-gate skill domain path - removed by migration `2026-02-21-quality-gate-domain-split`
- `orchestration/runtime/workflows/quality-gate/` - deprecated quality-gate workflow domain path - removed by migration `2026-02-21-quality-gate-domain-split`
- `group: quality-gate` - deprecated quality-gate taxonomy group key - removed by migration `2026-02-21-quality-gate-domain-split`
- `path: quality-gate/` - deprecated quality-gate runtime path prefix - removed by migration `2026-02-21-quality-gate-domain-split`
- `documentation-quality-gate` - deprecated workflow identifier and command token - removed by migration `2026-02-21-documentation-audit-clean-break-rename`
- `orchestration/runtime/workflows/audit/documentation-quality-gate/` - deprecated docs workflow runtime path - removed by migration `2026-02-21-documentation-audit-clean-break-rename`
- `cognition/practices/methodology/migrations/20` - deprecated migration record prefix under practices surface - removed by migration `2026-02-21-cognition-runtime-migrations-surface-split`
- `/.octon/state/evidence/migration/*-evidence.md` - deprecated flat migration evidence filename pattern - removed by migration `2026-02-21-migration-evidence-bundle-format`
- `onboard-new-developer` - retired onboarding workflow identifier/command token; removed from discoverable routing by migration `2026-02-24-clean-break-governance-cutover`
- `operation.target.instruction_layers` - deprecated context-governance clean-break compatibility alias; replaced by top-level `instruction_layers` field in migration `2026-02-25-context-governance-clean-break`
- `operation.target.context_acquisition` - deprecated context-governance clean-break compatibility alias; replaced by top-level `context_acquisition` field in migration `2026-02-25-context-governance-clean-break`
- `operation.target.context_overhead_ratio` - deprecated context-governance clean-break compatibility alias; replaced by top-level `context_overhead_ratio` field in migration `2026-02-25-context-governance-clean-break`
- `latest_receipt // .receipt` - deprecated instruction-layer receipt fallback expression removed in migration `2026-02-25-context-governance-clean-break`
- `latest_digest // .digest` - deprecated instruction-layer digest fallback expression removed in migration `2026-02-25-context-governance-clean-break`
- `compatibility_receipt` - deprecated context-governance clean-break compatibility output key removed in migration `2026-02-25-context-governance-clean-break`
- `compatibility_digest` - deprecated context-governance clean-break compatibility output key removed in migration `2026-02-25-context-governance-clean-break`
- `nearest-registry-wins` - deprecated locality resolution token replaced by the root-owned repo-instance scope registry in migration `2026-03-19-locality-and-scope-registry-cutover`

## Banned Paths

- `/.octon/framework/agency/agents/` - replaced by `/.octon/framework/agency/actors/agents/` - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.octon/framework/agency/assistants/` - replaced by `/.octon/framework/agency/actors/assistants/` - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.octon/framework/agency/teams/` - replaced by `/.octon/framework/agency/actors/teams/` - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.octon/framework/agency/CONSTITUTION.md` - moved to governance surface - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.octon/framework/agency/DELEGATION.md` - moved to governance surface - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.octon/framework/agency/MEMORY.md` - moved to governance surface - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.octon/framework/agency/actors/` - replaced by `/.octon/framework/agency/runtime/` - removed by migration `2026-02-21-agency-actors-to-runtime`
- `/.octon/framework/agency/actors/agents/` - replaced by `/.octon/framework/agency/runtime/agents/` - removed by migration `2026-02-21-agency-actors-to-runtime`
- `/.octon/framework/agency/actors/assistants/` - replaced by `/.octon/framework/agency/runtime/assistants/` - removed by migration `2026-02-21-agency-actors-to-runtime`
- `/.octon/framework/agency/actors/teams/` - replaced by `/.octon/framework/agency/runtime/teams/` - removed by migration `2026-02-21-agency-actors-to-runtime`
- `/.octon/framework/orchestration/workflows/` - replaced by `/.octon/framework/orchestration/runtime/workflows/` - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.octon/framework/orchestration/missions/` - replaced by `/.octon/instance/orchestration/missions/` - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.octon/framework/orchestration/incidents.md` - moved to governance surface - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.octon/framework/orchestration/incident-response.md` - compatibility redirect removed in clean-break migration `2026-02-20-orchestration-bounded-surfaces`
- `/.octon/framework/scaffolding/runtime/templates/octon/orchestration/workflows/` - replaced by `/.octon/framework/scaffolding/runtime/templates/octon/orchestration/runtime/workflows/` - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.octon/framework/scaffolding/runtime/templates/octon/orchestration/missions/` - replaced by `/.octon/framework/scaffolding/runtime/templates/octon/instance/orchestration/missions/` - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.octon/framework/scaffolding/runtime/templates/<legacy-docs-template>/orchestration/workflows/` - replaced by `/.octon/framework/scaffolding/runtime/templates/<legacy-docs-template>/orchestration/runtime/workflows/` - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.octon/framework/capabilities/commands/` - replaced by `/.octon/framework/capabilities/runtime/commands/` - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `/.octon/framework/capabilities/skills/` - replaced by `/.octon/framework/capabilities/runtime/skills/` - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `/.octon/framework/capabilities/tools/` - replaced by `/.octon/framework/capabilities/runtime/tools/` - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `/.octon/framework/capabilities/services/` - replaced by `/.octon/framework/capabilities/runtime/services/` - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `/.octon/framework/capabilities/_ops/policy/` - moved to governance surface - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `/.octon/framework/capabilities/services/conventions/` - moved to practices surface - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `/.octon/framework/assurance/CHARTER.md` - moved to governance surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.octon/framework/assurance/DOCTRINE.md` - moved to governance surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.octon/framework/assurance/CHANGELOG.md` - moved to governance surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.octon/framework/assurance/complete.md` - moved to practices surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.octon/framework/assurance/session-exit.md` - moved to practices surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.octon/framework/assurance/standards/` - split across governance and practices surfaces - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.octon/framework/assurance/trust/` - moved to runtime surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.octon/framework/assurance/_ops/scripts/` - moved to runtime surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.octon/framework/assurance/_ops/state/` - moved to runtime surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.octon/framework/scaffolding/templates/` - replaced by `/.octon/framework/scaffolding/runtime/templates/` - removed by migration `2026-02-20-scaffolding-bounded-surfaces`
- `/.octon/framework/scaffolding/_ops/scripts/` - replaced by `/.octon/framework/scaffolding/runtime/_ops/scripts/` - removed by migration `2026-02-20-scaffolding-bounded-surfaces`
- `/.octon/framework/scaffolding/prompts/` - replaced by `/.octon/framework/scaffolding/practices/prompts/` - removed by migration `2026-02-20-scaffolding-bounded-surfaces`
- `/.octon/framework/scaffolding/examples/` - replaced by `/.octon/framework/scaffolding/practices/examples/` - removed by migration `2026-02-20-scaffolding-bounded-surfaces`
- `/.octon/framework/scaffolding/patterns/` - replaced by `/.octon/framework/scaffolding/governance/patterns/` - removed by migration `2026-02-20-scaffolding-bounded-surfaces`
- `/.octon/runtime/` - replaced by `/.octon/framework/engine/runtime/` plus `/.octon/framework/engine/governance/` and `/.octon/framework/engine/practices/` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.octon/runtime/run` - replaced by `/.octon/framework/engine/runtime/run` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.octon/runtime/run.cmd` - replaced by `/.octon/framework/engine/runtime/run.cmd` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.octon/runtime/config/` - replaced by `/.octon/framework/engine/runtime/config/` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.octon/runtime/crates/` - replaced by `/.octon/framework/engine/runtime/crates/` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.octon/runtime/spec/` - replaced by `/.octon/framework/engine/runtime/spec/` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.octon/runtime/wit/` - replaced by `/.octon/framework/engine/runtime/wit/` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.octon/runtime/_ops/` - replaced by `/.octon/framework/engine/_ops/` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.octon/runtime/_meta/` - replaced by `/.octon/framework/engine/_meta/` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.octon/framework/cognition/context/` - replaced by `/.octon/instance/cognition/context/shared/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.octon/framework/cognition/decisions/` - replaced by `/.octon/instance/cognition/decisions/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.octon/framework/cognition/analyses/` - replaced by `/.octon/instance/cognition/context/shared/analyses/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.octon/framework/cognition/knowledge-plane/` - replaced by `/.octon/instance/cognition/context/shared/knowledge/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.octon/framework/cognition/principles/` - replaced by `/.octon/framework/cognition/governance/principles/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.octon/framework/cognition/pillars/` - replaced by `/.octon/framework/cognition/governance/pillars/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.octon/framework/cognition/purpose/` - replaced by `/.octon/framework/cognition/governance/purpose/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.octon/framework/cognition/methodology/` - replaced by `/.octon/framework/cognition/practices/methodology/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.octon/framework/cognition/principles/_ops/` - replaced by `/.octon/framework/cognition/_ops/principles/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.octon/framework/cognition/principles/_meta/docs/` - replaced by `/.octon/framework/cognition/_meta/principles/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.octon/framework/cognition/_meta/architecture/content-plane/` - replaced by `/.octon/framework/cognition/_meta/architecture/artifact-surface/` - removed by migration `2026-02-22-artifact-surface-clean-break-rename`
- `/.octon/framework/cognition/_meta/architecture/artifact-surface/runtime-content-layer.md` - replaced by `/.octon/framework/cognition/_meta/architecture/artifact-surface/runtime-artifact-layer.md` - removed by migration `2026-02-22-artifact-surface-clean-break-rename`
- `/.octon/framework/capabilities/runtime/skills/quality-gate/` - replaced by focused runtime domains `/.octon/framework/capabilities/runtime/skills/audit/`, `/.octon/framework/capabilities/runtime/skills/remediation/`, and `/.octon/framework/capabilities/runtime/skills/refactor/` - removed by migration `2026-02-21-quality-gate-domain-split`
- `/.octon/framework/orchestration/runtime/workflows/quality-gate/` - replaced by focused runtime domains `/.octon/framework/orchestration/runtime/workflows/audit/` and `/.octon/framework/orchestration/runtime/workflows/refactor/` - removed by migration `2026-02-21-quality-gate-domain-split`
- `/.octon/framework/orchestration/runtime/workflows/audit/documentation-quality-gate/` - replaced by `/.octon/framework/orchestration/runtime/workflows/audit/audit-documentation/` - removed by migration `2026-02-21-documentation-audit-clean-break-rename`
- `/.octon/framework/cognition/practices/methodology/migrations/20` - replaced by `/.octon/instance/cognition/context/shared/migrations/20` for dated migration records - removed by migration `2026-02-21-cognition-runtime-migrations-surface-split`
- `/.octon/state/evidence/migration/<YYYY-MM-DD>-<slug>-evidence.md` - replaced by migration evidence bundle directories `/.octon/state/evidence/migration/<YYYY-MM-DD>-<slug>/` - removed by migration `2026-02-21-migration-evidence-bundle-format`

## Banned Config Keys or Env Vars

- `(none currently)` - no legacy config or env keys removed in migrations `2026-02-20-agency-bounded-surfaces`, `2026-02-21-agency-actors-to-runtime`, `2026-02-20-orchestration-bounded-surfaces`, `2026-02-20-capabilities-bounded-surfaces`, `2026-02-20-assurance-bounded-surfaces`, `2026-02-20-scaffolding-bounded-surfaces`, `2026-02-20-engine-bounded-surfaces`, `2026-02-20-cognition-bounded-surfaces`, `2026-02-21-quality-gate-domain-split`, `2026-02-21-documentation-audit-clean-break-rename`, `2026-02-21-cognition-runtime-migrations-surface-split`, `2026-02-21-migration-evidence-bundle-format`, `2026-02-22-artifact-surface-clean-break-rename`, or `2026-02-24-clean-break-governance-cutover`

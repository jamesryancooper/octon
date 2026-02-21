---
title: Legacy Banlist (SSOT)
description: Canonical banlist of removed legacy identifiers, paths, and configuration keys enforced by CI.
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

## Banned Paths

- `/.harmony/agency/agents/` - replaced by `/.harmony/agency/actors/agents/` - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.harmony/agency/assistants/` - replaced by `/.harmony/agency/actors/assistants/` - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.harmony/agency/teams/` - replaced by `/.harmony/agency/actors/teams/` - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.harmony/agency/CONSTITUTION.md` - moved to governance surface - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.harmony/agency/DELEGATION.md` - moved to governance surface - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.harmony/agency/MEMORY.md` - moved to governance surface - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.harmony/agency/actors/` - replaced by `/.harmony/agency/runtime/` - removed by migration `2026-02-21-agency-actors-to-runtime`
- `/.harmony/agency/actors/agents/` - replaced by `/.harmony/agency/runtime/agents/` - removed by migration `2026-02-21-agency-actors-to-runtime`
- `/.harmony/agency/actors/assistants/` - replaced by `/.harmony/agency/runtime/assistants/` - removed by migration `2026-02-21-agency-actors-to-runtime`
- `/.harmony/agency/actors/teams/` - replaced by `/.harmony/agency/runtime/teams/` - removed by migration `2026-02-21-agency-actors-to-runtime`
- `/.harmony/orchestration/workflows/` - replaced by `/.harmony/orchestration/runtime/workflows/` - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.harmony/orchestration/missions/` - replaced by `/.harmony/orchestration/runtime/missions/` - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.harmony/orchestration/incidents.md` - moved to governance surface - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.harmony/orchestration/incident-response.md` - compatibility redirect removed in clean-break migration `2026-02-20-orchestration-bounded-surfaces`
- `/.harmony/scaffolding/runtime/templates/harmony/orchestration/workflows/` - replaced by `/.harmony/scaffolding/runtime/templates/harmony/orchestration/runtime/workflows/` - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.harmony/scaffolding/runtime/templates/harmony/orchestration/missions/` - replaced by `/.harmony/scaffolding/runtime/templates/harmony/orchestration/runtime/missions/` - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.harmony/scaffolding/runtime/templates/harmony-docs/orchestration/workflows/` - replaced by `/.harmony/scaffolding/runtime/templates/harmony-docs/orchestration/runtime/workflows/` - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.harmony/capabilities/commands/` - replaced by `/.harmony/capabilities/runtime/commands/` - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `/.harmony/capabilities/skills/` - replaced by `/.harmony/capabilities/runtime/skills/` - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `/.harmony/capabilities/tools/` - replaced by `/.harmony/capabilities/runtime/tools/` - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `/.harmony/capabilities/services/` - replaced by `/.harmony/capabilities/runtime/services/` - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `/.harmony/capabilities/_ops/policy/` - moved to governance surface - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `/.harmony/capabilities/services/conventions/` - moved to practices surface - removed by migration `2026-02-20-capabilities-bounded-surfaces`
- `/.harmony/assurance/CHARTER.md` - moved to governance surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.harmony/assurance/DOCTRINE.md` - moved to governance surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.harmony/assurance/CHANGELOG.md` - moved to governance surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.harmony/assurance/complete.md` - moved to practices surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.harmony/assurance/session-exit.md` - moved to practices surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.harmony/assurance/standards/` - split across governance and practices surfaces - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.harmony/assurance/trust/` - moved to runtime surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.harmony/assurance/_ops/scripts/` - moved to runtime surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.harmony/assurance/_ops/state/` - moved to runtime surface - removed by migration `2026-02-20-assurance-bounded-surfaces`
- `/.harmony/scaffolding/templates/` - replaced by `/.harmony/scaffolding/runtime/templates/` - removed by migration `2026-02-20-scaffolding-bounded-surfaces`
- `/.harmony/scaffolding/_ops/scripts/` - replaced by `/.harmony/scaffolding/runtime/_ops/scripts/` - removed by migration `2026-02-20-scaffolding-bounded-surfaces`
- `/.harmony/scaffolding/prompts/` - replaced by `/.harmony/scaffolding/practices/prompts/` - removed by migration `2026-02-20-scaffolding-bounded-surfaces`
- `/.harmony/scaffolding/examples/` - replaced by `/.harmony/scaffolding/practices/examples/` - removed by migration `2026-02-20-scaffolding-bounded-surfaces`
- `/.harmony/scaffolding/patterns/` - replaced by `/.harmony/scaffolding/governance/patterns/` - removed by migration `2026-02-20-scaffolding-bounded-surfaces`
- `/.harmony/runtime/` - replaced by `/.harmony/engine/runtime/` plus `/.harmony/engine/governance/` and `/.harmony/engine/practices/` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.harmony/runtime/run` - replaced by `/.harmony/engine/runtime/run` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.harmony/runtime/run.cmd` - replaced by `/.harmony/engine/runtime/run.cmd` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.harmony/runtime/config/` - replaced by `/.harmony/engine/runtime/config/` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.harmony/runtime/crates/` - replaced by `/.harmony/engine/runtime/crates/` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.harmony/runtime/spec/` - replaced by `/.harmony/engine/runtime/spec/` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.harmony/runtime/wit/` - replaced by `/.harmony/engine/runtime/wit/` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.harmony/runtime/_ops/` - replaced by `/.harmony/engine/_ops/` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.harmony/runtime/_meta/` - replaced by `/.harmony/engine/_meta/` - removed by migration `2026-02-20-engine-bounded-surfaces`
- `/.harmony/cognition/context/` - replaced by `/.harmony/cognition/runtime/context/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.harmony/cognition/decisions/` - replaced by `/.harmony/cognition/runtime/decisions/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.harmony/cognition/analyses/` - replaced by `/.harmony/cognition/runtime/analyses/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.harmony/cognition/knowledge-plane/` - replaced by `/.harmony/cognition/runtime/knowledge-plane/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.harmony/cognition/principles/` - replaced by `/.harmony/cognition/governance/principles/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.harmony/cognition/pillars/` - replaced by `/.harmony/cognition/governance/pillars/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.harmony/cognition/purpose/` - replaced by `/.harmony/cognition/governance/purpose/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.harmony/cognition/methodology/` - replaced by `/.harmony/cognition/practices/methodology/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.harmony/cognition/principles/_ops/` - replaced by `/.harmony/cognition/_ops/principles/` - removed by migration `2026-02-20-cognition-bounded-surfaces`
- `/.harmony/cognition/principles/_meta/docs/` - replaced by `/.harmony/cognition/_meta/principles/` - removed by migration `2026-02-20-cognition-bounded-surfaces`

## Banned Config Keys or Env Vars

- `(none currently)` - no legacy config or env keys removed in migrations `2026-02-20-agency-bounded-surfaces`, `2026-02-21-agency-actors-to-runtime`, `2026-02-20-orchestration-bounded-surfaces`, `2026-02-20-capabilities-bounded-surfaces`, `2026-02-20-assurance-bounded-surfaces`, `2026-02-20-scaffolding-bounded-surfaces`, `2026-02-20-engine-bounded-surfaces`, or `2026-02-20-cognition-bounded-surfaces`

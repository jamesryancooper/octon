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

## Banned Paths

- `/.harmony/agency/agents/` - replaced by `/.harmony/agency/actors/agents/` - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.harmony/agency/assistants/` - replaced by `/.harmony/agency/actors/assistants/` - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.harmony/agency/teams/` - replaced by `/.harmony/agency/actors/teams/` - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.harmony/agency/CONSTITUTION.md` - moved to governance surface - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.harmony/agency/DELEGATION.md` - moved to governance surface - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.harmony/agency/MEMORY.md` - moved to governance surface - removed by migration `2026-02-20-agency-bounded-surfaces`
- `/.harmony/orchestration/workflows/` - replaced by `/.harmony/orchestration/runtime/workflows/` - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.harmony/orchestration/missions/` - replaced by `/.harmony/orchestration/runtime/missions/` - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.harmony/orchestration/incidents.md` - moved to governance surface - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.harmony/orchestration/incident-response.md` - compatibility redirect removed in clean-break migration `2026-02-20-orchestration-bounded-surfaces`
- `/.harmony/scaffolding/templates/harmony/orchestration/workflows/` - replaced by `/.harmony/scaffolding/templates/harmony/orchestration/runtime/workflows/` - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.harmony/scaffolding/templates/harmony/orchestration/missions/` - replaced by `/.harmony/scaffolding/templates/harmony/orchestration/runtime/missions/` - removed by migration `2026-02-20-orchestration-bounded-surfaces`
- `/.harmony/scaffolding/templates/harmony-docs/orchestration/workflows/` - replaced by `/.harmony/scaffolding/templates/harmony-docs/orchestration/runtime/workflows/` - removed by migration `2026-02-20-orchestration-bounded-surfaces`
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

## Banned Config Keys or Env Vars

- `(none currently)` - no legacy config or env keys removed in migrations `2026-02-20-agency-bounded-surfaces`, `2026-02-20-orchestration-bounded-surfaces`, `2026-02-20-capabilities-bounded-surfaces`, or `2026-02-20-assurance-bounded-surfaces`

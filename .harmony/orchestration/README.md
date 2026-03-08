# Orchestration

Canonical workflow and mission coordination boundary for the Harmony harness.
Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

## Bounded Surfaces

| Path | Purpose | Discovery |
|------|---------|-----------|
| `_meta/architecture/` | Orchestration subsystem architecture and specification docs | `_meta/architecture/README.md` |
| `runtime/` | Runtime orchestration artifacts (`workflows/`, `missions/`) | `runtime/README.md` |
| `governance/` | Incident governance and response contracts | `governance/README.md` |
| `practices/` | Orchestration operating standards | `practices/README.md` |

## Convention Authority

- Domain-local naming, authoring, and operating conventions belong in `practices/`.
- `_meta/architecture/` is reference architecture, not the canonical conventions surface.
- Cross-domain baseline conventions come from `/.harmony/conventions.md`.

## Discovery

Read in this order:

1. `runtime/workflows/manifest.yml` for workflow discovery (Tier 1)
2. `runtime/workflows/registry.yml` for workflow metadata and dependencies (Tier 2)
3. `runtime/missions/registry.yml` for active mission registry
4. `governance/incidents.md` for incident governance
5. `governance/production-incident-runbook.md` for production operational response steps
5. `practices/workflow-authoring-standards.md` and
   `practices/mission-lifecycle-standards.md` for operating discipline

## Interaction Model

- **Workflows:** Routable via intent matching and executed from `runtime/workflows/`.
- **Missions:** Time-bounded execution units managed in `runtime/missions/`.
- **Governance:** Incident protocol and operational constraints are defined in `governance/`.

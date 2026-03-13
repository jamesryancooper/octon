# Orchestration

Canonical orchestration coordination boundary for the Octon harness.
Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

## Bounded Surfaces

| Path | Purpose | Discovery |
|------|---------|-----------|
| `_meta/architecture/` | Orchestration subsystem architecture and specification docs | `_meta/architecture/README.md` |
| `runtime/` | Runtime orchestration artifacts (`workflows/`, `missions/`, `automations/`, `watchers/`, `queue/`, `runs/`, `incidents/`) | `runtime/README.md` |
| `governance/` | Orchestration governance contracts, incident policy, queue safety, watcher signal policy, automation policy, and approver authority | `governance/README.md` |
| `practices/` | Orchestration operating standards | `practices/README.md` |

## Convention Authority

- Domain-local naming, authoring, and operating conventions belong in `practices/`.
- `_meta/architecture/` is reference architecture, not the canonical conventions surface.
- Cross-domain baseline conventions come from `/.octon/conventions.md`.

## Discovery

Read in this order:

1. `runtime/workflows/manifest.yml` for workflow discovery (Tier 1)
2. `runtime/workflows/registry.yml` for workflow metadata and dependencies (Tier 2)
3. `runtime/missions/registry.yml` for active mission registry
4. `runtime/automations/manifest.yml` and `runtime/automations/registry.yml`
   for automation discovery
5. `runtime/watchers/manifest.yml` and `runtime/watchers/registry.yml` for
   watcher discovery
6. `runtime/queue/registry.yml` and `runtime/runs/index.yml` for queue and run
   discovery
7. `runtime/incidents/index.yml` for runtime incident discovery
8. `governance/incidents.md`, `governance/automation-policy.md`,
   `governance/queue-safety-policy.md`, and
   `governance/watcher-signal-policy.md` for governance authority
9. `governance/production-incident-runbook.md` for production operational
   response steps
10. `practices/README.md` for orchestration operating discipline

## Interaction Model

- **Workflows:** Routable via intent matching and executed from `runtime/workflows/`.
- **Missions:** Time-bounded execution units managed in `runtime/missions/`.
- **Automations:** Event and schedule-triggered launch policy lives in
  `runtime/automations/`.
- **Watchers:** Detector definitions and event emission live in
  `runtime/watchers/`.
- **Queue and Runs:** Queue ingress and orchestration-facing run projections
  live in `runtime/queue/` and `runtime/runs/`.
- **Incidents:** Runtime incident state lives in `runtime/incidents/` under
  governance control from `governance/`.
- **Governance:** Incident, automation, queue, and watcher policy constraints
  are defined in `governance/`.

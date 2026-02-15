# Orchestration

Workflows and missions that coordinate multi-step work.

## Contents

| Path | Purpose | Discovery |
|------|---------|-----------|
| `_meta/architecture/` | Orchestration subsystem specification docs | `_meta/architecture/README.md` |
| `workflows/` | Multi-step procedures with numbered steps | `workflows/manifest.yml` |
| `missions/` | Time-bounded sub-projects with isolated state | `missions/registry.yml` |
| `incidents.md` | Canonical incident response playbook | `incidents.md` |
| `incident-response.md` | Compatibility redirect for legacy incident-response references | `incident-response.md` |

## Interaction Model

- **Workflows:** Routable via intent matching. Read `workflows/manifest.yml` first, then `workflows/README.md` for group catalog.
- **Missions:** Referenced by slug. Read `missions/README.md` for lifecycle and creation guidance.

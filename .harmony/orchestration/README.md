# Orchestration

Workflows and missions that coordinate multi-step work.

## Contents

| Subdirectory | Purpose | Discovery |
|--------------|---------|-----------|
| `workflows/` | Multi-step procedures with numbered steps | `workflows/manifest.yml` |
| `missions/` | Time-bounded sub-projects with isolated state | `missions/registry.yml` |

## Interaction Model

- **Workflows:** Routable via intent matching. Read `workflows/manifest.yml` first, then `workflows/README.md` for group catalog.
- **Missions:** Referenced by slug. Read `missions/README.md` for lifecycle and creation guidance.

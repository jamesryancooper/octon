---
title: Start Here
description: Boot sequence and orientation for this harness
---

# .octon: Start Here

Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

## Prerequisites

{{PREREQUISITES or "None required"}}

## Structure

```text
.octon/
├── README.md
├── AGENTS.md
├── octon.yml
├── framework/        ← Portable authored Octon core
├── instance/         ← Repo-specific durable authored authority
├── inputs/           ← Additive and exploratory raw inputs
├── state/            ← Continuity, evidence, and control truth
└── generated/        ← Rebuildable outputs only
```

Canonical repo-instance authority lives under:

- `instance/manifest.yml`
- `instance/ingress/`
- `instance/bootstrap/`
- `instance/locality/` (`manifest.yml`, `registry.yml`, `scopes/<scope-id>/scope.yml`)
- `instance/cognition/`
- `instance/capabilities/runtime/`
- `instance/orchestration/missions/`
- `instance/extensions.yml`

Compiled locality publication and control surfaces live under:

- `state/control/locality/quarantine.yml`
- `generated/effective/locality/scopes.effective.yml`
- `generated/effective/locality/artifact-map.yml`
- `generated/effective/locality/generation.lock.yml`

Overlay-capable repo authority is limited to declared enabled overlay points:

| Overlay point | Instance path | Merge mode | Precedence |
| --- | --- | --- | ---: |
| `instance-governance-policies` | `instance/governance/policies/**` | `replace_by_path` | 10 |
| `instance-governance-contracts` | `instance/governance/contracts/**` | `replace_by_path` | 20 |
| `instance-agency-runtime` | `instance/agency/runtime/**` | `merge_by_id` | 30 |
| `instance-assurance-runtime` | `instance/assurance/runtime/**` | `append_only` | 40 |

Root `AGENTS.md` and `CLAUDE.md` are thin adapters to `.octon/AGENTS.md`
only. They must be symlinks or byte-for-byte parity copies.

## Boot Sequence

0. **If root `AGENTS.md`, `.octon/AGENTS.md`, or `.octon/instance/bootstrap/OBJECTIVE.md` is missing:** run `/init` (or `.octon/framework/scaffolding/runtime/_ops/scripts/init-project.sh`) first.
1. **Read `AGENTS.md`** → Root ingress adapter to `.octon/AGENTS.md`
2. **Read `.octon/instance/ingress/AGENTS.md`** → Canonical internal ingress
3. **Read `.octon/instance/bootstrap/OBJECTIVE.md`** → Active workspace objective
4. **Read `.octon/instance/bootstrap/scope.md`** → Boundaries
5. **Read `.octon/instance/bootstrap/conventions.md`** → Style rules
6. **Scan `.octon/instance/bootstrap/catalog.md`** → Available operations
7. **Read `.octon/state/continuity/repo/log.md`** → Know what's been done
8. **Read `.octon/state/continuity/repo/tasks.json`** → Know current priorities and goal
9. **Begin** highest-priority unblocked task
10. **Before finishing:** Complete `.octon/framework/assurance/practices/session-exit.md`, verify against `.octon/framework/assurance/practices/complete.md`

## Visibility & Autonomy Rules

| Directory | Autonomy | Description |
|-----------|----------|-------------|
| `inputs/exploratory/ideation/scratchpad/` | **Human-led only** | Human-led zone (thinking, staging, archives) |

Subdirectories: `inbox/` (staging), `archive/` (deprecated).

**Human-led:** Access ONLY when human explicitly directs to specific files.

## When Stuck

- Check `state/continuity/repo/tasks.json` for blocked items
- Check `instance/cognition/context/shared/lessons.md` for anti-patterns to avoid
- Check `instance/cognition/context/shared/decisions.md` for relevant past decisions
- Review repo-root context and adjacent domain docs for patterns
- Document blocker in `state/continuity/repo/log.md` and stop

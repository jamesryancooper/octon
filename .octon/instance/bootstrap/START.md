---
title: Start Here
description: Boot sequence and orientation for the root .octon harness.
---

# .octon: Start Here

Octon is a portable harness that turns any repository into a governed autonomous engineering environment.

Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

## Single-Root Model

This harness uses one repo-root `.octon/` per repository.

| Component | Canonical Path |
|-----------|----------------|
| Agents | `.octon/framework/agency/runtime/agents/` |
| Assistants | `.octon/framework/agency/runtime/assistants/` |
| Teams | `.octon/framework/agency/runtime/teams/` |
| Templates | `.octon/framework/scaffolding/runtime/templates/` |
| Workflows | `.octon/framework/orchestration/runtime/workflows/` |
| Skills | `.octon/framework/capabilities/runtime/skills/` |
| Commands | `.octon/framework/capabilities/runtime/commands/` |
| Tools | `.octon/framework/capabilities/runtime/tools/` |
| Services | `.octon/framework/capabilities/runtime/services/` |
| Prompts | `.octon/framework/scaffolding/practices/prompts/` |
| Context | `.octon/instance/cognition/context/shared/` |
| Checklists | `.octon/framework/assurance/` |

**Resolution:** The active harness is the only `.octon/` on the current repository ancestor chain. Sibling repositories may each have their own repo-root harness.

## Control-Plane Profiles

`/.octon/octon.yml` is the authoritative root manifest for topology,
versioning, install/export profiles, and fail-closed policy hooks.

| Profile | Operator Surface | Behavior |
|-----------|----------------|----------|
| `bootstrap_core` | `/init` | Complete bootstrap after adopting the framework bundle and minimal instance metadata |
| `repo_snapshot` | `/export-harness --profile repo_snapshot` | Export `octon.yml`, `framework/**`, `instance/**`, and enabled-pack dependency closure |
| `pack_bundle` | `/export-harness --profile pack_bundle --pack-ids <csv>` | Export only selected additive packs plus dependency closure |
| `full_fidelity` | Git clone | Advisory only; not a synthetic export payload |

---

## Canonical Specification

The cross-subsystem canonical contract for this harness is:

- `cognition/_meta/architecture/specification.md`

Subsystem expansion specs:

- `agency/_meta/architecture/specification.md`
- `capabilities/_meta/architecture/specification.md`
- `orchestration/_meta/architecture/specification.md`
- `engine/_meta/architecture/README.md`

---

## Structure

```text
.octon/
├── README.md
├── AGENTS.md
├── octon.yml
├── framework/
│   ├── manifest.yml
│   ├── agency/
│   ├── assurance/
│   ├── capabilities/
│   ├── cognition/
│   ├── engine/
│   ├── orchestration/
│   └── scaffolding/
├── instance/
│   ├── manifest.yml
│   ├── extensions.yml
│   ├── ingress/
│   ├── bootstrap/
│   ├── cognition/
│   ├── locality/
│   └── orchestration/
├── inputs/
│   ├── additive/
│   │   └── extensions/
│   └── exploratory/
│       ├── ideation/
│       ├── plans/
│       ├── drafts/
│       ├── packages/
│       └── proposals/
├── state/
│   ├── continuity/
│   ├── evidence/
│   └── control/
└── generated/
    ├── effective/
    ├── cognition/
    └── proposals/
```

Only `framework/**` and `instance/**` are authored authority. Raw
`inputs/**` remain non-authoritative even when a profile exports them.

## Naming Convention

Use plain directory names for structural units (domains, subsystems, components). Use underscore-prefixed namespaces for non-structural support material:

- `_meta/` — docs-as-code governance and architecture reference modules.
- `_ops/` — operational assets such as scripts and mutable state.
- `_scaffold/` — templates and scaffolding material.

Canonical SSOT for `runtime/` vs `_ops/` semantics:
`cognition/_meta/architecture/runtime-vs-ops-contract.md`.

Within these namespaces, common subpaths are:

- `_meta/architecture/`
- `_meta/docs/`
- `_meta/evidence/`
- `_ops/scripts/`
- `state/**`
- `_scaffold/template/`

## Canonical Agent-Led Path

Use this as the only recommended onboarding path for agent execution.

Canonical workflow contract:

- `/.octon/framework/orchestration/runtime/workflows/tasks/agent-led-happy-path/workflow.yml`

Human-readable guide:

- `/.octon/framework/orchestration/runtime/workflows/tasks/agent-led-happy-path/README.md`

Flow:

1. Bootstrap
   - If root `AGENTS.md`, `/.octon/AGENTS.md`, or `/.octon/instance/bootstrap/OBJECTIVE.md` is missing, run `/init` (or
     `.octon/framework/scaffolding/runtime/_ops/scripts/init-project.sh`) first.
   - Read `/AGENTS.md`, `/.octon/instance/bootstrap/OBJECTIVE.md`, `scope.md`, `conventions.md`,
     `cognition/_meta/architecture/specification.md`, and
     `cognition/governance/principles/README.md`.
2. Execute
   - Read `state/continuity/repo/log.md` and `state/continuity/repo/tasks.json`.
   - Execute the highest-priority unblocked task.
3. Assure
   - Run `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`.
   - Run additional surface-specific validators for changed domains.
4. Continuity
   - Update `state/continuity/repo/log.md` and `state/continuity/repo/tasks.json`.
   - Complete `assurance/practices/session-exit.md` and verify
     `assurance/practices/complete.md`.

Legacy onboarding variants are hard-deprecated for new sessions.

## Runtime Quick Start

From repo root:

```bash
.octon/framework/engine/runtime/run --help
.octon/framework/engine/runtime/run studio
```

Use `studio` when you want a visual workflow graph, a read-only orchestration
operations workspace, and the safe staged edit/apply flow.

## Assistants

Assistants are focused specialists available via `@mention`:

- `@reviewer` / `@rev` — Code review
- `@refactor` / `@ref` — Code restructuring
- `@docs` / `@doc` — Documentation

See `agency/manifest.yml` for actor discovery and `catalog.md` for invocation details.

## Visibility & Autonomy Rules

Two directories are **human-led**. Agents MUST NOT access them autonomously.

| Directory              | Purpose                          | Autonomy           |
|------------------------|----------------------------------|--------------------|
| `ideation/projects/`   | Human-led explorations           | **Human-led only** |
| `ideation/scratchpad/` | Ephemeral content and idea funnel | **Human-led only** |

**Scratchpad subdirectories (`ideation/scratchpad/`):** `inbox/` (staging), `archive/` (deprecated), `brainstorm/` (exploration), `ideas/`, `drafts/`, `daily/`.

### Human-Led Collaboration

Agents MAY access `ideation/projects/` or `ideation/scratchpad/` ONLY when:

1. Human explicitly points to specific file(s)
2. Human requests a concrete change
3. Agent work stays scoped to referenced files

**During autonomous operation:** Treat these paths as if they do not exist.

---

## The Funnel

Ideas flow from ephemeral scratchpad to committed work:

```
ideation/scratchpad/ideas/      → Quick captures (most die here)
        ↓
ideation/scratchpad/brainstorm/ → Structured exploration (filter stage)
        ↓
ideation/projects/              → Committed research (produces artifacts)
        ↓
orchestration/runtime/missions/         → Committed execution
        ↓
cognition/runtime/context/              → Permanent knowledge
```

---

## Where Things Go

| Content | Destination | Lifecycle |
|---------|-------------|-----------|
| External imports, raw drops | `ideation/scratchpad/inbox/` | Temporary → triage → move out |
| Quick ideas | `ideation/scratchpad/ideas/` | May graduate or die |
| Ideas worth exploring | `ideation/scratchpad/brainstorm/` | Graduate to projects or kill |
| Committed research | `ideation/projects/<slug>/` | Until findings published |
| Deprecated content | `ideation/scratchpad/archive/` | Permanent reference |
| Finalized decisions | `cognition/runtime/context/decisions.md` | Permanent |
| Constraints, non-negotiables | `cognition/runtime/context/constraints.md` | Permanent |
| Next actions | `continuity/next.md` | Active |
| Harness terminology | `cognition/runtime/context/glossary.md` | Reference |
| Repo-wide terminology | `cognition/runtime/context/glossary-repo.md` | Reference |
| Lessons learned | `cognition/runtime/context/lessons.md` | Reference |

**Publishing findings:** Project findings flow directly to `cognition/runtime/context/` files without a separate promotion step.

---

## When Stuck

- Check `state/continuity/repo/tasks.json` for blocked items and their blockers
- Check `cognition/runtime/context/lessons.md` for anti-patterns to avoid
- Check `cognition/runtime/context/decisions.md` for relevant past decisions
- Review `scaffolding/practices/prompts/` for relevant task templates
- If truly blocked, document the blocker in `state/continuity/repo/log.md` and stop

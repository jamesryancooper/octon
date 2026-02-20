---
title: Start Here
description: Boot sequence and orientation for the root .harmony harness.
---

# .harmony: Start Here

## Inheritance

This harness extends `.harmony/` for shared infrastructure.

| Component | Local (Project-Specific) | Shared (in `.harmony/`) |
|-----------|--------------------------|-------------------------|
| Agents | `.harmony/agency/actors/agents/` | `.harmony/agency/actors/agents/` |
| Assistants | `.harmony/agency/actors/assistants/` | `.harmony/agency/actors/assistants/` |
| Teams | `.harmony/agency/actors/teams/` | `.harmony/agency/actors/teams/` |
| Templates | `.harmony/scaffolding/templates/` | `.harmony/scaffolding/templates/` |
| Workflows | `.harmony/orchestration/runtime/workflows/` | `.harmony/orchestration/runtime/workflows/` |
| Skills | `.harmony/capabilities/runtime/skills/` | `.harmony/capabilities/runtime/skills/` |
| Commands | `.harmony/capabilities/runtime/commands/` | `.harmony/capabilities/runtime/commands/` |
| Tools | `.harmony/capabilities/runtime/tools/` | `.harmony/capabilities/runtime/tools/` |
| Services | `.harmony/capabilities/runtime/services/` | `.harmony/capabilities/runtime/services/` |
| Prompts | `.harmony/scaffolding/prompts/` | `.harmony/scaffolding/prompts/` |
| Context | `.harmony/cognition/context/` | `.harmony/cognition/context/` |
| Checklists | `.harmony/assurance/` | `.harmony/assurance/` |

**Resolution:** All resources now live under `.harmony/`.

---

## Canonical Specification

The cross-subsystem canonical contract for this harness is:

- `cognition/_meta/architecture/specification.md`

Subsystem expansion specs:

- `agency/_meta/architecture/specification.md`
- `capabilities/_meta/architecture/specification.md`
- `orchestration/_meta/architecture/specification.md`

---

## Structure

```text
.harmony/
├── START.md        ← You are here
├── scope.md        ← Boundaries
├── conventions.md  ← Style rules
├── catalog.md      ← Available operations
│
├── agency/
│   ├── manifest.yml    ← Actor registry discovery
│   ├── _meta/architecture/   ← Agency subsystem specification
│   ├── governance/     ← Cross-agent contracts (constitution, delegation, memory)
│   ├── actors/         ← Runtime actor artifacts
│   │   ├── agents/     ← Autonomous supervisors
│   │   ├── assistants/ ← Focused specialists (@mention invocation)
│   │   └── teams/      ← Reusable multi-actor compositions
│   ├── practices/      ← Collaboration and delivery practices
│   └── _ops/           ← Validation scripts and operational checks
│
├── capabilities/
│   ├── _meta/architecture/   ← Capabilities subsystem specification
│   ├── runtime/        ← Runtime capability artifacts
│   │   ├── commands/   ← Atomic instruction-driven operations
│   │   ├── skills/     ← Composite instruction-driven capabilities
│   │   ├── tools/      ← Atomic invocation-driven tool packs
│   │   └── services/   ← Composite invocation-driven domain capabilities
│   ├── governance/     ← Capabilities policy contracts
│   ├── practices/      ← Capabilities operating standards
│   └── _ops/           ← Validation scripts and operational state
│
├── cognition/
│   ├── _meta/architecture/   ← Cross-cutting harness and methodology architecture
│   ├── principles/     ← Canonical principles, pillars, and purpose
│   ├── methodology/    ← AI-native development methodology
│   ├── context/        ← Shared reference material and repo context
│   ├── decisions/      ← Architecture Decision Records
│   └── analyses/       ← Analytical working artifacts
│
├── continuity/         ← log.md, tasks.json, entities.json, next.md
│   └── _meta/architecture/   ← Continuity subsystem specification
│
├── orchestration/
│   ├── _meta/architecture/   ← Orchestration subsystem specification
│   ├── runtime/        ← Runtime orchestration artifacts
│   │   ├── workflows/  ← Multi-step procedures
│   │   └── missions/   ← Time-bounded sub-projects
│   ├── governance/     ← Incident governance contracts
│   └── practices/      ← Operating standards
│
├── scaffolding/
│   ├── _meta/architecture/   ← Scaffolding subsystem specification
│   ├── patterns/       ← Reusable design/policy patterns
│   ├── templates/      ← Boilerplate for new content
│   ├── prompts/        ← Task templates
│   └── examples/       ← Reference patterns
│
├── assurance/            ← complete.md, session-exit.md + standards
│   └── _meta/architecture/   ← Assurance subsystem specification
│
├── ideation/           ← Human-led zone (IGNORE)
│   ├── _meta/architecture/   ← Ideation subsystem specification
│   ├── scratchpad/     ← Temporary staging (inbox/, archive/, etc.)
│   └── projects/       ← Committed research
│
├── output/             ← Reports, drafts, artifacts
│   └── _meta/architecture/   ← Output subsystem specification
│
└── runtime/            ← Executable runtime layer (kernel + launchers)
    ├── _meta/evidence/ ← Runtime verification artifacts and audit evidence
    ├── _ops/bin/       ← Runtime-local prebuilt binaries
    ├── _ops/state/     ← Runtime-local mutable state (traces, kv, caches)
    ├── crates/         ← Runtime implementation crates
    ├── config/         ← Runtime policy and cache config
    └── spec/           ← Runtime contract/schema bundle
```

## Naming Convention

Use plain directory names for structural units (domains, subsystems, components). Use underscore-prefixed namespaces for non-structural support material:

- `_meta/` — docs-as-code governance and architecture reference modules.
- `_ops/` — operational assets such as scripts and mutable state.
- `_scaffold/` — templates and scaffolding material.

Within these namespaces, common subpaths are:

- `_meta/architecture/`
- `_meta/docs/`
- `_meta/evidence/`
- `_ops/scripts/`
- `_ops/state/`
- `_scaffold/template/`

## Boot Sequence

0. **If `AGENTS.md` is missing at repo root:** run `/init` (or `.harmony/scaffolding/_ops/scripts/init-project.sh`) first; add `--with-boot-files` if `BOOT.md` and `BOOTSTRAP.md` compatibility files are needed; add `--with-agent-platform-adapters` for opt-in adapter bootstrap config
1. **Read `scope.md`** → Know boundaries
2. **Read `conventions.md`** → Know style rules
3. **Read `cognition/_meta/architecture/specification.md`** → Know canonical harness rules
4. **Read `cognition/principles/README.md`** → Know operating principles
5. **Scan `catalog.md`** → Know available operations and assistants
6. **Read `continuity/log.md`** → Know what's been done
7. **Read `continuity/tasks.json`** → Know current priorities
8. **Check `orchestration/runtime/missions/registry.yml`** → Know active missions (if any)
9. **Begin** highest-priority unblocked task
10. **Before finishing:** Complete `assurance/session-exit.md`, verify against `assurance/complete.md`

## Runtime Quick Start

From repo root:

```bash
.harmony/runtime/run --help
.harmony/runtime/run studio
```

Use `studio` when you want a visual workflow graph + inspector + safe staged
edit/apply flow.

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
cognition/context/              → Permanent knowledge
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
| Finalized decisions | `cognition/context/decisions.md` | Permanent |
| Constraints, non-negotiables | `cognition/context/constraints.md` | Permanent |
| Next actions | `continuity/next.md` | Active |
| Harness terminology | `cognition/context/glossary.md` | Reference |
| Repo-wide terminology | `cognition/context/glossary-repo.md` | Reference |
| Lessons learned | `cognition/context/lessons.md` | Reference |

**Publishing findings:** Project findings flow directly to `cognition/context/` files without a separate promotion step.

---

## When Stuck

- Check `continuity/tasks.json` for blocked items and their blockers
- Check `cognition/context/lessons.md` for anti-patterns to avoid
- Check `cognition/context/decisions.md` for relevant past decisions
- Review `scaffolding/prompts/` for relevant task templates
- If truly blocked, document the blocker in `continuity/log.md` and stop

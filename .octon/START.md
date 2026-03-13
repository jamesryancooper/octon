---
title: Start Here
description: Boot sequence and orientation for the root .octon harness.
---

# .octon: Start Here

Octon is a portable harness that turns any repository into a governed autonomous engineering environment.

Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

## Inheritance

This harness extends `.octon/` for shared infrastructure.

| Component | Local (Project-Specific) | Shared (in `.octon/`) |
|-----------|--------------------------|-------------------------|
| Agents | `.octon/agency/runtime/agents/` | `.octon/agency/runtime/agents/` |
| Assistants | `.octon/agency/runtime/assistants/` | `.octon/agency/runtime/assistants/` |
| Teams | `.octon/agency/runtime/teams/` | `.octon/agency/runtime/teams/` |
| Templates | `.octon/scaffolding/runtime/templates/` | `.octon/scaffolding/runtime/templates/` |
| Workflows | `.octon/orchestration/runtime/workflows/` | `.octon/orchestration/runtime/workflows/` |
| Skills | `.octon/capabilities/runtime/skills/` | `.octon/capabilities/runtime/skills/` |
| Commands | `.octon/capabilities/runtime/commands/` | `.octon/capabilities/runtime/commands/` |
| Tools | `.octon/capabilities/runtime/tools/` | `.octon/capabilities/runtime/tools/` |
| Services | `.octon/capabilities/runtime/services/` | `.octon/capabilities/runtime/services/` |
| Prompts | `.octon/scaffolding/practices/prompts/` | `.octon/scaffolding/practices/prompts/` |
| Context | `.octon/cognition/runtime/context/` | `.octon/cognition/runtime/context/` |
| Checklists | `.octon/assurance/` | `.octon/assurance/` |

**Resolution:** All resources now live under `.octon/`.

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
├── START.md        ← You are here
├── scope.md        ← Boundaries
├── conventions.md  ← Style rules
├── catalog.md      ← Available operations
│
├── agency/
│   ├── manifest.yml    ← Actor registry discovery
│   ├── _meta/architecture/   ← Agency subsystem specification
│   ├── runtime/        ← Runtime actor artifacts
│   │   ├── agents/     ← Autonomous supervisors
│   │   ├── assistants/ ← Focused specialists (@mention invocation)
│   │   └── teams/      ← Reusable multi-actor compositions
│   ├── governance/     ← Cross-agent contracts (constitution, delegation, memory)
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
│   ├── runtime/        ← Cognition runtime artifacts (context, decisions, analyses)
│   ├── governance/     ← Principles, controls, pillars, and exception contracts
│   ├── practices/      ← Methodology and cognition operations guidance
│   └── _ops/           ← Mutable cognition scripts/state for guardrails
│
├── continuity/         ← log.md, tasks.json, entities.json, next.md
│   └── _meta/architecture/   ← Continuity subsystem specification
│
├── orchestration/
│   ├── _meta/architecture/   ← Orchestration subsystem specification
│   ├── runtime/        ← Runtime orchestration artifacts
│   │   ├── workflows/  ← Canonical workflows with generated READMEs
│   │   └── missions/   ← Time-bounded sub-projects
│   ├── governance/     ← Incident governance contracts
│   └── practices/      ← Operating standards
│
├── scaffolding/
│   ├── _meta/architecture/   ← Scaffolding subsystem specification
│   ├── runtime/        ← Runtime scaffolding artifacts
│   │   ├── templates/  ← Boilerplate for new content
│   │   └── _ops/scripts/ ← Scaffolding bootstrap scripts
│   ├── governance/     ← Reusable design and policy patterns
│   └── practices/      ← Task prompts and reference examples
│
├── assurance/           ← Assurance domain
│   ├── _meta/architecture/   ← Assurance subsystem specification
│   ├── runtime/         ← Runtime assurance artifacts and validators
│   ├── governance/      ← Weighted policy contracts and score controls
│   └── practices/       ← Session-exit and completion standards
│
├── ideation/           ← Human-led zone (IGNORE)
│   ├── _meta/architecture/   ← Ideation subsystem specification
│   ├── scratchpad/     ← Temporary staging (inbox/, archive/, etc.)
│   └── projects/       ← Committed research
│
├── output/             ← Reports, drafts, artifacts
│   └── _meta/architecture/   ← Output subsystem specification
│
└── engine/             ← Executable engine domain
    ├── runtime/        ← Executable runtime layer (kernel + launchers)
    │   ├── run         ← POSIX launcher
    │   ├── run.cmd     ← Windows launcher
    │   ├── crates/     ← Runtime implementation crates
    │   ├── config/     ← Runtime policy and cache config
    │   ├── spec/       ← Runtime contract/schema bundle
    │   └── wit/        ← Canonical runtime WIT contracts
    ├── governance/     ← Normative runtime contracts/policies
    ├── practices/      ← Engine operating standards/runbooks
    ├── _ops/           ← Runtime-local prebuilt binaries and mutable state
    └── _meta/          ← Architecture and verification evidence
```

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
- `_ops/state/`
- `_scaffold/template/`

## Canonical Agent-Led Path

Use this as the only recommended onboarding path for agent execution.

Canonical workflow contract:

- `/.octon/orchestration/runtime/workflows/tasks/agent-led-happy-path/workflow.yml`

Human-readable guide:

- `/.octon/orchestration/runtime/workflows/tasks/agent-led-happy-path/README.md`

Flow:

1. Bootstrap
   - If root `AGENTS.md`, `/.octon/AGENTS.md`, or `/.octon/OBJECTIVE.md` is missing, run `/init` (or
     `.octon/scaffolding/runtime/_ops/scripts/init-project.sh`) first.
   - Read `/AGENTS.md`, `/.octon/OBJECTIVE.md`, `scope.md`, `conventions.md`,
     `cognition/_meta/architecture/specification.md`, and
     `cognition/governance/principles/README.md`.
2. Execute
   - Read `continuity/log.md` and `continuity/tasks.json`.
   - Execute the highest-priority unblocked task.
3. Assure
   - Run `bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`.
   - Run additional surface-specific validators for changed domains.
4. Continuity
   - Update `continuity/log.md` and `continuity/tasks.json`.
   - Complete `assurance/practices/session-exit.md` and verify
     `assurance/practices/complete.md`.

Legacy onboarding variants are hard-deprecated for new sessions.

## Runtime Quick Start

From repo root:

```bash
.octon/engine/runtime/run --help
.octon/engine/runtime/run studio
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

- Check `continuity/tasks.json` for blocked items and their blockers
- Check `cognition/runtime/context/lessons.md` for anti-patterns to avoid
- Check `cognition/runtime/context/decisions.md` for relevant past decisions
- Review `scaffolding/practices/prompts/` for relevant task templates
- If truly blocked, document the blocker in `continuity/log.md` and stop

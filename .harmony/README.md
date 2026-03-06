# .harmony: Shared Harness Foundation

## Purpose

`.harmony/` provides **reusable infrastructure** for agent harnesses across the repository:

- Generic agents, assistants, teams, workflows, commands, prompts
- Harness templates for scaffolding
- Skills framework and base skills
- Assurance checklists and context references

## One-Page Overview

Harmony is an **agent-first, system-governed engineering harness**. It is not the
product code itself; it is the operating layer around the codebase that makes
planning, delivery, governance, and learning consistent and repeatable.
Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

## Conventions Placement

- Global cross-domain conventions live in `/.harmony/conventions.md`.
- Domain-local naming and authoring conventions live in `<domain>/practices/`.
- `_meta/architecture/` is for reference architecture/specification artifacts, not
  canonical conventions.
- Domains without a `practices/` surface inherit conventions from
  `/.harmony/conventions.md`.

### What Harmony Is

Harmony combines:

- A methodology (PLAN -> SHIP -> LEARN)
- A contract system for agent behavior and delegation
- A portable harness that can be reused across repositories

Its role is to define how work happens, who can act, what tools are allowed,
and what assurance/safety gates must be met before work is considered complete.

### What Harmony Does

Harmony gives a solo builder or small team a structured control plane for
software delivery by:

- Standardizing cross-project agent execution through shared contracts, workflows, capabilities, and auditability
- Enforcing safety via an agent-native deny-by-default control plane (shared
  policy engine, scoped permissions, and CI/runtime parity gates)
- Preventing unsafe autonomy with no-silent-apply for material side effects
- Preserving continuity through append-only logs, decisions, and next-step artifacts
- Requiring assurance gates before handoff or completion
- Enabling portability so the same operating model can be copied to new repos

### Assurance Engine

Harmony assurance weighting, scoring, and policy deviation enforcement is run by
the **Assurance Engine**.

The Assurance Engine is implemented as an **authoritative local engine**: policy and
measurement files live in-repo, resolution and gate logic run locally or in CI,
and generated evidence artifacts are written back to the repo workspace. This
keeps governance deterministic, auditable, portable, and independent of an
external service.

### How Harmony Works

Harmony is organized by function:

- `agency/`: actor model, delegation, and contracts
- `capabilities/`: commands, skills, tools, services, and shared policy ops (`_ops/`)
- `orchestration/`: runtime workflows/missions plus governance and practices
- `cognition/`: principles, methodology, and architecture contracts
- `continuity/`: operational memory across sessions
- `assurance/`: definition-of-done and session-exit gates
- `engine/`: executable runtime authority, governance contracts, and operating practices
- `output/`: generated artifacts and reports

Discovery follows progressive disclosure:

1. `manifest.yml` for indexing and routing
2. `registry.yml` for extended metadata
3. Full definitions (`SKILL.md`, workflow docs, contracts) when needed

Governance is explicit:

- Consequential side effects are governed by deny-by-default policy, ACP gates,
  reversibility requirements, and append-only receipts
- Agent autonomy is bounded by contract precedence and policy
- Humans retain policy authorship, exceptions handling, and escalation authority
- Human-led zones (for example, `ideation/`) are excluded unless explicitly scoped

In short: Harmony is a governed acceleration system. AI increases speed and
leverage; contracts, assurance gates, and ACPs preserve trust,
traceability, and reversibility.

## Canonical Specification

The cross-subsystem canonical contract for this harness is:

- `/.harmony/cognition/_meta/architecture/specification.md`

Subsystem expansion specs:

- `/.harmony/agency/_meta/architecture/specification.md`
- `/.harmony/capabilities/_meta/architecture/specification.md`
- `/.harmony/engine/_meta/architecture/README.md`
- `/.harmony/orchestration/_meta/architecture/specification.md`

**Portability:** This directory is designed to be copied to other repositories. See [Adopting in Other Repos](#adopting-in-other-repos) below.

## Inheritance Model

```
.harmony/            <- Shared foundation (generic, domain-agnostic)
    |
    v inherits
.harmony/            <- Single root (all content organized by cognitive function)
```

All content now lives under `.harmony/`, organized by cognitive function.

## Override Priority

When resolving a resource, agents check local first, then shared:

| Resource | Search Order |
|----------|--------------|
| Agency Manifest | `.harmony/agency/manifest.yml` |
| Agents | `.harmony/agency/runtime/agents/` |
| Assistants | `.harmony/agency/runtime/assistants/` |
| Teams | `.harmony/agency/runtime/teams/` |
| Templates | `.harmony/scaffolding/runtime/templates/` |
| Workflows | `.harmony/orchestration/runtime/workflows/` |
| Skills | `.harmony/capabilities/runtime/skills/` |
| Commands | `.harmony/capabilities/runtime/commands/` |
| Prompts | `.harmony/scaffolding/practices/prompts/` |
| Checklists | `.harmony/assurance/` |
| Context | `.harmony/cognition/runtime/context/` |

## Structure

```
.harmony/
├── README.md           <- You are here
│
├── agency/
│   ├── manifest.yml    <- Actor discovery and routing metadata
│   ├── _meta/architecture/ <- Agency subsystem specification
│   ├── runtime/        <- Runtime actor artifacts
│   │   ├── agents/     <- Autonomous supervisors
│   │   ├── assistants/ <- Generic specialists (@mention invocation)
│   │   └── teams/      <- Reusable multi-actor compositions
│   ├── governance/     <- Cross-agent contracts (constitution, delegation, memory)
│   ├── practices/      <- Human-agent operating practices
│   └── _ops/           <- Validation scripts and operational checks
│
├── capabilities/
│   ├── _meta/architecture/ <- Capabilities subsystem specification
│   ├── runtime/        <- Runtime capability artifacts
│   │   ├── commands/   <- Atomic instruction-driven operations
│   │   ├── skills/     <- Composite instruction-driven capabilities
│   │   ├── tools/      <- Atomic invocation-driven tool packs
│   │   └── services/   <- Composite invocation-driven domain capabilities
│   ├── governance/     <- Capability policy contracts and schemas
│   ├── practices/      <- Capability authoring and operating standards
│   └── _ops/           <- Agent-native deny-by-default control plane assets
│
├── cognition/
│   ├── _meta/architecture/ <- Cross-cutting harness architecture
│   ├── runtime/        <- Cognition runtime artifacts (context, decisions, analyses)
│   ├── governance/     <- Principles, controls, pillars, and exception contracts
│   ├── practices/      <- Methodology and cognition operations guidance
│   └── _ops/           <- Mutable cognition scripts/state for guardrails
│
├── continuity/         <- Session log, tasks, entities, next steps
│   └── _meta/architecture/ <- Continuity subsystem specification
│
├── orchestration/
│   ├── _meta/architecture/ <- Orchestration subsystem specification
│   ├── runtime/        <- Runtime orchestration artifacts
│   │   ├── workflows/  <- Multi-step procedures (harness, missions, skills)
│   │   └── missions/   <- Time-bounded sub-projects
│   ├── governance/     <- Incident governance contracts
│   └── practices/      <- Operating standards
│
├── scaffolding/
│   ├── _meta/architecture/ <- Scaffolding subsystem specification
│   ├── runtime/        <- Runtime scaffolding artifacts
│   │   ├── templates/  <- Harness scaffolding (harmony/, harmony-docs/, harmony-node-ts/)
│   │   └── _ops/scripts/ <- Scaffolding bootstrap scripts
│   ├── governance/     <- Reusable design and policy patterns
│   └── practices/      <- Task templates and reference examples
│
├── assurance/           <- Assurance domain
│   ├── _meta/architecture/ <- Assurance subsystem specification
│   ├── runtime/         <- Runtime assurance artifacts and validators
│   ├── governance/      <- Weighted policy contracts and score controls
│   └── practices/       <- Session-exit and completion standards
│
├── ideation/           <- Human-led zone (scratchpad/, projects/)
│   └── _meta/architecture/ <- Ideation subsystem specification
│
├── output/             <- Reports, drafts, artifacts
│   └── _meta/architecture/ <- Output subsystem specification
│
└── engine/             <- Executable engine domain
    ├── runtime/        <- Executable runtime layer (kernel, launchers, specs)
    │   ├── run         <- POSIX launcher
    │   ├── run.cmd     <- Windows launcher
    │   ├── config/     <- Runtime policy and cache configuration
    │   ├── crates/     <- Runtime implementation crates
    │   ├── spec/       <- Runtime schema/protocol specifications
    │   └── wit/        <- Canonical runtime WIT contracts
    ├── governance/     <- Normative runtime contracts and release policy
    ├── practices/      <- Engine operating standards and runbooks
    ├── _ops/           <- Runtime-local prebuilt binaries and mutable state
    └── _meta/          <- Architecture and evidence
```

## Runtime vs `_ops/` SSOT

The canonical cross-domain contract for classifying artifacts between
`runtime/` and `_ops/` is:

- `/.harmony/cognition/_meta/architecture/runtime-vs-ops-contract.md`

## What Lives Here

### In `.harmony/` (Shared)

- Generic agents, assistants, and team compositions
- Base templates for harness creation
- Harness/mission management workflows
- Generic commands (recover, refactor, validate-frontmatter)
- Tool usage and compaction guides
- Base assurance checklists
- Skills framework and generic skills

### Project-Specific Content

- `START.md`, `scope.md`, `conventions.md`, `catalog.md`
- `continuity/` (session log, tasks, entities)
- `orchestration/runtime/missions/` instances (time-bounded sub-projects)
- Domain-specific context (`cognition/runtime/context/` — decisions, lessons, glossary, constraints)
- Domain-specific workflows (e.g., flowkit)
- Skills outputs and logs (always local)
- `ideation/scratchpad/` (human-led zone with inbox/, archive/, etc.)

## Skills Registry Pattern

`.harmony/capabilities/runtime/skills/registry.yml` defines skill capabilities without project-specific paths.

`.harmony/capabilities/runtime/skills/registry.yml` defines skill capabilities and adds:

- Project-specific input/output mappings
- Project-specific skills
- Project-specific pipelines

## Harness Integration

### Skills

Harness directories (`.claude/`, `.cursor/`, `.codex/`) symlink to `.harmony/capabilities/runtime/skills/` for shared skills:

```
.claude/skills/synthesize-research -> ../../.harmony/capabilities/runtime/skills/synthesize-research
.cursor/skills/synthesize-research -> ../../.harmony/capabilities/runtime/skills/synthesize-research
.codex/skills/synthesize-research -> ../../.harmony/capabilities/runtime/skills/synthesize-research
```

### Commands

Harness command directories symlink to `.harmony/capabilities/runtime/commands/` for shared commands:

```
.cursor/commands/refactor.md -> ../../.harmony/capabilities/runtime/commands/refactor.md
.claude/commands/refactor.md -> ../../.harmony/capabilities/runtime/commands/refactor.md
```

**Note:** Codex CLI does not support project-level custom commands. Codex users have two options:

1. Manually copy commands from `.harmony/capabilities/runtime/commands/` to `~/.codex/prompts/`
2. Run script implementations directly (for example: `.harmony/scaffolding/runtime/_ops/scripts/init-project.sh`)

## Adopting in Other Repos

To use this harness infrastructure in another repository:

### Quick Start

```bash
# 1. Copy .harmony/ to your repo
cp -r /path/to/harmony/.harmony /path/to/your-repo/

# 2. Inspect the common Harmony objectives
.harmony/scaffolding/runtime/_ops/scripts/init-project.sh --list-objectives

# 3. Initialize project-level bootstrap files and choose an objective contract
.harmony/scaffolding/runtime/_ops/scripts/init-project.sh --objective project-app-repo

# Optional: also generate BOOT compatibility files
.harmony/scaffolding/runtime/_ops/scripts/init-project.sh --objective project-app-repo --with-boot-files

# Or run without --objective in an interactive terminal and choose from the prompt
.harmony/scaffolding/runtime/_ops/scripts/init-project.sh

# 4. Customize OBJECTIVE.md, .harmony/scope.md, and .harmony/conventions.md
```

If your tool supports harness commands, run `/init` instead of invoking the script directly. Interactive `/init` prompts for a common objective and writes the objective contract for the workspace. Use `--objective <id>` for scripted bootstrap and `--with-boot-files` when `BOOT.md` and `BOOTSTRAP.md` compatibility files are needed.

### What's Included

| Directory | Purpose |
|-----------|---------|
| `scaffolding/runtime/templates/` | Harness scaffolding (base + variants) |
| `agency/governance/` | Cross-agent contracts and precedence overlays |
| `agency/runtime/agents/` | Supervisory actors and delegation policy |
| `agency/runtime/assistants/` | Generic specialists (reviewer, refactor, docs) |
| `agency/runtime/teams/` | Reusable multi-actor compositions |
| `agency/practices/` | Human-agent operating standards and delivery discipline |
| `orchestration/runtime/workflows/` | Harness management + mission lifecycle |
| `orchestration/governance/` | Incident governance contracts |
| `orchestration/practices/` | Orchestration operating standards |
| `capabilities/_ops/` | Agent-native deny-by-default control plane (policy, grants, kill-switches, validation) |
| `capabilities/runtime/skills/` | Composable capabilities with defined I/O |
| `capabilities/runtime/commands/` | Atomic operations |
| `scaffolding/practices/prompts/` | Task templates |
| `assurance/` | Assurance gates |
| `cognition/runtime/context/` | Tool usage, compaction guides |

### Next Steps

1. Edit `OBJECTIVE.md` to sharpen the repo's active objective
2. Review `.harmony/cognition/runtime/context/intent.contract.yml` and adjust it to match the approved objective
3. Edit `.harmony/scope.md` to define your repo's boundaries
4. Edit `.harmony/conventions.md` for your style rules
5. Add repo-specific context to `.harmony/cognition/runtime/context/`
6. Create scoped harnesses as needed: `domains/foo/.harmony/`, `services/foo/.harmony/`

For detailed documentation, see `.harmony/cognition/_meta/architecture/shared-foundation.md`.

### When to Consider Publishing

If you have 5+ repositories using this pattern, frequent updates, or need semantic versioning, consider publishing `.harmony/` as a reusable distribution. See `.harmony/cognition/_meta/architecture/shared-foundation.md#when-to-consider-a-package` for guidance.

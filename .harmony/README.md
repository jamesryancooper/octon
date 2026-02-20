# .harmony: Shared Harness Foundation

## Purpose

`.harmony/` provides **reusable infrastructure** for agent harnesses across the repository:

- Generic agents, assistants, teams, workflows, commands, prompts
- Harness templates for scaffolding
- Skills framework and base skills
- Assurance checklists and context references

## One-Page Overview

Harmony is an **AI-native, human-governed engineering harness**. It is not the
product code itself; it is the operating layer around the codebase that makes
planning, delivery, governance, and learning consistent and repeatable.

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

- Standardizing execution through agents, assistants, workflows, and skills
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
- `runtime/`: executable runtime and studio tooling
- `output/`: generated artifacts and reports

Discovery follows progressive disclosure:

1. `manifest.yml` for indexing and routing
2. `registry.yml` for extended metadata
3. Full definitions (`SKILL.md`, workflow docs, contracts) when needed

Governance is explicit:

- Consequential side effects are governed by deny-by-default policy, ACP gates,
  reversibility requirements, and append-only receipts
- Agent autonomy is bounded by contract precedence and policy
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
| Agents | `.harmony/agency/actors/agents/` |
| Assistants | `.harmony/agency/actors/assistants/` |
| Teams | `.harmony/agency/actors/teams/` |
| Templates | `.harmony/scaffolding/templates/` |
| Workflows | `.harmony/orchestration/runtime/workflows/` |
| Skills | `.harmony/capabilities/runtime/skills/` |
| Commands | `.harmony/capabilities/runtime/commands/` |
| Prompts | `.harmony/scaffolding/prompts/` |
| Checklists | `.harmony/assurance/` |
| Context | `.harmony/cognition/context/` |

## Structure

```
.harmony/
├── README.md           <- You are here
│
├── agency/
│   ├── manifest.yml    <- Actor discovery and routing metadata
│   ├── _meta/architecture/ <- Agency subsystem specification
│   ├── governance/     <- Cross-agent contracts (constitution, delegation, memory)
│   ├── actors/         <- Runtime actor artifacts
│   │   ├── agents/     <- Autonomous supervisors
│   │   ├── assistants/ <- Generic specialists (@mention invocation)
│   │   └── teams/      <- Reusable multi-actor compositions
│   ├── practices/      <- Human-agent operating practices
│   └── _ops/           <- Validation scripts and operational checks
│
├── capabilities/
│   ├── _meta/architecture/ <- Capabilities subsystem specification
│   ├── _ops/           <- Agent-native deny-by-default control plane assets
│   ├── skills/         <- Skills framework + generic skills
│   ├── commands/       <- Generic atomic operations
│   ├── tools/          <- Tool packs and custom tools
│   └── services/       <- Typed domain capabilities (+ services/_meta/docs/)
│
├── cognition/
│   ├── _meta/architecture/ <- Cross-cutting harness architecture
│   ├── principles/     <- Canonical principles and guardrails
│   ├── methodology/    <- AI-native development methodology
│   ├── context/        <- Generic reference material (tools, compaction)
│   ├── decisions/      <- Architecture Decision Records
│   └── analyses/       <- Analytical artifacts
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
│   ├── templates/      <- Harness scaffolding (harmony/, harmony-docs/, harmony-node-ts/)
│   ├── prompts/        <- Task templates
│   └── examples/       <- Reference patterns
│
├── assurance/            <- Assurance gates (complete.md, session-exit.md)
│   └── _meta/architecture/ <- Assurance subsystem specification
│
├── ideation/           <- Human-led zone (scratchpad/, projects/)
│   └── _meta/architecture/ <- Ideation subsystem specification
│
├── output/             <- Reports, drafts, artifacts
│   └── _meta/architecture/ <- Output subsystem specification
│
└── runtime/            <- Executable runtime layer (kernel, launchers, specs)
    ├── _meta/evidence/ <- Runtime verification and audit evidence
    ├── _ops/bin/       <- Runtime-local prebuilt binaries
    ├── _ops/state/     <- Runtime-local mutable state
    ├── config/         <- Runtime policy and cache configuration
    ├── crates/         <- Runtime implementation crates
    ├── spec/           <- Runtime schema/protocol specifications
    └── wit/            <- Canonical runtime WIT contracts
```

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
- Domain-specific context (`cognition/context/` — decisions, lessons, glossary, constraints)
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
2. Run script implementations directly (for example: `.harmony/scaffolding/_ops/scripts/init-project.sh`)

## Adopting in Other Repos

To use this harness infrastructure in another repository:

### Quick Start

```bash
# 1. Copy .harmony/ to your repo
cp -r /path/to/harmony/.harmony /path/to/your-repo/

# 2. Initialize project-level bootstrap files (AGENTS.md, CLAUDE.md alias, alignment-check shim)
.harmony/scaffolding/_ops/scripts/init-project.sh

# Optional: also generate BOOT compatibility files
.harmony/scaffolding/_ops/scripts/init-project.sh --with-boot-files

# 3. Customize .harmony/scope.md and .harmony/conventions.md
```

If your tool supports harness commands, run `/init` instead of invoking the script directly. Use `/init --with-boot-files` when `BOOT.md` and `BOOTSTRAP.md` compatibility files are needed.

### What's Included

| Directory | Purpose |
|-----------|---------|
| `scaffolding/templates/` | Harness scaffolding (base + variants) |
| `agency/governance/` | Cross-agent contracts and precedence overlays |
| `agency/actors/agents/` | Supervisory actors and delegation policy |
| `agency/actors/assistants/` | Generic specialists (reviewer, refactor, docs) |
| `agency/actors/teams/` | Reusable multi-actor compositions |
| `agency/practices/` | Human-agent operating standards and delivery discipline |
| `orchestration/runtime/workflows/` | Harness management + mission lifecycle |
| `orchestration/governance/` | Incident governance contracts |
| `orchestration/practices/` | Orchestration operating standards |
| `capabilities/_ops/` | Agent-native deny-by-default control plane (policy, grants, kill-switches, validation) |
| `capabilities/runtime/skills/` | Composable capabilities with defined I/O |
| `capabilities/runtime/commands/` | Atomic operations |
| `scaffolding/prompts/` | Task templates |
| `assurance/` | Assurance gates |
| `cognition/context/` | Tool usage, compaction guides |

### Next Steps

1. Edit `.harmony/scope.md` to define your repo's boundaries
2. Edit `.harmony/conventions.md` for your style rules
3. Add repo-specific context to `.harmony/cognition/context/`
4. Create scoped harnesses as needed: `domains/foo/.harmony/`, `services/foo/.harmony/`

For detailed documentation, see `.harmony/cognition/_meta/architecture/shared-foundation.md`.

### When to Consider Publishing

If you have 5+ repositories using this pattern, frequent updates, or need semantic versioning, consider publishing `.harmony/` as a reusable distribution. See `.harmony/cognition/_meta/architecture/shared-foundation.md#when-to-consider-a-package` for guidance.

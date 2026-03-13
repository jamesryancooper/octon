---
title: The .octon Directory
description: Canonical reference for the domain-organized agent harness pattern.
---

# The `.octon` Directory: A Domain-Organized Agent Harness

## Machine Discovery

- `index.yml` - canonical architecture discovery index for this surface.
- `discovery-index-model.md` - finalized cognition discovery architecture (canonical + sidecar + index contract).
- `README.index.yml` - sidecar section index for this document's headings.
- `resources.index.yml` - sidecar section index for architecture resource headings.
- `artifact-surface/index.yml` - machine-readable index for optional artifact-surface architecture docs.

## Terminology

| Term | Meaning |
|------|---------|
| Octon Framework | The overall methodology, architecture, principles, and reusable system design that can be applied across many repositories and teams |
| Octon Universal Localized Harness | The concrete repo-root `.octon/` implementation inside a specific repository that applies the framework locally |
| Root harness | The primary `.octon/` at repo root that owns repo-wide harness policy and shared defaults |
| Harness | The `.octon/` support structure |
| Domain | A top-level directory organizing related concerns (e.g., `cognition/`, `orchestration/`) |
| Portable infrastructure | Reusable framework assets declared in `octon.yml` |
| Boot sequence | Steps to orient and begin work |
| Cold start | First session without prior context |
| Token budget | Maximum tokens for agent-facing content |

## Octon Universal Localized Harness vs Octon Framework

The terms are related but operate at different levels:

| Dimension | Octon Framework | Octon Universal Localized Harness |
|-----------|-------------------|-------------------------------------|
| **Level** | System-level paradigm | Repository/workspace-level implementation |
| **Scope** | Cross-project, reusable model | Local to one repository |
| **What it includes** | Principles, architecture, governance, and reusable patterns | Concrete `.octon/` files: workflows, skills, continuity, quality gates, context |
| **Portability role** | Defines what should be portable in general | Uses `octon.yml` to declare exactly which local paths are portable |
| **State model** | Conceptual + reusable standards | Operational + stateful (project decisions, continuity, mission artifacts) |
| **Purpose** | Provide a consistent way to build with Octon | Execute Octon in a specific codebase with local context |

**Short rule:** The **Framework** is the "system design"; the **Universal Localized Harness** is that design instantiated in a specific repository so humans and agents can run it.

## Canonical Specification

The cross-subsystem canonical contract is:

- `/.octon/cognition/_meta/architecture/specification.md`

Use subsystem specs for expanded contract details:

- `/.octon/agency/_meta/architecture/specification.md`
- `/.octon/capabilities/_meta/architecture/specification.md`
- `/.octon/orchestration/_meta/architecture/specification.md`
- `/.octon/engine/_meta/architecture/README.md`

Cross-subsystem structure contract:

- `/.octon/cognition/_meta/architecture/bounded-surfaces-contract.md`
- `/.octon/cognition/_meta/architecture/runtime-vs-ops-contract.md`
- `/.octon/cognition/_meta/architecture/discovery-index-model.md`

## Agency Subsystem Docs

For the finalized agency model, see:

- `.octon/agency/_meta/architecture/README.md`
- `.octon/agency/_meta/architecture/specification.md`
- `.octon/agency/_meta/architecture/architecture.md`
- `.octon/agency/_meta/architecture/finalization-plan.md`

---

## Single-Root Architecture

Within the repository, everything lives under one repo-root `.octon/` directory, organized by **domain**.

Canonical root-harness structure:

```
.octon/
    ├── octon.yml          <- Portability metadata
    │
    ├── agency/              <- Actors, governance, practices
    ├── capabilities/        <- Skills, commands, tools
    ├── cognition/           <- Context, decisions, analyses
    ├── continuity/          <- Progress log, tasks, next steps
    ├── ideation/            <- Scratchpad, projects (human-led)
    ├── orchestration/       <- Runtime orchestration, governance, practices
    ├── output/              <- Reports, drafts, artifacts
    ├── assurance/             <- Completion checklists
    └── scaffolding/         <- runtime, governance, practices
```

| Layer | Mechanism | Description |
|-------|-----------|-------------|
| **Portable** | Declared in `octon.yml` | Framework assets that travel across repos (agents, skills, templates, checklists) |
| **Project-specific** | Everything else | Local state: continuity, missions, decisions, project context |

**Portability:** The root harness `octon.yml` manifest declares which paths are portable. Running `octon init` copies those paths to bootstrap a new repo. Project-specific state (continuity logs, missions, decisions) stays with the originating repo. See [octon.yml](#octonyml-portability-metadata) for details.

---

## Core Concept

A `.octon` directory is a **co-located support structure** that contains everything needed to effectively work on a specific area of your project. It's the "working memory" and "instruction set" for that part of the codebase---useful to both human developers and AI agents.

The key insight: **context should live close to where it's needed**, but still remain inside the single repo-root harness so governance, discovery, and validation stay coherent.

---

## Why Locality Matters

1. **Scoped Context Reduces Noise**

When an agent starts working in `.octon/cognition/practices/methodology/`, it can immediately find relevant context in `.octon/` without searching the entire repository. This is critical because:

- Agents have limited context windows
- Irrelevant context dilutes attention
- Domain-specific instructions are more precise than generic ones

2. **Different Areas Have Different Needs**

Your methodology documentation has different workflows than, say, a React component library or an API service. A `.octon` directory lets you define:

- Area-specific checklists and quality criteria
- Relevant style guides and conventions
- Tailored prompts for common tasks
- Domain-appropriate verification steps

3. **Discoverability**

An agent (or human) landing in a directory can immediately ask: "Is there a `.octon` here?" If yes, they know exactly where to find context, instructions, and progress tracking. It's a **convention that scales**.

4. **Encapsulation of Working State**

Agents struggle when they "arrive with no memory of what came before." A `.octon` directory provides a persistent location for:

- Progress tracking across sessions
- Work-in-progress artifacts
- Decision logs and rationale

---

## Full Structure Reference

```text
.octon/
├── octon.yml              # Portability metadata (which paths are portable)
├── START.md                 # Boot sequence (read first)
├── scope.md                 # Boundaries and responsibilities
├── conventions.md           # Style and formatting rules
├── catalog.md               # Index of commands and workflows
│
├── agency/                  # Actors, governance, and operating practices
│   ├── README.md            # Domain orientation (referenced)
│   ├── manifest.yml         # Actor discovery and routing metadata
│   ├── governance/          # Cross-agent governance contracts
│   │   ├── CONSTITUTION.md  # Non-negotiable governance and red lines
│   │   ├── DELEGATION.md    # Delegation authority and escalation contract
│   │   └── MEMORY.md        # Memory retention and privacy contract
│   ├── actors/              # Runtime actor artifacts
│   │   ├── agents/          # Autonomous agent definitions
│   │   │   └── <name>/
│   │   │       ├── AGENT.md # Agent execution contract
│   │   │       └── SOUL.md  # Agent identity contract
│   │   ├── assistants/      # Focused specialists (serve agents/humans)
│   │   │   ├── registry.yml # @mention mappings
│   │   │   ├── _scaffold/template/
│   │   │   │   └── assistant.md
│   │   │   └── <name>/
│   │   │       └── assistant.md
│   │   └── teams/           # Team compositions
│   ├── practices/           # Operating standards and delivery guidance
│   └── _ops/                # Validation scripts and operational checks
│
├── orchestration/           # Runtime orchestration, governance, practices
│   ├── README.md            # Domain orientation (routable + referenced)
│   ├── runtime/             # Runtime orchestration artifacts
│   │   ├── workflows/       # Multi-step procedures
│   │   │   ├── manifest.yml # Workflow index (Tier 1 discovery)
│   │   │   ├── registry.yml # Extended metadata + parameters
│   │   │   └── <workflow-name>/
│   │   └── missions/        # Time-bounded sub-projects
│   │       ├── registry.yml # Active/archived index
│   │       ├── _scaffold/template/
│   │       └── <mission-slug>/
│   │           ├── mission.md # Goal, scope, owner
│   │           ├── tasks.json # Mission-specific tasks
│   │           └── log.md     # Mission-specific progress
│   ├── governance/          # Incident governance contracts
│   └── practices/           # Operating standards and delivery guidance
│
├── capabilities/            # Skills, commands, and tools
│   ├── README.md            # Domain orientation (routable + referenced)
│   ├── skills/              # Composable capabilities
│   │   ├── manifest.yml     # Skill index (Tier 1 discovery)
│   │   ├── capabilities.yml # Skill sets, valid capabilities
│   │   ├── registry.yml     # Extended metadata + I/O mappings
│   │   ├── _scaffold/template/
│   │   │   └── SKILL.md
│   │   ├── <skill-name>/    # Individual skills
│   │   │   └── SKILL.md     # Skill definition
│   │   └── logs/            # Execution logs
│   ├── commands/            # Atomic operations
│   │   └── manifest.yml     # Command index
│   └── tools/               # Tool definitions
│
├── cognition/               # Background knowledge and memory
│   ├── README.md            # Domain orientation (reference material)
│   ├── context/             # Domain knowledge
│   │   ├── index.yml        # Context file index (with "when to read")
│   │   ├── decisions.md     # Agent-readable decision summaries
│   │   ├── lessons.md       # Anti-patterns and failures to avoid
│   │   ├── glossary.md      # Domain-specific terminology
│   │   └── ...              # dependencies.md, constraints.md
│   ├── decisions/           # Structured decision records
│   └── analyses/            # Analysis artifacts
│
├── continuity/              # Session-to-session continuity
│   ├── README.md            # Domain orientation (state contract)
│   ├── log.md               # What's been done (append-only)
│   ├── tasks.json           # Structured task list with goal
│   ├── next.md              # Immediate actionable steps
│   └── entities.json        # Entity state tracking (optional)
│
├── assurance/                 # Verification and quality gates
│   ├── README.md            # Domain orientation (state contract)
│   ├── complete.md          # Definition of done, quality criteria
│   └── session-exit.md      # Steps before ending a session
│
├── scaffolding/             # Reusable building blocks
│   ├── README.md            # Domain orientation (referenced)
│   ├── prompts/             # Reusable task templates
│   ├── templates/           # Boilerplate for new content
│   └── examples/            # Reference patterns (minimal, copyable)
│
├── ideation/                # Human-led zone (AGENTS: HUMAN-LED ONLY)
│   ├── README.md            # Domain orientation (access rules)
│   ├── scratchpad/          # Thinking, staging, and archives
│   │   ├── inbox/           # Temporary staging for imports
│   │   ├── archive/         # Deprecated content
│   │   ├── brainstorm/      # Ideas under structured exploration
│   │   ├── ideas/           # Quick captures, possibilities
│   │   ├── daily/           # Date-based notes (YYYY-MM-DD.md)
│   │   ├── drafts/          # Work-in-progress documents
│   │   └── clips/           # Snippets and fragments
│   └── projects/            # Human-led explorations (produces artifacts)
│       ├── README.md        # Projects overview
│       ├── registry.md      # Active/paused/completed index
│       ├── _scaffold/template/       # New project template
│       └── <project-slug>/  # Individual project
│
├── output/                  # Generated artifacts
│   ├── README.md            # Domain orientation (write contract)
│   ├── reports/             # Analysis reports
│   ├── drafts/              # Draft documents
│   └── artifacts/           # Other generated output
│
└── engine/                  # Executable engine domain
    ├── runtime/             # Runtime implementation + launchers
    ├── governance/          # Normative runtime contracts
    ├── practices/           # Engine operating standards
    ├── _ops/state/          # Runtime-local mutable state
    └── _meta/evidence/      # Runtime verification and audit evidence
```

### Structure Categorization

The full tree above is the **canonical superset** for the repo-root harness.

| Profile | Baseline | Notes |
|---------|----------|-------|
| **Root harness (repo-wide)** | `octon.yml`, `START.md`, `scope.md`, `conventions.md`, `catalog.md`, `continuity/`, `assurance/`, `scaffolding/practices/prompts/`, `orchestration/runtime/workflows/`, `orchestration/governance/`, `orchestration/practices/`, `capabilities/runtime/commands/`, `cognition/runtime/context/`, `engine/` | The root harness is the primary coordination surface and is expected to carry full governance/state coverage |

---

## `octon.yml`: Portability Metadata

The `octon.yml` file at the root of `.octon/` is the **single source of truth** for portability, autonomy, and resolution rules. It replaces the old two-root convention with metadata-driven portability.

```yaml
schema_version: "1.0"

# Portable paths -- copy these to bootstrap a new repo via `octon init`.
# Everything else is project-specific state that stays with this repo.
portable:
  - START.md
  - scope.md
  - conventions.md
  - catalog.md
  - README.md
  - agency/manifest.yml
  - agency/governance/
  - agency/runtime/agents/
  - agency/runtime/assistants/
  - agency/runtime/teams/
  - agency/practices/
  - capabilities/runtime/skills/manifest.yml
  - capabilities/runtime/skills/registry.yml
  - capabilities/runtime/skills/capabilities.yml
  - capabilities/runtime/skills/_scaffold/template/
  - capabilities/runtime/skills/_ops/scripts/
  - capabilities/runtime/skills/**/SKILL.md
  - capabilities/runtime/skills/**/references/
  - capabilities/runtime/commands/
  - orchestration/runtime/workflows/
  - orchestration/governance/
  - orchestration/practices/
  - assurance/
  - scaffolding/
  - cognition/runtime/context/primitives.md
  - cognition/runtime/context/tools.md
  - cognition/runtime/context/compaction.md

# Agent-excluded zones. Agents MUST NOT access without explicit human direction.
human_led:
  - ideation/**

# Resolution rules for capabilities that span framework and project concerns.
resolution:
  agency: "Framework definitions loaded; project overrides merged on top"
  capabilities: "Single manifest and registry; no extends pattern"
  orchestration: "Framework workflows and project workflows coexist"
```

| Section | Purpose |
|---------|---------|
| `portable` | Paths that `octon init` copies to new repos. These are the framework assets. |
| `human_led` | Paths agents must not access autonomously. |
| `resolution` | Rules for how framework and project content coexist. |

**Key principle:** Portability is declared as metadata, not directory structure. There is no separate "shared" directory---`octon.yml` tells tooling which parts of `.octon/` are reusable framework assets and which are project-specific state.

---

## The Flat Structure Philosophy

Everything at the domain level is **agent-facing**. The sole exception is `ideation/`, which is **human-led**.

| Directory | Agent Access |
|-----------|-------------|
| `agency/`, `capabilities/`, `cognition/`, `continuity/`, `orchestration/`, `output/`, `assurance/`, `scaffolding/` | Agent reads and writes freely |
| `ideation/` | Human-led only (declared in `octon.yml`) |

This single rule eliminates ambiguity. The `ideation/` directory consolidates all human-led content (scratchpad, projects) in one place, and agents know to ignore it during autonomous operation.

---

## Domain Orientation Contract

Every domain has a `README.md` that answers three questions: *What is this? What's in it? How do agents interact with it?* The depth of each README is proportional to the domain's interaction model---routable domains point to their discovery stacks, while simpler domains document their read/write contracts directly.

### Universal README Template

All domain READMEs follow this structure:

```markdown
# {Domain Name}

{One-line purpose.}

## Contents

{Table: subdirectory/file | purpose | discovery/index file}

## Interaction Model

{How agents interact with this domain.}
```

Additional sections vary by interaction model:

| Interaction Model | Domains | README Adds |
|-------------------|---------|-------------|
| **Routable** | capabilities (skills), orchestration (workflows) | Pointer to `manifest.yml` discovery stack |
| **Referenced** | agency, capabilities (commands), scaffolding | Inline contents table with index file references |
| **Reference material** | cognition | "When to Read" guidance per file; `context/index.yml` reference |
| **State** | continuity, quality, output | Read/write contract (what to read before work, what to update after) |
| **Human-gated** | ideation | Access restriction rules |

### Discovery Proportionality

Not every domain needs a manifest. Discovery depth is proportional to how agents find and use the domain's contents:

| Pattern | When Used | Examples |
|---------|-----------|---------|
| **3-tier progressive disclosure** (manifest → registry → definition) | Routable capabilities with intent matching | Skills, workflows |
| **Lightweight manifest** (flat YAML index) | Enumerable items accessed by name | Commands |
| **Lightweight index** (YAML with "when to read" guidance) | Reference files agents selectively load | Cognition context |
| **Registry** (YAML tracking active items) | Items with lifecycle state | Missions, assistants, teams |
| **README table only** | Small, fixed set of files | Quality, continuity, output |

### Machine-Readable Indexes

Two domains have dedicated indexes beyond their README:

- **`capabilities/runtime/commands/manifest.yml`** --- Lightweight command index (id, display_name, summary, access, argument_hint). Simpler than skills/workflows manifests: no triggers, no skill sets, no groups. Commands are deterministic and invoked by name, not by intent matching.

- **`cognition/runtime/context/index.yml`** --- Context file index with a `when` field per entry, telling agents when each reference file is relevant to their current task. Avoids loading all context files to find the one needed.

---

## Agent Ignore Convention

### Why `.octon` itself is dot-prefixed

The `.octon` directory uses a dot prefix to signal "supporting infrastructure, not primary content." This follows conventions like `.git/`, `.vscode/`, and `.github/`---directories that tooling actively uses but that aren't the main content of a project.

**Agents should actively look for `.octon`** when starting work in an area. The dot prefix indicates "this is where you find your harness," not "ignore this."

### The `ideation/` Directory

The `ideation/` directory consolidates human-led content. It is **off-limits to autonomous agents**:

| Directory | Purpose | Autonomy Level |
|-----------|---------|----------------|
| `ideation/scratchpad/` | Human-led zone for thinking, staging, and archives | **Human-led only** |
| `ideation/projects/` | Human-led explorations that produce artifacts | **Human-led only** |

#### The Scratchpad

`ideation/scratchpad/` consolidates human-led ephemeral content and the early-stage idea funnel:

| Subdirectory | Purpose | Lifecycle |
|--------------|---------|-----------|
| `inbox/` | Temporary staging for imports | Move out when processed |
| `archive/` | Deprecated content | Permanent reference |
| `brainstorm/` | Ideas under structured exploration | Graduate to projects or kill |
| `ideas/` | Quick captures, possibilities | Graduate to brainstorm or die |
| `drafts/` | Work-in-progress | Promote when ready |
| `daily/` | Date-based notes | Reference |

**The Funnel:** Ideas flow from scratchpad to committed work:

```
ideation/scratchpad/ideas/      -> Quick captures (most die here)
        |
ideation/scratchpad/brainstorm/ -> Structured exploration (filter stage)
        |
ideation/projects/              -> Committed research (produces artifacts)
        |
orchestration/runtime/missions/         -> Committed execution
        |
cognition/runtime/context/              -> Permanent knowledge
```

#### Human-Led Collaboration

`ideation/` has a special collaboration mode:

| Rule | Description |
|------|-------------|
| **No autonomous access** | Agents MUST NOT scan, read, or write during autonomous operation |
| **Human-directed only** | Agents MAY access ONLY when a human explicitly points to specific files AND requests specific changes |
| **Scoped work** | When directed, agent work stays within the referenced files |

**Example: Valid collaboration**

```text
Human: "Review ideation/projects/auth-research/findings.md and summarize"
Agent: [Reads the specific file, provides summary as directed]
```

**Example: Invalid autonomous action**

```text
Agent: "I noticed some relevant notes in ideation/scratchpad/ that might help..."
-> VIOLATION: Agent scanned ideation/scratchpad/ without explicit human direction
```

#### Projects and the Funnel

Projects (`ideation/projects/`) have a distinct role in the funnel because they frequently produce artifacts that feed the main harness. Projects are still human-led (require explicit direction) but findings flow directly to `cognition/runtime/context/` without a separate promotion step.

| Content Type | Destination |
|--------------|-------------|
| Design decisions | `cognition/runtime/context/decisions.md` |
| Anti-patterns | `cognition/runtime/context/lessons.md` |
| New terminology | `cognition/runtime/context/glossary.md` |
| Actionable work | Create mission in `orchestration/runtime/missions/` |

**Rule:** Summarize and distill findings; don't copy project notes verbatim.

---

## Design Rationale

### Root-Level Files

The root-level files form an **orientation layer**---the first things an agent reads before diving into domains.

| File | Purpose |
|------|---------|
| `octon.yml` | Portability metadata, autonomy rules, resolution rules |
| `START.md` | Boot sequence, prerequisites, first actions |
| `scope.md` | Boundaries, in/out of scope, decision authority |
| `conventions.md` | Style rules, terminology, formatting standards |
| `catalog.md` | Index of available commands and workflows in this harness |

### Domains

Each domain has a `README.md` that provides orientation. The README depth is proportional to how agents interact with that domain (see [Domain Orientation Contract](#domain-orientation-contract)).

| Directory | Purpose | Contains | Interaction Model |
|-----------|---------|----------|-------------------|
| `agency/` | Actor + governance boundaries | Actors, governance, practices | Referenced |
| `capabilities/` | Executable capabilities | Skills, commands, tools | Routable + Referenced |
| `cognition/` | Background knowledge and memory | Context, decisions, analyses | Reference material |
| `continuity/` | Session-to-session state | Log, tasks, entities | State (read/write contract) |
| `ideation/` | Human-led exploration | Scratchpad, projects | Human-gated |
| `orchestration/` | Coordination and execution | Runtime, governance, practices | Routable + Referenced |
| `output/` | Generated artifacts | Reports, drafts, artifacts | State (write contract) |
| `assurance/` | Verification and quality gates | Completion checklists, session-exit | State (quality gates) |
| `scaffolding/` | Reusable building blocks | runtime, governance, practices | Referenced |

### Mapping from Previous Structure

For reference, here is how the previous flat structure maps to domains:

| Previous Path | Current Path |
|---------------|--------------|
| `agents/` | `agency/runtime/agents/` |
| `assistants/` | `agency/runtime/assistants/` |
| `teams/` | `agency/runtime/teams/` |
| `context/` | `cognition/runtime/context/` |
| `progress/` | `continuity/` |
| `checklists/` | `assurance/` |
| `workflows/` | `orchestration/runtime/workflows/` |
| `missions/` | `orchestration/runtime/missions/` |
| `commands/` | `capabilities/runtime/commands/` |
| `skills/` | `capabilities/runtime/skills/` |
| `prompts/` | `scaffolding/practices/prompts/` |
| `templates/` | `scaffolding/runtime/templates/` |
| `examples/` | `scaffolding/practices/examples/` |
| `patterns/` | `scaffolding/governance/patterns/` |
| `projects/` | `ideation/projects/` |
| `.scratchpad/` | `ideation/scratchpad/` |
| *(new)* | `output/` |

---

## Benefits of This Approach

1. **Agent Efficiency** --- An agent reads `START.md` and immediately knows how to begin useful work

2. **Human-Agent Parity** --- The same structure helps human developers; it's onboarding documentation that also works for agents

3. **Incremental Adoption** --- Start with high-churn areas; the convention scales as needed

4. **Domain Specialization** --- Each area can define its own checklists, workflows, and prompts

5. **Reduced "One-Shotting"** --- Explicit task lists and incremental workflows guide agents toward smaller, verifiable steps

6. **Domain Organization** --- Related concerns are co-located under intuitive top-level domains, reducing cognitive overhead

7. **Metadata-Driven Portability** --- `octon.yml` declares what is reusable vs. project-specific, enabling clean bootstrapping without directory duplication

---

## When to Create a Harness

Not every directory needs a `.octon`. Use this guide to decide.

### Create a harness when

| Situation | Why it helps |
|-----------|--------------|
| **Large monorepo with distinct areas** | Each area gets scoped context; agents don't load irrelevant instructions |
| **Multi-session or long-running tasks** | Progress tracking survives context window resets |
| **Complex constraints or conventions** | Domain-specific rules are captured where they're needed |
| **Multiple agents working in parallel** | Each area has its own task list and progress log |
| **High-churn areas** | Frequent work benefits from established patterns and checklists |
| **Areas with unique workflows** | Custom prompts and procedures live close to where they're used |

### Skip the harness when

| Situation | Why it's overkill |
|-----------|-------------------|
| **Small, single-purpose repos** | A root README suffices |
| **One-shot tasks** | No continuity needed; just do the work |
| **Areas where a README suffices** | If scope/conventions/progress aren't complex, don't add ceremony |
| **Rarely touched directories** | Maintenance burden exceeds benefit |
| **Leaf directories with no sub-work** | A single file doesn't need a harness |

### Key strengths

| Strength | What it addresses |
|----------|-------------------|
| **Locality** | Guidance for X lives next to X---no hunting through centralized docs |
| **Scoped context** | Agent loads only relevant context, not the entire repo |
| **Continuity** | `continuity/log.md` + `tasks.json` survive context resets |
| **Explicit boundaries** | `scope.md` prevents scope creep; agent knows when to stop |
| **Quality gates** | `assurance/practices/complete.md` checklist prevents premature completion |
| **Separation** | Agent-facing vs human-led is explicit (`ideation/` directory) |

### Risks to watch

| Risk | Mitigation |
|------|------------|
| **Proliferation** | Don't create harnesses everywhere---only where sustained agent work happens |
| **Drift** | Use harness rules to enforce consistency; consider a linter |
| **Maintenance burden** | Keep harnesses minimal; archive stale ones |
| **Discovery** | Harness rules auto-trigger; boot sequence is standardized |
| **Duplication** | Use `octon.yml` portable declarations to share framework assets |

### The adoption heuristic

Ask: **"Does this repository need a repo-root Octon harness at all?"**

- **Yes** --- Adopt the repo-root `/.octon/` bundle and bootstrap it with
  `/init`
- **No** --- A README or inline comments suffice

---

## The Meta-Pattern

What we're developing is essentially a **recursive documentation pattern**:

- The main content is the *what*
- The `.octon` is the *how* and *why* of working on that content

This mirrors how effective engineering teams operate: not just code, but runbooks, playbooks, and institutional knowledge that lives close to the code it supports.

The `.octon` directory formalizes this for the age of AI agents, creating a **co-located harness** that enables effective, incremental, well-tested work across context windows.

---

## Repo-Root Harness

Octon supports one active harness per repository at `/<repo>/.octon/`.

Domain-specific context should live under repo-root harness paths such as:

- `.octon/cognition/runtime/context/`
- `.octon/orchestration/runtime/workflows/`
- `.octon/continuity/`

---

## Universal Harness-Agnostic Pattern

Harnesses are designed to be **portable across all AI harnesses**---Cursor, Claude Code, Codex, or any future tool.

### Design Principle

```
+------------------------------------------------------------+
|                     AI Harnesses                           |
+--------------+--------------+--------------+--------------+
|    Cursor    |  Claude Code |    Codex     |    Future    |
|  /command    |  /command    |  /command    |   /command   |
|              |              |              |              |
|  .cursor/    |  .claude/    |  .codex/     |  .<harness>/ |
|  commands/   |  commands/   |  commands/   |   commands/  |
+------+-------+------+-------+------+-------+------+-------+
       |              |              |              |
       v              v              v              v
+------------------------------------------------------------+
|               PRIMARY .octon/ ROOT (repo-level)           |
+------------------------------------------------------------+
|  .octon/                                                  |
|  +-- octon.yml           (portability metadata)           |
|  +-- orchestration/        (runtime, governance, practices) |
|  +-- capabilities/         (skills, commands)               |
|  +-- agency/               (actors, governance, practices)  |
|  +-- ...                                                    |
+------------------------------------------------------------+
```

| Principle | Description |
|-----------|-------------|
| **Single root per repository** | Each repository uses one repo-root `.octon/` |
| **`octon.yml` declares portability** | Metadata specifies which paths are framework assets vs. project-specific |
| **Harness entry points are thin wrappers** | `.<harness>/commands/` only provides syntax and delegation |
| **No harness-specific logic in workflows** | Workflows work identically regardless of invoking harness |
| **Harness is portable** | Copy a `.octon/` to any repo; `octon.yml` declares what to include |

See [workflows.md](/.octon/orchestration/_meta/architecture/workflows.md) for the full implementation pattern.

---

## Harness Integration

### Cursor

Canonical harness-rule policy packs live in
`.octon/engine/governance/rules/`. The Cursor adapter entry point
`.cursor/rules/octon/RULE.md` (symlinked from the canonical rules surface)
provides context when editing `.octon/` files. It:

- Triggers on glob pattern `**/.octon/**`
- Points agents to canonical references
- Provides key principles and token budget guidelines
- Uses "Apply Intelligently" (not always-apply) to avoid unnecessary context in non-harness sessions

### Harness Entry Points

Harness-specific commands wrap workflows for integration. All workflows live in `.octon/`:

| Command | Delegates To |
|---------|--------------|
| `/update-harness` | `.octon/orchestration/runtime/workflows/meta/update-harness/` |
| `/evaluate-harness` | `.octon/orchestration/runtime/workflows/meta/evaluate-harness/` |
| `/migrate-harness` | `.octon/orchestration/runtime/workflows/meta/migrate-harness/` |
| `/bootstrap` | `.octon/scaffolding/practices/prompts/bootstrap-session.md` |
| `/synthesize-research` | `.octon/capabilities/runtime/skills/synthesis/synthesize-research/` |
| `/research` | `.octon/orchestration/runtime/workflows/projects/create-project.md` |

These commands live in `.<harness>/commands/` (e.g., `.cursor/commands/`, `.claude/commands/`) and are thin wrappers that delegate to `.octon/` paths.

---

## Token Budget Guidelines

See `.octon/engine/governance/rules/adapters/cursor/octon/RULE.md` for
the authoritative token budget table used by Cursor rule adapters.

**Summary:** Target ~2,000 tokens total, ~300 per file, ~200 for START.md. A compact harness leaves maximum context window for actual work.

---

## Related Documentation

### Core Concepts

- [Taxonomy](./taxonomy.md) --- Harness entry points, harness commands, workflows, and their relationships
- [Harness Workflows](/.octon/orchestration/_meta/architecture/workflows.md) --- Multi-step procedures and the Universal Harness-Agnostic Pattern
- [Harness Commands](/.octon/capabilities/_meta/architecture/commands.md) --- Harness-scoped atomic operations
- [Agency](/.octon/agency/_meta/architecture/README.md) --- Canonical actor taxonomy, contracts, and architecture
- [Missions](/.octon/orchestration/_meta/architecture/missions.md) --- Time-bounded sub-projects
- [Skills](/.octon/capabilities/_meta/architecture/README.md) --- Composable capabilities with defined I/O

### Directory Documentation

- [Scratchpad](/.octon/ideation/_meta/architecture/scratchpad.md) --- Human-led thinking space and idea funnel
- [Projects](/.octon/ideation/_meta/architecture/projects.md) --- Human-led explorations that produce harness artifacts
- [Prompts](/.octon/scaffolding/_meta/architecture/prompts.md) --- Reusable task templates
- [Templates](/.octon/scaffolding/_meta/architecture/templates.md) --- Boilerplate for new content
- [Examples](/.octon/scaffolding/_meta/architecture/examples.md) --- Reference patterns
- [Progress](/.octon/continuity/_meta/architecture/progress.md) --- Session continuity tracking
- [Context](./context.md) --- Background knowledge
- [Checklists](/.octon/assurance/_meta/architecture/checklists.md) --- Quality gates
- [Scripts](/.octon/scaffolding/_meta/architecture/scripts.md) --- Shell utilities for harness maintenance

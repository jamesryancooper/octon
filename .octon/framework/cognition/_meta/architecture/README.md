---
title: The .octon Directory
description: Canonical reference for the class-first super-root harness pattern.
---

# The `.octon` Directory: A Class-First Super-Root Harness

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
| Domain | A subsystem inside `framework/` or `instance/` that organizes related concerns |
| Portable infrastructure | Profile-defined framework and instance payloads governed by `octon.yml` |
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
| **Portability role** | Defines what should be portable in general | Uses `octon.yml` profiles to declare install/export units and fail-closed policy hooks |
| **State model** | Conceptual + reusable standards | Operational + stateful (project decisions, continuity, mission artifacts) |
| **Purpose** | Provide a consistent way to build with Octon | Execute Octon in a specific codebase with local context |

**Short rule:** The **Framework** is the "system design"; the **Universal Localized Harness** is that design instantiated in a specific repository so humans and agents can run it.

## Canonical Specification

The cross-subsystem canonical contract is:

- `/.octon/framework/cognition/_meta/architecture/specification.md`

Use subsystem specs for expanded contract details:

- `/.octon/framework/agency/_meta/architecture/specification.md`
- `/.octon/framework/capabilities/_meta/architecture/specification.md`
- `/.octon/framework/orchestration/_meta/architecture/specification.md`
- `/.octon/framework/engine/_meta/architecture/README.md`

Cross-subsystem structure contract:

- `/.octon/framework/cognition/_meta/architecture/bounded-surfaces-contract.md`
- `/.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
- `/.octon/framework/cognition/_meta/architecture/discovery-index-model.md`

## Agency Subsystem Docs

For the finalized agency model, see:

- `.octon/framework/agency/_meta/architecture/README.md`
- `.octon/framework/agency/_meta/architecture/specification.md`
- `.octon/framework/agency/_meta/architecture/architecture.md`
- `.octon/framework/agency/_meta/architecture/finalization-plan.md`

---

## Single-Root Architecture

Within the repository, everything lives under one repo-root `.octon/`
directory, organized first by **artifact class** and then by subsystem.

Canonical root-harness structure:

```text
.octon/
  README.md
  AGENTS.md
  octon.yml
  framework/
  instance/
  inputs/
  state/
  generated/
```

| Class root | Authority | Description |
|-------|-----------|-------------|
| `framework/` | Authored authority | Portable Octon core organized internally by subsystem |
| `instance/` | Authored authority | Repo-specific durable authority and repo bindings |
| `inputs/` | Non-authoritative | Additive packs and exploratory inputs |
| `state/` | Operational truth | Mutable continuity, evidence, and control state |
| `generated/` | Derived only | Rebuildable effective views, summaries, graphs, and registries |

**Portability:** `octon.yml` no longer declares a broad path allowlist. It
defines install/export profiles, class-root bindings, version compatibility,
human-led zones, and fail-closed policies. `bootstrap_core` is the install
contract completed by `/init`; `repo_snapshot` and `pack_bundle` are exported
through `/export-harness`; `full_fidelity` is advisory only and uses normal
Git clone semantics. See [octon.yml](#octonyml-root-manifest-contract) for
details.

---

## Core Concept

A repo-root `.octon/` directory is the **co-located support structure** for
the repository. Its top level is class-first so authored authority, raw
inputs, operational truth, and rebuildable outputs are explicit before any
domain-specific guidance is resolved.

The key insight: **context should live close to where it's needed**, but still
remain inside the single repo-root harness so governance, discovery, and
validation stay coherent.

---

## Why Locality Matters

1. **Scoped Context Reduces Noise**

When an agent starts working in `.octon/framework/cognition/practices/methodology/`, it can immediately find relevant context in `.octon/` without searching the entire repository. This is critical because:

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

An agent (or human) landing anywhere in the repository can resolve the repo root and load `/.octon/`. That keeps discovery deterministic without supporting descendant harnesses.

4. **Encapsulation of Working State**

Agents struggle when they "arrive with no memory of what came before." A `.octon` directory provides a persistent location for:

- Progress tracking across sessions
- Work-in-progress artifacts
- Decision logs and rationale

---

## Full Structure Reference

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
│   ├── locality/
│   ├── cognition/
│   ├── governance/
│   ├── agency/
│   ├── assurance/
│   ├── capabilities/
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

### Structure Categorization

The tree above is the canonical super-root. Top-level placement is class-based;
subsystem organization happens inside `framework/` and `instance/`.

---

## `octon.yml`: Root Manifest Contract

The `octon.yml` file at the root of `.octon/` is the **single source of
truth** for topology, versioning, profiles, autonomy boundaries, and
fail-closed policy hooks.

```yaml
schema_version: "octon-root-manifest-v2"

topology:
  super_root: ".octon/"
  class_roots:
    framework: "framework/"
    instance: "instance/"
    inputs: "inputs/"
    state: "state/"
    generated: "generated/"

versioning:
  harness:
    release_version: "0.5.0"
    supported_schema_versions:
      - "octon-root-manifest-v2"
      - "octon-framework-manifest-v2"
      - "octon-instance-manifest-v1"
  extensions:
    api_version: "1.0"

profiles:
  bootstrap_core:
    include:
      - "octon.yml"
      - "framework/**"
      - "instance/manifest.yml"
  repo_snapshot:
    include:
      - "octon.yml"
      - "framework/**"
      - "instance/**"
      - "inputs/additive/extensions/<enabled-and-dependent>/**"
    exclude:
      - "inputs/exploratory/**"
      - "state/**"
      - "generated/**"
  pack_bundle:
    selector: "inputs/additive/extensions/<selected>/**"
    include_dependency_closure: true
  full_fidelity:
    advisory: "Use a normal Git clone for exact repository reproduction."

policies:
  raw_input_dependency: "fail-closed"
  generated_staleness: "fail-closed"

zones:
  human_led:
    - "inputs/exploratory/ideation/**"
```

| Section | Purpose |
|---------|---------|
| `topology` | Super-root home and class-root bindings |
| `versioning` | Harness release and compatibility contracts |
| `profiles` | Install/export/update units and profile semantics |
| `policies` | Fail-closed raw-input and staleness rules |
| `zones` | Human-led or excluded areas |

**Key principle:** Portability is profile-driven, not broad-path copy driven.
`/init` completes `bootstrap_core`; `/export-harness` materializes
`repo_snapshot` and `pack_bundle`; `full_fidelity` is advisory only.

---

## Super-Root Philosophy

Everything at the top level is classified first by authority and lifecycle,
not by subsystem. Human-led ideation remains under
`inputs/exploratory/ideation/**` and stays excluded from autonomous access
unless explicitly requested.

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

### Class Roots

Each class root has a distinct authority contract. The top level is no longer a
mixed domain tree.

| Directory | Purpose | Contains | Interaction Model |
|-----------|---------|----------|-------------------|
| `framework/` | Portable authored Octon core | Companion manifest, overlay registry, authored framework domains | Authoritative authored core |
| `instance/` | Repo-specific durable authority | Ingress, bootstrap, locality, context, decisions, missions, extensions config | Authoritative repo-owned |
| `inputs/` | Non-authoritative additive and exploratory material | Extension packs, proposals, plans, drafts, ideation | Non-authoritative source material |
| `state/` | Operational truth and retained evidence | Continuity, control state, evidence bundles | Mutable operational truth |
| `generated/` | Rebuildable derived outputs | Effective views, reports, registries, projections | Derived and non-authoritative |

### Legacy Mapping

For reference, here is how the retired mixed-tree structure maps into the
current class-root topology:

| Previous Path | Current Path |
|---------------|--------------|
| `agents/`, `assistants/`, `teams/` | `framework/agency/runtime/` |
| `commands/`, `skills/`, `tools/`, `services/` | `framework/capabilities/runtime/` |
| `context/` | `instance/cognition/context/` |
| `progress/` | `state/continuity/repo/` |
| `checklists/` | `framework/assurance/practices/` |
| `workflows/` | `framework/orchestration/runtime/workflows/` |
| `missions/` | `instance/orchestration/missions/` |
| `prompts/`, `templates/`, `examples/`, `patterns/` | `framework/scaffolding/` |
| `projects/`, `.scratchpad/` | `inputs/exploratory/ideation/` |
| `output/` | `generated/` and `state/evidence/validation/` depending artifact class |

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
| **Proliferation** | Don't add `.octon/` to every folder; use one repo-root harness and organize domain guidance beneath it |
| **Drift** | Use harness rules to enforce consistency; consider a linter |
| **Maintenance burden** | Keep harnesses minimal; archive stale ones |
| **Discovery** | Harness rules auto-trigger; boot sequence is standardized |
| **Duplication** | Use `octon.yml` profiles and exported bundles rather than ad hoc path copying |

### The adoption heuristic

Ask: **"Does this repository need a repo-root Octon harness at all?"**

- **Yes** --- Adopt the repo-root `bootstrap_core` bundle and complete
  bootstrap with `/init`
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

- `.octon/instance/cognition/context/shared/`
- `.octon/framework/orchestration/runtime/workflows/`
- `.octon/state/continuity/repo/`

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
|  +-- octon.yml           (root manifest)                  |
|  +-- framework/          (portable authored core)         |
|  +-- instance/           (repo-specific authority)        |
|  +-- inputs/             (raw additive/exploratory input) |
|  +-- state/              (operational truth/evidence)     |
|  +-- generated/          (rebuildable outputs)            |
|  +-- ...                                                    |
+------------------------------------------------------------+
```

| Principle | Description |
|-----------|-------------|
| **Single root per repository** | Each repository uses one repo-root `.octon/` |
| **`octon.yml` declares profiles and topology** | Metadata specifies class roots, versioning, install/export units, and fail-closed policies |
| **Harness entry points are thin wrappers** | `.<harness>/commands/` only provides syntax and delegation |
| **No harness-specific logic in workflows** | Workflows work identically regardless of invoking harness |
| **Harness portability is profile-driven** | Use `bootstrap_core`, `repo_snapshot`, or `pack_bundle`; use Git clone for `full_fidelity` |

See [workflows.md](/.octon/framework/orchestration/_meta/architecture/workflows.md) for the full implementation pattern.

---

## Harness Integration

### Cursor

Canonical harness-rule policy packs live in
`.octon/framework/engine/governance/rules/`. The Cursor adapter entry point
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
| `/update-harness` | `.octon/framework/orchestration/runtime/workflows/meta/update-harness/` |
| `/evaluate-harness` | `.octon/framework/orchestration/runtime/workflows/meta/evaluate-harness/` |
| `/migrate-harness` | `.octon/framework/orchestration/runtime/workflows/meta/migrate-harness/` |
| `/bootstrap` | `.octon/framework/scaffolding/practices/prompts/bootstrap-session.md` |
| `/synthesize-research` | `.octon/framework/capabilities/runtime/skills/synthesis/synthesize-research/` |
| `/research` | `.octon/framework/orchestration/runtime/workflows/projects/create-project.md` |

These commands live in `.<harness>/commands/` (e.g., `.cursor/commands/`, `.claude/commands/`) and are thin wrappers that delegate to `.octon/` paths.

---

## Token Budget Guidelines

See `.octon/framework/engine/governance/rules/adapters/cursor/octon/RULE.md` for
the authoritative token budget table used by Cursor rule adapters.

**Summary:** Target ~2,000 tokens total, ~300 per file, ~200 for START.md. A compact harness leaves maximum context window for actual work.

---

## Related Documentation

### Core Concepts

- [Taxonomy](./taxonomy.md) --- Harness entry points, harness commands, workflows, and their relationships
- [Harness Workflows](/.octon/framework/orchestration/_meta/architecture/workflows.md) --- Multi-step procedures and the Universal Harness-Agnostic Pattern
- [Harness Commands](/.octon/framework/capabilities/_meta/architecture/commands.md) --- Harness-scoped atomic operations
- [Agency](/.octon/framework/agency/_meta/architecture/README.md) --- Canonical actor taxonomy, contracts, and architecture
- [Missions](/.octon/framework/orchestration/_meta/architecture/missions.md) --- Time-bounded sub-projects
- [Skills](/.octon/framework/capabilities/_meta/architecture/README.md) --- Composable capabilities with defined I/O

### Directory Documentation

- [Scratchpad](/.octon/framework/cognition/_meta/architecture/inputs/exploratory/ideation/scratchpad.md) --- Human-led thinking space and idea funnel
- [Projects](/.octon/framework/cognition/_meta/architecture/inputs/exploratory/ideation/projects.md) --- Human-led explorations that produce harness artifacts
- [Prompts](/.octon/framework/scaffolding/_meta/architecture/prompts.md) --- Reusable task templates
- [Templates](/.octon/framework/scaffolding/_meta/architecture/templates.md) --- Boilerplate for new content
- [Examples](/.octon/framework/scaffolding/_meta/architecture/examples.md) --- Reference patterns
- [Progress](/.octon/framework/cognition/_meta/architecture/state/continuity/progress.md) --- Session continuity tracking
- [Context](./context.md) --- Background knowledge
- [Checklists](/.octon/framework/assurance/_meta/architecture/checklists.md) --- Quality gates
- [Scripts](/.octon/framework/scaffolding/_meta/architecture/scripts.md) --- Shell utilities for harness maintenance

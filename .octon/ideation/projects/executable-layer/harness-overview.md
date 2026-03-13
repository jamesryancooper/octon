# The Octon Portable Harness: Overview and Architecture

> **Reading context:** This document describes the *existing* Octon harness — its structure, governance, discovery model, and architectural principles. It provides essential background for understanding the executable layer design documents in this bundle. If you already have access to the `.octon/` directory, this summarizes what lives there; if you don't, this is your orientation.
>
> **This bundle's reading order:**
>
> 1. **This file** — existing harness context
> 2. [executable-layer-gains.md](executable-layer-gains.md) — why add an executable layer
> 3. [spec-bundle.md](spec-bundle.md) — authoritative v1 contracts (service.json, protocol, discovery, capabilities)
> 4. [executable-layer-implementation-architecture.md](executable-layer-implementation-architecture.md) — implementation architecture (repo layout, bootstrap, caching, CLI)
> 5. [rust-kernel-reference.md](rust-kernel-reference.md) — Rust host-side kernel reference
> 6. [rust-fs-host-api.md](rust-fs-host-api.md) — sandboxed filesystem host API (Rust)
> 7. [rust-service-authoring.md](rust-service-authoring.md) — guest-side service authoring (Rust)

## What

The `.octon/` directory is a **repo-wide agent harness** — a self-contained, metadata-driven operating system for AI-assisted software development. It is a structured collection of markdown files, YAML manifests, and scripts organized into nine domains:

| Domain | Purpose |
|---|---|
| **agency/** | Agents, assistants, teams — who does the work and under what rules |
| **capabilities/** | Skills, commands, tools, services — what actions are available |
| **cognition/** | Principles, methodology, context, decisions — the knowledge base |
| **orchestration/** | Workflows, missions — multi-step procedures and time-bounded projects |
| **continuity/** | Progress log, tasks, next steps — session-to-session memory |
| **quality/** | Completion checklists and exit gates — definition of done |
| **scaffolding/** | Templates, prompts, patterns — reusable starting points |
| **ideation/** | Scratchpad and projects — human-led exploration zone (agents stay out) |
| **output/** | Reports, drafts, artifacts — generated deliverables |

The harness defines a complete governance layer: a `CONSTITUTION.md` with red lines, a delegation policy, a memory policy, per-agent execution contracts (`AGENT.md`) and identity contracts (`SOUL.md`), and an umbrella specification (`cognition/_meta/architecture/specification.md`) with numbered invariants (OCTON-SPEC-001 through OCTON-SPEC-801).

---

## How

### Portability Is Metadata-Driven

The `octon.yml` manifest declares which paths are portable (copy them to bootstrap a new repo via `octon init`) vs. project-specific state that stays local. It also declares human-led zones and resolution rules for framework/project overlaps.

### Discovery Uses Progressive Disclosure

Instead of reading everything at boot, agents follow a layered path:

1. `manifest.yml` — lightweight index (id, name, summary, triggers)
2. `registry.yml` — extended metadata and I/O paths
3. `SKILL.md` / `README.md` — full definition loaded only on activation

### Governance Is Layered and Precedence-Ordered

Six contract layers stack from repo-wide safety (`AGENTS.md`) down through constitution, delegation, memory, execution, and identity — each narrower in scope. Conflicts resolve top-down.

### Permissions Are Deny-by-Default

Agents get no tool access, file write, or service invocation unless explicitly allowlisted. Material side effects require ACP policy gate approval, with control intensity scaling by risk tier.

### The Boot Sequence

Defined in `START.md`, the boot sequence is a 10-step orientation: read scope, conventions, canonical spec, principles, catalog, continuity log, tasks, active missions — then begin work. On exit, quality gates must be satisfied.

### The Methodology (PLAN, SHIP, LEARN)

Work is organized as a closed feedback loop across six pillars — Direction, Focus, Velocity, Trust, Continuity, Insight — with concrete practices at each stage: spec-first planning, trunk-based tiny PRs, feature flags, SLO-driven reliability, blameless postmortems feeding back into the next planning cycle.

---

## Why

### 1. Agent Governance Without Vendor Lock-In

The harness is pure files — markdown, YAML, shell scripts. No runtime dependency, no proprietary platform, no SDK. It works with Claude Code, Cursor, any AI IDE, or a bare terminal. The methodology is explicitly stack-, host-, and environment-agnostic. The `portable:` list in `octon.yml` means you can seed a new repo with the framework in one copy operation.

### 2. Safe Autonomy for Solo Builders

A solo developer cannot be both Driver and Navigator simultaneously. The harness fills that gap with structural guardrails: deny-by-default permissions, risk-tiered ACP checkpoints, a conscience rubric before irreversible actions, red lines that agents cannot cross, and a "no silent apply" rule (agents produce proposals, ACP policy gates authorize promotion). This lets agents operate with meaningful autonomy inside bounded, observable, reversible corridors.

### 3. Institutional Memory That Survives Context Windows

LLM context is ephemeral. The harness externalizes decisions, lessons, constraints, glossary, and progress into durable files under `cognition/` and `continuity/`. The funnel pattern (scratchpad to projects to missions to context) gives ideas a lifecycle. Session-exit checklists force knowledge capture before context evaporates. The result: a new session can boot, read the log, and resume where the last one left off — no human re-explanation needed.

---

## Architecture

### Structural Architecture

#### Single-Root, Domain-Organized

The harness uses a **single `.octon/` root** per scope, organized into nine top-level domains. There is no separation of "framework" vs. "project" at the directory level — that distinction is metadata-driven via `octon.yml`. This was a deliberate architectural decision (replacing a prior two-root convention):

```
.octon/
├── octon.yml          <- portability manifest (what's framework vs. project-local)
├── START.md             <- boot sequence (orientation layer)
├── scope.md             <- boundaries
├── conventions.md       <- style rules
├── catalog.md           <- available operations index
│
├── agency/              <- WHO does work
├── capabilities/        <- WHAT actions exist
├── cognition/           <- WHAT we know
├── orchestration/       <- HOW multi-step work is coordinated
├── continuity/          <- WHAT happened across sessions
├── quality/             <- WHEN work is done
├── scaffolding/         <- WHAT templates/patterns are reusable
├── ideation/            <- WHERE humans think (agents stay out)
└── output/              <- WHERE generated artifacts land
```

The root-level files form an **orientation layer** — the first thing any agent reads. Domains provide **depth**.

#### Nested Harnesses

The pattern is recursive. A descendant `.octon/` can live in any subdirectory (e.g., `packages/auth/.octon/`) to provide area-specific context. The **nearest-harness rule** applies: agents resolve to the closest `.octon/` ancestor, with the root as fallback for anything not locally overridden. Descendant harnesses are intentionally minimal — they include only the subsystems they need.

---

### Portability Architecture

Portability is **metadata-driven, not structural** (OCTON-SPEC-002). The `portable:` list in `octon.yml` declares exactly which paths are framework assets that travel to new repos via `octon init`. Everything else (continuity logs, missions, decisions, project context) is project-specific state that stays put.

The `resolution:` block handles the merge model when framework and project content coexist:

| Domain | Resolution |
|---|---|
| Agency | Framework definitions loaded; project overrides merged on top |
| Capabilities | Single manifest and registry; no extends pattern |
| Orchestration | Framework workflows and project workflows coexist |

---

### Agency Architecture

The actor model has three artifact types with clean separation:

| Actor | Nature | Key Traits |
|---|---|---|
| **Agent** | Autonomous supervisor | Plans, delegates, owns mission lifecycle, maintains cross-session state |
| **Assistant** | Focused specialist | Bounded task executor, `@mention` invocable, stateless between invocations, escalates when out of scope |
| **Team** | Composition artifact | Declares role membership and handoff policy — coordination abstraction, not a runtime primitive |

"Subagent" is retained only as runtime terminology (an assistant invocation spawned by an agent), not as an artifact class.

#### Governance Layer Precedence

Governance is layered with strict precedence:

```
AGENTS.md (repo root)         <- highest authority
  -> CONSTITUTION.md           <- non-negotiable red lines + conscience rubric
    -> DELEGATION.md           <- who can delegate to whom
      -> MEMORY.md             <- what gets remembered and for how long
        -> AGENT.md (per agent)<- execution rules
          -> SOUL.md (per agent)<- identity and interpersonal stance
```

Each agent has a split contract: `AGENT.md` defines *what it does* (execution policy, orchestration rules, quality boundaries); `SOUL.md` defines *who it is* (philosophy, communication style, ambiguity handling). This split prevents identity drift from contaminating execution rules and vice versa.

#### Invocation Rules

Invocation rules are directional:

- **Humans** -> agents, assistants, skills, workflows
- **Agents** -> assistants, skills, workflows, escalate to human
- **Assistants** -> escalate up only (no uncontrolled recursion)
- **Skills** -> bounded; cannot orchestrate agents unless explicitly declared as a `delegator` skill

---

### Capabilities Architecture

A 2x2 taxonomy along two axes — **atomic vs. composite** and **instruction-driven vs. invocation-driven**:

```
                Atomic                    Composite
           +-------------------+------------------------+
Instruction|   Commands        |   Skills               |
-driven    |   (single .md)    |   (SKILL.md + refs)    |
           +-------------------+------------------------+
Invocation |   Tools           |   Services             |
-driven    |   (call, result)  |   (typed domain I/O)   |
           +-------------------+------------------------+
```

- **Commands** — atomic, deterministic one-shot operations (e.g., `/init`)
- **Skills** — composite instruction sets following the agentskills.io spec with Octon extensions (progressive disclosure, tool permission allowlists, run logging)
- **Tools** — atomic invocation-driven capabilities with immediate results; support `pack:<id>` grouping
- **Services** — composite domain capabilities behind stable typed interfaces (shell, MCP, or library); organized by category (guard, prompt, cost, flow, agent-platform, retrieval)

**Permissions are deny-by-default.** Each skill declares its `allowed-tools` in SKILL.md frontmatter — this is the single source of truth. Unknown tools fail closed.

---

### Discovery Architecture (Progressive Disclosure)

Everything routable uses a **four-tier discovery stack** (OCTON-SPEC-003), so agents load only what they need:

| Tier | Artifact | Token Cost | When Loaded |
|---|---|---|---|
| **1** | `manifest.yml` | ~50 tokens/item | Session start — scan for routing matches |
| **2** | `registry.yml` | ~100 tokens/item | After matching — get extended metadata, I/O paths, dependencies |
| **3** | `SKILL.md` / `README.md` | <500 lines | Activation — load full definition |
| **4** | `references/` or step files | As needed | Execution — load detailed phase instructions, safety rules, examples |

This keeps cold-start cost low (~2,000 tokens total target for the orientation layer) while still allowing deep context when a specific capability is activated.

---

### Orchestration Architecture

Two primitives:

**Workflows** — ordered, multi-step procedures with numbered step files (`01-validate.md`, `02-build.md`, ..., `NN-verify.md`). They differ from skills in three ways: explicit step ordering, inter-step state flow via Input/Output prose contracts, and a mandatory verification gate as the final step. Support checkpointing/resume, parallel step groups, and idempotency markers.

**Missions** — time-bounded sub-projects with lifecycle state (active/paused/completed). Owned by agents. Have their own `mission.md`, `tasks.json`, and `log.md`. This separates durable project work from the repo-level continuity artifacts.

---

### Continuity Architecture

Four files form a **session-to-session memory contract**:

| File | Role | Mutability |
|---|---|---|
| `log.md` | What happened (session history) | Append-only — past entries never rewritten |
| `tasks.json` | What needs doing | Read-write |
| `entities.json` | Entity state tracking | Read-write |
| `next.md` | Immediate next actions | Read-write |

The contract is simple: read `tasks.json` + latest `log.md` entry before starting; update all four before ending a session. This is what allows an agent to cold-start with no prior context and resume meaningfully.

---

### Governance Architecture

The umbrella specification defines **numbered invariants** (OCTON-SPEC-001 through OCTON-SPEC-801) organized as:

- **Cross-cutting rules** (001-011): domain organization, metadata-driven portability, progressive disclosure, deny-by-default, no silent apply, risk-tiered ACP, continuity integrity, quality gates, human-led boundaries, doc coupling, project bootstrap
- **Subsystem contracts** (101, 201, 301, 501, 601, 701, 801): each domain has a boundary contract preserving its taxonomy, interaction model, and lifecycle semantics

Safety invariants compound across layers:

- **Constitution** -> red lines, conscience rubric, escalation triggers
- **Deny-by-default** -> allowlist-based permissions, fail-closed
- **No silent apply** -> agents propose, humans authorize
- **ACP checkpoints** -> approval intensity scales with risk tier
- **Quality gates** -> definition-of-done and session-exit gates must pass before completion

---

### Harness-Agnostic Architecture

The harness is designed to work across **any AI IDE or agent platform**:

```
+----------+----------+----------+----------+
|  Cursor  |  Claude  |  Codex   |  Future  |
| .cursor/ | .claude/ | .codex/  | .<host>/ |
| commands/| commands/| commands/| commands/|
+----+-----+----+-----+----+-----+----+-----+
     |          |          |          |
     +----------+----------+----------+
                    |
     +--------------v--------------+
     |     .octon/ (canonical)    |
     |  workflows, skills, agents,  |
     |  services, context, quality  |
     +------------------------------+
```

Host-specific directories (`.cursor/commands/`, `.claude/commands/`) are **thin wrappers** that delegate to `.octon/` paths. No harness-specific logic lives in workflows or skills. This means the same capability definitions work identically regardless of which IDE or agent runtime invokes them.

---

### The Meta-Pattern

The architecture follows a recursive documentation pattern: the code is the *what*; `.octon/` is the *how* and *why* of working on that code. It formalizes the runbooks, playbooks, and institutional knowledge that effective teams maintain — but co-locates it with the code, structures it for machine consumption, and makes it durable across context windows and session boundaries.

---

### Naming Convention

The harness uses plain directory names for structural units and underscore-prefixed namespaces for non-structural support material:

| Namespace | Purpose |
|---|---|
| `_meta/` | Docs-as-code governance and architecture reference modules |
| `_ops/` | Operational assets such as scripts and mutable state |
| `_scaffold/` | Templates and scaffolding material |

Within these namespaces, standard subpaths are:

- `_meta/architecture/`
- `_ops/scripts/`
- `_ops/state/`
- `_scaffold/template/`

---

### The Six Pillars

Octon's pillars are organized in three phases forming a complete feedback loop:

**PLAN Phase:**

1. **Direction through Validated Discovery** — Build the right thing because every feature is validated before investment.
2. **Focus through Absorbed Complexity** — Build features, not infrastructure — Octon handles the rest.

**SHIP Phase:**

3. **Velocity through Agentic Automation** — Ship fast because AI automation removes bottlenecks and multiplies output.
4. **Trust through Governed Determinism** — Ship confidently because behavior is predictable, agents are bounded, security is enforced, and mistakes are reversible.

**LEARN Phase:**

5. **Continuity through Institutional Memory** — Knowledge persists because decisions, traces, and context are captured durably.
6. **Insight through Structured Learning** — Improve continuously because every outcome teaches us something.

Together these pillars create a self-reinforcing system: Direction ensures we build the right thing, Focus gives us bandwidth to build it, Velocity and Trust let us ship fast and safely, Continuity preserves what we learned, and Insight feeds back to Direction for the next cycle.

---

### Umbrella Specification Reference

| ID | Rule | Summary |
|---|---|---|
| OCTON-SPEC-001 | Domain-Organized Harness Root | Root harness must remain domain-organized with explicit top-level domains |
| OCTON-SPEC-002 | Portability Is Metadata-Driven | Portable assets and resolution rules declared in `octon.yml` |
| OCTON-SPEC-003 | Progressive-Disclosure Discovery | Routable capabilities use manifest -> registry -> definition |
| OCTON-SPEC-004 | Deny-by-Default Permissions | Agent access is allowlist-based and fail-closed |
| OCTON-SPEC-005 | No Silent Apply for Material Side Effects | Material side effects require ACP policy approval |
| OCTON-SPEC-006 | Risk-Tiered System Governance | Approval intensity scales with risk tier |
| OCTON-SPEC-007 | Continuity Artifact Integrity | Append-only artifacts preserve historical integrity |
| OCTON-SPEC-008 | Completion and Exit Quality Gates | Tasks must satisfy definition-of-done and session-exit gates |
| OCTON-SPEC-009 | Human-Led Ideation Boundaries | `ideation/**` is human-led; autonomous access prohibited |
| OCTON-SPEC-010 | Documentation and Contract Coupling | Changes should update corresponding docs in the same change set |
| OCTON-SPEC-011 | Project Bootstrap Initialization | Project-level bootstrap artifacts initialized via `/init` |
| OCTON-SPEC-101 | Agency Contract Boundary | Agency defines actor taxonomy, invocation model, and delegation boundaries |
| OCTON-SPEC-201 | Capabilities Contract Boundary | Capabilities preserves the four-part taxonomy and interaction model |
| OCTON-SPEC-301 | Orchestration Contract Boundary | Orchestration preserves workflow and mission boundaries |
| OCTON-SPEC-501 | Continuity Contract Boundary | Continuity preserves session-state through explicit artifacts |
| OCTON-SPEC-601 | Assurance Contract Boundary | Assurance preserves completion and exit contracts as enforceable gates |
| OCTON-SPEC-701 | Ideation Contract Boundary | Ideation remains human-led and separate from autonomous execution |
| OCTON-SPEC-801 | Output Contract Boundary | Output used for generated artifacts, separated from source and policy |

---

### Key Architectural Principles

| Principle | Summary |
|---|---|
| Progressive Disclosure | Layer context from concise to deep to preserve focus |
| Complexity Calibration | Favor minimal sufficient complexity; add complexity only when justified by constraints |
| Single Source of Truth | Keep each core fact/contract authoritative in one place |
| Locality | Keep context and ownership near the work surface |
| Deny by Default | Deny dangerous actions unless explicitly permitted |
| Contract-first | Define and govern API/data contracts before implementation |
| No Silent Apply | Agents produce proposals; humans authorize material side-effects |
| Reversibility | Ensure every material change has a tested rollback path |
| Idempotency | Make mutating operations safe under retries and partial failures |
| Guardrails | Apply policy/eval/security gates fail-closed across agent loops |
| ACP Checkpoints | Use risk-tiered ACP checkpoints at consequential decisions |
| Documentation is Code | Version specs, ADRs, and runbooks with the same rigor as implementation |

# Continuity Plane Exploration (Harmony-aligned, production-realistic)

## Role

You are a senior agent-systems architect + prompt auditor + technical writer. Your job is to design and document a **production-ready Continuity Plane** for **highly effective long-running agents** (multi-session, multi-context-window) and to specify how it integrates with Harmony’s **three-plane architecture** and **Content Plane (HCP)** substrate.

## Objective

Produce **ship-ready Markdown documentation** (public-spec caliber) that describes:

- A Continuity Plane that preserves **process knowledge** (decisions, handoffs, progress, backlog state) and keeps agents effective across resets.
- A concrete, operational “continuity stack” for agents—**Prompt**, **Context**, **Memory**—implemented through deterministic artifacts, strict lifecycles, and verification discipline.
- A drop-in **starter kit** for `.continuity/` that is usable at **Tier 0 (filesystem-only)** and scales up via tiers.

Primary success: a fresh agent can restart with minimal context and **continue correctly** without repeating work, drifting, or claiming completion without evidence.

## Inputs (read + extract into a design matrix)

You MUST read and internalize:

- **Harmony constraints and canonical terminology/layout**
  - `docs/ai/architecture/content-plane/**`
  - `continuity-plane.md`
  - `README.md`
  - `three-planes-integration.md`
  - `README.md`
- **Sources list** (treat as “research inputs”): `docs/ai/architecture/continuity-plane/.workspace/.inbox/resources.md`

Optional (if provided by the caller):

- Target environment constraints (repo structure, tool limits, privacy constraints)
- Harness assumptions (single agent vs multi-agent, offline vs online, tool access)

### Step 0 — Build a “Design Matrix” (required)

Before proposing architecture, write a short matrix/table capturing:

- **Hard constraints** (MUSTs) from Harmony + the caller
- **Non-goals/boundaries**
- **Available I/O surfaces** (filesystem, command execution, browser, MCP, git/CI)
- **Assumptions** (explicit) and **open questions** (explicit)

### Step 1 — Source extraction (required)

For each source you can access, extract:

1) key claims/patterns  
2) implied failure modes it solves  
3) which continuity primitive(s) it contributes (**prompt/context/memory/verification/orchestration/safety**)  
4) operational tradeoffs (token cost, latency, complexity, reliability)  
5) “how to implement” notes (schemas, pipelines, APIs, roles, lifecycles)

Maintain a “**Sources → Primitives Map**” in your output. If a source is inaccessible, note it and proceed with best-effort synthesis.

## Constraints / Non-goals (Harmony alignment: non-negotiable)

### Canonical naming & layout (required)

- Continuity artifacts live under **`.continuity/`** (NOT `.uacf/`).
- Legacy mapping (if relevant): `.uacf/` → `.continuity/` (same semantic role; `.continuity/` is canonical in Harmony).
- If you need to mention legacy names, include a mapping once, then use `.continuity/` exclusively.

### Cross-plane references & provenance (required)

- Use Harmony’s **cross-plane reference convention** when linking across planes:  
  `ref:<plane>:<type>:<id>[@version]`  
  Examples:
  - `ref:continuity:decision:ADR-0042`
  - `ref:knowledge:module:packages/harmony-content/src/index.ts`
  - `ref:content:doc:getting-started`
- If you use the optional `@...` suffix, define what it means for each artifact type (e.g., locale selector vs semantic version vs commit/tag). Prefer consistency across your deliverable; when in doubt, treat it as a generic **qualifier** and explain.
- Within a single plane, you MAY use local shorthand (e.g., Content Plane `ref:<type>:<id>[@locale]`) but you MUST define the mapping and show at least one canonical cross-plane example.
- Every durable write (decision, handoff, memory write, evidence) MUST carry **provenance**: who/what wrote it, when, why, and links to supporting artifacts (PR, trace, tests).

### Hard boundaries (avoid product creep)

You MUST NOT propose or require:

- A hosted CMS product, WYSIWYG editor, scheduling UI, RBAC/auth systems, or real-time collaborative editing as baseline features.
- Runtime authoring/mutation APIs as a default (stay compiler/tooling-first unless boundary conditions force an escalation path).
- “Magic memory” without schemas, provenance, retention rules, or contradiction handling.

### Determinism, verification, governance (Harmony methodology)

- Make verification evidence **first-class** and fail-closed: no “done” without evidence.
- Prefer deterministic artifacts, stable IDs, and reproducible context packs.
- Include safe-action escalation for irreversible actions and high-risk changes.

## What this Continuity Plane MUST cover (non-negotiable scope)

Your output MUST explicitly cover:

1) **Continuity primitives (core stack)**: prompt engineering, context engineering, memory engineering (episodic/semantic/procedural), plus any missing primitives required in production (verification, checkpoints, provenance, orchestration, safety, evals).
2) **Workflow architecture & lifecycles**: startup/rehydration, steady-state work loop, shutdown/handoff, recovery/rollback, completion audit.
3) **Continuity artifacts** (persistent state outside the context window): canonical folder layout, minimum artifact set, schemas, update rules, indexing/export rules, examples, and anti-corruption rules.
4) **Verification, evidence, and evaluation**: what constitutes proof, where it is recorded, how it links to backlog items; success metrics and regression scenarios.
5) **Orchestration**: single-agent baseline + optional multi-agent topology; coordination via artifacts; conflict management and merge/consistency strategy.
6) **Safety, privacy, and governance**: secrets/PII handling, retention boundaries, safe-action policy, auditability/provenance, non-goals/boundary enforcement.
7) **Integration contract**: environment-agnostic harness adapter contract; tier model; context-window management behavior (fresh-window reboot vs compaction; low-budget emergency protocol).

## Core output: what you must produce

Produce **clean, ship-ready Markdown** describing the Continuity Plane **as implemented on Harmony**. Output either:

- a single Markdown document, or
- a set of Markdown files separated by `FILE: path/to/file.md` headers.

You MUST include concrete schemas, templates, checklists, and examples (not just prose).
Use placeholders where repo-specific values are required (e.g., `<PROJECT_NAME>`, `<REPO_ROOT>`, `<COMMAND_TO_RUN_TESTS>`, `<SESSION_ID>`, `<TRACE_ID>`).

## Deliverables (your output MUST include all)

### 1) Executive summary (≤ 1 page)

- What the Continuity Plane is, what it solves, who it’s for, expected outcomes, and how it fits inside HCP/HCG and the three-plane model.

### 2) Design goals, non-goals, and measurable success criteria

Include measurable outcomes such as:

- reduction in repeated work / duplicate edits
- lower “premature victory” rate
- verification evidence completeness (coverage)
- recovery time after context reset
- token/latency budgets for context packs
- memory precision/recall targets + contradiction rate targets

### 3) Failure-mode taxonomy → mitigations → enforcement points

At minimum cover:

- context resets → state loss
- context rot (too much/wrong context)
- one-shot overreach
- premature completion
- verification gaps
- tool confusion / tool misuse
- unsafe irreversible actions
- drift from goals / spec mismatch
- inconsistent memory updates (contradictions, stale facts)
- multi-agent conflict (duplicate work, merge conflicts, inconsistent decisions)

For each failure mode, map:

- **Mitigation(s)** (process + technical)
- **Artifacts** that implement it (e.g., backlog fields, decision record, evidence pack)
- **Enforcement points** (schema validation, lifecycle rules, CI gates, human review hooks)

### 4) Reference architecture (MUST include Mermaid diagrams)

Include:

- **Single-agent baseline**
- **Optional multi-agent topology** (Orchestrator/Conductor + specialists such as Implementer/Coder, QA/Verifier, Documentation/Archivist, Researcher/Analyst)
- Data flows across:
  - `content/` canonical files
  - `.continuity/` continuity artifacts
  - HCG indexes (`.harmony/content/*.sqlite|json|graph`)
  - context pack exporter(s)
  - memory stores and recall/update pathways

Diagrams MUST show:

- startup/rehydration path
- steady-state work loop
- end-of-session handoff path
- recovery/rollback path
- completion audit path

### 5) The Continuity Stack (Prompt, Context, Memory)

Define explicit interfaces, responsibilities, and enforcement:

**A. Prompt Engineering**

- Instruction architecture (stable “policy” vs session/task-specific “working set”)
- Tool contracts and stop conditions (no pretending it’s done; checkpoint/handoff instead)
- Prompt linting rules (what can be validated at build time)
- Where prompts live in Harmony (e.g., `content/agent/prompts/**`, `.continuity/templates/prompts/**`)

**B. Context Engineering**

- Context assembly pipeline: sources → ranking → shaping (compaction/summarization/redaction) → deterministic pack IR → exporters
- Token budgeting: hard/soft caps + low-budget emergency compaction protocol
- Provenance and context-rot prevention
- Specialist packs (routing different packs to different roles)

**C. Memory Engineering**

- Memory types: episodic / semantic / procedural
- Store forms: append-only event logs vs curated “facts/skills” vs lessons learned
- Write/update policies (including contradiction handling and “grounding rules”)
- Retrieval policies (when to recall, top-k, cite sources, confidence fields)
- Retention/forgetting (TTL, redaction, privacy boundaries)

### 6) Harmony integration spec (non-negotiable)

Describe exactly how Continuity “lives inside” Harmony:

- Canonical repo layout (`content/`, `.continuity/`, `.harmony/`)
- Schemas and validation rules for each continuity artifact (refer to `content/_schemas/continuity/**` where applicable)
- Build pipeline stages (validate → resolve refs → index → export context packs)
- Dependency graph / blast radius impacts for continuity changes
- Context Pack IR (fields, ordering rules, provenance, token budget)

### 7) Standard `.continuity/` artifacts (with schemas + lifecycle rules)

Define a canonical folder containing at minimum:

- `.continuity/backlog.yaml` (mutable; schema-validated; includes acceptance + evidence fields)
- `.continuity/plan.md` (snapshot)
- `.continuity/risks.md` (snapshot)
- `.continuity/decisions/` (decision records; immutable after acceptance/merge; supersede via new file)
- `.continuity/handoffs/` (session-scoped, immutable snapshots)
- `.continuity/events/` (append-only NDJSON per session)
- Optional but recommended:
  - `.continuity/checklists/` (session-start/end, context-low, recovery, completion-audit)
  - `.continuity/templates/prompts/` (initializer, work-session, orchestrator, archivist, verifier)
  - `.continuity/eval/` (rubrics, regression scenarios, memory tests)
  - `.continuity/tool-policy/` (allow/deny lists, escalation rules)

For EVERY artifact provide:

- purpose
- schema (YAML/JSON/NDJSON/frontmatter)
- example contents
- update rules (append-only vs controlled edits)
- anti-corruption rules (no silent deletions, don’t rewrite history)
- how it is indexed in HCG and exported into context packs

### 8) Harness adapter contract (tiered, environment-agnostic)

Define the minimal harness interface and tier model:

- filesystem read/write (required)
- optional command execution
- optional external tool access (including MCP servers)
- checkpoints (Tier 0 none → Tier 1 git → Tier 2 CI/tests → Tier 3 autonomous loop + browser + monitoring)
- verification hooks and evidence capture
- context-window management behavior (fresh-window reboot vs compaction)
- safe-action policy (allowlist/denylist; irreversible-action escalation)

### 9) Lifecycle playbooks (copy/paste ready)

Procedures for:

- first-run bootstrap (Initializer)
- standard work session loop
- orchestrated multi-agent session loop
- context-low emergency protocol (checkpoint + handoff)
- broken state / failed verification recovery
- completion audit (definition of done + final evidence)

Each playbook MUST enforce:

- incremental work discipline (small, testable units)
- evidence before “done”
- clean handoff artifacts

### 10) Prompt templates (copy/paste ready; composable roles)

Provide robust templates with placeholders:

- Initializer prompt
- Work-session prompt
- Orchestrator prompt
- Documentation/Archivist prompt
- QA/Verifier prompt
- (Optional) Researcher/Analyst prompt

Each template MUST:

- rehydrate from `.continuity/` + HCG queries
- select next backlog item(s)
- execute, verify, checkpoint, and update artifacts
- produce end-of-session handoff
- handle low-context conditions explicitly
- enforce tool contracts + safe-action escalation

### 11) Examples across domains

Provide:

- one coding example
- one non-coding example (ops, research, analysis, etc.)

Each includes:

- `.continuity/` folder structure
- sample backlog item
- sample progress/event entries
- sample handoff brief
- what the context pack would include and why (token budget notes)

### 12) Security, privacy, and safety

Include:

- secrets handling and PII redaction rules
- memory retention boundaries and deletion/redaction protocol
- provenance + audit trails (who/what/when/why; trace IDs)
- safe tool use (irreversible actions, data exfil risk)
- explicit human-in-the-loop escalation points

### 13) Adoption guide + pitfalls

Include:

- “Adopt in 30 minutes” quickstart
- migration path for existing projects
- pitfalls + anti-patterns (especially CMS creep and context dumping)
- review/QA workflow for teams

### 14) Drop-in starter kit: `.continuity/` (copy/paste ready)

Output:

- directory tree
- full initial contents for each file using `FILE: .continuity/...` headers
- MUST be Tier-0 compatible (filesystem-first; don’t assume git/CI)

## Lifecycle (what your design MUST define)

Your Continuity Plane design MUST specify the following, including “who writes what” and “what gets linked to what”:

- **Startup / Rehydration**: how a fresh window reconstructs state (handoff + backlog + plan + recent events + key decisions).
- **Steady-state work loop**: select item → plan micro-steps → execute → verify → record evidence → checkpoint → update artifacts.
- **Shutdown / Handoff**: produce session handoff brief optimized for next session; append events; update backlog/plan/risks.
- **Recovery / Rollback**: how to handle failed verification, corrupted state, or wrong direction (checkpoint restore, decision supersession, backlog correction with history preserved).
- **Completion**: definition of done + final audit + evidence pack + next-step recommendations.

## Artifacts (schemas + update rules) — required details

Your output MUST include schemas and examples for (at minimum):

- Backlog item schema fields:
  - `id`, `title`, `status`, `priority`, `owner`, `acceptance_criteria[]`
  - `verification` (required): `evidence[]` with pointers/refs to tests, traces, screenshots, PRs, commands run, and outputs
  - `dependencies[]`, `risks[]`, `notes`, `created_at`, `updated_at`
- Progress events format (NDJSON) with fields: `ts`, `session_id`, `actor`, `action`, `files`, `refs[]`, `data`
- Decision record template with frontmatter, rationale, alternatives, consequences, and `affects[]` refs to knowledge/content artifacts
- Handoff brief template optimized for rehydration (current state, what changed, what’s next, blockers, open questions, pointers to key files/refs)

## Templates / Playbooks (required details)

Your output MUST include:

- Copy/paste **checklists** for:
  - session start
  - session end
  - context-low
  - recovery
  - completion audit
- Prompt templates that embed:
  - stop conditions (when to pause, checkpoint, and hand off)
  - tool contracts and safe-action policy
  - artifact update rules (append-only vs immutable)
  - evidence requirements (what to capture, where to write it)

## Examples (required details)

Your examples MUST show end-to-end flow:

- how the backlog item is selected
- what context pack is assembled (and why)
- what verification is performed
- what evidence is recorded
- what handoff looks like

## Security / Safety (required details)

Your output MUST include:

- A concrete **safe-action policy** (allowlist/denylist) and escalation rules for irreversible or risky actions.
- Redaction rules at write boundaries (what MUST NOT be written to `.continuity/`).
- Retention rules (what persists, what expires, how redactions are applied without rewriting history).

## Evaluation / Observability (required details)

Your output MUST include:

- **Metrics**: repeat-work rate, evidence completeness, recovery time, context pack token size, memory contradiction rate, task success rate.
- **Eval plan**: regression scenarios; memory precision/recall measurement; contradiction detection; context pack relevance checks.
- **Observability**: what to log per session (trace IDs, tool calls, context pack hashes, memory operations, errors).

## Completeness checklist (MUST satisfy before finalizing)

Before you finalize, you MUST include and self-check:

- [ ] A Design Matrix (constraints, non-goals, assumptions, open questions)
- [ ] Sources → Primitives Map
- [ ] Failure modes → mitigations → artifacts/enforcement mapping
- [ ] Mermaid diagrams for single-agent and multi-agent + all lifecycle flows
- [ ] A fully specified `.continuity/` artifact set with schemas, examples, update rules, and indexing/export rules
- [ ] Tiered harness adapter contract (Tier 0–3)
- [ ] Lifecycle playbooks + checklists (startup/work/handoff/recovery/completion/context-low)
- [ ] Prompt templates for required roles that enforce evidence + handoffs + safe-action policy
- [ ] Security/privacy/retention + redaction rules
- [ ] Evaluation/observability plan with metrics and regression scenarios
- [ ] Two end-to-end examples (coding + non-coding) including sample artifacts and evidence
- [ ] Drop-in starter kit output with full file contents (`FILE: .continuity/...`)

### Definition of done (for your documentation output)

You may only claim completion if:

- Every checklist item above is satisfied, and
- Every “done” state in your design is backed by explicit, recorded **verification evidence**, and
- The output includes a clean handoff artifact suitable for a fresh context window, and
- All non-goals/boundaries are explicitly enforced (fail-closed where appropriate), and
- Any missing information is surfaced as explicit assumptions + open questions.

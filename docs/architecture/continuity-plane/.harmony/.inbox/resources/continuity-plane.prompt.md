# Continuity Framework

You are a senior agent-systems architect + technical writer. Your job is to design and document a production-ready, environment-agnostic “Continuity Framework” (CF) that makes *any* agent more effective on long-running, multi-step tasks spanning many sessions/context windows.

CF must work:

- In any IDE/editor (I use Cursor IDE, but do not make the framework Cursor-dependent)
- With any agent harness (e.g., Cursor agents, OpenAI Codex, Claude Code, custom tool loops)
- For any agent role (coder, researcher, analyst, PM, support, ops, etc.)
- For any long-running agentic task category (software, research, writing, design, data, operations)

## Inputs (read and internalize)

Analyze these sources to understand known failure modes + proven harness patterns:

1) <https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents>
2) <https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices#multi-context-window-workflows>
3) <https://github.com/anthropics/claude-quickstarts/tree/main/autonomous-coding>
4) <https://github.com/anthropics/claude-quickstarts/blob/main/autonomous-coding/prompts/initializer_prompt.md>
5) <https://github.com/anthropics/claude-quickstarts/blob/main/autonomous-coding/prompts/coding_prompt.md>
6) <https://github.com/anthropics/claude-quickstarts/blob/main/autonomous-coding/prompts/app_spec.txt>

You may go beyond these sources: introduce additional best practices or patterns if they improve universality, robustness, or clarity. If you introduce extra concepts, explain why they matter and how they map to the Continuity Framework.

IMPORTANT: Some referenced materials focus on a 2-agent setup (e.g., an Initializer agent + a Coding/Implementer agent). The Continuity Framework must explicitly explore additional essential agent roles beyond these two (e.g., an Orchestrator/Conductor agent and a Documentation/Archivist agent) and explain how they compose, coordinate, and hand off work using the continuity artifacts.

## Core problem to solve

Long-running agents fail when context resets: they lose state, repeat work, leave messy partial progress, declare success early, or drift from goals. The Continuity Framework must prevent these outcomes by standardizing:

- Persistent state + continuity artifacts
- Session startup (“get bearings”) and session shutdown (“clean handoff”) routines
- Incremental progress discipline (small, testable units)
- Verification discipline (don’t mark done without evidence)
- Recovery and rollback strategies (checkpoints)
- Cross-session planning and prioritization
- Cross-agent coordination patterns (optional, but recommended at scale): how an Orchestrator coordinates specialist agents (coding, docs, QA, etc.) via shared continuity artifacts without losing continuity or creating conflicting changes
- Tool/harness integration contracts (so any environment can adopt the same framework)

## Required deliverable

Produce clear, logical, well-formatted **Markdown documentation** for the Continuity Framework that is ready to ship as a public spec + implementation guide.

### Output format (deliver all of this)

Create a single cohesive Markdown document (or a set of Markdown files separated by clear “FILE: …” headers) with:

1) **Executive summary (1 page)**
   - What the Continuity Framework is, what it solves, who it’s for, and key outcomes.

2) **Design goals & non-goals**
   - Include explicit success criteria and measurable outcomes (e.g., reduced repetition, fewer “half-implemented” states, consistent verification).

3) **Failure modes (taxonomy)**
   - Catalog common long-running-agent failure modes and how the Continuity Framework mitigates each.
   - Include at least: “one-shotting too much,” “unfinished work at context end,” “premature victory,” “verification gaps,” “state drift,” “tool confusion,” “context-budget panic,” “unsafe or irreversible actions.”

4) **The Continuity Framework architecture**
   - A reference architecture diagram (use Mermaid) showing components and data flows.
   - Must include both a **single-agent baseline** and an optional **multi-agent topology** (e.g., Orchestrator/Conductor + Implementer/Coder + Documentation/Archivist + Verifier) and show how each role reads/writes the continuity artifacts.
   - Must include a clear **lifecycle**:
     - Bootstrap / Initializer phase (first session)
     - Repeating Work Sessions (N sessions)
     - Handoff protocol at session end
     - Recovery protocol (broken state / failed verification)
     - Completion protocol (definition of done + final audit)

5) **Standard Continuity Artifacts (the heart of the framework)**
   Define a universal, repo/workspace-local folder (recommend a name like `.continuity/`) containing:
   - A **structured backlog** (JSON/YAML) with items, status, acceptance criteria, and verification evidence fields
   - A **progress log** (human-readable narrative) capturing what changed, why, and what’s next
   - A **decision log** (lightweight ADR-style)
   - A **current plan / next-actions** file
   - A **risk & assumptions** file
   - A **context pack** / “handoff brief” file that is optimized to rehydrate a fresh session fast
   - Optional: test/validation manifests, runbooks, checklists, evaluation rubrics

   For every artifact:
   - Provide purpose, schema (JSON/YAML where relevant), examples, and update rules.
   - Include strict guidance to prevent destructive edits (e.g., don’t rewrite history; update via append-only logs or controlled fields).

6) **Harness & IDE adapter contract (environment-agnostic)**
   Provide a minimal interface that any harness can implement, such as:
   - Read/write workspace files
   - Execute commands (optional)
   - Access external info/tools (optional)
   - Provide checkpointing mechanism (git, snapshots, file copies, or harness-native checkpoints)
   - Provide verification tools (tests, linters, browser automation, human review hooks)
   - Provide context-window management behavior (compaction vs fresh-window reboot)
   - Provide a “safe actions” policy (allowlist/denylist) and escalation rules

   IMPORTANT: Do not assume git is available, but specify “tiers”:
   - Tier 0: filesystem only
   - Tier 1: filesystem + git
   - Tier 2: filesystem + git + automated verification tools
   - Tier 3: full autonomous loop + UI/browser automation + monitoring

7) **Session playbooks (copy/paste ready)**
   Provide step-by-step procedures for:
   - First run (Initializer session)
   - Standard work session (repeated loop)
   - Optional: Orchestrated multi-agent session (Orchestrator delegates to specialist agents; reconciles outputs; records decisions + verification evidence; produces a clean handoff)
   - When context budget is low (how to checkpoint + handoff cleanly)
   - When something is broken (triage + rollback)
   - When the agent thinks it’s done (completion audit checklist)

8) **Prompt templates (universal, harness-agnostic)**
   Provide two robust templates with placeholders:
   - `Initializer Prompt Template` (sets up artifacts, expands requirements into a structured backlog, creates run scripts where possible)
   - `Work Session Prompt Template` (rehydrates state, selects next item, implements incrementally, verifies, checkpoints, writes handoff)
   Also provide optional role templates (and guidance for composing them into multi-agent systems):
   - Orchestrator/Conductor (selects next items, delegates work, resolves conflicts, ensures evidence + clean handoffs)
   - Documentation/Archivist (keeps docs and continuity artifacts accurate; produces/refreshes context packs and handoff briefs)
   - Researcher, Analyst, PM, Ops/Support, QA/Verifier
   Each template must:
   - Enforce incremental work (one backlog item at a time unless explicitly batching)
   - Require verification evidence before marking “done”
   - Require end-of-session handoff artifacts
   - Explicitly instruct against premature stopping due to context limits; instead checkpoint and hand off cleanly

9) **Examples across domains**
   Provide at least:
   - One coding example (Cursor-friendly, but not Cursor-dependent)
   - One non-coding example (e.g., market research report, incident response runbook, or data analysis project)
   For each example, show:
   - The artifact folder structure
   - A sample backlog item
   - A sample progress entry
   - A sample handoff brief

10) **Security, privacy, and safety section**

- Handling secrets, PII, credential hygiene
- Safe tool use and irreversible actions
- Auditability and provenance (what changed, why, when)

11) **Adoption guide**

- “Quickstart: adopt the Continuity Framework in 30 minutes”
- Migration guide for existing projects
- Common pitfalls + anti-patterns
- How teams should review/QA agent work

12) **Completeness checklist**

- A checklist readers can use to confirm they implemented the Continuity Framework correctly.

13) **Drop-in `.continuity/` starter kit (copy/paste ready)**
   Provide a complete, repo-ready starter kit that can be dropped into any workspace with minimal edits.

- Output must include a directory tree and the full initial contents for each file, separated by clear `FILE: .continuity/...` headers.
- Include (at minimum):
  - `.continuity/README.md` (what this folder is, update rules, and the recommended workflow)
  - `.continuity/backlog.yaml` (or `.json`) with a small starter backlog and fields for acceptance criteria + verification evidence
  - `.continuity/progress.md` (append-only) with 1–2 example entries
  - `.continuity/decisions.md` (or `.continuity/decisions/adr-0001.md`) with an ADR template + one example decision
  - `.continuity/plan.md` (current plan / next actions) with a concrete starter structure
  - `.continuity/risks.md` (risks & assumptions) with a starter checklist/table
  - `.continuity/handoff.md` (context pack / handoff brief) as a fill-in template optimized for rapid rehydration
  - `.continuity/checklists/` containing copy/paste checklists:
    - `session-start.md` (rehydrate + select next item)
    - `session-end.md` (verification, checkpoint, handoff)
    - `context-low.md` (budget-low protocol)
    - `recovery.md` (broken state / failed verification)
    - `completion-audit.md` (definition of done + final audit)
  - `.continuity/templates/prompts/` containing prompt templates:
    - `initializer.md`
    - `work-session.md`
    - `orchestrator.md`
    - `documentation-archivist.md`
    - `qa-verifier.md` (or equivalent)
- The kit must be environment-agnostic (Tier 0 filesystem-first) and must not assume git, CI, or a specific IDE.
- Use placeholders (e.g., `<PROJECT_NAME>`, `<REPO_ROOT>`, `<COMMAND_TO_RUN_TESTS>`) where repo-specific values are required.

## Writing and quality requirements

- Markdown must be clean, scannable, and production-ready.
- Use headings, tables, and callout blocks where helpful.
- Use concise, unambiguous language and define terms in a glossary.
- Do not include long verbatim quotes from sources; instead synthesize.
- If you reference ideas from sources, include a short “Sources & influences” section describing what was borrowed and what was extended.

## Output constraints

- Make the Continuity Framework usable even with minimal tooling (filesystem-only).
- Avoid vendor-specific dependencies; treat Cursor, Codex, Claude Code, etc. as examples only.
- Ensure the framework is role/task-agnostic (not just software engineering).
- Prioritize continuity, verification, and clean handoffs above novelty.

Now generate the Continuity Framework documentation.

<https://manthanguptaa.in/posts/chatgpt_memory/>
<https://deepengineering.substack.com/p/implicit-memory-systems-for-llms>
<https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents>
<https://github.com/anthropics/claude-cookbooks/blob/main/tool_use/memory_cookbook.ipynb>
<https://natesnewsletter.substack.com/p/executive-briefing-the-memory-gap>
<https://natesnewsletter.substack.com/p/i-read-everything-google-anthropic>
<https://developers.googleblog.com/architecting-efficient-context-aware-multi-agent-framework-for-production/>
<https://medium.com/@mail_36332/introducing-graphmd-turning-markdown-documents-into-executable-knowledge-graphs-6925d936423f>

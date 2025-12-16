# Universal Skills (Vendor‑Neutral “Skills” System)

**Status:** Draft spec v0.1 (provider‑neutral)

Universal Skills is a **portable, repository‑native skills system** that works with *any* IDE, editor, CLI, or agent runtime (“host”) that can read/write local files and follow instructions.

It generalizes two proven patterns:

- **Agent Skills (Claude Skills)**: a runtime that preloads **skill metadata** and lazily loads full instructions when relevant (progressive disclosure) [see: Claude Code Skills docs](https://code.claude.com/docs/en/skills).
- **Open Agent System (OAS) pattern**: a single **instructions/index file** (“catalog + dispatcher”) that points to individual agent/skill definition files, plus output folders for multi‑step pipelines.

Universal Skills keeps the **spirit** (modular, composable capabilities with lazy loading) while removing provider‑specific mechanics (proprietary discovery, metadata parsing rules, hosted marketplaces).

---

## 1) Conceptual Overview

### 1.1 What is a Universal Skill

A **Universal Skill** is a **text‑based capability definition** (typically Markdown with a structured metadata header) that tells a host:

- **When** to use the skill (explicit commands + natural triggers)
- **What inputs** it expects (files, folders, text, structured args)
- **What outputs** it produces (paths, formats)
- **How** to execute it (step‑by‑step behavior, tool usage policy)
- **How to be safe** (guardrails, non‑destructive defaults)

A Universal Skill is designed to be:

- **Portable**: checked into a repo and reusable across hosts.
- **Composable**: outputs of one skill become inputs to another.
- **Auditable**: “what happened” is visible as files + logs.
- **Progressively disclosed**: only load the minimum context needed.

### 1.2 Goals & constraints

- **Portability across hosts**: no reliance on proprietary skill runtimes.
- **Predictable invocation**:
  - **Deterministic**: explicit commands / explicit skill IDs.
  - **Convenient**: optional natural‑language triggers.
- **Progressive loading**: host reads a **single catalog** first; skill files are read **only on demand**.
- **Multi‑step workflows**: support pipelines like:
  - *Research → Image curation → HTML reader* (from the video transcript)
  - *Asset generation → Ingestion into another app* (jingle workflow)
  - *Batch transforms using deterministic scripts* (image transformer)
- **Host‑agnostic minimal contract**:
  - read files
  - write files
  - follow instructions
  - optionally call tools (shell, web search, HTTP, etc.)

**Non‑goals (by design):**

- A proprietary marketplace or centralized registry.
- A single “one true” runtime.
- Perfect auto‑invocation across all hosts (many will remain probabilistic).

### 1.3 Relationship to Claude Skills (vendor‑neutral crosswalk)

Claude Skills provides an integrated runtime where:

- A skill has a `SKILL.md` with metadata (`name`, `description`, etc.).
- The runtime can preload **only metadata**, then lazily load the full `SKILL.md` when relevant (progressive disclosure).
- Skills can include supporting files and executable scripts.

Universal Skills adopts the **design patterns** while generalizing the mechanics.

#### Equivalence in spirit

- **Modular capability units**: 1 skill = 1 focused workflow.
- **Progressive disclosure**: catalog first, full instructions only when needed.
- **Composability**: skills can stack; hosts can chain them.
- **Packaged resources**: skills can include templates/scripts.

#### Differences in mechanics (why Universal Skills exists)

- **Discovery/runtime**:
  - Claude Skills has a dedicated runtime that manages metadata preloading and skill activation.
  - Universal Skills requires a **host adapter** (thin instructions) + a **catalog‑first discipline** to emulate the same behavior.
- **Metadata parsing**:
  - Claude Skills can read “frontmatter only” efficiently.
  - Many hosts will read entire files if you point them at a skill; Universal Skills therefore emphasizes keeping the **catalog** compact and splitting large references.
- **Invocation certainty**:
  - Skills are often **probabilistic** (the model decides to use them). The transcript notes real‑world misses unless explicitly referenced.
  - Universal Skills treats deterministic invocation as a first‑class requirement: **always provide an explicit way to select a skill**.

**References (Claude Skills):**

- [Introducing Agent Skills](https://www.claude.com/blog/skills)
- [Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- [Agent Skills (Claude Code Docs)](https://code.claude.com/docs/en/skills)
- [anthropics/skills repository](https://github.com/anthropics/skills)
- [How to create custom Skills (Help Center)](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills)

---

## 2) Architecture & Data Flow

### 2.1 Components

Universal Skills consists of five conceptual components:

1. **Host / Agent Runner**
   - An IDE assistant, CLI agent, background worker, or chat agent.
   - Responsible for reading files, following instructions, and writing outputs.

2. **Skill Index / Catalog (single entry file)**
   - A compact file (recommended: `universal-skills/INSTRUCTIONS.md`).
   - Acts as the **router**: lists skills, commands, triggers, and where their definitions live.

3. **Skill Definitions**
   - One folder per skill containing `SKILL.md` (plus optional resources).

4. **Runtime Context & Tools**
   - Filesystem + optional tools (web search, shell, HTTP, language runtimes).

5. **Inputs/Outputs**
   - Standard folders (`sources/`, `outputs/`, `logs/`) enabling multi‑step workflows.

### 2.2 High‑level structure (recommended)

```text
<repo-root>/
  universal-skills/
    INSTRUCTIONS.md
    skills/
      <skill-id>/
        SKILL.md
        templates/
        scripts/
        reference/
    sources/
    outputs/
      drafts/
      refined/
      html/
      social/
      assets/
    logs/
    adapters/
      cursor/
      claude-code/
      gemini-cli/
      vscode/
      ...

  # optional host entry points (examples; not required)
  CLAUDE.md
  GEMINI.md
  AGENTS.md
  .cursor/rules/universal-skills.mdc
```

**Assumption:** your host can read `universal-skills/INSTRUCTIONS.md` at session start (or very early) via some “project instructions” mechanism.

### 2.3 Data flow: catalog‑first, then lazy load

1. **Session start**
   - Host loads its normal system prompt.
   - Host adapter injects: “Read `universal-skills/INSTRUCTIONS.md` first.”

2. **Catalog read**
   - Host reads `INSTRUCTIONS.md`.
   - Host learns:
     - available skills
     - explicit commands
     - trigger phrases
     - file paths to skill definitions
     - global safety and output rules

3. **Invocation / routing**
   - If user uses an **explicit command** (preferred), route deterministically.
   - Otherwise, match user intent against triggers and pick a skill (probabilistic).

4. **Progressive disclosure**
   - Host reads only the chosen skill’s `SKILL.md`.
   - Host reads additional skill resources *only if needed*.

5. **Execution**
   - Host reads required inputs.
   - Host produces outputs in expected folders.
   - Host writes a run log entry.

6. **Chaining**
   - Downstream skills use upstream outputs as their inputs.

### 2.4 Example pipeline mapping (from the video)

**History pipeline:**

- **History Researcher**
  - Input: a topic definition in `sources/` (scope/audience constraints)
  - Output: `outputs/drafts/<topic>.md` with placeholders for image needs

- **History Image Curator**
  - Input: `outputs/drafts/<topic>.md`
  - Output: `outputs/refined/<topic>.md` with validated image references + metadata

- **HTML Reader Builder**
  - Input: `outputs/refined/<topic>.md`
  - Output: `outputs/html/<topic>.html` (navigable reader)

**Jingle workflow:**

- **Jingle / Asset Orchestrator**
  - Input: holiday/event brief
  - Output: `outputs/assets/<event>/` (audio file + metadata) + optional ingestion instructions

**Image transformer workflow:**

- **Image Transformer**
  - Input: images in `sources/inbox/`
  - Output: transformed images in `outputs/assets/images/`
  - Optional: deterministic scripts (e.g., ImageMagick wrappers)

---

## 3) Skill Definition Model

Universal Skills uses a schema that can be authored as:

- **Markdown + YAML frontmatter** (human‑first; recommended)
- **JSON/YAML** (machine‑first; optional)

### 3.1 Required fields (minimum viable skill)

- **`id`**: stable, host‑agnostic identifier (kebab‑case)
- **`name`**: human name
- **`version`**: semantic version for the skill
- **`summary`**: one‑line “what + when”
- **`description`**: longer description with usage cues
- **`invocation`**: explicit commands and/or explicit “call patterns”
- **`inputs` / `outputs`**: types + locations
- **`behavior.steps`**: executable procedure
- **`safety`**: guardrails + tool policy

### 3.2 Recommended fields (portable + maintainable)

- **Identity & provenance**: `author`, `created_at`, `updated_at`, `license`
- **Dependencies**: `requires` (tools/packages/services)
- **Composition**: `depends_on` (other skills or output artifacts)
- **Observability**: `logging` (what to record)
- **Validation**: `acceptance_criteria` and `checks`
- **Host bindings**: optional `bindings` per host (shortcuts, palettes)

### 3.3 Inputs and outputs model

Define inputs/outputs as structured entries:

- **`inputs[]`**: each has `name`, `type`, `required`, `path_hint`, `schema` (optional)
- **`outputs[]`**: each has `name`, `type`, `path`, `format`, `determinism` (expected stability)

Supported input types (suggested baseline):

- `text`
- `file`
- `folder`
- `glob`
- `json`
- `yaml`

Supported output types (suggested baseline):

- `markdown`
- `html`
- `json`
- `images`
- `audio`
- `log`

### 3.4 Tool interaction & safety

Universal Skills treats tool use as a policy decision.

- **`safety.tool_policy.mode`**: `deny-by-default` (recommended) or `allow-by-default`
- **`safety.tool_policy.allowed`**: allowlist (shell/web/http/package install/etc.)
- **`safety.file_policy`**:
  - default to non‑destructive
  - require backups / write only under `universal-skills/outputs/` unless explicitly requested

This mirrors the practical security guidance around skills and plugins: treat skills like software you’re installing; audit before use [see general Skills cautions](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills).

### 3.5 Authoring best practices (portable patterns)

- **Keep skills focused**: one workflow per skill. If it grows, split into multiple skills that chain cleanly.
- **Make `summary`/`description` concrete**: include both what the skill does and the phrases users will say when they need it. (This mirrors how discovery works in integrated runtimes like Claude Skills.)
- **Always provide deterministic invocation**: commands and/or explicit call patterns. Treat trigger matching as best‑effort.
- **Design for progressive disclosure**:
  - keep the catalog compact
  - keep `SKILL.md` procedural and scoped
  - move deep reference material into `reference/` and only read it as needed
- **Write for auditability**: declare outputs and always write run logs. Prefer writing new files over editing many existing files.
- **Include examples + acceptance criteria**: they function as “unit tests for behavior” across different hosts.
- **Default to safety**:
  - write only under `universal-skills/outputs/` unless explicitly asked
  - deny-by-default tool policy unless you truly need broader access
  - never embed secrets in skill files or logs
- **Version like software**: bump `version` for behavior changes; keep a short changelog in the skill body if the skill is shared with a team.

### 3.6 Canonical Universal Skill template (copy‑paste)

```markdown
---
id: example-skill
name: Example Skill
version: 1.0.0
summary: Do X for Y. Use when the user asks about Z.
description: |
  Performs X end-to-end and writes outputs to a predictable location.
  Use this skill when the user invokes /example or requests Z.

author:
  name: Your Name
  contact: your-email-or-handle
created_at: 2025-12-11
updated_at: 2025-12-11
license: MIT

invocation:
  commands:
    - /example
  explicit_call_patterns:
    - "use skill: example-skill"
  triggers:
    - "do X"
    - "generate Z"

inputs:
  - name: request
    type: text
    required: true
  - name: source_file
    type: file
    required: false
    path_hint: "universal-skills/sources/..."

outputs:
  - name: primary_output
    type: markdown
    path: "universal-skills/outputs/drafts/example-output.md"
    format: markdown

depends_on: []
requires:
  tools: []
  packages: []
  services: []

safety:
  tool_policy:
    mode: deny-by-default
    allowed:
      - filesystem.read
      - filesystem.write.outputs
  file_policy:
    write_scope:
      - "universal-skills/outputs/**"
    destructive_actions: "never"

behavior:
  goals:
    - "Produce a correct, useful output"
  steps:
    - "Read the relevant inputs"
    - "Plan the output structure"
    - "Generate the output"
    - "Write outputs to the declared paths"
    - "Write a run log entry"

acceptance_criteria:
  - "Output file exists at the declared path"
  - "Output includes a brief summary section"

examples:
  - input: "Create Z from A"
    invocation: "/example A"
    output: "universal-skills/outputs/drafts/example-output.md"

---

## Instructions (human-readable)

(Write the detailed instructions here. Keep them procedural.)
```

**Design note:** This template intentionally includes both structured metadata *and* human instructions. Hosts that can parse YAML can use it directly; hosts that cannot can still follow the prose.

### 3.7 Optional machine-readable schema (JSON)

This is a *reference shape* for tooling; it is not required for day‑one usage:

```json
{
  "$schema": "https://example.com/universal-skills.schema.json",
  "id": "string",
  "name": "string",
  "version": "string",
  "summary": "string",
  "description": "string",
  "invocation": {
    "commands": ["string"],
    "explicit_call_patterns": ["string"],
    "triggers": ["string"]
  },
  "inputs": [
    {
      "name": "string",
      "type": "text|file|folder|glob|json|yaml",
      "required": true,
      "path_hint": "string"
    }
  ],
  "outputs": [
    {
      "name": "string",
      "type": "markdown|html|json|images|audio|log",
      "path": "string",
      "format": "string"
    }
  ],
  "depends_on": ["string"],
  "requires": {
    "tools": ["string"],
    "packages": ["string"],
    "services": ["string"]
  },
  "safety": {
    "tool_policy": {
      "mode": "deny-by-default|allow-by-default",
      "allowed": ["string"]
    },
    "file_policy": {
      "write_scope": ["string"],
      "destructive_actions": "never|prompt"
    }
  },
  "behavior": {
    "goals": ["string"],
    "steps": ["string"]
  }
}
```

---

## 4) Skill Index / Catalog (Instructions File)

### 4.1 Role of the index

`universal-skills/INSTRUCTIONS.md` is the **canonical entry point**.

It must contain:

- **Global host rules** (catalog‑first, progressive disclosure, output conventions)
- **Skill catalog** (ID, commands, triggers, path to definition)
- **Routing logic** (how to choose skills)
- **Composition guidance** (common pipelines)
- **Contribution rules** (how to add/update skills)

### 4.2 Progressive disclosure rules

A Universal Skills host should follow these rules:

- **MUST** read the index before choosing a skill.
- **MUST NOT** read every skill definition upfront.
- **SHOULD** load a skill definition only when:
  - an explicit command maps to it, or
  - triggers strongly match and no command was given.
- **SHOULD** load only the minimal extra resources needed (templates, references).

This is the portable equivalent of Claude’s “metadata first, load on demand” model.

### 4.3 Example `INSTRUCTIONS.md` (adapted)

```markdown
## Universal Skills – Instructions

You are a Universal Skills host operating inside this repository.

### Global rules

- Read *this file* (`universal-skills/INSTRUCTIONS.md`) first.
- Do not load all skill definitions. Load only the skill(s) required.
- Prefer explicit invocation (commands) over trigger matching.
- Write outputs only under `universal-skills/outputs/` unless the user explicitly requests otherwise.
- After execution:
  - summarize what you did
  - list created/modified files
  - write a log entry to `universal-skills/logs/runs/<timestamp>-<skill-id>.md`

### Available skills

1) **History Researcher** (`history-researcher`)
- Command: `/history-research`
- Triggers: "research the history of", "write a history article"
- Definition: `universal-skills/skills/history-researcher/SKILL.md`
- Inputs: `universal-skills/sources/*.md`
- Outputs: `universal-skills/outputs/drafts/*.md`

2) **History Image Curator** (`history-image-curator`)
- Command: `/history-images`
- Triggers: "curate images", "add validated images"
- Definition: `universal-skills/skills/history-image-curator/SKILL.md`
- Inputs: `universal-skills/outputs/drafts/*.md`
- Outputs: `universal-skills/outputs/refined/*.md`

3) **HTML Reader Builder** (`html-reader-builder`)
- Command: `/build-html-reader`
- Triggers: "turn this into an HTML reader", "make a web page reader"
- Definition: `universal-skills/skills/html-reader-builder/SKILL.md`
- Inputs: `universal-skills/outputs/refined/*.md`
- Outputs: `universal-skills/outputs/html/*.html`

4) **Instagram Post Generator** (`instagram-post-generator`)
- Command: `/instagram-post`
- Triggers: "make an Instagram post", "social caption"
- Definition: `universal-skills/skills/instagram-post-generator/SKILL.md`
- Inputs: `universal-skills/outputs/refined/*.md`
- Outputs: `universal-skills/outputs/social/*.md`

### Routing

- If a command is used, run the mapped skill.
- If no command:
  1) match request against triggers
  2) pick the best match
  3) if ambiguous, ask 1 clarifying question or propose 2 options

### Common workflows

- History pipeline: `/history-research` → `/history-images` → `/build-html-reader`
- Social cutdown: `/instagram-post` after `/history-images`

### Adding a new skill

1) Create `universal-skills/skills/<skill-id>/SKILL.md` using the canonical template.
2) Add an entry under “Available skills” above.
3) If your host supports commands, add/refresh host adapters (see `universal-skills/adapters/`).
```

---

## 5) Execution, Integration & Host Adapters

Universal Skills is host‑agnostic, but it benefits from **tiny host adapters**.

### 5.1 Installation (“registering” skills)

To install Universal Skills into a project:

1. Add the `universal-skills/` folder (catalog + skills + outputs/logs).
2. Add *one* host‑specific pointer so the host reads the catalog first.

**Assumption:** your host has *some* mechanism for project instructions (rules, memory files, config, or “always read X at startup”).

### 5.2 Host adapter pattern

A host adapter is a small file (or rule) that says:

- “Read `universal-skills/INSTRUCTIONS.md` immediately.”
- “When a user invokes a command, route to the corresponding skill.” (optional)

#### Example: generic pointer file

```markdown
## Universal Skills

**CRITICAL:** Read `universal-skills/INSTRUCTIONS.md` immediately, then follow it.
```

#### Crosswalk examples (optional)

- **Claude Code**: a root `CLAUDE.md` can contain the pointer line (Claude-specific but simple) [see Claude Code skills docs](https://code.claude.com/docs/en/skills).
- **Gemini CLI / Codex / other CLIs**: analogous pointer files (`GEMINI.md`, `AGENTS.md`) following the same pattern.
- **Cursor**: a persistent rule file that injects the pointer (implementation detail varies by Cursor version).

#### Concrete host adapter snippets (examples)

**Assumption:** every host has *some* way to inject “project instructions”. If your host uses a different file name/location, keep the content but move it to the host’s expected place.

**Cursor (project rules)** *(example only; adjust to your Cursor version)*:

```markdown
---
description: "Universal Skills: catalog-first routing"
when:
  - always
---

## Universal Skills (Cursor adapter)

**CRITICAL:** Read `universal-skills/INSTRUCTIONS.md` immediately, then follow it.
```

**Claude Code / Claude Desktop (project instruction file, e.g. `CLAUDE.md`)**:

```markdown
## Universal Skills

**CRITICAL:** Read `universal-skills/INSTRUCTIONS.md` immediately, then follow it.
```

**Gemini CLI (project instruction file, e.g. `GEMINI.md`)**:

```markdown
## Universal Skills

**CRITICAL:** Read `universal-skills/INSTRUCTIONS.md` immediately, then follow it.
```

**Codex or other agent CLIs (project instruction file, e.g. `AGENTS.md`)**:

```markdown
## Universal Skills

**CRITICAL:** Read `universal-skills/INSTRUCTIONS.md` immediately, then follow it.
```

**Slash command adapters (optional, host-specific):** if your host supports user-invoked commands, implement each Universal Skill command as a thin wrapper that says “follow skill `<id>`” and passes `$ARGUMENTS`. (This mirrors the “deterministic invocation” approach shown in the Open Agent System pattern.)

**Universal Skills principle:** all “smart” behavior lives in `universal-skills/` and skill files—not in the adapter.

### 5.3 Deterministic invocation

Because many hosts treat skill selection as **probabilistic**, Universal Skills requires deterministic invocation.

Recommended options (choose at least one):

- **Slash commands**: `/history-research`.
- **Explicit call phrase**: `use skill: history-researcher`.
- **CLI wrapper**: `us run history-researcher --source ...`.
- **Editor command palette mapping**: “Universal Skills: History Researcher”.

**Rule:** if the user explicitly selects a skill ID/command, the host **must not** pick a different skill.

### 5.4 Ambiguity resolution

When no explicit command is used:

- If one skill clearly matches triggers, run it.
- If two+ skills match:
  - ask **one** clarifying question, or
  - propose the top 2 skills and default to the safer one.

### 5.5 Context management

Universal Skills emulates “metadata injection” with **catalog discipline**:

- Keep `INSTRUCTIONS.md` compact: only include what is needed for routing.
- Keep each skill’s `SKILL.md` focused.
- Move large material into `reference/` files within a skill folder.

**Three-tier disclosure model (recommended):**

1. **Tier 1 (always)**: `INSTRUCTIONS.md` (catalog + router)
2. **Tier 2 (on demand)**: selected `skills/<id>/SKILL.md`
3. **Tier 3 (rare)**: skill references, templates, scripts

This mirrors the progressive disclosure pattern described in Anthropic’s engineering write‑up [see](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills).

### 5.6 Error handling & observability

A skill run should leave an artifact trail:

- **Run log**: `universal-skills/logs/runs/<timestamp>-<skill-id>.md`
- **Outputs**: written only to declared output paths
- **Optional validation reports**: `.../logs/validation/<timestamp>-...`

Log entries should include:

- inputs used (paths)
- outputs written (paths)
- external calls made (web/API) and why
- failures and recovery steps

#### Suggested run log format

```markdown
---
run_id: 2025-12-11T10-31-00Z-history-researcher
skill_id: history-researcher
skill_version: 1.0.0
status: success  # success|partial|failed
started_at: 2025-12-11T10:31:00Z
ended_at: 2025-12-11T10:44:12Z

inputs:
  - universal-skills/sources/video-games.md
outputs:
  - universal-skills/outputs/drafts/video-games.md
tools_used:
  - filesystem.read
  - filesystem.write.outputs
  - web.search
external_calls:
  - type: web.search
    purpose: "verify dates and key figures"
---

## Summary

- What you did (2–5 bullets).

## Notes

- Ambiguities and how you resolved them.
- Known gaps and recommended next steps.
```

### 5.7 Portability rules

To keep skills portable:

- Avoid host‑specific tool names inside core skill logic.
- Treat tool calls as capabilities (“web search”, “shell”, “http”), not brands.
- Keep adapters thin and replaceable.

---

## 6) Examples (5 concrete Universal Skills)

Each example below is a realistic “SKILL.md” you can copy and adapt.

### 6.1 Example 1 — History Researcher

**Concept:** Deep research on a topic definition file; write a structured draft article with image placeholders.

**Invocation:** `/history-research universal-skills/sources/video-games.md`

```markdown
---
id: history-researcher
name: History Researcher
version: 1.0.0
summary: Research a historical topic into a structured draft. Use for deep research and article drafting.
description: |
  Produces a draft historical article from a topic brief in universal-skills/sources/.
  Use when the user asks for historical research, timelines, or long-form explainers,
  or when the user invokes /history-research.

author:
  name: Universal Skills Working Group
created_at: 2025-12-11
updated_at: 2025-12-11

invocation:
  commands:
    - /history-research
  explicit_call_patterns:
    - "use skill: history-researcher"
  triggers:
    - "research the history of"
    - "write a history article"
    - "create a timeline"

inputs:
  - name: topic_brief
    type: file
    required: true
    path_hint: "universal-skills/sources/<topic>.md"

outputs:
  - name: draft_article
    type: markdown
    path: "universal-skills/outputs/drafts/<topic>.md"
    format: markdown

requires:
  tools:
    - web.search (optional)
  packages: []
  services: []

safety:
  tool_policy:
    mode: deny-by-default
    allowed:
      - filesystem.read
      - filesystem.write.outputs
      - web.search
  file_policy:
    write_scope:
      - "universal-skills/outputs/**"
    destructive_actions: "never"

behavior:
  goals:
    - "Produce a fact-based, well-structured draft article"
    - "Leave explicit image needs as placeholders"
  steps:
    - "Read the topic brief and extract: scope, audience, length, constraints."
    - "Create an outline with headings and a narrative flow."
    - "If web search is available, gather key facts, dates, names, and 5–10 credible sources."
    - "Write the draft in Markdown with clear sections and short paragraphs."
    - "Insert image placeholders like: <!-- IMAGE_NEEDED: ... --> at relevant sections."
    - "Write the draft to universal-skills/outputs/drafts/<topic>.md."
    - "Write a run log entry with sources used and file paths."

acceptance_criteria:
  - "Draft exists in outputs/drafts"
  - "Includes at least 5 citations/links (when web search available)"
  - "Includes IMAGE_NEEDED placeholders"

---

## Instructions

1) Open the provided topic brief. If it lacks scope or audience, ask 1 clarifying question.
2) Produce a structured, source-aware draft article.
3) Add IMAGE_NEEDED placeholders where visuals would improve comprehension.
4) Save the draft to `universal-skills/outputs/drafts/<topic>.md`.
5) Summarize what you wrote and where.
```

### 6.2 Example 2 — History Image Curator

**Concept:** Replace image placeholders with validated image references + metadata, producing a refined article.

**Invocation:** `/history-images universal-skills/outputs/drafts/video-games.md`

```markdown
---
id: history-image-curator
name: History Image Curator
version: 1.0.0
summary: Curate and validate images for a draft history article.
description: |
  Takes a draft article with IMAGE_NEEDED placeholders and produces a refined version
  with real images (or well-formed image specs) plus licensing/attribution notes.
  Use after history-researcher, or when the user asks to add/curate images.

author:
  name: Universal Skills Working Group
created_at: 2025-12-11
updated_at: 2025-12-11

invocation:
  commands:
    - /history-images
  explicit_call_patterns:
    - "use skill: history-image-curator"
  triggers:
    - "curate images"
    - "add images to this article"
    - "validate images"

inputs:
  - name: draft_article
    type: file
    required: true
    path_hint: "universal-skills/outputs/drafts/<topic>.md"

outputs:
  - name: refined_article
    type: markdown
    path: "universal-skills/outputs/refined/<topic>.md"
    format: markdown
  - name: image_manifest
    type: json
    path: "universal-skills/outputs/refined/<topic>.images.json"
    format: json

requires:
  tools:
    - web.search (optional)
    - http.fetch (optional)
    - shell (optional)
  packages: []
  services: []

safety:
  tool_policy:
    mode: deny-by-default
    allowed:
      - filesystem.read
      - filesystem.write.outputs
      - web.search
      - http.fetch
      - shell
  file_policy:
    write_scope:
      - "universal-skills/outputs/**"
    destructive_actions: "never"

behavior:
  goals:
    - "Replace placeholders with usable image references"
    - "Preserve attribution/licensing metadata"
  steps:
    - "Scan the draft for IMAGE_NEEDED placeholders."
    - "For each placeholder, propose 1–3 candidate images and pick the best."
    - "Record: source URL, creator/rights holder if known, license/usage constraints, and alt text."
    - "If downloads are allowed, fetch images into outputs/assets/images/<topic>/ and reference local paths."
    - "Otherwise, reference URLs and include a licensing note."
    - "Write a refined markdown article and a machine-readable image manifest JSON."

acceptance_criteria:
  - "Refined article exists"
  - "Image manifest exists and is valid JSON"
  - "Every image has alt text and attribution notes"

---

## Instructions

- Prefer legally usable images (public domain / permissive licenses) when possible.
- If licensing is uncertain, do not claim a license—mark it as "unknown" and keep the image as a suggestion.
- Keep the refined article readable even if images cannot be downloaded.
```

### 6.3 Example 3 — HTML Reader Builder

**Concept:** Convert refined markdown + images into a navigable HTML reader/viewer.

**Invocation:** `/build-html-reader universal-skills/outputs/refined/video-games.md`

```markdown
---
id: html-reader-builder
name: HTML Reader Builder
version: 1.0.0
summary: Build a navigable HTML reader from a refined article.
description: |
  Turns refined markdown content into a single-page HTML reader with navigation,
  keyboard controls, and image support. Use after history-image-curator or when
  the user asks to make a web reader/viewer.

invocation:
  commands:
    - /build-html-reader
  explicit_call_patterns:
    - "use skill: html-reader-builder"
  triggers:
    - "turn this into an HTML reader"
    - "make a web page for this"

inputs:
  - name: refined_article
    type: file
    required: true
    path_hint: "universal-skills/outputs/refined/<topic>.md"

outputs:
  - name: html
    type: html
    path: "universal-skills/outputs/html/<topic>.html"
    format: html

safety:
  tool_policy:
    mode: deny-by-default
    allowed:
      - filesystem.read
      - filesystem.write.outputs
  file_policy:
    write_scope:
      - "universal-skills/outputs/**"
    destructive_actions: "never"

behavior:
  goals:
    - "Produce a readable, offline-friendly HTML viewer"
    - "Preserve headings, sections, and images"
  steps:
    - "Parse the refined markdown structure (headings/sections)."
    - "Design a simple theme (typography + spacing + dark/light friendly colors)."
    - "Generate a TOC sidebar and keyboard navigation (optional)."
    - "Inline minimal CSS/JS so the file is portable."
    - "Write the final HTML to outputs/html/<topic>.html."

acceptance_criteria:
  - "HTML renders as a single file"
  - "TOC links work"
  - "Images appear or degrade gracefully"

---

## Instructions

- Prioritize portability: one HTML file with inline CSS/JS.
- If local images are used, reference relative paths.
- Include a header noting generation date and source markdown path.
```

### 6.4 Example 4 — Instagram Post Generator

**Concept:** Turn a refined article into a scroll-stopping post + caption + hashtags.

**Invocation:** `/instagram-post universal-skills/outputs/refined/video-games.md`

```markdown
---
id: instagram-post-generator
name: Instagram Post Generator
version: 1.0.0
summary: Produce an Instagram-ready post from an article.
description: |
  Summarizes a long-form article into a strong hook, carousel outline, caption,
  and hashtags. Use when the user requests a social cutdown or invokes /instagram-post.

invocation:
  commands:
    - /instagram-post
  explicit_call_patterns:
    - "use skill: instagram-post-generator"
  triggers:
    - "make an Instagram post"
    - "social caption"
    - "carousel outline"

inputs:
  - name: refined_article
    type: file
    required: true
    path_hint: "universal-skills/outputs/refined/<topic>.md"

outputs:
  - name: instagram_post
    type: markdown
    path: "universal-skills/outputs/social/<topic>.instagram.md"
    format: markdown

safety:
  tool_policy:
    mode: deny-by-default
    allowed:
      - filesystem.read
      - filesystem.write.outputs
  file_policy:
    write_scope:
      - "universal-skills/outputs/**"
    destructive_actions: "never"

behavior:
  goals:
    - "Create a high-retention post structure"
    - "Stay faithful to the source article"
  steps:
    - "Extract 5–10 key beats from the article."
    - "Write: hook (1–2 lines), carousel slide outline (6–10 slides), caption, CTA, hashtags."
    - "Write output to outputs/social/<topic>.instagram.md."

acceptance_criteria:
  - "Includes hook, carousel outline, caption, hashtags"
  - "No invented facts"

---

## Instructions

- Do not invent facts; if a claim is uncertain in the source, omit it.
- Optimize the hook for curiosity without clickbait.
- Keep hashtags relevant and not spammy.
```

### 6.5 Example 5 — Jingle / Asset Orchestrator

**Concept:** Generate a short creative brief for an external music tool, then package outputs + ingestion notes.

**Invocation:** `use skill: jingle-asset-orchestrator` with an event brief.

```markdown
---
id: jingle-asset-orchestrator
name: Jingle / Asset Orchestrator
version: 1.0.0
summary: Orchestrate external asset generation and package outputs for ingestion.
description: |
  Creates a creative brief for a music-generation tool (or human composer), tracks outputs,
  and prepares ingestion-ready artifacts (file naming, bitrate targets, metadata). Use for
  “create a jingle”, “holiday audio”, or packaging assets for another application.

invocation:
  commands:
    - /make-jingle
  explicit_call_patterns:
    - "use skill: jingle-asset-orchestrator"
  triggers:
    - "create a jingle"
    - "holiday music"
    - "sound for an event"

inputs:
  - name: event_brief
    type: text
    required: true

outputs:
  - name: creative_brief
    type: markdown
    path: "universal-skills/outputs/assets/<event>/brief.md"
    format: markdown
  - name: ingestion_notes
    type: markdown
    path: "universal-skills/outputs/assets/<event>/ingestion.md"
    format: markdown

requires:
  tools:
    - http.fetch (optional)
    - shell (optional)
  packages: []
  services:
    - "music-generation API (optional; host-dependent)"

safety:
  tool_policy:
    mode: deny-by-default
    allowed:
      - filesystem.write.outputs
      - filesystem.read
      - shell
      - http.fetch
  file_policy:
    write_scope:
      - "universal-skills/outputs/**"
    destructive_actions: "never"

behavior:
  goals:
    - "Produce a clear creative brief"
    - "Package artifacts for deterministic ingestion"
  steps:
    - "Extract mood, tempo, length, lyrics constraints, and brand tone from the event brief."
    - "Write a creative brief suitable for a music generation tool or a composer."
    - "Define target output specs (format, bitrate, loudness) and file naming."
    - "Write ingestion instructions for the downstream app (where to drop files, how to verify)."
    - "Write outputs under outputs/assets/<event>/..."

---

## Instructions

- If the host cannot call external music tools, stop at creating the brief + ingestion notes.
- If the host can call an external API, log every request/response reference (no secrets in logs).
- Prefer deterministic post-processing steps (e.g., bitrate conversion) via scripts when available.
```

### 6.6 Side-by-side: Claude Skill vs Universal Skill (conceptual mapping)

**Claude Skill (typical shape):**

```markdown
---
name: pdf-processing
description: Extract text, fill forms, merge PDFs. Use when working with PDF files.
allowed-tools: Read, Grep
---

# PDF Processing

(Instructions...)
```

**Universal Skill (mapped shape):**

```markdown
---
id: pdf-processing
name: PDF Processing
version: 1.0.0
summary: Extract text and fill forms in PDFs.
description: Use when the user provides PDFs or asks for PDF extraction/form filling.
invocation:
  commands: ["/pdf"]
  explicit_call_patterns: ["use skill: pdf-processing"]
  triggers: ["PDF", "form fill", "extract text"]
inputs: [{"name":"pdf","type":"file","required":true}]
outputs: [{"name":"text","type":"markdown","path":"universal-skills/outputs/drafts/<name>.md"}]
safety:
  tool_policy:
    mode: deny-by-default
    allowed: ["filesystem.read", "filesystem.write.outputs"]
behavior:
  steps: ["Read pdf", "Extract text", "Write output"]
---

## Instructions

(Instructions...)
```

---

## 7) Migration & Adaptation from Claude Skills

### 7.1 Concept mapping

| Claude Skills concept | Universal Skills concept |
|---|---|
| `SKILL.md` | `skills/<id>/SKILL.md` (same idea) |
| `name` | `name` + stable `id` |
| `description` (used for discovery) | `summary` + `description` + explicit commands |
| metadata preloading | catalog-first discipline + compact index |
| `allowed-tools` | `safety.tool_policy.allowed` (capabilities allowlist) |
| supporting files | `templates/`, `scripts/`, `reference/` alongside the skill |
| plugin/marketplace distribution | git submodule, repo copy, internal registry, ZIP bundles |

### 7.2 Migration recipe

1. **Extract skill intent**
   - Identify what the Claude Skill does and when it should be used.

2. **Define a stable `id`**
   - Use kebab‑case; avoid vendor references.

3. **Move “discovery text” into the catalog**
   - Put commands + triggers in `INSTRUCTIONS.md`.

4. **Convert metadata**
   - Map Claude `name/description/allowed-tools` into Universal fields.

5. **Normalize inputs/outputs**
   - Make I/O explicit with stable output paths under `universal-skills/outputs/`.

6. **Add deterministic invocation**
   - Add a command (`/something`) and an explicit call pattern (`use skill: <id>`).

7. **Add logs + acceptance criteria**
   - Make it auditable across hosts.

### 7.3 Common pitfalls

- **Over-reliance on proprietary discovery**
  - Many hosts will not preload metadata; ensure `INSTRUCTIONS.md` is the real router.

- **Assuming auto-discovery**
  - Without a built-in runtime, nothing will find your skills unless you wire in the pointer.

- **Ignoring context limits**
  - Keep the catalog small; split large references; avoid loading many skills at once.

- **Unsafe tool assumptions**
  - Treat skills as software: audit third-party skills and scripts. This applies to skill packs and plugins alike.

---

## Appendix A — Minimal “Universal Skills Host” contract

A host that supports Universal Skills should be able to:

- Read files by path
- Write files by path
- Follow structured instructions

Optional but useful:

- Run shell commands
- Perform web search
- Fetch HTTP resources

**Assumption:** not all hosts can do all optional capabilities. Skills should degrade gracefully.

---

## Appendix B — Reference links

- [Open Agent System Definition (reference pattern)](https://raw.githubusercontent.com/bladnman/open-agent-system/main/OpenAgentDefinition.md)
- [Introducing Agent Skills](https://www.claude.com/blog/skills)
- [Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- [Agent Skills (Claude Code Docs)](https://code.claude.com/docs/en/skills)
- [anthropics/skills repository](https://github.com/anthropics/skills)
- [How to create custom Skills (Help Center)](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills)

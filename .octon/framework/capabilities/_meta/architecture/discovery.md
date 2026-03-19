---
title: Skill Discovery
description: Manifest and registry formats for skill discovery and routing.
---

# Skill Discovery

Skills use a **three-file model** for progressive disclosure:

**Three files** optimize for token efficiency:

| File | Purpose | When Loaded | Token Budget |
|------|---------|-------------|--------------|
| `manifest.yml` | Skill discovery index | Always (session start) | ~50 tokens/skill |
| `capabilities.yml` | Capability schema | For validation/expansion | ~75 lines total |
| `registry.yml` | Extended metadata | After skill matched | ~50 tokens/skill |

> **Token Budget Note:** The [agentskills.io specification](https://agentskills.io/specification) recommends ~100 tokens for discovery metadata. Octon's multi-file model splits this: ~50 tokens for manifest (always loaded) + ~50 tokens for registry (loaded after match). Capability schema is loaded separately for validation. SKILL.md frontmatter (name + description) should stay under ~100 tokens per the spec.

All three files live in a **single location**: `.octon/framework/capabilities/runtime/skills/`.

---

## Shared Manifest (`.octon/framework/capabilities/runtime/skills/manifest.yml`)

Compact index for agent routing—contains only what's needed to match user intent:

```yaml
# Skills Manifest (Skill Discovery Index)
schema_version: "2.0"
default: null

skills:
  - id: refine-prompt
    display_name: Refine Prompt
    group: synthesis
    path: synthesis/refine-prompt/
    summary: "Context-aware prompt refinement with persona assignment."
    status: active
    tags:
      - prompt
      - refinement
      - context-aware
    triggers:
      - "refine my prompt"
      - "improve this prompt"
      - "expand this prompt"
```

### Manifest Fields

| Field | Required | Description |
|-------|----------|-------------|
| `schema_version` | Yes | Manifest format version |
| `default` | No | Default skill ID when no match found (see below) |
| `skills` | Yes | Array of skill entries |

### Default Skill

The `default` field specifies which skill to invoke when user intent doesn't match any skill's triggers or commands. This provides a fallback behavior instead of failing with "no matching skill."

```yaml
# Example: Use refine-prompt as fallback for unmatched intents
default: refine-prompt
```

**Behavior:**

| Value | Behavior |
|-------|----------|
| `null` | No fallback; agent reports "no matching skill found" |
| `<skill-id>` | Invoke the specified skill when no match |

**Use cases:**

- **General-purpose skill** — Set a versatile skill (like `refine-prompt`) as default to handle ambiguous requests
- **Help/guidance skill** — Set a help skill that guides users to the right skill
- **Null (recommended default)** — Prefer explicit matching; ask user for clarification

**Harness override:** The harness manifest's `default` takes precedence over the shared manifest's `default`, allowing harness-specific fallback behavior.

### Skill Entry Fields (Manifest)

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique skill identifier (matches directory name and SKILL.md `name`) |
| `display_name` | Yes | Human-readable display name |
| `group` | Yes | Skill group for directory organization |
| `path` | Yes | Relative path to skill directory |
| `summary` | Yes | One-line description for routing |
| `status` | No | Lifecycle state: `active`, `deprecated`, `experimental`, `draft` (default: `active`) |
| `tags` | No | Freeform labels for filtering and grouping |
| `triggers` | No | Natural language phrases for matching |
| `skill_sets` | No | Capability bundles (executor, guardian, etc.) |
| `capabilities` | No | Additional capabilities beyond skill sets |

### Status Values

| Status | Description |
|--------|-------------|
| `active` | Skill is ready for production use (default) |
| `deprecated` | Skill is being phased out; agents may warn users |
| `experimental` | Skill is in development; behavior may change |
| `draft` | Skill is not ready for activation; used for in-progress definitions |

### Tags

Tags enable filtering and grouping skills by domain or function:

```yaml
# Filter skills by tag
/list-skills --tag=research
/list-skills --tag=prompt
```

Common tag categories:
- **Domain:** `research`, `documentation`, `testing`, `refactoring`
- **Function:** `synthesis`, `generation`, `analysis`, `transformation`
- **Scope:** `codebase-wide`, `file-level`, `project-level`

### Tags vs Capabilities

**Tags** and **capabilities** serve different purposes:

| Concept | Determined By | Purpose |
|---------|---------------|---------|
| Tags | `tags` field | Discovery, filtering, semantic categorization |
| Skill Sets | `skill_sets` field | Capability bundles for common patterns |
| Capabilities | `capabilities` field | What the skill can do, drives documentation |

**Tags** express semantic categories—what kind of thing a skill is:

```yaml
skills:
  - id: validate-schema
    tags: [validator, json, schema]
    skill_sets: []
    capabilities: []

  - id: refactor
    tags: [refactor, codebase, verification]
    skill_sets: [executor, guardian]
    capabilities: [resumable]
```

**Capabilities** determine documentation requirements. Two skills with the same tags might have different capabilities:

- `validate-schema` (tag: validator) — `skill_sets: []` (minimal docs)
- `audit-compliance` (tag: validator) — `skill_sets: [executor, guardian]` (full workflow docs)

See [Capabilities](./capabilities.md) and [Skill Sets](./skill-sets.md) for the complete reference.

---

## Skills Registry (`.octon/framework/capabilities/runtime/skills/registry.yml`)

Extended metadata loaded after a skill is matched—contains routing rules, commands, parameters, and requirements. Input/output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth for I/O).

```yaml
# Skills Registry (Extended Metadata)
schema_version: "3.0"

routing:
  explicit_command_required: false
  ambiguity_resolution: "ask"  # ask | first_match | most_specific

skills:
  refine-prompt:
    version: "2.1.1"
    commands:
      - /refine-prompt
    parameters:
      - name: raw_prompt
        type: text
        required: true
        description: "The raw prompt text to refine"
    requires:
      context:
        - type: directory_exists
          path: ".octon/"
          description: "Requires a harness directory"
    composition:
      mode: prerequisites
      failure_policy: fail_fast
      steps: []
```

> **Tool Permissions:** Tool permissions are defined in SKILL.md frontmatter via `allowed-tools`, not in registry.yml. This is the **single source of truth** for what tools a skill may use. See [Specification](./specification.md#tool-permissions-single-source-of-truth) for details.

### Registry Schema Fields

| Field | Required | Description |
|-------|----------|-------------|
| `schema_version` | Yes | Registry format version |
| `routing.explicit_command_required` | No | Require `/command` syntax (default: false) |
| `routing.ambiguity_resolution` | No | How to handle multiple matches: `ask`, `first_match`, `most_specific` |
| `skills` | Yes | Map of skill id → extended metadata |

### Skill Entry Fields (Registry)

| Field | Required | Description |
|-------|----------|-------------|
| `version` | No | Semantic version string |
| `commands` | Yes | Slash commands that invoke this skill |
| `parameters` | No | Input parameters the skill accepts |
| `requires.context` | No | Context conditions for skill activation |
| `composition` | No | Skill-local prerequisite or invocation graph |

> **Note:** Input/output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` under `skills.<id>.io`.

> **Tool Permissions:** Tool permissions are **not** defined in registry.yml. They are defined in SKILL.md frontmatter via `allowed-tools` (single source of truth). The internal format is derived via the mapping function in `validate-skills.sh`.

### Context Requirements

Skills can declare context conditions that must be met before activation:

```yaml
requires:
  context:
    - type: directory_exists
      path: ".octon/"
      description: "Requires a harness directory"
    - type: files_match
      glob: "**/*.md"
      min_count: 1
      description: "Requires at least one markdown file"
```

| Context Type | Parameters | Description |
|--------------|------------|-------------|
| `directory_exists` | `path` | Directory must exist |
| `file_exists` | `path` | File must exist |
| `files_match` | `glob`, `min_count` | Files matching glob must meet minimum count |

**Note:** The pattern `use skill: <id>` is universal and recognized by all agents automatically. It does not require per-skill configuration.

---

## Skill I/O Mappings

I/O paths are defined in `registry.yml` under each skill's entry:

```yaml
skills:
  synthesize-research:
    io:
      inputs:
        - path: "/.octon/instance/capabilities/runtime/skills/resources/synthesize-research/"
          kind: directory
          required: true
          description: "Research notes and source materials"
      outputs:
        - path: ".octon/inputs/exploratory/drafts/{{topic}}-synthesis.md"
          kind: file
          format: markdown
          determinism: stable
          description: "Synthesized research findings document"

  refine-prompt:
    io:
      inputs:
        - path: "/.octon/instance/capabilities/runtime/skills/resources/refine-prompt/prompts/"
          kind: directory
          required: false
          description: "Optional prompt source folder"
      outputs:
        - path: ".octon/framework/scaffolding/practices/prompts/{{timestamp}}-refined.md"
          kind: file
          format: markdown
          determinism: stable
          description: "Refined prompt output"
```

> **Note:** All `.octon/framework/capabilities/runtime/skills/` categories follow the `{{category}}/{{skill-id}}/` pattern. See [Design Conventions](../../practices/design-conventions.md#harness-skills-directory-structure) for details.

### I/O Schema

Input and output entries use a standardized schema:

**Input Fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `path` | Yes | Path pattern (supports `{{placeholders}}`) |
| `kind` | No | `file` or `directory` (default: `file`) |
| `required` | No | Whether input must exist (default: `true`) |
| `description` | No | Human-readable description |

**Output Fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `path` | Yes | Output path pattern (supports `{{placeholders}}`) |
| `kind` | No | `file` or `directory` (default: `file`) |
| `format` | No | `markdown`, `json`, `yaml`, `text`, `html`, `binary` |
| `determinism` | No | `stable` (same input = same output), `variable`, `unique` |
| `description` | No | Human-readable description |

### Output Paths and Permission Tiers

Output paths are declared in the registry and validated against the repository-root harness boundary. Skills produce two distinct artifact types with different permission models.

#### Deliverables (Final Products)

Deliverables go directly to their final destination with tiered permissions:

| Tier | Scope | Example Path | Use Case |
|------|-------|--------------|----------|
| **Tier 1** | `.octon/{{category}}/` | `.octon/framework/scaffolding/practices/prompts/refined.md` | Standard deliverables |
| **Tier 2** | `.octon/**` | `.octon/generated/exports/data.json` | Custom harness locations |
| **Tier 3** | `<harness-root>/**` | `src/generated/api-client.ts` | Project source locations |

```yaml
# Deliverables - final destination
.octon/framework/scaffolding/practices/prompts/{{timestamp}}-refined.md
.octon/inputs/exploratory/drafts/{{topic}}-synthesis.md
```

#### Operational Artifacts

Operational artifacts use the categorical `{{category}}/{{skill-id}}/` pattern within `.octon/framework/capabilities/runtime/skills/`:

| Category | Path Pattern | Purpose |
|----------|--------------|---------|
| `/.octon/instance/capabilities/runtime/skills/configs/` | `/.octon/instance/capabilities/runtime/skills/configs/{{skill-id}}/` | Per-skill configuration overrides |
| `/.octon/instance/capabilities/runtime/skills/resources/` | `/.octon/instance/capabilities/runtime/skills/resources/{{skill-id}}/` | Per-skill input materials |
| `/.octon/state/control/skills/checkpoints/` | `/.octon/state/control/skills/checkpoints/{{skill-id}}/{{run-id}}/` | Execution state (checkpoints, manifests) |
| `/.octon/state/evidence/runs/skills/` | `/.octon/state/evidence/runs/skills/{{skill-id}}/{{run-id}}.md` | Execution history |

#### Custom Paths (Tier 2 & 3)

Declare custom deliverable paths in the registry:

```yaml
skills:
  # Tier 2: Within .octon/
  synthesize-research:
    io:
      inputs:
        - path: "projects/{{project}}/"
          type: folder
      outputs:
        - path: "projects/{{project}}/synthesis.md"   # .octon/inputs/exploratory/ideation/projects/...
          type: markdown

  # Tier 3: Harness root
  generate-docs:
    io:
      outputs:
        - path: "docs/generated/{{name}}.md"          # {{harness_root}}/docs/...
          type: markdown

  # Tier 3: Into the project tree
  scaffold-kit:
    io:
      outputs:
        - path: "packages/flowkit/README.md"
          type: markdown
```

---

### Repository Scope Validation

Output paths must fall within the repository-root harness scope:

- **Can write within the repo root:** including declared project source paths
- **Cannot write outside the repository:** no upward traversal or external paths

#### Valid Paths

```yaml
# In repo/.octon/framework/capabilities/runtime/skills/registry.yml
skills:
  scaffold-all:
    io:
      outputs:
        - path: "README.md"                         # ✓ Harness root
        - path: "src/generated.ts"                  # ✓ Harness subdirectory
        - path: "docs/guides/setup.md"              # ✓ Repo path
        - path: "packages/kits/flowkit/README.md"   # ✓ Deep repo path
```

#### Invalid Paths

```yaml
# In repo/.octon/framework/capabilities/runtime/skills/registry.yml
skills:
  generate-guide:
    io:
      outputs:
        - path: "guides/quickstart.md"              # ✓ Valid: within repo root
        - path: "../README.md"                      # ✗ REJECTED: escapes repo root
        - path: "../other-repo/README.md"           # ✗ REJECTED: sibling workspace outside repo root
```

#### Validation Rules

Paths are validated at:

1. **Registry load time** — Warn/error if paths are outside scope
2. **Execution time** — Block writes that escape the repository boundary

### Composition

Define skill-local prerequisite or invocation metadata:

```yaml
composition:
  mode: sequential
  failure_policy: fail_fast
  steps:
    - id: synthesize-research
      kind: skill
      ref: synthesize-research
      role: invoke
      required: true
```

---

## Routing Rules

When a user invokes a skill, the system:

1. Read `.octon/framework/capabilities/runtime/skills/manifest.yml` for skill index
2. If explicit command (`/skill-name`), route directly
4. If `use skill: <name>` pattern, route directly
5. Otherwise, match against triggers in manifest
6. If ambiguous, use `ambiguity_resolution` setting from registry (default: ask)
7. Load matched skill's entry from `registry.yml` for commands/requires

---

## See Also

- [Architecture](./architecture.md) — Single-root harness model and scope authority
- [Invocation](./invocation.md) — How routing rules are applied
- [Execution](./execution.md) — Scope enforcement during execution
- [Creation](./creation.md) — Adding skills to the manifest and registry

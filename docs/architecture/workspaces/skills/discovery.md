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

> **Token Budget Note:** The [agentskills.io specification](https://agentskills.io/specification) recommends ~100 tokens for discovery metadata. Harmony's multi-file model splits this: ~50 tokens for manifest (always loaded) + ~50 tokens for registry (loaded after match). Capability schema is loaded separately for validation. SKILL.md frontmatter (name + description) should stay under ~100 tokens per the spec.

All three files live in a **single location**: `.harmony/capabilities/skills/`.

---

## Shared Manifest (`.harmony/capabilities/skills/manifest.yml`)

Compact index for agent routing—contains only what's needed to match user intent:

```yaml
# Skills Manifest (Skill Discovery Index)
schema_version: "1.2"
default: null

skills:
  - id: refine-prompt
    display_name: Refine Prompt
    path: refine-prompt/
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

**Workspace override:** The workspace manifest's `default` takes precedence over the shared manifest's `default`, allowing workspace-specific fallback behavior.

### Skill Entry Fields (Manifest)

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique skill identifier (matches directory name and SKILL.md `name`) |
| `display_name` | Yes | Human-readable display name |
| `path` | Yes | Relative path to skill directory |
| `summary` | Yes | One-line description for routing |
| `status` | No | Lifecycle state: `active`, `deprecated`, `experimental` (default: `active`) |
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

## Shared Registry (`.harmony/capabilities/skills/registry.yml`)

Extended metadata loaded after a skill is matched—contains routing rules, commands, parameters, and requirements. Input/output paths are defined in `.harmony/capabilities/skills/registry.yml` (single source of truth for I/O).

```yaml
# Skills Registry (Extended Metadata)
schema_version: "1.2"

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
          path: ".harmony/"
          description: "Requires a workspace directory"
    depends_on: []
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
| `depends_on` | No | Other skills this skill requires |

> **Note:** Input/output paths are defined in `.harmony/capabilities/skills/registry.yml` under `skill_mappings`.

> **Tool Permissions:** Tool permissions are **not** defined in registry.yml. They are defined in SKILL.md frontmatter via `allowed-tools` (single source of truth). The internal format is derived via the mapping function in `validate-skills.sh`.

### Context Requirements

Skills can declare context conditions that must be met before activation:

```yaml
requires:
  context:
    - type: directory_exists
      path: ".harmony/"
      description: "Requires a workspace directory"
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

## Skill Mappings

I/O paths are defined in `registry.yml` under each skill's entry:

```yaml
skill_mappings:
  synthesize-research:
    inputs:
      - path: "resources/synthesize-research/"
        kind: directory
        required: true
        description: "Research notes and source materials"
    outputs:
      - path: ".harmony/output/drafts/{{topic}}-synthesis.md"
        kind: file
        format: markdown
        determinism: stable
        description: "Synthesized research findings document"

  refine-prompt:
    inputs:
      - path: "resources/refine-prompt/prompts/"
        kind: directory
        required: false
        description: "Optional prompt source folder"
    outputs:
      - path: ".harmony/scaffolding/prompts/{{timestamp}}-refined.md"
        kind: file
        format: markdown
        determinism: stable
        description: "Refined prompt output"
```

> **Note:** All `.harmony/capabilities/skills/` categories follow the `{{category}}/{{skill-id}}/` pattern. See [Design Conventions](./design-conventions.md#workspace-skills-directory-structure) for details.

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

Output paths are declared in the registry and validated against the workspace's hierarchical scope. Skills produce two distinct artifact types with different permission models.

#### Deliverables (Final Products)

Deliverables go directly to their final destination with tiered permissions:

| Tier | Scope | Example Path | Use Case |
|------|-------|--------------|----------|
| **Tier 1** | `.harmony/{{category}}/` | `.harmony/scaffolding/prompts/refined.md` | Standard deliverables |
| **Tier 2** | `.harmony/**` | `.harmony/output/exports/data.json` | Custom workspace locations |
| **Tier 3** | `<workspace-root>/**` | `src/generated/api-client.ts` | Project source locations |

```yaml
# Deliverables - final destination
.harmony/scaffolding/prompts/{{timestamp}}-refined.md
.harmony/output/drafts/{{topic}}-synthesis.md
```

#### Operational Artifacts

Operational artifacts use the categorical `{{category}}/{{skill-id}}/` pattern within `.harmony/capabilities/skills/`:

| Category | Path Pattern | Purpose |
|----------|--------------|---------|
| `configs/` | `configs/{{skill-id}}/` | Per-skill configuration overrides |
| `resources/` | `resources/{{skill-id}}/` | Per-skill input materials |
| `runs/` | `runs/{{skill-id}}/{{run-id}}/` | Execution state (checkpoints, manifests) |
| `logs/` | `logs/{{skill-id}}/{{run-id}}.md` | Execution history |

#### Custom Paths (Tier 2 & 3)

Declare custom deliverable paths in the registry:

```yaml
skill_mappings:
  # Tier 2: Within .harmony/
  synthesize-research:
    inputs:
      - path: "projects/{{project}}/"
        type: folder
    outputs:
      - path: "projects/{{project}}/synthesis.md"   # .harmony/ideation/projects/...
        type: markdown

  # Tier 3: Workspace root
  generate-docs:
    outputs:
      - path: "docs/generated/{{name}}.md"          # {{workspace_root}}/docs/...
        type: markdown

  # Tier 3: Into descendant workspace
  scaffold-kit:
    outputs:
      - path: "flowkit/README.md"                 # Descendant workspace
        type: markdown
```

---

### Hierarchical Scope Validation

Output paths must fall within the workspace's hierarchical scope:

- **Can write DOWN:** Into descendant workspaces
- **Cannot write UP:** Into ancestor workspaces
- **Cannot write SIDEWAYS:** Into sibling workspaces

#### Valid Paths

```yaml
# In repo/.harmony/capabilities/skills/registry.yml (scope: repo/**)
skill_mappings:
  scaffold-all:
    outputs:
      - path: "README.md"                         # ✓ Workspace root
      - path: "src/generated.ts"                  # ✓ Workspace subdirectory
      - path: "docs/guides/setup.md"              # ✓ Descendant workspace (docs)
      - path: "packages/kits/flowkit/README.md"   # ✓ Deep descendant workspace
```

#### Invalid Paths

```yaml
# In docs/.harmony/capabilities/skills/registry.yml (scope: docs/**)
skill_mappings:
  generate-guide:
    outputs:
      - path: "guides/quickstart.md"              # ✓ Valid: within scope
      - path: "../README.md"                      # ✗ REJECTED: ancestor (repo)
      - path: "../packages/kits/README.md"        # ✗ REJECTED: sibling path

# In flowkit/.harmony/capabilities/skills/registry.yml (scope: flowkit/**)
skill_mappings:
  generate-types:
    outputs:
      - path: "src/types.ts"                      # ✓ Valid: within scope
      - path: "../shared/types.ts"                # ✗ REJECTED: ancestor (kits)
      - path: "../../README.md"                   # ✗ REJECTED: ancestor (repo)
```

#### Validation Rules

Paths are validated at:

1. **Registry load time** — Warn/error if paths are outside scope
2. **Execution time** — Block writes that escape hierarchical scope

### Pipelines

Define multi-skill workflows:

```yaml
pipelines:
  - id: full-research
    name: Full Research Pipeline
    steps:
      - gather-sources
      - synthesize-research
      - generate-report
    description: "End-to-end research with synthesis and reporting"
```

---

## Routing Rules

When a user invokes a skill, the system:

1. Read `.harmony/capabilities/skills/manifest.yml` for skill index
2. If explicit command (`/skill-name`), route directly
4. If `use skill: <name>` pattern, route directly
5. Otherwise, match against triggers in manifest
6. If ambiguous, use `ambiguity_resolution` setting from registry (default: ask)
7. Load matched skill's entry from `registry.yml` for commands/requires

---

## See Also

- [Architecture](./architecture.md) — Hierarchical workspace model and scope authority
- [Invocation](./invocation.md) — How routing rules are applied
- [Execution](./execution.md) — Scope enforcement during execution
- [Creation](./creation.md) — Adding skills to the manifest and registry

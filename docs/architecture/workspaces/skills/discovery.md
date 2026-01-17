---
title: Skill Discovery
description: Manifest and registry formats for skill discovery and routing.
---

# Skill Discovery

Skills use a **two-file, two-location model** for progressive disclosure:

**Two files** optimize for token efficiency:

| File | Purpose | When Loaded | Token Budget |
|------|---------|-------------|--------------|
| `manifest.yml` | Skill discovery index | Always (session start) | ~50 tokens/skill |
| `registry.yml` | Extended metadata | After skill matched | ~50 tokens/skill |

> **Token Budget Note:** The [agentskills.io specification](https://agentskills.io/specification) recommends ~100 tokens for discovery metadata. Harmony's two-file model splits this: ~50 tokens for manifest (always loaded) + ~50 tokens for registry (loaded after match). SKILL.md frontmatter (name + description) should stay under ~100 tokens per the spec.

**Two locations** separate shared definitions from workspace-specific configuration:

| Location | Manifest | Registry |
|----------|----------|----------|
| `.harmony/skills/` | Shared skill index | Shared extended metadata |
| `.workspace/skills/` | Workspace-specific skills | I/O mappings, pipelines |

Agents read shared files first, then workspace files. Workspace entries extend or override shared definitions.

---

## Shared Manifest (`.harmony/skills/manifest.yml`)

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

---

## Shared Registry (`.harmony/skills/registry.yml`)

Extended metadata loaded after a skill is matched—contains routing rules, commands, parameters, and requirements. Input/output paths are defined in `.workspace/skills/registry.yml` (single source of truth for I/O).

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
          path: ".workspace/"
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

> **Note:** Input/output paths are defined in `.workspace/skills/registry.yml`, not here. This keeps portable skill logic separate from workspace-specific I/O configuration.

> **Tool Permissions:** Tool permissions are **not** defined in registry.yml. They are defined in SKILL.md frontmatter via `allowed-tools` (single source of truth). The internal format is derived via the mapping function in `validate-skills.sh`.

### Context Requirements

Skills can declare context conditions that must be met before activation:

```yaml
requires:
  context:
    - type: directory_exists
      path: ".workspace/"
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

## Workspace Manifest (`.workspace/skills/manifest.yml`)

Extends the shared manifest with workspace-specific skills:

```yaml
# Skills Manifest (Project-Specific)
schema_version: "1.2"
extends: "../../.harmony/skills/manifest.yml"
default: null

# Project-specific skills
skills: []
```

### Workspace Manifest Fields

| Field | Required | Description |
|-------|----------|-------------|
| `extends` | Yes | Path to shared manifest to inherit from |
| `default` | No | Default skill for this workspace (overrides shared manifest's `default`) |
| `skills` | No | Workspace-local skill entries (same format as shared) |

> **Note:** Setting `default: null` in the workspace manifest explicitly disables any default inherited from the shared manifest.

---

## Workspace Registry (`.workspace/skills/registry.yml`)

Extends the shared registry with workspace-specific I/O mappings and pipelines:

```yaml
# Skills Registry (Workspace-Specific)
schema_version: "1.2"
extends: "../../.harmony/skills/registry.yml"
default: null

# Workspace-specific I/O mappings for inherited skills
skill_mappings:
  research-synthesizer:
    inputs:
      - path: "projects/{{project}}/"
        kind: directory
        required: true
        description: "Project folder containing research notes"
    outputs:
      - path: "outputs/drafts/{{topic}}-synthesis.md"
        kind: file
        format: markdown
        determinism: stable
        description: "Synthesized research findings document"

# Extended metadata for workspace-specific skills
skills: {}

# Workspace-specific pipelines
pipelines:
  - id: research-synthesis
    name: Research Synthesis Pipeline
    steps:
      - research-synthesizer
```

### Workspace Registry Fields

| Field | Required | Description |
|-------|----------|-------------|
| `extends` | Yes | Path to shared registry to inherit from |
| `skill_mappings` | No | I/O path overrides for inherited skills |
| `skills` | No | Extended metadata for workspace-local skills |
| `pipelines` | No | Multi-skill workflow definitions |

### Skill Mappings

Override I/O paths for inherited skills without modifying the shared definition:

```yaml
skill_mappings:
  refine-prompt:
    inputs:
      - path: "sources/prompts/"
        kind: directory
        required: false
        description: "Optional prompt source folder"
    outputs:
      - path: "outputs/refined-prompts/{{timestamp}}-refined.md"
        kind: file
        format: markdown
        determinism: stable
        description: "Refined prompt output"
```

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

Output paths are declared in the registry and validated against the workspace's hierarchical scope.

#### Permission Tiers

| Tier | Location | Declaration |
|------|----------|-------------|
| **Tier 1** | `.workspace/skills/outputs/**` | None required (default) |
| **Tier 2** | `.workspace/**` | Must declare in registry |
| **Tier 3** | `<workspace-root>/**` | Must declare in registry |

#### Default Output (Tier 1)

Without explicit declaration, skills write to the default safe zone:

```yaml
# No declaration needed - automatically allowed
.workspace/skills/outputs/{{category}}/{{timestamp}}-{{name}}.md
```

#### Custom Paths (Tier 2 & 3)

Declare custom output paths in the registry:

```yaml
skill_mappings:
  # Tier 2: Within .workspace/
  research-synthesizer:
    inputs:
      - path: "projects/{{project}}/"
        type: folder
    outputs:
      - path: "projects/{{project}}/synthesis.md"   # .workspace/projects/...
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
# In repo/.workspace/skills/registry.yml (scope: repo/**)
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
# In docs/.workspace/skills/registry.yml (scope: docs/**)
skill_mappings:
  generate-guide:
    outputs:
      - path: "guides/quickstart.md"              # ✓ Valid: within scope
      - path: "../README.md"                      # ✗ REJECTED: ancestor (repo)
      - path: "../packages/kits/README.md"        # ✗ REJECTED: sibling path

# In flowkit/.workspace/skills/registry.yml (scope: flowkit/**)
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
      - research-synthesizer
      - generate-report
    description: "End-to-end research with synthesis and reporting"
```

---

## Routing Rules

When a user invokes a skill, the system:

1. Read `.harmony/skills/manifest.yml` for shared skill index
2. Read `.workspace/skills/manifest.yml` for workspace-specific skills
3. If explicit command (`/skill-name`), route directly
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

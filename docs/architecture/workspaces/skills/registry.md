---
title: Skill Registry
description: Shared and workspace-specific registry formats for skill routing.
---

# Skill Registry

Registries provide centralized metadata for skill routing and discovery. The architecture uses separate registries for shared skills (`.harmony/`) and workspace-specific I/O mappings (`.workspace/`). Output paths declared in the workspace registry are validated against the workspace's hierarchical scope.

---

## Shared Registry (`.harmony/skills/registry.yml`)

Contains skill metadata for routing **without** workspace-specific I/O paths:

```yaml
# Skills Registry (Shared Foundation)
schema_version: "1.1"
default: null

routing:
  explicit_command_required: false
  ambiguity_resolution: "ask"  # ask | first_match | most_specific

skills:
  - id: refine-prompt
    name: Refine Prompt
    path: refine-prompt/
    version: "2.1.1"
    summary: "Transform rough prompts into clear, actionable instructions."
    commands:
      - /refine-prompt
    explicit_call_patterns:
      - "use skill: refine-prompt"
    triggers:
      - "refine my prompt"
      - "improve this prompt"
    requires:
      tools:
        - filesystem.read
        - filesystem.write.outputs
    depends_on: []
```

### Schema Fields

| Field | Required | Description |
|-------|----------|-------------|
| `schema_version` | Yes | Registry format version |
| `default` | No | Default skill when no match found |
| `routing.explicit_command_required` | No | Require `/command` syntax (default: false) |
| `routing.ambiguity_resolution` | No | How to handle multiple matches: `ask`, `first_match`, `most_specific` |

### Skill Entry Fields

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique skill identifier (matches directory name) |
| `name` | Yes | Human-readable display name |
| `path` | Yes | Relative path to skill directory |
| `version` | No | Semantic version string |
| `summary` | Yes | One-line description for routing |
| `commands` | Yes | Slash commands that invoke this skill |
| `explicit_call_patterns` | No | Literal phrases for explicit invocation |
| `triggers` | No | Natural language phrases for matching |
| `requires.tools` | No | Required tool permissions |
| `depends_on` | No | Other skills this skill requires |

---

## Workspace Skills Registry (`.workspace/skills/registry.yml`)

Extends the shared registry with workspace-specific I/O mappings:

```yaml
# Skills Registry (Workspace-Specific)
schema_version: "1.1"
extends: "../../.harmony/skills/registry.yml"
default: null

# Workspace-specific I/O mappings for inherited skills
skill_mappings:
  research-synthesizer:
    inputs:
      - path: "projects/<project>/"
        type: folder
    outputs:
      - path: "projects/<project>/synthesis.md"
        type: markdown
        determinism: stable

# Workspace-specific skills (not in .harmony/)
skills: []

# Workspace-specific pipelines
pipelines:
  - id: research-synthesis
    name: Research Synthesis Pipeline
    steps:
      - research-synthesizer
```

### Workspace-Specific Fields

| Field | Required | Description |
|-------|----------|-------------|
| `extends` | Yes | Path to shared registry to inherit from |
| `skill_mappings` | No | I/O path overrides for inherited skills |
| `skills` | No | Workspace-local skill definitions |
| `pipelines` | No | Multi-skill workflow definitions |

### Skill Mappings

Override I/O paths for inherited skills without modifying the shared definition:

```yaml
skill_mappings:
  refine-prompt:
    inputs:
      - path: "sources/prompts/"
        type: folder
    outputs:
      - path: "outputs/refined-prompts/"
        type: folder
```

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
.workspace/skills/outputs/<category>/<timestamp>-<name>.md
```

#### Custom Paths (Tier 2 & 3)

Declare custom output paths in the registry:

```yaml
skill_mappings:
  # Tier 2: Within .workspace/
  research-synthesizer:
    inputs:
      - path: "projects/<project>/"
        type: folder
    outputs:
      - path: "projects/<project>/synthesis.md"   # .workspace/projects/...
        type: markdown

  # Tier 3: Workspace root
  generate-docs:
    outputs:
      - path: "docs/generated/<name>.md"          # <workspace-root>/docs/...
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

1. Read `.harmony/skills/registry.yml` for shared skills
2. Read `.workspace/skills/registry.yml` for workspace mappings
3. If explicit command (`/skill-name`), route directly
4. If `use skill: <name>` pattern, route directly
5. Otherwise, match against triggers
6. If ambiguous, use `ambiguity_resolution` setting (default: ask one clarifying question)

---

## See Also

- [Architecture](./architecture.md) — Hierarchical workspace model and scope authority
- [Invocation](./invocation.md) — How routing rules are applied
- [Execution](./execution.md) — Scope enforcement during execution
- [Creation](./creation.md) — Adding skills to the registry

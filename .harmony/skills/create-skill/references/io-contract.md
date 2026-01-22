---
# I/O Contract Documentation
# AUTHORITATIVE SOURCES:
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .harmony/skills/registry.yml
#   - Output paths: .workspace/skills/registry.yml
---

# I/O Contract Reference

Input/output specifications for the create-skill skill.

> **Authoritative Sources:**
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Parameters: `.harmony/skills/registry.yml`
> - Output paths: `.workspace/skills/registry.yml`

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `skill_name` | text | Yes | - | Skill identifier (kebab-case, 1-64 chars) |
| `description` | text | No | - | Initial description for SKILL.md |
| `archetype` | text | No | `workflow` | Skill archetype: `utility` or `workflow` |

## Output Structure

### Created Skill Directory

```
.harmony/skills/{{skill-name}}/
├── SKILL.md
├── references/
│   ├── behaviors.md
│   ├── io-contract.md
│   ├── safety.md
│   ├── examples.md
│   └── validation.md
├── scripts/
└── assets/
```

### Continuity Artifacts

```
.workspace/skills/runs/create-skill/{{run-id}}/
├── checkpoint.yml     # Execution state (source of truth for resume)
└── summary.md         # Creation summary
```

Where `{{run-id}}` = `{{timestamp}}-{{skill-name}}` (e.g., `2026-01-20-analyze-codebase`)

### Symlinks

```
.claude/skills/{{skill-name}} -> ../../.harmony/skills/{{skill-name}}
.cursor/skills/{{skill-name}} -> ../../.harmony/skills/{{skill-name}}
.codex/skills/{{skill-name}} -> ../../.harmony/skills/{{skill-name}}
```

### Log Structure

```
.workspace/skills/logs/
├── index.yml                          # Top-level index (update with new run)
└── create-skill/
    ├── index.yml                      # Skill-level index (all skills created)
    └── {{run-id}}.md                    # Run log
```

## Checkpoint File Schema

```yaml
# checkpoint.yml - Source of truth for execution state
skill: create-skill
version: "1.0.0"
run_id: "{{timestamp}}-{{skill-name}}"
skill_name: "{{skill-name}}"

status: in_progress  # pending | in_progress | completed | failed

current_phase: 3
phases:
  1_validate:
    status: completed
    completed_at: "2026-01-20T14:00:00Z"
    warnings: []
  2_copy_template:
    status: completed
    completed_at: "2026-01-20T14:00:05Z"
    files_created:
      - SKILL.md
      - references/behaviors.md
      - references/io-contract.md
      - references/safety.md
      - references/examples.md
      - references/validation.md
    symlinks_created:
      - .claude/skills/{{skill-name}}
      - .cursor/skills/{{skill-name}}
      - .codex/skills/{{skill-name}}
  3_initialize:
    status: in_progress
    started_at: "2026-01-20T14:00:10Z"
  4_update_registry:
    status: pending
  5_update_catalog:
    status: pending
  6_report:
    status: pending

resume:
  phase: 3
  instruction: "Continue placeholder replacement"

parameters:
  skill_name: "{{skill-name}}"
  description: null
  archetype: "workflow"
```

## Log Index Schemas

### Top-Level Index (`logs/index.yml`)

```yaml
# logs/index.yml - Cross-skill chronological index (~50-100 tokens)
updated: "2026-01-20T14:30:00Z"

recent_runs:
  - timestamp: "2026-01-20T14:30:00Z"
    skill: create-skill
    id: "2026-01-20-analyze-codebase"
    status: completed
    log: create-skill/2026-01-20-analyze-codebase.md

summary:
  total_runs: 5
  by_skill:
    create-skill: 3
    refactor: 2
```

### Skill-Level Index (`logs/create-skill/index.yml`)

```yaml
# logs/create-skill/index.yml - All create-skill runs
skill: create-skill
updated: "2026-01-20T14:30:00Z"

runs:
  - id: "2026-01-20-analyze-codebase"
    skill_created: "analyze-codebase"
    status: completed
    timestamp: "2026-01-20T14:30:00Z"
    log: 2026-01-20-analyze-codebase.md
    artifacts: ../runs/create-skill/2026-01-20-analyze-codebase/

# Quick lookup for skills created
skills_created:
  - analyze-codebase
  - generate-report
```

## Dependencies

Tool requirements defined in SKILL.md `allowed-tools`:

| Tool | Purpose |
|------|---------|
| `Read` | Read manifest, registry, template files |
| `Glob` | Find existing skills for uniqueness check |
| `Grep` | Search for existing skill entries |
| `Write(.harmony/skills/*)` | Create skill directory and files |
| `Write(runs/*)` | Write execution state (session recovery) |
| `Write(logs/*)` | Write execution log |
| `Bash(mkdir)` | Create directories |
| `Bash(ln)` | Create symlinks |
| `Bash(cp)` | Copy template files |

## Command-Line Usage

### Basic Invocation

```
/create-skill "analyze-codebase"
```

### With Description

```
/create-skill "analyze-codebase" --description="Analyze codebase structure and patterns"
```

### Specify Archetype

```
/create-skill "format-json" --archetype=utility
```

### Resume Interrupted

```
# Will detect checkpoint and offer to resume
/create-skill "analyze-codebase"
```

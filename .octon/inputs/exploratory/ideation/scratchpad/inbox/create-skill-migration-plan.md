# Migration Planning: Create-Skill Workflow → Skill

## Objective

Plan the migration of `.octon/workflows/skills/create-skill/` to `.octon/skills/create-skill/` following the workflow archetype pattern. This workflow is a scaffolding utility that creates new skills from templates—simpler than the refactor workflow but still requiring careful migration to preserve idempotency and validation behavior.

---

## Context Summary

### Source: Current Workflow Structure

```
.octon/workflows/skills/create-skill/
├── 00-overview.md      # Core description, prerequisites, failure conditions
├── 01-validate-name.md # Format, naming convention, uniqueness checks
├── 02-copy-template.md # Copy template to new skill directory
├── 03-initialize-skill.md # Update SKILL.md with name and placeholders
├── 04-update-registry.md  # Add entry to manifest.yml and registry.yml
├── 05-update-catalog.md   # Add row to catalog.md skills table
└── 06-report-success.md   # Confirm creation and provide next steps
```

Key workflow characteristics:
- 6 sequential phases with idempotency markers (checkpoint files)
- Blocking validation in Phase 1 (format, uniqueness)
- Non-blocking warning for naming convention (verb-noun pattern)
- Creates agentskills.io spec-compliant skill structure
- Updates 3 registration points (manifest, registry, catalog)
- Creates harness symlinks (.claude, .cursor, .codex)

### Target: Skills Infrastructure

```
.octon/skills/create-skill/
├── SKILL.md                    # Core skill definition
└── references/
    ├── behaviors.md            # Phase-by-phase instructions
    ├── io-contract.md          # Inputs, outputs, dependencies
    ├── safety.md               # Tool policies, boundaries
    ├── validation.md           # Acceptance criteria
    └── examples.md             # Usage examples
```

Required integration points:
- `.octon/skills/manifest.yml` — Add skill entry with triggers
- `.octon/skills/registry.yml` — Add extended metadata

---

## Key Design Decisions

### 1. Skill Classification: Utility vs Workflow Archetype

**Decision:** Classify as `metadata.archetype: utility` (not `workflow`).

**Rationale:**
- Unlike `refactor`, this skill has no verification gate that loops back
- Execution is linear and typically completes in seconds
- No checkpoint/resume needed—failures simply restart
- No complex state management required
- Idempotency is handled via existence checks, not checkpoint files

**Implication:** Simpler skill structure without checkpoint.yml or progressive execution state.

### 2. Checkpoint Strategy

**Decision:** Use existence-based idempotency, not checkpoint files.

**Rationale:**
- Each phase naturally checks "is this already done?" via file/entry existence
- Directory exists → skip copy; registry entry exists → skip add
- No need for explicit checkpoint.yml given the atomic nature of each step
- If interrupted, running again safely resumes from incomplete state

**Implementation:**
```markdown
## Phase 2: Copy Template

**Idempotency:** If `.octon/skills/<skill-name>/SKILL.md` exists, skip to Phase 3.
```

### 3. Output Location

**Decision:** No persistent outputs directory—this skill creates infrastructure, not artifacts.

**Rationale:**
- The "output" of this skill is the new skill directory itself
- No analysis artifacts, reports, or logs beyond the creation confirmation
- Log the run to `logs/runs/` for audit trail, but no `outputs/` subdirectory

**Log structure:**
```
.workspace/skills/logs/runs/{timestamp}-create-skill-{skill-name}.md
```

### 4. Symlink Strategy

**Decision:** Make symlink creation optional with a parameter, defaulting to `true`.

**Rationale:**
- Not all projects use all harnesses (.claude, .cursor, .codex)
- Users may prefer manual symlink management
- Default to creating symlinks for convenience

**Parameter:**
```yaml
- name: create_symlinks
  type: boolean
  required: false
  default: true
  description: "Create symlinks in harness directories (.claude, .cursor, .codex)"
```

### 5. Catalog Update Scope

**Decision:** Make catalog update conditional on `.workspace/catalog.md` existence.

**Rationale:**
- Not all workspaces have a catalog.md file
- Phase 5 (Update Catalog) should gracefully skip if no catalog exists
- Warn user that catalog was not updated if file doesn't exist

---

## SKILL.md Design

### Frontmatter

```yaml
---
name: create-skill
description: >
  Scaffold a new skill from template with registry entry, following the
  agentskills.io specification. Validates naming convention, copies template
  structure, initializes SKILL.md, and registers in manifest and registry.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-01-20"
  updated: "2026-01-20"
  archetype: utility
allowed-tools: Read Glob Write Edit Bash(mkdir) Bash(ln)
---
```

### Core Sections

```markdown
# Create Skill

Scaffold a new skill following the agentskills.io specification.

## When to Use

Use this skill when:
- Creating a new skill from scratch
- Need agentskills.io-compliant skill structure
- Want automatic registry and manifest updates

## Quick Start

/create-skill my-new-skill

## Core Workflow

1. **Validate Name** — Check format (kebab-case), convention (verb-noun), uniqueness
2. **Copy Template** — Copy `_scaffold/template/` to `skills/<name>/`
3. **Initialize Skill** — Update SKILL.md frontmatter and placeholders
4. **Update Registry** — Add entry to manifest.yml and registry.yml
5. **Update Catalog** — Add row to catalog.md (if exists)
6. **Report Success** — Confirm creation and provide next steps

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| skill_name | text | yes | — | The skill identifier (kebab-case) |
| create_symlinks | boolean | no | true | Create harness symlinks |

## Naming Convention

Use action-oriented names (verb-noun pattern):
- ✓ `refine-prompt`, `generate-report`, `analyze-codebase`
- ✗ `prompt-refiner`, `report-generator`, `codebase-analyzer`

## Boundaries

- Name must be 1-64 characters, lowercase with hyphens
- Name must be unique in registry
- Cannot overwrite existing skills
- Non-verb names trigger a warning (not blocking)

## When to Escalate

- Skill name already exists → Stop and report error
- Template files missing → Stop and report error
- Cannot write to skills directory → Stop and report error
```

---

## Reference File Mapping

| Workflow File | Target Reference | Content Strategy |
|---------------|------------------|------------------|
| 01-validate-name.md | behaviors.md (Phase 1) | Include format regex, verb list, error messages |
| 02-copy-template.md | behaviors.md (Phase 2) | Include file list, directory structure |
| 03-initialize-skill.md | behaviors.md (Phase 3) | Include placeholder replacement table |
| 04-update-registry.md | behaviors.md (Phase 4) | Include YAML entry templates |
| 05-update-catalog.md | behaviors.md (Phase 5) | Include table row format |
| 06-report-success.md | behaviors.md (Phase 6) | Include success message template |
| 00-overview.md | SKILL.md + io-contract.md | Split between main file and I/O contract |

---

## I/O Contract Definition

### Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| skill_name | string | yes | The skill identifier (kebab-case, 1-64 chars) |
| create_symlinks | boolean | no | Create harness symlinks (default: true) |

### Outputs

| Output | Location | Description |
|--------|----------|-------------|
| Skill directory | `.octon/skills/<skill-name>/` | New skill with SKILL.md and references/ |
| Manifest entry | `.octon/skills/manifest.yml` | Discovery entry with triggers |
| Registry entry | `.octon/skills/registry.yml` | Extended metadata |
| Catalog row | `.workspace/catalog.md` | Skills table row (if catalog exists) |
| Execution log | `.workspace/skills/logs/runs/{ts}-create-skill-{name}.md` | Run audit trail |

### Dependencies

| Type | Path | Description |
|------|------|-------------|
| Template | `.octon/skills/_scaffold/template/` | Source template directory |
| Manifest | `.octon/skills/manifest.yml` | For uniqueness check and registration |
| Registry | `.octon/skills/registry.yml` | For uniqueness check and registration |

---

## Manifest Entry

```yaml
- id: create-skill
  display_name: Create Skill
  path: create-skill/
  summary: "Scaffold new skill from template with registry entry."
  status: active
  tags:
    - scaffolding
    - skill
    - template
  triggers:
    - "create a new skill"
    - "scaffold a skill"
    - "add a skill"
    - "new skill template"
```

## Registry Entry

```yaml
create-skill:
  version: "1.0.0"
  commands:
    - /create-skill
  parameters:
    - name: skill_name
      type: text
      required: true
      description: "The skill identifier (kebab-case, 1-64 chars)"
    - name: create_symlinks
      type: boolean
      required: false
      default: true
      description: "Create symlinks in harness directories"
  requires:
    context:
      - type: directory_exists
        path: ".octon/skills/_scaffold/template/"
        description: "Requires skill template directory"
  depends_on: []
```

---

## Migration Execution Plan

### Phase 1: Create Skill Directory Structure

```bash
mkdir -p .octon/skills/create-skill/references
```

Files to create:
- `.octon/skills/create-skill/SKILL.md`
- `.octon/skills/create-skill/references/behaviors.md`
- `.octon/skills/create-skill/references/io-contract.md`
- `.octon/skills/create-skill/references/safety.md`
- `.octon/skills/create-skill/references/validation.md`
- `.octon/skills/create-skill/references/examples.md`

### Phase 2: Write SKILL.md

Consolidate overview content from `00-overview.md` into the frontmatter and core sections.

### Phase 3: Write behaviors.md

Migrate step-by-step instructions from all 6 workflow files:
- Preserve regex patterns for validation
- Preserve YAML templates for registry entries
- Preserve success message format
- Add idempotency notes inline

### Phase 4: Write io-contract.md

Document inputs, outputs, and dependencies from Phase 2 analysis.

### Phase 5: Write safety.md

Define tool policies:
- `Read`: Unrestricted for validation checks
- `Write`: Limited to `.octon/skills/**`, `.workspace/catalog.md`
- `Edit`: Limited to `.octon/skills/manifest.yml`, `.octon/skills/registry.yml`
- `Bash(mkdir)`: Limited to `.octon/skills/`
- `Bash(ln)`: Limited to harness directories

### Phase 6: Write validation.md

Define acceptance criteria:
- Skill directory exists with correct structure
- SKILL.md has valid frontmatter
- Manifest entry exists with correct id
- Registry entry exists with correct structure
- Symlinks exist (if create_symlinks=true)
- No duplicate skill names

### Phase 7: Write examples.md

Provide worked examples:
- Basic skill creation
- Skill with custom parameters
- Handling naming convention warnings

### Phase 8: Update manifest.yml

Add entry from Manifest Entry section above.

### Phase 9: Update registry.yml

Add entry from Registry Entry section above.

### Phase 10: Validate the Skill

- Run `/create-skill test-skill` to verify scaffolding works
- Verify idempotency by running again
- Clean up test skill

### Phase 11: Deprecate Workflow

Mark `.octon/workflows/skills/create-skill/` for removal:
1. Add deprecation notice to `00-overview.md`
2. Update any references in documentation
3. Schedule removal in next major version

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Symlink creation fails on Windows | Medium | Low | Document Windows compatibility; make symlinks optional |
| Template directory missing | Low | High | Add template existence check in Phase 1 validation |
| Concurrent skill creation race condition | Low | Medium | Use atomic file operations; registry entry as lock |
| Breaking existing workflow references | Low | Medium | Update CLAUDE.md to reference new skill location |

---

## Success Criteria

The migration is successful when:

- [ ] `create-skill` skill scaffolds new skills correctly
- [ ] Naming validation preserves format + convention checks
- [ ] Idempotency works (re-running completes safely)
- [ ] Manifest and registry entries are correct
- [ ] Catalog update is conditional on file existence
- [ ] Execution log is created for each run
- [ ] Original workflow can be deprecated without loss of functionality

---

## Differences from Refactor Migration

| Aspect | Refactor Skill | Create-Skill Skill |
|--------|----------------|-------------------|
| Archetype | `workflow` | `utility` |
| Checkpoint file | Yes (`checkpoint.yml`) | No (existence-based) |
| Verification gate | Yes (mandatory loop-back) | No |
| Output artifacts | Multiple (manifests, reports) | None (creates infrastructure) |
| Complexity | High (6 phases with state) | Low (6 phases, linear) |
| Resume support | Explicit checkpoint-based | Implicit existence-based |
| Scope limits | 50 files, 3 modules | N/A (single skill creation) |

---

## Appendix: Behaviors.md Outline

```markdown
# Create Skill Behaviors

## Phase 1: Validate Name

**Objective:** Ensure skill name is valid, follows conventions, and is unique.

### Format Validation (Blocking)
- Pattern: `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`
- Length: 1-64 characters
- No consecutive hyphens

### Convention Check (Warning Only)
Common action verbs: analyze, build, create, deploy, extract, generate, process, refine, run, validate, transform, convert, export, import, sync

If name doesn't start with a verb, warn but continue.

### Uniqueness Check (Blocking)
- Read `.octon/skills/manifest.yml`
- Check no entry has matching `id`

**Idempotency:** If skill directory already exists, ask user whether to overwrite or abort.

---

## Phase 2: Copy Template

**Objective:** Create skill directory with template files.

### Files to Copy
- `_scaffold/template/SKILL.md` → `<skill-name>/SKILL.md`
- `_scaffold/template/references/behaviors.md` → `<skill-name>/references/behaviors.md`
- `_scaffold/template/references/io-contract.md` → `<skill-name>/references/io-contract.md`
- `_scaffold/template/references/safety.md` → `<skill-name>/references/safety.md`
- `_scaffold/template/references/examples.md` → `<skill-name>/references/examples.md`
- `_scaffold/template/references/validation.md` → `<skill-name>/references/validation.md`

### Directories to Create
- `<skill-name>/scripts/`
- `<skill-name>/assets/`

### Symlinks (if create_symlinks=true)
- `.claude/skills/<skill-name>` → `../../.octon/skills/<skill-name>`
- `.cursor/skills/<skill-name>` → `../../.octon/skills/<skill-name>`
- `.codex/skills/<skill-name>` → `../../.octon/skills/<skill-name>`

**Idempotency:** If `<skill-name>/SKILL.md` exists, skip to Phase 3.

---

## Phase 3: Initialize Skill

**Objective:** Replace placeholders with actual skill name and dates.

### SKILL.md Frontmatter Updates
| Field | Value |
|-------|-------|
| `name` | `<skill-name>` |
| `metadata.created` | Current date (YYYY-MM-DD) |
| `metadata.updated` | Current date (YYYY-MM-DD) |

### Body Updates
- Replace `skill-name` → `<skill-name>` throughout
- Replace `/skill-name` → `/<skill-name>` throughout

### Reference File Updates
Same replacements in all `references/*.md` files.

**Idempotency:** If `name:` field in SKILL.md matches `<skill-name>`, skip to Phase 4.

---

## Phase 4: Update Registry

**Objective:** Add skill to manifest.yml and registry.yml.

### Manifest Entry
[Include YAML template]

### Registry Entry
[Include YAML template]

**Idempotency:** If entry with `id: <skill-name>` exists in manifest.yml, skip to Phase 5.

---

## Phase 5: Update Catalog

**Objective:** Add skill to catalog.md skills table (if file exists).

### Table Row Format
```markdown
| [<skill-name>](./skills/<skill-name>/SKILL.md) | `/<skill-name>` | [TODO: Description] |
```

**Conditional:** If `.workspace/catalog.md` doesn't exist, skip with warning.

**Idempotency:** If table contains `<skill-name>`, skip to Phase 6.

---

## Phase 6: Report Success

**Objective:** Confirm creation and provide next steps.

### Success Message
[Include formatted output from 06-report-success.md]

### Log Entry
Write execution log to `logs/runs/{timestamp}-create-skill-{skill-name}.md`
```

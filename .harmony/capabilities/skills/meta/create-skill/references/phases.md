---
behavior:
  phases:
    - name: "Validate Name"
      steps:
        - "Check format: ^[a-z][a-z0-9]*(-[a-z0-9]+)*$"
        - "Verify length: 1-64 characters"
        - "Check naming convention (verb-noun pattern)"
        - "Verify uniqueness against manifest.yml"
        - "Run alignment-first gate: aligned or extension-proposed"
    - name: "Copy Template"
      steps:
        - "Create directory .harmony/capabilities/skills/<group>/{{skill_name}}/"
        - "Copy SKILL.md from _template/"
        - "Copy references/ directory from _template/"
        - "Create empty scripts/ and assets/ directories"
        - "Create symlinks in harness folders"
    - name: "Initialize Skill"
      steps:
        - "Replace {{skill_name}} placeholders in SKILL.md"
        - "Set metadata.created and metadata.updated dates"
        - "Replace placeholders in all reference files"
    - name: "Update Registry"
      steps:
        - "Add entry to manifest.yml under skills array"
        - "Add entry to registry.yml under skills map"
    - name: "Update Catalog"
      steps:
        - "Add row to .harmony/catalog.md skills table"
    - name: "Report Success"
      steps:
        - "Display creation summary"
        - "List created files and symlinks"
        - "Provide next steps guidance"
        - "Update checkpoint to completed"
        - "Write run log and update indexes"
  goals:
    - "Valid skill directory created"
    - "Registry entries added correctly"
    - "Symlinks functional in all harness folders"
    - "Alignment decision recorded before scaffolding"
    - "Next steps clearly communicated"
    - "Run logged and indexed"
---

# Behavior Reference

Detailed phase-by-phase behavior for the create-skill skill.

## Phase 1: Validate Name

Verify the skill name meets all requirements before any file operations.

### Actions

1. **Format Validation (Blocking)**

   ```regex
   ^[a-z][a-z0-9]*(-[a-z0-9]+)*$
   ```

   - Must be 1-64 characters
   - Lowercase letters, numbers, hyphens only
   - Must not start or end with hyphen
   - No consecutive hyphens

2. **Naming Convention Check (Warning Only)**

   Check if name starts with action verb:
   - `analyze`, `build`, `create`, `deploy`, `extract`
   - `generate`, `process`, `refine`, `run`, `validate`
   - `transform`, `convert`, `export`, `import`, `sync`

   If not verb-noun pattern, warn but continue:
   > "Consider using an action-oriented name starting with a verb (e.g., 'analyze-data' instead of 'data-analyzer')"

3. **Uniqueness Check (Blocking)**

   - Read `.harmony/capabilities/skills/manifest.yml`
   - Check `skills[].id` for existing match
   - If exists, STOP and report

4. **Alignment-First Gate (Blocking)**

   Decide one of:

   - `aligned` — skill fits existing contracts (`skill_sets`, `capabilities`, reference mappings, and `allowed-tools` vocabulary)
   - `extension-proposed` — a spec extension proposal is prepared with synchronized updates

   If neither is true, STOP before file creation and request clarification.

   If `extension-proposed`, include:

   - Deviation note (why existing contracts are insufficient)
   - Proposed contract delta
   - Required docs/template/validation updates
   - Migration impact (if any)

### Error Messages

- Invalid format: "Skill name must be 1-64 lowercase characters with hyphens (e.g., 'refine-prompt')"
- Consecutive hyphens: "Skill name cannot contain consecutive hyphens (--)"
- Already exists: "Skill '{{name}}' already exists in manifest.yml"
- Alignment unresolved: "Skill design must be aligned to current contracts or accompanied by an approved extension proposal"

### Checkpoint Update

```yaml
current_phase: 1
phases:
  1_validate:
    status: completed
    completed_at: "{{timestamp}}"
    skill_name: "{{skill_name}}"
    alignment_decision: "aligned"  # or extension-proposed
    warnings: []  # or naming convention warnings
```

---

## Phase 2: Copy Template

Create the skill directory structure from template.

### Actions

1. **Create Directory**

   ```bash
   mkdir -p .harmony/capabilities/skills/<group>/{{skill_name}}/references
   mkdir -p .harmony/capabilities/skills/<group>/{{skill_name}}/scripts
   mkdir -p .harmony/capabilities/skills/<group>/{{skill_name}}/assets
   ```

2. **Copy Core Files**

   - `.harmony/capabilities/skills/_template/SKILL.md` → `.harmony/capabilities/skills/<group>/{{skill_name}}/SKILL.md`

3. **Copy Reference Files**

   - `_template/references/phases.md` → `<group>/{{skill_name}}/references/phases.md`
   - `_template/references/io-contract.md` → `<group>/{{skill_name}}/references/io-contract.md`
   - `_template/references/safety.md` → `<group>/{{skill_name}}/references/safety.md`
   - `_template/references/examples.md` → `<group>/{{skill_name}}/references/examples.md`
   - `_template/references/validation.md` → `<group>/{{skill_name}}/references/validation.md`

4. **Create Symlinks in Harness Folders**

   ```bash
   ln -s ../../.harmony/capabilities/skills/<group>/{{skill_name}} .claude/skills/{{skill_name}}
   ln -s ../../.harmony/capabilities/skills/<group>/{{skill_name}} .cursor/skills/{{skill_name}}
   ln -s ../../.harmony/capabilities/skills/<group>/{{skill_name}} .codex/skills/{{skill_name}}
   ```

### Verification

- Directory `.harmony/capabilities/skills/<group>/{{skill_name}}/` exists
- File `SKILL.md` exists
- All 5 reference files exist
- Symlinks exist and resolve correctly

### Checkpoint Update

```yaml
current_phase: 2
phases:
  2_copy_template:
    status: completed
    completed_at: "{{timestamp}}"
    files_created:
      - SKILL.md
      - references/phases.md
      - references/io-contract.md
      - references/safety.md
      - references/examples.md
      - references/validation.md
    symlinks_created:
      - .claude/skills/{{skill_name}}
      - .cursor/skills/{{skill_name}}
      - .codex/skills/{{skill_name}}
```

---

## Phase 3: Initialize Skill

Replace placeholders with actual values.

### Actions

1. **Update SKILL.md Frontmatter**

   ```yaml
   name: {{skill_name}}
   metadata:
     created: "{{YYYY-MM-DD}}"
     updated: "{{YYYY-MM-DD}}"
   ```

2. **Replace Body Placeholders**

   - `{{skill_name}}` → `{{skill_name}}`
   - `{{skill_display_name}}` → `{{Skill Name}}` (title case)
   - `/skill-name` → `/{{skill_name}}`
   - `_state/logs/skill-name/<run-id>.md` → `_state/logs/<skill-name>/<run-id>.md`

3. **Update Reference Files**

   - Replace `skill-name` with `{{skill_name}}` in all files
   - Replace `/skill-name` with `/{{skill_name}}`

### Checkpoint Update

```yaml
current_phase: 3
phases:
  3_initialize:
    status: completed
    completed_at: "{{timestamp}}"
    placeholders_replaced: 15
```

---

## Phase 4: Update Registry

Add entries to manifest and registry files.

### Actions

1. **Add to manifest.yml**

   ```yaml
   - id: {{skill_name}}
     display_name: "{{Skill Name - TODO}}"
     path: <group>/{{skill_name}}/
     summary: "[TODO: One-line description for routing]"
     status: active
     tags:
       - "[TODO: category-tag]"
     triggers:
       - "[TODO: natural language trigger]"
   ```

2. **Add to registry.yml**

   ```yaml
   {{skill_name}}:
     version: "1.0.0"
     commands:
       - /{{skill_name}}
     parameters:
       - name: input
         type: text
         required: true
         description: "[TODO: Describe primary input]"
     requires:
       context:
         - type: directory_exists
           path: ".harmony/"
           description: "Requires a harness directory"
     depends_on: []
   ```

### Manifest Entry Fields

| Field | Purpose | Required |
|-------|---------|----------|
| `id` | Unique identifier, matches SKILL.md `name` and manifest `id` | Yes |
| `display_name` | Human-readable display name | Yes |
| `path` | Relative path to skill directory | Yes |
| `summary` | Brief description for routing | Yes |
| `status` | Lifecycle state (active/deprecated/experimental) | No |
| `tags` | Freeform labels for filtering | No |
| `triggers` | Natural language activation phrases | No |

### Registry Entry Fields

| Field | Purpose | Required |
|-------|---------|----------|
| `version` | Semantic version | No |
| `commands` | Slash commands for invocation | Yes |
| `parameters` | Input parameters | No |
| `requires.context` | Context conditions for activation | No |
| `depends_on` | Skill dependencies | No |

### Checkpoint Update

```yaml
current_phase: 4
phases:
  4_update_registry:
    status: completed
    completed_at: "{{timestamp}}"
    manifest_updated: true
    registry_updated: true
```

---

## Phase 5: Update Catalog

Add entry to harness catalog.

### Actions

1. **Add row to catalog.md**

   ```markdown
   | [{{skill_name}}](.harmony/capabilities/skills/<group>/{{skill_name}}/SKILL.md) | `/{{skill_name}}` | [TODO: Description] |
   ```

   If table has placeholder row ("*No skills defined yet*"), replace it.

### Checkpoint Update

```yaml
current_phase: 5
phases:
  5_update_catalog:
    status: completed
    completed_at: "{{timestamp}}"
```

---

## Phase 6: Report Success

Communicate completion and next steps.

### Actions

1. **Display Summary**

   ```markdown
   ## Skill Created: {{skill_name}}

   **Location:** `.harmony/capabilities/skills/<group>/{{skill_name}}/`

   ### Files Created
   - SKILL.md (core definition)
   - references/phases.md
   - references/io-contract.md
   - references/safety.md
   - references/examples.md
   - references/validation.md

   ### Symlinks Created
   - .claude/skills/{{skill_name}}
   - .cursor/skills/{{skill_name}}
   - .codex/skills/{{skill_name}}

   ### Registry Updated
   - manifest.yml: Entry added
   - registry.yml: Entry added

   ### Next Steps
   1. Edit SKILL.md to define description and workflow
   2. Complete TODO items in manifest.yml and registry.yml
   3. Add examples to references/examples.md
   4. Test with `/{{skill_name}} [input]`
   ```

2. **Update Checkpoint to Completed**

3. **Write Run Log**

   Write execution log to `_state/logs/create-skill/{{run_id}}.md`:

   ```markdown
   # Run Log: create-skill

   **Run ID:** {{run_id}}
   **Skill Created:** {{skill_name}}
   **Status:** completed
   **Started:** {{start-timestamp}}
   **Completed:** {{end-timestamp}}

   ## Phases

   | Phase | Status | Completed |
   |-------|--------|-----------|
   | 1. Validate | completed | {{timestamp}} |
   | 2. Copy Template | completed | {{timestamp}} |
   | 3. Initialize | completed | {{timestamp}} |
   | 4. Update Registry | completed | {{timestamp}} |
   | 5. Update Catalog | completed | {{timestamp}} |
   | 6. Report Success | completed | {{timestamp}} |

   ## Files Created

   - .harmony/capabilities/skills/<group>/{{skill_name}}/SKILL.md
   - .harmony/capabilities/skills/<group>/{{skill_name}}/references/phases.md
   - .harmony/capabilities/skills/<group>/{{skill_name}}/references/io-contract.md
   - .harmony/capabilities/skills/<group>/{{skill_name}}/references/safety.md
   - .harmony/capabilities/skills/<group>/{{skill_name}}/references/examples.md
   - .harmony/capabilities/skills/<group>/{{skill_name}}/references/validation.md
   ```

4. **Update Log Indexes**

   - Add entry to `_state/logs/index.yml` (top-level)
   - Add entry to `_state/logs/create-skill/index.yml` (skill-level)

### Checkpoint Update

```yaml
status: completed
current_phase: 6
phases:
  6_report:
    status: completed
    completed_at: "{{timestamp}}"
```

---

## Idempotency Support

On invocation, check for existing checkpoint:

1. Look for `_state/runs/create-skill/*{{skill_name}}*/checkpoint.yml`
2. If found with `status: completed`:
   - "Skill '{{skill_name}}' already exists. Create a different skill?"
3. If found with `status: in_progress`:
   - "Found incomplete scaffold. Resume from Phase {N}? [Y/n]"
4. If skill directory exists but no checkpoint:
   - "Skill directory exists. Overwrite? [y/N]"

### Resume Algorithm

```
1. Read checkpoint.yml (~50 tokens)
2. Check status field (pending | in_progress | completed | failed)
3. Check current_phase for where execution stopped
4. Check resume.instruction for explicit resume guidance

Resume decision matrix:

| checkpoint.status | current_phase | Action |
|-------------------|---------------|--------|
| completed | 6 | "Skill already created. Start new skill?" |
| failed | any | "Previous attempt failed at Phase {N}. Retry?" |
| in_progress | 1-3 | Resume from current_phase |
| in_progress | 4-5 | Resume from current_phase |
| in_progress | 6 | Resume at reporting |
```

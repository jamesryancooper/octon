---
title: Initialize Skill
description: Update SKILL.md and reference files with skill name and initial values.
---

# Step 3: Initialize Skill

> **Deprecated workflow step:** Use the `create-skill` skill for current placeholder conventions and references.

## Input

- `skill-name` from Step 1
- Template files from Step 2

## Actions

### Update SKILL.md Frontmatter

Replace placeholders in `.octon/framework/capabilities/runtime/skills/<group>/<skill-name>/SKILL.md`:

```yaml
---
name: <skill-name>                    # Must match directory name
description: >
  [TODO: One paragraph describing what this skill does...]
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: "[TODO: Author Name]"
  created: "[current date YYYY-MM-DD]"
  updated: "[current date YYYY-MM-DD]"
allowed-tools: Read Glob Grep Write(../{{category}}/*) Write(/.octon/state/evidence/runs/skills/*)
---
```

### Update SKILL.md Body

Replace placeholders:
- `# [Skill Name]` -> `# [Human-Readable Name - TODO]`
- `/skill-name` -> `/<skill-name>`
- `skill-name skill` -> `<skill-name> skill`
- All skill log references -> `/.octon/state/evidence/runs/skills/<skill-name>/<run-id>.md`

### Update Reference Files

For each file in `references/`:
- Replace all `skill-name` with `<skill-name>`
- Replace `/skill-name` with `/<skill-name>`
- Update any skill-specific paths

**Files to update:**
- `references/phases.md`
- `references/io-contract.md`
- `references/safety.md`
- `references/examples.md`
- `references/validation.md`

### Set Dates

Set to current date in ISO format (YYYY-MM-DD):
- `metadata.created`
- `metadata.updated`

## Verification

- Frontmatter `name` field equals `<skill-name>`
- `metadata.created` has valid date
- `metadata.updated` has valid date
- All `skill-name` placeholders replaced in SKILL.md
- All `skill-name` placeholders replaced in reference files
- Command references use `/<skill-name>`

## Idempotency

**Check:** Is SKILL.md already initialized?
- [ ] Frontmatter `name` field matches `<skill-name>`
- [ ] `metadata.created` field has valid date
- [ ] Reference files have `<skill-name>` (not `skill-name`)

**If Already Complete:**
- Verify initialization is correct
- Skip to next step

**Marker:** `checkpoints/create-skill/<skill-name>/03-initialize.complete`

## Output

- Initialized `SKILL.md` with correct name and dates
- Initialized reference files with correct skill name
- Ready for user customization
- Proceed to Step 4

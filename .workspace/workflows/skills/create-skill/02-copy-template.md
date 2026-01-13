---
title: Copy Template
description: Copy skill template to new skill directory.
---

# Step 2: Copy Template

## Input

- Validated `skill-id` from Step 1

## Actions

```text
1. Create directory: skills/<skill-id>/
2. Copy skills/_template/SKILL.md to skills/<skill-id>/SKILL.md
3. Create empty directories:
   - skills/<skill-id>/templates/
   - skills/<skill-id>/reference/
   - skills/<skill-id>/scripts/
4. Create symlinks in harness folders:
   - .claude/skills/<skill-id> -> ../../.workspace/skills/<skill-id>
   - .cursor/skills/<skill-id> -> ../../.workspace/skills/<skill-id>
   - .codex/skills/<skill-id> -> ../../.workspace/skills/<skill-id>
```

## Verification

- Directory `skills/<skill-id>/` exists
- File `skills/<skill-id>/SKILL.md` exists
- Subdirectories created (templates/, reference/, scripts/)

## Output

- New skill directory with template files
- Proceed to Step 3

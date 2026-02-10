---
title: Customize Templates
description: Replace placeholders with context-specific values.
---

# Step 6: Customize Templates

Replace placeholders based on analysis and user input. Wildcards (`*`) indicate repeatable items.

## Placeholder mapping

| File | Placeholders |
|------|-------------|
| `scope.md` | `{{TARGET_NAME}}`, `{{SCOPE_DESCRIPTION}}`, `{{IN_SCOPE_*}}`, `{{OUT_OF_SCOPE_*}}`, `{{LOCAL_DECISION_*}}`, `{{ESCALATE_DECISION_*}}`, `{{ADJACENT_AREAS}}` |
| `conventions.md` | `{{NAMING_CONVENTION}}` (kebab-case, PascalCase, snake_case based on detected patterns) |
| `START.md` | `{{PREREQUISITES}}` (dependencies, env vars, build steps) |
| `quality/complete.md` | `{{CUSTOM_QUALITY_CHECK_*}}` (enable/disable based on detected tooling) |
| `continuity/tasks.json` | `{{DATE}}`, `{{FIRST_TASK_ID}}`, `{{FIRST_TASK_DESCRIPTION}}` |
| `continuity/log.md` | `{{DATE}}`, `{{DIRECTORY_TYPE}}`, `{{BRIEF_SCOPE}}`, `{{KEY_FINDING_*}}`, `{{FIRST_TASK}}` |

## Initial tasks by directory state

| Directory State | Initial Tasks |
|-----------------|---------------|
| Empty/new | "Define structure", "Create initial content" |
| Has code | "Document current state", "Identify priorities" |
| Has docs | "Audit existing content", "Identify gaps" |

## Idempotency

**Check:** Are templates already customized?
- [ ] No `{{placeholder}}` patterns remain in files
- [ ] `scope.md` has target-specific content

**If Already Complete:**
- Verify no placeholders remain
- Skip to next step

**Marker:** `checkpoints/create-harness/<target>/06-customize.complete`

# Workflow Template

This directory contains the canonical template for creating new workflows.

## Files

| File | Purpose |
|------|---------|
| `WORKFLOW.md` | Workflow entry point with spec-compliant frontmatter |
| `01-step.md` | Generic step template with idempotency section |
| `NN-verify.md` | Mandatory verification gate template |

## Usage

When creating a new workflow:

1. Copy this template directory to the target location
2. Rename files according to your workflow steps
3. Replace all `[placeholder]` values with actual content
4. Update the step numbering (01, 02, 03... NN)
5. Ensure the final step is always verification

## Enhanced Frontmatter Schema

The `WORKFLOW.md` template includes spec-compliant fields plus Harmony extensions:

```yaml
---
# Core spec fields (required)
name: "[workflow-id]"
description: "[What this workflow does and when to use it]"
steps:
  - id: "[step-id]"
    file: 01-step-name.md
    description: "[Brief step description]"
# Harmony extensions (optional)
access: human|agent
version: "1.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
---
```

## Required Sections in Steps

Each step file must include:

1. **Input** - What the step receives
2. **Purpose** - Why the step exists
3. **Actions** - What to do
4. **Idempotency** - Completion detection and skip logic
5. **Output** - What the step produces
6. **Proceed When** - Conditions to move forward

## Verification Gate

Every workflow must end with a verification step that:

- Confirms all objectives were achieved
- Documents results in a table format
- Prevents completion if any criterion fails
- Includes its own idempotency check

## See Also

- **Create workflow:** `.harmony/orchestration/workflows/meta/create-workflow/`
- **Evaluate workflow:** `.harmony/orchestration/workflows/meta/evaluate-workflow/`
- **Gap fixes guide:** `.harmony/cognition/context/workflow-gaps.md`
- **Quality criteria:** `.harmony/cognition/context/workflow-quality.md`

# Workflow Template

This directory contains the canonical template for creating new workflows.

## Files

| File | Purpose |
|------|---------|
| `00-overview.md` | Workflow entry point with enhanced frontmatter |
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

The `00-overview.md` template includes gap-fix fields:

```yaml
---
title: "[Title]"
description: "[Max 160 chars]"
access: human|agent
version: "1.0.0"           # Semantic versioning
depends_on: []              # Cross-workflow dependencies
checkpoints:
  enabled: true
  storage: ".workspace/progress/checkpoints/"
parallel_steps: []          # Steps safe to run in parallel
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

- **Create workflow:** `.harmony/workflows/workflows/create-workflow/`
- **Evaluate workflow:** `.harmony/workflows/workflows/evaluate-workflow/`
- **Gap fixes guide:** `.harmony/context/workflow-gaps.md`
- **Quality criteria:** `.harmony/context/workflow-quality.md`

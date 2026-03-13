---
title: Update Workflow
description: Update a canonical workflow and repair workflow README drift.
access: agent
argument-hint: <path>
---

# Update Workflow `/update-workflow`

Update the canonical workflow behind a workflow surface and regenerate or repair
the resulting workflow README.

## Usage

```text
/update-workflow <path>
/update-workflow <path> --from-report <assessment-path>
```

## Implementation

Execute the canonical workflow at:

- `/.octon/orchestration/runtime/workflows/meta/update-workflow/`

The update flow should:

1. Audit the current canonical workflow and guide
2. Plan workflow-level changes
3. Apply the workflow changes
4. Regenerate or repair the workflow README
5. Revalidate the full surface

## Output

- Updated canonical workflow contract and assets
- Aligned workflow README
- Validation receipt showing drift closure

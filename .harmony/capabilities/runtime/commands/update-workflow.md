---
title: Update Workflow
description: Update a canonical pipeline and repair workflow projection drift.
access: agent
argument-hint: <path>
---

# Update Workflow `/update-workflow`

Update the canonical pipeline behind a workflow surface and regenerate or repair
the resulting workflow projection.

## Usage

```text
/update-workflow <path>
/update-workflow <path> --from-report <assessment-path>
```

## Implementation

Execute the canonical pipeline at:

- `/.harmony/orchestration/runtime/pipelines/meta/update-workflow/`

The update flow should:

1. Audit the current canonical pipeline and projection
2. Plan pipeline-level changes
3. Apply the pipeline changes
4. Regenerate or repair the workflow projection
5. Revalidate the full surface

## Output

- Updated canonical pipeline contract and assets
- Aligned workflow projection
- Validation receipt showing drift closure

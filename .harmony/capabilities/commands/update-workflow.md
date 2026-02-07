---
title: Update Workflow
description: Modify an existing workflow to add features or fix gaps.
access: human
argument-hint: <path>
---

# Update Workflow `/update-workflow`

Modify an existing workflow to add gap remediation features, new steps, or improve quality. This is a **mutating operation** that modifies workflow files in place.

## Usage

```text
/update-workflow <path>
/update-workflow <path> --gaps-only
/update-workflow <path> --from-report <assessment-path>
```

**Examples:**
```text
/update-workflow .harmony/workflows/refactor/
/update-workflow .workspace/workflows/my-workflow/ --gaps-only
```

## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `path` | Path to workflow directory | Required |
| `--gaps-only` | Only apply gap remediation fixes | false |
| `--from-report` | Use existing evaluation report | None |

## Implementation

Execute the workflow in `.harmony/workflows/workflows/update-workflow/`.

Steps:

1. Audit current - Read and analyze existing workflow
2. Identify gaps - Compare against requirements
3. Plan changes - Create ordered change manifest
4. Execute changes - Apply modifications
5. Verify update - Validate updated workflow

## What Gets Updated

### Gap Remediation (--gaps-only)

- Add `version`, `depends_on`, `checkpoints`, `parallel_steps` to frontmatter
- Add `## Idempotency` sections to all step files
- Add `## Version History` section to overview
- Increment version appropriately

### Full Update

All gap remediation plus:
- Fix content issues (vague error messages, missing sections)
- Fix structural issues (broken links, naming inconsistencies)
- Add missing prerequisites/failure conditions

## Version Increment

| Change Type | Bump | Example |
|-------------|------|---------|
| Gap fields only | Patch | 1.0.0 -> 1.0.1 |
| New sections | Minor | 1.0.0 -> 1.1.0 |
| Structure changes | Major | 1.0.0 -> 2.0.0 |

## Recommended Workflow

1. **Evaluate first:**
   ```text
   /evaluate-workflow <path>
   ```
   Review the assessment report to understand current state.

2. **Apply updates:**
   ```text
   /update-workflow <path>
   ```
   Review proposed changes before confirming.

3. **Verify:**
   ```text
   /evaluate-workflow <path>
   ```
   Confirm improved score.

## Key Features

- **Safe:** Creates backup before modifications (optional)
- **Resumable:** Tracks progress for interrupted updates
- **Incremental:** Applies changes one at a time
- **Verified:** Final step validates all changes applied

## References

- **Workflow:** `.harmony/workflows/workflows/update-workflow/`
- **Evaluate First:** `.harmony/commands/evaluate-workflow.md`
- **Gap Guide:** `.harmony/context/workflow-gaps.md`
- **Quality Criteria:** `.harmony/context/workflow-quality.md`

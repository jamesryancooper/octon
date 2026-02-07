---
title: Update Workflow
description: Modify an existing workflow to add features or fix gaps.
access: human
version: "1.0.0"
depends_on:
  - workflow: workflows/workflows/evaluate-workflow
    condition: "optional but recommended to run first"
checkpoints:
  enabled: true
  storage: ".workspace/progress/checkpoints/"
parallel_steps: []
---

# Update Workflow: Overview

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

## Target

Existing workflow directory to modify.

## Prerequisites

- Valid path to workflow directory
- `00-overview.md` exists in directory
- Files are writable
- Recommended: Run `/evaluate-workflow` first to identify issues

## Failure Conditions

- Path does not exist -> STOP, report "Path not found: <path>"
- No `00-overview.md` found -> STOP, report "Not a valid workflow directory"
- Files are read-only -> STOP, report "Cannot write to <path>"
- Workflow is in published package -> STOP, suggest copying first

## Steps

1. [Audit current](./01-audit-current.md) - Read and parse existing workflow
2. [Identify gaps](./02-identify-gaps.md) - Compare against requirements
3. [Plan changes](./03-plan-changes.md) - Create change manifest
4. [Execute changes](./04-execute-changes.md) - Apply modifications
5. [Verify update](./05-verify-update.md) - Validate updated workflow

## Verification Gate

Update Workflow is NOT complete until:
- [ ] All planned changes are applied
- [ ] Workflow still validates (frontmatter, structure)
- [ ] Version is incremented appropriately
- [ ] Version history is updated with change summary

## Version Increment Guidelines

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Add gap fix fields only | Patch (0.0.X) | 1.0.0 -> 1.0.1 |
| Add new step or section | Minor (0.X.0) | 1.0.0 -> 1.1.0 |
| Change step structure | Major (X.0.0) | 1.0.0 -> 2.0.0 |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01-14 | Initial version |

## References

- **Evaluate first:** `.harmony/workflows/workflows/evaluate-workflow/`
- **Gap guide:** `.harmony/context/workflow-gaps.md`
- **Quality criteria:** `.harmony/context/workflow-quality.md`

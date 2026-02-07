---
title: Evaluate Workflow
description: Assess an existing workflow against quality criteria and gap coverage.
access: human
version: "1.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".workspace/progress/checkpoints/"
parallel_steps:
  - group: "assessment"
    steps: ["02-assess-structure", "03-assess-gap-coverage"]
    join_at: "04-assess-quality"
---

# Evaluate Workflow: Overview

Assess an existing workflow for structure compliance, gap coverage, and content quality. This is a **read-only assessment** that produces a report without modifying the workflow.

## Usage

```text
/evaluate-workflow <path>
```

**Examples:**
```text
/evaluate-workflow .harmony/workflows/refactor/
/evaluate-workflow .workspace/workflows/custom-deploy/
```

## Target

Existing workflow directory containing `00-overview.md` and step files.

## Prerequisites

- Valid path to workflow directory
- `00-overview.md` exists in directory
- Directory contains at least one step file

## Failure Conditions

- Path does not exist -> STOP, report "Path not found: <path>"
- No `00-overview.md` found -> STOP, report "Not a valid workflow directory"
- Path is a file, not directory -> STOP, report "Expected directory, got file"
- Cannot read files -> STOP, report "Permission denied: <path>"

## Steps

1. [Read workflow](./01-read-workflow.md) - Load and parse overview and step files
2. [Assess structure](./02-assess-structure.md) - Check file organization and naming
3. [Assess gap coverage](./03-assess-gap-coverage.md) - Check for gap remediation features
4. [Assess quality](./04-assess-quality.md) - Evaluate content quality and completeness
5. [Generate report](./05-generate-report.md) - Produce assessment report with grade

## Output

Assessment report with:
- Overall grade (A/B/C/D/F)
- Structure compliance score (0-25 points)
- Gap coverage score (0-20 points)
- Content quality score (0-25 points)
- Maintainability score (0-10 points)
- Specific recommendations

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01-14 | Initial version |

## References

- **Quality criteria:** `.harmony/context/workflow-quality.md`
- **Gap checklist:** `.harmony/context/workflow-gaps.md`
- **Update workflow:** `.harmony/workflows/workflows/update-workflow/` (to fix issues)

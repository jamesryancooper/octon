---
title: Evaluate Workflow
description: Assess a directory or single-file workflow with the shared workflow scorer.
access: human
version: "2.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps:
  - group: "assessment"
    steps: ["02-assess-structure", "03-assess-gap-coverage"]
    join_at: "04-assess-quality"
---

# Evaluate Workflow: Overview

Assess an existing workflow artifact using the shared workflow scorer. This is a **read-only assessment** that produces a human-readable report from the same machine-readable scoring model used by the Workflow System Audit.

## Usage

```text
/evaluate-workflow <path>
```

**Examples:**
```text
/evaluate-workflow .harmony/orchestration/runtime/workflows/refactor/refactor/
/evaluate-workflow .harmony/orchestration/runtime/workflows/projects/create-project.md
```

## Target

- Directory workflow with `WORKFLOW.md`
- Single-file workflow `.md`

## Prerequisites

- Valid path to a workflow artifact
- Directory workflows have `WORKFLOW.md`
- Single-file workflows have workflow frontmatter and inline flow

## Failure Conditions

- Path does not exist -> STOP, report "Path not found: <path>"
- Directory path missing `WORKFLOW.md` -> STOP, report "Not a valid workflow directory"
- File path is not a workflow markdown file -> STOP, report "Not a valid single-file workflow"
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
- Shared category scores from the workflow-quality rubric
- Specific recommendations
- Validation-ready issue metadata from the shared scorer

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2026-03-06 | Switched to shared scorer, `WORKFLOW.md`, and single-file workflow support |
| 1.0.0 | 2025-01-14 | Initial version |

## References

- **Quality criteria:** `.harmony/cognition/runtime/context/workflow-quality.md`
- **Gap checklist:** `.harmony/cognition/runtime/context/workflow-gaps.md`
- **Shared scorer:** `.harmony/orchestration/runtime/workflows/_ops/scripts/audit-workflow-system.sh`
- **Update workflow:** `.harmony/orchestration/runtime/workflows/meta/update-workflow/` (to fix issues)

## Required Outcome

- [ ] Workflow artifact is parsed successfully
- [ ] Shared score output is rendered into a human-readable report
- [ ] Recommendations identify the most important gaps without mutating the target

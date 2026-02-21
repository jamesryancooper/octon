---
title: Evaluate Workflow
description: Assess a workflow against quality criteria and gap coverage.
access: human
argument-hint: <path>
---

# Evaluate Workflow `/evaluate-workflow`

Assess an existing workflow for structure compliance, gap coverage, and content quality. This is a **read-only operation** that produces an assessment report without modifying the workflow.

## Usage

```text
/evaluate-workflow <path>
```

**Examples:**
```text
/evaluate-workflow .harmony/orchestration/runtime/workflows/refactor/refactor/
/evaluate-workflow .harmony/orchestration/runtime/workflows/my-workflow/
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `path` | Path to workflow directory containing `00-overview.md` |

## Implementation

Execute the workflow in `.harmony/orchestration/runtime/workflows/meta/evaluate-workflow/`.

Steps:

1. Read workflow - Load and parse files
2. Assess structure - Check file organization
3. Assess gap coverage - Check for gap remediation features
4. Assess quality - Evaluate content quality
5. Generate report - Produce assessment with grade

## Output

Assessment report with:

- **Overall Grade:** A/B/C/D/F (based on 100-point scale)
- **Structure Score:** 0-25 points
- **Frontmatter Score:** 0-20 points
- **Content Score:** 0-25 points
- **Gap Coverage Score:** 0-20 points
- **Maintainability Score:** 0-10 points
- **Specific Recommendations:** Prioritized improvement actions

## Grade Interpretation

| Grade | Score | Meaning |
|-------|-------|---------|
| A | 90-100 | Exemplary: No action needed |
| B | 80-89 | Good: Address minor issues when convenient |
| C | 70-79 | Adequate: Prioritize gap fixes |
| D | 60-69 | Below Standard: Run `/update-workflow` |
| F | 0-59 | Failing: Major restructuring needed |

## Key Features

- **Non-Destructive:** Read-only assessment, no modifications
- **Comprehensive:** Evaluates structure, content, and gap coverage
- **Actionable:** Provides specific recommendations
- **Gradable:** Clear scoring system for comparison

## Recommended Follow-Up

- Grade C or lower: Run `/update-workflow <path>` to address gaps
- Grade B: Review recommendations, apply selectively
- Grade A: Maintain current quality

## References

- **Workflow:** `.harmony/orchestration/runtime/workflows/meta/evaluate-workflow/`
- **Quality Criteria:** `.harmony/cognition/runtime/context/workflow-quality.md`
- **Gap Checklist:** `.harmony/cognition/runtime/context/workflow-gaps.md`
- **Update Workflow:** `.harmony/capabilities/runtime/commands/update-workflow.md`

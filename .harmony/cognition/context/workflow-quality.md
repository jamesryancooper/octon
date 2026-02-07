---
title: Workflow Quality Criteria
description: Grading rubric and quality standards for workflows.
---

# Workflow Quality Criteria

This document defines the quality standards used to evaluate workflows.

## Grading Rubric

| Grade | Score | Description |
|-------|-------|-------------|
| **A** | 90-100% | Exemplary: All requirements met, gap fixes complete, well-documented |
| **B** | 80-89% | Good: Most requirements met, minor gaps or improvements possible |
| **C** | 70-79% | Adequate: Core functionality present, notable gaps or issues |
| **D** | 60-69% | Below Standard: Significant issues, missing critical elements |
| **F** | <60% | Failing: Does not meet minimum requirements |

---

## Evaluation Categories

### 1. Structure Compliance (25 points)

| Criterion | Points | Check |
|-----------|--------|-------|
| `00-overview.md` exists | 5 | File present in workflow directory |
| Numbered step files | 5 | Files follow `NN-name.md` pattern |
| Final step is verification | 5 | Last numbered file is verify/validation |
| Consistent file naming | 5 | All files use kebab-case |
| README or documentation | 5 | Purpose documented somewhere |

### 2. Frontmatter Compliance (20 points)

| Criterion | Points | Check |
|-----------|--------|-------|
| `title` field present | 4 | Non-empty string |
| `description` field present | 4 | Non-empty, max 160 chars |
| `access` field present | 4 | Value is `human` or `agent` |
| `version` field present | 4 | Semantic version format |
| Gap fix fields present | 4 | `depends_on`, `checkpoints`, `parallel_steps` |

### 3. Content Quality (25 points)

| Criterion | Points | Check |
|-----------|--------|-------|
| Prerequisites defined | 5 | Clear list of requirements |
| Failure conditions defined | 5 | At least one STOP condition |
| Steps are actionable | 5 | Each step has concrete Actions |
| Verification criteria clear | 5 | Checklist items are testable |
| Error messages helpful | 5 | Specific, actionable error text |

### 4. Gap Coverage (20 points)

| Criterion | Points | Check |
|-----------|--------|-------|
| Idempotency sections | 4 | Each step has `## Idempotency` |
| Dependencies declared | 4 | `depends_on` properly configured |
| Checkpoints configured | 4 | `checkpoints.enabled: true` with storage |
| Version history present | 4 | Table with at least initial version |
| Parallel steps identified | 4 | `parallel_steps` analyzed (even if empty) |

### 5. Maintainability (10 points)

| Criterion | Points | Check |
|-----------|--------|-------|
| Steps are focused | 3 | Each step does one thing |
| References are valid | 3 | Links resolve to real files |
| No dead code/steps | 2 | All steps reachable from overview |
| Consistent formatting | 2 | Headings, lists, code blocks consistent |

---

## Scoring Formula

```
Total Score = Structure + Frontmatter + Content + Gap Coverage + Maintainability
            = 25 + 20 + 25 + 20 + 10
            = 100 points maximum
```

Grade boundaries:
- A: 90-100
- B: 80-89
- C: 70-79
- D: 60-69
- F: 0-59

---

## Quick Assessment Checklist

For rapid workflow evaluation:

### Must Have (Failing without these)
- [ ] `00-overview.md` exists
- [ ] At least one step file exists
- [ ] Verification/final step exists
- [ ] `title` in frontmatter
- [ ] `description` in frontmatter

### Should Have (Below standard without these)
- [ ] `access` in frontmatter
- [ ] `version` in frontmatter
- [ ] Prerequisites section
- [ ] Failure conditions section
- [ ] Steps section with links

### Nice to Have (Good to exemplary)
- [ ] All gap fix fields
- [ ] Idempotency in every step
- [ ] Version history section
- [ ] Parallel steps analyzed
- [ ] Comprehensive error messages

---

## Common Issues and Fixes

### Issue: Missing verification step

**Problem:** Workflow declares completion without verification gate.

**Fix:** Add `NN-verify.md` as final step with:
- Verification checklist
- Results documentation format
- Failure handling procedure

### Issue: No idempotency sections

**Problem:** Steps don't handle re-runs gracefully.

**Fix:** Add to each step file:
```markdown
## Idempotency

**Check:** [How to detect completion]
**If Already Complete:** [Skip or cleanup]
**Marker:** `checkpoints/<workflow>/<step>.complete`
```

### Issue: Vague failure conditions

**Problem:** "If error occurs -> STOP" doesn't help recovery.

**Fix:** Make conditions specific:
```markdown
## Failure Conditions

- Target directory already exists -> STOP, use /update-workflow instead
- Invalid ID format -> STOP, ID must be kebab-case (e.g., my-workflow)
- Template not found -> STOP, verify .harmony/workflows/_template/ exists
```

### Issue: Steps not actionable

**Problem:** Steps describe what should happen but not how.

**Fix:** Add concrete Actions:
```markdown
## Actions

1. Run `ls <target>` to check if directory exists
2. If exists, read `00-overview.md` to verify it's a workflow
3. Parse frontmatter using YAML parser
4. Check `version` field matches semantic format
```

### Issue: Missing gap fix fields

**Problem:** Frontmatter missing `version`, `depends_on`, etc.

**Fix:** Add complete frontmatter:
```yaml
---
title: "My Workflow"
description: "Brief description."
access: human
version: "1.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".workspace/progress/checkpoints/"
parallel_steps: []
---
```

---

## Assessment Report Template

```markdown
# Workflow Assessment: [Workflow Name]

**Path:** `[path/to/workflow/]`
**Date:** YYYY-MM-DD
**Evaluator:** [agent/human]

## Scores

| Category | Score | Max | Notes |
|----------|-------|-----|-------|
| Structure | X | 25 | |
| Frontmatter | X | 20 | |
| Content | X | 25 | |
| Gap Coverage | X | 20 | |
| Maintainability | X | 10 | |
| **Total** | **X** | **100** | **Grade: X** |

## Gap Coverage Detail

| Gap | Status | Notes |
|-----|--------|-------|
| Idempotency | Full/Partial/None | |
| Dependencies | Full/Partial/None/N/A | |
| Branching | Full/Partial/None/N/A | |
| Checkpoints | Full/Partial/None | |
| Versioning | Full/Partial/None | |
| Parallel | Full/Partial/None/N/A | |

## Recommendations

1. [Priority 1 recommendation]
2. [Priority 2 recommendation]
3. [Priority 3 recommendation]

## Summary

[Overall assessment and next steps]
```

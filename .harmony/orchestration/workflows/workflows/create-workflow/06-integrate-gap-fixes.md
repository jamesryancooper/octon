---
title: Integrate Gap Fixes
description: Add idempotency, checkpoints, versioning, and parallel support.
---

# Step 6: Integrate Gap Fixes

## Input

- Customized workflow files from Step 5
- Requirements from Step 2
- Template selection from Step 3 (parallel groups)

## Purpose

Ensure the new workflow incorporates all gap remediation features for reliability, resumability, and maintainability.

## Actions

### 6.1 Add Version Field

In `00-overview.md` frontmatter, ensure:
```yaml
version: "1.0.0"
```

### 6.2 Add Dependency Declarations

If the workflow depends on other workflows:
```yaml
depends_on:
  - workflow: <dependency-path>
    condition: "<when dependency is required>"
```

If no dependencies, ensure empty array:
```yaml
depends_on: []
```

### 6.3 Add Checkpoint Configuration

In `00-overview.md` frontmatter:
```yaml
checkpoints:
  enabled: true
  storage: ".workspace/progress/checkpoints/"
```

### 6.4 Add Idempotency Sections

For EACH step file, ensure `## Idempotency` section exists with:

```markdown
## Idempotency

**Check:** [Specific check for this step]
- [ ] [Condition that indicates completion]

**If Already Complete:**
- [Skip action or cleanup action]

**Marker:** `checkpoints/<workflow-id>/<step>.complete`
```

Customize the check for each step:
- Validation steps: Check if validated data exists
- Creation steps: Check if artifact exists
- Transformation steps: Check if output exists
- Verification steps: Check if results logged

### 6.5 Identify and Declare Parallel Steps

Review step dependencies:

```text
For each pair of steps (N, N+1):
  Q1: Does step N+1 read files that step N writes?
  Q2: Does step N+1 use output variables from step N?
  Q3: If step N fails, must step N+1 be skipped?

  If all answers are NO: Steps can potentially run in parallel
```

If parallel steps identified, add to frontmatter:
```yaml
parallel_steps:
  - group: "<descriptive-group-name>"
    steps: ["<step-a-filename>", "<step-b-filename>"]
    join_at: "<step-that-needs-both>"
```

If no parallel opportunities:
```yaml
parallel_steps: []
```

### 6.6 Add Version History Section

Add to `00-overview.md` before References:
```markdown
## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | <today's date> | Initial version |
```

### 6.7 Add Parallel Execution Notes (if applicable)

For steps in parallel groups, add to step file:
```markdown
## Parallel Execution

**Group:** <group-name>
**Can run with:** <other-step-filename>
**Join point:** <join-step-filename>

**Independence Check:**
- [ ] This step does not write to files read by parallel steps
- [ ] This step does not depend on outputs from parallel steps
- [ ] Failure in this step does not invalidate parallel steps
```

## Idempotency

**Check:** Are gap fixes already integrated?
- [ ] `version` field present in overview frontmatter
- [ ] `depends_on` field present (even if empty)
- [ ] `checkpoints` field present with storage path
- [ ] `parallel_steps` field present (even if empty)
- [ ] Each step file has `## Idempotency` section
- [ ] Version History section present

**If Already Complete:**
- Verify all fields are present and valid
- Skip to next step if complete
- Resume integration if partial

**Marker:** `checkpoints/create-workflow/<workflow-id>/06-gaps.complete`

## Gap Fix Verification Checklist

Before proceeding, confirm:

- [ ] Overview frontmatter has `version: "X.Y.Z"`
- [ ] Overview frontmatter has `depends_on: [...]`
- [ ] Overview frontmatter has `checkpoints: {enabled: true, storage: "..."}`
- [ ] Overview frontmatter has `parallel_steps: [...]`
- [ ] Overview body has `## Version History` section
- [ ] Every step file has `## Idempotency` section
- [ ] Idempotency sections have Check, If Already Complete, Marker
- [ ] Parallel steps (if any) have Independence Check

## Output

- All gap fix fields present in frontmatter
- All step files have idempotency sections
- Parallel opportunities documented
- Version history initialized

## Proceed When

- [ ] All items in Gap Fix Verification Checklist pass
- [ ] No missing gap fix fields

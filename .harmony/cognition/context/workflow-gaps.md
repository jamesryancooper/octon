---
title: Workflow Gap Remediation Guide
description: Reference for implementing workflow architecture gap fixes.
---

# Workflow Gap Remediation Guide

This document explains the six identified gaps in workflow architecture and how to address them.

## Gap Summary

| Gap | Problem | Solution |
|-----|---------|----------|
| Idempotency | Re-running steps may cause issues | Completion checks + skip logic |
| Dependencies | Unclear workflow ordering | `depends_on` frontmatter field |
| Branching | All workflows strictly linear | Conditional branch notation |
| Checkpoints | Can't resume interrupted workflows | State persistence + markers |
| Versioning | No change tracking | `version` field + history section |
| Parallel | Sequential even when unnecessary | `parallel_steps` declaration |

---

## 1. Idempotency

### Problem

When a workflow is interrupted and resumed, or when a step is re-run, it may:
- Duplicate work already done
- Fail on already-existing artifacts
- Corrupt partial state

### Solution

Add an `## Idempotency` section to every step file:

```markdown
## Idempotency

**Check:** [How to detect if this step already ran]
- [ ] File `X` exists
- [ ] Registry contains entry for `Y`

**If Already Complete:**
- Skip to next step
- OR: Clean up by [action] before re-running

**Marker:** `checkpoints/<workflow-id>/<step>.complete`
```

### Implementation Checklist

- [ ] Each step has `## Idempotency` section
- [ ] Completion checks are specific and testable
- [ ] Skip logic is clear (skip vs cleanup-then-run)
- [ ] Marker file path follows convention

---

## 2. Cross-Workflow Dependencies

### Problem

Some workflows require others to complete first, but this isn't documented. Agents may:
- Start workflows out of order
- Miss prerequisite setup
- Encounter cryptic failures

### Solution

Add `depends_on` array to overview frontmatter:

```yaml
depends_on:
  - workflow: workspace/create-workspace
    condition: "target .workspace/ must exist"
  - workflow: skills/create-skill
    condition: "optional, only if workflow uses skills"
```

### Resolution Logic

Before executing a workflow:
1. Parse `depends_on` array
2. For each dependency, check if condition is satisfied
3. If not satisfied, either:
   - Execute dependency workflow first
   - Report blocker and suggest manual execution

### Implementation Checklist

- [ ] `depends_on` field present (can be empty `[]`)
- [ ] Each dependency has `workflow` path and `condition`
- [ ] Conditions are testable statements
- [ ] Circular dependencies avoided

---

## 3. Conditional Branching

### Problem

All workflows execute steps linearly, but some need:
- Different paths based on input
- Skip steps that don't apply
- Multiple routes to same outcome

### Solution

Add branch notation to Steps section:

```markdown
## Steps

1. [Validate prerequisites](./01-validate.md)
2. [Analyze context](./02-analyze.md)
3. **Branch:**
   - If complex workflow: [Design parallel structure](./03a-design-parallel.md)
   - If simple workflow: [Design linear structure](./03b-design-linear.md)
4. [Generate files](./04-generate.md) _(branches merge here)_
```

And in step files:

```markdown
## Conditions

**Branch A:** If [condition A]
- Proceed to [step X]

**Branch B:** If [condition B]
- Proceed to [step Y]

**Default:** If neither condition
- Proceed to next numbered step
```

### Implementation Checklist

- [ ] Branch points clearly marked in overview
- [ ] Branch conditions are mutually exclusive or prioritized
- [ ] Merge points identified
- [ ] All branches eventually reach verification

---

## 4. Checkpoints / Resumption

### Problem

Long workflows may be interrupted by:
- Session timeouts
- Errors mid-execution
- User pauses

Without checkpoints, the workflow must restart from the beginning.

### Solution

Add checkpoint configuration to frontmatter:

```yaml
checkpoints:
  enabled: true
  storage: ".workspace/progress/checkpoints/"
```

Checkpoint storage structure:

```
.workspace/progress/checkpoints/
├── <workflow-id>/
│   ├── state.json           # Current step, branch, variables
│   ├── 01-step.complete     # Marker per completed step
│   ├── 02-step.complete
│   └── context.json         # Captured context for resumption
```

State schema:

```json
{
  "workflow": "workflows/create-workflow",
  "started_at": "2025-01-14T10:00:00Z",
  "current_step": "03-design-structure",
  "branch": "parallel",
  "variables": {
    "workflow_id": "my-workflow",
    "target_path": ".harmony/workflows/my-workflow/"
  },
  "completed_steps": ["01-validate", "02-analyze"]
}
```

### Resume Procedure

1. Read `checkpoints/<workflow>/state.json`
2. Load context from `context.json`
3. Continue from `current_step`
4. Skip steps in `completed_steps` (via idempotency checks)

### Implementation Checklist

- [ ] `checkpoints` field in frontmatter
- [ ] Each step creates completion marker
- [ ] State file updated after each step
- [ ] Resume instructions in overview

---

## 5. Versioning

### Problem

Workflows evolve but changes aren't tracked. This causes:
- Confusion about expected behavior
- Breaking changes without notice
- No migration path for updates

### Solution

Add `version` field to frontmatter:

```yaml
version: "1.2.0"
```

And `## Version History` section before References:

```markdown
## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.2.0 | 2025-01-14 | Added parallel step support |
| 1.1.0 | 2025-01-10 | Added checkpoint system |
| 1.0.0 | 2025-01-05 | Initial version |
```

### Versioning Guidelines

- **Major (X.0.0):** Breaking changes to step structure or outputs
- **Minor (0.X.0):** New steps added, optional features
- **Patch (0.0.X):** Clarifications, error message improvements

### Implementation Checklist

- [ ] `version` field in frontmatter
- [ ] Semantic version format (X.Y.Z)
- [ ] Version History section present
- [ ] Major changes documented with migration notes

---

## 6. Parallel Step Execution

### Problem

Steps execute sequentially even when independent. This is:
- Slower than necessary
- Wasteful of parallelizable work
- Missed optimization opportunity

### Solution

Add `parallel_steps` array to frontmatter:

```yaml
parallel_steps:
  - group: "validation"
    steps: ["02-validate-target", "03-validate-templates"]
    join_at: "04-analyze"
  - group: "file-generation"
    steps: ["05-generate-overview", "06-generate-steps"]
    join_at: "07-verify"
```

And in parallel-safe step files:

```markdown
## Parallel Execution

**Group:** validation
**Can run with:** 03-validate-templates.md
**Join point:** 04-analyze.md

**Independence Check:**
- [ ] This step does not write to files read by parallel steps
- [ ] This step does not depend on outputs from parallel steps
- [ ] Failure in this step does not invalidate parallel steps
```

### Independence Criteria

Two steps can run in parallel if:
1. Neither reads files the other writes
2. Neither depends on the other's output
3. Either can fail without affecting the other
4. Both complete before the join point

### Implementation Checklist

- [ ] `parallel_steps` field present (can be empty `[]`)
- [ ] Each group has `steps` array and `join_at` point
- [ ] Independence verified for each parallel pair
- [ ] Join points are actual step files

---

## Quick Reference

### Frontmatter Template (Complete)

```yaml
---
title: "[Title]"
description: "[Max 160 chars]"
access: human|agent
version: "1.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".workspace/progress/checkpoints/"
parallel_steps: []
---
```

### Step Idempotency Template

```markdown
## Idempotency

**Check:** [Detection method]
- [ ] [Condition]

**If Already Complete:**
- [Skip or cleanup action]

**Marker:** `checkpoints/<workflow>/<step>.complete`
```

### Gap Fix Checklist

For any workflow:

- [ ] Overview has `version` field
- [ ] Overview has `depends_on` field (even if empty)
- [ ] Overview has `checkpoints` configuration
- [ ] Overview has `parallel_steps` field (even if empty)
- [ ] Overview has Version History section
- [ ] Each step has Idempotency section
- [ ] Branch points documented (if any)
- [ ] Final step is verification gate

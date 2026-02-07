---
title: Workspace Checklists
description: Quality gates stored in .harmony/quality/ including definition of done
---

# Workspace Checklists

The `checklists/` directory contains **quality gates** that agents verify before completing work.

## Location

```text
.harmony/quality/
├── complete.md          # Definition of done (required)
├── session-exit.md  # Session completion steps (recommended)
├── review.md        # Pre-review checklist (optional)
└── deploy.md        # Pre-deployment checklist (optional)
```

---

## `complete.md` (Required)

Every workspace MUST have a `checklists/complete.md` that defines completion criteria.

### Structure

```markdown
# Definition of Done

## Before Marking Any Task Complete

- [ ] Output matches task requirements
- [ ] Stayed within `scope.md` boundaries
- [ ] Follows `conventions.md` style rules
- [ ] Updated `progress/log.md` with session summary
- [ ] Updated `progress/tasks.json` status

## Quality Criteria

### For [Content Type A]

- [ ] Criterion 1
- [ ] Criterion 2

### For [Content Type B]

- [ ] Criterion 1
- [ ] Criterion 2
```

### Rules

- MUST be verifiable (each item can be checked true/false)
- MUST include progress tracking requirements
- SHOULD be domain-specific (customize for the workspace)
- MAY include common failure modes as warnings

---

## `session-exit.md` (Recommended)

Steps to complete before ending a session, context reset, or handoff.

### Structure

```markdown
# Session Exit Checklist

## Required Steps

- [ ] Update `progress/log.md` with session summary
- [ ] Update `progress/tasks.json` status
- [ ] Update `progress/entities.json` if applicable
- [ ] Document in-flight state if mid-task

## Conditional Steps

### If a decision was made
- [ ] Add to `context/decisions.md`

### If something failed
- [ ] Add to `context/lessons.md`
```

### Purpose

Session exit ensures **continuity** across context resets. Without it, the next session may:
- Repeat completed work
- Miss important context
- Lose in-flight state

---

## Using Checklists

Checklists are referenced in the boot sequence:

```markdown
7. Before finishing: Complete `checklists/session-exit.md`, verify against `checklists/complete.md`
```

Agents MUST NOT mark tasks complete without verifying all applicable checklist items.

---

## Checklist Principles

1. **Verifiable** — Each item is true/false, not subjective
2. **Actionable** — Agent can check each item without external help
3. **Minimal** — Only include what prevents real failures
4. **Domain-specific** — Customize for the workspace's content type

---

## Common Failure Modes Section

Include a table of common failures and their prevention:

```markdown
## Common Failure Modes

| Failure | Prevention |
|---------|------------|
| Premature completion | Run through this checklist |
| Scope creep | Re-read `scope.md` if task expands |
| Broken continuity | Always update `progress/log.md` |
```

---

## See Also

- [Progress](./progress.md) — Session continuity tracking
- [README.md](./README.md) — Canonical workspace structure

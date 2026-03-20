---
title: Harness Checklists
description: Assurance gates stored in .octon/framework/assurance/ including definition of done
---

# Harness Checklists

The `assurance/` directory contains **assurance gates** that agents verify before completing work.

Applicability by harness type:

- Repo-root harness: `assurance/` is strongly recommended and typically present.

## Location

```text
.octon/framework/assurance/
└── practices/
    ├── complete.md      # Definition of done (required)
    ├── session-exit.md  # Session completion steps (recommended)
    ├── review.md        # Pre-review checklist (optional)
    └── deploy.md        # Pre-deployment checklist (optional)
```

---

## `practices/complete.md` (Required When `assurance/` Exists)

If a harness includes the `assurance/` subsystem, it MUST define `assurance/practices/complete.md` with completion criteria.

- Repo-root harness: should always include this file.

### Structure

```markdown
# Definition of Done

## Before Marking Any Task Complete

- [ ] Output matches task requirements
- [ ] Stayed within `scope.md` boundaries
- [ ] Follows `conventions.md` style rules
- [ ] Updated `/.octon/state/continuity/repo/log.md` with session summary
- [ ] Updated `/.octon/state/continuity/repo/tasks.json` status

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
- SHOULD be domain-specific (customize for the harness)
- MAY include common failure modes as warnings

---

## `practices/session-exit.md` (Recommended)

Steps to complete before ending a session, context reset, or handoff.

### Structure

```markdown
# Session Exit Checklist

## Required Steps

- [ ] Update `/.octon/state/continuity/repo/log.md` with session summary
- [ ] Update `/.octon/state/continuity/repo/tasks.json` status
- [ ] Update `/.octon/state/continuity/repo/entities.json` if applicable
- [ ] Document in-flight state if mid-task

## Conditional Steps

### If a decision was made
- [ ] Add or update an ADR in `/.octon/instance/cognition/decisions/`
- [ ] Update `/.octon/instance/cognition/decisions/index.yml`
- [ ] Regenerate `/.octon/generated/cognition/summaries/decisions.md`

### If something failed
- [ ] Add to `/.octon/instance/cognition/context/shared/lessons.md`
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
7. Before finishing: Complete `assurance/practices/session-exit.md`, verify against `assurance/practices/complete.md`
```

Agents MUST NOT mark tasks complete without verifying all applicable checklist items.

---

## Checklist Principles

1. **Verifiable** — Each item is true/false, not subjective
2. **Actionable** — Agent can check each item without external help
3. **Minimal** — Only include what prevents real failures
4. **Domain-specific** — Customize for the harness's content type

---

## Common Failure Modes Section

Include a table of common failures and their prevention:

```markdown
## Common Failure Modes

| Failure | Prevention |
|---------|------------|
| Premature completion | Run through this checklist |
| Scope creep | Re-read `scope.md` if task expands |
| Broken continuity | Always update `/.octon/state/continuity/repo/log.md` |
```

---

## See Also

- [Progress](../../cognition/_meta/architecture/state/continuity/progress.md) — Session continuity tracking
- [README.md](./README.md) — Canonical harness structure

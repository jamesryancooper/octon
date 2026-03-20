---
title: Session Exit Checklist
description: Steps to complete before ending a session or context reset
---

# Session Exit Checklist

Complete before ending a session, context reset, or handoff.

## Required Steps

- [ ] **Update `state/continuity/repo/log.md`** with session summary
- [ ] **Update `state/continuity/repo/tasks.json`** status
- [ ] **Update `state/continuity/repo/entities.json`** if applicable
- [ ] **Update `state/continuity/scopes/<scope-id>/**`** when a declared scope
  is the primary continuity home
- [ ] **Document in-flight state** if mid-task

## Conditional Steps

### If a decision was made

- [ ] Add or update an ADR in `instance/cognition/decisions/`
- [ ] Update `instance/cognition/decisions/index.yml`
- [ ] Regenerate `generated/cognition/summaries/decisions.md`

### If something failed

- [ ] Add to `instance/cognition/context/shared/lessons.md`

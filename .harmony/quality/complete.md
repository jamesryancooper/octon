---
title: Definition of Done
description: Quality criteria and completion checklist for workspace tasks.
---

# Definition of Done

## Before Marking Any Task Complete

- [ ] Output matches task requirements
- [ ] Stayed within `scope.md` boundaries
- [ ] Follows `conventions.md` style rules
- [ ] Updated `continuity/log.md` with session summary
- [ ] Updated `continuity/tasks.json` status

## Quality Criteria

### For Agent-Facing Content

- [ ] Under token budget
- [ ] Actionable (agent can act on it immediately)
- [ ] No explanatory padding ("why" belongs in `ideation/scratchpad/` or `docs/`)
- [ ] Uses lists over prose

### For Prompts/Workflows

- [ ] Clear context section (1-2 sentences)
- [ ] Numbered instructions
- [ ] Defined output/deliverable
- [ ] Tested with at least one execution

## Common Failure Modes

| Failure | Prevention |
|---------|------------|
| **Premature completion** | Run through this checklist before marking done |
| **Scope creep** | Re-read `scope.md` if task expands |
| **Broken continuity** | Always update `continuity/log.md` before session end |
| **Token bloat** | Ask "does an agent need this to act?" If no, cut it or move to `ideation/scratchpad/` |

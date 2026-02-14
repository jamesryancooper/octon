---
title: Definition of Done
description: Quality criteria and completion checklist for harness tasks.
---

# Definition of Done

## Before Marking Any Task Complete

- [ ] Output matches task requirements
- [ ] Stayed within `scope.md` boundaries
- [ ] Follows `conventions.md` style rules
- [ ] Native-first rule preserved (core behavior works with zero adapters)
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

### For Agent Platform Interop Changes

- [ ] Core contracts/schemas remain provider-agnostic
- [ ] Provider-specific terms exist only in adapter paths
- [ ] `validate-service-independence.sh --mode platform-core` passes
- [ ] `validate-service-independence.sh --mode conformance` passes (when adapters are in scope)
- [ ] `validate-service-independence.sh --mode degradation` passes
- [ ] Native commands (`context-budget`, `validate-session-policy`) run without adapters

## Common Failure Modes

| Failure | Prevention |
|---------|------------|
| **Premature completion** | Run through this checklist before marking done |
| **Scope creep** | Re-read `scope.md` if task expands |
| **Broken continuity** | Always update `continuity/log.md` before session end |
| **Token bloat** | Ask "does an agent need this to act?" If no, cut it or move to `ideation/scratchpad/` |

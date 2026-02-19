# Definition of Done

## Before Marking Any Task Complete

- [ ] Output matches task requirements
- [ ] Stayed within `scope.md` boundaries
- [ ] Follows `conventions.md` style rules
- [ ] Updated `continuity/log.md` with session summary
- [ ] Updated `continuity/tasks.json` status

## Quality Criteria

- [ ] Actionable (agent can act on it immediately)
- [ ] No explanatory padding ("why" belongs in `ideation/scratchpad/` or `docs/`)
- [ ] Uses lists over prose

## Quality Gates (customize per directory type)

- [ ] Tests pass (if applicable)
- [ ] Linting passes (if applicable)
- [ ] Build succeeds (if applicable)
- [ ] No type errors (if applicable)
- [ ] {{CUSTOM_QUALITY_CHECK_*}}

## Common Failure Modes

| Failure | Prevention |
|---------|------------|
| Premature completion | Run through this checklist |
| Scope creep | Re-read `scope.md` if task expands |
| Broken continuity | Always update `continuity/log.md` |

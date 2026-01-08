---
title: Definition of Done
description: Quality criteria for code tasks.
---

# Definition of Done

## Before Marking a Task Complete

- [ ] Code compiles without errors
- [ ] All tests pass (`pnpm test`)
- [ ] Linting passes (`pnpm lint`)
- [ ] Types are correct (no `any` unless justified)
- [ ] Changes are documented (JSDoc, README if needed)
- [ ] Follows `conventions.md` patterns

## Code-Specific Checks

- [ ] New components have tests
- [ ] New components have stories (if applicable)
- [ ] Props are documented with JSDoc
- [ ] Error cases are handled
- [ ] No console.log statements in production code


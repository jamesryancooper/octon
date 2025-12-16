# Definition of Done

## Before Marking Any Task Complete

- [ ] Output matches task requirements
- [ ] Stayed within `scope.md` boundaries
- [ ] Follows `conventions.md` style rules
- [ ] Updated `progress/log.md` with session summary
- [ ] Updated `progress/tasks.json` status

## Quality Criteria

### Code Quality

- [ ] TypeScript types check (`pnpm typecheck`)
- [ ] ESLint passes (`pnpm lint`)
- [ ] Tests pass (`pnpm test`)
- [ ] No console warnings in tests

### Component Quality

- [ ] Storybook story exists for component
- [ ] Props are documented with JSDoc
- [ ] Accessibility: keyboard navigation works
- [ ] Accessibility: screen reader tested (basic)

### Documentation

- [ ] README updated if API changed
- [ ] Breaking changes noted in changelog

## Common Failure Modes

| Failure | Prevention |
|---------|------------|
| Missing story | Add story before marking component done |
| Untested edge cases | Check story controls for all prop variants |
| Accessibility gaps | Tab through component, check focus states |
| Type leaks | Ensure all exports have explicit types |

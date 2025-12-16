# Scope: ui-kit

## This Workspace Covers

Shared React UI component library for the design system.

## In Scope

- Creating new components
- Writing component tests
- Updating component styles
- Component documentation and Storybook stories
- Accessibility improvements
- Design token usage

## Out of Scope

- App-specific components (belong in `apps/`)
- Business logic (belong in `packages/domain/`)
- API integrations (belong in `packages/adapters/`)
- Global styling decisions (coordinate with design team)

## Decision Authority

**Decide locally:**

- Component API design
- Internal component structure
- Test coverage approach
- Story organization

**Escalate:**

- New design tokens
- Breaking API changes
- Removing existing components
- Cross-cutting style changes

## Adjacent Areas

| Area | Relationship |
|------|--------------|
| `packages/config/` | Shared TypeScript/ESLint configs |
| `apps/web/` | Primary consumer of components |
| `apps/docs/` | Component documentation site |

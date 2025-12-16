# Scope: Root .workspace

## This Workspace Covers

- The `.workspace` harness pattern itself (meta-documentation)
- Templates and examples for creating new `.workspace` directories
- Agent prompts for workspace evaluation and refinement

## In Scope

- Defining the `.workspace` structure and conventions
- Creating reusable prompts for workspace operations
- Documenting best practices for agent harnesses
- Maintaining token-efficient, actionable content

## Out of Scope

- Domain-specific content (belongs in domain's own `.workspace`)
- General project documentation (belongs in `/docs`)
- Code implementation (belongs in `/packages`, `/apps`)
- Human onboarding beyond `.workspace` usage

## Decision Authority

**Decide locally:**

- File naming within this `.workspace`
- Prompt templates and workflow definitions
- Progress tracking format

**Escalate:**

- Changes to the `.workspace` pattern that affect other workspaces
- New conventions that should apply project-wide

## Adjacent Areas

| Area | Relationship |
|------|--------------|
| `docs/harmony/ai/methodology/.workspace` | Implements this pattern for methodology docs |
| `.cursor/` | IDE-specific agent configuration (complementary) |

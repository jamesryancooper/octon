---
title: "ADR-007: Primitives Documentation"
status: accepted
date: 2026-01-14
mutability: append-only
---

# ADR-007: Primitives Documentation

## Status

Accepted

## Context

The Octon framework has seven distinct building blocks (primitives) that serve different purposes:

1. **Skills** - Composable capabilities with I/O contracts
2. **Commands** - Lightweight entry points
3. **Workflows** - Multi-step procedures with checkpoints
4. **Assistants** - Persona-based specialists
5. **Checklists** - Quality gates for verification
6. **Prompts** - Task templates with structured I/O
7. **Templates** - Scaffolding for new structures

These primitives were documented across various files but lacked a central reference explaining:
- When to use each primitive
- How they differ from each other
- Decision criteria for choosing between them

New users and agents had to piece together this understanding from multiple sources.

## Decision

Create `.octon/cognition/context/primitives.md` as the central reference for all Octon primitives.

### Decisions Made

| ID | Decision | Choice |
|----|----------|--------|
| D025 | Primitives documentation | Central reference in `.octon/cognition/context/primitives.md` |
| D026 | Seven primitives | Skills, Commands, Workflows, Assistants, Checklists, Prompts, Templates |

## Structure

The document includes:

- **Quick Reference Table** - All primitives with purpose, invocation, and state
- **Per-Primitive Sections** - Location, purpose, characteristics, when to use, examples, structure
- **Decision Matrix** - Situation → primitive mapping with rationale
- **Conceptual Groupings** - By question answered, by lifecycle phase
- **Example Scenarios** - Concrete use cases for each primitive
- **Related Resources** - Registry and template locations

## Consequences

### Positive

- Single source of truth for primitive selection
- Faster onboarding for new users and agents
- Consistent terminology across documentation
- Clear decision criteria reduce primitive misuse

### Negative

- Another file to maintain when primitives evolve
- Must stay synchronized with individual primitive docs

## Related

- `.octon/cognition/context/primitives.md` - The reference document
- `.octon/README.md` - Structure overview (references primitives.md)
- `.octon/capabilities/skills/registry.yml` - Skills registry
- `.octon/agency/assistants/registry.yml` - Assistants registry

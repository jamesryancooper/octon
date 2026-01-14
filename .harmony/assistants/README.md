---
title: Assistants
description: Focused specialists that serve agents or humans for scoped tasks.
---

# Assistants

Assistants are **focused specialists** that perform scoped, one-off tasks. They can be invoked directly by humans via `@mention` or delegated to by agents.

## Available Assistants

| Name | Aliases | Description |
|------|---------|-------------|
| reviewer | `@review`, `@rev` | Code review: quality, style, correctness |
| refactor | `@refactor`, `@ref` | Code restructuring: extract, rename, simplify |
| docs | `@docs`, `@doc` | Documentation: clarity, completeness, accuracy |

## Invocation

**Direct (human):**
```text
@reviewer Check this PR for security issues
@refactor Extract method from this large function
@docs Improve clarity of this README
```

**Delegated (agent):**
Agents may delegate subtasks to assistants when specialized focus is needed.

## Creating a New Assistant

1. Copy `_template/` to a new directory: `assistants/<name>/`
2. Update `assistant.md` with mission, rules, and output format
3. Register in `registry.yml`

## Registry Format

See `registry.yml` for the @mention mapping configuration.

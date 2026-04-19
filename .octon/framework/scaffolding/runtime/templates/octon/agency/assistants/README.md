---
title: Assistants
description: Focused specialists that serve agents or humans for scoped tasks.
---

# Assistants

Assistants are **focused specialists** that perform scoped, one-off tasks. They can be invoked directly by humans via `@mention` or delegated to by agents.

Use `../manifest.yml` and `registry.yml` to resolve assistant routing metadata.

## Available Assistants

See `registry.yml` for configured assistants.

## Invocation

**Direct (human):**
```text
@name task description
```

**Delegated (agent):**
Agents may delegate subtasks to assistants when specialized focus is needed.

## Creating a New Assistant

1. Copy `_scaffold/template/` to a new directory: `assistants/<name>/`
2. Update `SPECIALIST.md` with mission, rules, and output format
3. Register in `registry.yml`

## Registry Format

See `registry.yml` for the @mention mapping configuration.

---
title: Specialists
description: Bounded, scoped execution-role helpers.
---

# Specialists

Specialists perform scoped, stateless tasks inside the orchestrator's granted
envelope. They do not own mission lifecycle, continuity, authority widening, or
final closeout.

Use `registry.yml` to resolve specialist routing metadata.

## Available Specialists

See `registry.yml` for configured specialists.

## Invocation

**Direct (human):**
```text
@name task description
```

**Delegated:**
The orchestrator may delegate bounded subtasks to specialists when specialized
focus is needed.

## Creating a New Specialist

1. Copy `_scaffold/template/` to a new directory: `specialists/<name>/`
2. Update `SPECIALIST.md` with mission, rules, and output format
3. Register in `registry.yml`

## Registry Format

See `registry.yml` for the @mention mapping configuration.

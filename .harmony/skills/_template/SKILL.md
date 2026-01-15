---
name: skill-name
description: >
  [One paragraph describing what this skill does and when to use it.
  Include specific keywords to help agents identify relevant tasks.
  Describe the value proposition and typical use cases.]
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: "[Author Name]"
  version: "0.1.0"
  created: "[YYYY-MM-DD]"
  updated: "[YYYY-MM-DD]"
allowed-tools: Read Glob Grep Write(outputs/*) Write(logs/*)
---

# [Skill Name]

[One sentence describing what this skill does and its primary value.]

## When to Use

Use this skill when:

- [Trigger condition 1]
- [Trigger condition 2]
- [Trigger condition 3]

## Quick Start

```
/skill-name "[input]"
```

## Core Workflow

1. **[Phase 1]** - [Brief description]
2. **[Phase 2]** - [Brief description]
3. **[Phase 3]** - [Brief description]
4. **Output** - Save results and execution log

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `[param1]` | Yes | - | [Description] |
| `[param2]` | No | [default] | [Description] |

## Output Location

- **Results:** `outputs/[category]/<timestamp>-[name].md`
- **Run logs:** `logs/runs/<timestamp>-skill-name.md`

## Boundaries

- [Constraint 1 - what the skill must never do]
- [Constraint 2 - what the skill must always do]
- Write only to designated output paths
- [Additional constraints]

## When to Escalate

- [Condition requiring user input]
- [Ambiguous situation]
- [Error condition]

## References

For detailed documentation:

- [Behavior phases](references/behaviors.md) - Full phase-by-phase instructions
- [Invocation patterns](references/triggers.md) - Commands, triggers, parameters
- [I/O contract](references/io-contract.md) - Inputs, outputs, dependencies
- [Safety policies](references/safety.md) - Tool and file policies
- [Examples](references/examples.md) - Full usage examples
- [Validation](references/validation.md) - Acceptance criteria

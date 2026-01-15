---
commands:
  - /skill-name

explicit_call_patterns:
  - "use skill: skill-name"

triggers:
  - "[natural language trigger 1]"
  - "[natural language trigger 2]"
  - "[natural language trigger 3]"
---

# Invocation Reference

How to invoke the skill-name skill.

## Commands

- `/skill-name` - Primary command invocation

## Explicit Call Patterns

- `use skill: skill-name`

## Natural Language Triggers

The skill activates on phrases like:

- "[natural language trigger 1]"
- "[natural language trigger 2]"
- "[natural language trigger 3]"

## Parameters

### `[param1]` (required)
[Description of the parameter and how to use it.]

```
/skill-name "[value]"
/skill-name path/to/file.txt
```

### `[param2]` (optional, default: [default])
[Description of the optional parameter.]

```
/skill-name "[value]" --param2=[option]
```

## Example Invocations

```bash
# Basic usage
/skill-name "[input]"

# With options
/skill-name "[input]" --param2=[option]

# From file
/skill-name path/to/input.txt
```

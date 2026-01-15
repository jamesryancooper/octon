---
commands:
  - /refine-prompt

explicit_call_patterns:
  - "use skill: refine-prompt"

triggers:
  - "refine my prompt"
  - "improve this prompt"
  - "expand this prompt"
  - "spell check my prompt"
  - "clarify my prompt"
  - "analyze and improve my prompt"
---

# Invocation Reference

How to invoke the refine-prompt skill.

## Commands

- `/refine-prompt` - Primary command invocation

## Explicit Call Patterns

- `use skill: refine-prompt`

## Natural Language Triggers

The skill activates on phrases like:

- "refine my prompt"
- "improve this prompt"
- "expand this prompt"
- "spell check my prompt"
- "clarify my prompt"
- "analyze and improve my prompt"

## Parameters

### `raw_prompt` (required)
The raw prompt text to refine. Can be provided inline or as a file path.

```
/refine-prompt "add caching to the api"
/refine-prompt path/to/prompt.txt
```

### `execute` (optional, default: false)
Execute the refined prompt after saving.

```
/refine-prompt "add caching" --execute
```

### `context_depth` (optional, default: standard)
How deep to analyze repository context.

| Value | Behavior |
|-------|----------|
| `minimal` | Skip repo analysis, basic intent expansion only |
| `standard` | Analyze immediate scope, find relevant patterns |
| `deep` | Full repo analysis, dependency mapping, risk assessment |

```
/refine-prompt "refactor auth" --context_depth=deep
```

### `skip_confirmation` (optional, default: false)
Skip the intent confirmation step.

```
/refine-prompt "quick fix" --skip_confirmation=true
```

## Example Invocations

```bash
# Basic refinement
/refine-prompt "add caching to the api"

# Deep analysis with execution
/refine-prompt "refactor the auth module" --context_depth=deep --execute

# Quick refinement without confirmation
/refine-prompt "fix the typo in config" --skip_confirmation=true

# From file
/refine-prompt path/to/rough-prompt.txt --context_depth=standard
```

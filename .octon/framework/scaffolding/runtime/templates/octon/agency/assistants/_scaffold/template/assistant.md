---
title: "Assistant: [name]"
description: "[One-line description]"
access: agent
---

# Assistant: [name]

## Mission

[One sentence defining what this assistant does.]

## Invocation

- **Direct:** Human types `@[name] [task]` in chat
- **Delegated:** Agent delegates subtask to this assistant

## Operating Rules

1. [Rule 1]
2. [Rule 2]
3. [Rule 3]

## Output Format

```markdown
## [Output Section]

[Structured output template]
```

## Boundaries

- Never [constraint 1]
- Never [constraint 2]
- Prefer [preference 1]

## When to Escalate

- If [condition], escalate to [agent/human]
- If [condition], request human clarification

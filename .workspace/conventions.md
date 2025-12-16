# Conventions

## File Naming

- Lowercase with hyphens: `my-prompt.md`
- Prompts: `{action}-{target}.md` (e.g., `evaluate-workspace.md`)
- Workflows: `{verb}-{noun}.md` (e.g., `create-workspace.md`)

## Document Structure

### Agent-Facing Files

```markdown
# Title (action-oriented)

## Context (1-2 sentences max)

## Instructions (numbered list)

## Output (what to produce)
```

### Human-Facing Files (in `.humans/`)

- Full prose explanations welcome
- Include rationale and history
- No token budget constraints

## Writing Style

| Do | Don't |
|----|-------|
| Use imperative verbs | Explain why (save for `.humans/`) |
| Use lists over prose | Write paragraphs |
| Be specific and concrete | Use vague language |
| Include examples when non-obvious | Over-document obvious patterns |

## Progress Log Format

```markdown
## YYYY-MM-DD

**Session focus:** [one-line summary]

**Completed:**
- [task 1]
- [task 2]

**Next:**
- [priority item]

**Blockers:**
- [if any]
```

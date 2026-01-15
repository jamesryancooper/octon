---
safety:
  tool_policy:
    mode: deny-by-default
    allowed:
      - filesystem.read
      - filesystem.write.outputs
      - filesystem.glob
      - filesystem.grep
  file_policy:
    write_scope:
      - ".workspace/skills/outputs/**"
      - ".workspace/skills/logs/**"
    destructive_actions: never
---

# Safety Reference

Safety policies and constraints for the skill-name skill.

## Tool Policy

**Mode:** Deny-by-default

Only the following tools are permitted:

| Tool | Purpose |
|------|---------|
| `filesystem.read` | [Purpose] |
| `filesystem.write.outputs` | [Purpose] |
| `filesystem.glob` | [Purpose] |
| `filesystem.grep` | [Purpose] |

## File Policy

### Write Scope

The skill may only write to:

- `.workspace/skills/outputs/**`
- `.workspace/skills/logs/**`

### Destructive Actions

**Policy:** Never

The skill must never:
- Delete files
- Overwrite source code
- Modify files outside designated output paths

## Behavioral Boundaries

- [Boundary 1 - what the skill must never do]
- [Boundary 2 - what the skill must always do]
- Write only to designated output paths
- [Additional boundaries]

## Escalation Triggers

The skill must escalate to the user when:

- [Condition 1]
- [Condition 2]
- [Condition 3]

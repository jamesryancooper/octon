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

Safety policies and constraints for the refine-prompt skill.

## Tool Policy

**Mode:** Deny-by-default

Only the following tools are permitted:

| Tool | Purpose |
|------|---------|
| `filesystem.read` | Read codebase files for context analysis |
| `filesystem.write.outputs` | Write refined prompts and logs to output directories |
| `filesystem.glob` | Find files matching patterns |
| `filesystem.grep` | Search file contents |

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

- Never change the core intent of the original prompt
- Always preserve the user's explicit preferences
- State all assumptions - never silently assume
- Reference only files that actually exist
- Do not execute unless explicitly requested
- Write only to designated output paths
- If contradictions cannot be resolved, ask before proceeding
- Limit context analysis to reasonable scope (don't scan entire monorepo)
- Always perform self-critique before finalizing
- Always confirm intent unless explicitly skipped

## Escalation Triggers

The skill must escalate to the user when:

- The prompt has unresolvable contradictions
- The intent is completely unclear
- Referenced files don't exist
- The request conflicts with project constraints
- The scope is too large (>20 files)
- Domain expertise is needed to fill gaps accurately
- Self-critique reveals major issues
- User rejects intent confirmation

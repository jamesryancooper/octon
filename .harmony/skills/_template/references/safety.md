---
# Safety Policy Documentation
# Note: Tool permissions are authoritative in SKILL.md frontmatter (allowed-tools)
# This file documents policies and boundaries for human reference
safety:
  tool_policy:
    mode: deny-by-default         # Always deny-by-default
    # Allowed tools defined in SKILL.md frontmatter (allowed-tools)
  file_policy:
    write_scope:                   # Paths where writing is allowed
      - ".workspace/{{category}}/**"     # Deliverables (final destination)
      - ".workspace/skills/runs/**"      # Execution state (session recovery)
      - ".workspace/skills/logs/**"      # Logs (always allowed)
      # Custom paths as defined in registry I/O mapping
      # Must be within workspace's hierarchical scope
    scope_authority:               # Hierarchical scope rules
      down: allowed                # Can write into descendant workspaces
      up: blocked                  # Cannot write into ancestor workspaces
      sideways: blocked            # Cannot write into sibling workspaces
    destructive_actions: never     # Always 'never'
---

# Safety Reference

Safety policies and constraints for the skill-name skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Output paths: `.workspace/skills/registry.yml`

## Tool Policy

**Mode:** Deny-by-default

Tool permissions are defined in SKILL.md `allowed-tools` frontmatter (single source of truth).

Describe the tools this skill uses and their purposes in prose here. Reference the `allowed-tools` field in SKILL.md for the authoritative list.

## File Policy

### Write Scope

The skill may only write to designated output locations:

| Tier        | Path                                      | Purpose              |
|-------------|-------------------------------------------|----------------------|
| **Tier 1**  | `.workspace/{{category}}/**`              | Deliverables         |
| **Tier 1**  | `.workspace/skills/runs/{{skill-id}}/**`  | Execution state (session recovery) |
| **Tier 1**  | `.workspace/skills/logs/**`               | Execution logs       |

### Scope Authority

| Direction     | Permission | Description                           |
|---------------|------------|---------------------------------------|
| **Down**      | Allowed    | Can write into descendant workspaces  |
| **Up**        | Blocked    | Cannot write into ancestor workspaces |
| **Sideways**  | Blocked    | Cannot write into sibling workspaces  |

### Destructive Actions

**Policy:** Never

The skill must never:

- Delete files
- Overwrite source code
- Modify files outside designated output paths
- Write to ancestor or sibling workspace paths

## Behavioral Boundaries

### Must Always

- {{Boundary 1 - what the skill must always do}}
- {{Boundary 2}}
- Write only to designated output paths
- State assumptions explicitly

### Must Never

- {{Boundary 1 - what the skill must never do}}
- {{Boundary 2}}
- Delete or modify source files
- Access resources outside defined scope

## Escalation Triggers

The skill must escalate to the user when:

| Condition         | Action              |
|-------------------|---------------------|
| {{Condition 1}}   | {{Action to take}}  |
| {{Condition 2}}   | {{Action to take}}  |
| {{Condition 3}}   | {{Action to take}}  |

## Input Validation

Before processing, validate:

- [ ] Input path/value exists and is valid
- [ ] Input meets expected format
- [ ] Required context is available

If validation fails, report the specific issue and exit gracefully.

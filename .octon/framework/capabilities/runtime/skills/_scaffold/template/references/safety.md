---
# Safety Policy Documentation
# Note: Tool permissions are authoritative in SKILL.md frontmatter (allowed-tools)
# This file documents policies and boundaries for human reference
#
# ## Domain Content Guidelines
#
# This file should contain ONLY:
# - Tool and file policies (permissions, write scope)
# - Must/must-not behavioral constraints
# - Escalation triggers
# - Repository-root scope authority rules
#
# If this file exceeds 100 lines AND domain-specific content (patterns, algorithms, rationale)
# exceeds 30 lines, extract that content to a `<domain>.md` file.
#
# See: .octon/framework/capabilities/_meta/architecture/reference-artifacts.md#domain-file-extraction-heuristics
#
safety:
  tool_policy:
    mode: deny-by-default         # Always deny-by-default
    # Allowed tools defined in SKILL.md frontmatter (allowed-tools)
  file_policy:
    write_scope:                   # Paths where writing is allowed
      - ".octon/generated/{{category}}/**"     # Deliverables (final destination)
      - ".octon/state/control/skills/checkpoints/**"      # Execution state (session recovery)
      - ".octon/state/evidence/runs/skills/**"      # Logs (always allowed)
      # Custom paths as defined in registry I/O mapping
      # Must remain within the repository-root harness scope
    scope_authority:               # Repository-root scope rules
      repo_root: allowed           # Can write within the repository boundary when declared
      outside_repo: blocked        # Cannot write outside the repository boundary
    destructive_actions: never     # Always 'never'
---

# Safety Reference

**Required when capability:** `safety-bounded`

Safety policies and constraints for the skill-name skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Output paths: `.octon/framework/capabilities/runtime/skills/registry.yml`

## Tool Policy

**Mode:** Deny-by-default

Tool permissions are defined in SKILL.md `allowed-tools` frontmatter (single source of truth).

Describe the tools this skill uses and their purposes in prose here. Reference the `allowed-tools` field in SKILL.md for the authoritative list.

## File Policy

### Write Scope

The skill may only write to designated output locations:

| Tier        | Path                                      | Purpose              |
|-------------|-------------------------------------------|----------------------|
| **Tier 1**  | `.octon/generated/{{category}}/**`              | Deliverables         |
| **Tier 1**  | `.octon/state/control/skills/checkpoints/{{skill-id}}/**`  | Execution state (session recovery) |
| **Tier 1**  | `.octon/state/evidence/runs/skills/**`               | Execution logs       |

### Scope Authority

| Boundary         | Permission | Description |
|------------------|------------|-------------|
| **Within repo root** | Allowed | Can write to declared repository paths |
| **Outside repo root** | Blocked | Cannot write outside the repository boundary |

### Destructive Actions

**Policy:** Never

The skill must never:

- Delete files
- Overwrite source code
- Modify files outside designated output paths
- Write outside the repo-root harness boundary

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

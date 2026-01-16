---
title: Skill Invocation
description: Methods for invoking skills and routing rules.
---

# Skill Invocation

Skills can be invoked through explicit commands, explicit patterns, or natural language triggers.

---

## Invocation Methods

### Explicit Commands (Recommended)

The most reliable way to invoke a skill:

```markdown
/refine-prompt "add caching to the api"
```

Commands are defined in the skill's registry entry and `triggers.md` reference file.

### Explicit Pattern

Use the `use skill:` pattern for explicit invocation without slash commands:

```markdown
use skill: refine-prompt
```

This pattern is useful when the agent should definitely use a specific skill.

### Trigger Matching

Natural language phrases can trigger skill activation:

```markdown
"refine my prompt"
→ Matches trigger in registry
→ Routes to refine-prompt skill
```

Triggers are matched against the `triggers` field in the registry.

---

## Routing Rules

When a user invokes a skill, the system follows these steps:

1. **Resolve workspace** — Determine active workspace (see below)
2. **Read shared registry** — Load `.harmony/skills/registry.yml`
3. **Read workspace registry** — Load active workspace's `.workspace/skills/registry.yml`
4. **Check explicit command** — If `/skill-name`, route directly
5. **Check explicit pattern** — If `use skill: <name>`, route directly
6. **Match triggers** — Compare input against registered triggers
7. **Resolve ambiguity** — If multiple matches, use `ambiguity_resolution` setting

### Ambiguity Resolution

When multiple skills match a trigger:

| Mode | Behavior |
|------|----------|
| `ask` | Ask user to choose (default) |
| `first_match` | Use first matching skill |
| `most_specific` | Use skill with most specific trigger match |

Configure in registry:

```yaml
routing:
  ambiguity_resolution: "ask"
```

---

## Parameter Passing

### Inline Parameters

Pass parameters directly after the command:

```markdown
/refine-prompt "add caching to the api"
```

### Named Parameters

Use flags for optional parameters:

```markdown
/refine-prompt "add caching" --context_depth=deep --execute
```

### From File

Reference a file as input:

```markdown
/refine-prompt path/to/prompt.txt
```

---

## Workspace Context

Skills execute within a workspace context that determines their scope and permissions. The active workspace is resolved before skill execution.

### Resolution Priority

| Priority | Method | Example |
|----------|--------|---------|
| 1 | Explicit `--workspace` flag | `/skill --workspace=path/to/ws "input"` |
| 2 | Input path | Nearest `.workspace/` ancestor of input files |
| 3 | Current directory | Nearest `.workspace/` ancestor of CWD |

### Workspace Flag

Override workspace resolution explicitly:

```bash
# Execute in repo workspace regardless of CWD
/refine-prompt --workspace=/repo "add caching"

# Execute in a specific nested workspace
/generate-docs --workspace=packages/kits/flowkit "api docs"
```

### Automatic Resolution

Without an explicit flag, the workspace is determined automatically:

```bash
# CWD: /repo/packages/kits/flowkit/src/
/refine-prompt "add caching"
# → Resolves to flowkit workspace (nearest .workspace/ from CWD)

# Input-based resolution
/research-synthesizer packages/kits/flowkit/notes/
# → Resolves to flowkit workspace (nearest .workspace/ from input path)
```

### Workspace Context Affects

| Aspect | How Workspace Context Applies |
|--------|-------------------------------|
| **Registry loading** | Loads the active workspace's `.workspace/skills/registry.yml` |
| **Output paths** | Validates paths against workspace's hierarchical scope |
| **Write permissions** | Can write down (descendants), not up (ancestors) or sideways (siblings) |
| **Run logs** | Written to active workspace's `.workspace/skills/logs/runs/` |

See [Architecture](./architecture.md#workspace-resolution) for the complete resolution algorithm.

---

## Examples

### Basic Invocation

```bash
# Explicit command
/refine-prompt "add caching to the api"

# With options
/refine-prompt "refactor the auth module" --context_depth=deep

# Skip confirmation
/refine-prompt "quick fix" --skip_confirmation=true

# From file
/refine-prompt path/to/rough-prompt.txt

# With explicit workspace
/refine-prompt --workspace=packages/kits "add kit utilities"
```

### Explicit Pattern

```markdown
I need to use skill: refine-prompt to improve this prompt.
```

### Natural Language

```markdown
User: "Can you refine my prompt for adding user authentication?"
Agent: [Matches "refine my prompt" trigger → routes to refine-prompt skill]
```

---

## Discovery

### List Available Skills

Skills are discovered from:
- `.harmony/skills/registry.yml` — Shared skills
- `.workspace/skills/registry.yml` — Workspace-specific skills

### Skill Information

To learn about a skill before using it:

```markdown
What does the refine-prompt skill do?
```

The agent will load the skill's `SKILL.md` and description.

---

## See Also

- [Architecture](./architecture.md) — Workspace resolution and hierarchical scope
- [Registry](./registry.md) — Registry format and trigger definitions
- [Reference Artifacts](./reference-artifacts.md) — The `triggers.md` reference file
- [Execution](./execution.md) — What happens after invocation

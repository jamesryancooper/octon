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

Commands are defined in the skill's registry entry (`registry.yml`).

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

Triggers are matched against the `triggers` field in the manifest.

---

## Routing Rules

When a user invokes a skill, the system follows these steps:

1. **Resolve harness** — Determine active harness (see below)
2. **Read shared manifest** — Load `.harmony/capabilities/skills/manifest.yml` for skill index
3. **Read harness manifest** — Load active harness's `.harmony/capabilities/skills/manifest.yml`
4. **Check explicit command** — If `/skill-name`, route directly
5. **Check explicit pattern** — If `use skill: <name>`, route directly
6. **Match triggers** — Compare input against registered triggers in manifest
7. **Resolve ambiguity** — If multiple matches, use `ambiguity_resolution` setting (from registry)
8. **Load extended metadata** — Read `registry.yml` for matched skill's commands/requires

### Ambiguity Resolution

When multiple skills match a trigger:

| Mode            | Behavior                                  |
|-----------------|-------------------------------------------|
| `ask`           | Ask user to choose (default)              |
| `first_match`   | Use first matching skill                  |
| `most_specific` | Use skill with most specific trigger match|

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

## Harness Context

Skills execute within a harness context that determines their scope and permissions. The active harness is resolved before skill execution.

### Resolution Priority

| Priority |         Method          |                  Example                         |
|----------|-------------------------|--------------------------------------------------|
|    1     | Explicit `--harness`  | `/skill --harness=path/to/ws "input"`          |
|    2     | Input path              | Nearest `.harmony/` ancestor of input files    |
|    3     | Current directory       | Nearest `.harmony/` ancestor of CWD            |

### Harness Flag

Override harness resolution explicitly:

```bash
# Execute in repo harness regardless of CWD
/refine-prompt --harness=/repo "add caching"

# Execute in a specific nested harness
/generate-docs --harness=packages/kits/flowkit "api docs"
```

### Automatic Resolution

Without an explicit flag, the harness is determined automatically:

```bash
# CWD: /repo/packages/kits/flowkit/src/
/refine-prompt "add caching"
# → Resolves to flowkit harness (nearest .harmony/ from CWD)

# Input-based resolution
/synthesize-research packages/kits/flowkit/notes/
# → Resolves to flowkit harness (nearest .harmony/ from input path)
```

### Harness Context Affects

| Aspect               | How Harness Context Applies                                                         |
|----------------------|---------------------------------------------------------------------------------------|
| **Registry loading** | Loads the active harness's `.harmony/capabilities/skills/registry.yml`                         |
| **Output paths**     | Validates paths against harness's hierarchical scope                                |
| **Write permissions**| Can write down (descendants), not up (ancestors), or sideways (siblings)              |
| **Run logs**         | Written to active harness's `.harmony/capabilities/skills/_state/logs/{{skill-id}}/{{run-id}}.md`     |

See [Harness Resolution](./harness-resolution.md) for the complete resolution algorithm.

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

# With explicit harness
/refine-prompt --harness=packages/kits "add kit utilities"
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

Skills are discovered from manifest files (Tier 1):

- `.harmony/capabilities/skills/manifest.yml` — Shared skill index
- `.harmony/capabilities/skills/manifest.yml` — Harness-specific skills

Extended metadata is loaded from registry files after matching:

- `.harmony/capabilities/skills/registry.yml` — Commands, requires, depends_on
- `.harmony/capabilities/skills/registry.yml` — I/O mappings, pipelines

### Skill Information

To learn about a skill before using it:

```markdown
What does the refine-prompt skill do?
```

The agent will load the skill's `SKILL.md` and description.

---

## See Also

- [Architecture](./architecture.md) — Harness resolution and hierarchical scope
- [Discovery](./discovery.md) — Manifest and registry formats
- [Reference Artifacts](./reference-artifacts.md) — Reference file documentation
- [Execution](./execution.md) — What happens after invocation

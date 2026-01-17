---
title: Workspace Resolution
description: Nearest ancestor model for determining which workspace to use when invoking a skill.
---

# Workspace Resolution

When a skill is invoked, the system must determine which workspace context to use. This follows the **nearest ancestor** model, similar to how git finds the repository root.

## Resolution Algorithm

```markdown
RESOLVE_WORKSPACE(cwd, input_paths, explicit_workspace):
  1. If explicit_workspace provided → use it
  2. Else if input_paths provided → find nearest .workspace/ ancestor of first input
  3. Else → find nearest .workspace/ ancestor of cwd
  4. If none found → error: "No workspace context"
```

## Resolution Priority

| Priority | Method | Description |
|----------|--------|-------------|
| 1 | Explicit flag | `--workspace=path/to/ws` overrides all |
| 2 | Input path | Nearest `.workspace/` ancestor of input files |
| 3 | Current directory | Nearest `.workspace/` ancestor of CWD |

## Finding the Nearest Workspace

Walk up from the starting directory until a `.workspace/` is found:

```markdown
Starting: /repo/packages/kits/flowkit/src/
         ↑ check for .workspace/ → not found
         /repo/packages/kits/flowkit/
         ↑ check for .workspace/ → FOUND

Active workspace: flowkit
Workspace root: /repo/packages/kits/flowkit/
Scope: flowkit/**
```

## Examples

```bash
# CWD-based resolution (most common)
cd /repo/packages/kits/flowkit/src
/refine-prompt "add caching"
# → Resolves to flowkit workspace

# Input-based resolution
cd /repo
/research-synthesizer packages/kits/flowkit/notes/
# → Resolves to flowkit workspace (based on input path)

# Explicit override
cd /repo/packages/kits/flowkit/src
/refine-prompt --workspace=/repo "add caching"
# → Resolves to repo workspace (explicit override)
```

## Agent Harness Implementation

Agent harnesses should:

1. **Track CWD** — Maintain awareness of current working directory
2. **Resolve workspace** — Apply the resolution algorithm before skill execution
3. **Provide context** — Pass workspace root and scope to the skill
4. **Display status** — Optionally show active workspace in prompt/status

```markdown
# Example status line showing active workspace
[flowkit] > /refine-prompt "add caching"
    ↑
    active workspace indicator
```

## No Workspace Found

If no `.workspace/` is found walking up from the starting point:

- **Error state** — Skills requiring workspace context cannot execute
- **Fallback** — Some read-only operations may proceed without workspace context
- **User action** — Create a `.workspace/` directory or specify `--workspace` explicitly

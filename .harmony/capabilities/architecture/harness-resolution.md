---
title: Harness Resolution
description: Nearest ancestor model for determining which harness to use when invoking a skill.
---

# Harness Resolution

When a skill is invoked, the system must determine which harness context to use. This follows the **nearest ancestor** model, similar to how git finds the repository root.

## Resolution Algorithm

```markdown
RESOLVE_HARNESS(cwd, input_paths, explicit_harness):
  1. If explicit_harness provided → use it
  2. Else if input_paths provided → find nearest .harmony/ ancestor of first input
  3. Else → find nearest .harmony/ ancestor of cwd
  4. If none found → error: "No harness context"
```

## Resolution Priority

| Priority | Method | Description |
|----------|--------|-------------|
| 1 | Explicit flag | `--harness=path/to/ws` overrides all |
| 2 | Input path | Nearest `.harmony/` ancestor of input files |
| 3 | Current directory | Nearest `.harmony/` ancestor of CWD |

## Finding the Nearest Harness

Walk up from the starting directory until a `.harmony/` is found:

```markdown
Starting: /repo/packages/kits/flowkit/src/
         ↑ check for .harmony/ → not found
         /repo/packages/kits/flowkit/
         ↑ check for .harmony/ → FOUND

Active harness: flowkit
Harness root: /repo/packages/kits/flowkit/
Scope: flowkit/**
```

## Examples

```bash
# CWD-based resolution (most common)
cd /repo/packages/kits/flowkit/src
/refine-prompt "add caching"
# → Resolves to flowkit harness

# Input-based resolution
cd /repo
/synthesize-research packages/kits/flowkit/notes/
# → Resolves to flowkit harness (based on input path)

# Explicit override
cd /repo/packages/kits/flowkit/src
/refine-prompt --harness=/repo "add caching"
# → Resolves to repo harness (explicit override)
```

## Agent Harness Implementation

Agent harnesses should:

1. **Track CWD** — Maintain awareness of current working directory
2. **Resolve harness** — Apply the resolution algorithm before skill execution
3. **Provide context** — Pass harness root and scope to the skill
4. **Display status** — Optionally show active harness in prompt/status

```markdown
# Example status line showing active harness
[flowkit] > /refine-prompt "add caching"
    ↑
    active harness indicator
```

## No Harness Found

If no `.harmony/` is found walking up from the starting point:

- **Error state** — Skills requiring harness context cannot execute
- **Fallback** — Some read-only operations may proceed without harness context
- **User action** — Create a `.harmony/` directory or specify `--harness` explicitly

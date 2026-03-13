---
title: Harness Resolution
description: Repository-root model for determining which harness to use when invoking a skill.
---

# Harness Resolution

When a skill is invoked, the system resolves the repository-root harness for the active repository.

## Resolution Algorithm

```markdown
RESOLVE_HARNESS(cwd, explicit_harness):
  1. If explicit_harness provided → use it
  2. Else → find the outermost `.octon/` ancestor of cwd
  3. If none found → error: "No repository-root harness context"
```

## Resolution Priority

| Priority | Method | Description |
|----------|--------|-------------|
| 1 | Explicit flag | `--harness=/repo` overrides auto-resolution |
| 2 | Current directory | Outermost `.octon/` ancestor of CWD |

## Finding the Repo-Root Harness

Walk up from the starting directory and keep the outermost `.octon/` ancestor:

```markdown
Starting: /repo/packages/kits/flowkit/src/
         ↑ collect any ancestor `.octon/`
         /repo/.octon/ → outermost match

Active harness: repo root
Harness root: /repo/
Scope: repo/**
```

## Examples

```bash
# CWD-based resolution (most common)
cd /repo/packages/kits/flowkit/src
/refine-prompt "add caching"
# → Resolves to repo-root harness

# Explicit override
cd /repo/packages/kits/flowkit/src
/refine-prompt --harness=/repo "add caching"
# → Resolves to repo harness (explicit override)
```

## Agent Harness Implementation

Agent harnesses should:

1. **Track CWD** — Maintain awareness of current working directory
2. **Resolve harness** — Apply the resolution algorithm before skill execution
3. **Provide context** — Pass repo root and harness root to the skill
4. **Display status** — Optionally show active harness in prompt/status

```markdown
# Example status line showing active harness
[repo] > /refine-prompt "add caching"
```

## No Harness Found

If no repo-root `.octon/` is found walking up from the starting point:

- **Error state** — Skills requiring harness context cannot execute
- **Fallback** — Some read-only operations may proceed without harness context
- **User action** — Create a repo-root `.octon/` directory or specify `--harness` explicitly

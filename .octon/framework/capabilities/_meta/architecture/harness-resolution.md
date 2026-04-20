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
  2. Else → collect `.octon/` directories on the cwd ancestor chain
  3. If exactly one found → use it
  4. If none found → error: "No repository-root harness context"
  5. If more than one found → error: "Exactly one repo-root harness is allowed"
```

## Resolution Priority

| Priority | Method | Description |
|----------|--------|-------------|
| 1 | Explicit flag | `--harness=/repo` overrides auto-resolution |
| 2 | Current directory | The only `.octon/` directory found on the CWD ancestor chain |

## Finding the Repo-Root Harness

Walk up from the starting directory and inspect only the ancestor chain:

```markdown
Starting: /repo/packages/kits/flowkit/src/
         ↑ inspect ancestors for `.octon/`
         /repo/.octon/ → only match

Active harness: repo root
Harness root: /repo/
Scope: repo/**
```

If the walk finds both `/repo/.octon/` and `/repo/packages/kits/.octon/`, resolution fails because exactly one repo-root harness is allowed on an ancestor chain. A sibling repository such as `/workspace/other-repo/.octon/` is ignored because it is not on the ancestor chain.

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

## Runtime Implementation

Runtime implementations should:

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

## Invalid Multiple Harness Roots

If multiple `.octon/` directories are found on the same ancestor chain:

- **Error state** — Execution stops with an ancestor-chain conflict error
- **Reason** — Octon supports sibling repo-root harnesses, but only one repo-root harness per ancestor chain
- **User action** — Remove the descendant or ancestor `.octon/` so exactly one repo-root harness remains for that repository

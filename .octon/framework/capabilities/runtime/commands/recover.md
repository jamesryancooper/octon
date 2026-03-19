---
title: Recover from Errors
description: Recovery procedures for common agent failure modes.
access: agent
---

# Recover from Errors

## Code is broken

1. `git status` — See what changed
2. `git diff` — Inspect changes
3. `git checkout -- <file>` — Revert specific file
4. `git reset --hard HEAD~1` — Revert last commit (destructive)

## Lost context

1. Read `/.octon/state/continuity/repo/log.md` — What was done
2. Read `/.octon/state/continuity/repo/tasks.json` — Current state
3. `git log --oneline -10` — Recent commits
4. Re-read `START.md` boot sequence

## Stuck on a task

1. Document blocker in `/.octon/state/continuity/repo/log.md`
2. Update task status to `blocked` in `tasks.json`
3. Move to next unblocked task
4. If all tasks blocked, stop and report

## File edit failed

- `StrReplace` requires unique `old_string`
- Add more context lines to make unique
- Or use `replace_all: true` for global replace

## References

- **Canonical:** `.octon/framework/capabilities/_meta/architecture/commands.md`

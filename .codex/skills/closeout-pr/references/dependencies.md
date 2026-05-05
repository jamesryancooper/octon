---
title: Dependencies
description: External dependencies for the closeout-pr skill.
---

# Dependencies

Required:

- `git`
- `gh`

Useful health probes:

- `gh api user`
- `gh pr view <number>`
- `gh pr checks <number>`

If `gh auth status` is a false negative but real operation probes succeed,
prefer the real operation probes for closeout continuity.

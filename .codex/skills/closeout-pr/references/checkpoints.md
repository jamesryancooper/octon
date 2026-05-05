---
title: Checkpoints
description: Durable checkpoints for the closeout-pr skill.
---

# Checkpoints

Use these checkpoints inside the loop:

1. Worktree scope reviewed
2. Commit created and pushed
3. Draft PR created or updated
4. Checks/conversations polled
5. Failed-check remediation applied
6. Review feedback remediation applied
7. Ready gate satisfied
8. Merge requested or confirmed
9. Branch, remote branch, and worktree cleanup completed or explicitly deferred

Checkpoint intent:

- make long-running closeout progress resumable
- keep blocker reporting precise
- separate code-fix turns from pure waiting turns

---
title: Closeout Worktree Dependencies
---

# Dependencies

Required local surfaces:

- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md`
- `.octon/framework/assurance/runtime/_ops/scripts/classify-change-closeout-residue.sh`

Required tools:

- `git status`
- `git diff`
- `git rev-parse`
- `git branch`
- `git ls-files`

No new external dependency is introduced. Git is already required by the
Change closeout and worktree autonomy contracts.

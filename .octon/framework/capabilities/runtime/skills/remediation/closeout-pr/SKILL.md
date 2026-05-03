---
name: closeout-pr
description: >
  PR-backed Change closeout subflow. Reviews the current task-scoped branch,
  creates or updates the PR selected by Change routing, monitors checks and
  unresolved conversations, applies the smallest credible remediation when
  failures appear, and records published, ready, landed, and cleaned lifecycle
  outcomes until merge or an explicit external blocker.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-04-17"
  updated: "2026-04-17"
skill_sets: [executor, collaborator, guardian, integrator]
capabilities: [external-dependent, long-running, stateful]
allowed-tools: Read Glob Grep Edit Bash(gh *) Bash(git status *) Bash(git diff *) Bash(git add *) Bash(git commit *) Bash(git push *) Bash(git rev-parse *) Bash(git branch *) Bash(git ls-files *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-pr-open.sh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh *) Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Closeout PR

PR-backed Change closeout subflow for one branch worktree.

## When to Use

Use this skill when:

- `closeout-change` or an equivalent canonical route selector has selected
  `branch-pr`
- work on a branch worktree has reached a credible completion point
- the branch should move through commit, push, PR, checks, review resolution,
  and merge without stopping at the first closeout mutation
- you want the same branch and same PR to remain the task container until
  merge or an explicit external blocker

## Quick Start

```markdown
/closeout-pr title="fix(workflow): harden helper retries"
```

Or, when a PR already exists:

```markdown
/closeout-pr pr="123"
```

## Core Workflow

1. **Review** — Start from the current branch worktree, inspect tracked,
   unstaged, and untracked changes, and define the task-scoped file set
2. **Commit** — Stage the intended files only and create a conventional commit
3. **Draft PR** — Push the current branch and create or update one draft PR
4. **Monitor** — Poll checks, mergeability, and unresolved review threads
5. **Remediate checks** — If a check fails, inspect the failing run, implement
   the smallest credible fix, validate locally, commit, push, and recheck
6. **Remediate conversations** — Treat unresolved conversations as a merge
   blocker; address them with `fix + commit + push + reply`
7. **Ready gate** — Move out of draft only when checks are green, no
   unresolved conversations remain, no author action items remain, and the
   merge lane is correct. Autonomous draft completion is allowed only for
   branch-pr PRs that are open, still draft, in the autonomous lane, green on
   required checks including `AI Review Gate / decision` when required, PR
   quality, branch naming, clean-state, and autonomy checks, free of blocking
   labels, requested changes, merge conflicts, stale head state, and
   unresolved author-action review threads, and backed by Change receipt or PR
   closeout evidence. High-impact PRs require explicit self-review of the diff,
   policy impact, evidence, and rollback path, but high impact alone is not a
   manual-lane blocker.
8. **Merge** — Request squash auto-merge or merge through the current
   protected-main route for the autonomous lane, or keep the PR ready in the
   manual lane only when a concrete blocker requires authorized human action
9. **Cleanup** — After merge, record local branch, remote branch, and worktree
   cleanup evidence or explicit deferred-cleanup evidence
10. **Stop condition** — Continue until merged or until a precise external
   blocker is reached and reported.

## Parameters

Parameters are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts an optional PR number/URL plus optional commit/PR metadata
and file-scope controls.

## Output Location

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.octon/state/evidence/validation/analysis/YYYY-MM-DD-pr-closeout-<run-id>.md`
  — Closeout report
- `/.octon/state/evidence/runs/skills/closeout-pr/` — Execution logs with index

## Boundaries

- Require upstream Change identity and selected route `branch-pr`, except when
  the task itself starts from an existing PR context
- Start from the current branch worktree, never from `main`
- Reuse the same branch and same PR for the life of the task
- Review tracked, unstaged, and untracked changes before staging
- Include only the files that belong to the intended task scope
- Never force-push, amend, or rebase during ordinary remediation
- Never treat helper output as proof of readiness or mergeability
- Never resolve reviewer-owned threads programmatically as the author unless
  the documented solo-maintainer exception applies: the actor is repository
  owner or maintainer, the fix has been committed and pushed, the thread has
  an evidence reply, required checks are green, and the resolution is recorded
  as conversation cleanup rather than approval
- GitHub required checks, branch policy, and unresolved conversations remain
  the final merge gate for PR-backed Changes only
- Draft/open PR state is `published`, not full closeout
- Ready PR state is `ready`, not landed
- Full PR-backed closeout requires merge evidence: `publication_status:
  pr-merged`, landed ref or merge ref, rollback handle, and cleanup disposition;
  without merge evidence, report a precise external blocker instead of
  completion
- Do not mark a draft PR ready, request auto-merge, or merge autonomously
  unless the autonomous draft completion policy in
  `.octon/framework/execution-roles/practices/pull-request-standards.md` is
  satisfied
- Do not bypass protected-main controls; GitHub required checks, rulesets,
  mergeability, and review policy remain authoritative at merge time
- Continue until merged or until a precise external blocker is reached and reported
- If progress cannot continue, report the exact blocker instead of claiming
  success

## When to Escalate

- The branch worktree contains unrelated changes that cannot be separated
  credibly
- A failing check is clearly infrastructure-only rather than code-related
- Review feedback is ambiguous or conflicting and cannot be resolved safely
- A concrete blocker requires human merge authority, credentials, policy
  acceptance, or product/security/legal/architectural judgment
- Required checks fail for a reason that cannot be safely remediated
  autonomously
- Required evidence, mergeability, rollback safety, or post-merge
  `origin/main` state cannot be proven
- Policies conflict or authority is ambiguous
- GitHub transport/auth problems prevent the next step from completing

Do not escalate merely because a PR is high-impact. Report the exact blocker,
evidence gathered, attempted remediation, and smallest human decision needed.

## References

For detailed documentation:

- [Behavior phases](references/phases.md) — Full phase-by-phase loop
- [Decision logic](references/decisions.md) — Lane, blocker, and stop decisions
- [Checkpoints](references/checkpoints.md) — Durable checkpoints inside the loop
- [I/O contract](references/io-contract.md) — Parameters, outputs, and tool surface
- [Safety](references/safety.md) — Git, PR, and review guardrails
- [Validation](references/validation.md) — Acceptance criteria for successful closeout
- [Dependencies](references/dependencies.md) — External tool requirements

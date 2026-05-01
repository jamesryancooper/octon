---
name: closeout-pr
description: >
  Autonomous Git/GitHub closeout loop for one branch worktree. Reviews the
  current task-scoped changes, creates or updates the branch PR, monitors
  checks and unresolved conversations, applies the smallest credible
  remediation when failures appear, and continues until merge or an explicit
  external blocker.
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

Autonomous Git/GitHub closeout loop for one branch worktree.

## When to Use

Use this skill when:

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
   merge lane is correct
8. **Merge** — Request squash auto-merge for the autonomous lane, or keep the
   PR ready in the manual lane until an authorized human merges it
9. **Stop condition** — Continue until merged or until a precise external
   blocker is reached and reported. Continue until merged or until a precise
   external blocker is reached and reported.

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
  the final merge gate
- Continue until merged or until a precise external blocker is reached and reported
- If progress cannot continue, report the exact blocker instead of claiming
  success

## When to Escalate

- The branch worktree contains unrelated changes that cannot be separated
  credibly
- A failing check is clearly infrastructure-only rather than code-related
- Review feedback is ambiguous or conflicting and cannot be resolved safely
- The PR is in the manual lane and requires human merge authority
- GitHub transport/auth problems prevent the next step from completing

## References

For detailed documentation:

- [Behavior phases](references/phases.md) — Full phase-by-phase loop
- [Decision logic](references/decisions.md) — Lane, blocker, and stop decisions
- [Checkpoints](references/checkpoints.md) — Durable checkpoints inside the loop
- [I/O contract](references/io-contract.md) — Parameters, outputs, and tool surface
- [Safety](references/safety.md) — Git, PR, and review guardrails
- [Validation](references/validation.md) — Acceptance criteria for successful closeout
- [Dependencies](references/dependencies.md) — External tool requirements

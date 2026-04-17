---
name: resolve-pr-comments
description: >
  Systematic resolution of pull request review comments. Fetches comments
  from a GitHub PR, classifies them by type and severity, applies fixes in
  a deterministic order, verifies each change, then completes the author
  remediation loop with commit, push, reply, and a structured completion
  report. Designed to close review ping-pong loops quickly without taking
  reviewer-owned thread resolution away from reviewers.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-02-09"
  updated: "2026-04-17"
skill_sets: [executor, guardian]
capabilities: [external-dependent]
allowed-tools: Read Glob Grep Edit Bash(gh) Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Resolve PR Comments

Systematic resolution of pull request review comments.

## When to Use

Use this skill when:

- A PR has received review comments that need to be addressed
- You want to resolve many review comments consistently and efficiently
- You need deterministic author-side remediation: fix, commit, push, reply
- You need to close a review round before re-requesting review
- Comments span multiple files and need coordinated resolution

## Quick Start

```
/resolve-pr-comments pr="123"
```

Or with a full URL:

```
/resolve-pr-comments pr="https://github.com/owner/repo/pull/123"
```

## Core Workflow

1. **Fetch** — Retrieve all unresolved review comments from the PR via `gh`
2. **Classify** — Group comments by type, severity, and affected file
3. **Plan** — For each comment group, determine the resolution strategy and
   isolate author action items
4. **Fix** — Apply fixes in dependency order (structural changes before
   cosmetic)
5. **Verify** — Confirm each fix addresses the reviewer's concern
6. **Commit** — Create intentional commit(s) for the addressed review work
7. **Push** — Publish the branch update so reviewers can inspect real changes
8. **Reply** — Respond on each addressed thread with what changed, or explain
   why no code change was needed
9. **Report** — Produce a structured resolution report and note whether
   re-requesting review is appropriate

### Resolution Order

Comments are addressed in this order to prevent cascading conflicts:

1. **Structural changes** — File moves, renames, API changes
2. **Logic fixes** — Bug fixes, correctness issues
3. **Design changes** — Architecture, pattern adjustments
4. **Style/formatting** — Naming, formatting, conventions
5. **Documentation** — Comments, docstrings, README updates
6. **Questions** — Responses that don't require code changes

### Comment Classification

| Type | Definition | Resolution |
|------|-----------|------------|
| BUG | Correctness issue identified by reviewer | Apply fix, add test if feasible |
| DESIGN | Architecture or pattern concern | Apply change or explain tradeoff |
| STYLE | Naming, formatting, convention violation | Apply change |
| NIT | Minor suggestion, optional | Apply if low-risk, skip with note if not |
| QUESTION | Reviewer asking for clarification | Respond in PR, no code change needed |
| OUT_OF_SCOPE | Valid concern but not for this PR | Acknowledge, defer to follow-up |

## Parameters

Parameters are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts one required parameter (`pr`) identifying the pull request,
plus optional parameters for filtering by reviewer and controlling scope.

## Output Location

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.octon/state/evidence/validation/analysis/YYYY-MM-DD-pr-comments-resolved.md` — Resolution report
- `/.octon/state/evidence/runs/skills/resolve-pr-comments/` — Execution logs with index

## Boundaries

- Never force-push or amend commits without explicit user approval
- Never dismiss or resolve PR comments programmatically — let the reviewer or
  a maintainer confirm
- Apply fixes via new commits, then push before replying so reviewer comments
  point at real artifacts
- Always leave a reply for each addressed review thread, or explain grouped
  handling clearly when one reply covers several comments
- Do not modify files outside the PR's changed file set without flagging
- If a comment requires a design decision, present options rather than
  choosing unilaterally
- Maximum scope: 50 unresolved comments per run (escalate if exceeded)

## When to Escalate

- Comment requires a design decision with significant tradeoffs — present options
- Comment conflicts with another reviewer's comment — flag the conflict
- Comment requires changes outside the PR scope — suggest follow-up PR
- Reviewer intent is ambiguous after inspection — ask for clarification rather
  than guessing
- More than 50 unresolved comments — recommend splitting into batches

## References

For detailed documentation:

- [Behavior phases](references/phases.md) — Full phase-by-phase instructions
- [I/O contract](references/io-contract.md) — Inputs, outputs, PR comment schema
- [Safety policies](references/safety.md) — Git safety, reviewer respect
- [Validation](references/validation.md) — Acceptance criteria for complete resolution
- [Examples](references/examples.md) — Resolution examples from real PRs
- [Dependencies](references/dependencies.md) — External tool requirements (gh CLI)

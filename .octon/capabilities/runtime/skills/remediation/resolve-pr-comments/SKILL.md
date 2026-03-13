---
name: resolve-pr-comments
description: >
  Systematic resolution of pull request review comments. Fetches comments
  from a GitHub PR, classifies them by type and severity, proposes and
  applies fixes in a deterministic order, verifies each resolution, and
  produces a structured completion report. Designed to close review
  ping-pong loops quickly without sacrificing quality.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-02-09"
  updated: "2026-02-10"
skill_sets: [executor, guardian]
capabilities: [external-dependent]
allowed-tools: Read Glob Grep Edit Bash(gh) Write(../../output/reports/*) Write(_ops/state/logs/*)
---

# Resolve PR Comments

Systematic resolution of pull request review comments.

## When to Use

Use this skill when:

- A PR has received review comments that need to be addressed
- You want to resolve many review comments consistently and efficiently
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
2. **Classify** — Group comments by type (bug fix, style, design, question, nit) and affected file
3. **Plan** — For each comment group, determine the resolution strategy
4. **Resolve** — Apply fixes in dependency order (structural changes before cosmetic)
5. **Verify** — Confirm each resolution addresses the reviewer's concern
6. **Report** — Produce a structured resolution report

### Resolution Order

Comments are resolved in this order to prevent cascading conflicts:

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

Parameters are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts one required parameter (`pr`) identifying the pull request, plus optional parameters for filtering by reviewer and controlling scope.

## Output Location

Output paths are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.octon/output/reports/analysis/YYYY-MM-DD-pr-comments-resolved.md` — Resolution report
- `_ops/state/logs/resolve-pr-comments/` — Execution logs with index

## Boundaries

- Never force-push or amend commits without explicit user approval
- Never dismiss or resolve PR comments programmatically — let the reviewer confirm
- Apply fixes via new commits (not amends) so reviewers can see incremental changes
- Do not modify files outside the PR's changed file set without flagging
- If a comment requires a design decision, present options rather than choosing unilaterally
- Maximum scope: 50 unresolved comments per run (escalate if exceeded)

## When to Escalate

- Comment requires a design decision with significant tradeoffs — present options
- Comment conflicts with another reviewer's comment — flag the conflict
- Comment requires changes outside the PR scope — suggest follow-up PR
- More than 50 unresolved comments — recommend splitting into batches

## References

For detailed documentation:

- [Behavior phases](references/phases.md) — Full phase-by-phase instructions
- [I/O contract](references/io-contract.md) — Inputs, outputs, PR comment schema
- [Safety policies](references/safety.md) — Git safety, reviewer respect
- [Validation](references/validation.md) — Acceptance criteria for complete resolution
- [Examples](references/examples.md) — Resolution examples from real PRs
- [Dependencies](references/dependencies.md) — External tool requirements (gh CLI)

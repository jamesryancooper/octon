---
name: closeout-change
description: >
  Route-neutral Change closeout. Resolves Change identity, selects direct-main,
  branch-only, PR-backed, or stage-only/escalated route from the canonical
  default work unit policy, records lifecycle outcome and Change receipt
  requirements, and delegates to PR-specific closeout only when branch-pr is
  selected.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-05-01"
  updated: "2026-05-01"
skill_sets: [executor, collaborator, guardian, integrator]
capabilities: [external-dependent, stateful, safety-bounded, self-validating]
allowed-tools: Read Glob Grep Edit Bash(git status *) Bash(git diff *) Bash(git add *) Bash(git commit *) Bash(git rev-parse *) Bash(git branch *) Bash(git ls-files *) Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Closeout Change

Route-neutral closeout for Octon's default work unit: the Change.

## When to Use

Use this skill when a Change has reached a credible completion or checkpoint
point and the next output route has not already been selected.

Use `closeout-pr` only after this skill or another canonical authority has
selected `branch-pr`, or when the task starts from an existing PR context.

## Core Workflow

1. **Resolve Change** — Identify the Change intent, scope, touched paths, and
   existing branch or PR context.
2. **Select Route** — Load
   `.octon/framework/product/contracts/default-work-unit.yml` and select exactly
   one route: `direct-main`, `branch-no-pr`, `branch-pr`, or
   `stage-only-escalate`.
3. **Select Outcome** — Resolve lifecycle outcome separately from route:
   `preserved`, `branch-local-complete`, `published-branch`, `published`,
   `ready`, `landed`, `cleaned`, `blocked`, `escalated`, or `denied`.
4. **Validate Evidence** — Check the route-required validation, review or
   waiver, durable history, receipt, and rollback evidence.
5. **Act Or Preserve** — Complete the route-specific next step or preserve state
   and report blockers.
6. **Record Receipt** — Produce or update a Change receipt shaped by
   `.octon/framework/product/contracts/change-receipt-v1.schema.json`.
7. **Delegate PR** — Invoke `closeout-pr` only when the selected route is
   `branch-pr`.

## Boundaries

- Do not open a PR unless route selection returns `branch-pr`.
- Do not create a branch merely because a Change exists.
- Do not claim direct-main completion without a commit, local validation
  evidence, Change receipt, and rollback handle.
- Do not claim `branch-no-pr` as `landed` without branch commit evidence, main
  integration evidence, landed ref, rollback handle, and cleanup disposition.
- For hosted `branch-no-pr` landing, run hosted no-PR landing preflight before
  mutation and require provider ruleset evidence, a pushed source branch, exact
  source SHA required checks, fast-forward-only update evidence, and proof that
  `origin/main` equals `landed_ref` after the push.
- If the provider ruleset requires PR for `main`, report a blocker for
  `branch-no-pr` hosted landing. Do not silently convert `branch-no-pr` to
  `branch-pr`; PR mutation requires selected route `branch-pr` or explicit
  operator reroute.
- Do not claim `branch-pr` as full closeout when the PR is only draft, open, or
  ready; full PR-backed closeout requires merge evidence or a precise external
  blocker.
- Do not treat stage-only evidence as completed durable history.
- Do not use proposal-local packet paths as runtime or policy dependencies.

## References

- [Phases](references/phases.md)
- [Decisions](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
- [I/O contract](references/io-contract.md)
- [Safety](references/safety.md)
- [Validation](references/validation.md)
- [Dependencies](references/dependencies.md)

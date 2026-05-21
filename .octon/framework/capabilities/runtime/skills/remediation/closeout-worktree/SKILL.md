---
name: closeout-worktree
description: >
  Dirty-worktree closeout wrapper. Inventories and partitions multiple local
  change sets, then routes each coherent candidate through singular
  closeout-change execution without replacing the Change default work unit.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-05-21"
  updated: "2026-05-21"
skill_sets: [executor, collaborator, guardian, integrator]
capabilities: [external-dependent, stateful, safety-bounded, self-validating]
allowed-tools: Read Glob Grep Bash(git status *) Bash(git diff *) Bash(git rev-parse *) Bash(git branch *) Bash(git ls-files *) Bash(bash .octon/framework/assurance/runtime/_ops/scripts/classify-change-closeout-residue.sh *) Bash(bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh *) Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Closeout Worktree

Dirty-worktree wrapper for decomposing multiple local change sets into
singular `closeout-change` runs.

## When to Use

Use this skill when the operator asks to close out a worktree, close out all
local changes, or resolve a dirty repository state that may contain more than
one coherent Change.

Use `closeout-change` directly when the current scope is already one coherent
Change. Use `closeout-pr` only after a singular Change route resolves to
`branch-pr`.

## Core Workflow

1. **Bind Constraints** — Load the default work unit policy, Change Closeout
   State Machine, Git/worktree autonomy contract, and `closeout-change`
   contract.
2. **Inventory Worktree** — Capture branch, HEAD, `main`, `origin/main`,
   staged, unstaged, untracked, ignored, branch, and remote state.
3. **Classify Residue** — Run the read-only residue classifier and classify
   staged, unstaged, untracked, ignored, generated, host-projection, evidence,
   release, input-surface, and branch residue.
4. **Partition Candidate Changes** — Group residue into candidate Change
   scopes by intent, touched paths, branch identity, receipt references,
   validation requirements, and operator instructions.
5. **Resolve Ambiguity** — Ask or stop when ownership, grouping, target
   outcome, route, validation floor, cleanup authority, or destructive action
   would be ambiguous.
6. **Select One Candidate** — Choose exactly one coherent candidate Change for
   the next closeout attempt. Multiple candidates alone is not a blocker;
   stop before delegation only when the selected candidate has a
   candidate-keyed blocker.
7. **Delegate Singular Closeout** — Route the selected candidate through
   `closeout-change` with explicit include/exclude paths, route hints, target
   outcome, and receipt refs when known.
8. **Re-inventory** — After each delegated closeout attempt, re-run inventory
   and classification before selecting another candidate.
9. **Repeat Or Stop** — Continue selecting and delegating one candidate at a
   time while coherent candidates remain. Stop only when every candidate is
   closed, retained, blocked, escalated, deferred, or foreign with evidence,
   or when the next selected candidate has a candidate-keyed blocker.
10. **Wrapper Report** — Record the final worktree disposition: closed
    Changes, retained candidates, blocked or escalated items, evidence refs,
    and next route condition.

## Wrapper Evidence

Write wrapper reports as `schema_version: closeout-worktree-report-v1`. The
report must record the initial inventory, read-only residue classification,
observed candidate count, selected candidate, candidate boundaries,
orchestration iterations, delegated `closeout-change` evidence, retained
residue, blockers, final candidate dispositions, final inventory, and
next-route condition.

For every selected or delegated candidate, include explicit
`boundaries.include_paths` and `boundaries.exclude_paths`. Multiple observed
change sets must be represented as multiple candidate records, not batched into
one Change receipt or used as a reason to block a safely separable selected
candidate.

Each new report must include an `iterations` list. Every delegated or closed
candidate must have an iteration that records pre-inventory, pre-classification,
selected candidate id, include/exclude paths, singular `closeout-change`
reference, `closeout-change` outcome, post-inventory, post-classification, and
the next selection reason. Every report must include
`final_candidate_dispositions` keyed by candidate id with final state `closed`,
`retained`, `blocked`, `escalated`, `deferred`, or `foreign`; closed
candidates must cite the singular `closeout-change` receipt, log, or evidence
reference under `.octon/state/evidence/runs/skills/closeout-change/`; synthetic
route labels are not sufficient closeout evidence.

Candidates with `retained`, `deferred`, or `foreign` disposition must have
candidate-keyed `retained_residue` entries covering their included boundary
paths. Candidates with `blocked`, `escalated`, or `ambiguous` disposition must
have candidate-keyed blocker evidence, and reports with unresolved candidates
must not use a terminal `next_route_condition` such as `none`. Reports that
supersede or continue an earlier wrapper partition must reconcile every prior
candidate as still present, folded, retained, blocked, escalated, deferred, or
foreign. Reports whose final classifier summary shows ignored residue must
include retained or foreign ignored-residue evidence. Validate the report with
`.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh --report <path>`
before claiming worktree closeout.

## Boundaries

- Do not replace the default work unit; the unit remains one Change.
- Do not create a `Closeout Changes` model, command, or competing closeout
  route.
- Do not stage, commit, push, open a PR, land, merge, delete, restore, reset,
  or overwrite directly from this wrapper. Those material actions belong to a
  selected singular `closeout-change` route.
- Do not close unrelated residue under one receipt.
- Do not treat detection as deletion authority.
- Do not use `.octon/inputs/**`, proposal-local files, generated outputs, host
  state, GitHub state, chat, model memory, or tool availability as closeout
  authority.
- Do not continue when a candidate cannot be separated without touching
  ambiguous or user-owned work.
- Do not claim full worktree closeout while any retained, blocked, ambiguous,
  or foreign candidate remains undocumented.

## References

- [Phases](references/phases.md)
- [Decisions](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
- [I/O contract](references/io-contract.md)
- [Safety](references/safety.md)
- [Validation](references/validation.md)
- [Dependencies](references/dependencies.md)

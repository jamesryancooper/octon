---
name: repo-hygiene-cleanup
description: >
  Receipt-backed repository hygiene cleanup for local Octon run artifacts.
  Classifies untracked local residue, emits optional cleanup authorization
  receipts, and performs deletion only through explicit confirmation or a
  validating receipt.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-05-21"
  updated: "2026-05-21"
skill_sets: [executor, guardian]
capabilities: [external-dependent, stateful, safety-bounded, self-validating]
allowed-tools: Read Glob Grep Bash(git status *) Bash(git ls-files *) Bash(bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh *) Bash(bash .octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh *) Write(/.octon/state/evidence/runs/skills/repo-hygiene-cleanup/*) Write(/.octon/state/evidence/validation/analysis/*)
---

# Repo Hygiene Cleanup

Receipt-backed cleanup for untracked local Octon run, control, evidence, and
scratch artifacts.

## When to Use

Use this skill when a worktree contains local `.octon/state/**` or
`.octon/generated/.tmp/**` residue and the operator wants a bounded cleanup
route after classification.

Do not use this skill to implement proposals, clean generated run-health
projections, delete branches, remove tracked files, clean input packets, or
rewrite durable framework or instance authority.

## Workflow

1. **Bind Authority** - Read
   `.octon/instance/governance/policies/repo-hygiene.yml`,
   `.octon/framework/product/contracts/repo-hygiene-cleanup-authorization-v1.schema.json`,
   and the helper contract in
   `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`.
2. **Inventory** - Capture `git status --short`, relevant untracked paths, and
   any operator-provided include or exclude intent. Treat generated outputs,
   host state, proposal-local files, chat, memory, and tool availability as
   evidence at most, never cleanup authority.
3. **Classify First** - Run the helper without mutation. Retain its summary,
   cleanup candidate count, protected referenced count, manual-review count,
   status digest, classification digest, cleanup path-set digest, protected
   paths digest, and manual-review paths digest.
4. **Select Route** - Use one of two delete routes only:
   `--confirm` for explicit operator action, or `--authorize <receipt.json>`
   followed by `--authorization <receipt.json>` for receipt-backed cleanup.
   If the operator did not authorize deletion, stop after classification.
5. **Receipt Route** - When using the receipt route, store the emitted
   `repo-hygiene-cleanup-authorization-v1` receipt under retained evidence,
   then invoke the helper with `--authorization`. The helper must revalidate
   current git refs, status digest, classification digest, path-set digest,
   protected digest, manual-review digest, proof bits, and exact path set
   before deleting anything.
6. **Record Evidence** - Write a run log under
   `.octon/state/evidence/runs/skills/repo-hygiene-cleanup/<run-id>/` with the
   helper output, receipt ref when one exists, deleted path list, retained
   protected paths, retained manual-review paths, and any blocker.
7. **Validate** - Run
   `.octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh`
   after any durable policy, helper, schema, or skill-surface change.

## Fail Closed

Stop before deletion when the receipt is missing, unreadable, malformed,
denied, expired, stale, path-mismatched, proof-incomplete, or attempts to cover
a tracked, referenced, protected, manual-review, input, durable evidence,
active control, generated authority, generated run-health, ignored, or
user-owned path.

Generated run-health projection pruning remains owned by
`generate-run-health-read-model.sh --all-runs` and its `pruned_paths` evidence.
This skill must not delete
`.octon/generated/cognition/projections/materialized/runs/**`.

## Boundaries

- Do not delete without `--confirm` or a validating
  `repo-hygiene-cleanup-authorization-v1` receipt.
- Do not treat dry-run classification, generated views, or proposal-local files
  as deletion authority.
- Do not bypass filesystem, sandbox, host, provider, runtime, or platform
  safety controls.
- Do not claim full worktree closeout; this skill only handles repo-hygiene
  cleanup candidates within the helper's current scope.

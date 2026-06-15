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
allowed-tools: Read Glob Grep Bash(git status *) Bash(git ls-files *) Bash(bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh *) Bash(bash .octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh *) Write(/.octon/state/evidence/local/runs/skills/repo-hygiene-cleanup/*) Write(/.octon/state/evidence/runs/skills/repo-hygiene-cleanup/*) Write(/.octon/state/evidence/validation/analysis/*)
---

# Repo Hygiene Cleanup

Receipt-backed cleanup for untracked local Octon run, control, evidence, and
scratch artifacts.

## When to Use

Use this skill when a worktree contains local `.octon/state/**` or
`.octon/generated/.tmp/**` residue and the operator wants a bounded cleanup
route after classification. `closeout-worktree` may delegate eligible residue
to this skill during routine cleaned closeout; this skill remains a hygiene
subroute and does not replace `closeout-change` or authorize branch cleanup.

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
3. **Classify First** - Run the helper without mutation. Retain raw helper
   output, local-only path details, and sensitive debugging context under
   `.octon/state/evidence/local/runs/skills/repo-hygiene-cleanup/<run-id>/`.
   Publish only summary counts and digests unless a later receipt explicitly
   redacts and promotes a shareable summary.
   Terminal closeout sink files under
   `.octon/state/evidence/local/terminal-closeout/<change-id>/` are
   local-private retained evidence and are protected from generic cleanup.
4. **Select Route** - Use one of two delete routes only:
   `--confirm` for explicit operator action, or `--authorize <receipt.json>`
   followed by `--authorization <receipt.json>` for receipt-backed cleanup.
   Use `--cleanup-path <repo-relative-path>` when the cleanup should be
   limited to one or more selected current cleanup candidates. The receipt
   route may proceed without another operator prompt only when the helper's
   current classification contains exact selected untracked, unreferenced
   cleanup candidates and no protected, manual-review, user-owned, generated
   run-health, active control, durable evidence, tracked,
   generated-authority, or proposal-input file path is included. Untracked,
   unreferenced `.DS_Store` paths may be selected only as
   `local_filesystem_metadata`, including below inputs roots. If neither delete
   route is available or valid, stop after classification.
5. **Receipt Route** - When using the receipt route, store the emitted
   `repo-hygiene-cleanup-authorization-v1` receipt under retained evidence,
   then invoke the helper with `--authorization`. The helper must revalidate
   current git refs, status digest, classification digest, path-set digest,
   protected digest, manual-review digest, proof bits, and exact selected path
   set before deleting anything. Raw receipt-generation logs stay local-private
   when they include local paths or operator-sensitive details.
6. **Record Evidence** - Write a concise publishable receipt under
   `.octon/state/evidence/runs/skills/repo-hygiene-cleanup/<run-id>/` with the
   route, helper summary, digest set, redaction posture, authorization receipt
   ref when one exists, local evidence ref plus digest, deleted count, retained
   protected count, retained manual-review count, and any blocker. Do not embed
   raw helper output, raw deleted path lists, raw retained path lists, or
   `.octon/state/evidence/local/**` payloads in the publishable receipt.
7. **Validate** - Run
   `.octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh`
   after any durable policy, helper, schema, or skill-surface change.

## Fail Closed

Stop before deletion when the receipt is missing, unreadable, malformed,
denied, expired, stale, path-mismatched, proof-incomplete, or attempts to cover
a tracked, referenced, protected, manual-review, proposal input file, durable
evidence, active control, generated authority, generated run-health, or
user-owned path. Ignored `.DS_Store` paths are eligible only when the helper
classifies them as untracked, unreferenced local filesystem metadata.
Terminal closeout sink files are eligible for deletion only through a separate
explicit local-private evidence cleanup route that selects those paths by
operator intent; they are never generic local run residue cleanup candidates.

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
- Do not use local-private raw logs under `.octon/state/evidence/local/**` as
  hosted/shared closeout evidence; hosted/shared claims require concise
  publishable receipts under
  `.octon/state/evidence/runs/skills/repo-hygiene-cleanup/<run-id>/`.
- Do not delete branches, tracked files, proposal inputs, generated run-health
  projections, durable evidence, terminal closeout local evidence sink files,
  active control state, detached Git worktrees, ignored non-metadata paths, or
  user-owned paths.
- Treat `lifecycle-interaction-request-v1` receipts as non-authorizing context.
  They may identify why hygiene was requested, but deletion still requires
  helper classification plus explicit confirmation or a validating
  `repo-hygiene-cleanup-authorization-v1` receipt that matches the selected
  current path set and proof bits.

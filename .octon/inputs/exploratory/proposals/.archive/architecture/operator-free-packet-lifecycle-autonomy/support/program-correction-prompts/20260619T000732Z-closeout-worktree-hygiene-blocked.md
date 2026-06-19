prompt_id: operator-free-packet-lifecycle-autonomy-closeout-worktree-hygiene-correction-20260619T000732Z
generated_at: 2026-06-19T00:07:32Z
generated_by: octon-proposal-lifecycle-generate-program-correction-prompt
target_program: .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
finding_id: closeout-worktree-hygiene-blocked
finding_scope: parent
finding_owner: parent-closeout-worktree-hygiene
artifact_class: operational-aid
authority: non-authoritative

# Program Correction Prompt: Closeout Worktree Hygiene Blocked

## Finding

The parent program closeout route for
`.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`
is blocked by final worktree hygiene.

The required classifier command:

```bash
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh --target .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --lifecycle proposal-program --format yaml
```

reported:

```yaml
worktree_hygiene_verdict: blocked
worktree_hygiene_blocker_class: worktree-hygiene-blocked
worktree_hygiene_owned_path_count: 0
worktree_hygiene_in_scope_path_count: 213
worktree_hygiene_foreign_path_count: 21
worktree_hygiene_foreign_fingerprint: sha256:05c4446b912ca575a102d676c48f3bfc5d0c2f67eb5248c06d9cd4ec6f718a95
next_route_condition: route through closeout-change or operator scope resolution before proposal archive authorization
```

## Correction Goal

Resolve or explicitly route the foreign or ambiguous worktree paths so the
parent closeout classifier can distinguish parent closeout scope from unrelated
or linked-proposal residue. Do not archive, clean, land, publish, delete,
branch-clean, or claim `cleaned` from this correction prompt.

## Constraints

- Preserve parent `proposal.yml#status: implemented`.
- Do not mutate child packets.
- Do not use parent evidence to satisfy child-owned evidence.
- Do not recreate child evidence casually; inspect retained child receipts and
  retained-run evidence indexes only as evidence.
- Do not hand-edit generated outputs.
- Do not delete local residue unless a separate cleanup route is explicitly
  authorized and the cleanup receipt permits deletion.
- Do not stage, commit, push, archive, branch-clean, or claim `cleaned` from
  this correction route.

## Required Route

1. Start with fresh ingress and worktree preflight.
2. Inspect the current `git status --short` and the classifier partition.
3. Classify each foreign or ambiguous path as one of:
   - linked proposal work that must be closed out or scope-accepted separately;
   - unrelated residue that requires operator scope resolution;
   - generated output requiring canonical generator verification;
   - protected evidence or control residue that must be retained;
   - cleanup candidate requiring explicit cleanup authorization.
4. If a separate linked proposal or Change closeout is required, route it
   explicitly. Do not silently absorb it into this parent program.
5. Rerun:

```bash
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh --target .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --lifecycle proposal-program --format yaml
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --run-registry-check
```

6. Rerun the parent closeout route from fresh preflight only after classifier
   verdict is `pass`.

## Acceptance Criteria

- The classifier reports `worktree_hygiene_verdict: pass` for the parent
  program, or a human/operator route explicitly accepts the remaining scope and
  the classifier no longer reports foreign or ambiguous paths for closeout.
- Parent status remains `implemented`.
- Child packets remain unmodified.
- No archive, cleanup, landing, publication, deletion, branch cleanup, or
  `cleaned` claim occurs.
- A future parent `support/proposal-closeout.md` may authorize archive only
  after the closeout route itself passes all gates and records
  `archive_authorized: yes`.

## Current Blocked Receipt

The blocked closeout receipt is:

`.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy/support/proposal-closeout.md`

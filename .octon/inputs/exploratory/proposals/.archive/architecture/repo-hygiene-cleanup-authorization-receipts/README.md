# Repo Hygiene Cleanup Authorization Receipts

## Findings

High: current repo hygiene still depends on late operator confirmation for
local artifact deletion. The policy and helper already classify untracked local
run/control/evidence residue, protect referenced files, and default to dry-run,
but deletion still depends on `--confirm`. The target architecture should add a
retained authorization receipt and make the helper accept a validating receipt
as an alternative non-dry-run path.

High: `Closeout Worktree` can classify and route hygiene residue, but it must
not delete it. The wrapper remains responsible for inventory, partitioning,
delegation, retained residue reporting, and next-route conditions only.

Medium: generated run-health pruning is generator-owned. The run-health
generator already records `pruned_paths`, and generic local-run artifact cleanup
must not claim or delete generated run-health projection residue.

## Recommendation

Implement this as repo-hygiene authorization receipts plus helper hardening,
with one narrow `repo-hygiene-cleanup` skill route for operator-facing workflow.
Do not create `Closeout Changes`, do not move cleanup authority into `Closeout
Worktree` or singular `Closeout Change`, and do not add a new broad command.

## Profile Selection Receipt

- release_state: pre-1.0
- change_profile: atomic
- rationale: The change affects destructive cleanup authorization boundaries
  and should land as one coherent, validator-backed architecture change.
- proposal_authority: non-authoritative input packet only

## Packet Contents

This packet defines the proposed receipt model, helper behavior, closeout
integration, validation, and acceptance criteria needed before implementation.
The source prompt and findings are retained under `resources/` as lineage, not
as policy or runtime authority.

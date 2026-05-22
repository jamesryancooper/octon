# Source Findings

This resource records source findings used to draft the proposal. It is lineage
only and is not policy, runtime authority, or cleanup authorization.

## Findings

High: current repo hygiene still uses late operator confirmation, not governed
cleanup authorization. Current policy requires explicit `--confirm` operator
action, and `cleanup-local-run-artifacts.sh` is dry-run by default and deletes
only with `--confirm`. Required change: add a repo-hygiene cleanup
authorization receipt and make the helper accept `--authorization <receipt>` as
an alternative to ad hoc `--confirm`.

High: `Closeout Worktree` can classify and route hygiene, but must not delete.
The wrapper inventories, partitions, delegates, and reports; it does not
mutate. Required change: `Closeout Worktree` should record repo-hygiene
classification and next route, while cleanup execution belongs to repo hygiene.

Medium: generated run-health pruning is a separate governed path. Generic
cleanup covers `.octon/state/**` and `.octon/generated/.tmp/**`, not generated
cognition run-health projections. Run-health generation already records
`pruned_paths` during generator-owned pruning. Required change: keep run-health
pruning generator-owned and do not route it through local-run artifact cleanup.

## Recommendation

Implement repo-hygiene authorization receipts plus helper hardening, with a
narrow repo-hygiene cleanup route or skill if an operator-facing workflow is
needed. Do not add `closeout-residue`, and do not move cleanup authority into
`Closeout Worktree` or `Closeout Change`.

## Authorization Model

Add `repo-hygiene-cleanup-authorization-v1` with schema version,
authorization id, creation time, policy/helper/repo refs, git refs,
classification refs and digests, cleanup path-set digest, authorized path
proofs, protected/manual-review digests, discard or rollback posture,
authorization result, and freshness or expiry fields.

## Eligible Cleanup Classes

Eligible cleanup is limited to untracked, unreferenced local publish,
service-build, runtime-agent-quorum, superseded publication-attempt, and
generated scratch residue under explicit patterns. Generated run-health stale
paths are eligible only through the run-health generator with `pruned_paths`.

## Retained Or Manual Classes

Tracked files, referenced files, `.octon/inputs/**`, durable closeout receipts,
active control or continuity state, build-to-delete evidence, claim-adjacent
evidence, host projections, ignored local files, generated effective artifacts,
and paths outside explicit cleanup patterns must remain retained or
manual-review.

## Helper Behavior

The helper should support dry-run, `--authorize <out.json>`,
`--authorization <receipt.json>`, and manual `--confirm`. Receipt-backed
cleanup must recompute classification, verify exact path-set and digest
matches, and fail closed on stale, malformed, denied, path-mismatched, tracked,
referenced, protected, or manual-review candidates.

## Closeout Integration

`Closeout Worktree` should add report fields for repo-hygiene classification,
authorization refs, cleanup candidates, protected referenced paths,
manual-review paths, cleanup actions performed as false, and next-route
condition. `Closeout Change` should avoid global hygiene claims; cleaned means
selected route cleanup only.

# Target Architecture

The corrective architecture is a six-child proposal program:

1. Architecture review freshness guards ensure digest-bound parent and child
   review receipts cannot silently drift.
2. Delivery receipt completion guards require a concrete Proposal Program
   Delivery receipt and evidence index before clean-delivery claims.
3. Change closeout reconciliation records hosted landing, local main sync,
   source branch cleanup, and terminal proof after manual or route-owned Git
   completion.
4. Cleanup disposition separates classifier detection, preserve/exclude
   evidence, repo-hygiene authorization, and final terminal cleanliness.
5. Validator hardening expands aggregate clean-delivery checks and negative
   controls.
6. Test hermeticity keeps assurance tests from dirtying tracked generated read
   models.

## Authority Model

The parent program coordinates ordering only. Each child packet owns its own
promotion targets and retained evidence. Proposal Program Delivery owns
aggregate delivery receipts. Change closeout owns Git landing, sync, branch
cleanup, and terminal proof. Repo-hygiene cleanup owns deletion.

## Terminal Claim Model

`completed` child lifecycle evidence cannot imply `git_clean_terminal`.
Terminal claims require fresh delivery receipt validation, Change closeout
alignment, live remote proof where applicable, terminal current-state proof,
worktree hygiene, and final clean Git status after the last mutation.

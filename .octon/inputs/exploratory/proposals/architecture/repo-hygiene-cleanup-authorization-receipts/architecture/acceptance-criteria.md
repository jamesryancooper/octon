# Acceptance Criteria

1. `repo-hygiene-cleanup-authorization-v1` exists as a strict schema and is
   referenced by repo-hygiene policy and validation.
2. `cleanup-local-run-artifacts.sh --authorize <out.json>` emits a receipt that
   binds policy/helper refs, git refs, status digest, classification digest,
   path-set digest, protected/manual-review digests, and rollback or discard
   posture.
3. `cleanup-local-run-artifacts.sh --authorization <receipt.json>` revalidates
   current classification and deletes only the exact authorized cleanup path set
   without requiring ad hoc `--confirm`.
4. Missing, malformed, denied, stale, path-mismatched, status-drifted, tracked,
   referenced, protected, manual-review, ignored, input-surface, durable
   evidence, active control, generated authority, and generated run-health
   candidates fail closed.
5. Generated run-health stale projection pruning remains owned by
   `generate-run-health-read-model.sh` and is evidenced through `pruned_paths`.
6. `repo-hygiene-cleanup` exists as a narrow remediation skill and is registered
   in the skill manifest, registry, and remediation group.
7. `Closeout Worktree` reports route repo-hygiene cleanup without performing
   cleanup, and validation rejects reports that claim wrapper cleanup authority.
8. `Closeout Change` documentation makes cleaned outcomes route-bound and does
   not imply global worktree hygiene.
9. Repo-hygiene governance validation, cleanup helper tests, closeout-worktree
   wrapper validation, and skill validation pass.
10. Runtime/platform approval boundaries remain explicit: governance receipts
    authorize only Octon cleanup policy, not filesystem, sandbox, host, or
    provider permission bypass.

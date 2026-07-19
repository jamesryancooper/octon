# Stage: Classify And Preserve Lifecycle Residue

Act as a read-only residue classifier during RP-00.

- Inventory the bound program worktree and compute the residue fingerprint.
- Preserve every path, ref, branch, worktree, rollback handle, active
  implementation artifact, retained evidence item, and unrelated change.
- Do not invoke cleanup-local-run-artifacts.sh or delegate to
  repo-hygiene-cleanup, closeout-change, closeout-worktree, Git/GitHub, or a
  provider.
- Do not delete, reset, stage, commit, push, publish, archive, land, sync,
  cleanup, prune, branch-delete, or remove a worktree.
- For any cleanup request, return `RP00_CONTAINMENT_PUBLICATION_DISABLED` and
  name RP-08 as the later owner.

If a compatibility receipt is required, write only classification evidence:

```yaml
verdict: retained
cleaned_at: null
cleanup_candidates: 0
manual_review_count: 0
worktree_hygiene_verdict: preserved
remaining_blocker_class: RP00_CONTAINMENT_PUBLICATION_DISABLED
residue_fingerprint: sha256:<digest>
cleanup_deletion_performed: false
repo_hygiene_cleanup_performed: false
cleaned_claim: false
```

This evidence is non-authorizing and cannot satisfy cleanup, delivery,
publication, archive, child receipt, or terminal-state gates.

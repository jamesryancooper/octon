---
schema_version: closeout-change-containment-receipt-v1
receipt_id: external-tool-integrity-amendment-20260719T193436Z
recorded_at: 2026-07-19T19:34:36Z
change_id: external-tool-integrity-amendment
selected_route: branch-pr
branch_pr_predicate: explicit-operator-pr-request
target_lifecycle_outcome: published
lifecycle_outcome: preserved
closeout_outcome: continued
integration_status: not-landed
publication_status: local-only
cleanup_status: deferred
branch: chore/external-tool-integrity
base_ref: origin/main@72391b18d9341bce4e7ba109ec8db11ef2389f92
candidate_digest: sha256:88c39435049a5ab0148d49287200aa83667d98c9931c0b517bc59c189082c8ff
next_owning_route: closeout-pr
---

# External Tool Integrity Amendment Preservation

The clean branch reconstructs only the manifest-backed external-tool-integrity
amendment from current `origin/main`. The independent `branch-pr` predicate is
the operator's explicit protected-main PR reconstruction authorization.

The candidate contains 70 amendment paths, preserves newer owner-lane registry
content, and excludes the dirty canonical-main checkout plus all proposal,
generated, older closeout/RP-00, provider, credential, and runtime-
implementation residue. Fresh closed-book charter-audit evidence reports no
direct contradiction.

The amendment-specific validator, architecture workflow and receipt gates,
proposal fixture matrices, syntax/YAML checks, and `git diff --check` pass. The
only broad non-pass observation is the pre-existing two-path framing finding in
an unrelated proposal package.

The branch and worktree are the pre-landing rollback container. Cleanup remains
deferred under SI-00. The next owner is `closeout-pr`, targeting one draft PR.

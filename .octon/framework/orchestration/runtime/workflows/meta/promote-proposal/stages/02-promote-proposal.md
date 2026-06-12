---
title: Promote Proposal
description: Rewrite the proposal to implemented state after proving that promotion targets are materialized and independent from proposal-local paths.
---

# Step 2: Promote Proposal

## Actions

1. Validate every `promotion_evidence` path is repo-relative, already exists,
   durable-target-bound, and independent from proposal-local paths.
2. Fail closed unless every promotion target exists.
3. Fail closed if any promotion target still references the proposal path or archive path.
4. For program child invocations, fail closed on parent-owned, wrong-child,
   missing, stale, generated-only, or lineage-mismatched promotion evidence;
   the program runner must perform selected-child binding before this workflow
   rewrites status.
5. Write or refresh `support/implementation-conformance-review.md` with a
   passing conformance verdict, checked evidence, promotion target coverage,
   implementation map coverage, validator coverage, generated output coverage,
   rollback coverage, downstream reference coverage, exclusions, and closeout
   recommendation.
6. Write or refresh `support/post-implementation-drift-churn-review.md` with a
   passing drift/churn verdict, backreference scan, naming drift review,
   generated projection freshness, manifest/schema validity, projection
   boundary review, target-family review, churn review, validators run,
   exclusions, and closeout recommendation.
7. Rewrite `proposal.yml` from `status: accepted` to `status: implemented`.
8. Regenerate `generated/proposals/registry.yml` from manifests instead of editing it manually.
9. Run `validate-proposal-implementation-conformance.sh --package <proposal_path>`.
10. Run `validate-proposal-post-implementation-drift.sh --package <proposal_path>`.
11. Regenerate the proposal artifact index and run
    `validate-proposal-lifecycle-terminal-freshness.sh --proposal
    <proposal_path> --run-registry-check` after the last support receipt or
    status mutation.

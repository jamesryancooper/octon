# Proposal Program Delivery Workflow

This workflow coordinates target-owned child implementation or archive-
readiness evidence in `execution_order_policy` child-before-parent order. It
admits only `implemented` or `archive-ready` with `route=stage-only`.

Admission requires a profile path, delivery run id, explicit outcome, a
retained readiness receipt, and `delivery-readiness-preflight`. The profile is
validated by `validate-proposal-program-delivery-profile.sh`. Direct-main,
hosted branch-no-PR, landing, sync, cleanup, landed/synced/cleaned, and
omitted/default requests stop with `RP00_CONTAINMENT_PUBLICATION_DISABLED`.

The exact aggregate `proposal-program-delivery-receipt` and evidence-only
`proposal-program-delivery-evidence-index` are validated by
`validate-proposal-program-delivery-receipt.sh` and
`validate-proposal-program-delivery-evidence-index.sh`. A parent summary never
replaces target-owned child receipts. The order override receipt compatibility uses
`proposal-program-delivery-order-override-receipt-v1` and remains
non-authorizing.

Feature-catalog-drift evidence uses `feature-catalog-drift-receipt-v1` and
`validate-feature-catalog-drift-closeout.sh`; unresolved child or parent feature-catalog drift blocks completed delivery.
The include-path classification,
route-owned clean worktree evidence, and lifecycle postmortem threshold records
remain diagnostic only.

The workflow does not delegate to closeout-change, closeout-worktree,
repo-hygiene-cleanup, Git/GitHub, provider, archive relocation, branch cleanup,
or publication. Exact child and parent work remains preserved and RP-06/RP-08
are named only as later owners.

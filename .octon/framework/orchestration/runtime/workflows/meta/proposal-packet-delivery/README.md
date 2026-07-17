# Proposal Packet Delivery Workflow

The workflow coordinates an accepted packet to `implemented` or
`archive-ready` with `route=stage-only`. It preserves exact work and disables
publication effects during RP-00.

Admission requires `profile_path`, `delivery_run_id`, an explicit target
outcome, and `validate-proposal-packet-delivery-profile.sh`. Direct-main,
hosted branch-no-PR, landing, sync, cleanup, landed/synced/cleaned, and
omitted/default effectful requests stop with
`RP00_CONTAINMENT_PUBLICATION_DISABLED`.

The stages retain the existing target-owned lifecycle boundaries:

- `run-packet-implementation` owns implementation;
- `promote-proposal` owns promotion;
- `closeout-packet` and `proposal-packet-terminal-closeout` own readiness;
- `archive-proposal` is only a later named owner and is not invoked here; and
- proposal-packet-delivery-order-override evidence remains evidence-only.

The aggregate `proposal-packet-delivery-receipt` is validated with
`validate-proposal-packet-delivery-receipt.sh` and never replaces target-owned
receipts. Feature-catalog-drift uses `feature-catalog-drift-receipt-v1` and
`validate-feature-catalog-drift-closeout.sh`; unresolved feature-catalog drift blocks completed delivery.
The receipt retains explicit blockers and the next owning lifecycle.

The pre-archive and already-archived states are classified without archive
relocation. The partition-clean archive readiness route and
`validate-proposal-packet-delivery-order-override-receipt.sh` cannot authorize
Git/GitHub mutation, Change closeout, closeout-worktree delegation,
repo-hygiene-cleanup, landing, sync, cleanup, or a success claim. PR fallback forbidden
is the governing posture.

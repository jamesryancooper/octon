# Acceptance Criteria

The implementation is acceptable only when all applicable criteria pass.

## Delivery Route

- `/proposal-packet-delivery target=<proposal-packet-path> outcome=cleaned route=branch-no-pr [profile=<profile-path>] [run-id=<id>]` is documented and published.
- The route validates accepted packet state, fresh proposal review
  authorization, implementation authorization, and implementation readiness
  before implementation.
- The route refuses PR fallback when `route=branch-no-pr`.

## Authority Preservation

- Packet implementation runs through the packet implementation route.
- Proposal status transition to `implemented` runs through `promote-proposal`
  after conformance and drift/churn receipts pass.
- Packet archive authorization runs through `closeout-packet` and
  `support/proposal-closeout.md`.
- Terminal closeout runs through proposal packet terminal closeout.
- Archive runs through archive-proposal with disposition `implemented`.
- Git mutation, hosted landing, final sync, and branch cleanup run through
  closeout-change or closeout-worktree and governed branch helpers.
- Repo-hygiene deletion runs only through repo-hygiene-cleanup authorization.
- Generated proposal and capability projections are refreshed only through
  owning scripts.

## Receipt Binding

- `proposal-packet-delivery-receipt-v1` validates and records source receipt
  refs for implementation, conformance, drift/churn, promote-proposal,
  closeout-packet, terminal closeout, archive, generated publication freshness,
  Change closeout, hosted landing authorization, cleanup authorization,
  terminal proof, and final git status.
- The aggregate receipt cannot replace source receipts or mint authority.

## Terminal Cleaned Claim

- Cleaned requires local `main == origin/main == landed_ref`.
- Cleaned requires `git status --short` to be empty.
- Missing promote-proposal receipt, closeout-packet archive authorization,
  branch-no-pr authorization, archive authorization, cleanup authorization,
  final sync proof, or clean-worktree proof blocks cleaned.

## Validation

- Proposal packet delivery workflow/profile/receipt validators pass.
- Capability publication validation passes after command and skill publication.
- Generated proposal registry and packet artifact freshness checks pass.
- Negative controls fail closed for stale receipts, missing authorization,
  PR fallback, generated authority overclaims, proposal-local authority
  overclaims, and dirty-worktree cleaned overclaims.
- Final validation includes `git diff --check`.

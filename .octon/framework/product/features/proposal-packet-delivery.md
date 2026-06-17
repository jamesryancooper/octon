# Proposal Packet Delivery

Proposal Packet Delivery is the runtime-facing workflow surface for delivering a
single accepted proposal packet.

The workflow coordinates packet implementation, implementation conformance,
post-implementation drift/churn validation, promotion through
`promote-proposal`, packet closeout through `closeout-packet`, terminal closeout
through `proposal-packet-terminal-closeout`, archive relocation through
`archive-proposal`, and Change closeout through `closeout-change` or
`closeout-worktree`.

It emits a `proposal-packet-delivery-receipt-v1` aggregate receipt with the
highest outcome that has current passing owning evidence. The receipt does not
replace implementation receipts, promotion receipts, closeout receipts, archive
receipts, Change receipts, branch authorization receipts, cleanup authorization
receipts, terminal proof, or worktree hygiene proof.

## Boundary

Delivery is coordination, not authority transfer. Packet implementation,
promotion, closeout, terminal closeout, archive relocation, Git mutation,
branch cleanup, repo hygiene deletion, and generated publication refresh remain
owned by their canonical routes and publishers.

Generated outputs remain derived-only. Generated prompts, proposal-local files,
dashboards, chat state, host state, tool state, and model memory remain
non-authoritative.

## Operator Route

```text
/proposal-packet-delivery target=<proposal-packet-path> outcome=cleaned
```

When every owning lifecycle passes, the receipt may report `cleaned`. When any
receipt is missing, stale, contradictory, denied, or outside the delivery
profile, the workflow reports `blocked` with the blocker class and next owning
route.

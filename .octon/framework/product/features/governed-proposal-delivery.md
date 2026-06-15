# Governed Proposal Delivery

Proposal Program Delivery is the runtime-facing workflow surface for this
feature.

Governed proposal delivery coordinates an accepted proposal program through
target-owned packet implementation, generated publication freshness, packet
closeout, archive handoff, Change closeout, final sync, branch cleanup,
terminal proof, and worktree hygiene.

The mechanism emits a `proposal-program-delivery-receipt-v1` aggregate receipt
with the highest outcome that has current passing owning evidence. It does not
replace child packet receipts, closeout receipts, archive receipts, Change
receipts, branch authorization receipts, cleanup authorization receipts,
terminal proof, or worktree hygiene proof.

## Boundary

Delivery is coordination, not authority transfer. Child packet lifecycles own
implementation and packet-local evidence. `archive-proposal` owns implemented
archive routing. `closeout-change` and `closeout-worktree` own Git mutation,
hosted landing, final sync, source branch cleanup, and Change closeout claims.
`repo-hygiene-cleanup` owns residue deletion after cleanup authorization.
Owning publisher scripts own generated publication refresh.

Generated outputs remain derived-only. Generated prompts, proposal-local files,
dashboards, chat state, host state, tool state, and model memory remain
non-authoritative.

## Operator Route

```text
/proposal-program-delivery target=<proposal-program-path> outcome=cleaned
```

When every owning lifecycle passes, the receipt may report `cleaned`. When any
receipt is missing, stale, contradictory, or outside the delivery profile, the
workflow reports `blocked` with the blocker class and next owning route.

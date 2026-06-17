# Proposal Packet Delivery

`proposal-packet-delivery` coordinates an accepted proposal packet from
implementation authorization through durable implementation, promotion,
closeout, archive handoff, Change closeout, final sync, branch cleanup,
terminal proof, and final hygiene.

The workflow emits an aggregate `proposal-packet-delivery-receipt-v1` receipt.
It does not replace target-owned implementation receipts, promotion receipts,
`closeout-packet` receipts, terminal closeout receipts, archive receipts,
Change receipts, branch authorization receipts, cleanup authorization receipts,
terminal proof, or worktree hygiene proof.

## Boundaries

- `run-packet-implementation` owns implementation.
- `promote-proposal` owns implemented status and promotion receipts.
- `closeout-packet` owns `support/proposal-closeout.md` and archive
  authorization.
- `proposal-packet-terminal-closeout` owns `support/proposal-terminal-closeout.yml`.
- `archive-proposal` owns archive relocation.
- `closeout-change` and `closeout-worktree` own Git mutation, hosted landing,
  final sync, source branch cleanup, and Change closeout claims.
- `repo-hygiene-cleanup` owns residue deletion after cleanup authorization.
- Owning publisher scripts own generated publication refresh.

Generated outputs remain derived-only. Generated prompts, proposal-local files,
dashboards, chat state, host state, tool state, and model memory remain
non-authoritative.

## Validation

- Profiles validate with `validate-proposal-packet-delivery-profile.sh`.
- Receipts validate with `validate-proposal-packet-delivery-receipt.sh`.
- Branch-no-pr landing requires branch landing authorization.
- Source branch cleanup requires branch cleanup authorization.
- `cleaned` requires fresh terminal current-state proof after the final
  mutation.

## Operator Route

```text
/octon-proposal-run-packet-delivery target=<proposal-packet-path> outcome=cleaned
```

When every owning lifecycle passes, the receipt may report `cleaned`. When any
receipt is missing, stale, contradictory, denied, or outside the delivery
profile, the workflow reports `blocked` with the blocker class and next owning
route.

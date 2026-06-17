# Stage 06: Route Packet Closeout

Route packet closeout through `closeout-packet` after promotion.

Required checks:

- `support/proposal-closeout.md` exists and reports `verdict: pass`.
- `support/proposal-closeout.md` reports `archive_authorized: yes` before
  terminal closeout or archive routing.
- Packet closeout does not archive directly.
- Closeout evidence cites fresh implementation, promotion, conformance, and
  drift/churn receipts.
- Proposal-local files do not authorize archive, Git mutation, branch cleanup,
  or repo hygiene deletion.

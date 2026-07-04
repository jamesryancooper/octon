# Source Lineage

- PM-006: hosted landing had sufficient Octon authorization but still required
  execution-environment approval.
- Audit evidence: the hosted no-PR landing authorization approved landing,
  proved no PR required, preserved host controls, and bound the empty check set
  to the source SHA, while the helper still required `--confirm` and the
  execution environment required approval for the push.
- Operator decision: `--confirm` should become an explicit receipt-consumption
  execution flag, not a human gate, when current authorization evidence is
  complete.

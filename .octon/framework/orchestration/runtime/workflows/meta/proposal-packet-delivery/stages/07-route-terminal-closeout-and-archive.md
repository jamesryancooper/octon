# Stage 07: Route Terminal Closeout And Archive

Route terminal readiness through `proposal-packet-terminal-closeout`, then route
implemented archive through the separate `archive-proposal` lifecycle.

Required checks:

- Pre-archive packets are routed to `proposal-packet-terminal-closeout` and
  `archive-proposal` rather than moved directly by the delivery wrapper.
- Already-archived packets do not rerun archive relocation; missing or stale
  archive evidence blocks with `archive-proposal` as the next owning lifecycle.
- `support/proposal-terminal-closeout.yml` reports a passing terminal verdict.
- Terminal closeout does not move the packet to archive.
- `archive-proposal` owns archive relocation and archive metadata.
- Archive relocation is followed by generated proposal registry/artifact
  freshness validation.
- Fresh archive mutations block Change closeout until revalidated.
- Before terminal closeout or archive handoff, generated-input freshness scope
  records one of: generated freshness not in scope; generated-input scope
  detected and owner-routed; generated refresh needed but not authorized;
  generated output present but stale; generated output fresh but
  non-authoritative.
- Stale generated output or missing owning-validator freshness evidence blocks
  the terminal delivery claim and names the owning generator or authorization
  route as the next lifecycle.
- Fresh generated output may support operator understanding and validator
  evidence only; it must not authorize closeout, archive, cleanup, publication,
  parent lifecycle state, or Change closeout.

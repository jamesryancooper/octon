# Stage 07: Route Terminal Closeout And Archive

Route terminal readiness through `proposal-packet-terminal-closeout`, then route
implemented archive through the separate `archive-proposal` lifecycle.

Required checks:

- `support/proposal-terminal-closeout.yml` reports a passing terminal verdict.
- Terminal closeout does not move the packet to archive.
- `archive-proposal` owns archive relocation and archive metadata.
- Archive relocation is followed by generated proposal registry/artifact
  freshness validation.
- Fresh archive mutations block Change closeout until revalidated.

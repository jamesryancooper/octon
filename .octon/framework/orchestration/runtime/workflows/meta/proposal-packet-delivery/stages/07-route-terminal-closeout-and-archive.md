# Stage 07: Resolve Terminal Readiness And Stop Before Archive

Route terminal-readiness validation through
`proposal-packet-terminal-closeout`, then stop at `archive-ready`. This stage
does not invoke `archive-proposal` or relocate the packet during SI-00.

Required checks:

- Packet closeout and terminal-closeout evidence is fresh and target-owned.
- `support/proposal-terminal-closeout.yml` reports a passing readiness verdict.
- The current target is `archive-ready`; implemented requests may stop earlier.
- Exact work, candidate refs, worktrees, rollback handles, and unrelated work
  remain preserved.
- Archive relocation, Git/GitHub mutation, hosted landing, final sync, cleanup,
  branch deletion, and generated direct publication are not performed.
- If later archive or publication is requested, record the separate owning
  lifecycle and `RP00_CONTAINMENT_PUBLICATION_DISABLED`; do not dispatch it.
- Generated freshness remains validator evidence only and never authorizes
  archive, publication, cleanup, or Change closeout.

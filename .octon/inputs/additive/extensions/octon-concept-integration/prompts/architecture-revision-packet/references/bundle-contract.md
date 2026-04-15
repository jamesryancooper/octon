# Architecture Revision Packet Bundle Contract

- input type: single external source artifact, optionally narrowed to selected
  concepts
- output type: architecture proposal packet for ordinary architecture revision
- escalation rule: route to `constitutional-challenge-packet` when the blocker
  is really a kernel, precedence, fail-closed, or authority rule
- validators:
  - `validate-proposal-standard.sh --package <packet-path>`
  - `validate-architecture-proposal.sh --package <packet-path>`

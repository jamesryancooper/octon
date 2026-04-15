# Architecture Revision Contract

This file is the single source of truth for extension-specific
architecture-revision rules that sit on top of Octon's repo-wide proposal
standards.

## Schema And Layout Sources Of Truth

Architecture revision packet schema, lifecycle, and layout rules are owned by:

- `/.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- `/.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`

## Extension-Specific Architecture Revision Expectations

An `architecture-revision-packet` should:

- be used when an important concept cannot fit the current ordinary
  architecture without revising authored framework or instance structure,
- stay inside the current constitutional kernel, fail-closed posture, and
  authority-routing model,
- identify the current architectural blockers, affected surfaces, migration
  posture, and validator or publication impact,
- escalate to `constitutional-challenge-packet` instead of forcing a packet
  when the blocker is really a kernel, precedence, authority, or fail-closed
  rule,
- and be valid under both
  `validate-proposal-standard.sh --package <packet-path>` and
  `validate-architecture-proposal.sh --package <packet-path>`.

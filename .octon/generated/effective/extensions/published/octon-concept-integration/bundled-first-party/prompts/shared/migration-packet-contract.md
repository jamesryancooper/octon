# Migration Packet Contract

This file is the single source of truth for extension-specific migration-packet
rules that sit on top of Octon's repo-wide proposal standards.

## Schema And Layout Sources Of Truth

Migration packet schema, lifecycle, and layout rules are owned by:

- `/.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- `/.octon/framework/scaffolding/governance/patterns/migration-proposal-standard.md`

## Extension-Specific Migration Packet Expectations

A concept-integration migration packet should:

- define rollout, cutover, rollback, sequencing, and validation posture,
- make compatibility, release-state, and change-profile assumptions explicit,
- keep promotion targets out of the proposal tree,
- preserve traceability from source through verification into the migration
  plan,
- include manifest-governed packet support artifacts when available,
- and be valid under both
  `validate-proposal-standard.sh --package <packet-path>` and
  `validate-migration-proposal.sh --package <packet-path>`.

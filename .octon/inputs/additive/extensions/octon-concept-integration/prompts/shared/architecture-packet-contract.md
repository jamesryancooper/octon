# Architecture Packet Contract

This file is the single source of truth for extension-specific packetization
rules that sit on top of Octon's repo-wide proposal standards.

## Schema And Layout Sources Of Truth

Proposal schema, lifecycle, and layout rules are owned by:

- `/.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- `/.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`

Architecture-packet bundle stages must satisfy those standards rather than restating full
manifest field lists inline.

## Extension-Specific Packet Expectations

In addition to the repo-wide proposal standards, a concept-integration packet
should:

- remain non-canonical and point promotion targets at durable repo surfaces,
- include the managed packet support files declared in `manifest.yml`
  `artifact_policy.packet_support_files` whenever those artifacts are available,
- preserve traceability from source artifact to extraction, verification,
  packetization, and downstream implementation,
- and be valid under both
  `validate-proposal-standard.sh --package <packet-path>` and
  `validate-architecture-proposal.sh --package <packet-path>`.

## Extension-Specific Working Materials

The extension may require additional architecture and resources documents to
make the packet download-ready and implementation-ready, but those additions
must complement the repo proposal standards instead of replacing them.

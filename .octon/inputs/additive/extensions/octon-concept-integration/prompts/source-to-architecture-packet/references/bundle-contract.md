# Source To Architecture Packet Bundle Contract

This bundle turns one external source artifact into a verified architecture
proposal packet and, when requested, a packet-specific implementation prompt.

## Bundle Contract

- input type: single external source artifact
- default output: architecture proposal packet
- default downstream execution surface:
  `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/packet-to-implementation/stages/01-implement-packet.md`
- shared packet contract:
  `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/shared/architecture-packet-contract.md`
- default validators:
  - `validate-proposal-standard.sh --package <packet-path>`
  - `validate-architecture-proposal.sh --package <packet-path>`

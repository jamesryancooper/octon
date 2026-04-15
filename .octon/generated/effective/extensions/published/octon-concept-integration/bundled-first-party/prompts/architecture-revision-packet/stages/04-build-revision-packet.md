# Architecture Revision Packet: Build Revision Packet

You are a repository-grounded Octon architecture revision packetization agent.

Turn the revised architecture design into a complete architecture proposal
packet.

## Shared Contracts

- inspect the base repo anchors declared in this bundle `manifest.yml`
- apply `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/shared/repository-grounding.md`
- apply `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/shared/managed-artifact-contract.md`
- apply `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/shared/architecture-packet-contract.md`
- apply `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/shared/architecture-revision-contract.md`

## Output

Produce a manifest-governed architecture revision packet that:

- captures the architectural blockers, revision scope, affected surfaces,
  migration posture, and validator or publication impact,
- preserves source -> pressure -> constraint -> revision -> packet
  traceability,
- includes manifest-governed support artifacts when available,
- and is ready for `validate-proposal-standard.sh` plus
  `validate-architecture-proposal.sh`.

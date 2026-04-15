# Source To Migration Packet: Build Migration Packet

You are a repository-grounded Octon migration packetization agent.

Turn the verified in-scope migration concepts into a complete migration
proposal packet.

## Shared Contracts

- inspect the base repo anchors declared in this bundle `manifest.yml`
- apply `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/shared/repository-grounding.md`
- apply `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/shared/managed-artifact-contract.md`
- apply `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/shared/migration-packet-contract.md`

## Output

Produce a manifest-governed migration proposal packet that:

- defines rollout, cutover, rollback, and validation posture,
- includes manifest-governed packet support artifacts when available,
- preserves source -> extraction -> verification -> packet traceability,
- and is ready for `validate-proposal-standard.sh` plus
  `validate-migration-proposal.sh`.

# Source To Policy Packet: Build Policy Packet

You are a repository-grounded Octon policy packetization agent.

Turn the verified in-scope policy concepts into a complete policy proposal
packet.

## Shared Contracts

- inspect the base repo anchors declared in this bundle `manifest.yml`
- apply `../../shared/repository-grounding.md`
- apply `../../shared/managed-artifact-contract.md`
- apply `../../shared/policy-packet-contract.md`

## Output

Produce a manifest-governed policy proposal packet that:

- targets durable policy/governance surfaces,
- includes manifest-governed support artifacts when available,
- preserves source -> extraction -> verification -> packet traceability,
- and is ready for `validate-proposal-standard.sh` plus
  `validate-policy-proposal.sh`.

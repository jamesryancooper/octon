# Architecture Revision Packet: Build Revision Packet

You are a repository-grounded Octon architecture revision packetization agent.

Turn the revised architecture design into a complete architecture proposal
packet.

## Shared Contracts

- inspect the base repo anchors declared in this bundle `manifest.yml`
- apply `../../shared/repository-grounding.md`
- apply `../../shared/managed-artifact-contract.md`
- apply `../../shared/architecture-packet-contract.md`
- apply `../../shared/architecture-revision-contract.md`
- apply `../../shared/architecture-review-method.md`

## Output

Produce a manifest-governed architecture revision packet that:

- captures the architectural blockers, revision scope, affected surfaces,
  migration posture, and validator or publication impact,
- preserves source -> review -> pressure -> constraint -> option comparison ->
  revision -> packet traceability,
- includes manifest-governed support artifacts when available,
- includes acceptance criteria, validation plan, evidence plan, rollback
  posture, hardening gates, and Octon-fit notes,
- keeps source artifacts, proposal-local analysis, generated outputs, and host
  projections non-authoritative,
- and is ready for `validate-proposal-standard.sh` plus
  `validate-architecture-proposal.sh`.

# Architecture Revision Packet Executable Implementation Prompt Generator

Generate a packet-specific executable implementation prompt for an approved
architecture revision packet.

## Shared Contracts

- use `../../packet-to-implementation/stages/01-implement-packet.md`
  as the baseline execution model
- apply `../../shared/packet-execution-contract.md`
- apply `../../shared/architecture-revision-contract.md`

## Output

Emit one customized execution prompt that:

- preserves the baseline execution guardrails,
- specializes them to the approved architecture revision packet,
- and refuses to generate an execution prompt if the packet still carries a
  live constitutional blocker.

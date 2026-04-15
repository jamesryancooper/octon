# Source To Architecture Packet

This bundle turns one external source artifact into a verified architecture
proposal packet and, when requested, a packet-specific implementation prompt.

The bundle manifest is the source of truth for bundle inventory, shared
references, repo anchors, packet support files, and alignment defaults.

## Flow

1. `stages/01-extract.md`
2. `stages/02-verify.md`
3. `stages/03-build-architecture-packet.md`

## Companions

- `companions/01-generate-implementation-prompt.md`
- `companions/02-align-bundle.md`

## Downstream Execution

Packet execution is handled by the separate `packet-to-implementation` bundle.
This architecture bundle stops at validated packet generation plus the optional
implementation-prompt companion.

## Shared Contracts

- `../shared/repository-grounding.md`
- `../shared/managed-artifact-contract.md`
- `../shared/alignment-mode-contract.md`
- `../shared/architecture-packet-contract.md`
- `../shared/packet-execution-contract.md`

# Packet Refresh And Supersession: Refresh Or Supersede Packet

Produce a refreshed packet or a superseding packet that matches the live repo.

## Shared Contracts

- apply `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/shared/managed-artifact-contract.md`
- apply the packet-kind contract that matches the packet under refresh

## Output

Emit the narrowest correct packet update:

- refresh in place when the packet kind, scope, and promotion targets are still
  materially correct,
- supersede when the live repo or packet drift makes in-place refresh
  misleading.

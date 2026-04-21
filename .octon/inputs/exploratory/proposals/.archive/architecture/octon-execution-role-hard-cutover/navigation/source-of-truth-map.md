# Source of Truth Map

## Packet-local authority

Within this proposal packet, authority flows as follows:

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/**`
5. `resources/**`
6. `navigation/artifact-catalog.md`
7. `README.md`

`proposal.yml` and `architecture-proposal.yml` are the only lifecycle authorities.

## Durable authority outside the packet

The packet is subordinate to the live Octon authority model:

1. `/.octon/framework/**` portable authored authority
2. `/.octon/instance/**` repo-specific authored authority
3. `/.octon/state/control/**` mutable operational truth
4. `/.octon/state/continuity/**` resumable work state
5. `/.octon/state/evidence/**` retained proof
6. `/.octon/generated/**` derived-only read models
7. `/.octon/inputs/**` non-authoritative inputs

This map follows the live `.octon/README.md`, which states that only
`framework/**` and `instance/**` are authored authority and that raw
`inputs/**` never participate directly in runtime or policy decisions.

## Boundary rules

- Proposal paths are never runtime or policy dependencies.
- Generated proposal registry is discovery-only.
- Generated cognition may feed context packs only as labeled derived input.
- Retained evidence must live under `state/evidence/**`.
- Runtime control truth must live under `state/control/**`.
- No external host UI, chat transcript, label, comment, or check mints authority.

## Promotion boundary

All promotion targets are `.octon/**` paths outside
`/.octon/inputs/exploratory/proposals/**`. No non-`.octon/**` target is mixed
into this active packet.

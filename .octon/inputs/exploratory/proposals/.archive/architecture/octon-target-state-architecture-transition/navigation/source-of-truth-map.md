# Source of Truth Map

## Packet-local precedence

Within this proposal packet, interpret artifacts in this order:

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/**`
5. `resources/**`
6. `navigation/artifact-catalog.md`
7. `README.md`

`proposal.yml` and `architecture-proposal.yml` are the only lifecycle authorities for the packet. Working documents express proposed promotion work only.

## Durable authority outside the packet

The packet is subordinate to the live Octon authority model:

1. `/.octon/framework/constitution/**` — constitutional kernel and contract families.
2. `/.octon/framework/cognition/_meta/architecture/contract-registry.yml` — machine-readable topology, authority, publication, and doc-target registry.
3. `/.octon/framework/cognition/_meta/architecture/specification.md` — human-readable companion to the registry.
4. `/.octon/instance/**` — repo-specific authored authority, including governance, locality, ingress, bootstrap, charter, missions, decisions, and support admissions.
5. `/.octon/state/control/**` — mutable operational control truth.
6. `/.octon/state/evidence/**` — retained evidence, disclosure, validation, support, and publication receipts.
7. `/.octon/state/continuity/**` — handoff and resumption state.
8. `/.octon/generated/effective/**` — runtime-facing derived outputs only when publication receipts and freshness artifacts are current.
9. `/.octon/generated/cognition/**` — non-authoritative operator and mission read models.
10. `/.octon/inputs/**` — non-authoritative additive and exploratory material.

## Boundary rules

- This packet cannot authorize, approve, execute, publish, or close a run.
- Proposal paths must never be runtime or policy dependencies.
- Generated artifacts may summarize or project but never mint authority.
- `inputs/**` never becomes a direct runtime or policy dependency.
- Host labels, comments, checks, UI state, and chat transcripts may mirror state but never become authority.
- Promotion must produce durable targets that stand without this packet.

## Promotion boundary

All declared `promotion_targets` are `.octon/**` paths outside `/.octon/inputs/exploratory/proposals/**`. No non-`.octon/**` promotion target is mixed into this active packet.

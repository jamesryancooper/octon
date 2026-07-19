# Proposal Reading and Precedence Map

## Authority Boundary

Current canonical repository authority outranks this proposal. The specified
reconciliation is the controlling non-authoritative planning baseline. This
packet may describe future durable ownership but cannot mint that ownership.

## External Sources

| Concern | Source | Role |
| --- | --- | --- |
| Constitutional authority | `.octon/framework/constitution/**` and `.octon/instance/**` | Governs authority, evidence, ownership, and topology. |
| Proposal lifecycle | `.octon/inputs/exploratory/proposals/README.md` and proposal standards | Governs this packet's shape and lifecycle. |
| Reconciled packet boundary | Reconciliation `reconciled-proposal-packet-map.yml` entry RP-10 | Controls purpose, scope, dependencies, proof, and exclusions. |
| Reconciled decisions | FD-019, RF-015, PO-FD-019, PG-10-PROJECT-NONAUTHORITY, UE-010, ED-005 | Controls traceability and future gates. |
| Current implementation facts | Current Project Profile schemas, locality profile, engagement compiler, mission commands, and contract registries | Establishes the repository-grounded starting point. |

## Proposal-Local Precedence

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/workspace-project-design-and-dependency-receipt.yml`
4. `resources/packet-contract.yml`
5. `resources/traceability.yml`
6. `architecture/target-architecture.md`
7. `architecture/acceptance-criteria.md`
8. `architecture/implementation-plan.md`
9. remaining architecture and navigation documents
10. `README.md`

## Planned Durable Ownership

| Concern | Planned owner | Boundary |
| --- | --- | --- |
| Workspace Project schema and active record | RP-10 Workspace Project component | Identifies and narrows; never authorizes. |
| Project inference, refresh, lifecycle, and corrections | RP-10 Workspace Project component | Produces candidates or governed record changes; cannot widen active runs. |
| Rebuildable location index | RP-10 project discovery component | Non-authoritative host/location read model. |
| Project Profile facts | Existing Project Profile owner, revised by RP-10 | Facts remain evidence-backed and enter execution only through an explicit whitelist. |
| Mission authority and control state | Existing mission runtime owners | RP-10 reads these sources and does not replace them. |
| Cross-project mission inbox | RP-10 read-model/CLI component | Read-only projection; cannot mutate or authorize a mission. |
| Harness compilation | RP-11 | Consumes RP-10 exact refs and digests; RP-10 does not compile or authorize the Harness. |
| Canonical authorization | RP-01 and existing authority engine | Workspace Project fields cannot redefine or bypass it. |

Shared registry files receive RP-10-owned entries through the trusted
integration lane; RP-10 does not claim ownership of unrelated registry
content. Kernel integration files likewise grant RP-10 ownership only over the
project/inbox symbols introduced by this packet.

The exact UUIDv7 identity, RFC-8785/SHA-256 record layout, boundary and
correction rules, immutable run snapshot, location-index recovery, inbox
pagination/freshness, accepted RP-01 digest, and proof order are selected in
`resources/workspace-project-design-and-dependency-receipt.yml`. These are
planned-not-created-not-executed.

## Derived and Operational Surfaces

- `.octon/state/continuity/repo/missions/**` remains continuity, not authority.
- `.octon/state/evidence/project-profiles/**` and this packet's validation
  evidence root retain facts and proof, not permission.
- project location indexes and generated mission views are rebuildable
  non-authoritative read models.
- `.octon/generated/proposals/registry.yml` remains a discovery projection and
  is intentionally not edited by this child authoring task.

## Conflict Rule

If project metadata conflicts with a Run Contract, authority decision, support
admission, or host enforcement boundary, the project data may only narrow the
effective scope. Ambiguity blocks the affected project selection while leaving
unrelated project work available.

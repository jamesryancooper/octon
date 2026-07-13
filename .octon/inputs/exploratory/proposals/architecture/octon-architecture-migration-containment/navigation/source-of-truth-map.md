# Proposal Reading and Precedence Map

## Authority Boundary

The repository constitutional kernel, current product and instance governance,
and accepted run-specific authority outrank this packet. The intake,
reconciliation, parent program, Revision 2 proposal, this packet, generated
views, GitHub state, and chat are non-authoritative planning or observation
surfaces.

## Proposal-Local Precedence

1. `proposal.yml` — identity, lifecycle, scope, and promotion targets.
2. `architecture-proposal.yml` — architecture subtype contract.
3. `resources/packet-contract.yml` — reconciled RP-00 boundary and ownership.
4. `architecture/target-architecture.md` — intended SI-00 end state.
5. `architecture/acceptance-criteria.md` — proof conditions.
6. `architecture/implementation-plan.md` — later implementation sequence.
7. Remaining architecture and resource documents — supporting detail.
8. `navigation/artifact-catalog.md` — packet inventory only.
9. `.octon/generated/proposals/registry.yml` — discovery projection only.
10. `README.md` — operator orientation only.

## Durable Authorities and Owners

| Concern | Durable authority or planned owner | Boundary |
| --- | --- | --- |
| Change route semantics | `.octon/framework/product/contracts/default-work-unit.{yml,md}` | RP-00 may remove autonomous direct-main at containment; RP-06 owns the later final publication classifier and route UX. |
| Physical side-effect inventory | `.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml` | Must enumerate authenticated physical writers and consumers; it never grants authority. |
| Authorization boundary coverage | `.octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml` | RP-00 inventories; RP-01 later repairs canonical authority and exact launch guards. |
| Delegated governance inventory | `.octon/framework/orchestration/governance/delegated-governance-inventory-v1.yml` | Inventory and lineage only; no lifecycle-local authority survives as a competing issuer. |
| Support declaration | `.octon/instance/governance/support-targets.yml` and admitted dossiers/admissions | Human governance owns live support; RP-00 may narrow claims but never widen them. |
| Harness disclosure source | `.octon/instance/governance/disclosure/harness-card.yml` | Claims must equal direct retained proof. |
| Retained packet proof | `.octon/state/evidence/validation/proposals/octon-architecture-migration-containment/**` | Evidence only; never policy, authority, or proposal lifecycle truth. |

## Derived and External Surfaces

| Surface | Classification | Rule |
| --- | --- | --- |
| `.github/workflows/**` | repo-local host projection | Inventory and disable unsafe paths through the owning implementation route; never list as an `octon-internal` promotion target. |
| GitHub rulesets, Apps, tokens, environments, checks | external provider state | Observe read-only for baseline; later mutation requires separate authority and retained provider receipts. |
| `.octon/generated/effective/governance/support-target-matrix.yml` | derived runtime-effective view | Refresh only through its owning generator after authoritative claim changes. |
| `.octon/generated/proposals/registry.yml` | derived proposal discovery | Not edited by this child-authoring task and never proposal lifecycle authority. |

## Conflict Rules

- Current canonical repository authority outranks reconciliation prose.
- The reconciled decision register controls non-authoritative program planning.
- Missing ownership, proof, or provider freshness fails closed.
- RP-00 containment may not absorb RP-01 authority repair, RP-05 Git adapter,
  RP-06 publication, RP-07 evidence, or RP-14 product-proof ownership.
- A durable non-`.octon/**` implementation target requires a linked proposal;
  it may not be silently added here.


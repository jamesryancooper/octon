# Proposal Reading and Precedence Map

## Authority Boundary

Current canonical repository authority outranks this proposal. The fixed
reconciliation is the controlling non-authoritative planning baseline. A
valid signature proves origin/integrity under the operator trust set; it does
not prove safety, compatibility, capability authorization, selection, or
permission to execute.

## External Sources

| Concern | Source | Role |
| --- | --- | --- |
| Constitutional authority and evidence | `.octon/framework/constitution/**`, `.octon/instance/**`, and RP-07 output | Governs authority, signed evidence identity, retention, and topology. |
| Proposal lifecycle | `.octon/inputs/exploratory/proposals/README.md` and proposal standards | Governs this packet's shape and lifecycle. |
| Reconciled boundary | Reconciliation packet-map entry RP-12 | Controls purpose, scope, dependencies, proof, and exclusions. |
| Traceability | FD-021, RF-016, RF-027, PO-FD-021, PG-12-SIGNED-CATALOG, UE-012, ROD-004 | Controls accepted baseline lineage, governed configuration, and future proof; no operator decision remains open. |
| Current implementation facts | Extension governance, schemas, desired config, active/quarantine state, publisher, generated catalog/lock, resolver, and validators | Establishes reusable repository primitives and current gaps. |

## Proposal-Local Precedence

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/packet-contract.yml`
4. `resources/traceability.yml`
5. `architecture/target-architecture.md`
6. `architecture/acceptance-criteria.md`
7. `architecture/implementation-plan.md`
8. remaining architecture and navigation documents
9. `README.md`

## Durable and Operational Ownership

| Surface | Owner | Boundary |
| --- | --- | --- |
| Signed extension envelope contract | RP-12 | Authenticates exact private release metadata and payload; never authorizes. |
| Approved private sources, trusted signer set, revocations, desired selection, and exact pins | Operator-owned `.octon/instance/extensions.yml` contract extended by RP-12 | Desired state only; changed through canonical repo governance. |
| Normalized raw pack/release material | Existing additive-input owner | Non-authoritative source; runtime cannot read it directly. |
| Verified availability catalog | RP-12 import verifier writing actual control state | Records exact available signed releases; cannot select or activate. |
| Active and quarantine truth | Existing extension control-state owner, extended by RP-12 | Actual state; publisher/reconciler only. |
| Generated effective catalog, artifact map, generation lock, and published pack views | Existing extension publisher, extended by RP-12 | Rebuildable runtime projections; never desired or authority. |
| Import, compatibility, publication, transition, and rollback receipts | RP-12 producers using RP-07 evidence identity/retention | Evidence only; receipts do not authorize. |
| Exact extension-generation Harness input | RP-11 contract; RP-12 supplies an admitted ref/digest | Harness cannot select or refresh a generation itself. |
| Capability authorization and execution | Existing authority/capability owners | Signature, availability, selection, and catalog rows cannot grant. |

## Writer Separation

- The import verifier may stage an untrusted artifact, verify it, place an
  immutable normalized release, update verified availability/quarantine actual
  state, and emit an import receipt. It cannot edit desired selection or
  generated runtime outputs.
- The operator/governed repo-change route writes desired sources, trusted
  signer/revocation policy, selection, and pins. Import cannot write these.
- The existing publisher reads desired plus verified actual availability,
  revalidates, writes active/quarantine actual state, atomically publishes the
  generated family, and emits transition receipts.
- Runtime resolvers and the Harness read only a verified generated generation
  handle and cross-check actual state; they are read-only consumers.

Shared resolver and publisher files grant RP-12 ownership only over exact
extension-signer, availability, generation, and restore fields/functions. RP-11
retains generic Harness/resolver semantics; RP-07 retains signer/evidence
mechanisms; RP-13 retains child behavior.

## Derived and Retained Surfaces

- `.octon/state/control/extensions/**` is actual operational truth, not desired
  policy or proposal authority.
- `.octon/generated/effective/extensions/**` is publisher-owned projection.
- `.octon/inputs/additive/.incoming/**` is untrusted staging and never a
  runtime dependency.
- retained historical signed releases under the additive archive are recovery
  inputs only and must be reverified before restoration.
- `.octon/generated/proposals/registry.yml` is a discovery projection and is
  intentionally not edited by this child authoring task.

## Conflict Rule

Any source, signer, revocation, envelope, manifest, payload, dependency,
compatibility, capability, pin, actual-state, generated-state, or Harness
generation disagreement fails the affected import/publication/launch closed.
No lower-precedence catalog or receipt can override desired policy or canonical
authority.

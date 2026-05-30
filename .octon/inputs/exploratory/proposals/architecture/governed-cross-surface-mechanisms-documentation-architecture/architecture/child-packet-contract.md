# Child Packet Contract

_Status: Draft parent-program canonical child contract_

Each child packet remains a normal manifest-governed proposal packet. The
parent coordinates dependency order and aggregate evidence only.

The current registry entries are canonical sibling child packets. A child
packet is canonical because its sibling directory and child-owned
`proposal.yml` manifest exist. Parent declarations still do not satisfy child
manifests, child receipts, child validation verdicts, child promotion targets,
or child terminal outcomes.

## Authority Boundaries

- Parent coordinates only.
- Child manifests remain child-owned.
- Child subtype manifests remain child-owned.
- Child acceptance criteria remain child-owned.
- Child validation verdicts remain child-owned.
- Child promotion targets remain child-owned.
- Child archive metadata remains child-owned.
- Parent evidence may summarize but never satisfy child receipts.

## Common Child Requirements

Each required child must:

0. Exist as a sibling proposal packet before implementation prompt generation
   or program closeout.
1. Declare one `change_profile`.
2. Declare explicit promotion targets outside the proposal workspace.
3. Preserve `inputs/**` as non-authoritative lineage.
4. Preserve `generated/**` as derived-only.
5. Preserve product feature entries as navigation-only.
6. Preserve `state/control/**` as mutable operational truth.
7. Preserve `state/evidence/**` as retained evidence.
8. Include implementation-grade completeness review before implementation.
9. Include implementation conformance and drift/churn receipts after promotion.
10. Include validators or negative-control tests for authority confusion.

## Program-Specific Child Rules

### `mechanism-index-foundation`

Must create an architecture/governance index for governed cross-surface
mechanisms. The index must not become runtime authority, policy authority,
support authority, closeout authority, cleanup authority, or retained evidence.

### `authority-class-schema-alignment`

Must align product feature catalog and mechanism index vocabulary with the
topology registry. It must prevent `state/control/**` from being labeled
retained evidence and must distinguish generated-effective surfaces from
operator read models.

### `mechanism-index-validator-guards`

Must add validator coverage for navigation-only posture, mechanism index
non-authority, path/class consistency, generated-effective non-authority,
operator read-model non-authority, lifecycle interaction receipt
non-authorization, and retired terminology containment.

### `product-doc-boundary-crosslinks`

Must update product docs only as navigation and cross-linking. It must not make
runtime/operator mechanisms into product features unless a child packet
explicitly proposes and validates that product surface.

### `retired-terminology-guardrails`

Must keep `Lifecycle Autopilot` language only in explicit compatibility or
historical lineage notes. Current architecture and product language must use
`Governed Lifecycle Orchestration` or the appropriate layer-specific term.

### `program-closeout-coverage-evidence`

Must verify aggregate documentation coverage without satisfying child receipts.
It may summarize child outcomes, but child-owned validation, promotion,
implementation, and closeout evidence remain authoritative for each child.

### `mechanism-detail-pages-and-operator-map`

Optional. Must stay navigation and visibility only. Generated operator maps
must follow operator read-model rules and cannot be consumed as runtime,
policy, support, authority, or closure input.

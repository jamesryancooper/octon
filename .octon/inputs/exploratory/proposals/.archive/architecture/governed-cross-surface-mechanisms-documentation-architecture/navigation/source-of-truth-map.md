# Source Of Truth Map

This proposal program is exploratory input. It is not durable runtime,
governance, closeout, cleanup, retained-evidence, or generated-effective
authority.

## Parent-Local Coordination Surfaces

- `proposal.yml`
- `architecture-proposal.yml`
- `resources/child-packet-index.yml`
- `resources/child-packet-index.md`
- `architecture/packet-sequence.md`
- `architecture/child-packet-contract.md`
- `architecture/program-closeout-plan.md`
- `support/program-creation.md`
- `support/proposal-review.md`

These surfaces define parent coordination only.

The child registry is currently a canonical child packet registry. Child paths
are sibling packet locations with child-owned proposal manifests. The parent
registry coordinates sequence and readiness only; it does not replace
child-owned lifecycle truth, receipts, promotion targets, validation verdicts,
or terminal outcomes.

## External Authority Surfaces Referenced

- `.octon/instance/ingress/AGENTS.md`
- `.octon/framework/product/README.md`
- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/product/contracts/product-feature-catalog-v1.schema.json`
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `.octon/framework/engine/runtime/spec/**`
- `.octon/framework/orchestration/runtime/workflows/**`
- `.octon/instance/governance/policies/repo-hygiene.yml`

Those external surfaces retain their own authority classes. This proposal
program does not replace them.

## Non-Authority Surfaces

- Product feature catalog entries are navigation-only.
- Generated-effective outputs are derived runtime handles only.
- Generated cognition outputs are operator read models only.
- Raw intake and exploratory proposals are non-authoritative inputs.
- Lifecycle interaction receipts are advisory handoff context only.
- Parent program evidence may summarize child outcomes but never satisfy child
  receipts.

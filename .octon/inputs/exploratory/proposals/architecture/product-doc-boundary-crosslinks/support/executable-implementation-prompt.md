# Executable Implementation Prompt: Product Doc Boundary Crosslinks

proposal_path: `.octon/inputs/exploratory/proposals/architecture/product-doc-boundary-crosslinks`
next_route: `run-packet-implementation`

## Implementation Scope

Implement only the accepted child packet for `product-doc-boundary-crosslinks`.
Add product documentation crosslinks to the governed cross-surface mechanisms architecture index while preserving product feature catalog navigation-only posture.

Live repo state at prompt generation:

- `.octon/framework/product/README.md` exists.
- `.octon/framework/product/features/README.md` exists.
- `.octon/framework/product/features/catalog.yml` exists.
- `.octon/framework/product/contracts/` exists.
- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/` is expected to exist after `mechanism-index-foundation` implementation.

Promotion targets:

- `.octon/framework/product/README.md`
- `.octon/framework/product/features/`
- `.octon/framework/product/contracts/`

## Workstreams

1. Add concise product documentation language that product docs use `product features`.
2. Add concise architecture/governance crosslinks that point to governed cross-surface mechanisms for authority-class and cross-surface boundary detail.
3. Keep the product feature catalog explicitly navigation-only.
4. Avoid converting lower-level runtime/operator mechanisms into product features unless an authoritative product contract explicitly requires it.
5. Update existing product feature docs only where crosslinks prevent boundary confusion.
6. Keep runtime/operator terminology concrete: lifecycles, workflows, routes, state machines, receipts, command names, and skill names.
7. Avoid duplicating the full mechanism index inside product docs.

## Authority Boundaries

- Product docs do not become runtime, policy, closeout, cleanup, generated-effective, operator read-model, raw input, or retained-evidence authority.
- Product feature catalog entries remain navigation-only.
- Do not mutate runtime specs, state/control truth, retained evidence, generated outputs, or child proposal receipts.
- Do not make generated, raw, host, chat, model memory, or tool availability surfaces authoritative.

## Validation

Run these checks at minimum:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/product-doc-boundary-crosslinks --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/product-doc-boundary-crosslinks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/product-doc-boundary-crosslinks --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/product-doc-boundary-crosslinks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/product-doc-boundary-crosslinks
```

Run link or terminology validators if available for product docs.

## Evidence And Receipts

After implementation, produce:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

The conformance receipt must list product docs changed, crosslinks added, and evidence that product features remain navigation-only.

The drift/churn receipt must explain why crosslinks are minimal, whether any feature entry was changed, and whether any product doc duplicates architecture mechanism detail.

## Rollback Posture

Rollback is manual: revert product doc and product contract changes if they imply product feature entries own runtime, policy, evidence, cleanup, closeout, generated, or raw input authority.

## Terminal Criteria

Implementation is complete only when crosslinks are present, product docs remain navigation-only, validation passes, and both required receipts pass. Refuse closeout/archive claims until `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md` exist, pass their validators, and confirm no product authority widening remains.

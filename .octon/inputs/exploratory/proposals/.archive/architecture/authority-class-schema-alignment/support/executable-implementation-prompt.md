# Executable Implementation Prompt: Authority Class Schema Alignment

proposal_path: `.octon/inputs/exploratory/proposals/architecture/authority-class-schema-alignment`
next_route: `run-packet-implementation`

## Implementation Scope

Implement only the accepted child packet for `authority-class-schema-alignment`.
Align product feature catalog and governed cross-surface mechanism authority-class vocabulary with the topology registry.

Live repo state at prompt generation:

- `.octon/framework/product/contracts/product-feature-catalog-v1.schema.json` exists.
- `.octon/framework/product/features/catalog.yml` exists.
- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/` is expected to exist after `mechanism-index-foundation` implementation.

Promotion targets:

- `.octon/framework/product/contracts/product-feature-catalog-v1.schema.json`
- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`

## Workstreams

1. Compare product feature catalog authority classes with `.octon/framework/cognition/_meta/architecture/contract-registry.yml`.
2. Align the product catalog schema with the mechanism index vocabulary without making the product feature catalog authority-bearing beyond its product contract role.
3. Ensure the vocabulary distinguishes authored authority, product contract, runtime spec, runtime implementation, mutable operational truth, retained evidence, generated-effective non-authority, generated operator read model, publication input only, exploratory/raw input, navigation only, and compatibility only.
4. Update product catalog entries only when necessary to keep authority-class values valid and navigation-only.
5. Update the mechanism index authority-class guide created by the foundation child so it uses the same vocabulary.
6. Add examples or validator-facing notes that explicitly reject `state/control/**` as retained evidence and keep `state/evidence/**` as retained evidence.
7. Distinguish generated operator read model surfaces from generated-effective non-authority handles.

## Authority Boundaries

- Do not mutate `.octon/state/control/**` or `.octon/state/evidence/**`.
- Do not treat generated-effective output as authored authority.
- Do not treat generated operator read model output as runtime or support truth.
- Do not let product feature catalog entries become runtime, policy, closeout, cleanup, or retained-evidence authority.
- Do not treat proposal-local content as durable authority.

## Validation

Run these checks at minimum:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/authority-class-schema-alignment --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/authority-class-schema-alignment
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/authority-class-schema-alignment --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/authority-class-schema-alignment
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/authority-class-schema-alignment
```

Run any mechanism-index validator added by the foundation implementation if it exists.

## Evidence And Receipts

After implementation, produce:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

The conformance receipt must prove that `state/control/**` is mutable operational truth, `state/evidence/**` is retained evidence, generated operator read model and generated-effective non-authority classes are distinct, and product feature catalog entries remain navigation-only.

The drift/churn receipt must record schema churn, catalog changes, rejected broader vocabulary changes, and any remaining validation gap.

## Rollback Posture

Rollback is manual: revert schema, catalog, and mechanism index vocabulary changes if authority classes become ambiguous or broader than the topology registry supports.

## Terminal Criteria

Implementation is complete only when the vocabulary is layer-correct, validation passes, and both required receipts pass. Refuse closeout/archive claims until `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md` exist, pass their validators, and confirm no generated/raw/navigation/control/evidence authority confusion remains.

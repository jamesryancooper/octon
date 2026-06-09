# Executable Implementation Prompt: Mechanism Index Validator Guards

proposal_path: `.octon/inputs/exploratory/proposals/architecture/mechanism-index-validator-guards`
next_route: `run-packet-implementation`

## Implementation Scope

Implement only the accepted child packet for `mechanism-index-validator-guards`.
Add validator and test coverage that keeps the governed cross-surface mechanisms index, product feature catalog, generated-effective outputs, operator read models, raw inputs, lifecycle interaction receipts, and state roots inside their declared authority classes.

Live repo state at prompt generation:

- `.octon/framework/assurance/runtime/_ops/scripts/` exists.
- `.octon/framework/assurance/runtime/_ops/tests/` exists.
- `.octon/framework/product/contracts/product-feature-catalog-v1.schema.json` exists.
- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/` is expected to exist after `mechanism-index-foundation` implementation.

Promotion targets:

- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/product/contracts/product-feature-catalog-v1.schema.json`
- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`

## Workstreams

1. Reuse existing validators where possible: product feature catalog, generated non-authority, runtime-effective artifact handles, operator read models, input non-authority, and host projection non-authority.
2. Add or extend a mechanism index validator that rejects mechanism index runtime-authority overclaims.
3. Add path/class consistency checks for `state/control/**` as mutable operational truth and `state/evidence/**` as retained evidence.
4. Add negative controls proving state/control not retained evidence.
5. Add checks proving feature catalog navigation-only posture.
6. Add checks proving lifecycle interaction receipts not authorization.
7. Add checks proving generated-effective surfaces remain non-authoritative and operator read models remain navigation/visibility only.
8. Add checks proving parent proposal-program evidence cannot satisfy child packet receipts.
9. Add retired terminology guard hooks if needed for `Lifecycle Autopilot` containment.

## Authority Boundaries

- Validators may reject invalid authority claims but must not create runtime authority.
- Do not mutate runtime truth, state/control truth, retained evidence, generated outputs, or proposal child-owned receipts.
- Do not create a second control plane through generated or operator-facing validation output.
- Do not collapse proposal lifecycle, Change closeout, worktree closeout, and repo hygiene cleanup.

## Validation

Run these checks at minimum:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-index-validator-guards --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-index-validator-guards
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-index-validator-guards --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-artifact-handles.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-operator-read-models.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/governed-cross-surface-mechanisms-documentation-architecture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-index-validator-guards
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-index-validator-guards
```

Run new validator tests directly from `.octon/framework/assurance/runtime/_ops/tests/`.

## Evidence And Receipts

After implementation, produce:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

The conformance receipt must list validators/tests added or changed and show positive and negative coverage for navigation-only, mechanism-index non-authority, state/control not retained evidence, generated non-authority, operator read-model non-authority, lifecycle interaction receipts not authorization, and parent evidence not satisfying child receipts.

The drift/churn receipt must explain reuse versus new validators, fixture churn, and any remaining stale validation coverage.

## Rollback Posture

Rollback is manual: revert validator and test changes if they produce false authority, duplicate existing validators unnecessarily, or allow authority-class overclaims.

## Terminal Criteria

Implementation is complete only when validator coverage proves the specified boundaries and both required receipts pass. Refuse closeout/archive claims until `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md` exist, pass their validators, and confirm no unresolved validation gap remains.

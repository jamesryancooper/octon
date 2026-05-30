# Executable Implementation Prompt: Retired Terminology Guardrails

proposal_path: `.octon/inputs/exploratory/proposals/architecture/retired-terminology-guardrails`
next_route: `run-packet-implementation`

## Implementation Scope

Implement only the accepted child packet for `retired-terminology-guardrails`.
Contain retired `Lifecycle Autopilot` language to explicit compatibility notes or historical lineage, and use current terminology elsewhere.

Live repo state at prompt generation:

- `.octon/framework/product/features/lifecycle-autopilot.md` exists.
- `.octon/framework/product/roadmap/lifecycle-autopilot.md` exists.
- `.octon/framework/cognition/_meta/architecture/` exists.
- `.octon/framework/assurance/runtime/_ops/scripts/` exists.
- `.octon/framework/assurance/runtime/_ops/tests/` exists.

Promotion targets:

- `.octon/framework/product/features/lifecycle-autopilot.md`
- `.octon/framework/product/roadmap/lifecycle-autopilot.md`
- `.octon/framework/cognition/_meta/architecture/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Workstreams

1. Inventory current uses of `Lifecycle Autopilot` in the promotion targets.
2. Replace current-language uses with `Governed Lifecycle Orchestration` or the correct layer-specific term.
3. Preserve explicit compatibility notes or historical lineage where the retired term is intentionally retained.
4. Ensure compatibility notes are compatibility-only and do not become current product, runtime, policy, support, closeout, cleanup, generated, or retained-evidence authority.
5. Add or update retired terminology validation that rejects `Lifecycle Autopilot` outside compatibility or historical contexts.
6. Keep product docs aligned: current product feature language is `Governed Lifecycle Orchestration`.
7. Keep runtime/operator docs aligned to lifecycles, workflows, routes, state machines, receipts, commands, and skills.

## Authority Boundaries

- Do not delete historical lineage without explicit evidence.
- Do not change runtime behavior or lifecycle dispatch.
- Do not make compatibility notes current authority.
- Do not mutate state/control truth, retained evidence, generated outputs, or child packet receipts.

## Validation

Run these checks at minimum:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/retired-terminology-guardrails --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/retired-terminology-guardrails
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/retired-terminology-guardrails --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/retired-terminology-guardrails
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/retired-terminology-guardrails
```

Run the retired-term validator added by this implementation.

## Evidence And Receipts

After implementation, produce:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

The conformance receipt must list each retained `Lifecycle Autopilot` occurrence and classify it as compatibility note or historical lineage, and list each current-language replacement.

The drift/churn receipt must confirm no historical lineage was silently erased and no compatibility-only text became current authority.

## Rollback Posture

Rollback is manual: revert terminology and validator changes if they erase required lineage, reintroduce retired terminology as current language, or confuse lifecycle, workflow, route, and state machine terms.

## Terminal Criteria

Implementation is complete only when retired terminology is contained, validation passes, and both required receipts pass. Refuse closeout/archive claims until `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md` exist, pass their validators, and confirm no unauthorized terminology drift remains.

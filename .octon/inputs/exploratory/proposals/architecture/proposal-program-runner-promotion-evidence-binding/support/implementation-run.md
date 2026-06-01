# Implementation Run Receipt

verdict: pass
implemented_at: 2026-06-01T14:14:22Z
promotion_evidence_count: 3

## Implementation Scope

Durable promotion work landed for the three accepted promotion target families:

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`

`proposal.yml#status` remains `accepted`; status mutation is still owned by the
separate `promote-proposal` lifecycle route.

## Promotion Evidence

- Runtime evidence binding now validates child `promotion_evidence` before
  `promote-proposal` dispatch against selected child id, child target,
  non-proposal write scopes, child-owned receipt freshness, and recorded
  receipt digests when present.
- Invalid wrong-child, parent-owned, missing, stale, duplicate, unsafe, or
  generated-only evidence fails before workflow dispatch and writes retained
  blocker evidence for the program child route.
- Valid selected-child evidence remains dispatchable to workflow-owned
  promotion and is passed as normalized `promotion_evidence`.

## Changed Durable Targets

- Added selected-child promotion evidence preflight, normalized evidence input
  handling, child-owned receipt validation, blocker evidence retention, and
  focused regression tests in `lifecycle_program.rs`.
- Tightened `promote-proposal` workflow input, validation, promotion, and
  report text so program-child invocation fails closed on unbound evidence.
- Tightened the proposal-packet lifecycle contract so promotion dispatch
  requires implementation-run, conformance, and post-implementation drift
  receipts alongside `promotion_evidence`.

## Generated Outputs

Generated effective extension and capability projections were refreshed through
publication scripts after the lifecycle contract changed.

- extension publication id: `extensions-e539e7c8b239`
- capability routing publication id: `capabilities-680c4550e713`

## Validation Commands

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-promotion-evidence-binding --require-implementation-authorization`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-promotion-evidence-binding`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-promotion-evidence-binding`
- `CARGO_TARGET_DIR=/private/tmp/octon-runtime-crates-target cargo test -p octon_kernel promotion_evidence -- --nocapture`
- `CARGO_TARGET_DIR=/private/tmp/octon-runtime-crates-target cargo test -p octon_kernel child_promotion -- --nocapture`
- `CARGO_TARGET_DIR=/private/tmp/octon-runtime-crates-target cargo test -p octon_kernel unattended_policy -- --nocapture`
- `CARGO_TARGET_DIR=/private/tmp/octon-runtime-crates-target cargo test -p octon_kernel --test proposal_program_cli -- --nocapture`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-promote-proposal-workflow.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh --contract .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
- `bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh`
- `bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`
- `bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-proposal-program-runner-fixture-matrix.sh`
- `bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-authority-boundaries.sh`
- `bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-route-resolution.sh`
- `bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-pack-shape.sh`
- `git diff --check -- .octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs .octon/framework/orchestration/runtime/workflows/meta/promote-proposal .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml .octon/generated/effective/extensions .octon/generated/effective/capabilities`

## Retained Evidence

- `.octon/state/evidence/validation/proposals/proposal-program-runner-promotion-evidence-binding/2026-06-01T141422Z-implementation-route.yml`
- `.octon/state/evidence/validation/publication/extensions/2026-06-01T14-21-35Z-extensions-e539e7c8b239.yml`
- `.octon/state/evidence/validation/publication/capabilities/2026-06-01T14-30-58Z-capabilities-680c4550e713.yml`

## Rollback Posture

Rollback is patch reversal of the runtime binding changes, workflow text,
lifecycle contract source, tests, packet support receipts, and derived
publication outputs from this implementation route. If the lifecycle contract
source is reverted, regenerate extension and capability projections through the
same publication scripts.

## Blockers

None.

# Source Of Truth Map

## Proposal-Local Lifecycle Sources

1. `proposal.yml`
2. `architecture-proposal.yml`

These files are the packet-local lifecycle sources. They govern only this
temporary proposal packet and do not become durable Octon authority.

## Proposal-Local Architecture Sources

1. `navigation/source-of-truth-map.md`
2. `architecture/target-architecture.md`
3. `architecture/implementation-plan.md`
4. `architecture/acceptance-criteria.md`
5. `architecture/file-change-map.md`
6. `architecture/validation-plan.md`
7. `architecture/current-state-gap-map.md`
8. `architecture/cutover-checklist.md`
9. `architecture/rollback-plan.md`
10. `architecture/operator-disclosure.md`

## Source-Authored Durable Targets

The packet proposes later changes only to durable source-authored or
publication-input surfaces outside the proposal path:

- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle-model.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/routing-guide.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/`
- `.octon/framework/product/features/lifecycle-autopilot.md`
- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.md`
- `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-lifecycle-contract.schema.json`
- `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/lifecycle-run-event.schema.json`
- `.octon/framework/engine/runtime/spec/lifecycle-route-execution-request-v1.schema.json`
- `.octon/framework/engine/runtime/spec/lifecycle-route-execution-result-v1.schema.json`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_driver.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-executor-adapter.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-v1-acceptance.sh`

Additive extension inputs under `.octon/inputs/additive/**` are authored
publication inputs. They are not direct runtime or policy authority by being
inside `inputs/**`; they become runtime-discoverable only through the governed
publication path and derived generated effective projections.

## Derived Generated Projection Handles

Generated effective outputs may be used only as runtime discovery and comparison
handles:

- `.octon/generated/effective/extensions/catalog.effective.yml`
- `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/context/lifecycle.contract.yml`
- `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/context/lifecycles/proposal-program.contract.yml`
- `.octon/generated/proposals/registry.yml`

These files must not be edited by this proposal creation step. A later
implementation may refresh them only as a derived publication step after
source-authored changes land and publication receipts are retained.

## Retained Evidence Targets For Later Implementation

Later implementation must retain evidence outside `inputs/**`, including:

- `.octon/state/evidence/runs/<run-id>/**`
- `.octon/state/control/execution/runs/<run-id>/**`
- `.octon/state/evidence/validation/publication/**`

Proposal-local receipts in `support/**` disclose packet state only. They do not
satisfy runtime, policy, promotion, generated publication, or Change closeout
evidence requirements.

## Boundary Rules

- Proposal packets remain temporary, non-canonical, and non-authoritative.
- No proposal manifest status is added by this architecture.
- Runner orchestration stays separate from proposal-extension route semantics.
- The lifecycle executor may run a route only after runner-selected gates,
  authority-zone checks, scope checks, receipt freshness checks, and required
  human approval evidence pass.
- Generated outputs, GitHub and CI state, chat, browser state, tool
  availability, external dashboards, and model memory never become authority.

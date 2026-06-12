# Repository Reconnaissance

## Searches Run

- `rg --files .octon/inputs/exploratory/proposals`
- `rg --files .octon/framework/orchestration/runtime/workflows`
- `rg --files .octon/framework/assurance | rg 'schema|validator|validate|review-finding|review-disposition'`
- `rg --files .octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms .octon/framework/product .octon/instance/governance`
- `rg -n "implementation-conformance|post-implementation|terminal freshness|archive|proposal closeout|closeout" ...`
- `rg --files .octon/framework/capabilities/_ops/scripts .octon/framework/assurance/runtime/_ops/scripts | rg 'publish|generate.*host|projection|proposal.*registry'`

## Existing Surfaces Found

- `current-state-mechanism-architecture-review` exists as a read-only evidence
  workflow for governed mechanism architecture.
- `verify-implementation-conformance` exists as the implementation conformance
  workflow.
- `audit-post-implementation-drift` exists as the drift/churn workflow.
- `lifecycle-postmortem` exists as optional post-run evidence.
- `validate-governed-cross-surface-mechanisms.sh` validates the mechanism index
  and operator map boundaries.
- `validate-product-feature-catalog.sh` validates product feature navigation
  and authority classifications.
- `validate-proposal-implementation-conformance.sh`,
  `validate-proposal-post-implementation-drift.sh`, and
  `validate-proposal-lifecycle-terminal-freshness.sh` own existing proposal
  lifecycle gates.
- `publish-capability-routing.sh`, `publish-host-projections.sh`,
  `generate-proposal-registry.sh`, `publish-runtime-route-bundle.sh`, and
  `publish-pack-routes.sh` own generated publication paths.
- `review-finding-v1` and `review-disposition-v1` already exist in assurance
  contracts.

## Reused Surfaces

- Current-state mechanism architecture review is reused as an evidence lens.
- Implementation conformance and drift/churn validators remain predecessor
  gates.
- Existing publication scripts remain source of generated freshness evidence.
- Existing review finding and disposition schemas remain the finding model.
- Product feature catalog and governed mechanism index remain navigation and
  architecture guidance.

## Rejected Surfaces And Reason

- Lifecycle postmortem was rejected as the hard gate because its contract is
  evidence-only.
- Current-state mechanism architecture review was rejected as the whole hard
  gate because it does not prove implementation conformance, drift/churn,
  publication freshness, or terminal freshness by itself.
- A new mechanism-level control plane was rejected because existing lifecycle
  contracts and validators already own authority.

## New Surfaces Proposed

- A workflow that orchestrates existing evidence into one strict integration
  receipt.
- A mechanism integration profile schema to declare expected surfaces and
  `not_applicable` rationales.
- A governed mechanism integration receipt schema to validate the hard gate.
- Two validators and focused tests for profile and receipt validation.
- Conditional proposal lifecycle hooks and terminal freshness integration for
  mechanism proposals.

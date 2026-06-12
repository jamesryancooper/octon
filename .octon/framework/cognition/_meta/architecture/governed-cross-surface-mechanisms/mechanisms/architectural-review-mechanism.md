# Architectural Review Mechanism

## Role

The Architectural Review Mechanism is the native Octon mechanism for
schema-backed architecture review, route selection, evidence capture, and
proposal lifecycle gating.

## Native Authority

- Doctrine: `/.octon/framework/cognition/practices/methodology/architectural-review/`
- Workflows:
  - `pre-integration-architecture-review`
  - `post-integration-architecture-review`
  - `current-state-mechanism-architecture-review`
  - `architecture-readiness-audit`
- Schemas:
  - `architectural-review-report-v1`
  - `architectural-review-routing-decision-v1`
  - `architectural-review-support-receipt-v1`
- Validators:
  - `validate-architectural-review-naming.sh`
  - `validate-architectural-review-routing.sh`
  - `validate-architectural-review-receipts.sh`
  - `validate-architectural-review-workflows.sh`
  - `validate-architectural-review-lifecycle-gates.sh`

## Lifecycle Boundary

Pre-Integration Architecture Review is mandatory for architecture proposal
acceptance and implementation authorization. The gate is enforced by
`validate-proposal-review-gate.sh` through
`support/pre-integration-architecture-review.yml`.

Post-Integration Architecture Review remains evidence-only unless a later
durable policy explicitly changes that status. Implementation conformance and
post-implementation drift/churn remain the hard closeout gates.

## Non-Authority Boundary

Raw inputs, proposal packets, generated outputs, proposal-local analysis, chat,
host state, dashboards, tool availability, model memory, lifecycle postmortems,
and extension packetization helpers cannot authorize mutation, closeout,
promotion, redesign, support widening, generated publication, or constitutional
amendment.

Skills and commands invoke workflows only. They do not define a second control
plane and do not duplicate workflow authority.

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
- Audit modes:
  - canonical `domain-architecture-audit`, invoked through
    `audit-domain-architecture`
  - canonical `surface-architecture-audit`, invoked through
    `audit-surface-architecture`
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
  - `validate-architectural-review-skills-commands.sh`
  - `validate-governed-cross-surface-mechanisms.sh`
  - `validate-product-feature-catalog.sh`

## Invocation And Navigation

The product feature entry at
`/.octon/framework/product/features/architectural-review-mechanism.md` is
navigation-only. It does not authorize review outcomes, lifecycle gates,
generated publication, or closeout.

Command facades exist for:

- `pre-integration-architecture-review`
- `post-integration-architecture-review`
- `current-state-mechanism-architecture-review`
- `architecture-readiness-audit`
- `audit-domain-architecture`
- `audit-surface-architecture`

`architecture-readiness-audit` remains canonical. `audit-architecture-readiness`
is retired outside historical, retired-name documentation, and validator
contexts.

## Lifecycle Boundary

Pre-Integration Architecture Review is mandatory for architecture proposal
acceptance and implementation authorization. The gate is enforced by
`validate-proposal-review-gate.sh` through
`support/pre-integration-architecture-review.yml`.

Post-Integration Architecture Review remains evidence-only unless a later
durable policy explicitly changes that status. Implementation conformance and
post-implementation drift/churn remain the hard closeout gates.

Architecture Readiness Audit, Domain Architecture Audit, and Surface
Architecture Audit emit retained audit evidence. They do not authorize proposal
acceptance, implementation, closeout, generated publication, or support
widening.

## Non-Authority Boundary

Raw inputs, proposal packets, generated outputs, proposal-local analysis, chat,
host state, dashboards, tool availability, model memory, lifecycle postmortems,
and extension packetization helpers cannot authorize mutation, closeout,
promotion, redesign, support widening, generated publication, or constitutional
amendment.

Skills and commands invoke workflows only. They do not define a second control
plane and do not duplicate workflow authority.

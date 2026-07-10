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
  - `architectural-review-support-receipt-v1` (lifecycle-gating support receipt; method-free)
  - `architectural-review-report-v2` (additive run evidence; carries `method` and `lenses_applied`)
  - `architectural-review-routing-decision-v2` (additive run evidence; carries `method` and `lenses_applied`)
- Method layer (navigation):
  - method catalog:
    `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml`
    (`methods.catalog`; default `balanced-architecture-review-method`), one method
    doc per catalog entry beside it
  - shared lens bank:
    `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml`
    and `architecture-lens-bank.md`
  - method selection: the `method_selection` block in
    `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml`
    (`default_method`, `allowed_methods_by_route`, `escalation_map`), fail-closed on
    `unknown_method` and `missing_method_record`
- Validators:
  - `validate-architectural-review-naming.sh`
  - `validate-architectural-review-routing.sh`
  - `validate-architectural-review-receipts.sh`
  - `validate-architectural-review-workflows.sh`
  - `validate-architectural-review-lifecycle-gates.sh`
  - `validate-architectural-review-extension-split.sh`
  - `validate-architectural-review-skills-commands.sh`
  - `validate-architectural-review-lens-references.sh`
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

## Method Layer (Navigation)

Each review run selects one method (how the review is conducted) for a given
occasion (the route) and records the selected method id and the applied lens
profile in run evidence through the v2 routing-decision or report artifact, inside
the existing run-evidence root
`.octon/state/evidence/runs/workflows/<run-id>/architectural-review/<occasion>/`.
This is descriptive run evidence only: it introduces no new stage, gate, evidence
root, or review-output authority, and the lifecycle-gating support receipt stays
`architectural-review-support-receipt-v1` and method-free.

Balanced Architecture Review is the default for every occasion; companion methods
are advisory options recommended on the named escalation conditions in
`review-routing.yml` (`method_selection.escalation_map`): Greenfield when the
target does not exist yet, Tradeoff when two or more viable target designs are in
play, Failure-Mode when runtime or governance failure behavior is in doubt,
Evolution/Fitness when long-lived mechanism health is in doubt, and
Boundary/Authority when authority location is in doubt. `unknown_method` and
`missing_method_record` are fail-closed per routing v2. Method selection creates
no lifecycle gate and grants no review output any authority.

## Non-Authority Boundary

Raw inputs, proposal packets, generated outputs, proposal-local analysis, chat,
host state, dashboards, tool availability, model memory, lifecycle postmortems,
and extension packetization helpers cannot authorize mutation, closeout,
promotion, redesign, support widening, generated publication, or constitutional
amendment.

Skills and commands invoke workflows only. They do not define a second control
plane and do not duplicate workflow authority.

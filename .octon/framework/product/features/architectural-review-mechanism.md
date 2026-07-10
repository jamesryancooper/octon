# Architectural Review Mechanism

This feature note is navigation-only. It helps agents and operators find the
native architectural review doctrine, workflows, skills, commands, validators,
retained evidence, and generated projections.

## Boundary

- The product feature entry does not authorize review outcomes, lifecycle
  gates, generated publication, or closeout.
- Pre-Integration Architecture Review remains mandatory for architecture
  proposal acceptance and implementation authorization.
- Post-Integration Architecture Review remains evidence-only.
- Current-State Mechanism Architecture Review remains evidence-only.
- `architecture-readiness-audit` remains the canonical readiness audit name.
- `audit-architecture-readiness` remains retired outside historical,
  retired-name documentation, and validator contexts.
- `audit-domain-architecture` and `audit-surface-architecture` are invocation
  aliases for the canonical `domain-architecture-audit` and
  `surface-architecture-audit` modes.
- Generated outputs remain derived-only and must be refreshed through canonical
  publication scripts.
- Proposal-local receipts remain evidence only.

## Main Surfaces

- Methodology: `.octon/framework/cognition/practices/methodology/architectural-review/`
- Governed mechanism detail:
  `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/mechanisms/architectural-review-mechanism.md`
- Workflows:
  `.octon/framework/orchestration/runtime/workflows/audit/pre-integration-architecture-review/`,
  `.octon/framework/orchestration/runtime/workflows/audit/post-integration-architecture-review/`,
  `.octon/framework/orchestration/runtime/workflows/audit/current-state-mechanism-architecture-review/`,
  and `.octon/framework/orchestration/runtime/workflows/audit/architecture-readiness-audit/`
- Command facades:
  `/pre-integration-architecture-review`,
  `/post-integration-architecture-review`,
  `/current-state-mechanism-architecture-review`,
  `/architecture-readiness-audit`,
  `/audit-domain-architecture`,
  and `/audit-surface-architecture`

## Method Layer

The mechanism operates an explicit method layer (navigation-only; it authorizes
nothing). A review run selects one **method** (how the review is conducted) for a
given **occasion** (the route), records it as descriptive run evidence, and grants
that record no lifecycle, acceptance, promotion, or closeout authority.

- Method catalog:
  `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml`
  (`methods.catalog`; `balanced-architecture-review-method` is the default), with
  one method doc per entry beside it: `balanced-architecture-review-method.md`,
  `greenfield-reference-architecture-review-method.md`, `tradeoff-review-method.md`,
  `failure-mode-review-method.md`, `evolution-fitness-review-method.md`, and
  `boundary-authority-review-method.md`.
- Shared lens bank:
  `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml`
  and `architecture-lens-bank.md` — methods select lenses from this one bank.
- Method-selection mechanics: the `method_selection` block in
  `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml`
  (`default_method`, `allowed_methods_by_route`, `escalation_map`), fail-closed on
  `unknown_method` and `missing_method_record`.
- v2 evidence schemas (additive; carry `method` and `lenses_applied`):
  `.octon/framework/constitution/contracts/assurance/architectural-review-report-v2.schema.json`
  and
  `.octon/framework/constitution/contracts/assurance/architectural-review-routing-decision-v2.schema.json`.
  The lifecycle-gating support receipt stays
  `architectural-review-support-receipt-v1` and remains method-free.
- Lens-reference validator:
  `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lens-references.sh`.

Each of the four review occasions records the selected method id and the applied
lens profile in run evidence through the v2 routing-decision or report artifact,
inside the existing run-evidence root
`.octon/state/evidence/runs/workflows/<run-id>/architectural-review/<occasion>/`.
No new stage, gate, evidence root, or review-output authority is introduced.

## Per-Occasion Method Advisory

Balanced Architecture Review is the default for every occasion; companion methods
are recommended (advisory only) on the named escalation conditions. Lifecycle
prompts consult this advisory by reference; it changes no gate.

- Pre-Integration Architecture Review: Balanced default; Greenfield when the
  target does not exist yet, Tradeoff when two or more viable designs are in play,
  Failure-Mode when failure behavior is in doubt, Evolution/Fitness when
  long-lived health is in doubt, Boundary/Authority when authority location is in
  doubt.
- Post-Integration Architecture Review: Balanced default; Failure-Mode,
  Evolution/Fitness, or Boundary/Authority on the corresponding condition.
- Current-State Mechanism Architecture Review: Balanced default; Evolution/Fitness,
  Boundary/Authority, or Failure-Mode on the corresponding condition.
- Architecture Readiness Audit: Balanced default; Failure-Mode when failure
  behavior is in doubt — readiness verdict semantics are unchanged.

## Validation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-workflows.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-skills-commands.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-cross-surface-mechanisms.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
```

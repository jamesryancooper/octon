# Executable Implementation Prompt

Implement `evidence-provenance-hardening` as a child-owned proposal packet
under the parent `governed-workflow-runtime-transition-program`.

## Promotion Targets

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/contracts/retention/`
- `.octon/framework/constitution/contracts/disclosure/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Required Work

Bind the durable evidence obligation namespace, retention contracts,
disclosure contracts, receipt provenance requirements, and assurance validators
to child-owned retained evidence. Keep proposal-local inputs as planning
artifacts only; implementation authority must live in the promotion targets or
under retained evidence roots outside `inputs/**`.

## Validation

Run and record outcomes for:

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-provenance-hardening`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-provenance-hardening`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-provenance-hardening`
- `validate-evidence-obligation-ids.sh`
- `validate-evidence-disclosure-tiers.sh`
- `validate-evidence-completeness.sh`
- `validate-disclosure-wording-coherence.sh`
- `generate-proposal-registry.sh --check`

Retain evidence under
`.octon/state/evidence/validation/proposals/evidence-provenance-hardening/`.

## Required Receipts

Write or refresh:

- `support/implementation-run.md`
- `support/validation.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/proposal-closeout.md`

## Rollback

Rollback is limited to the declared promotion targets. If validation finds
that provenance requirements block supported closeout or evidence workflows,
revert or narrow the affected evidence obligation, retention, disclosure,
runtime specification, or validator edits while preserving retained validation
receipts.

## Closeout Refusal Criteria

Refuse closeout or archive when retained evidence is missing, when validation
does not pass, when proposal-local inputs are cited as implementation
authority, when generated read models are cited as control or evidence
authority, or when conformance and drift/churn receipts do not pass.

# Executable Implementation Prompt

Implement `migration-cutover-compatibility-retirement` as a child-owned cutover confirmation packet for the Governed Workflow Runtime transition program.

## Scope

- Confirm durable compatibility-retirement wording in:
  - `.octon/framework/cognition/_meta/terminology/naming-constitution.md`
  - `.octon/framework/cognition/_meta/terminology/glossary.md`
  - `.octon/framework/cognition/_meta/architecture/specification.md`
  - `.octon/README.md`
  - `.octon/AGENTS.md`
  - `.octon/instance/ingress/AGENTS.md`
  - `.octon/instance/bootstrap/START.md`
- Record child-owned implementation, validation, conformance, drift/churn, and closeout receipts.
- Retain validation evidence outside `inputs/**` under `.octon/state/evidence/validation/proposals/migration-cutover-compatibility-retirement/`.

## Required Validation Commands

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/migration-cutover-compatibility-retirement --require-implementation-authorization`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-compatibility-retirement-readiness.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-compatibility-retirement-cutover.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/migration-cutover-compatibility-retirement --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/migration-cutover-compatibility-retirement`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/migration-cutover-compatibility-retirement`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/migration-cutover-compatibility-retirement`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/migration-cutover-compatibility-retirement`
- `cd .octon/inputs/exploratory/proposals/architecture/migration-cutover-compatibility-retirement && shasum -a 256 -c SHA256SUMS.txt`

## Required Receipts

- `support/implementation-run.md`
- `support/validation.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/proposal-closeout.md`

## Rollback Expectations

Rollback is to restore the child to accepted status, remove implementation closeout authority from this packet, preserve predecessor child archives, and keep Governed Agent Runtime compatibility wording bounded until a corrected cutover receipt is available.

## Closeout Refusal Criteria

Refuse closeout if any required predecessor child lacks implemented archive metadata, retained promotion evidence, implementation-run receipt, conformance receipt, drift/churn receipt, closeout receipt, or current validator coverage.

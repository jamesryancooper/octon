# Follow-Up Program Verification Prompt

Verify `governed-workflow-runtime-transition-program` after required child
implementation and archive closeout.

## Required Checks

- Confirm every required child in `resources/child-packet-index.yml` is archived
  implemented with child-owned implementation-run, validation, conformance,
  drift/churn, proposal-closeout, archive metadata, and retained promotion
  evidence.
- Confirm deferred candidates remain `required: false`, `deferred: true`, and
  explicitly resolved by retained parent disposition evidence.
- Run:
  - `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/governed-workflow-runtime-transition-program`
  - `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/governed-workflow-runtime-transition-program`
  - `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/governed-workflow-runtime-transition-program`
  - `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/governed-workflow-runtime-transition-program --skip-registry-check`

## Refusal Criteria

Refuse parent closeout if a required child is active, lacks implemented archive
metadata, lacks child-owned retained evidence, or if parent evidence is used as
a substitute for any child-owned lifecycle receipt.

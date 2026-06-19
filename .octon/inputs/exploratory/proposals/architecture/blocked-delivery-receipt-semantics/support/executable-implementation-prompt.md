# Executable Implementation Prompt: blocked-delivery-receipt-semantics

prompt_id: blocked-delivery-receipt-semantics-implementation-20260617T000000Z
packet: .octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics
route: octon-proposal-lifecycle-run-packet-implementation
authorized_by: .octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics/support/proposal-review.md

## Boundary

Execute only this child packet. The parent program
`.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`
is context only and must not be implemented, promoted, closed out, archived,
cleaned, landed, published, deleted, or used as implementation evidence.

Allowed durable promotion targets:

- `.octon/framework/product/contracts/proposal-packet-delivery-receipt-v1.schema.json`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-receipt.sh`

Allowed proposal-local support evidence for this child:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Refuse implementation and route to correction if durable behavior requires any
target outside the two promotion targets above. Do not hand-edit generated
outputs. Do not mutate historical delivery receipts.

## Preconditions

Before durable edits, confirm:

- `proposal.yml#status` is `accepted`.
- `support/proposal-review.md` records `verdict: accepted`,
  `implementation_prompt_authorized: yes`, and
  `open_blocking_findings_count: 0`.
- These gates pass for this child:
  - `validate-proposal-review-gate.sh --package <child> --require-implementation-authorization`
  - `validate-proposal-implementation-readiness.sh --package <child>`
  - `validate-architecture-proposal.sh --package <child>`
  - `validate-proposal-standard.sh --package <child> --skip-registry-check`
  - `validate-architectural-review-receipts.sh --receipt <child>/support/pre-integration-architecture-review.yml --package <child> --mode pre-integration-architecture-review --require-pass`

## Implementation Task

Update the proposal packet delivery receipt schema and validator so a blocked
delivery receipt is structurally truthful:

- `actual_outcome: blocked` validates only when explicit blocker evidence is
  present.
- A blocked receipt without explicit blockers fails.
- Success-only proof requirements are not imposed on blocked receipts.
- Non-blocked outcomes with open blockers fail.
- `cleaned` outcomes remain strict and still require target-owned receipts,
  promotion evidence, packet and terminal closeout receipts, archive evidence,
  Change closeout evidence, final sync proof, terminal current-state proof,
  worktree hygiene, generated-publication freshness, and non-authority
  boundaries.
- Aggregate delivery receipts summarize target-owned receipts but never replace
  target-owned receipts.

Keep the validator deterministic and shell-native, matching the surrounding
style. Prefer a narrow `actual_outcome == blocked` branch instead of relaxing
the existing cleaned path.

## Required Evidence

Record child-owned evidence after implementation:

- `support/implementation-run.md`: changed files, commands, outcomes, and any
  temporary fixture path used for blocked receipt validation.
- `support/implementation-conformance-review.md`: verdict pass/fail, exact
  promotion-target conformance, and explicit statement that parent review
  evidence was not reused.
- `support/post-implementation-drift-churn-review.md`: verdict pass/fail,
  changed-path check, unrelated worktree preservation, and generated-output
  hand-edit check.
- `support/validation.md`: passing validator commands and results.

## Validators

Run and record:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics --require-implementation-authorization`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics --mode pre-integration-architecture-review --require-pass`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-receipt.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-receipt.sh --receipt <valid-blocked-fixture>`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-packet-delivery.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics`

The blocked fixture may be temporary validation evidence. If retained inside the
packet, place it only where proposal-review freshness rules permit. Do not add a
durable shared fixture unless the child packet is revised to include that target.

## Rollback

Rollback is a paired revert of the schema and validator changes. Do not edit
historical receipts to make rollback appear successful.

## Closeout Refusal Criteria

Refuse closeout/archive/publish/landing/branch deletion/cleanup/retained
evidence deletion/`cleaned` claims. This route stops after durable
implementation evidence is recorded. Promotion to `implemented` is a separate
child-only lifecycle step.

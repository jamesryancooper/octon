# Executable Implementation Prompt: packet-delivery-wrapper-orchestration-autonomy

prompt_id: packet-delivery-wrapper-orchestration-autonomy-implementation-20260618T012157Z
packet: .octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy
route: octon-proposal-lifecycle-run-packet-implementation
authorized_by: .octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy/support/proposal-review.md

## Boundary

Execute only this child packet. The parent program
`.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`
is context only and must not be implemented, promoted, closed out, archived,
cleaned, landed, published, deleted, or used as implementation evidence.

The prerequisite child
`.octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics`
is dependency evidence only. Do not reuse its review, implementation,
verification, promotion, or validator evidence as evidence for this child.

Allowed durable promotion targets:

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/`
- `.octon/framework/capabilities/runtime/commands/proposal-packet-delivery.md`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-packet-delivery/SKILL.md`
- `.octon/framework/product/contracts/proposal-packet-delivery-profile-v1.schema.json`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh`

Allowed proposal-local support evidence for this child:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Refuse implementation and route to correction if durable behavior requires any
target outside the promotion targets above. Do not hand-edit generated outputs.
Do not mutate historical delivery receipts, parent review receipts, or sibling
child evidence.

## Preconditions

Before durable edits, confirm:

- `proposal.yml#status` is `accepted`.
- `support/proposal-review.md` records `verdict: accepted`,
  `implementation_prompt_authorized: yes`, and
  `open_blocking_findings_count: 0`.
- `blocked-delivery-receipt-semantics` is implemented and its dependency gate
  is satisfied, including:
  - `support/implementation-run.md` exists.
  - `support/implementation-conformance-review.md` exists and passes.
  - `support/post-implementation-drift-churn-review.md` exists and passes.
  - `support/validation.md` records passing child-specific validators.
  - `validate-proposal-implementation-conformance.sh --package <child1>` passes.
  - `validate-proposal-post-implementation-drift.sh --package <child1>` passes.
  - `validate-proposal-lifecycle-terminal-freshness.sh --proposal <child1> --run-registry-check` passes.
  - Independent verification reported no blocking findings.
- These gates pass for this child:
  - `validate-proposal-review-gate.sh --package <child> --require-implementation-authorization`
  - `validate-proposal-implementation-readiness.sh --package <child>`
  - `validate-architecture-proposal.sh --package <child>`
  - `validate-proposal-standard.sh --package <child> --skip-registry-check`
  - `validate-architectural-review-receipts.sh --receipt <child>/support/pre-integration-architecture-review.yml --package <child> --mode pre-integration-architecture-review --require-pass`

## Implementation Task

Update the packet delivery wrapper workflow, command, skill, profile schema, and
workflow validator so `/proposal-packet-delivery outcome=cleaned
route=branch-no-pr` is the outer orchestrator for accepted packet delivery.

Required behavior:

- Validate the delivery profile before any delivery claim.
- Require `route=branch-no-pr` for cleaned no-PR delivery.
- Forbid PR fallback and PR metadata for the branch-no-PR route.
- Recognize and route pre-archive and already-archived packet states
  explicitly.
- Route implementation, implementation conformance, drift/churn review,
  proposal promotion, packet closeout, terminal packet closeout, archive
  handoff, Change closeout, final sync, branch cleanup authorization, terminal
  current-state proof, and hygiene through their owning lifecycle surfaces.
- Keep archive relocation, generated publication, Change closeout, cleanup,
  final sync, and terminal proof owner-routed. The wrapper may detect missing
  evidence and route to the owner, but it must not replace the owner.
- Emit an aggregate delivery receipt that summarizes target-owned receipts and
  never replaces target-owned receipts.
- Emit `actual_outcome: blocked` with explicit blockers and the next owning
  lifecycle when a gate lacks required evidence.
- Preserve generated outputs as derived-only and refresh generated outputs only
  through canonical generators when a lifecycle route requires it.

Keep the implementation deterministic and aligned with the existing workflow,
schema, skill, command, and shell validator style. Prefer narrow additions to
the existing route contract over a rewrite.

## Required Evidence

Record child-owned evidence after implementation:

- `support/implementation-run.md`: changed files, commands, dependency preflight
  results, durable behavior implemented, and any blocked/deferred items.
- `support/implementation-conformance-review.md`: verdict pass/fail, exact
  promotion-target conformance, aggregate receipt boundary, PR fallback
  refusal, owner routing, and explicit statement that parent and sibling
  evidence were not reused as this child evidence.
- `support/post-implementation-drift-churn-review.md`: verdict pass/fail,
  changed-path check, generated-output hand-edit check, unrelated worktree
  preservation, proposal-path backreference check for durable targets, and
  closeout/archive/cleanup refusal.
- `support/validation.md`: passing validator commands and results.

## Validators

Run and record:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy --require-implementation-authorization`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy --mode pre-integration-architecture-review --require-pass`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-profile.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-receipt.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-packet-delivery.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy`

## Rollback

Rollback is a paired revert of the workflow, command, skill, profile schema, and
workflow validator changes made for this child. Do not edit generated outputs,
historical receipts, parent evidence, or sibling evidence to make rollback
appear successful.

## Closeout Refusal Criteria

Refuse closeout/archive/publish/landing/branch deletion/cleanup/retained
evidence deletion/`cleaned` claims. This route stops after durable
implementation evidence is recorded. Promotion to `implemented` is a separate
child-only lifecycle step.

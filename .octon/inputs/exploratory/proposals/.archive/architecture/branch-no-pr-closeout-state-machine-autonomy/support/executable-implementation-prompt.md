# Executable Implementation Prompt: branch-no-pr-closeout-state-machine-autonomy

prompt_id: branch-no-pr-closeout-state-machine-autonomy-implementation-20260618T015855Z
packet: .octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy
route: octon-proposal-lifecycle-run-packet-implementation
authorized_by: .octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy/support/proposal-review.md

## Boundary

Execute only this child packet. The parent program
`.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`
is context only and must not be implemented, promoted, closed out, archived,
cleaned, landed, published, deleted, or used as implementation evidence.

The prerequisite children are dependency evidence only. Do not reuse their
review, implementation, verification, promotion, or validator evidence as
evidence for this child.

Allowed durable promotion targets:

- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`

Allowed proposal-local support evidence for this child:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Refuse implementation and route to correction if durable behavior requires any
target outside the promotion targets above. Do not hand-edit generated outputs.
Do not mutate historical Change receipts, parent review receipts, sibling
child evidence, branch state, hosted refs, cleanup state, or retained evidence.

## Preconditions

Before durable edits, confirm:

- `proposal.yml#status` is `accepted`.
- `support/proposal-review.md` records `verdict: accepted`,
  `implementation_prompt_authorized: yes`, and
  `open_blocking_findings_count: 0`.
- `packet-delivery-wrapper-orchestration-autonomy` is implemented and its
  dependency gate is satisfied, including:
  - `support/implementation-run.md` exists.
  - `support/implementation-conformance-review.md` exists and passes.
  - `support/post-implementation-drift-churn-review.md` exists and passes.
  - `support/validation.md` records passing child-specific validators.
  - `validate-proposal-implementation-conformance.sh --package <child2>` passes.
  - `validate-proposal-post-implementation-drift.sh --package <child2>` passes.
  - `validate-proposal-lifecycle-terminal-freshness.sh --proposal <child2> --run-registry-check` passes.
  - Independent verification reported no blocking findings.
- These gates pass for this child:
  - `validate-proposal-review-gate.sh --package <child> --require-implementation-authorization`
  - `validate-proposal-implementation-readiness.sh --package <child>`
  - `validate-architecture-proposal.sh --package <child>`
  - `validate-proposal-standard.sh --package <child> --skip-registry-check`
  - `validate-architectural-review-receipts.sh --receipt <child>/support/pre-integration-architecture-review.yml --package <child> --mode pre-integration-architecture-review --require-pass`

## Implementation Task

Update, or confirm already-current, branch-no-PR closeout state-machine
behavior so `closeout-change` owns progression from branch-local completion to
published branch, hosted no-PR landing, final sync, governed branch cleanup,
and `cleaned` only when route-specific proof exists.

If the current durable state already satisfies every required behavior below,
do not churn durable targets. Instead, record a no-op durable implementation in
the child-owned implementation evidence and explain which existing schema,
skill, reference, validator, and test surfaces prove the behavior.

Required behavior:

- Branch-no-PR receipts distinguish `branch-local-complete`,
  `published-branch`, `landed`, `cleaned`, `deferred`, and `blocked` actual
  outcomes.
- Hosted branch-no-PR landing requires governed landing authorization, source
  ref proof, hosted main update proof, landed ref, rollback handle, exact-SHA
  required-check or explicit empty-check rationale, and main alignment proof.
- `cleaned` requires landing proof, final sync proof, cleanup authorization,
  cleanup evidence, and branch deletion or retained-branch disposition.
- Missing landing, sync, cleanup, or authorization proof produces a lower
  actual outcome with explicit blocker or stop-reason evidence.
- Cleanup authorization is required before branch deletion, branch pruning, or
  any `cleaned` claim.
- Protected retained evidence and local run residue are not deleted as branch
  cleanup; eligible local residue stays routed to `repo-hygiene-cleanup`.
- PR metadata remains invalid for branch-no-PR receipts, and route transition
  to `branch-pr` requires explicit transition authority and predicate evidence.
- `closeout-change` must not replace proposal-packet delivery wrapper
  orchestration, archive relocation, generated publication, terminal proof, or
  global worktree hygiene ownership.

Keep the implementation deterministic and aligned with the existing schema,
skill, reference, and shell validator style. Prefer narrow additions to
existing closeout semantics over a rewrite.

## Required Evidence

Record child-owned evidence after implementation:

- `support/implementation-run.md`: changed files or no-op durable
  implementation, commands, dependency preflight results, durable behavior
  implemented or confirmed, and any blocked/deferred items.
- `support/implementation-conformance-review.md`: verdict pass/fail, exact
  promotion-target conformance, state-machine coverage, cleanup authorization
  coverage, PR metadata refusal, protected-evidence boundary, and explicit
  statement that parent and sibling evidence were not reused as this child
  evidence.
- `support/post-implementation-drift-churn-review.md`: verdict pass/fail,
  changed-path check, generated-output hand-edit check, unrelated worktree
  preservation, proposal-path backreference check for durable targets, and
  closeout/archive/cleanup refusal.
- `support/validation.md`: passing validator commands and results.

## Validators

Run and record:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy --require-implementation-authorization`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy --mode pre-integration-architecture-review --require-pass`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal .octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy --run-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy`

## Rollback

Rollback is a paired revert of any Change receipt schema and closeout-change
skill/reference changes made for this child. If the implementation is a no-op
durable confirmation, rollback is limited to removing this child's
implementation evidence and returning the child lifecycle route to the prior
accepted state through a governed correction route.

Do not edit generated outputs, historical receipts, parent evidence, sibling
evidence, branch state, cleanup state, or retained evidence to make rollback
appear successful.

## Closeout Refusal Criteria

Refuse closeout/archive/publish/landing/branch deletion/cleanup/retained
evidence deletion/`cleaned` claims. This route stops after durable
implementation evidence is recorded. Promotion to `implemented` is a separate
child-only lifecycle step.

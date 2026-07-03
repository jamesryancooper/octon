prompt_id: run-program-clean-delivery-postmortem-hardening-follow-up-program-verification-20260703T0857Z
generated_by: octon-proposal-lifecycle-generate-program-verification-prompt
target_program: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening
route: run-program-verification-and-correction-loop
lifecycle_id: proposal-program
program_run_id: lifecycle-proposal-program-postmortem-hardening-20260703T0857Z
artifact_class: operational-aid
authority: non-authoritative
generated_at: 2026-07-03T08:57:00Z

# Follow-Up Program Verification Prompt

## Purpose

Run aggregate parent program verification for
`.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening`
after the parent implementation orchestration run.

This prompt is an operational handoff. It is not control truth, parent
closeout evidence, child evidence, archive authorization, cleanup
authorization, landing authorization, publication authorization, deletion
authorization, branch cleanup authorization, or a `cleaned` claim.

The verification loop must write both parent-local aggregate receipts:

- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`

Those receipts may summarize child state by reference, but they must not
satisfy child receipts, child validation verdicts, child promotion targets,
child archive metadata, delivery receipts, Change receipts, cleanup
dispositions, rollback handles, terminal proof, or child terminal outcomes.

## Prompt Generation Basis

The prompt bundle was consumed through a compact capsule with fresh alignment
evidence:

- prompt set: `octon-proposal-lifecycle-generate-program-verification-prompt`
- bundle digest:
  `sha256:18e80cae87192d0e7e403e3db1ce5207d09597f9c3525dfff68631d10f1a5969`
- alignment receipt:
  `.octon/state/evidence/validation/extensions/prompt-alignment/2026-07-03T06-21-11Z-octon-proposal-lifecycle-octon-proposal-lifecycle-generate-program-verification-prompt.yml`
- route run: `lifecycle-proposal-program-postmortem-hardening-20260703T0857Z`

Generation-time digest checks for the required repo anchors and prompt assets
matched the compact capsule. Full prompt expansion was not active.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: verify one implemented parent program from retained parent
  and child evidence while preserving child-owned authority boundaries
- transitional exception: not authorized

## Boundaries

- Preserve parent `proposal.yml#status: implemented` unless a separate
  authorized lifecycle route changes it.
- Do not promote, close out, archive, clean, land, publish, delete residue,
  delete branches, mutate host state, or claim `cleaned` for the parent.
- Do not use parent evidence to satisfy child-owned evidence.
- Do not recreate child evidence from the parent route. Inspect existing child
  receipts, child archive metadata, retained workflow evidence, and retained
  validation evidence.
- Do not mutate child manifests, child subtype manifests, child receipts,
  child archive metadata, child validation verdicts, child promotion targets,
  cleanup dispositions, rollback handles, or terminal outcomes.
- Do not hand-edit generated outputs. Refresh generated outputs only through
  canonical generators if a validator proves they are stale and the route
  allows refresh.
- Treat proposal-local files, generated proposal registries, generated
  effective projections, generated prompts, host projections, dashboards, chat
  history, tool state, and model memory as non-authoritative.

## Mandatory Reads

Read the current parent packet:

- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/architecture-proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/README.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/navigation/source-of-truth-map.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/navigation/artifact-catalog.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/resources/child-packet-index.yml`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/resources/child-packet-index.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/architecture/child-packet-contract.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/architecture/packet-sequence.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/architecture/program-closeout-plan.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/architecture/target-architecture.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/architecture/implementation-plan.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/architecture/acceptance-criteria.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/validation-plan.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/support/implementation-grade-completeness-review.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/support/proposal-review.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/support/pre-integration-architecture-review.yml`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/support/program-implementation-orchestration-prompt.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/support/program-implementation-orchestration-run.md`

Read retained parent workflow and control evidence:

- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-postmortem-hardening-20260703T0857Z/program-lifecycle-checkpoint.yml`
- `.octon/state/control/execution/runs/lifecycle-proposal-program-postmortem-hardening-20260703T0857Z/program-lifecycle-checkpoint.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-postmortem-hardening-20260703T0857Z/program-events.ndjson`
- `.octon/state/control/execution/runs/lifecycle-proposal-program-postmortem-hardening-20260703T0857Z/program-events.ndjson`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-postmortem-hardening-20260703T0857Z/worktree-baseline.yml`
- `.octon/state/evidence/runs/skills/proposal-program-delivery/run-program-clean-delivery-postmortem-hardening-20260703T082428Z/delivery-profile.yml`

Read each archived child packet and inspect the child-owned support receipts:

- `support/proposal-review.md`
- `support/pre-integration-architecture-review.yml`
- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`
- `support/proposal-closeout.md`
- `support/proposal-terminal-closeout.yml`

Required child archive paths:

- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-architecture-review-freshness`
- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-delivery-receipt-completion`
- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-change-closeout-reconciliation`
- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-cleanup-disposition`
- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-validator-hardening`
- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-test-hermeticity`

## Verification Work

1. Confirm current worktree state and classify changes as child durable
   targets, child proposal-local receipts, parent-local coordination evidence,
   generated outputs, retained evidence, cleanup residue, unrelated residue, or
   explicit dirty-start baseline residue.
2. Confirm parent `proposal.yml#status` is `implemented`.
3. Confirm the parent proposal review gate is current. If
   `reviewed_packet_digest` is stale after reviewed packet files changed,
   record that as a blocker and do not hand-edit the review receipt from this
   route.
4. Confirm the parent strict architecture receipt exists and reports a passing
   pre-integration architecture review with no unresolved items.
5. Confirm the parent implementation orchestration run reports:
   `verdict: pass`, `child_authority_preserved: yes`,
   `required_child_count: 6`, `terminal_child_count: 6`,
   `child_receipt_summary_count: 24`,
   `parent_summary_not_child_evidence: true`, and
   `child_receipts_remain_child_owned: true`.
6. Confirm the parent implementation orchestration run does not grant archive,
   cleanup, Git mutation, delivery, publication, branch cleanup, deletion, or
   terminal-cleanliness authority.
7. Confirm both control and evidence checkpoints record each required child
   with `current_state: archived`, `final_verdict: completed`, and terminal,
   verification, and closeout gates set to true.
8. Reconcile `resources/child-packet-index.yml`,
   `architecture/packet-sequence.md`, and the checkpoint dependency gates.
9. Confirm every required child archive exists, has `proposal.yml#status:
   archived`, and carries passing child-owned review, pre-integration
   architecture review, implementation-run, implementation-conformance,
   post-implementation drift/churn, validation, closeout, and terminal-closeout
   receipts.
10. Inspect durable target families for active proposal-path backreferences,
    parent-summary-as-child-evidence leakage, generated-output authority drift,
    host-projection authority drift, cleanup-authority drift, and terminal
    cleanliness overclaims.
11. Resolve aggregate Proposal Program Delivery evidence. The delivery profile
    is not a delivery receipt. Locate a concrete
    `proposal-program-delivery-receipt-v1` receipt and its evidence index for
    `proposal-program-delivery-run-program-clean-delivery-postmortem-hardening-20260703t0824`
    or the current successor delivery run before accepting any `cleaned`,
    closeout-ready, terminal-clean, final-sync, or worktree-clean claim.
12. Verify Change closeout evidence separately from parent program evidence.
    Hosted landing, local main sync, branch cleanup, and terminal proof must
    cite Change closeout receipts and live-ref checks when claimed.
13. Verify cleanup disposition separately from detection evidence. Classifier
    output does not authorize deletion, and preserved residue must be named
    without being hidden by a clean-delivery claim.
14. Verify validator hardening with negative controls for dirty worktree,
    final sync false, open blockers, missing delivery receipt, stale receipt
    digest, missing evidence index, parent-summary substitution, and
    non-cleaned outcome.
15. Verify test hermeticity by proving worktree hygiene tests do not dirty
    tracked generated read models.
16. Produce stable findings with owner classification:
    `parent`, `child:<child-id>`, `child-group:<group-id>`, `delivery`,
    `change-closeout`, `cleanup`, `generated-output`, `worktree-hygiene`,
    `retained-evidence`, or `cross-packet`.
17. If findings require mutation, generate targeted correction prompts through
    the governed program correction route and stop before unrelated edits.

## Required Validators

Run the parent validators from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening --require-terminal-evidence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening --mode pre-integration-architecture-review --require-pass
```

Run proposal validators for each archived child packet:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child-archive-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <child-archive-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <child-archive-path> --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt <child-archive-path>/support/pre-integration-architecture-review.yml --package <child-archive-path> --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child-archive-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child-archive-path>
```

Run delivery, closeout, cleanup, and aggregate clean-delivery validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh --profile .octon/state/evidence/runs/skills/proposal-program-delivery/run-program-clean-delivery-postmortem-hardening-20260703T082428Z/delivery-profile.yml
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh
bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh --dry-run
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh
```

When a concrete delivery receipt and index are present, also run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh --receipt <delivery-receipt>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh --root <delivery-evidence-root> --index <delivery-evidence-index>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh --receipt <delivery-receipt>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt <change-receipt> --verify-live-refs
bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh --receipt <change-receipt> --require-live-remote
bash .octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh --root <delivery-evidence-root>
```

Run targeted test suites when the aggregate verdict depends on the corrected
failure modes:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-architectural-review-validators.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-review-gate.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-proposal-program-delivery-evidence-index.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-classify-proposal-worktree-hygiene.sh
git status --short -- .octon/generated/cognition/projections/materialized/runs
git diff --check
```

If a validator is unavailable or blocked, record the exact command, exit
status, retained stdout/stderr location when available, and why the missing
evidence blocks or limits the receipt verdict. Do not convert a blocked command
into a passing manual assertion.

## Conformance Receipt Requirements

Write
`support/program-implementation-orchestration-conformance-review.md` with at
least these top-level fields:

```text
verdict: pass|fail
unresolved_items_count: <integer>
child_receipt_summary_count: <integer>
child_authority_preserved: yes|no
```

Use `verdict: pass` and `child_authority_preserved: yes` only when all of the
following are true:

- Parent `proposal.yml#status` is `implemented`.
- Parent proposal review is accepted, implementation prompt authorization is
  present, and `validate-proposal-review-gate.sh` passes.
- Parent pre-integration architecture review passes with no unresolved items.
- Parent implementation orchestration run reports the six required children,
  six terminal children, 24 child receipt summaries, and
  `child_authority_preserved: yes`.
- Both control and evidence checkpoints record all six required children as
  archived, completed, and terminal/verification/closeout gate true.
- Each required child archive exists and carries passing child-owned review,
  strict architecture review, implementation-run, implementation-conformance,
  post-implementation drift/churn, validation, closeout, and terminal-closeout
  receipts.
- Child dependency gates match `resources/child-packet-index.yml` and
  `architecture/packet-sequence.md`.
- Parent promotion targets are covered by child-owned implementation evidence,
  retained validation evidence, or explicit no-op evidence; the parent does not
  claim to have implemented runtime behavior directly.
- Stale architecture review receipt recurrence is prevented by validator
  behavior and negative controls, not by hand-edited digest text.
- Delivery receipt completion behavior requires a concrete Proposal Program
  Delivery receipt and digest-bound evidence index before any clean-delivery
  claim.
- Change closeout reconciliation behavior can prove hosted landing, local main
  sync, branch cleanup, and terminal proof through Change receipts when those
  outcomes are claimed.
- Cleanup disposition behavior distinguishes detected residue, protected
  residue, preserved residue, deletion authorization, and terminal cleanliness.
- Aggregate clean-delivery validation rejects dirty worktree, final sync false,
  open blockers, missing delivery receipt, stale receipt evidence, missing
  evidence index, parent-summary substitution, and non-cleaned outcome.
- Worktree hygiene tests do not dirty tracked generated read models.
- Durable evidence outside proposal-local inputs supports aggregate program
  implementation and verification.
- Generated projections and read models remain derived-only and are not used as
  authority, permission, support, promotion, closeout, archive, cleanup,
  delivery, branch cleanup, deletion, or terminal proof.
- The parent receipt does not rewrite, edit, satisfy, or replace child
  manifests, subtype manifests, receipts, validators, promotion targets,
  archive metadata, rollback handles, cleanup dispositions, Change receipts,
  delivery receipts, or terminal outcomes.

A missing concrete delivery receipt may coexist with a passing implementation
conformance verdict only if the receipt explicitly limits the claim to parent
program implementation verification and records that `cleaned`, parent
closeout readiness, terminal clean, final sync, and worktree-clean claims are
blocked until Proposal Program Delivery provides the concrete receipt and
evidence index.

Include sections for blockers, checked evidence, child receipt summary,
promotion target coverage, validator coverage, delivery receipt coverage,
Change closeout coverage, generated output coverage, publication freshness,
cleanup and worktree-hygiene posture, rollback coverage, downstream reference
coverage, exclusions, and final route recommendation.

## Drift And Churn Receipt Requirements

Write
`support/program-post-implementation-orchestration-drift-churn-review.md` with
at least these top-level fields:

```text
verdict: pass|fail
unresolved_items_count: <integer>
child_receipt_summary_count: <integer>
child_authority_preserved: yes|no
```

Use `verdict: pass` and `child_authority_preserved: yes` only when all of the
following are true:

- The conformance receipt exists and reports `verdict: pass`,
  `unresolved_items_count: 0`, and `child_authority_preserved: yes`.
- No active child packet directories remain for children that the checkpoint
  reports as archived.
- Archived child packets preserve implemented archive metadata and child-owned
  receipts without moving child authority into the parent packet.
- Durable framework, instance, state, and generated targets do not acquire new
  active proposal-path dependencies except retained evidence, historical
  provenance, or proposal-local lineage references.
- Generated proposal registry and generated effective projections remain
  derived-only; if they are refreshed, retained publication/freshness evidence
  is cited.
- Runtime lifecycle, workflow, closeout, product-contract, validator, test,
  command, and skill surfaces do not outstate the child promotion scopes.
- Proposal Program Delivery receipts and indexes remain retained evidence and
  do not replace child-owned receipts or Change receipts.
- Change closeout and hosted no-PR validation remain the owning proof for
  landing, sync, branch cleanup, and terminal state claims.
- Cleanup classification remains routing evidence only and does not become
  deletion authorization.
- Churn is limited to lifecycle support, retained evidence, generated
  projections with publication receipts, and declared child promotion targets.
- The route does not mutate runtime behavior, connector permissions, generated
  projections, state/control truth, Git refs, archive state, cleanup state,
  host state, or child packet state while claiming to perform verification
  only.

Include sections for blockers, checked evidence, active proposal-path
backreference scan, generated projection freshness, manifest and schema
validity, host projection boundary review, target-family boundary review,
cleanup and worktree-hygiene posture, churn review, validators run, exclusions,
and final closeout recommendation.

## Stable Finding Identity

Use stable finding ids in the `RCDPH-PVFY` namespace:

- `RCDPH-PVFY-001`, `RCDPH-PVFY-002`, and so on.
- Reuse the same id across reruns for the same root cause.
- Do not renumber findings after one is resolved.
- Group issues only when they share one correction and one acceptance test.

Each finding must include:

- id
- severity: `P0`, `P1`, `P2`, or `P3`
- status: `open`, `resolved`, `blocked`, or `accepted-external`
- owner classification
- affected paths
- evidence
- expected behavior
- correction scope
- acceptance criteria
- deferral eligibility: `eligible` or `not-eligible`

No finding is deferrable if it concerns authority boundaries, child authority
preservation, parent-summary-as-child-evidence leakage, required validator
failure, missing delivery receipt for a `cleaned` claim, missing evidence
index, stale review evidence, Change closeout terminal proof, cleanup deletion
authority, generated-output authority drift, or non-hermetic validation tests.

## Evidence Requirements

For every command or deterministic check, record:

- exact command
- exit code
- relevant output summary
- affected paths
- retained evidence location
- whether the evidence is packet-local lifecycle evidence or retained Octon
  evidence

Retained evidence belongs under existing Octon evidence roots such as:

- `.octon/state/evidence/validation/**`
- `.octon/state/evidence/runs/skills/**`
- `.octon/state/evidence/runs/workflows/**`

Do not store retained evidence in `generated/**`. Proposal registry
projections, generated effective outputs, GitHub surfaces, CI state, chat
context, tool availability, and model memory are not Octon authority.

## Pass And Failure Semantics

If any required command fails, any required receipt is missing or stale, any
child archive is missing, any child-owned receipt is failing, any active child
directory remains incorrectly live, any generated output is stale and cannot be
refreshed through its canonical route, any cleanup/worktree blocker prevents a
parent readiness claim, or the parent would need to own child truth to pass,
write failing receipts with concrete blockers. Do not omit the receipts because
verification failed.

If both aggregate receipts pass and no concrete delivery receipt is required
for the next claim, the final route recommendation should be:

`Proceed to generate-program-closeout-prompt.`

If both aggregate receipts pass but a `cleaned`, terminal-clean, final-sync, or
closeout-ready claim lacks concrete Proposal Program Delivery receipt evidence,
the final route recommendation should be:

`Run proposal-program-delivery or the owning delivery closeout route before program closeout.`

If either aggregate receipt fails, the final route recommendation should name
the next owning route, usually `generate-program-correction-prompt`,
`proposal-program-delivery`, `cleanup-lifecycle-residue`, `closeout-worktree`,
`closeout-change`, or a child-owned packet route.

## Authority Boundary

The parent program may coordinate sequence, dependency gates, aggregate
verification, evidence references, and closeout refusal criteria. It may not
create, revise, satisfy, or replace child-owned authority, child receipts,
child validation verdicts, child promotion targets, child archive metadata,
delivery receipts, Change receipts, cleanup authorization, rollback handles,
terminal proof, or child terminal outcomes.

Proposal-local files and generated prompts remain temporary non-authority
support. Durable authority, control truth, retained evidence, and generated
projection publication must remain in their declared repository classes.

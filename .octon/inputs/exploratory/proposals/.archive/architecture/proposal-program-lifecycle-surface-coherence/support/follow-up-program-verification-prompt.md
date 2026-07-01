prompt_id: proposal-program-lifecycle-surface-coherence-follow-up-program-verification-20260701T142147Z
generated_by: octon-proposal-lifecycle-generate-program-verification-prompt
target_program: .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence
route: run-program-verification-and-correction-loop
lifecycle_id: proposal-program
program_run_id: lifecycle-proposal-program-1782852942821-fba365cc
artifact_class: operational-aid
authority: non-authoritative
generated_at: 2026-07-01T14:21:47Z

# Follow-Up Program Verification Prompt

## Purpose

Run aggregate parent program verification for
`.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence`
after the parent implementation orchestration run.

This prompt is an operational handoff. It is not control truth, parent
closeout evidence, child evidence, archive authorization, cleanup
authorization, landing authorization, publication authorization, or a
`cleaned` claim.

The verification loop must write both parent-local aggregate receipts:

- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`

Those receipts may summarize child state by reference, but they must not
satisfy child receipts, child validation verdicts, child promotion targets,
child archive metadata, rollback handles, cleanup dispositions, or child
terminal outcomes.

## Prompt Generation Basis

The prompt bundle was consumed through a compact capsule with fresh alignment
evidence:

- prompt set: `octon-proposal-lifecycle-generate-program-verification-prompt`
- bundle digest:
  `sha256:581741a858b04d2f85183470a0f83a6915cb0729a4fd91661da241835f53281c`
- alignment receipt:
  `.octon/state/evidence/validation/extensions/prompt-alignment/2026-07-01T13-26-24Z-octon-proposal-lifecycle-octon-proposal-lifecycle-generate-program-verification-prompt.yml`
- route run: `lifecycle-proposal-program-1782852942821-fba365cc`

Generation-time digest checks for the required prompt assets matched the compact
capsule.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: verify one implemented parent program from retained parent
  and child evidence while preserving child-owned authority boundaries
- transitional exception: not authorized

## Boundaries

- Preserve parent `proposal.yml#status: implemented` unless a separate
  authorized lifecycle route changes it.
- Do not promote, close out, archive, clean, land, publish, delete, or claim
  `cleaned` for the parent.
- Do not use parent evidence to satisfy child-owned evidence.
- Do not recreate child evidence casually; inspect existing child receipts,
  child archive metadata, and retained workflow evidence.
- Do not mutate child manifests, child receipts, child archive metadata, child
  validation verdicts, child promotion targets, cleanup dispositions, or
  terminal outcomes from the parent route.
- Do not hand-edit generated outputs. Refresh generated outputs only through
  canonical generators if a validator proves they are stale and the route
  allows refresh.
- Treat generated proposal registries, generated effective projections, host
  projections, prompt artifacts, chat history, and local host state as
  non-authoritative.

## Mandatory Reads

Read the current parent packet:

- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/architecture-proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/navigation/source-of-truth-map.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/navigation/artifact-catalog.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/resources/child-packet-index.yml`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/architecture/child-packet-contract.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/architecture/packet-sequence.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/architecture/program-closeout-plan.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/architecture/target-architecture.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/architecture/implementation-plan.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/architecture/acceptance-criteria.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/validation-plan.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/support/implementation-grade-completeness-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/support/proposal-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/support/pre-integration-architecture-review.yml`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/support/program-implementation-orchestration-prompt.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/support/program-implementation-orchestration-run.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence/support/lifecycle-residue-cleanup.md`

Read retained parent workflow evidence:

- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1782852942821-fba365cc/parent/program-implementation-orchestration-run.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1782852942821-fba365cc/program-lifecycle-checkpoint.yml`
- `.octon/state/control/execution/runs/lifecycle-proposal-program-1782852942821-fba365cc/program-lifecycle-checkpoint.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1782852942821-fba365cc/aggregate-terminal-blockers.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1782852942821-fba365cc/parent/delegated-promotion-parent-promote-proposal.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1782852942821-fba365cc/publication-freshness-preflight/summary.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1782852942821-fba365cc/program-events.ndjson`

Read each archived child packet named by the checkpoint and inspect these
child-owned support receipts:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`
- `support/proposal-closeout.md`
- `support/proposal-terminal-closeout.yml`

Required child archive paths:

- `.octon/inputs/exploratory/proposals/.archive/architecture/proposal-delivery-input-contract-alignment`
- `.octon/inputs/exploratory/proposals/.archive/architecture/proposal-program-delivery-operator-alias`
- `.octon/inputs/exploratory/proposals/.archive/architecture/proposal-program-delivery-host-projections`
- `.octon/inputs/exploratory/proposals/.archive/architecture/proposal-program-review-loop-documentation`
- `.octon/inputs/exploratory/proposals/.archive/architecture/proposal-lifecycle-surface-validation-hardening`

## Verification Work

1. Confirm current worktree state and classify changes as child durable targets,
   child proposal-local receipts, parent-local coordination evidence,
   generated outputs, retained evidence, cleanup residue, or unrelated residue.
2. Confirm parent `proposal.yml#status` is `implemented`.
3. Confirm the parent proposal review gate is current. If
   `reviewed_packet_digest` is stale after lifecycle support artifacts changed,
   record that as a blocker and do not hand-edit the review receipt from this
   route.
4. Confirm the parent implementation orchestration run reports:
   `verdict: pass`, `child_authority_preserved: yes`,
   `required_child_count: 5`, `terminal_child_count: 5`,
   `child_receipt_summary_count: 20`,
   `parent_summary_not_child_evidence: true`, and
   `child_receipts_remain_child_owned: true`.
5. Confirm the retained parent run evidence points to the same parent receipt
   digest and records `status: pass`, `child_authority_preserved: yes`, and
   `child_receipt_summary_count: 20`.
6. Confirm both control and evidence checkpoints record each required child
   with `current_state: archived`, `final_verdict: completed`, and terminal,
   verification, and closeout gates set to true.
7. Confirm aggregate terminal blockers report
   `blocked_required_child_count: 0`.
8. Reconcile `resources/child-packet-index.yml` and
   `architecture/packet-sequence.md` against the archived child outcomes,
   including dependency order and terminal dependency gates.
9. Confirm every required child archive exists, has `proposal.yml#status:
   archived`, and carries passing child-owned implementation, conformance,
   drift/churn, validation, closeout, and terminal-closeout receipts.
10. Inspect durable target families for active proposal-path backreferences,
   parent-summary-as-child-evidence leakage, generated-output authority drift,
   host-projection authority drift, and product catalog overclaims.
11. Verify publication freshness only through canonical retained publication
    evidence. Generated outputs remain derived-only.
12. Inspect `support/lifecycle-residue-cleanup.md` and current hygiene evidence.
    If cleanup, archive, closeout, or worktree hygiene remains blocked, record
    that as a blocker or residual risk in the aggregate receipts instead of
    claiming parent closeout readiness.
13. Produce stable findings with owner classification:
    `parent`, `child:<child-id>`, `child-group:<group-id>`, `cross-packet`,
    `generated-output`, `worktree-hygiene`, or `retained-evidence`.
14. If findings require mutation, generate targeted correction prompts through
    the governed program correction route and stop before unrelated edits.

## Required Validators

Run the parent validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence
```

Run proposal validators for each archived child packet:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child-archive-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <child-archive-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child-archive-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child-archive-path>
```

Run generated/publication freshness checks when the aggregate verdict depends
on generated outputs or host projections:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh
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
- Parent proposal review is accepted and implementation prompt authorization is
  present, with a current `reviewed_packet_digest` according to
  `validate-proposal-review-gate.sh`.
- Parent pre-integration architecture review passes with no unresolved items.
- Parent implementation orchestration run reports the five required children,
  five terminal children, 20 child receipt summaries, and
  `child_authority_preserved: yes`.
- Retained parent run evidence reports `status: pass` and the same parent
  receipt digest.
- Both checkpoints record all five required children archived, completed, and
  terminal/verification/closeout gate true.
- Aggregate terminal blockers report `blocked_required_child_count: 0`.
- Each required child archive exists and carries passing child-owned
  implementation-run, implementation-conformance, post-implementation
  drift/churn, validation, closeout, and terminal-closeout receipts.
- Child dependency gates match `resources/child-packet-index.yml` and
  `architecture/packet-sequence.md`.
- Parent promotion targets are covered by child-owned implementation evidence
  or explicit no-op evidence; the parent does not claim to have implemented
  runtime behavior directly.
- Durable evidence outside proposal-local inputs supports aggregate program
  completion and promotion.
- Generated projections and read models remain derived-only and are not used as
  authority, permission, support, promotion, closeout, archive, cleanup, or
  terminal proof.
- The parent receipt does not rewrite, edit, satisfy, or replace child
  manifests, subtype manifests, receipts, validators, promotion targets,
  archive metadata, rollback handles, cleanup dispositions, or terminal
  outcomes.

Include sections for blockers, checked evidence, child receipt summary,
promotion target coverage, validator coverage, generated output coverage,
publication freshness, cleanup and worktree-hygiene posture, rollback coverage,
downstream reference coverage, exclusions, and final route recommendation.

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
- Runtime capability, command, skill, workflow, validator, host projection, and
  product catalog surfaces do not outstate the accepted child promotion scopes.
- Program delivery alias behavior remains a delegating convenience surface
  without independent lifecycle, delivery, closeout, archive, cleanup, or
  terminal proof authority.
- Program review/revision documentation remains parent-local coordination and
  does not become a child authority substitute.
- Churn is limited to lifecycle support, retained evidence, generated
  projections with publication receipts, and declared child promotion targets.
- The route does not mutate runtime behavior, connector permissions, generated
  projections, state/control truth, Git refs, archive state, cleanup state, or
  host state while claiming to perform verification only.

Include sections for blockers, checked evidence, active proposal-path
backreference scan, generated projection freshness, manifest and schema
validity, host projection boundary review, target-family boundary review,
cleanup and worktree-hygiene posture, churn review, validators run, exclusions,
and final closeout recommendation.

## Pass And Failure Semantics

If any required command fails, any required receipt is missing or stale, any
child archive is missing, any child-owned receipt is failing, any active child
directory remains incorrectly live, any generated output is stale and cannot be
refreshed through its canonical route, any cleanup/worktree blocker prevents a
parent readiness claim, or the parent would need to own child truth to pass,
write failing receipts with concrete blockers. Do not omit the receipts because
verification failed.

If both aggregate receipts pass, the final route recommendation should be:

`Proceed to generate-program-closeout-prompt.`

If either receipt fails, the final route recommendation should name the next
owning route, usually `generate-program-correction-prompt`,
`cleanup-lifecycle-residue`, `closeout-worktree`, or a child-owned packet
route.

# Custom Program Closeout Prompt

```yaml
verdict: pass
generated_at: "2026-07-03T09:56:45Z"
generator_route_id: "generate-program-closeout-prompt"
prompt_set_id: "octon-proposal-lifecycle-generate-program-closeout-prompt"
prompt_bundle_sha256: "sha256:5153ba674565ef7297faa4db2753e7a22c07eeef6c4d9c53dbc7ca1a18ffb1e1"
program_run_id: "lifecycle-proposal-program-postmortem-hardening-20260703T093801Z"
program_packet_path: ".octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening"
proposal_id: "run-program-clean-delivery-postmortem-hardening"
required_child_count: 6
terminal_child_count: 6
child_receipt_summary_count: 24
child_authority_preserved: yes
artifact_class: operational-aid
authority: non-authoritative
```

This prompt is a packet-local operational aid for closing out the parent
program. It is not authority, does not approve archival, does not replace a run
contract, and does not satisfy retained validation or evidence obligations.

## Goal

Close out `run-program-clean-delivery-postmortem-hardening` only if the parent
can write `support/proposal-closeout.md` from current repository state,
retained workflow evidence, deterministic validation, target-owned delivery
evidence, returned worktree-handoff evidence, and child-owned receipts without
moving child authority into the parent packet.

The closeout route must either:

- record `support/proposal-closeout.md` with `verdict: pass`,
  `archive_authorized: yes`, and `child_authority_preserved: yes` only when all
  required gates pass and the parent is ready for a separate `archive-proposal`
  route; or
- record a blocked or deferred closeout with concrete blockers, missing
  evidence, next route condition, and `archive_authorized: no`.

Do not archive the parent from this closeout route. Do not mutate child packet
state, child archive metadata, child closeout receipts, child promotion
targets, child validation verdicts, delivery receipts, Change receipts,
cleanup receipts, Git refs, generated outputs, or host state from the parent
closeout route.

## Prompt Generation Basis

The prompt bundle was consumed through a compact capsule with fresh alignment
evidence:

- prompt set: `octon-proposal-lifecycle-generate-program-closeout-prompt`
- bundle digest:
  `sha256:5153ba674565ef7297faa4db2753e7a22c07eeef6c4d9c53dbc7ca1a18ffb1e1`
- alignment receipt:
  `.octon/state/evidence/validation/extensions/prompt-alignment/2026-07-03T06-21-11Z-octon-proposal-lifecycle-octon-proposal-lifecycle-generate-program-closeout-prompt.yml`
- route run:
  `lifecycle-proposal-program-postmortem-hardening-20260703T093801Z`

Generation-time digest checks for the required repo anchors and prompt assets
matched the compact capsule. Full prompt expansion was not active.

## Mandatory Inputs

Read these parent packet files before asserting closeout status:

- `proposal.yml`
- `architecture-proposal.yml`
- `README.md`
- `navigation/source-of-truth-map.md`
- `navigation/artifact-catalog.md`
- `resources/child-packet-index.yml`
- `resources/child-packet-index.md`
- `architecture/child-packet-contract.md`
- `architecture/packet-sequence.md`
- `architecture/program-closeout-plan.md`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`
- `validation-plan.md`
- `support/proposal-review.md`
- `support/pre-integration-architecture-review.yml`
- `support/implementation-grade-completeness-review.md`
- `support/program-implementation-orchestration-prompt.md`
- `support/program-implementation-orchestration-run.md`
- `support/follow-up-program-verification-prompt.md`
- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`
- `support/lifecycle-residue-cleanup.md`

Read these retained parent workflow and control evidence files for current
factual state:

- `.octon/state/control/execution/runs/lifecycle-proposal-program-postmortem-hardening-20260703T093801Z/program-lifecycle-checkpoint.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-postmortem-hardening-20260703T093801Z/program-lifecycle-checkpoint.yml`
- `.octon/state/control/execution/runs/lifecycle-proposal-program-postmortem-hardening-20260703T093801Z/program-events.ndjson`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-postmortem-hardening-20260703T093801Z/program-events.ndjson`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-postmortem-hardening-20260703T093801Z/aggregate-terminal-blockers.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-postmortem-hardening-20260703T093801Z/worktree-baseline.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-postmortem-hardening-20260703T093801Z/lifecycle-interactions/parent-closeout-worktree-return.json`
- `.octon/state/evidence/validation/analysis/2026-07-03-closeout-worktree-run-program-clean-delivery-postmortem-hardening-parent-lifecycle-residue-handoff.yml`
- `.octon/state/evidence/runs/skills/proposal-program-delivery/run-program-clean-delivery-postmortem-hardening-20260703T082428Z/delivery-profile.yml`

Locate and read the concrete Proposal Program Delivery receipt and evidence
index for
`proposal-program-delivery-run-program-clean-delivery-postmortem-hardening-20260703t0824`
or a current successor delivery run before accepting any `cleaned`,
closeout-ready, terminal-clean, final-sync, hosted-landing, branch-cleanup, or
worktree-clean claim. The delivery profile alone is not a delivery receipt and
does not authorize parent closeout.

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

## Required Parent Gates

Parent closeout may pass only when all of these are true:

- `proposal.yml` has `status: implemented`.
- `support/program-implementation-orchestration-run.md` reports
  `verdict: pass`, `child_authority_preserved: yes`,
  `required_child_count: 6`, `terminal_child_count: 6`,
  `child_receipt_summary_count: 24`, `parent_summary_not_child_evidence:
  true`, and `child_receipts_remain_child_owned: true`.
- `support/program-implementation-orchestration-run.md` grants no archive,
  cleanup, Git mutation, delivery, publication, branch cleanup, deletion, or
  terminal-cleanliness authority.
- `support/program-implementation-orchestration-conformance-review.md`
  reports `verdict: pass`, `unresolved_items_count: 0`,
  `child_receipt_summary_count: 24`, and `child_authority_preserved: yes`.
- `support/program-post-implementation-orchestration-drift-churn-review.md`
  reports `verdict: pass`, `unresolved_items_count: 0`,
  `child_receipt_summary_count: 24`, and `child_authority_preserved: yes`.
- The lifecycle checkpoint records every required child with
  `current_state: archived`, `final_verdict: completed`, and terminal,
  verification, and closeout gates true.
- `aggregate-terminal-blockers.yml` reports `blocked_required_child_count: 0`.
- Every child archive path exists and retains passing child-owned review,
  pre-integration architecture review, implementation run, implementation
  conformance, post-implementation drift/churn, validation, closeout, and
  terminal-closeout receipts.
- A concrete Proposal Program Delivery receipt and evidence index validate for
  the current delivery run or its successor. A profile-only delivery root is a
  blocker for `verdict: pass` and `archive_authorized: yes`.
- Change closeout evidence separately proves any hosted landing, local main
  sync, source branch cleanup, terminal proof, or final sync claim that appears
  in the closeout receipt. Static validators alone are not a target-specific
  Change closeout receipt.
- Cleanup disposition evidence separately proves any cleanup or deletion claim.
  Detection, classification, or dry-run output does not authorize deletion.
- The closeout route validates
  `parent-closeout-worktree-return.json` and the cited
  `closeout-worktree-report-v1` against the current lifecycle residue
  fingerprint before treating parent lifecycle residue as preserved and
  excluded from closeout blocking. The handoff permits no cleaned claim, no
  Git mutation, no deletion, and no child-owned evidence replacement.
- Parent aggregate evidence summarizes child outcomes only. It does not
  satisfy child receipts, child promotion targets, child validation verdicts,
  child archive metadata, child rollback handles, child delivery receipts, or
  child terminal outcomes.
- Generated projections, generated registries, read models, dashboards, host
  state, chat, tool availability, and agent output remain non-authority and
  derived-only.

## Required Validation

Run the parent validation floor before writing a passing closeout receipt:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening --require-terminal-evidence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening --mode pre-integration-architecture-review --require-pass
git diff --check
```

Run proposal validators for each archived child packet:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child-archive-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <child-archive-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <child-archive-path> --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt <child-archive-path>/support/pre-integration-architecture-review.yml --package <child-archive-path> --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child-archive-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child-archive-path>
```

Run delivery, closeout, cleanup, and aggregate clean-delivery validators:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh --profile .octon/state/evidence/runs/skills/proposal-program-delivery/run-program-clean-delivery-postmortem-hardening-20260703T082428Z/delivery-profile.yml
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh --receipt <delivery-receipt>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh --root <delivery-evidence-root> --index <delivery-evidence-index>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh --receipt <delivery-receipt>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt <change-receipt> --verify-live-refs
bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh --receipt <change-receipt> --require-live-remote
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh --report .octon/state/evidence/validation/analysis/2026-07-03-closeout-worktree-run-program-clean-delivery-postmortem-hardening-parent-lifecycle-residue-handoff.yml
bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh --active-run-id lifecycle-proposal-program-postmortem-hardening-20260703T093801Z --summary-only
bash .octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh --root <delivery-evidence-root>
```

If a validator is unavailable, times out, or fails, record the exact command,
exit status, retained stdout/stderr location when available, and why the
missing evidence blocks or limits the receipt verdict. Do not convert a
blocked command into a passing manual assertion.

## Hard Stops

Refuse `verdict: pass`, `archive_authorized: yes`, or archive-ready language
when any of these are true:

- Either parent aggregate receipt is missing, failing, unresolved, stale, or
  does not preserve child authority.
- Any required child has no terminal archived outcome.
- Any child-owned implementation, conformance, drift/churn, validation,
  closeout, terminal-closeout, archive, promotion, rollback, or delivery
  evidence is missing, stale, failing, or being replaced by parent summary
  text.
- The parent would need to edit child packets or own child truth to pass.
- No concrete Proposal Program Delivery receipt and evidence index can be
  located and validated for the delivery run or its successor.
- No target-specific Change receipt can prove hosted landing, local main sync,
  source branch cleanup, final sync, or terminal proof while those states are
  being claimed.
- Parent lifecycle residue cannot be reconciled with a current
  closeout-worktree return or the current residue fingerprint differs from the
  preserved handoff fingerprint.
- Cleanup detection or classification is being treated as deletion authority.
- Parent closeout depends on proposal-local inputs, generated projections,
  host state, dashboards, chat, tool availability, or agent output as
  authority.
- Active proposal paths, durable framework or instance surfaces, state/control
  truth, or generated effective surfaces acquire new raw proposal-path
  dependencies as part of closeout.
- Git, PR, CI, review, merge, branch cleanup, local-main sync, final-sync, or
  explicit stage-only route requirements remain unresolved for the selected
  Change closeout route.

## Closeout Receipt Requirements

Write or refresh `support/proposal-closeout.md`. Minimum successful shape:

```markdown
# Proposal Program Closeout Receipt

verdict: pass
closed_at: <UTC timestamp>
proposal_id: run-program-clean-delivery-postmortem-hardening
archive_authorized: yes
archive_disposition: implemented
child_authority_preserved: yes
program_run_id: lifecycle-proposal-program-postmortem-hardening-20260703T093801Z

## Route

selected_git_route: <direct-main|branch-no-pr|branch-pr|stage-only-escalate>
lifecycle_outcome: <route-specific outcome>
cleanup_summary: <summary of validated cleanup/worktree handoff without deletion overclaim>
next_route_condition: archive-proposal may run only after this receipt is retained and route gates remain satisfied

## Evidence

parent_aggregate_evidence:
  - .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/support/program-implementation-orchestration-run.md
  - .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/support/program-implementation-orchestration-conformance-review.md
  - .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening/support/program-post-implementation-orchestration-drift-churn-review.md
  - .octon/state/control/execution/runs/lifecycle-proposal-program-postmortem-hardening-20260703T093801Z/program-lifecycle-checkpoint.yml
  - .octon/state/evidence/runs/workflows/lifecycle-proposal-program-postmortem-hardening-20260703T093801Z/program-lifecycle-checkpoint.yml
  - .octon/state/evidence/runs/workflows/lifecycle-proposal-program-postmortem-hardening-20260703T093801Z/aggregate-terminal-blockers.yml

delivery_evidence:
  - <concrete proposal-program-delivery-receipt-v1 path>
  - <concrete delivery evidence index path>

change_closeout_evidence:
  - <concrete Change receipt path or explicit not-claimed disposition>

worktree_handoff_evidence:
  - .octon/state/evidence/runs/workflows/lifecycle-proposal-program-postmortem-hardening-20260703T093801Z/lifecycle-interactions/parent-closeout-worktree-return.json
  - .octon/state/evidence/validation/analysis/2026-07-03-closeout-worktree-run-program-clean-delivery-postmortem-hardening-parent-lifecycle-residue-handoff.yml

child_receipt_summary:
  required_child_count: 6
  terminal_child_count: 6
  archived_child_count: 6
  blocked_required_child_count: 0
  child_receipt_summary_count: 24
  child_receipts_remain_child_owned: yes

## Validation

Record exact commands, exit status, and retained logs or output summaries.

## Hygiene

Record intended parent closeout changes, unrelated existing worktree changes,
generated outputs retained, evidence retained, cleanup performed or deferred,
and rollback handle.

## Authority Boundary

Parent closeout evidence summarizes child outcomes only. It does not satisfy,
replace, edit, authorize, or archive child manifests, subtype manifests, child
receipts, child validation verdicts, child promotion targets, child acceptance
criteria, child archive metadata, child rollback handles, child delivery
evidence, or child terminal outcomes.
```

Use `archive_authorized: no` for blocked, deferred, stage-only, profile-only
delivery, unresolved Change closeout, unresolved worktree-handoff, unresolved
cleanup, or unresolved terminal-proof outcomes.

## Final Answer Contract

Report only the actual closeout state:

- parent closeout receipt path and verdict;
- selected route and lifecycle outcome;
- validation commands that passed, failed, or were blocked;
- whether child authority remains preserved;
- concrete delivery receipt and evidence-index refs, or the blocker if absent;
- Change closeout receipt refs and live-ref checks when claimed;
- worktree-handoff refs and residue fingerprint disposition;
- evidence roots retained outside `inputs/**`;
- Git/PR/CI/review/merge/branch cleanup/sync state when applicable;
- remaining blockers or `none`.

Do not claim the parent is archived. A separate archive route must perform
parent archive mutation after successful closeout authorization.

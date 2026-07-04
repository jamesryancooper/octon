# Custom Program Closeout Prompt

```yaml
verdict: pass
generated_at: "2026-07-04T03:38:20Z"
generator_route_id: "generate-program-closeout-prompt"
prompt_set_id: "octon-proposal-lifecycle-generate-program-closeout-prompt"
prompt_bundle_sha256: "sha256:5153ba674565ef7297faa4db2753e7a22c07eeef6c4d9c53dbc7ca1a18ffb1e1"
program_run_id: "lifecycle-proposal-program-1783112176123-f118c03e"
program_packet_path: ".octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening"
proposal_id: "run-program-clean-delivery-autonomy-hardening"
required_child_count: 7
terminal_child_count: 7
child_receipt_summary_count: 28
child_authority_preserved: yes
artifact_class: operational-aid
authority: non-authoritative
```

This prompt is a packet-local operational aid for closing out the parent
program. It is not authority, does not approve archival, does not replace a run
contract, and does not satisfy retained validation or evidence obligations.

## Goal

Close out `run-program-clean-delivery-autonomy-hardening` only if the parent
can write `support/proposal-closeout.md` from current repository state,
retained workflow evidence, deterministic validation, parent aggregate
receipts, parent worktree handoff evidence, and child-owned terminal receipts
without moving child authority into the parent packet.

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
  `.octon/state/evidence/validation/extensions/prompt-alignment/2026-07-04T03-18-55Z-octon-proposal-lifecycle-octon-proposal-lifecycle-generate-program-closeout-prompt.yml`
- route run:
  `lifecycle-proposal-program-1783112176123-f118c03e`

The required repo anchor digests matched the compact capsule. Full prompt
expansion was not active.

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

- `.octon/state/control/execution/runs/lifecycle-proposal-program-1783112176123-f118c03e/program-lifecycle-checkpoint.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1783112176123-f118c03e/program-lifecycle-checkpoint.yml`
- `.octon/state/control/execution/runs/lifecycle-proposal-program-1783112176123-f118c03e/program-events.ndjson`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1783112176123-f118c03e/program-events.ndjson`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1783112176123-f118c03e/aggregate-terminal-blockers.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1783112176123-f118c03e/worktree-baseline.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1783112176123-f118c03e/parent/worktree-hygiene-classification.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1783112176123-f118c03e/lifecycle-interactions/parent-closeout-worktree-return.json`
- `.octon/state/evidence/validation/analysis/lifecycle-proposal-program-1783112176123-f118c03e-parent-closeout-worktree-report.yml`

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

- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-compact-blocker-remediation`
- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-autonomous-hygiene-continuation`
- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-stale-branch-retirement`
- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-run-health-localization`
- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-no-dispatch-deduplication`
- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-retained-state-reporting`
- `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-authorized-hosted-landing`

## Required Parent Gates

Parent closeout may pass only when all of these are true:

- `proposal.yml` has `status: implemented`.
- `support/program-implementation-orchestration-run.md` reports
  `verdict: pass`, `child_authority_preserved: yes`,
  `required_child_count: 7`, `terminal_child_count: 7`,
  `child_receipt_summary_count: 28`, `parent_summary_not_child_evidence:
  true`, and `child_receipts_remain_child_owned: true`.
- `support/program-implementation-orchestration-run.md` grants no archive,
  cleanup, Git mutation, delivery, publication, branch cleanup, deletion, or
  terminal-cleanliness authority.
- `support/program-implementation-orchestration-conformance-review.md`
  reports `verdict: pass`, `unresolved_items_count: 0`,
  `child_receipt_summary_count: 28`, and `child_authority_preserved: yes`.
- `support/program-post-implementation-orchestration-drift-churn-review.md`
  reports `verdict: pass`, `unresolved_items_count: 0`,
  `child_receipt_summary_count: 28`, and `child_authority_preserved: yes`.
- The lifecycle checkpoint records every required child with
  `current_state: archived`, `final_verdict: completed`, and terminal,
  verification, and closeout gates true.
- `aggregate-terminal-blockers.yml` reports `blocked_required_child_count: 0`.
- Every child archive path exists and retains passing child-owned review,
  pre-integration architecture review, implementation run, implementation
  conformance, post-implementation drift/churn, validation, closeout, and
  terminal-closeout receipts.
- Parent lifecycle residue is reconciled by the current non-mutating
  `parent-closeout-worktree-return.json` and the cited
  `closeout-worktree-report-v1`, including the matching foreign fingerprint
  `sha256:56021a77cf783b1a26f72f3c02edd64ceb449d08840b43c624e8e166ff1eb93e`
  and residue fingerprint
  `sha256:1f06a41143a36057e3566dcd0fd7ac6c81f1a6bc17ae3b919ec3850f498ac7b3`.
- The worktree handoff is used only as preserve/exclude evidence for parent
  closeout blocking. It does not authorize deletion, Git mutation, cleanup,
  archive relocation, branch cleanup, hosted actions, publication, staging,
  commit, push, or a `cleaned` claim.
- Any claimed Proposal Program Delivery, Change closeout, hosted landing,
  local main sync, branch cleanup, final sync, terminal proof, or cleaned
  status has concrete target-specific receipt evidence and passes its
  validator. If no such claim is made, record `not-claimed` explicitly.
- Cleanup disposition evidence separately proves any cleanup or deletion claim.
  Detection, classification, dry-run output, or parent summary text does not
  authorize deletion.
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
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening --mode pre-integration-architecture-review --require-pass
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

Run closeout, cleanup, and clean-delivery validators for any state being
claimed by the parent receipt:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh --report .octon/state/evidence/validation/analysis/lifecycle-proposal-program-1783112176123-f118c03e-parent-closeout-worktree-report.yml
bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh --active-run-id lifecycle-proposal-program-1783112176123-f118c03e --summary-only
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh --receipt <delivery-or-clean-delivery-receipt>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh --receipt <delivery-receipt>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh --root <delivery-evidence-root> --index <delivery-evidence-index>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt <change-receipt> --verify-live-refs
bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh --receipt <change-receipt> --require-live-remote
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
- Parent lifecycle residue cannot be reconciled with the current
  `parent-closeout-worktree-return.json` and current closeout-worktree report,
  or the current residue fingerprint differs from the preserved handoff
  fingerprint.
- Cleanup detection, classification, dry-run output, or parent summary text is
  being treated as deletion authority.
- The receipt claims Proposal Program Delivery, Change closeout, hosted
  landing, local main sync, source branch cleanup, final sync, terminal proof,
  or cleaned status without target-specific retained receipts and passing
  validators.
- Parent closeout depends on proposal-local inputs, generated projections,
  host state, dashboards, chat, tool availability, or agent output as
  authority.
- Active proposal paths, durable framework or instance surfaces, state/control
  truth, or generated effective surfaces acquire new raw proposal-path
  dependencies as part of closeout.
- Git, PR, CI, review, merge, branch cleanup, local-main sync, final-sync, or
  explicit stage-only route requirements remain unresolved for the selected
  Change closeout route when those outcomes are claimed.

## Closeout Receipt Requirements

Write or refresh `support/proposal-closeout.md`. Minimum successful shape:

```markdown
# Proposal Program Closeout Receipt

verdict: pass
closed_at: <UTC timestamp>
proposal_id: run-program-clean-delivery-autonomy-hardening
archive_authorized: yes
archive_disposition: implemented
child_authority_preserved: yes
program_run_id: lifecycle-proposal-program-1783112176123-f118c03e

## Route

selected_git_route: <direct-main|branch-no-pr|branch-pr|stage-only-escalate|not-claimed>
lifecycle_outcome: <route-specific outcome>
cleanup_summary: <validated cleanup/worktree handoff summary without deletion or cleaned overclaim>
next_route_condition: archive-proposal may run only after this receipt is retained and route gates remain satisfied

## Evidence

parent_aggregate_evidence:
  - .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/support/program-implementation-orchestration-run.md
  - .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/support/program-implementation-orchestration-conformance-review.md
  - .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/support/program-post-implementation-orchestration-drift-churn-review.md
  - .octon/state/control/execution/runs/lifecycle-proposal-program-1783112176123-f118c03e/program-lifecycle-checkpoint.yml
  - .octon/state/evidence/runs/workflows/lifecycle-proposal-program-1783112176123-f118c03e/program-lifecycle-checkpoint.yml
  - .octon/state/evidence/runs/workflows/lifecycle-proposal-program-1783112176123-f118c03e/aggregate-terminal-blockers.yml

worktree_handoff_evidence:
  - .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/support/lifecycle-residue-cleanup.md
  - .octon/state/evidence/runs/workflows/lifecycle-proposal-program-1783112176123-f118c03e/lifecycle-interactions/parent-closeout-worktree-return.json
  - .octon/state/evidence/validation/analysis/lifecycle-proposal-program-1783112176123-f118c03e-parent-closeout-worktree-report.yml

delivery_evidence:
  - <concrete proposal-program-delivery-receipt-v1 path, or not-claimed>
  - <concrete delivery evidence index path, or not-claimed>

change_closeout_evidence:
  - <concrete Change receipt path, or not-claimed>

child_receipt_summary:
  required_child_count: 7
  terminal_child_count: 7
  archived_child_count: 7
  blocked_required_child_count: 0
  child_receipt_summary_count: 28
  child_receipts_remain_child_owned: yes

## Validation

Record exact commands, exit status, and retained logs or output summaries.

## Hygiene

Record intended parent closeout changes, unrelated existing worktree changes,
generated outputs retained, evidence retained, cleanup performed or deferred,
and rollback handle. A preserved/excluded worktree handoff is not a cleaned
claim.

## Authority Boundary

Parent closeout evidence summarizes child outcomes only. It does not satisfy,
replace, edit, authorize, or archive child manifests, subtype manifests, child
receipts, child validation verdicts, child promotion targets, child acceptance
criteria, child archive metadata, child rollback handles, child delivery
evidence, or child terminal outcomes.
```

Use `archive_authorized: no` for blocked, deferred, stage-only, unresolved
child evidence, unresolved parent aggregate receipts, unresolved worktree
handoff, profile-only delivery, unresolved Change closeout, unresolved cleanup,
or unresolved terminal-proof outcomes.

## Final Answer Contract

Report only the actual closeout state:

- parent closeout receipt path and verdict;
- selected route and lifecycle outcome;
- validation commands that passed, failed, or were blocked;
- whether child authority remains preserved;
- concrete delivery receipt and evidence-index refs, or `not-claimed`;
- Change closeout receipt refs and live-ref checks when claimed;
- worktree-handoff refs and residue fingerprint disposition;
- evidence roots retained outside `inputs/**`;
- Git, PR, CI, review, merge, branch cleanup, sync, and cleaned state when
  applicable;
- remaining blockers or `none`.

Do not claim the parent is archived. A separate archive route must perform
parent archive mutation after successful closeout authorization.

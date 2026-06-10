# Custom Program Closeout Prompt

```yaml
verdict: pass
generated_at: "2026-06-10T14:46:07Z"
generator_route_id: "generate-program-closeout-prompt"
program_run_id: "lifecycle-proposal-program-1781073115145-fe49ec37"
program_packet_path: ".octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration"
proposal_id: "octon-wide-delegated-governance-migration"
child_receipt_summary_count: 36
child_promotion_evidence_count: 82
child_authority_preserved: yes
```

This prompt is a packet-local operational aid for closing out the parent
program. It is not authority, does not approve archival, does not replace a run
contract, and does not satisfy retained validation or evidence obligations.

## Goal

Close out `octon-wide-delegated-governance-migration` only if the parent can
write `support/proposal-closeout.md` from current repository state, retained
workflow evidence, deterministic validation, and child-owned receipts without
moving child authority into the parent packet.

The closeout route must either:

- record `support/proposal-closeout.md` with `verdict: pass`,
  `archive_authorized: yes`, and `child_authority_preserved: yes` only when all
  required gates pass and the parent is ready for a separate `archive-proposal`
  route; or
- record a blocked or deferred closeout with concrete blockers, missing
  evidence, next route condition, and `archive_authorized: no`.

Do not archive the parent from this closeout route. Do not mutate child packet
state, child archive metadata, child closeout receipts, child promotion targets,
or child validation verdicts from the parent closeout route.

## Mandatory Inputs

Read these parent packet files before asserting closeout status:

- `proposal.yml`
- `architecture-proposal.yml`
- `README.md`
- `navigation/source-of-truth-map.md`
- `navigation/artifact-catalog.md`
- `resources/child-packet-index.yml`
- `architecture/child-packet-contract.md`
- `architecture/packet-sequence.md`
- `architecture/program-closeout-plan.md`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`
- `validation-plan.md`
- `RISK-REGISTER.md`
- `support/proposal-review.md`
- `support/implementation-grade-completeness-review.md`
- `support/program-implementation-orchestration-prompt.md`
- `support/program-implementation-orchestration-run.md`
- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`

Read these retained evidence and control files for current factual state:

- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1781073115145-fe49ec37/parent/aggregate-child-outcomes-20260610T133510Z.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1781073115145-fe49ec37/aggregate-terminal-blockers.yml`
- `.octon/state/control/execution/runs/lifecycle-proposal-program-1781073115145-fe49ec37/program-lifecycle-checkpoint.yml`
- `.octon/state/control/execution/runs/lifecycle-proposal-program-1781073115145-fe49ec37/program-events.ndjson`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1781073115145-fe49ec37/parent/delegated-promotion-parent-promote-proposal.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1781073115145-fe49ec37/parent/program-verification-correction-summary-20260610T142834Z.yml`

Read every archived child path listed by the aggregate child outcome evidence
and inspect these child-owned receipts in each child packet:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/proposal-closeout.md`

## Required Parent Gates

Parent closeout may pass only when all of these are true:

- `proposal.yml` has `status: implemented`.
- `support/program-implementation-orchestration-run.md` reports
  `verdict: pass`, `child_authority_preserved: yes`,
  `required_child_count: 9`, `terminal_child_count: 9`,
  `archived_child_count: 9`, `blocked_required_child_count: 0`, and
  `child_receipt_summary_count: 36`.
- `support/program-implementation-orchestration-conformance-review.md` reports
  `verdict: pass`, `unresolved_items_count: 0`,
  `child_receipt_summary_count: 36`, and
  `child_authority_preserved: yes`.
- `support/program-post-implementation-orchestration-drift-churn-review.md`
  reports `verdict: pass`, `unresolved_items_count: 0`,
  `child_receipt_summary_count: 36`, and
  `child_authority_preserved: yes`.
- Aggregate child outcome evidence reports `verdict: pass`,
  `child_authority_preserved: yes`, nine required children, nine terminal
  children, nine archived children, zero blocked required children, 36 child
  receipt summaries, and 82 child promotion evidence references.
- Aggregate terminal blocker evidence reports
  `blocked_required_child_count: 0`.
- The lifecycle checkpoint records every required child with
  `current_state: archived`, `final_verdict: completed`, and terminal,
  verification, and closeout gates true.
- Every child archive path exists and retains passing child-owned
  implementation run, implementation conformance, post-implementation
  drift/churn, and closeout receipts.
- Parent aggregate evidence summarizes child outcomes only. It does not satisfy
  child receipts, child promotion targets, child validation verdicts, child
  archive metadata, child rollback handles, or child terminal outcomes.
- Generated projections, generated registries, read models, dashboards, host
  state, chat, tool availability, and agent output remain non-authority and
  derived-only.

## Required Validation

Run the parent validation floor before writing a passing closeout receipt:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
git diff --check
```

If any command is unavailable, times out, or fails, record the exact command,
exit status, and retained stdout/stderr location when available. Do not convert
a blocked command into a passing manual assertion.

## Hard Stops

Refuse `verdict: pass`, `archive_authorized: yes`, or archive-ready language
when any of these are true:

- Either parent aggregate receipt is missing, failing, unresolved, stale, or
  does not preserve child authority.
- Any required child has no terminal archived outcome.
- Any child-owned implementation, conformance, drift/churn, closeout, archive,
  validation, promotion, or rollback evidence is missing, stale, failing, or
  being replaced by parent summary text.
- The parent would need to edit child packets or own child truth to pass.
- Parent closeout depends on proposal-local inputs, generated projections,
  host state, dashboards, chat, tool availability, or agent output as
  authority.
- Active proposal paths, durable framework or instance surfaces, state/control
  truth, or generated effective surfaces acquire new raw proposal-path
  dependencies as part of closeout.
- Worktree hygiene cannot distinguish intended parent closeout changes from
  unrelated tracked changes, untracked state/control residue, retained
  evidence, generated outputs, or local run residue.
- Git, PR, CI, review, merge, branch cleanup, local-main sync, or explicit
  stage-only route requirements remain unresolved for the selected Change
  closeout route.

## Closeout Receipt Requirements

Write or refresh `support/proposal-closeout.md`. Minimum successful shape:

```markdown
# Proposal Program Closeout Receipt

verdict: pass
closed_at: <UTC timestamp>
proposal_id: octon-wide-delegated-governance-migration
archive_authorized: yes
archive_disposition: implemented
child_authority_preserved: yes
program_run_id: lifecycle-proposal-program-1781073115145-fe49ec37

## Route

selected_git_route: <direct-main|branch-no-pr|branch-pr|stage-only-escalate>
lifecycle_outcome: <route-specific outcome>
next_route_condition: archive-proposal may run only after this receipt is retained and route gates remain satisfied

## Evidence

parent_aggregate_evidence:
  - .octon/state/evidence/runs/workflows/lifecycle-proposal-program-1781073115145-fe49ec37/parent/aggregate-child-outcomes-20260610T133510Z.yml
  - .octon/state/evidence/runs/workflows/lifecycle-proposal-program-1781073115145-fe49ec37/aggregate-terminal-blockers.yml
  - .octon/state/control/execution/runs/lifecycle-proposal-program-1781073115145-fe49ec37/program-lifecycle-checkpoint.yml
  - .octon/state/control/execution/runs/lifecycle-proposal-program-1781073115145-fe49ec37/program-events.ndjson
  - .octon/state/evidence/runs/workflows/lifecycle-proposal-program-1781073115145-fe49ec37/parent/program-verification-correction-summary-20260610T142834Z.yml

child_receipt_summary:
  required_child_count: 9
  terminal_child_count: 9
  archived_child_count: 9
  blocked_required_child_count: 0
  child_receipt_summary_count: 36
  child_promotion_evidence_count: 82
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
criteria, child archive metadata, child rollback handles, or child terminal
outcomes.
```

Use `archive_authorized: no` for blocked, deferred, or stage-only outcomes.

## Final Answer Contract

Report only the actual closeout state:

- parent closeout receipt path and verdict;
- selected route and lifecycle outcome;
- validation commands that passed, failed, or were blocked;
- whether child authority remains preserved;
- evidence roots retained outside `inputs/**`;
- Git/PR/CI/review/merge/branch cleanup/sync state when applicable;
- remaining blockers or `none`.

Do not claim the parent is archived. A separate archive route must perform
parent archive mutation after successful closeout authorization.

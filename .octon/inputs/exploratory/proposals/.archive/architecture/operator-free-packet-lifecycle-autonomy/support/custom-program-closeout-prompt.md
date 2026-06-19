prompt_id: operator-free-packet-lifecycle-autonomy-program-closeout-20260618T213111Z
generated_at: "2026-06-18T21:31:11Z"
generated_by: octon-proposal-lifecycle-generate-program-closeout-prompt
generator_route_id: generate-program-closeout-prompt
target_program: .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
artifact_class: operational-aid
authority: non-authoritative
parent_status_at_generation: accepted
child_receipt_summary_count: 7
child_authority_preserved: yes
closeout_execution_authorized: no

# Custom Program Closeout Prompt

## Purpose

This prompt prepares the separately authorized parent closeout route for
`operator-free-packet-lifecycle-autonomy`. It is an operational aid only. It
does not execute closeout, does not mutate parent lifecycle state, does not
archive the parent, does not authorize cleanup, landing, publication, deletion,
or a `cleaned` claim, and does not satisfy child-owned evidence.

Parent closeout execution requires a later explicit instruction authorizing the
`octon-proposal-lifecycle-closeout-program` route for this parent. If that
authorization is absent, stop before writing `support/proposal-closeout.md`.

## Mandatory Inputs

Read the current repository state, not stale conversation summaries:

- `proposal.yml`
- `architecture-proposal.yml`
- `README.md`
- `navigation/source-of-truth-map.md`
- `navigation/artifact-catalog.md`
- `resources/child-packet-index.yml`
- `architecture/packet-sequence.md`
- `architecture/child-packet-contract.md`
- `architecture/program-closeout-plan.md`
- `RISK-REGISTER.md`
- `validation-plan.md`
- `resources/source-lineage.md`
- `support/proposal-review.md`
- `support/implementation-grade-completeness-review.md`
- `support/follow-up-program-verification-prompt.md`
- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`

Inspect each required child packet as retained child evidence only:

- `.octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics`
- `.octon/inputs/exploratory/proposals/architecture/packet-delivery-wrapper-orchestration-autonomy`
- `.octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy`
- `.octon/inputs/exploratory/proposals/architecture/generated-freshness-scope-detection`
- `.octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation`
- `.octon/inputs/exploratory/proposals/architecture/terminal-evidence-sink-autonomy`
- `.octon/inputs/exploratory/proposals/architecture/git-mutation-sandbox-preflight`

For each child, inspect existing child-owned receipts without recreating them:

- `support/proposal-review.md`
- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`
- `support/pre-integration-architecture-review.yml`

Validate and cite the retained-run evidence indexes declared by
`resources/child-packet-index.yml`. These indexes are retained discovery and
replay aids. They do not replace child-owned packet receipts.

## Pre-Closeout Gates

The parent closeout route may write a passing `support/proposal-closeout.md`
only when all of these conditions hold at execution time:

- Separate user authorization explicitly permits parent closeout execution.
- Parent closeout execution does not promote, archive, clean, land, publish,
  delete, or claim `cleaned`.
- Parent status is still compatible with the current canonical closeout route.
  If the route requires `status: implemented` and the parent remains
  `accepted`, stop and route a governed correction or explicit lifecycle
  decision. Do not mutate parent status from the closeout route.
- All seven required children are `implemented`.
- `support/program-implementation-orchestration-conformance-review.md` has:
  - `verdict: pass`
  - `unresolved_items_count: 0`
  - `child_receipt_summary_count: 7`
  - `child_authority_preserved: yes`
- `support/program-post-implementation-orchestration-drift-churn-review.md`
  has:
  - `verdict: pass`
  - `unresolved_items_count: 0`
  - `child_receipt_summary_count: 7`
  - `child_authority_preserved: yes`
- Every child retained-run evidence index validates as
  `retained-run-evidence-index-v1`.
- Parent evidence summarizes child outcomes only. It does not satisfy, edit, or
  authorize child manifests, child receipts, child promotion targets, child
  validation verdicts, child archive metadata, child rollback handles, or child
  terminal outcomes.
- Generated outputs remain derived-only and are refreshed only through
  canonical generators when a validator requires refresh.
- No durable target gains active parent or child proposal-path backreferences.

## Required Validation

Run the parent validation floor immediately before closeout receipt generation:

```bash
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --skip-registry-check
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
```

Validate every child retained-run evidence index:

```bash
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-retained-run-evidence-index.sh --index <child-retained-run-evidence-index>
```

Rerun child dependency gates if child packet files, child receipts, generated
proposal artifacts, retained indexes, or parent child-registry references have
changed since aggregate verification:

```bash
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child>
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child>
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal <child> --run-registry-check
```

## Closeout Receipt Requirements

If parent closeout is separately authorized and all gates pass, write or
refresh only:

- `support/proposal-closeout.md`

Minimum successful receipt shape:

```markdown
# Proposal Program Closeout Receipt

verdict: pass
closed_at: <UTC timestamp>
proposal_id: operator-free-packet-lifecycle-autonomy
archive_authorized: yes
archive_disposition: implemented
child_authority_preserved: yes
selected_git_route: <direct-main|branch-no-pr|branch-pr|stage-only-escalate>
worktree_hygiene_verdict: <pass|blocked>
worktree_hygiene_blocker_class: <none|foreign-residue|protected-evidence|manual-review-required|other>
worktree_hygiene_owned_path_count: <integer>
worktree_hygiene_in_scope_path_count: <integer>
worktree_hygiene_foreign_path_count: <integer>
worktree_hygiene_foreign_fingerprint: <fingerprint-or-none>
worktree_hygiene_evidence: <path-or-summary>
cleanup_summary: <summary-or-none>
next_route_condition: archive-proposal may run only after this closeout receipt is retained and route gates remain satisfied

## Evidence

parent_aggregate_receipts:
  - support/program-implementation-orchestration-conformance-review.md
  - support/program-post-implementation-orchestration-drift-churn-review.md

child_receipt_summary:
  required_child_count: 7
  implemented_child_count: 7
  blocked_required_child_count: 0
  child_receipt_summary_count: 7
  child_receipts_remain_child_owned: yes

retained_evidence_indexes:
  - <validated retained-run-evidence-index.yml for each child>

## Validation

Record exact commands, exit status, and bounded output summaries.

## Authority Boundary

Parent closeout evidence summarizes child outcomes only. It does not satisfy,
replace, edit, authorize, promote, close out, archive, clean, delete, or mutate
child manifests, child receipts, child validation verdicts, child promotion
targets, child archive metadata, child rollback handles, or child terminal
outcomes.
```

Use `archive_authorized: no`, `verdict: blocked`, and
`selected_git_route: stage-only-escalate` if any gate fails, closeout lacks
explicit authorization, parent status is incompatible with closeout, worktree
hygiene is ambiguous, generated outputs are stale and cannot be refreshed
through canonical generators, or child authority would need to move into the
parent.

## Hard Stops

Stop without closeout when any of these are true:

- Explicit user authorization for parent closeout execution is absent.
- Parent status would need mutation to make closeout pass.
- Either aggregate parent receipt is missing, failing, unresolved, stale, or
  does not preserve child authority.
- Any required child is not implemented.
- Any child-owned implementation, conformance, drift/churn, validation,
  strict-architecture, terminal freshness, retained index, closeout, archive,
  promotion, or rollback evidence is missing, stale, failing, or being replaced
  by parent summary text.
- Parent closeout depends on proposal-local inputs, generated projections,
  host state, dashboards, chat, tool availability, or agent output as authority.
- Worktree hygiene cannot distinguish intended parent closeout changes from
  unrelated tracked changes, untracked state/control residue, retained
  evidence, generated outputs, or local run residue.
- PR, CI, review, merge, branch cleanup, local-main sync, or explicit
  stage-only route requirements remain unresolved for the selected Change
  closeout route.

## Generation-Time Evidence

This prompt was generated after the following gates passed:

- `validate-retained-run-evidence-index.sh --index <each child index>`:
  7/7 passed with `errors=0`.
- `validate-proposal-program-structure.sh --package <parent>`:
  `errors=0 warnings=0`.
- `validate-proposal-program-child-readiness.sh --package <parent>`:
  `errors=0 warnings=0`.
- `validate-proposal-program-readiness-projection.sh --package <parent>`:
  `errors=0 warnings=2`.
- `validate-proposal-standard.sh --package <parent> --skip-registry-check`:
  `errors=0 warnings=1`.
- `generate-proposal-registry.sh --check`:
  `errors=0`.

No generated outputs were refreshed during prompt generation.

## Final Answer Contract For Closeout Execution

When closeout is separately authorized and run, report:

- parent closeout receipt path and verdict;
- selected route and lifecycle outcome;
- validation commands that passed, failed, or were blocked;
- whether child authority remains preserved;
- retained evidence roots outside `inputs/**`;
- generated outputs refreshed, if any, and the canonical generator used;
- Git/PR/CI/review/merge/branch cleanup/sync state when applicable;
- remaining blockers or `none`;
- whether parent lifecycle state was mutated.

Do not claim the parent is archived. A separate archive route must perform any
parent archive mutation after successful closeout authorization and closeout
receipt retention.

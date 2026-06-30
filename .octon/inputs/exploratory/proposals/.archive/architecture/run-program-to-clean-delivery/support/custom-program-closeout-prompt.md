prompt_id: run-program-to-clean-delivery-program-closeout-20260630T015045Z
generated_at: "2026-06-30T01:50:45Z"
generated_by: octon-proposal-lifecycle-generate-program-closeout-prompt
generator_route_id: generate-program-closeout-prompt
target_program: .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
artifact_class: operational-aid
authority: non-authoritative
run_id: 20260630T015045Z-run-program-to-clean-delivery-parent-closeout-worktree-disposition
prompt_set_id: octon-proposal-lifecycle-generate-program-closeout-prompt
prompt_bundle_sha256: sha256:c9470f4c4ba68ccfe14f53ef35755ecc70ed3d805df7ee9dde7b7629b2f04d5b
parent_status_at_generation: implemented
child_receipt_summary_count: 6
child_authority_preserved: yes
closeout_execution_authorized: no

# Custom Program Closeout Prompt

## Purpose

Prepare the separately authorized parent closeout route for:

`.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery`

This prompt is an operational aid only. It does not execute closeout, mutate
parent lifecycle state, archive the parent, archive or edit children, deliver a
Change, stage, commit, push, clean branches, delete residue, refresh generated
outputs, or claim terminal `git_clean_terminal`.

Parent closeout execution requires a later explicit instruction authorizing the
`octon-proposal-lifecycle-closeout-program` route for this parent. If that
authorization is absent, stop before writing `support/proposal-closeout.md`.

## Mandatory Inputs

Read current repository state, not conversation summaries or generated
operator views:

- `AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `proposal.yml`
- `architecture-proposal.yml`
- `README.md`
- `navigation/source-of-truth-map.md`
- `navigation/artifact-catalog.md`
- `resources/child-packet-index.yml`
- `resources/child-packet-index.md`
- `architecture/packet-sequence.md`
- `architecture/child-packet-contract.md`
- `architecture/program-closeout-plan.md`
- `architecture/acceptance-criteria.md`
- `validation-plan.md`
- `support/proposal-review.md`
- `support/implementation-grade-completeness-review.md`
- `support/program-implementation-orchestration-prompt.md`
- `support/program-implementation-orchestration-run.md`
- `support/follow-up-program-verification-prompt.md`
- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`
- `.octon/state/evidence/runs/workflows/20260630T010000Z-run-program-to-clean-delivery-parent-next-route/aggregate-terminal-blockers.yml`

Inspect each required child through its child-owned archived packet and
terminal closeout receipt. The parent child registry preserves the original
sibling paths as planning lineage; archived packets and terminal receipts are
the current child lifecycle evidence to dereference.

Required children, in sequence:

1. `run-program-clean-delivery-architecture`
   - archived packet:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-architecture`
   - terminal receipt:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-architecture/support/proposal-terminal-closeout.yml`
2. `run-program-clean-delivery-runner-routing`
   - archived packet:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-runner-routing`
   - terminal receipt:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-runner-routing/support/proposal-terminal-closeout.yml`
3. `run-program-clean-delivery-workflow-handoff`
   - archived packet:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-workflow-handoff`
   - terminal receipt:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-workflow-handoff/support/proposal-terminal-closeout.yml`
4. `run-program-clean-delivery-evidence-metadata`
   - archived packet:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-evidence-metadata`
   - terminal receipt:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-evidence-metadata/support/proposal-terminal-closeout.yml`
5. `run-program-clean-delivery-validators`
   - archived packet:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-validators`
   - terminal receipt:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-validators/support/proposal-terminal-closeout.yml`
6. `run-program-clean-delivery-operator-surface`
   - archived packet:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-operator-surface`
   - terminal receipt:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-operator-surface/support/proposal-terminal-closeout.yml`

For each child, inspect child-owned evidence without recreating or editing it:

- `proposal.yml`
- `architecture-proposal.yml`
- `architecture/acceptance-criteria.md`
- `architecture/implementation-plan.md`
- `validation-plan.md`
- `support/proposal-review.md`
- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/proposal-closeout.md`
- `support/proposal-terminal-closeout.yml`

## Authority Boundaries

- `inputs/**` proposal packets remain non-authoritative planning lineage.
- Parent closeout may summarize child outcomes only by path, digest, and
  verdict. It must not satisfy, replace, edit, promote, close, archive, clean,
  or mutate child manifests, child receipts, child validation verdicts, child
  promotion targets, child archive metadata, child rollback handles, child
  terminal closeout, or child terminal outcomes.
- Child closeout, child archive metadata, child terminal receipts, child
  implementation conformance, and child post-implementation drift/churn remain
  child-owned.
- Parent closeout must not create delivery receipts, Change receipts, branch
  cleanup authorization, terminal current-state proof, or `git_clean_terminal`
  proof.
- Generated outputs remain derived-only and may be refreshed only by canonical
  generators when a validator requires refresh.
- Host state, dashboards, PR labels, chat history, model memory, and tool
  availability are not authority.

## Pre-Closeout Gates

The parent closeout route may write a passing `support/proposal-closeout.md`
only when all of these conditions hold at execution time:

- Separate user authorization explicitly permits parent closeout execution.
- Parent `proposal.yml#status` is `implemented`; do not mutate parent status
  from closeout to make the gate pass.
- Parent `architecture-proposal.yml#status: draft` is treated as non-blocking
  subtype metadata only if the parent standard and architecture validators pass.
- All six required child packets are archived from implemented state or
  otherwise covered by an explicitly accepted child-owned terminal outcome.
- `support/program-implementation-orchestration-conformance-review.md` has:
  - `verdict: pass`
  - `unresolved_items_count: 0`
  - `child_receipt_summary_count: 6`
  - `child_authority_preserved: yes`
- `support/program-post-implementation-orchestration-drift-churn-review.md`
  has:
  - `verdict: pass`
  - `unresolved_items_count: 0`
  - `child_receipt_summary_count: 6`
  - `child_authority_preserved: yes`
- Every child has passing child-owned implementation conformance evidence and
  passing child-owned post-implementation drift/churn evidence.
- Every child terminal closeout receipt reports `terminal_verdict:
  archive-ready` and `archive_ready: yes`.
- Aggregate terminal blocker evidence reports `blocked_required_child_count: 0`.
- The read-only worktree hygiene classifier reports no foreign or ambiguous
  path that would make parent closeout ownership unclear.
- Parent evidence continues to preserve delivery, Change closeout, branch
  cleanup, and terminal proof boundaries.

## Required Validation

Use Bash 4+ or Bash 5 for validators that rely on associative arrays. In this
environment, prefer Homebrew Bash and a PATH prefix so nested `env bash`
children do not resolve to `/bin/bash` 3.2:

```sh
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery --require-implementation-authorization
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery --skip-registry-check
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
```

Run the read-only hygiene classifier before any passing archive-ready claim:

```sh
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh --target .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery --lifecycle proposal-program --run-id 20260630T015045Z-run-program-to-clean-delivery-parent-closeout-worktree-disposition --format yaml
```

For each archived child, rerun child dependency gates if the child packet,
child receipts, generated proposal artifacts, parent child registry, or
terminal receipt changed since the aggregate verification receipts:

```sh
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <archived-child> --skip-registry-check
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <archived-child>
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <archived-child>
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <archived-child>
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-receipt.sh --receipt <archived-child>/support/proposal-terminal-closeout.yml
```

Delivery and Change validators are applicable only after their owning receipts
exist. If a receipt is absent before the delivery route, record
`not-applicable: receipt absent before delivery route` rather than inventing a
receipt:

```sh
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh --receipt <program-delivery-receipt-if-present>
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh --receipt <change-receipt-if-present>
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh --receipt <change-receipt-if-present>
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt <change-receipt-if-present> --verify-live-refs
PATH=/Users/jamesryancooper/.homebrew/bin:$PATH /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh --change-reipt <change-receipt-if-present>
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
proposal_id: run-program-to-clean-delivery
archive_authorized: yes
archive_disposition: implemented
child_authority_preserved: yes
selected_git_route: <direct-main|branch-no-pr|branch-pr|stage-only-escalate>
worktree_hygiene_verdict: pass
worktree_hygiene_blocker_class: none
worktree_hygiene_owned_path_count: <integer>
worktree_hygiene_in_scope_path_count: <integer>
worktree_hygiene_foreign_path_count: 0
worktree_hygiene_foreign_fingerprint: none
worktree_hygiene_evidence: <classifier-output-path-or-summary>
cleanup_summary: <summary-or-none>
next_route_condition: archive-proposal may run only after this closeout receipt is retained and route gates remain satisfied

## Evidence

parent_aggregate_receipts:
  - support/program-implementation-orchestration-conformance-review.md
  - support/program-post-implementation-orchestration-drift-churn-review.md

child_receipt_summary:
  required_child_count: 6
  archived_child_count: 6
  blocked_required_child_count: 0
  child_receipt_summary_count: 6
  child_receipts_remain_child_owned: yes

child_terminal_receipts:
  - .octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-architecture/support/proposal-terminal-closeout.yml
  - .octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-runner-routing/support/proposal-terminal-closeout.yml
  - .octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-workflow-handoff/support/proposal-terminal-closeout.yml
  - .octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-evidence-metadata/support/proposal-terminal-closeout.yml
  - .octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-validators/support/proposal-terminal-closeout.yml
  - .octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-operator-surface/support/proposal-terminal-closeout.yml

## Validation

Record exact commands, cwd, exit status, and bounded output summaries.

## Authority Boundary

Parent closeout evidence summarizes child outcomes only. It does not satisfy,
replace, edit, authorize, promote, close out, archive, clean, delete, or mutate
child manifests, child receipts, child validation verdicts, child promotion
targets, child archive metadata, child rollback handles, child terminal
closeout, or child terminal outcomes. It does not authorize delivery, branch
cleanup, or terminal `git_clean_terminal` by itself.
```

Use `verdict: blocked`, `archive_authorized: no`, and `selected_git_route:
stage-only-escalate` if any gate fails, closeout lacks explicit authorization,
parent status is incompatible with closeout, worktree hygiene is ambiguous,
generated outputs are stale and cannot be refreshed through canonical
generators, delivery or Change evidence is being overclaimed, or child
authority would need to move into the parent.

If the worktree hygiene classifier reports any `foreign-or-ambiguous` paths,
write or refresh `support/proposal-closeout.md` with:

- `verdict: blocked`
- `archive_authorized: no`
- `selected_git_route: stage-only-escalate`
- `worktree_hygiene_verdict: blocked`
- `worktree_hygiene_blocker_class: worktree-hygiene-blocked`
- `worktree_hygiene_owned_path_count`
- `worktree_hygiene_in_scope_path_count`
- `worktree_hygiene_foreign_path_count`
- `worktree_hygiene_evidence`
- `next_route_condition: closeout-change or operator scope resolution`

Do not stage, commit, push, delete, reset, archive, or otherwise clean worktree
paths from the closeout-program route.

## Hard Stops

Stop without a passing parent closeout receipt when any of these are true:

- Explicit user authorization for parent closeout execution is absent.
- Parent status would need mutation to make closeout pass.
- Either parent aggregate receipt is missing, failing, unresolved, stale, or
  does not preserve child authority.
- Any required child lacks child-owned implementation conformance,
  post-implementation drift/churn, closeout, archive, or terminal closeout
  evidence.
- Parent closeout depends on proposal-local inputs, generated projections,
  host state, dashboards, chat, tool availability, or agent output as
  authority.
- Worktree hygiene cannot distinguish intended parent closeout changes from
  unrelated tracked changes, untracked state/control residue, retained
  evidence, generated outputs, or local run residue.
- Delivery, Change closeout, hosted landing, branch cleanup, terminal proof,
  PR, CI, review, merge, sync, or explicit stage-only route requirements are
  being claimed without their owning receipts.

## Generation-Time Evidence

This prompt was generated after reading the parent packet and confirming the
two required parent-local aggregate receipts currently report:

- `verdict: pass`
- `unresolved_items_count: 0`
- `child_receipt_summary_count: 6`
- `child_authority_preserved: yes`

The generation route did not execute closeout, did not write
`support/proposal-closeout.md`, did not archive the parent, did not edit child
packets, did not create delivery or Change receipts, and did not claim terminal
clean state.

## Final Answer Contract For Closeout Execution

When parent closeout is separately authorized and run, report:

- parent closeout receipt path and verdict;
- selected route and lifecycle outcome;
- worktree hygiene verdict and blocker class;
- validation commands that passed, failed, or were not applicable;
- whether child authority remains preserved;
- retained evidence roots outside `inputs/**`;
- generated outputs refreshed, if any, and the canonical generator used;
- Git, PR, CI, review, merge, branch cleanup, and sync state when applicable;
- remaining blockers or `none`;
- whether parent lifecycle state or any child packet was mutated.

Do not claim the parent is archived. A separate archive route must perform any
parent archive mutation after successful closeout authorization and closeout
receipt retention.

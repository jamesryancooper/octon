prompt_id: proposal-program-execution-resilience-and-supersession-program-closeout-20260707T151000Z
generated_by: octon-proposal-lifecycle-generate-program-closeout-prompt
generator_route_id: generate-program-closeout-prompt
target_program: .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-resilience-and-supersession
route: closeout-proposal-program
lifecycle_id: proposal-program
program_run_id: lifecycle-proposal-program-execution-resilience-parent-terminal-20260707T151000Z
artifact_class: operational-aid
authority: non-authoritative
generated_at: 2026-07-07T15:10:00Z
parent_status_at_generation: implemented
required_child_count: 4
terminal_child_count: 4
child_receipt_summary_count: 16
child_authority_preserved: yes
parent_summary_not_child_evidence: true
closeout_execution_authorized: no

# Program Closeout Prompt

## Purpose

Prepare the parent closeout route for
`.octon/inputs/exploratory/proposals/architecture/proposal-program-execution-resilience-and-supersession`.

This prompt is parent-local operational guidance only. It does not execute
closeout, authorize archive, mutate lifecycle state, clean residue, stage,
commit, push, publish generated outputs, or replace child-owned receipts.

## Mandatory Gates

Before writing `support/proposal-closeout.md`, verify the current repository
state rather than conversation summaries:

- Parent `proposal.yml` records `status: implemented`.
- Parent `support/proposal-review.md` records `verdict: accepted`,
  `implementation_prompt_authorized: yes`, and zero blocking findings.
- Parent `support/pre-integration-architecture-review.yml` records a passing
  pre-integration architecture review with zero unresolved items.
- Parent `support/program-implementation-orchestration-run.md` records
  `verdict: pass`, `required_child_count: 4`, `terminal_child_count: 4`,
  `child_receipt_summary_count: 16`, and `child_authority_preserved: yes`.
- Parent `support/program-implementation-orchestration-conformance-review.md`
  records `verdict: pass`, `unresolved_items_count: 0`,
  `child_receipt_summary_count: 16`, and `child_authority_preserved: yes`.
- Parent `support/program-post-implementation-orchestration-drift-churn-review.md`
  records `verdict: pass`, `unresolved_items_count: 0`,
  `child_receipt_summary_count: 16`, and `child_authority_preserved: yes`.
- Parent `support/lifecycle-residue-cleanup.md` records zero cleanup
  candidates, no cleanup/deletion/cleaned claim, and
  `worktree_hygiene_verdict: preserved-by-closeout-worktree`.
- The cited closeout-worktree parent handoff report validates and records a
  non-mutating `preserve-and-exclude-from-lifecycle-closeout-blocking`
  disposition for the retained parent residue.
- All four children remain archived implemented and retain child-owned
  implementation-run, implementation-conformance, post-implementation drift,
  validation, closeout, terminal-closeout, and archive metadata.

## Required Child Inputs

Inspect these archived child packets as child-owned evidence only:

- `.octon/inputs/exploratory/proposals/.archive/architecture/proposal-program-loop-breaker`
- `.octon/inputs/exploratory/proposals/.archive/architecture/proposal-program-ownership-baseline-and-leases`
- `.octon/inputs/exploratory/proposals/.archive/architecture/proposal-program-supersession-rescue-path`
- `.octon/inputs/exploratory/proposals/.archive/architecture/closeout-worktree-autonomous-partition-evidence`

For each child, parent closeout may summarize only by reference. It must not
rewrite, replace, satisfy, or authorize child manifests, receipts, validators,
archive metadata, rollback handles, cleanup dispositions, or terminal outcomes.

## Required Parent Receipt

When all gates pass and closeout execution is separately authorized, write only
`support/proposal-closeout.md` for the parent. Include at least:

```text
verdict: pass|blocked|fail
closed_at: <UTC timestamp>
proposal_id: proposal-program-execution-resilience-and-supersession
program_run_id: <current lifecycle run id>
archive_authorized: yes|no
archive_disposition: implemented|blocked|not-authorized
child_authority_preserved: yes|no
child_closeout_count: 4
child_archive_authorized_count: 4
selected_git_route: <route>
worktree_hygiene_verdict: pass|preserved-by-closeout-worktree|blocked|fail
worktree_hygiene_blocker_class: <class-or-none>
worktree_hygiene_owned_path_count: <integer>
worktree_hygiene_in_scope_path_count: <integer>
worktree_hygiene_foreign_path_count: <integer>
worktree_hygiene_foreign_fingerprint: <fingerprint-or-none>
worktree_hygiene_evidence: <path>
closeout_worktree_report: <path-or-none>
lifecycle_interaction_return: <path-or-none>
cleanup_summary: <summary>
next_route_condition: archive-proposal lifecycle route
```

## Authority Boundary

The closeout receipt may authorize only parent archival after terminal
validation passes. It must not claim that retained residue was cleaned,
deleted, staged, committed, pushed, archived, published, or otherwise mutated.
Child manifests, receipts, validation verdicts, terminal closeout receipts,
archive metadata, and lifecycle outcomes remain child-owned.

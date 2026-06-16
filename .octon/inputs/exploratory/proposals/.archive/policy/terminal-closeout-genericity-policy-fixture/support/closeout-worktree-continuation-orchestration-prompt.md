# Closeout Worktree Continuation Orchestration Prompt

generated_at: 2026-06-16
prompt_role: packet-local orchestration aid
packet_path: .octon/inputs/exploratory/proposals/policy/terminal-closeout-genericity-policy-fixture
packet_id: terminal-closeout-genericity-policy-fixture
blocked_receipt_ref: .octon/inputs/exploratory/proposals/policy/terminal-closeout-genericity-policy-fixture/support/proposal-terminal-closeout.yml
next_route: closeout-worktree

This prompt is not authority. It is an orchestration aid for continuing from
the packet terminal-closeout blocker into the next lifecycle route recorded by
the terminal receipt. Bind all factual claims to current repository state,
retained evidence, deterministic validator output, and the canonical closeout
contracts.

## Goal

Continue the blocked terminal closeout for
`terminal-closeout-genericity-policy-fixture` by running the next canonical
lifecycle route, `closeout-worktree`, then perform the delivery steps required
for any coherent Change selected by that route.

The expected result is one of:

- a validated `closeout-worktree` wrapper report that partitions the current
  worktree, delegates each publishable candidate through singular
  `closeout-change`, and records a terminal worktree disposition; or
- a blocked, deferred, retained, escalated, or foreign disposition with
  candidate-keyed evidence and the next route condition.

Do not claim `archive-ready`, `cleaned`, `landed`, branch cleanup, PR readiness,
or worktree terminal state unless the route-owned evidence proves that outcome.

## Starting Context

The packet terminal receipt recorded:

- `terminal_verdict: blocked`
- `target_outcome: archive-ready`
- blocker class: `hygiene-blocked`
- blocker detail: `foreign or ambiguous worktree residue remains: 447 paths`
- failing evidence:
  `.octon/state/evidence/runs/workflows/2026-06-14-proposal-packet-terminal-closeout-octon-inputs-exploratory-proposals-policy-terminal-closeout-genericity-policy-fixture/reports/worktree-hygiene-classification.md`
- next canonical route: `closeout-worktree`

Treat this as retained evidence for why the prior terminal closeout stopped.
It is not proof of the current worktree state. Re-inventory the current
worktree before selecting any candidate.

## Mandatory Reads

Read the active repo ingress and mandatory constitutional set before planning:

- `.octon/instance/ingress/AGENTS.md`
- `.octon/framework/constitution/CHARTER.md`
- `.octon/framework/constitution/charter.yml`
- `.octon/framework/constitution/obligations/fail-closed.yml`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/precedence/normative.yml`
- `.octon/framework/constitution/precedence/epistemic.yml`
- `.octon/framework/constitution/ownership/roles.yml`
- `.octon/framework/constitution/contracts/registry.yml`
- `.octon/instance/charter/workspace.md`
- `.octon/instance/charter/workspace.yml`
- `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`

Read the route and delivery contracts before mutating Git, GitHub, branches, or
cleanup state:

- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md`
- `.octon/framework/execution-roles/practices/commits.md`
- `.octon/framework/execution-roles/practices/pull-request-standards.md`

Read packet-local context as advisory lineage:

- `proposal.yml`
- `policy-proposal.yml`
- `policy/decision.md`
- `policy/policy-delta.md`
- `policy/enforcement-plan.md`
- `implementation/implementation-map.md`
- `support/implementation-grade-completeness-review.md`
- `support/proposal-review.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/proposal-closeout.md`
- `support/proposal-terminal-closeout.yml`

## Profile Selection Receipt

- release_state: `pre-1.0`
- change_profile: `atomic`
- rationale: the continuation is route execution and delivery of bounded
  repository state, not a transitional governance migration.
- transitional_exception_note: `none`

## Orchestration Procedure

1. Confirm current branch, `HEAD`, `main`, `origin/main`, remotes, staged,
   unstaged, untracked, ignored, branch, and worktree state. The 2026-06-14
   blocker count is historical; do not reuse it as current state.

2. Run the read-only residue classifier required by `closeout-worktree` and
   retain the classifier output or a digest-backed summary. Detection is not
   deletion authority.

3. Partition every observed item into candidate records. Each candidate must
   have one coherent intent, explicit include and exclude paths, ownership
   posture, route hint, target lifecycle outcome, validation floor, rollback or
   discard posture, and exactly one residue routing class:
   `publishable_change`, `publishable_closeout_evidence`,
   `local_private_retained`, `foreign_manual_review`, `unsafe`, or
   `ambiguous`.

4. Default generic worktree closeout candidates to
   `target_lifecycle_outcome: cleaned` unless the operator explicitly requests
   a narrower outcome.

5. Select exactly one safely separable candidate. Multiple candidates alone is
   not a blocker. Stop only for a candidate-keyed blocker such as ambiguous
   ownership, overlapping path ownership, destructive cleanup need, missing
   validation, missing rollback posture, or unclear route authority.

6. Delegate only `publishable_change` and `publishable_closeout_evidence`
   candidates to singular `closeout-change`. The wrapper must not stage,
   commit, push, open PRs, land, merge, delete branches, restore, reset,
   overwrite, or perform repo-hygiene cleanup directly.

7. Route eligible repo-hygiene residue to `repo-hygiene-cleanup`; route
   temporary fixture retention residue to `fixture-retention-closeout`; route
   generated run-health projections to the owning generator; retain or block
   stale detached worktree residue until Git worktree cleanup proof exists.

8. After each delegated closeout attempt, re-inventory and re-classify before
   selecting the next candidate.

9. Write and validate the `closeout-worktree` wrapper report. The report must
   record candidates, iterations, delegated `closeout-change` refs, final
   candidate dispositions, retained residue, blockers, final inventory,
   final residue classes, `worktree_terminal_state`, and
   `next_route_condition`.

10. Validate the wrapper report with:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh --report <report-path>
```

## Delivery Procedure For Selected Changes

For each singular Change selected by `closeout-worktree`, use
`closeout-change` and obey the selected route:

- `direct-main`: require local validation, a landed commit on `main`, a Change
  receipt, rollback handle, push to `origin/main`, post-push fetch, and proof
  that local `main`, `origin/main`, and `landed_ref` align.
- `branch-no-pr`: require branch identity, no-PR rationale, local validation
  or blocker, durable commit/checkpoint, source branch push when claiming
  publication, governed landing authorization before hosted no-PR landing, and
  governed cleanup authorization before branch deletion.
- `branch-pr`: require a concrete PR predicate and predicate evidence before
  opening or using a PR. Follow the PR template, required checks, review
  gates, rollback evidence, and merge/cleanup proof before claiming landed or
  cleaned.
- `stage-only-escalate`: preserve patch/checkpoint/branch state, record the
  blocker, and do not claim durable completion.

Every delivery step must preserve unrelated work and must stage only the
selected candidate's include paths. If route-specific GitHub, provider,
sandbox, validation, cleanup, or approval gates block mutation, record the
blocker and next route condition instead of bypassing controls.

## Validation Floor

Run at minimum:

```bash
git diff --check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh --package .octon/inputs/exploratory/proposals/policy/terminal-closeout-genericity-policy-fixture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/policy/terminal-closeout-genericity-policy-fixture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/policy/terminal-closeout-genericity-policy-fixture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/policy/terminal-closeout-genericity-policy-fixture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-receipt.sh --receipt .octon/inputs/exploratory/proposals/policy/terminal-closeout-genericity-policy-fixture/support/proposal-terminal-closeout.yml
```

Add route-specific validators from the delegated `closeout-change` receipt and
rerun any failed validator after the smallest credible fix. If a failure is
outside the selected candidate's boundary, record it as an external blocker or
separate candidate instead of folding it into the current Change.

## Hard Stops

Stop and record a blocker when:

- current worktree inventory cannot safely separate candidate boundaries;
- a candidate needs destructive cleanup before ownership and deletion authority
  are proven;
- proposal-local files, generated outputs, host state, GitHub state, chat,
  model memory, or this prompt would be used as authority;
- a wrapper report lacks candidate-keyed include/exclude paths, final
  dispositions, delegated `closeout-change` refs, or blocker evidence;
- a delivery route would stage unrelated paths or overwrite user-owned work;
- branch landing, push, PR, merge, cleanup, or local-main sync proof is
  missing for the claimed outcome;
- validation fails and cannot be fixed inside the selected candidate boundary.

## Final Report Contract

Report:

- current route entered: `closeout-worktree`
- selected candidate ids and dispositions
- wrapper report path and validation result
- delegated `closeout-change` receipt paths and outcomes
- delivery route selected for each publishable Change
- validation commands run and results
- blockers, retained residue, exclusions, and next route condition
- explicit statement that this prompt and proposal-local packet files are
  advisory lineage only, not closeout authority

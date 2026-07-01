prompt_id: proposal-program-lifecycle-surface-coherence-program-closeout-20260701T163850Z
generated_by: octon-proposal-lifecycle-generate-program-closeout-prompt
generator_route_id: generate-program-closeout-prompt
target_program: .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence
route: closeout-program
lifecycle_id: proposal-program
program_run_id: lifecycle-proposal-program-1782852942821-fba365cc
artifact_class: operational-aid
authority: non-authoritative
generated_at: 2026-07-01T16:38:50Z
parent_status_at_generation: implemented
required_child_count: 5
terminal_child_count: 5
child_receipt_summary_count: 20
child_authority_preserved: yes
closeout_execution_authorized: no

# Program Closeout Prompt

## Purpose

Prepare the separately authorized parent closeout route for
`.octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence`.

This prompt is parent-local operational guidance only. It does not execute
closeout, authorize archive, mutate lifecycle state, clean residue, stage,
commit, push, publish generated outputs, run Change closeout, or claim a clean
worktree. It does not satisfy child receipts, child promotion targets, child
validation verdicts, child closeout receipts, child archive metadata, rollback
handles, cleanup dispositions, or child terminal outcomes.

Parent closeout execution requires a later explicit instruction authorizing
the `octon-proposal-lifecycle-closeout-program` route for this parent. If that
authorization is absent, stop before writing `support/proposal-closeout.md`.

## Generation Basis

The prompt bundle was consumed through the compact capsule for
`octon-proposal-lifecycle-generate-program-closeout-prompt`.

- bundle digest:
  `sha256:5153ba674565ef7297faa4db2753e7a22c07eeef6c4d9c53dbc7ca1a18ffb1e1`
- alignment receipt:
  `.octon/state/evidence/validation/extensions/prompt-alignment/2026-07-01T16-19-22Z-octon-proposal-lifecycle-octon-proposal-lifecycle-generate-program-closeout-prompt.yml`
- route run: `lifecycle-proposal-program-1782852942821-fba365cc`

Generation-time hash checks matched the compact capsule for the manifest,
stage prompt, companion prompt, bundle contract, repository grounding,
proposal contract, authority-boundary, lifecycle-artifact, validation/evidence,
and GitHub closeout boundary assets. The full prompt assets were not expanded.

## Mandatory Parent Inputs

Read the current repository state, not stale conversation summaries:

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
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`
- `validation-plan.md`
- `resources/source-lineage.md`
- `resources/repository-reconnaissance.md`
- `support/proposal-review.md`
- `support/pre-integration-architecture-review.yml`
- `support/implementation-grade-completeness-review.md`
- `support/program-implementation-orchestration-prompt.md`
- `support/program-implementation-orchestration-run.md`
- `support/follow-up-program-verification-prompt.md`
- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`
- `support/lifecycle-residue-cleanup.md`

Read retained parent workflow evidence:

- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1782852942821-fba365cc/parent/program-implementation-orchestration-run.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1782852942821-fba365cc/program-lifecycle-checkpoint.yml`
- `.octon/state/control/execution/runs/lifecycle-proposal-program-1782852942821-fba365cc/program-lifecycle-checkpoint.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1782852942821-fba365cc/aggregate-terminal-blockers.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1782852942821-fba365cc/publication-freshness-preflight/summary.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1782852942821-fba365cc/lifecycle-interactions/parent-closeout-worktree-return.json`
- `.octon/state/evidence/runs/skills/closeout-worktree/lifecycle-proposal-program-1782852942821-fba365cc-parent-worktree-handoff-current/parent-closeout-worktree-report.yml`

## Required Child Inputs

Inspect each archived child packet as child-owned evidence only:

- `.octon/inputs/exploratory/proposals/.archive/architecture/proposal-delivery-input-contract-alignment`
- `.octon/inputs/exploratory/proposals/.archive/architecture/proposal-program-delivery-operator-alias`
- `.octon/inputs/exploratory/proposals/.archive/architecture/proposal-program-delivery-host-projections`
- `.octon/inputs/exploratory/proposals/.archive/architecture/proposal-program-review-loop-documentation`
- `.octon/inputs/exploratory/proposals/.archive/architecture/proposal-lifecycle-surface-validation-hardening`

For each implemented child, require child-local evidence before the parent can
claim archive readiness:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`
- `support/proposal-closeout.md`
- `support/proposal-terminal-closeout.yml`

Parent closeout may summarize these child outcomes only by reference. It must
not rewrite, replace, satisfy, or authorize child manifests, receipts,
promotion targets, validators, archive metadata, rollback handles, cleanup
dispositions, or terminal outcomes.

## Pre-Closeout Gates

The parent closeout route may write a passing
`support/proposal-closeout.md` only when all of these conditions hold at
execution time:

- Separate route authorization explicitly permits parent closeout execution.
- Parent `proposal.yml` still records `status: implemented`.
- Parent proposal review is accepted, implementation prompt authorization is
  present, and the reviewed packet digest is current according to
  `validate-proposal-review-gate.sh`.
- Parent pre-integration architecture review has no unresolved items.
- `support/program-implementation-orchestration-conformance-review.md`
  exists and records `verdict: pass`, `unresolved_items_count: 0`,
  `child_receipt_summary_count: 20`, and
  `child_authority_preserved: yes`.
- `support/program-post-implementation-orchestration-drift-churn-review.md`
  exists and records `verdict: pass`, `unresolved_items_count: 0`,
  `child_receipt_summary_count: 20`, and
  `child_authority_preserved: yes`.
- Parent implementation orchestration run reports `verdict: pass`,
  `required_child_count: 5`, `terminal_child_count: 5`,
  `child_receipt_summary_count: 20`,
  `parent_summary_not_child_evidence: true`,
  `child_receipts_remain_child_owned: true`, and
  `child_authority_preserved: yes`.
- Retained parent workflow evidence points to the same parent receipt digest
  and records `status: pass`.
- Both parent checkpoints record all five required children as archived,
  completed, and terminal/verification/closeout gate true.
- Aggregate terminal blockers record `blocked_required_child_count: 0`.
- Every required child archive exists and has child-owned passing
  implementation-run, implementation-conformance, post-implementation
  drift/churn, validation, closeout, and terminal-closeout receipts.
- Child dependency gates still match `resources/child-packet-index.yml` and
  `architecture/packet-sequence.md`.
- The validated closeout-worktree return/report still matches the current
  residue fingerprint or the closeout route records a fresh, validated
  replacement disposition.
- Generated outputs, generated proposal metadata, and host projections remain
  derived-only and are refreshed only through canonical generators when a
  validator requires refresh.
- No durable target relies on parent proposal text, child proposal text,
  generated outputs, host state, dashboards, chat, or this prompt as authority.

If any gate fails, write a blocked parent closeout receipt or stop without
writing closeout evidence when route authorization is absent. Do not repair
child evidence, mutate parent status, or hand-edit generated outputs from this
closeout prompt.

## Required Validation

Run the parent validation floor immediately before closeout receipt
generation:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-lifecycle-surface-coherence
```

For each archived child packet, rerun the child validation floor:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child-archive-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <child-archive-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child-archive-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child-archive-path>
```

Validate the closeout-worktree disposition if parent closeout depends on
preserve/exclude worktree evidence:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-interaction-receipts.sh --return .octon/state/evidence/runs/workflows/lifecycle-proposal-program-1782852942821-fba365cc/lifecycle-interactions/parent-closeout-worktree-return.json
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh --report .octon/state/evidence/runs/skills/closeout-worktree/lifecycle-proposal-program-1782852942821-fba365cc-parent-worktree-handoff-current/parent-closeout-worktree-report.yml
```

Run generated and publication freshness checks only through canonical
validators or generators:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh
```

Use Bash 5 for validators that require modern Bash behavior. If `/bin/bash`
3.2 fails with shell-feature errors such as `declare: -A: invalid option`,
rerun with `/Users/jamesryancooper/.homebrew/bin/bash` and record the
interpreter correction in the closeout receipt.

## Required Parent Closeout Receipt

If parent closeout is separately authorized and all gates pass, write or
refresh only:

- `support/proposal-closeout.md`

The receipt must include at least these top-level fields:

```text
verdict: pass|blocked|fail
closed_at: <UTC timestamp>
proposal_id: proposal-program-lifecycle-surface-coherence
program_run_id: lifecycle-proposal-program-1782852942821-fba365cc
archive_authorized: yes|no
archive_disposition: implemented|blocked|not-authorized
child_authority_preserved: yes|no
child_closeout_count: <integer>
child_archive_authorized_count: <integer>
selected_git_route: <direct-main|branch-no-pr|branch-pr|stage-only-escalate|stage-only-no-git-action>
worktree_hygiene_verdict: pass|blocked|preserved-by-closeout-worktree|fail
worktree_hygiene_blocker_class: <class-or-none>
worktree_hygiene_owned_path_count: <integer>
worktree_hygiene_in_scope_path_count: <integer>
worktree_hygiene_foreign_path_count: <integer>
worktree_hygiene_foreign_fingerprint: <fingerprint-or-none>
worktree_hygiene_evidence: <path-or-summary>
closeout_worktree_report: <path-or-none>
lifecycle_interaction_return: <path-or-none>
cleanup_summary: <summary>
metadata_refreshed: yes|no
artifact_catalogs_refreshed: yes|no
proposal_artifact_indexes_refreshed: yes|no
proposal_registry_refreshed: yes|no
metadata_refresh_evidence: <paths-or-command-summary>
metadata_refresh_blocker_class: <class-or-none>
next_route_condition: <condition>
```

Use `verdict: pass`, `archive_authorized: yes`, and
`child_authority_preserved: yes` only when all required children have
child-owned terminal closeout and archive-ready evidence, both parent aggregate
receipts still pass, validation and freshness checks pass, worktree hygiene is
clean or has a validated non-mutating preserve/exclude disposition for the
selected route, and parent closeout evidence remains summary-only.

Use `verdict: blocked`, `archive_authorized: no`, and
`selected_git_route: stage-only-escalate` when any gate fails, route
authorization is missing, child authority would need to move into the parent,
metadata freshness cannot be proven, or worktree hygiene cannot be bounded.

## Hard Stops

Stop without passing parent closeout when any of these are true:

- Explicit route authorization for parent closeout execution is absent.
- Parent status would need mutation to make closeout pass.
- Either aggregate parent receipt is missing, failing, unresolved, stale, or
  does not preserve child authority.
- Any required child is missing archived packet state or child-owned
  implementation, conformance, drift/churn, validation, closeout, terminal
  closeout, archive, promotion, rollback, or cleanup evidence.
- Parent closeout depends on proposal-local inputs, generated projections,
  host state, dashboards, chat, tool availability, or agent output as
  authority.
- Generated output freshness is stale and cannot be refreshed through a
  canonical route.
- Worktree hygiene cannot distinguish intended parent closeout changes from
  unrelated tracked changes, retained evidence, active control state,
  generated outputs, local run residue, or manual-review paths.
- Git, PR, CI, review, merge, branch cleanup, local-main sync, archive, or
  Change closeout requirements remain unresolved for the selected route.

## Authority Boundary

Parent program closeout is coordination evidence only. Child packets preserve
their own manifests, promotion targets, validators, implementation evidence,
closeout receipts, archive metadata, terminal lifecycle outcomes, rollback
posture, and cleanup dispositions.

Generated proposal metadata, generated effective outputs, prompt artifacts,
raw inputs, host state, chat, dashboards, tool state, and model memory remain
non-authoritative. The separate archive route must perform any parent archive
mutation after successful closeout authorization and closeout receipt
retention.

## Final Answer Contract For Closeout Execution

When closeout is separately authorized and run, report:

- parent closeout receipt path and verdict;
- whether `archive_authorized` and `child_authority_preserved` are `yes`;
- selected Git/worktree route and lifecycle outcome;
- parent aggregate receipts consumed;
- child receipt summary and child-owned evidence refs;
- validators that passed, failed, or were blocked;
- retained evidence roots outside `inputs/**`;
- generated outputs refreshed, if any, and the canonical generator used;
- remaining blockers or `none`;
- whether parent lifecycle state, archive state, Git refs, cleanup state, or
  hosted provider state changed.

Do not claim the parent is archived. A separate archive route must validate
the retained closeout receipt before moving the parent packet.

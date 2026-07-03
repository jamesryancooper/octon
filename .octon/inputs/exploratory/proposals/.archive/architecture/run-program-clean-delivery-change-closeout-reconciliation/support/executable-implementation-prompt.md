# Executable Implementation Prompt

implementation_prompt_id: run-program-clean-delivery-change-closeout-reconciliation-implementation-prompt-2026-07-03
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation
route_id: run-packet-implementation
status: operational-aid

This prompt is an implementation aid for the accepted proposal packet. It does
not approve execution, widen promotion scope, create authority, replace packet
manifests, close out the packet, archive the packet, mutate Git refs, sync
branches, delete branches, publish generated outputs, or claim clean delivery.

## Generation Basis

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- packet review verdict: `accepted`
- implementation prompt authorization: `yes`
- reviewed packet digest:
  `sha256:8f44e8cdf83c58b12a46efa00823e546aa402650a8ee852dddab1afd75b62fd5`
- prompt bundle:
  `sha256:b2fc27e8e75f5e52971887e5bc440f17335fc4fe4303a630afa7148eea53efa6`

The implementation route must re-run the mandatory preflight gates before any
durable edit. Treat proposal-local files, generated prompts, generated
outputs, dashboards, host/tool/chat state, model memory, and parent summaries
as non-authoritative.

## Mandatory Preflight

Before editing durable targets, re-read the repository ingress, constitutional
kernel, proposal manifests, source-of-truth map, target architecture,
implementation plan, acceptance criteria, validation plan, implementation-grade
completeness review, proposal review, and strict pre-integration architecture
review.

Run from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation --require-implementation-authorization --print-digest
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation --mode pre-integration-architecture-review --require-pass
```

Refuse implementation unless all gates pass, the packet status remains
`accepted`, the accepted review digest is fresh, and
`open_blocking_findings_count: 0`.

## Approved Promotion Targets

Edit only these durable targets when edits are required:

- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

After durable edits land, create or update only these packet-local
implementation receipts:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Retained validation evidence must live outside `inputs/**`, preferably under:

- `.octon/state/evidence/validation/proposals/run-program-clean-delivery-change-closeout-reconciliation/`

## Out Of Scope

Do not edit proposal status, archive state, closeout state, generated/effective
outputs, support-target declarations, branch state, hosted refs, parent program
delivery state, unrelated child packets, sibling packet receipts, or local
cleanup residue.

Do not edit `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
unless this packet is revised to add that script as an approved promotion
target. If implementation cannot satisfy an acceptance criterion without
changing that validator or any other unapproved durable file, stop and report
`needs-packet-revision`.

Do not change `proposal.yml#status`; leave it as `accepted`. The later
promotion lifecycle route owns any implemented-status rewrite.

## Current Repository Starting Points

The live repository already contains the route-neutral Change closeout surface
that this packet must reuse:

- `closeout-change/SKILL.md` records the phase loop, proposal-program handoff
  boundary, hosted no-PR landing evidence, branch cleanup authorization, final
  local main sync, terminal current-state proof, and downgrade requirements.
- `default-work-unit.yml` separates selected route, target lifecycle outcome,
  and actual lifecycle outcome, and includes `published-branch`, `landed`, and
  `cleaned` evidence requirements.
- `change-closeout-state-machine.yml` binds inventory, validation,
  hosted-no-PR landing, PR-backed closeout, branch cleanup, receipt/evidence,
  final verification, and final report phases.
- `change-receipt-v1.schema.json` already models `target_lifecycle_outcome`,
  `lifecycle_outcome`, `integration_status`, `publication_status`,
  `cleanup_status`, `landing_authorization_ref`, `cleanup_authorization_ref`,
  `source_branch_integration`, `source_branch_cleanup`, `main_alignment`,
  terminal current-state proof, structured downgrade reasons, and
  stateful-closeout evidence.
- `validate-change-closeout-lifecycle-alignment.sh` and
  `validate-hosted-no-pr-landing.sh` already contain static and receipt-level
  checks for many branch publication, landing, authorization, cleanup, and
  sync rules.
- Existing receipt examples under
  `.octon/framework/product/contracts/examples/change-receipts/` include
  valid branch-local, published-branch, hosted branch-no-PR landed, direct-main
  landed, branch-PR ready, and invalid overclaim fixtures.

Before changing any target, inspect current diffs under the approved target
paths. The repository may already contain unrelated uncommitted edits under
`.octon/framework/assurance/runtime/_ops/tests/`; preserve them and integrate
without reverting user or earlier-agent work.

## Target End State

Change closeout is the single governed reconciliation path for terminal branch
publication, PR merge, hosted no-PR landing, local main sync, and branch
cleanup evidence. A clean-delivery terminal claim may cite Change closeout
evidence, but it cannot replace or summarize it into authority.

The durable surfaces must make these claims machine-checkable:

- branch publication is represented as `published-branch` or another lower
  nonterminal outcome unless landing evidence exists;
- PR-backed merge or hosted no-PR landing cannot be claimed without route-owned
  Change receipt evidence;
- local main sync must be represented by `main_alignment` evidence before
  `landed` or `cleaned` can be claimed;
- branch cleanup must be represented by cleanup disposition,
  `source_branch_cleanup`, cleanup evidence, and governed cleanup
  authorization when cleanup mutates refs;
- `cleaned` requires completed route-owned cleanup and sync evidence, plus
  terminal current-state proof when the policy requires it;
- host GitHub state, labels, comments, dashboards, chat narrative, generated
  summaries, parent delivery receipts, and proposal files remain evidence
  inputs or lineage only and cannot mint closeout authority.

## Ordered Workstreams

1. Inventory the current Change closeout surfaces.

   Run targeted reconnaissance:

   ```sh
   rg -n "target_lifecycle_outcome|lifecycle_outcome|published-branch|landed|cleaned|landing_authorization_ref|cleanup_authorization_ref|source_branch_integration|source_branch_cleanup|main_alignment|terminal_current_state_proof|not_landed_reason|not_cleaned_reason|GitHub|chat|host state" .octon/framework/capabilities/runtime/skills/remediation/closeout-change .octon/framework/product/contracts/default-work-unit.yml .octon/framework/product/contracts/change-closeout-state-machine.yml .octon/framework/product/contracts/change-receipt-v1.schema.json .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh .octon/framework/assurance/runtime/_ops/tests .octon/framework/product/contracts/examples/change-receipts
   ```

   Record which acceptance criteria are already satisfied by the current
   repository. Reuse existing schema fields, validators, examples, and test
   helpers before adding any new field or helper.

2. Complete the receipt-state contract only where gaps remain.

   Preserve the existing route-neutral model: `selected_route`,
   `target_lifecycle_outcome`, `lifecycle_outcome`, `integration_status`,
   `publication_status`, `cleanup_status`, and stateful-closeout evidence are
   separate facts.

   If the existing schema cannot represent a required publication, merge, sync,
   or cleanup state, add the smallest schema extension under the existing
   Change receipt contract. Do not add a parallel clean-delivery receipt,
   proposal-program-specific closeout schema, generated projection, or
   proposal-local runtime dependency.

3. Align policy, state machine, and skill text.

   Update only the existing closeout-change skill, default work-unit policy,
   and Change closeout state machine as needed so they agree on:

   - pushed branch publication is not landed or completed closeout;
   - PR merge and hosted no-PR landing are route-specific evidence paths;
   - branch-based `landed` requires source-branch integration, post-landing
     fetch, local main sync, origin/main and local main containment of the
     landed ref, rollback evidence, and stateful-closeout evidence;
   - branch-based `cleaned` additionally requires governed cleanup
     authorization when cleanup mutates refs, cleanup evidence, cleanup
     disposition, final sync, and any required terminal proof;
   - missing landing, sync, cleanup, authorization, terminal proof, or
     publishable evidence downgrades the actual outcome and records structured
     `not_landed_reason`, `landing_stop_reason`, `not_cleaned_reason`, or
     `cleanup_stop_reason` where applicable;
   - proposal-program delivery may pass context and cite returned closeout
     evidence, but cannot replace Change receipts, final sync proof, cleanup
     authorization, terminal proof, or route-owned validation.

4. Tighten `validate-change-closeout-lifecycle-alignment.sh`.

   Prefer extending existing receipt-level checks and example fixtures. The
   validator must reject at least these overclaims:

   - pushed-only branch evidence claimed as landed or completed closeout;
   - PR-backed or branch-no-PR landing claimed without matching route evidence;
   - `landed` or `cleaned` claimed without source-branch integration,
     post-landing fetch, local main sync, and main alignment evidence;
   - `cleaned` claimed while cleanup is pending, deferred, missing, or lacks a
     validating cleanup authorization when cleanup mutates refs;
   - target `landed` or `cleaned` downgraded without the required structured
     blocker reasons;
   - terminal proof used as authorization, packet evidence, generated
     publication evidence, or a substitute for landed ref, cleanup, sync, or
     route-owned validation;
   - host state, GitHub narrative, chat, generated outputs, parent summaries,
     or proposal-local files satisfying Change closeout evidence fields.

   If these cases already pass or fail correctly, preserve the logic and add
   only the missing tests or documentation alignment needed to prove coverage.

5. Tighten `validate-hosted-no-pr-landing.sh`.

   Keep this validator focused on hosted no-PR landing evidence. Ensure it
   rejects local checkpoints, pushed-only branches, missing hosted landing
   blocks, missing or stale landing authorization, missing exact source-SHA
   checks or explicit empty-check-set rationale, missing source-branch
   integration, and missing local main sync evidence for landing claims.

6. Add positive and negative controls.

   Extend existing tests under `.octon/framework/assurance/runtime/_ops/tests/`
   rather than creating a new harness unless reuse is not viable.

   Required positive controls:

   - existing static alignment checks pass;
   - valid branch-local and published-branch fixtures remain accepted only as
     nonterminal handoff or continuation outcomes;
   - valid hosted branch-no-PR landed fixture passes with authorization,
     integration, sync, and cleanup disposition evidence;
   - valid cleaned fixture or generated test receipt passes only when cleanup,
     final sync, stateful closeout, publishable evidence, and any required
     terminal proof are present.

   Required negative controls:

   - merge, landing, local main sync, or cleanup claim without matching Change
     receipt evidence fails;
   - host state, GitHub labels/comments, dashboards, chat narrative, generated
     projection, parent delivery receipt, or proposal file substitution fails;
   - pushed-only branch claimed as landed fails;
   - branch cleanup without governed cleanup authorization fails;
   - cleaned outcome with deferred or pending cleanup fails;
   - target cleaned downgraded without `not_cleaned_reason` and
     `cleanup_stop_reason` fails.

7. Record retained evidence and packet-local receipts.

   Create retained evidence under
   `.octon/state/evidence/validation/proposals/run-program-clean-delivery-change-closeout-reconciliation/`
   with:

   - implementation timestamp;
   - exact files changed;
   - diff summary;
   - targeted reconnaissance results;
   - validator commands, exit codes, and compact output excerpts;
   - any acceptance criterion already satisfied by pre-existing repository
     state;
   - any unimplemented criterion routed to `needs-packet-revision`.

   Then create the packet-local receipts listed in the Approved Promotion
   Targets section.

## Validation

Run the focused validation floor from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-state-machine.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-hosted-no-pr-landing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation --mode pre-integration-architecture-review --require-pass
```

If implementation touches tests that exercise clean-delivery wrapper behavior,
also run:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh
```

After implementation, create the required post-implementation receipts and run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation
```

Refuse implemented, closeout, or archive-ready claims until both receipts exist
and both post-implementation validators pass.

## Required Receipts

`support/implementation-run.md` must summarize the durable edits, list
promotion targets touched, cite retained validation evidence, map each
acceptance criterion to implementation or pre-existing coverage, and state
whether any criterion was blocked by the approved target boundary.

`support/implementation-conformance-review.md` must cover checked evidence,
promotion target coverage, implementation map coverage, validator coverage,
generated output coverage, governed mechanism integration coverage, rollback
coverage, downstream reference coverage, exclusions, and final closeout
recommendation. It must conclude with `verdict: pass` and
`unresolved_items_count: 0` before implementation can be considered complete.

`support/post-implementation-drift-churn-review.md` must cover backreference
scan, naming drift, generated projection freshness, manifest and schema
validity, repo-local projection boundaries, target family boundaries, churn
review, validators run, exclusions, and final closeout recommendation. It must
conclude with `verdict: pass` and `unresolved_items_count: 0` before closeout
or archive can be considered.

`support/validation.md` must list exact commands, cwd, start/end time or
timestamp, exit code, retained evidence path where used, and compact output
summary.

## Delegation Boundaries

No delegation is required. If the implementation runner explicitly delegates,
use disjoint write scopes only:

- policy, state machine, and closeout skill alignment;
- Change receipt schema and validator logic;
- shell test fixtures and examples;
- packet-local receipts and retained validation evidence.

The orchestrator remains responsible for final integration and must not let a
delegated worker widen scope, edit sibling packets, mutate generated outputs as
authority, edit unapproved durable targets, delete unrelated state/control or
evidence artifacts, or revert existing unrelated worktree changes.

## Rollback

Rollback is limited to the durable edits made under the approved promotion
targets. Revert or supersede validator, schema, policy, state-machine, skill,
or test changes through a governed correction route, then rerun the proposal
review gate and both post-implementation validators. Packet-local evidence
should be superseded by a new correction or rollback receipt, not silently
deleted.

## Closeout Refusal Criteria

Refuse closeout, archive, cleanup, parent delivery completion, branch
publication, hosted landing, merge, local main sync, branch deletion, remote
cleanup, generated publication, or `git_clean_terminal` claims from this
implementation route.

Also refuse implementation completion if any prerequisite proposal review,
strict pre-integration architecture review, implementation conformance review,
post-implementation drift/churn review, Change closeout validator, hosted
no-PR landing validator, or required test is missing, stale, failing, or still
requires clarification.

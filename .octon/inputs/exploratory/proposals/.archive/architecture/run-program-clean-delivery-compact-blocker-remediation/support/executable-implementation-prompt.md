# Executable Implementation Prompt

implementation_prompt_id: run-program-clean-delivery-compact-blocker-remediation-implementation-prompt-2026-07-03
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation
route_id: run-packet-implementation
status: operational-aid

This prompt is an implementation aid for the accepted child proposal packet. It
does not approve execution, widen promotion scope, create authority, replace
packet manifests, close out the packet, archive the packet, mutate Git state,
publish generated output, authorize cleanup, or claim clean delivery.

## Generation Basis

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- packet review verdict: `accepted`
- implementation prompt authorization: `yes`
- reviewed packet digest:
  `sha256:0522fb38f136fe7833f9d1b9b79ac431f3eacfba006d20e7d1f3b36501755c28`
- prompt bundle:
  `sha256:b2fc27e8e75f5e52971887e5bc440f17335fc4fe4303a630afa7148eea53efa6`

The implementation route must re-run the mandatory preflight gates before any
durable edit. Treat proposal-local files, generated prompts, generated outputs,
dashboards, host/tool/chat state, model memory, parent summaries, and compact
summaries as non-authoritative.

## Mandatory Preflight

Before editing durable targets, re-read the repository ingress, constitutional
kernel, proposal manifests, source-of-truth map, target architecture,
implementation plan, acceptance criteria, validation plan,
implementation-grade completeness review, proposal review, and strict
pre-integration architecture review.

Run from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation --mode pre-integration-architecture-review --require-pass
```

Refuse implementation unless all gates pass, `proposal.yml#status` remains
`accepted`, the accepted review digest is fresh, the completeness review has
`verdict: pass`, `clarification_required: no`, and
`unresolved_questions_count: 0`, and the review has
`open_blocking_findings_count: 0`.

## Approved Promotion Targets

Edit only these durable targets when edits are required:

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
- `.octon/framework/product/contracts/proposal-program-delivery-profile-v1.schema.json`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

After durable edits land, create or update only these packet-local
implementation receipts:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Retained validation evidence must live outside `inputs/**`, preferably under:

- `.octon/state/evidence/validation/proposals/run-program-clean-delivery-compact-blocker-remediation/`

## Out Of Scope

Do not edit proposal status, sibling child packets, parent program delivery
state, archive state, closeout state, generated/effective outputs,
support-target declarations, branch state, hosted refs, or local cleanup
residue.

Do not add a duplicate proposal-program delivery route, duplicate lifecycle
runner, duplicate clean-delivery validator, or parallel compact evidence
authority surface. If the acceptance criteria cannot be satisfied inside the
approved promotion targets, stop and report `needs-packet-revision`.

Do not change `proposal.yml#status`; leave it as `accepted`. The later
promotion lifecycle route owns any implemented-status rewrite.

## Target End State

The program lifecycle runner has compact blocker-remediation behavior for
recoverable blocker retries. It tracks an artifact budget with three trigger
signals:

- repeated identical blocker fingerprints;
- repeated full workflow directory emission beyond a configurable threshold;
- file-count or total-byte budget breach.

When a trigger fires, the lifecycle must stop producing duplicate full
workflow artifact trees and write compact remediation evidence instead. Compact
mode must preserve enough evidence to rerun gates and debug failures:

- one current compact blocker-remediation receipt;
- one bounded validation or raw-log summary;
- digest references to retained full evidence when full evidence is required;
- blocker class, current fingerprint, prior matching fingerprint, budget
  state, retained evidence refs, and next route;
- explicit fail-closed status when compacting would lose required evidence or
  the blocker cannot be classified, preserved, or routed safely.

Repeated full workflow directory emission fails closed for the full-output
path, not for the lifecycle itself. The lifecycle may continue in compact mode
only when required evidence remains preserved and a route-owned recovery path
proves safe.

## Current Repo Observations

The current lifecycle runner already contains compact evidence and recovery
structures such as compact evidence indexes, raw-log summaries, failing-slice
manifests, blocker ledgers, recovery delta summaries, retry fingerprint inputs,
recovery budgets, and token ceilings. Inspect and reuse those surfaces before
adding new structures. The likely implementation is to extend, connect, or
validate those existing surfaces, not to create a second compact evidence
model.

The current clean-delivery validator primarily checks the validator chain and,
when given a delivery receipt, the cleaned outcome and related receipt/index
invariants. Extend it with the packet's compact blocker-remediation budget
checks and fixtures without weakening existing clean-delivery receipt checks.

## Ordered Workstreams

1. Inventory the current compact and blocker surfaces.

   Run targeted reconnaissance:

   ```sh
   rg -n "compact|blocker|fingerprint|budget|threshold|raw-log|failing-slice|recovery_delta|token_ceiling|clean-delivery" .octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs .octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery .octon/framework/product/contracts/proposal-program-delivery-profile-v1.schema.json .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh .octon/framework/assurance/runtime/_ops/tests
   ```

   Record the result in retained validation evidence. Reuse existing workflow,
   schema, validator, fixture, and runner patterns. Do not add a parallel
   lifecycle artifact family when an existing compact evidence surface can be
   extended.

2. Add artifact-budget policy to the delivery profile.

   Extend `.octon/framework/product/contracts/proposal-program-delivery-profile-v1.schema.json`
   only as needed to admit compact blocker-remediation budget configuration.
   The profile may configure thresholds and policy requirements, but it must
   not become child-owned lifecycle truth or a substitute for route receipts.

   Required semantics:

   - repeated blocker fingerprint threshold is explicit and nonzero;
   - repeated full workflow directory threshold is explicit and nonzero;
   - file-count and total-byte budget limits are explicit when configured;
   - compact continuation requires retained evidence preservation;
   - compact continuation is denied when required receipts, full evidence, or
     route-owned recovery proof would be lost.

3. Implement compact blocker-remediation in the lifecycle runner.

   In `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`,
   connect existing blocker fingerprints, recovery budgets, compact evidence
   artifacts, and event/checkpoint metadata so repeated recoverable blockers
   switch from duplicate full-output emission to compact remediation evidence.

   Required receipt fields:

   - schema version and producer;
   - run id, lifecycle id, target, child id when applicable, route id, and
     blocker class;
   - trigger kind: repeated fingerprint, repeated full workflow directory,
     file count, byte count, or combined budget;
   - current fingerprint and prior matching fingerprint;
   - budget snapshot: limits, observed counts or bytes, attempts used,
     remaining attempts, and exhausted flag;
   - retained evidence refs plus digests for source full evidence when needed;
   - bounded log summary ref;
   - next route or explicit human-review requirement;
   - authority-boundary notice that compact evidence is evidence-only and does
     not replace child packet, parent delivery, archive, cleanup, Change,
     generated-publication, branch cleanup, or terminal proof receipts.

   Required behavior:

   - repeated identical blocker fingerprints produce a compact delta receipt,
     not another duplicate full workflow tree;
   - repeated full workflow directory emission fails closed after the
     configured threshold and switches to compact mode only when continuation
     is safe;
   - file-count and byte-budget breaches throttle artifact production and
     continue only when required evidence remains preserved;
   - unclassified blockers, unsafe route ownership, missing retained evidence,
     or evidence-loss risk stop in a human-review or blocked state;
   - compact summaries never become policy, runtime, closeout, archive,
     delivery, or support authority.

4. Update Proposal Program Delivery workflow wording.

   Update only the existing files under
   `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
   that need compact blocker-remediation language. Keep the workflow explicit
   that:

   - compact remediation handles recoverable retry artifact budgets only;
   - lifecycle postmortem or blocker threshold status is recorded when budget
     triggers apply;
   - parent summaries, aggregate receipts, compact summaries, generated
     outputs, host state, chat, and model memory do not satisfy child-owned
     receipts;
   - open blockers still prevent downstream outcome claims.

5. Extend clean-delivery validation.

   Update `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
   so static mode still validates the existing validator chain and receipt mode
   keeps all current cleaned-outcome checks. Add compact blocker-remediation
   validation coverage that can prove:

   - compact budget fields are present where configured;
   - repeated fingerprint, repeated full-directory, file-count, and byte-count
     trigger receipts have the required fields;
   - retained evidence refs and digests are present when full evidence is
     required;
   - compact mode is rejected when evidence would be lost;
   - compact evidence is explicitly evidence-only and non-authoritative.

6. Add positive and negative controls.

   Extend existing tests under `.octon/framework/assurance/runtime/_ops/tests/`
   rather than creating a new harness unless reuse is not viable.

   Required positive controls:

   - repeated identical blocker fingerprint emits or validates a compact delta
     receipt rather than another full workflow tree;
   - repeated full workflow directory threshold switches to compact mode when
     continuation is safe;
   - file-count budget breach throttles artifact output while preserving
     required evidence;
   - byte-budget breach throttles artifact output while preserving required
     evidence;
   - existing clean-delivery validator-chain and cleaned-receipt checks still
     pass.

   Required negative controls:

   - compact continuation fails when required receipts would be lost;
   - compact continuation fails when required full evidence refs or digests are
     absent;
   - compact continuation fails when the blocker cannot be classified or routed
     safely;
   - compact summaries or generated outputs fail if used as child-owned
     receipts, delivery authority, archive authority, cleanup authority,
     Change closeout authority, or terminal proof;
   - repeated full-output emission beyond threshold fails closed instead of
     silently producing another duplicate tree.

7. Record retained evidence and packet-local receipts.

   Create retained evidence under
   `.octon/state/evidence/validation/proposals/run-program-clean-delivery-compact-blocker-remediation/`
   with:

   - implementation timestamp;
   - exact files changed;
   - diff summary;
   - commands run and exit status;
   - positive and negative control summary;
   - compact budget trigger coverage;
   - authority-boundary and evidence-preservation notes;
   - rollback posture.

   Then create or update `support/implementation-run.md` with `verdict`,
   `implemented_at`, `promotion_evidence_count`, durable changes, validators
   run, retained evidence refs, blockers, and scope notes.

8. Make post-implementation gates executable.

   Create or update `support/implementation-conformance-review.md` with:

   - `verdict: pass|fail`
   - `unresolved_items_count`
   - sections named `Blockers`, `Checked Evidence`, `Promotion Target
     Coverage`, `Implementation Map Coverage`, `Validator Coverage`,
     `Generated Output Coverage`, `Rollback Coverage`, `Downstream Reference
     Coverage`, `Exclusions`, and `Final Closeout Recommendation`

   Then run:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation
   ```

   Create or update `support/post-implementation-drift-churn-review.md` with:

   - `verdict: pass|fail`
   - `unresolved_items_count`
   - sections named `Blockers`, `Checked Evidence`, `Backreference Scan`,
     `Naming Drift`, `Generated Projection Freshness`, `Manifest And Schema
     Validity`, `Repo-Local Projection Boundaries`, `Target Family Boundaries`,
     `Churn Review`, `Validators Run`, `Exclusions`, and `Final Closeout
     Recommendation`

   Then run:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation
   ```

## Required Validators

Run the focused implementation validators from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery-profile.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation --mode pre-integration-architecture-review --require-pass
```

After packet-local implementation receipts are written, also run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation
```

If a required command fails because the current worktree contains unrelated
pre-existing changes, record the exact failure and classify whether it blocks
this packet's scope. Do not revert unrelated worktree changes.

## Rollback Posture

Rollback is target-scoped and atomic. If implementation hides required
evidence, permits compact continuation without retained evidence, creates a
parallel authority surface, weakens clean-delivery validation, or cannot
satisfy negative controls inside the approved target set, revert only the task
edits in those targets, retain failed validation evidence, write
`support/implementation-run.md` with `verdict: fail`, and report the route as
blocked or `needs-packet-revision`.

Do not delete retained evidence or local residue. Cleanup remains owned by the
repo hygiene cleanup route.

## Delegation Boundary

Delegation is optional. If used, split by disjoint write scope:

- lifecycle-runner worker:
  `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`;
- workflow/profile worker:
  `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
  and `.octon/framework/product/contracts/proposal-program-delivery-profile-v1.schema.json`;
- validator/test/evidence owner:
  `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`,
  `.octon/framework/assurance/runtime/_ops/tests/`, retained validation
  evidence, packet-local receipts, and final validator run.

Delegation does not change authority. The implementation owner remains
accountable for scope, validation, receipts, and fail-closed decisions.

## Terminal Criteria

The implementation route may report success only when all of these are true:

- durable edits are limited to the approved promotion targets;
- repeated fingerprint, repeated full-directory threshold, file-count budget,
  byte-budget, and evidence-loss negative controls are implemented and pass;
- retained validation evidence exists outside `inputs/**`;
- compact evidence preserves required full-evidence refs and digests when
  needed;
- compact evidence is explicitly evidence-only and non-authoritative;
- `support/implementation-run.md` exists with `verdict: pass`,
  `implemented_at`, retained evidence refs, and a numeric
  `promotion_evidence_count`;
- `support/implementation-conformance-review.md` exists and
  `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation`
  passes;
- `support/post-implementation-drift-churn-review.md` exists and
  `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-compact-blocker-remediation`
  passes;
- `proposal.yml#status` remains `accepted`;
- no closeout, archive-ready, implemented-status, branch-cleanup, cleanup, or
  git-clean-terminal claim is made by this route.

Refuse closeout and archive claims while either post-implementation receipt is
missing, failing, unresolved, stale, or blocked. The later verification,
correction, promote, closeout, archive, delivery, and cleanup routes own those
lifecycle claims.

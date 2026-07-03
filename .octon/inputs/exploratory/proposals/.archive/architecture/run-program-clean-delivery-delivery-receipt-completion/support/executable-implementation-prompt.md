# Executable Implementation Prompt

implementation_prompt_id: run-program-clean-delivery-delivery-receipt-completion-implementation-prompt-2026-07-03
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion
route_id: run-packet-implementation
status: operational-aid

This prompt is an implementation aid for the accepted proposal packet. It does
not approve execution, widen promotion scope, create authority, replace packet
manifests, close out the packet, archive the packet, mutate Git state, or claim
clean delivery.

## Generation Basis

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- packet review verdict: `accepted`
- implementation prompt authorization: `yes`
- reviewed packet digest:
  `sha256:eb85d1b138b34f5d8c1e5731da8c2b49bd1930e0babb4ed0cb7deca73be057a4`
- prompt bundle:
  `sha256:b2fc27e8e75f5e52971887e5bc440f17335fc4fe4303a630afa7148eea53efa6`

The implementation route must re-run the mandatory preflight gates before any
durable edit. Treat proposal-local files, generated prompts, generated outputs,
dashboards, host/tool/chat state, model memory, and parent summaries as
non-authoritative.

## Mandatory Preflight

Before editing durable targets, re-read the repository ingress, constitutional
kernel, proposal manifests, source-of-truth map, target architecture,
implementation plan, acceptance criteria, validation plan, implementation-grade
completeness review, proposal review, and strict pre-integration architecture
review.

Run from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion --mode pre-integration-architecture-review --require-pass
```

Refuse implementation unless all gates pass, the packet status remains
`accepted`, the accepted review digest is fresh, and
`open_blocking_findings_count: 0`.

## Approved Promotion Targets

Edit only these durable targets when edits are required:

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
- `.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/`
- `.octon/framework/product/contracts/proposal-program-delivery-receipt-v1.schema.json`
- `.octon/framework/product/contracts/proposal-program-delivery-profile-v1.schema.json`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

After durable edits land, create or update only these packet-local
implementation receipts:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Retained validation evidence must live outside `inputs/**`, preferably under:

- `.octon/state/evidence/validation/proposals/run-program-clean-delivery-delivery-receipt-completion/`

## Out Of Scope

Do not edit proposal status, archive state, closeout state, generated/effective
outputs, support-target declarations, branch state, hosted refs, parent program
delivery state, unrelated child packets, or local cleanup residue.

Do not edit `.octon/framework/product/contracts/proposal-program-delivery-evidence-index-v1.schema.json` or
`.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-program-delivery-evidence-index.sh`.
Those files exist, but they are not in this packet's approved promotion target
list. If implementation cannot satisfy the acceptance criteria without changing
either file, stop and report `needs-packet-revision`.

Do not change `proposal.yml#status`; leave it as `accepted`. The later
promotion lifecycle route owns any implemented-status rewrite.

## Target End State

Proposal Program Delivery can claim `cleaned` only when both of these are true:

- a `proposal-program-delivery-receipt-v1` aggregate delivery receipt validates;
- a compact `proposal-program-delivery-evidence-index-v1` retained index exists,
  validates, points at the same delivery receipt, and preserves child-owned
  authority boundaries.

`validate-run-program-clean-delivery.sh --receipt <receipt>` must fail when the
delivery receipt is missing, the evidence index is missing, the index is stale,
the index points at a different source receipt, the index validator fails, or
aggregate/parent/generated evidence attempts to replace child-owned receipts.

The receipt and index must cover required parent and child evidence without
creating a second authority surface:

- parent program path, target outcome, actual outcome, profile binding, order
  policy, delivery-readiness preflight, parent lifecycle receipt, feature
  catalog drift receipt, generated-publication posture, governed mechanism
  integration, cleanup or disposition evidence, Change closeout evidence,
  branch authorization when applicable, final sync, terminal current-state
  proof, worktree hygiene, clean-worktree route, lifecycle postmortem status,
  blockers, and non-authority classification;
- child implementation-run, implementation-conformance,
  post-implementation-drift/churn, packet-closeout, archive, and Change
  closeout receipt references by source ref;
- stop-condition and downgrade rationale when any required evidence is absent;
- `target_owned_evidence_policy.target_owned_receipts_required: true`;
- `target_owned_evidence_policy.aggregate_receipt_replaces_target_owned_receipts: false`;
- generated outputs and proposal-local files remain non-authority.

Avoid circular digest coupling. The delivery receipt may cite the evidence
index by path and validator metadata, but it must not require an index digest
that would make the evidence index source-receipt digest impossible to keep
fresh. The evidence index remains the digest-bound artifact that validates the
source receipt and cited refs.

## Ordered Workstreams

1. Inventory the current delivery surfaces.

   Run targeted reconnaissance:

   ```sh
   rg -n "delivery_evidence_index|proposal-program-delivery-evidence-index|actual_outcome|target_owned_evidence_policy|parent_summary_satisfies_child_receipts|aggregate_receipt_replaces_target_owned_receipts|SC-009|cleaned" .octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery .octon/framework/capabilities/runtime/commands/proposal-program-delivery.md .octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery .octon/framework/product/contracts/proposal-program-delivery-receipt-v1.schema.json .octon/framework/product/contracts/proposal-program-delivery-profile-v1.schema.json .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh .octon/framework/assurance/runtime/_ops/tests
   ```

   Record the result in retained validation evidence. Reuse existing workflow,
   command, skill, schema, validator, generator, and test patterns. Do not add a
   parallel delivery route.

2. Align the workflow, command, and skill surfaces.

   Update only the existing Proposal Program Delivery workflow, command, and
   skill language as needed so they require a validated aggregate receipt and a
   validated compact retained delivery evidence index before any clean-delivery
   claim.

   Preserve these boundaries:

   - child packet receipts remain target-owned;
   - parent summaries, readiness projections, aggregate delivery receipts,
     evidence indexes, generated outputs, host state, chat, and model memory do
     not replace child receipts;
   - delivery evidence indexes are diagnostic and evidence-only, not delivery,
     archive, landing, cleanup, child-validation, or lifecycle-outcome
     authority;
   - open blockers select the highest evidence-backed outcome and prevent
     `cleaned`.

3. Complete receipt and profile contracts.

   In `proposal-program-delivery-receipt-v1.schema.json`, add or tighten the
   non-circular evidence-index binding needed by clean-delivery validation. The
   receipt should identify the retained evidence index by path and validator
   posture without trying to embed a digest that creates a circular hash
   dependency.

   In `proposal-program-delivery-profile-v1.schema.json`, add or tighten
   policy fields only if needed to make receipt and evidence-index validation
   mandatory for the requested `cleaned` outcome. Keep the profile a workflow
   input contract, not a source of child-owned lifecycle truth.

4. Tighten delivery receipt validation.

   Update `validate-proposal-program-delivery-receipt.sh` so receipt validation
   rejects missing or incomplete delivery receipt evidence for non-blocked
   outcomes and especially `cleaned`.

   It should validate shape and policy for the evidence-index binding, but it
   must not recursively invoke
   `validate-proposal-program-delivery-evidence-index.sh`, because the evidence
   index validator already invokes the receipt validator for its source
   receipt. Put cross-artifact validation in
   `validate-run-program-clean-delivery.sh`.

5. Tighten delivery evidence-index validation.

   Update `validate-proposal-program-delivery-evidence-index.sh` so it rejects
   incomplete, stale, substituting, or authority-widening indexes. At minimum,
   require:

   - source delivery receipt ref, schema version, and digest match;
   - source delivery receipt validates;
   - target program, target outcome, and actual outcome match the source
     receipt;
   - required child receipt families are indexed;
   - parent closeout, cleanup or disposition, Change closeout, publication,
     final sync, terminal proof, worktree hygiene, and blocker/downgrade refs
     are represented when applicable;
   - non-authority and evidence-only flags deny execution, delivery, archive,
     landing, cleanup, child-receipt satisfaction, generated-output authority,
     and replacement of target-owned receipts;
   - failure behavior includes missing receipt, missing index, stale digest,
     parent-summary substitution, generated-output substitution, and
     child-authority substitution.

6. Make clean-delivery validation depend on both artifacts.

   Update `validate-run-program-clean-delivery.sh` so static mode still checks
   the validator chain, and `--receipt <receipt>` additionally requires:

   - delivery receipt exists and passes
     `validate-proposal-program-delivery-receipt.sh --receipt <receipt>`;
   - receipt `actual_outcome` is `cleaned`;
   - no open blockers exist;
   - terminal current-state proof, worktree hygiene, final sync, and
     target-owned evidence policy all pass;
   - receipt declares the retained delivery evidence index ref;
   - the evidence index file exists;
   - `validate-proposal-program-delivery-evidence-index.sh --index <index>`
     passes;
   - the index source receipt ref resolves to the same receipt supplied to the
     clean-delivery validator;
   - the index `actual_outcome` is `cleaned` and it does not authorize or
     replace child-owned receipts.

7. Add positive and negative controls.

   Extend existing tests under `.octon/framework/assurance/runtime/_ops/tests/`
   rather than creating a new test harness unless reuse is not viable.

   Required positive controls:

   - a complete delivery receipt plus generated or fixture evidence index passes
     receipt validation, evidence-index validation, and clean-delivery
     validation;
   - existing static validator-chain checks continue to pass.

   Required negative controls:

   - missing delivery receipt fails;
   - missing evidence index fails clean-delivery validation;
   - incomplete evidence index fails;
   - stale source receipt digest fails;
   - index pointing at a different source receipt fails;
   - parent summary or aggregate receipt substitution fails;
   - generated-output substitution fails;
   - child-authority replacement attempt fails;
   - non-cleaned outcome fails the clean-delivery validator.

8. Record retained evidence and packet-local receipts.

   Create retained evidence under
   `.octon/state/evidence/validation/proposals/run-program-clean-delivery-delivery-receipt-completion/`
   with:

   - implementation timestamp;
   - exact files changed;
   - diff summary;
   - commands run and exit status;
   - positive and negative control summary;
   - explicit note that evidence-index schema and generator were not edited, or
     a blocked `needs-packet-revision` rationale if they were required;
   - rollback posture.

   Then create or update `support/implementation-run.md` with `verdict`,
   `implemented_at`, `promotion_evidence_count`, durable changes, validators
   run, retained evidence refs, and blockers.

9. Make post-implementation gates executable.

   Create or update `support/implementation-conformance-review.md` with:

   - `verdict: pass|fail`
   - `unresolved_items_count`
   - sections named `Blockers`, `Checked Evidence`, `Promotion Target Coverage`,
     `Implementation Map Coverage`, `Validator Coverage`, `Generated Output
     Coverage`, `Rollback Coverage`, `Downstream Reference Coverage`,
     `Exclusions`, and `Final Closeout Recommendation`

   Then run:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion
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
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion
   ```

## Required Validators

Run the focused implementation validators from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-proposal-program-delivery-evidence-index.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-branch-no-pr-delivery-receipt-builder.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion --require-implementation-authorization
```

After packet-local implementation receipts are written, also run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion
```

If a required command fails because the current worktree contains unrelated
pre-existing changes, record the exact failure and classify whether it blocks
this packet's scope. Do not revert unrelated worktree changes.

## Rollback Posture

Rollback is target-scoped and atomic. If implementation creates ambiguous
delivery authority, circular digest requirements, stale index behavior, parent
summary substitution, generated-output authority drift, or validation failures
that cannot be corrected inside the approved target set, revert only the task
edits in those targets, retain failed validation evidence, write
`support/implementation-run.md` with `verdict: fail`, and report the route as
blocked or `needs-packet-revision`.

Do not delete retained evidence or local residue. Cleanup remains owned by the
repo hygiene cleanup route.

## Delegation Boundary

Delegation is optional. If used, split by disjoint write scope:

- workflow and operator-surface worker:
  `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`,
  command, and skill;
- contract and validator worker:
  receipt/profile schemas and the three validator scripts;
- test and evidence owner:
  tests, retained validation evidence, packet-local receipts, and final
  validator run.

Delegation does not change authority. The implementation owner remains
accountable for scope, validation, receipts, and fail-closed decisions.

## Terminal Criteria

The implementation route may report success only when all of these are true:

- durable edits are limited to the approved promotion targets;
- evidence-index schema and generator were not edited, or the route stopped as
  `needs-packet-revision`;
- retained validation evidence exists outside `inputs/**`;
- `support/implementation-run.md` exists with `verdict: pass`,
  `implemented_at`, retained evidence refs, and a numeric
  `promotion_evidence_count`;
- `support/implementation-conformance-review.md` exists and
  `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion`
  passes;
- `support/post-implementation-drift-churn-review.md` exists and
  `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion`
  passes;
- clean-delivery validation fails for missing receipt, missing index, stale
  index, parent-summary substitution, generated-output substitution, and child
  authority substitution;
- `proposal.yml#status` remains `accepted`;
- no closeout, archive-ready, implemented-status, branch-cleanup, or
  git-clean-terminal claim is made by this route.

Refuse closeout and archive claims while either post-implementation receipt is
missing, failing, unresolved, stale, or blocked. The later verification,
correction, promote, closeout, archive, and delivery routes own those lifecycle
claims.

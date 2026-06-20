# Executable Implementation Prompt

proposal: `.octon/inputs/exploratory/proposals/architecture/generated-freshness-scope-detection`
route: `octon-proposal-lifecycle-run-packet-implementation`
status_precondition: `accepted`
implementation_authorization: `support/proposal-review.md`

## Scope

Implement only the generated freshness scope detection behavior approved for
this child packet. The durable implementation write scope is limited to:

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-support-envelope-reconciliation.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-support-envelope-reconciliation.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh`

Proposal-local evidence writes are limited to this packet's `support/`
directory. Do not modify the parent program lifecycle state. Do not implement
receipt semantics, branch-no-PR closeout, worktree cleanup, git mutation
preflight, parent promotion, parent closeout, archive, publication, landing,
deletion, branch cleanup, or a `cleaned` claim.

## Required Work

1. Read the packet manifest, architecture proposal, source-of-truth map,
   artifact catalog, implementation plan, acceptance criteria, completeness
   review, proposal review, strict architecture review receipt, and this
   prompt.
2. Inspect the current proposal-packet-delivery workflow and the existing
   support-envelope, run-health, and generated non-authority scripts.
3. Update proposal-packet-delivery workflow stages so generated-input scope is
   classified before terminal closeout/archive routing and the route records
   one of these outcomes:
   - generated freshness not in scope;
   - generated-input scope detected and owner-routed;
   - generated refresh needed but not authorized;
   - generated output present but stale;
   - generated output fresh but non-authoritative.
4. Bind support-envelope and run-health read-model refresh to their owning
   generator scripts. The workflow may summarize generator/read-model receipt
   state, but generated outputs and aggregate delivery receipts must never
   replace target-owned freshness, validation, or closeout receipts.
5. Update generated freshness validators so stale generated outputs fail the
   relevant terminal delivery claim, fresh generated outputs remain explicitly
   non-authoritative, and proposal-local or parent evidence cannot satisfy
   generated publication or closeout evidence.
6. Add or update negative controls inside the existing validator scripts or
   their existing test-discovered fixture paths only if those paths are already
   owned by the declared promotion targets. If the needed fixture or test path
   is outside the declared promotion targets, stop and report a scope blocker.

## Validation Commands

Run the child lifecycle gates and implementation validators from the repository
root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/generated-freshness-scope-detection --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/generated-freshness-scope-detection
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/generated-freshness-scope-detection
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/generated-freshness-scope-detection --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/generated-freshness-scope-detection/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/generated-freshness-scope-detection --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-support-envelope-reconciliation.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/generated-freshness-scope-detection
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/generated-freshness-scope-detection
```

If an implementation validator needs a fixture path argument, use only an
existing repo-local fixture path owned by the declared target family. Do not
hand-edit generated outputs to make a validator pass.

## Required Evidence

Update these proposal-local retained evidence files after durable
implementation:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

The implementation run receipt must include `verdict: pass` only when durable
changes, validators, and evidence all support that claim. It must record
Profile Selection Receipt facts: `release_state: pre-1.0`,
`change_profile: atomic`, and dependency changes: `none`.

The conformance receipt must pass, set `unresolved_item_count: 0`, cover every
promotion target, map each acceptance criterion to durable behavior, list
validators run, describe generated output handling, record rollback coverage,
and state that parent evidence and proposal-local evidence do not satisfy
durable generated freshness evidence.

The post-implementation drift/churn receipt must pass, set
`unresolved_item_count: 0`, record a proposal-path backreference scan for all
durable targets, verify generated-output non-authority, check target-family
boundaries, and record any generated outputs refreshed by canonical generator
or state `none`.

The validation evidence must list each command, result, and date, including the
three child-specific generated freshness validators.

## Rollback

Rollback is a coordinated revert of workflow routing and generated freshness
validator/generator changes in the declared durable targets, plus removal or
supersession of this child packet's implementation evidence. Do not roll back
unrelated existing P0 changes or unrelated local residue.

## Closeout Refusal Criteria

Refuse closeout, archive, publication, branch landing, branch cleanup, parent
promotion, parent closeout, deletion, or any `cleaned` claim when:

- conformance or drift/churn receipt is missing or failing;
- any child-specific generated freshness validator fails;
- generated freshness is required but stale or unauthorized;
- generated output is treated as authority;
- parent or proposal-local evidence is used as generated publication,
  closeout, cleanup, or lifecycle authority;
- implementation requires durable edits outside the declared promotion targets.

# Executable Implementation Prompt

prompt_id: terminal-evidence-sink-autonomy-implementation-20260618T163050Z
packet: .octon/inputs/exploratory/proposals/architecture/terminal-evidence-sink-autonomy
mode: child-packet-implementation
status_at_prompt_generation: accepted

## Mission

Implement the accepted child packet `terminal-evidence-sink-autonomy`.

The implementation must make branch-no-PR terminal proof a retained evidence
sink after landing, final sync, cleanup authorization, cleanup disposition, and
validation proof exist. Terminal proof must not require a source-branch commit
after landing and must not mutate `origin/main` or the landed source ref.

## Hard Boundaries

Do not promote, close out, archive, clean, land, publish, delete, or claim
`cleaned` for the parent program or for this child packet.

Parent program evidence is context only. It must not satisfy child
implementation, verification, promotion, or closeout evidence.

Durable edits are allowed only under these packet promotion targets:

- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/`

If implementation requires durable edits outside those targets, including
validator scripts, test scripts, contract schemas, generated outputs, state
evidence, or parent files, stop and report the blocker. Do not widen scope.

Do not hand-edit generated outputs. Generated proposal artifacts may be
refreshed only by the orchestrator through canonical generators after
implementation evidence is recorded.

## Inherited Context

Use these packet files as authority for the child:

- `proposal.yml`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`
- `support/proposal-review.md`
- `support/pre-integration-architecture-review.yml`
- `support/implementation-grade-completeness-review.md`
- `support/validation.md`
- parent child registry, packet sequence, child packet contract, risk register,
  validation plan, and source lineage as context only

Preflight gates passed before prompt generation:

- `validate-proposal-review-gate.sh --require-implementation-authorization`
- `validate-proposal-implementation-readiness.sh`
- `validate-architecture-proposal.sh`
- `validate-proposal-standard.sh --skip-registry-check`
- `validate-architectural-review-receipts.sh --require-pass`

Dependency gates passed before prompt generation:

- `branch-no-pr-closeout-state-machine-autonomy`: implemented; conformance,
  drift, and terminal freshness passed.
- `packet-worktree-partitioning-automation`: implemented; conformance, drift,
  terminal freshness, and independent verification passed.

## Required Implementation Behavior

Update only the allowed durable targets so they say, consistently:

- Branch-no-PR terminal proof is route-owned retained evidence, not a
  source-branch commit requirement.
- Terminal proof may be emitted only after landing evidence, final sync proof,
  cleanup authorization, cleanup disposition, rollback posture, and
  child/target-owned validation evidence exist.
- Terminal proof distinguishes the landed ref from the proof sink path or
  receipt path.
- Missing landing, final sync, cleanup authorization, cleanup disposition, or
  validation proof downgrades the actual outcome and blocks terminal success or
  `cleaned` claims.
- Terminal proof does not replace `closeout-change`, `closeout-worktree`, or
  proposal-packet delivery receipts.
- Terminal proof does not mutate `origin/main`, local `main`, the landed ref,
  source branch, generated outputs, or retained evidence.
- Aggregate delivery receipts may summarize route-owned terminal proof but must
  not replace target-owned receipts or proof files.

## Required Evidence To Write

Write or update only these child-owned support receipts:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

The receipts must record:

- durable files changed;
- validators run and results;
- evidence that durable edits stayed inside promotion targets;
- confirmation that no generated outputs were hand-edited;
- rollback instructions for the changed durable targets;
- explicit closeout refusal criteria.

## Required Validators

Run these from `/Users/jamesryancooper/Projects/octon` and record results in
`support/validation.md`:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/terminal-evidence-sink-autonomy --require-implementation-authorization`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/terminal-evidence-sink-autonomy`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/terminal-evidence-sink-autonomy`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/terminal-evidence-sink-autonomy --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/terminal-evidence-sink-autonomy/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/terminal-evidence-sink-autonomy --mode pre-integration-architecture-review --require-pass`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-state-machine.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-packet-delivery.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/terminal-evidence-sink-autonomy`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/terminal-evidence-sink-autonomy`

If any validator requires durable edits outside the allowed promotion targets,
stop and record a blocker instead of editing those paths.

## Rollback

Rollback is limited to reverting this child's durable changes under:

- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/`

Do not revert unrelated sibling child work, parent changes, generated outputs,
or user residue.

## Closeout Refusal Criteria

Refuse closeout, archive, branch cleanup, branch deletion, publication,
landing, or `cleaned` claims when:

- terminal proof is missing or only summarized by an aggregate receipt;
- landing evidence, final sync proof, cleanup authorization, cleanup
  disposition, rollback posture, or validation proof is missing;
- terminal proof would require a source-branch commit after landing;
- terminal proof would mutate `origin/main`, local `main`, the landed ref, or a
  source branch;
- parent program evidence is being used as child-owned proof;
- durable edits outside the promotion targets are required.

## Final Response From Implementation Worker

Report:

- durable files changed;
- proposal-local receipts updated;
- validators run and results;
- generated outputs touched, if any;
- scope blockers, if any;
- readiness for child-only promotion to `implemented`.

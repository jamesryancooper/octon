# Executable Implementation Prompt

prompt_id: git-mutation-sandbox-preflight-implementation-20260618T170020Z
packet: .octon/inputs/exploratory/proposals/architecture/git-mutation-sandbox-preflight
mode: child-packet-implementation
status_at_prompt_generation: accepted

## Mission

Implement the accepted child packet `git-mutation-sandbox-preflight`.

The implementation must make permission-sensitive git mutation failures
observable and routeable before retry, without making diagnostics into mutation
authority. Diagnostics must identify the git operation class, likely sandbox or
host permission blocker, required authorization gate, and owning rerun route.

## Hard Boundaries

Do not promote, close out, archive, clean, land, publish, delete, or claim
`cleaned` for the parent program or for this child packet.

Parent program evidence is context only. It must not satisfy child
implementation, verification, promotion, or closeout evidence.

Durable edits are allowed only under these packet promotion targets:

- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`

If implementation requires durable edits outside those targets, including git
helpers, validator scripts, test scripts, schemas, generated outputs, state
evidence, parent files, sibling packets, commands, or workflow manifests, stop
and report the blocker. Do not widen scope.

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

Dependency gate passed before prompt generation:

- `branch-no-pr-closeout-state-machine-autonomy`: implemented; conformance,
  drift, and terminal freshness passed.

## Required Implementation Behavior

Update only the allowed durable targets so they say, consistently:

- Permission-sensitive git mutation preflight diagnostics cover fetch,
  checkout, branch-local commit/publish, hosted landing, final sync, branch
  cleanup, and local or remote branch deletion/pruning.
- Diagnostics identify the operation class, current/target refs when known,
  expected authorization gate, likely sandbox/host/provider permission blocker,
  and owning rerun route.
- Diagnostics are retained routing evidence only. They do not authorize fetch,
  checkout, commit, push, landing, sync, cleanup, branch deletion, publication,
  closeout, or `cleaned` claims.
- A failed or denied mutation must preserve the lower actual outcome and record
  blocker evidence plus the owning rerun route.
- Hosted no-PR landing still requires governed landing authorization and helper
  validation before mutating `origin/main`.
- Branch cleanup or branch deletion still requires governed cleanup
  authorization and helper validation before mutating local or remote branch
  refs.
- Final sync still requires explicit post-fetch/sync evidence before landed or
  cleaned claims.
- Closeout-worktree may summarize diagnostics from delegated singular
  closeout-change runs but must not perform the git mutation or convert
  diagnostics into cleanup, landing, branch deletion, or closeout authority.

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

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/git-mutation-sandbox-preflight --require-implementation-authorization`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/git-mutation-sandbox-preflight`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/git-mutation-sandbox-preflight`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/git-mutation-sandbox-preflight --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/git-mutation-sandbox-preflight/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/git-mutation-sandbox-preflight --mode pre-integration-architecture-review --require-pass`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-hosted-no-pr-landing.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-state-machine.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/git-mutation-sandbox-preflight`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/git-mutation-sandbox-preflight`

If any validator requires durable edits outside the allowed promotion targets,
stop and record a blocker instead of editing those paths.

## Rollback

Rollback is limited to reverting this child's durable changes under:

- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`

Do not revert unrelated sibling changes already present in those files unless a
separate owning route authorizes that rollback. Do not revert generated output
residue, parent program files, sibling packet files, or retained evidence.

## Closeout Refusal Criteria

Refuse closeout, archive, branch cleanup, branch deletion, publication,
landing, sync, or `cleaned` claims when:

- git mutation diagnostics are missing for a blocked permission-sensitive
  operation;
- diagnostics are being used as mutation, authorization, cleanup, landing,
  branch deletion, publication, or closeout authority;
- landing authorization, cleanup authorization, final sync proof, rollback
  posture, or validation proof is missing;
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

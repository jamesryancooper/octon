# Executable Implementation Prompt

implementation_prompt_id: run-program-clean-delivery-authorized-hosted-landing-implementation-prompt-20260704T011116Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing
lifecycle_id: proposal-packet
route_id: run-packet-implementation
prompt_generation_run_id: lifecycle-proposal-program-1783112176123-f118c03e-run-program-clean-delivery-authorized-hosted-landing
reviewed_packet_digest: sha256:7eb2f5812e8e15802b780bae17d97eb9e40b40ff5f7fa85cb8fc058579d0139b
prompt_bundle_sha256: sha256:b2fc27e8e75f5e52971887e5bc440f17335fc4fe4303a630afa7148eea53efa6
release_state: pre-1.0
change_profile: atomic
non_authority_classification: packet-local-operational-support-only
generated_at: 2026-07-04T01:11:16Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, replace retained evidence, authorize
hosted mutation, authorize cleanup, authorize archive movement, publish
generated output, or claim closeout. Proposal inputs, generated prompts,
generated outputs, parent summaries, dashboards, host state, chat, model
memory, and tool availability remain non-authoritative.

## Prompt Generation Gate Receipt

Prompt generation was allowed after these gates passed from the repository
root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing --require-implementation-authorization --print-digest
```

The review gate emitted:

```text
sha256:7eb2f5812e8e15802b780bae17d97eb9e40b40ff5f7fa85cb8fc058579d0139b
```

The accepted proposal review records `verdict: accepted`,
`implementation_prompt_authorized: yes`, and
`open_blocking_findings_count: 0`. The implementation-grade completeness
review records `verdict: pass`, `unresolved_questions_count: 0`, and
`clarification_required: no`.

If any packet source, review digest, prompt bundle digest, review receipt, or
pre-integration architecture receipt drifts before implementation, stop and
rerun the owning review or freshness route.

## Required Starting Reads

Before editing, read:

- `AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/framework/constitution/CHARTER.md`
- `.octon/framework/constitution/charter.yml`
- `.octon/framework/constitution/obligations/fail-closed.yml`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/precedence/normative.yml`
- `.octon/framework/constitution/precedence/epistemic.yml`
- `.octon/framework/constitution/ownership/roles.yml`
- `.octon/instance/charter/workspace.md`
- `.octon/instance/charter/workspace.yml`
- `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`
- `.octon/framework/execution-roles/practices/standards/ai-assisted-development-discipline.md`
- `.octon/framework/execution-roles/practices/standards/repository-reconnaissance.md`
- `.octon/framework/execution-roles/practices/standards/cleanup-pass.md`
- `.octon/framework/execution-roles/practices/standards/dependency-discipline.md`
- `.octon/framework/execution-roles/practices/standards/validation-evidence-quality.md`
- `.octon/inputs/exploratory/proposals/README.md`
- `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`
- every file listed in this packet's `navigation/artifact-catalog.md`
- every approved promotion target below that the implementation may edit

Before durable edits, emit a Profile Selection Receipt, Repository
Reconnaissance Receipt, Minimal Implementation Plan, Impact Map, Evidence Plan,
Dependency Receipt, cleanup pass plan, and rollback notes. Use
`release_state: pre-1.0` and `change_profile: atomic`. The dependency receipt
should be `none` unless the implementation intentionally changes dependencies;
do not add dependencies without a separate receipt and validation.

Inspect current diffs before editing. Preserve unrelated local changes and do
not reset, restore, stash, clean, switch branches, delete branches, push,
fetch, or mutate hosted refs unless a current route-owned receipt authorizes
the exact action.

## Preconditions

Run these gates before durable target mutation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing --require-implementation-authorization --print-digest
```

Refuse implementation if any gate fails, if `proposal.yml#status` is not
`accepted`, if the accepted review digest is stale, if open blocking findings
appear, if the implementation-grade completeness review no longer passes, or
if satisfying acceptance criteria would require durable targets outside the
manifest without a packet revision or linked accepted proposal.

## Approved Promotion Targets

Durable implementation may touch only these manifest promotion targets and
their necessary in-family files:

- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

After durable edits, create or refresh only these packet-local implementation
receipts unless another accepted route authorizes more:

- `support/implementation-run.md`
- `support/validation.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Retained validation evidence should live outside `inputs/**`, preferably under:

- `.octon/state/evidence/validation/proposals/run-program-clean-delivery-authorized-hosted-landing/`

Do not edit generated/effective outputs by hand. If generated output freshness
is affected, run the owning publisher and retain publication/freshness
evidence; generated outputs remain derived-only.

Do not change `proposal.yml#status`; leave it as `accepted`. A later lifecycle
route owns any implemented-status rewrite, closeout, archive handoff, branch
cleanup, final sync, terminal proof, or `cleaned` claim.

## Explicit Non-Goals

- Do not perform hosted landing, cleanup, archive movement, branch deletion,
  branch switching, remote mutation, or generated publication from this prompt.
- Do not create a parallel landing authority, cleanup authority, Change
  receipt, closeout state machine, support target, generated projection, or
  proposal-local runtime dependency.
- Do not use chat text, host UI state, GitHub labels/comments, dashboards,
  generated summaries, parent delivery receipts, or proposal files as landing
  authority.
- Do not weaken provider controls, sandbox/tool approval boundaries,
  force-push protections, rollback requirements, final sync proof, or
  source/target ref freshness checks.
- Do not edit `.octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh`
  or `.octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-hosted-no-pr.sh`.
  These helpers are current live dependencies, but they are not approved
  promotion targets in this packet. If acceptance requires changing helper
  flags or helper mutation behavior, stop and report `needs-packet-revision`.

## Repository Starting Points

Reuse and extend existing surfaces before adding new fields, helpers,
validators, or tests:

- `closeout-change/SKILL.md` already models branch-no-pr route selection,
  hosted no-PR preflight, `branch-landing-authorization-v1`, exact source-SHA
  checks, rollback/discard posture, final local sync, cleanup authorization,
  permission diagnostics, and `runtime_approval_denied` downgrades.
- `change-closeout-state-machine.yml` already has a
  `hosted-no-pr-checks-and-landing` phase with exit evidence for pushed source
  branch, exact source-SHA checks, provider no-PR permission, governed landing
  authorization, fast-forward/update proof, `origin/main == landed_ref`,
  rollback handle, and final local sync.
- `change-closeout-state-machine.yml` already separates Octon governance
  authorization from runtime, sandbox, provider, or host approval denial using
  `runtime_approval_denied`.
- `change-receipt-v1.schema.json` already models `landing_authorization_ref`,
  `hosted_landing`, `landing_evaluation`, `landing_stop_reason`,
  `main_alignment`, `rollback_handle`, and cleanup/final proof fields.
- `validate-hosted-no-pr-landing.sh` already validates static hosted no-PR
  alignment and receipt-level hosted landing evidence, including authorization
  receipt freshness, source/target ref matching, check refs, empty-check-set
  rationale, rollback handle, provider ruleset evidence, and local main sync.
- `validate-change-closeout-lifecycle-alignment.sh` already validates
  route/lifecycle semantics, runtime approval denial only with matching
  governance authorization, cleanup authorization, terminal proof, retained
  state report rows, and branch-no-pr overclaim prevention.
- `test-hosted-no-pr-landing.sh`,
  `test-change-closeout-lifecycle-alignment.sh`, and
  `test-change-closeout-state-machine.sh` already contain hosted no-PR
  positive and negative fixture patterns.
- The live helper `.octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh`
  currently requires `--authorization <branch-landing-authorization-v1 receipt>`
  and also requires `--confirm` before mutation. Because that helper is not an
  approved target, this packet may define and validate closeout-change
  receipt-consuming execution semantics, but it may not directly replace the
  helper flag without packet revision.

If an existing field or test already satisfies an acceptance criterion, keep it
and record the coverage in `support/implementation-run.md` and
`support/validation.md` instead of duplicating logic.

## Target End State

Hosted no-PR landing can proceed non-interactively only when the selected
Change route has branch-no-pr hosted landing scope, an explicit
authorization-consuming execution signal is present, a current
`branch-landing-authorization-v1` receipt validates against immediate live
facts, and the execution environment is authorized for the exact mutation
class.

The durable implementation must make these claims machine-checkable:

- `--confirm` or chat confirmation is not the required human gate in
  closeout-change when a current landing authorization receipt, exact live
  preflight facts, rollback handle, final sync plan, and execution-environment
  lane are all proven.
- A distinct execution signal, such as `--execute-authorized-landing` or an
  equivalent route-owned field, means "consume this current authorization
  receipt for this exact hosted landing attempt." It is not an approval grant
  and does not mint landing authority.
- The execution signal is invalid unless it is paired with a fresh approved
  `branch-landing-authorization-v1` receipt, current source and target refs,
  exact source SHA, provider no-PR permission, required checks or approved
  empty-check-set rationale, rollback handle, host-control preservation, and a
  final sync plan.
- If the runtime, sandbox, provider, host, remote, or ref-write boundary
  denies mutation after Octon authorization validates, the receipt records the
  lower actual outcome with `landing_stop_reason: runtime_approval_denied`,
  blocker evidence, and no `landed`, `cleaned`, or completed-closeout
  overclaim.
- Missing, stale, denied, externally blocked, policy-incomplete, failed-check,
  ref-drift, force-push-required, missing-rollback, missing-final-sync, or
  missing-execution-lane cases fail closed or downgrade to a lower actual
  outcome.

## Ordered Workstreams

1. Inventory the current hosted landing surfaces.

   Run targeted reconnaissance:

   ```sh
   rg -n -- "--confirm|execute-authorized|authorization|landing_authorization_ref|hosted_landing|runtime_approval_denied|provider ruleset|exact source-SHA|empty-check|rollback|final sync|main_alignment|force-push|host controls" .octon/framework/capabilities/runtime/skills/remediation/closeout-change .octon/framework/product/contracts/change-closeout-state-machine.yml .octon/framework/product/contracts/change-receipt-v1.schema.json .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh .octon/framework/assurance/runtime/_ops/tests
   ```

   Record which acceptance criteria are already covered and which gaps remain.
   Preserve current `branch-landing-authorization-v1`, `landing_authorization_ref`,
   `hosted_landing`, `landing_evaluation`, `main_alignment`,
   `runtime_approval_denied`, and retained-state report semantics.

2. Define the authorization-consuming execution signal.

   Update the closeout-change durable skill surface so hosted branch-no-pr
   landing no longer requires an additional chat stop when all route-specific
   preconditions have already passed. The signal should be explicit and
   non-interactive, for example `--execute-authorized-landing`, but it must be
   described as receipt consumption, not approval creation.

   The closeout-change instructions must require these facts before the signal
   can be used:

   - selected route is `branch-no-pr`;
   - target lifecycle outcome is `landed` or `cleaned`;
   - source branch is pushed and exact source SHA is known;
   - provider ruleset permits no-PR route-neutral fast-forward/update;
   - required checks passed for the exact source SHA, or empty check set is
     explicitly allowed with retained rationale;
   - `branch-landing-authorization-v1` receipt is approved, current, and
     matches source ref, remote source ref, target branch, target pre-ref,
     provider ruleset, required check refs, rollback handle, and no-PR proof;
   - execution-environment lane is current for the exact mutation, either by
     pre-approved command prefix or equivalent sandbox/tool authority receipt;
   - rollback/discard posture and final sync plan are retained.

   If the implementation cannot express the signal without editing
   `git-branch-land-hosted-no-pr.sh`, stop and record
   `needs-packet-revision` because that helper is not an approved promotion
   target.

3. Align state machine and receipt schema only where needed.

   Prefer existing receipt fields. Add a minimal field only if validators need
   a machine-checkable distinction between explicit execution-signal receipt
   consumption and chat/operator confirmation.

   If a new field is needed, keep it scoped to hosted branch-no-pr landing and
   require it only for attempted non-interactive hosted mutation. It must cite:

   - the execution signal name or route field;
   - the consumed landing authorization ref and digest when available;
   - the execution-lane evidence ref;
   - source ref, target pre-ref, target post-ref when mutation succeeds;
   - provider ruleset/check evidence;
   - rollback handle;
   - final sync evidence or downgrade reason.

   Do not add a second Change receipt schema, proposal-program-specific
   landing receipt, generated projection, or proposal-local runtime dependency.

4. Tighten hosted landing validators.

   Extend `validate-hosted-no-pr-landing.sh` and
   `validate-change-closeout-lifecycle-alignment.sh` only where current checks
   cannot prove the new execution-signal boundary.

   Required validator behavior:

   - valid current authorization plus explicit execution signal is accepted;
   - missing execution signal for a non-interactive mutation attempt is
     rejected or downgraded;
   - stale, missing, denied, mismatched, or malformed authorization is
     rejected;
   - source-ref drift, target-pre-ref drift, provider denial, failed checks,
     missing empty-check-set rationale, missing rollback, missing final sync,
     force-push requirement, and missing execution-lane evidence are rejected;
   - `runtime_approval_denied` is accepted only when Octon authorization
     validates and the receipt truthfully records the lower actual outcome;
   - `runtime_approval_denied` without matching authorization still fails;
   - chat text, GitHub host state, dashboards, generated projections, parent
     summaries, and proposal files cannot satisfy landing authority or
     execution-lane fields.

5. Add positive and negative controls.

   Extend existing tests under
   `.octon/framework/assurance/runtime/_ops/tests/`.

   Required positive controls:

   - static hosted no-PR validator alignment still passes;
   - a valid current authorization receipt plus explicit execution signal
     passes;
   - an approved empty-check-set receipt passes only with retained rationale
     bound to the exact source ref;
   - runtime approval denial after valid Octon authorization downgrades
     truthfully and passes only as a non-landing outcome.

   Required negative controls:

   - missing execution signal for non-interactive mutation fails or downgrades;
   - `--confirm` or chat text alone does not satisfy the execution boundary;
   - stale authorization, ref drift, provider denial, failed checks, missing
     rollback, missing final sync, missing execution-lane evidence, and
     force-push requirement fail;
   - runtime approval denial without matching landing authorization fails;
   - local checkpoints, pushed-only branches, host state, generated outputs,
     parent summaries, and proposal files cannot satisfy hosted landing
     evidence.

6. Record implementation receipts.

   Write `support/implementation-run.md` with:

   - Profile Selection Receipt;
   - Repository Reconnaissance Receipt;
   - Minimal Implementation Plan;
   - Impact Map;
   - Evidence Plan;
   - Dependency Receipt;
   - cleanup pass result;
   - exact durable files changed;
   - existing fields reused;
   - any new field or validator change and why it was unavoidable;
   - explicit statement that no hosted refs were mutated by implementation
     unless a separate current route-owned receipt authorized that exact
     mutation.

   Write `support/validation.md` with command, cwd, start/end time, exit code,
   and relevant bounded output for each validation command. Retain full logs
   or compact evidence under
   `.octon/state/evidence/validation/proposals/run-program-clean-delivery-authorized-hosted-landing/`
   when useful.

7. Produce post-implementation reviews.

   After durable implementation and validation, create:

   - `support/implementation-conformance-review.md`
   - `support/post-implementation-drift-churn-review.md`

   These reviews must record `verdict: pass`, `unresolved_items_count: 0`, and
   cite the implementation evidence only if the implementation satisfies all
   acceptance criteria. Otherwise, record blockers and do not claim
   implementation completion.

## Validation Floor

Run at least:

```sh
git diff --check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing --require-implementation-authorization --print-digest
bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-hosted-no-pr-landing.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-state-machine.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing
```

If a generated proposal registry freshness check is run without
`--skip-registry-check`, it may report unrelated stale registry projection
state. Do not repair generated proposal registry freshness from this
implementation route unless the implementation itself changes manifest
projection inputs and the owning publication path is explicitly in scope.

## Rollback Posture

Rollback is additive and local to this child's approved durable targets:

- revert edits under the approved target paths;
- revert packet-local implementation receipts created by this route if they
  are superseded by a failed implementation;
- retain validation evidence that explains the failed attempt;
- do not delete retained evidence, generated publication receipts, branches,
  hosted refs, or unrelated local residue as rollback.

If implementation discovers that a helper outside the approved target set must
change, stop before editing it and record a packet revision blocker instead of
expanding the durable scope.

## Terminal Criteria

The implementation route may report implementation complete only when:

- all mandatory preflight gates still pass;
- durable edits are confined to approved promotion targets;
- no proposal path, prompt, generated output, host state, chat, model memory,
  or tool availability is treated as authority;
- hosted no-PR execution semantics are receipt-consuming and
  execution-lane-bound;
- stale, missing, denied, externally blocked, policy-incomplete, ref-drift,
  failed-check, missing-rollback, missing-final-sync, force-push, and missing
  execution-lane cases are covered by validators or tests;
- `support/implementation-conformance-review.md` exists and passes;
- `support/post-implementation-drift-churn-review.md` exists and passes;
- `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing`
  passes;
- `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-authorized-hosted-landing`
  passes.

Refuse closeout, archive, `implemented`, `landed`, `cleaned`, or terminal
delivery claims until both post-implementation receipts and both post-
implementation validators pass.

## Next Route

When this prompt is current and the implementation preflight gates still pass,
the next lifecycle route is `run-packet-implementation`.

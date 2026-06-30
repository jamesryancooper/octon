# Executable Implementation Prompt

implementation_prompt_id: run-program-clean-delivery-runner-routing-implementation-prompt-20260628T173200Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing
route_id: run-packet-implementation
prompt_generation_run_id: 20260628T173200Z-run-program-clean-delivery-runner-routing-review
status: operational-aid
generated_at: 2026-06-28T17:32:00Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, or substitute for retained evidence.
The proposal packet remains temporary and non-authoritative.

## Prompt Generation Gate Receipt

Prompt generation was allowed only after these gates passed:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing --print-digest
```

Observed review digest at prompt-generation time:
`sha256:bf59826513520ff688dee394a481aeccb1eeb55a7f7b2fa4205f548646d4b3b8`.

The review receipt records `verdict: accepted`,
`implementation_prompt_authorized: yes`, and
`open_blocking_findings_count: 0`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: implement runner route selection, lifecycle contract
  declaration, command text, skill text, validation, generated refresh, and
  evidence expectations as one coherent change.
- transitional exception: not authorized

## Mandatory Preflight

Before durable edits, read the packet and current repository state:

- `proposal.yml`
- `architecture-proposal.yml`
- `navigation/source-of-truth-map.md`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`
- `validation-plan.md`
- `support/proposal-review.md`
- `support/implementation-grade-completeness-review.md`
- `support/pre-integration-architecture-review.yml`

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing
```

Refuse implementation if any gate fails, if the review digest is stale, if
proposal status is not `accepted`, or if the work would require promotion
targets outside the manifest without a packet revision or linked proposal.

The current worktree may already contain local changes in declared target
families. Inspect existing diffs before editing and preserve changes outside
this packet's declared scope.

## In Scope

Durable implementation may touch only these manifest promotion targets:

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/`

Generated effective outputs may be refreshed only through their owning
publisher routes after additive extension inputs change. They remain
derived-only and cannot authorize route selection.

## Out Of Scope

Do not implement delivery workflow stages, terminal proof synthesis, generated
metadata hardening outside route input and freshness references, validators
owned by sibling packets, broad operator wrappers outside the program runner
command and skill, Change closeout, branch cleanup, hosted provider mutation,
repo hygiene deletion, archive relocation, final clean-state proof, or any
`cleaned` completion claim.

Do not change `proposal.yml#status`; the implementation route leaves the
packet accepted and records implementation evidence for later lifecycle routes.

## Repository Starting Points

Use the existing runner machinery rather than creating a second scheduler:

- `ProgramLifecyclePlanResult`, `ProgramChildPlanState`,
  `ProgramBlocker`, `ProgramRecoveryRecipeValidationEvidence`,
  `ProgramLifecycleRunResult`, and related evidence structs already model
  planner state, selected parent routes, selected child routes, blockers,
  retry posture, and execution summaries.
- `plan_program_lifecycle_from_octon_dir*` already reconstructs parent and
  child state from manifests, child registry, receipts, checkpoints, and
  run inputs.
- Existing compact evidence constants already include
  `planner-state.yml`, `program-context-capsule.yml`,
  `blocker-ledger.yml`, `route-decision-receipt.yml`,
  `model-routing-receipt.yml`, and `action-slice-ledger.yml`.
- Existing route-selection and dispatch helpers include
  `select_program_route_with_parent_handoff_context`,
  `select_runnable_batch`, `select_unblocked_route_ready_batch`,
  `execute_parent_program_route`, and `selected_route_for_child_execution`.
- Existing retry and resume guards include recovery budget checks, progress
  fingerprint checks, stale receipt recovery, unsafe resume blockers, executor
  preflight blockers, and parent route replan-loop blockers.

Extend these surfaces; do not introduce a proposal-local planner, generated
projection scheduler, or host-state scheduler.

## Workstream 1: Lifecycle Contract Declaration

Update `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
so clean-delivery continuation is an explicit runner posture under the
existing `orchestrated-replan-loop`.

Required contract coverage:

- declare continuation mode, selected outcome, route-selection inputs,
  route-decision evidence, retry fingerprint fields, resume source refs, and
  delivery handoff evidence;
- bind `target_outcome=cleaned` as a Proposal Program Delivery input, never as
  runner completion proof;
- state that child receipts remain child-owned and parent aggregate receipts
  may cite them only by path and digest;
- require stale receipt refresh to use the owning lifecycle route at a stable
  digest boundary;
- require retry budgets and recovery recipes to name idempotency class,
  route/action owner, post-attempt validation, and human-boundary behavior;
- preserve generated effective extension and capability outputs as
  derived-only publisher-owned refresh targets.

## Workstream 2: Runner Route Selection

Update `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
so the program runner can select the next route without an operator prompt
only when current state makes exactly one route-owned continuation legal.

Required behavior:

- reconstruct parent and child state from live manifests, child registry,
  child-owned support receipts, checkpoints, event logs, source-ref digests,
  and retained run evidence;
- select child-owned route progression before parent delivery when child gates
  remain open;
- select parent route progression only after child gates and parent receipts
  are fresh;
- emit route-decision, model-routing, planner-state, blocker-ledger, and
  action-slice evidence before dispatch;
- keep non-execute mode as `program-route-handoff` evidence only;
- in execute mode, consume one bounded step per selected parent route or
  runnable child batch;
- fail closed when child-owned evidence is missing, stale, or replaced by
  parent summaries, generated projections, chat, host state, or model memory.

Candidate route progression must stay route-owned and include only legal
packet or parent lifecycle routes such as child review/revise, implementation
prompt generation, implementation, verification/correction, promotion,
closeout, archive, parent status correction, parent closeout, and parent
delivery handoff.

## Workstream 3: Bounded Retry And Resume

Extend existing recovery-budget and recovery-progress machinery rather than
adding a parallel retry loop.

Required behavior:

- fingerprint blockers by blocker class, child id when present, route id,
  target digest, receipt digest, write-scope digest, stable digest boundary,
  and recovery owner;
- retry only when the lifecycle contract declares the route or recovery action,
  idempotency class, authority zone, retry budget, and post-attempt validation;
- stop on unchanged blocker fingerprints after the declared budget is
  exhausted;
- replan from live repository state after every route attempt, recovery
  action, generated refresh, residue-classification handoff, or receipt
  refresh;
- resume only when checkpoint event heads, child registry digest, source refs,
  model-visible context digest, and selected child evidence still verify;
- fail closed on unsafe resume.

## Workstream 4: Delivery Handoff Evidence

Emit Proposal Program Delivery handoff evidence only after child and parent
lifecycle gates pass.

The handoff evidence must include:

- parent program path and digest;
- child registry digest;
- child receipt refs and digests;
- parent receipt refs and digests;
- delivery-readiness preflight status;
- generated freshness status;
- route-decision receipt ref;
- `target_outcome=cleaned` as a requested delivery outcome;
- explicit statement that Proposal Program Delivery owns landing, sync,
  cleanup, branch cleanup, terminal proof, and the final `cleaned` claim.

The runner must stop before delivery mutation when delivery readiness, Change
closeout, branch cleanup, cleanup authorization, generated freshness, terminal
proof, or owning-route evidence is missing or stale.

## Workstream 5: Command And Skill Alignment

Update the proposal lifecycle command and skill surfaces that describe the
proposal-program runner:

- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/octon-proposal-run-program-lifecycle.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/manifest.fragment.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-run-program-lifecycle/SKILL.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/registry.fragment.yml`

Keep command and skill text aligned with the contract and runtime behavior.
Document clean-delivery continuation, `--execute-routes`, `--max-steps`,
`--max-child-concurrency`, deterministic resume, typed stop conditions,
delivery handoff boundaries, and forbidden authority transfers. Preserve the
wrapper as no prompt bundle and not a dispatcher route.

## Workstream 6: Generated Refresh

After additive extension command, skill, or lifecycle contract inputs change,
refresh generated outputs through owning publisher scripts, then validate
freshness. Use the current repository's owning routes; expected scripts
include:

```sh
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/publish-pack-routes.sh
bash .octon/framework/assurance/runtime/_ops/scripts/publish-runtime-route-bundle.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh
```

If publisher scripts require additional arguments in the current repository,
inspect their usage and invoke them through the owning publication route.
Generated outputs remain derived-only evidence, not authority.

## Validation

Run packet-level validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing
```

Run implementation validators and focused tests:

```sh
cargo test -p kernel lifecycle_program
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package <fixture-program>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package <fixture-program>
```

Add or update Rust tests covering:

- one legal child route selected without operator prompt;
- multiple legal routes, no legal routes, and ownership ambiguity stopping
  with typed blockers;
- non-execute mode producing `program-route-handoff` only;
- stale child receipt choosing the owning refresh route;
- parent summary substitution rejection;
- retry-budget exhaustion on unchanged blocker fingerprints;
- safe retry after changed stable digest boundary;
- unsafe resume failure;
- delivery handoff with `target_outcome=cleaned` as input only;
- delivery mutation, cleanup, branch cleanup, terminal proof, and `cleaned`
  claim rejection without owning-route evidence.

Run extension validation after command, skill, contract, or generated output
changes. At minimum, run the relevant extension pack, local test, publication,
and freshness validators available in the repository.

## Required Evidence And Receipts

Retain implementation evidence under an appropriate validation or run evidence
root, such as:

```text
.octon/state/evidence/validation/proposals/run-program-clean-delivery-runner-routing/<timestamp>/
```

Record:

- repository reconnaissance receipt for runner, lifecycle contract, command,
  skill, publisher, and validator surfaces;
- profile selection receipt using `release_state=pre-1.0` and
  `change_profile=atomic`;
- implementation map linking each changed file to the workstream above;
- route-decision, retry fingerprint, resume source-ref, delivery handoff, and
  blocker outcome evidence from tests or retained scenario runs;
- generated refresh and freshness receipts when generated outputs change;
- negative-control evidence for parent-summary substitution, generated-output
  authority, stale receipt refresh, unsafe resume, retry-budget exhaustion, and
  delivery mutation without owning-route evidence;
- rollback posture and commands.

After implementation, update packet support material:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

The conformance review must cover promotion target coverage, implementation
map coverage, validator coverage, generated output coverage, rollback
coverage, downstream reference coverage, exclusions, and final closeout
recommendation.

The drift/churn review must cover backreference scan, naming drift, generated
projection freshness, manifest and schema validity, repo-local projection
boundaries, target family boundaries, churn review, validators run,
exclusions, and final closeout recommendation.

## Post-Implementation Gates

Before any implemented, closeout, archive-ready, delivery, or clean-state
claim, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing
```

Refuse closeout or archive if either receipt is missing, stale, failing, or
not validated by the corresponding command. Refuse closeout or archive if the
runner can replace child receipts with parent summaries, consume generated
outputs as authority, dispatch without route-decision evidence, continue after
unsafe resume, exceed retry budgets without a typed blocker, mutate delivery
surfaces, clean branches, delete residue, or claim `cleaned`.

## Rollback

Rollback is one atomic revert of the runner, proposal-program lifecycle
contract, command, skill, and generated refresh outputs changed for this
packet. After rollback, rerun the same packet validators, focused Rust tests,
extension publication/freshness validators, implementation conformance gate,
and post-implementation drift/churn gate. Retain rollback evidence under the
same evidence root family used for implementation.

## Delegation Boundary

This prompt does not authorize independent execution ownership. Any delegation
must remain under one accountable orchestrator, use disjoint write scopes,
preserve user worktree changes, and cannot transfer child receipt ownership,
delivery authority, Change closeout, generated publication authority, cleanup
authority, branch cleanup, terminal proof, or final `cleaned` claim authority.

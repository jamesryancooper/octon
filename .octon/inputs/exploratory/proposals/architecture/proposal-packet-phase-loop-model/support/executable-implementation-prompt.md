# Executable Implementation Prompt

implementation_prompt_id: proposal-packet-phase-loop-model-implementation-prompt-2026-05-23
proposal_path: .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-23T14:09:13Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
proposal manifests, or substitute for retained evidence.

Durable authority may land only in the approved promotion targets outside the
proposal path. Proposal-local files, support receipts, generated proposal
registry entries, raw inputs, generated projections, host state, GitHub or CI
state, chat history, browser state, model memory, and tool availability are
implementation input or derived context only. They are not runtime, policy,
control, retained-evidence, publication, or closeout authority.

## Prompt Generation Gate Receipt

This prompt was generated only after both required gates passed from the
repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`; accepted
review digest before prompt artifact creation:
`sha256:780aae2887947eac72ffefbd066e05bcc320ff0f43e4b15ee1dfa72fbe840780`.
After catalog registration for this prompt, the accepted review receipt was
refreshed to the current digest:
`sha256:8a7f6f111b76d0a42e6dff1ccf24eedf20beb05d30f1782b74d40d4a63e52ff2`.

Before implementation, rerun the same gates and refuse implementation if either
fails, if the review digest is stale, if `proposal.yml#status` is not
`accepted`, if `implementation_prompt_authorized` is not `yes`, or if
`open_blocking_findings_count` is not `0`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: implement one coherent clean-break Proposal Packet
  Phase-Loop Model across the approved lifecycle contract, schema, runner,
  checkpoint, event-log, validator, test, source-extension, publication, and
  documentation surfaces.
- transitional exception: not authorized. Any compatibility behavior must be
  implementation-branch-only or explicitly marked compatibility-only with
  owner, removal review, and retirement trigger.

## Mandatory Preflight

Before editing durable targets, re-read:

- repository ingress and the constitutional kernel;
- `proposal.yml` and `architecture-proposal.yml`;
- `navigation/source-of-truth-map.md`;
- `architecture/target-architecture.md`;
- `architecture/current-state-gap-map.md`;
- `architecture/file-change-map.md`;
- `architecture/implementation-plan.md`;
- `architecture/validation-plan.md`;
- `architecture/acceptance-criteria.md`;
- `architecture/cutover-checklist.md`;
- `architecture/rollback-plan.md`;
- `resources/evidence-plan.md`;
- `resources/non-changes.md`;
- `resources/risk-register.md`;
- `support/implementation-grade-completeness-review.md`;
- `support/proposal-review.md`;
- current source lifecycle files under
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/**`;
- current lifecycle schemas, lifecycle runner, lifecycle driver, lifecycle
  executor request/result schemas, lifecycle executor crate, validators, and
  acceptance tests named by the proposal.

Then run these gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model --require-implementation-authorization
```

Refuse implementation unless all commands pass, `proposal.yml#status` is
`accepted`, the review verdict is `accepted`,
`implementation_prompt_authorized: yes`, `open_blocking_findings_count: 0`,
and the reviewed packet digest is fresh.

## Current Repository Baseline

The live repository currently has these relevant surfaces:

- source-authored proposal packet lifecycle contract at
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
  using `schema_version: octon-extension-lifecycle-contract-v1`,
  `execution_strategy: route-progression`, stable proposal manifest statuses,
  `states`, routes, validators, gates, receipts, and one bounded
  `proposal-review-revision` loop;
- proposal lifecycle model and routing docs under
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/`;
- extension lifecycle contract schema at
  `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-lifecycle-contract.schema.json`
  with v1 `states`, `routes`, `receipts`, `gates`, `validators`, `loops`, and
  `terminal_outcomes`, but no first-class `phase_loop`;
- lifecycle run event schema at
  `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/lifecycle-run-event.schema.json`
  with lifecycle, planning, handoff, dispatch, status, budget, and control
  event categories, but no phase-scoped event fields or explicit
  `phase-entered`, `phase-exited`, `phase-backtracked`, or `phase-blocked`
  event types;
- Lifecycle Autopilot docs that already describe plan, gate, execute, observe
  receipts, checkpoint, resume, and terminal or blocked outcomes;
- runtime implementation surfaces in
  `.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs`,
  `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_driver.rs`, and
  `.octon/framework/engine/runtime/crates/lifecycle_executor/`;
- lifecycle route executor request/result schemas at
  `.octon/framework/engine/runtime/spec/lifecycle-route-execution-request-v1.schema.json`
  and
  `.octon/framework/engine/runtime/spec/lifecycle-route-execution-result-v1.schema.json`;
- lifecycle contract, runner, executor adapter, and proposal lifecycle tests
  under `.octon/framework/assurance/runtime/_ops/`;
- generated effective proposal lifecycle projections under
  `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/**`,
  which are runtime discovery handles only and must be refreshed only from
  source through governed publication;
- host-projected Codex skills under `.codex/skills/octon-proposal-lifecycle*`,
  which are host projections and not source authority.

## Target End State

Implement the clean-break, layered Proposal Packet Phase-Loop Model accepted by
this packet:

- proposal packet lifecycle source contract uses
  `schema_version: octon-extension-lifecycle-contract-v2`;
- source contract declares `phase_loop.model_version: phase-loop-v1`;
- `phase_loop` references existing `routes`, `receipts`, `gates`,
  `validators`, `loops`, and `terminal_outcomes` instead of duplicating route
  predicates;
- proposal manifest statuses remain unchanged unless a new accepted packet
  proves a contract-level need;
- phases are contract, checkpoint, and event state, not
  `proposal.yml#status` values;
- the full phase set is represented:
  `target-binding-and-lifecycle-discovery`, `packet-creation`,
  `structural-validation`, `implementation-grade-completeness`,
  `review-and-revision`, `implementation-authorization`,
  `implementation-prompt-generation`, `implementation-execution`,
  `promotion`, `verification-and-correction`, `closeout-and-hygiene`,
  `archival`, and `terminal-explanation-reporting`;
- the generic substrate validates phase ids, route refs, receipt refs, gate
  refs, validator refs, loop refs, terminal refs, and backward-transition
  targets;
- runner evaluates the current phase from durable manifest, receipt, gate,
  checkpoint, and event evidence;
- runner enforces allowed transitions, backward transitions, loop bounds,
  stale receipt denial, cancellation, and fail-closed blockers;
- checkpoints record `current_phase`, `phase_counts`,
  `last_phase_transition`, `phase_blockers`, selected route, receipt
  freshness, gate results, event-log head, stop class, and resume or refusal
  reason;
- event logs record `phase-entered`, `phase-exited`, `phase-backtracked`,
  `phase-blocked`, route dispatch start and finish, stale receipt detection,
  budget exhaustion, cancellation, and fail-closed blocker classification;
- lifecycle event schema supports `phase_id` and `transition_id` where
  phase-scoped;
- executor remains route-invocation only and may receive `phase_id` only as
  context, never as authority;
- generated effective projections remain derived discovery handles;
- host-projected skills are refreshed from source only if source skill inputs
  change and the refresh is routed as a derived publication step.

## In Scope

Durable edits may touch only these approved promotion target families:

- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle-model.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/routing-guide.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/`
- `.octon/framework/product/features/lifecycle-autopilot.md`
- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.md`
- `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-lifecycle-contract.schema.json`
- `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/lifecycle-run-event.schema.json`
- `.octon/framework/engine/runtime/spec/lifecycle-route-execution-request-v1.schema.json`
- `.octon/framework/engine/runtime/spec/lifecycle-route-execution-result-v1.schema.json`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_driver.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-executor-adapter.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-v1-acceptance.sh`

Expected implementation outputs include:

- v2 schema support for `phase_loop`;
- source proposal packet lifecycle v2 contract with the approved phase set;
- source lifecycle model/routing/command/skill/prompt updates explaining
  phase-loop behavior without status confusion;
- runner and driver support for phase evaluation, transition enforcement,
  checkpoint phase state, route dispatch counts, phase attempt counts, resume,
  cancellation, and phase-aware stop reporting;
- event schema support for phase-scoped fields and phase event types;
- optional request/result schema phase context, with executor non-authority
  preserved;
- validator support and positive/negative fixtures for all accepted phase-loop
  constraints;
- generated effective projection refresh from source after durable source
  changes pass validation;
- host-projected skill refresh from source extension inputs when needed;
- retained publication, freshness, validation, and run evidence outside
  `inputs/**`.

After durable edits land, packet-local receipts are required:

- `.octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model/support/post-implementation-drift-churn-review.md`

Retained validation and publication evidence must live outside `inputs/**`,
preferably under:

- `.octon/state/evidence/validation/proposals/proposal-packet-phase-loop-model/<timestamp>/`
- `.octon/state/evidence/validation/publication/**`
- `.octon/state/evidence/runs/**` when a lifecycle runner creates run
  evidence

## Out Of Scope

Do not edit these surfaces for this packet:

- `.octon/instance/**`, except retained run or publication evidence produced
  by an approved lifecycle route;
- `.octon/state/control/**`, except lifecycle-run control created by an
  approved runner;
- `.octon/state/evidence/**`, except retained validation, publication, or run
  evidence created by the implementation route;
- `.octon/inputs/**` outside the approved additive extension source inputs and
  this proposal packet's required support receipts;
- `.octon/generated/**`, except generated effective projection refresh from
  source after durable source changes pass validation;
- `.codex/skills/**`, except a generated host projection refresh from source
  extension skill inputs when required by the implementation and validated as
  derived-only;
- root docs, root adapters, `.github/**`, provider settings, connector
  admission, branch protection, or external systems.

Do not add proposal manifest statuses. Do not make proposal-local receipts
runtime authority. Do not make generated projections source authority. Do not
make GitHub, CI, chat, browser state, tool availability, model memory, or host
projection state authoritative. Do not merge runner orchestration with
proposal-extension route semantics. Do not allow self-operating execution to
become self-authorizing.

Do not change this proposal packet's `proposal.yml#status`; leave it as
`accepted`. The later promotion or closeout lifecycle route owns any
implemented-status or archive rewrite.

If implementation requires any out-of-scope file, new authority class,
target-family widening, new proposal status, generated projection authority,
host projection authority, destructive action, PR creation, branch deletion, or
acceptance of stale evidence, stop and report `needs-packet-revision` with
evidence.

## Ordered Workstreams

### 0. Preflight And Evidence Directory

1. Record current worktree state and preserve unrelated existing edits.
2. Run the mandatory proposal standard, architecture, readiness, and strict
   review gates.
3. Create a retained evidence directory under
   `.octon/state/evidence/validation/proposals/proposal-packet-phase-loop-model/<timestamp>/`.
4. Record the Profile Selection Receipt there and in
   `support/implementation-run.md`: `release_state=pre-1.0`,
   `change_profile=atomic`, `transitional_exception_note=not authorized`.
5. Capture baseline searches for lifecycle contract v1, `states`, `loops`,
   lifecycle runner checkpoints, lifecycle event schema, executor request and
   result schemas, generated effective projection publication, host projection
   refresh, proposal status values, and validator fixtures.

### 1. Contract Schema And Source Contract

1. Update `extension-lifecycle-contract.schema.json` to accept
   `octon-extension-lifecycle-contract-v2` and a generic `phase_loop`
   primitive.
2. Define required `phase_loop` fields from the accepted architecture:
   `model_version`, `phases[]`, `phase_id`, `mode`, `owner_layer`,
   `route_refs`, `receipt_refs`, `gate_refs`, `entry_when`, `exit_when`,
   `exit_evidence_refs`, `re_entry_triggers`, `backward_transitions`,
   `loop_bounds`, `stop_conditions`, and `authority_boundaries`.
3. Preserve existing v1 contract handling only as explicitly required for
   compatibility; do not leave v1 proposal packet semantics as a competing live
   model after cutover.
4. Update source
   `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
   to v2 and add the proposal packet `phase_loop`.
5. Keep existing routes, receipts, gates, validators, loops, terminal
   outcomes, and allowed proposal statuses as the canonical route and evidence
   definitions. `phase_loop` must reference them.
6. Validate unique phase ids, resolved refs, finite loop bounds, legal
   backward transitions, terminal phases without routes, and no phase-defined
   status expansion.

### 2. Proposal Extension Semantics

1. Update proposal lifecycle model and routing docs to explain phases as runner
   state, not proposal statuses.
2. Update source command, skill, prompt, and validation inputs under
   `.octon/inputs/additive/extensions/octon-proposal-lifecycle/**` so create,
   review, revise, implementation prompt, implementation, verification,
   closeout, and archive routes preserve receipt freshness, authority
   boundaries, and fail-closed behavior.
3. Define packet-specific semantics for completeness, review, implementation,
   conformance, drift, closeout, hygiene, archive, revision-required,
   implementation-allowed, and correction-versus-revision decisions.
4. Keep program child authority separation unchanged.

### 3. Runner, Checkpoint, Event, And Executor Boundary

1. Update `lifecycle.rs` and `lifecycle_driver.rs` to plan from current phase
   plus route eligibility, not only route predicates.
2. Evaluate phase from durable manifest, receipt, gate, checkpoint, and event
   evidence.
3. Maintain phase attempt counts and route dispatch counts.
4. Write checkpoint fields for `current_phase`, `phase_counts`,
   `last_phase_transition`, `phase_blockers`, selected route, receipt
   freshness, gate results, event-log head, stop class, and resume or refusal
   reason.
5. Enforce allowed transitions, backward transitions, stale receipt denial,
   loop bounds, cancellation, checkpoint/event-head convergence, and
   impossible-transition denial.
6. Update `lifecycle-run-event.schema.json` with phase-scoped event support:
   `phase_id`, `transition_id`, `phase-entered`, `phase-exited`,
   `phase-backtracked`, and `phase-blocked`.
7. Update lifecycle executor request/result schemas only if `phase_id` context
   is needed. Treat it as observation context only. The executor must not
   select phase, reinterpret phase semantics, waive gates, or self-authorize.

### 4. Validators And Tests

1. Extend `validate-lifecycle-contracts.sh` for v2 contract shape and
   `phase_loop` validation.
2. Add positive and negative fixtures for:
   - valid proposal packet v2 phase-loop contract;
   - duplicate phase id;
   - dangling route, receipt, gate, validator, loop, terminal, and phase refs;
   - backward transition to missing phase;
   - missing or non-finite loop bounds;
   - terminal phase with dispatchable route;
   - phase-defined proposal status expansion;
   - generated effective projection consumed as source authority;
   - stale generated projection denial;
   - cancellation/resume phase preservation.
3. Update runner and executor tests for stale review rerouting, revision loop
   exhaustion as `blocked-max-iterations`, implementation denial without
   strict fresh review, archive denial without closeout receipt, checkpoint and
   event mismatch denial, cancellation, resume, and route-ready handoff versus
   dispatch.
4. Update proposal lifecycle acceptance tests for successful, stale, blocked,
   incomplete, unsafe, ambiguous, cancelled, resumed, archived, loop-bound, and
   generated-authority-denial paths.

### 5. Publication And Projection Refresh

1. After source-authored changes pass validation, refresh generated effective
   extension projections from source.
2. Verify generated projection source digests and freshness metadata.
3. Refresh host-projected proposal lifecycle skills from source extension
   inputs only if those source inputs changed.
4. Retain publication and freshness receipts under the appropriate
   `.octon/state/evidence/**` roots.
5. Re-run lifecycle discovery and acceptance tests against generated runtime
   handles.
6. Ensure generated effective projections are consumed only as discovery
   handles and are never treated as source authority.

### 6. Receipts And Packet-Local Closure Evidence

After implementation, write or refresh
`support/implementation-run.md` with at least:

- `verdict`;
- `implemented_at`;
- `promotion_evidence_count`;
- changed durable target list;
- retained evidence refs;
- validator summary;
- blockers or `none`.

Then write:

- `support/implementation-conformance-review.md` with `verdict` and
  `unresolved_items_count`;
- `support/post-implementation-drift-churn-review.md` with `verdict` and
  `unresolved_items_count`.

Do not claim closeout or archive readiness until both receipts pass their
validators.

## Required Validation

Run the minimum validation floor below after implementation. Add narrower tests
or schema checks as needed based on touched files.

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-executor-adapter.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-v1-acceptance.sh
cd .octon/framework/engine/runtime/crates && cargo test -p octon_kernel -p octon_lifecycle_executor
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
```

If generated effective projections or host projections are refreshed, also run
the repo's publication/freshness checks that govern those projections and
retain the resulting evidence.

If any required validator is missing, failing, stale, or outside the current
support envelope, stop and report the blocker instead of weakening the
validation floor.

## Required Conformance Checks

The implementation must prove all accepted architecture criteria:

- v2 contract and `phase_loop.model_version: phase-loop-v1` exist in source;
- every phase ref resolves;
- loop bounds are finite;
- terminal phases do not dispatch routes;
- no proposal manifest status set is widened;
- runner checkpoints include required phase fields;
- event schema and logs support required phase event types and fields;
- stale, missing, incomplete, or contradictory receipts deny implementation,
  promotion, closeout, and archive routes;
- executor cannot dispatch durable routes without valid delegation proof and
  approval evidence;
- generated effective projection is required for runtime discovery but remains
  non-authoritative;
- host-projected skills are derived from source and do not become authority;
- tests prove stale, blocked, incomplete, unsafe, ambiguous, successful,
  cancelled, resumed, archived, loop-bound, and generated-authority-denial
  paths.

## Rollback Posture

The implementation must remain revertible by restoring the previous lifecycle
contract, schema, runner, event schema, validator, test, source extension, and
projection behavior, then republishing generated projections from restored
source state. Record rollback notes in `support/implementation-run.md` and in
retained evidence.

Rollback must not use generated projections or proposal-local receipts as
source authority. If rollback requires hand-editing generated outputs, stop and
report `blocked-generated-authority`.

## Terminal Criteria

The implementation route is complete only when:

- all durable edits are within approved promotion targets or explicitly
  validated derived publication outputs;
- required validators pass or blockers are recorded without success claims;
- `support/implementation-run.md` exists and records implementation outcome;
- `support/implementation-conformance-review.md` exists and passes;
- `support/post-implementation-drift-churn-review.md` exists and passes;
- `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model`
  passes;
- `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model`
  passes;
- retained evidence exists outside `inputs/**` for validation, publication,
  generated freshness, and runner behavior as applicable.

Refuse closeout or archive claims until conformance and drift receipts pass.
The next lifecycle route after successful implementation is promotion or
verification according to the proposal lifecycle runner, not manual status
mutation from this prompt.

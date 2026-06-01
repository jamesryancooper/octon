# Executable Implementation Prompt

generated_at: 2026-06-01T04:04:37Z
proposal_path: `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-workflow-retry-ids`
proposal_id: `proposal-program-runner-workflow-retry-ids`
route: `run-packet-implementation`

## Authority And Gate Posture

This prompt is an operational aid for one accepted proposal packet. It does
not approve execution, widen scope, rewrite lifecycle status, replace retained
evidence, or make proposal-local files authoritative.

Before durable edits, re-run and require a clean pass:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-workflow-retry-ids --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-workflow-retry-ids
```

Profile Selection Receipt:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- profile rationale: `proposal.yml` and the workspace charter both declare
  atomic pre-1.0 work; retry id behavior must change as one coherent runtime
  cutover, not as a partial live state.
- transitional exception: `none`

## Target End State

Workflow leaf retry dispatches are collision-safe. Each new workflow command
dispatch uses an attempt-qualified workflow run id derived from the child route
run id and the current retry attempt ordinal. Resume of an existing workflow
run is not implicit: it is allowed only when same-input, same-authority,
same-target, replay-safe proof exists and is retained. Ambiguous existing
workflow state fails closed with evidence instead of overwriting workflow
control artifacts.

## In Scope

- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/workflow_leaf.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`

The implementation may update existing tests in
`.octon/framework/engine/runtime/crates/lifecycle_executor/tests/adapter.rs`
and may add focused unit tests inside `lifecycle_program.rs` if that is the
smallest existing test surface.

## Out Of Scope

- Any promotion target outside the three declared targets.
- New lifecycle statuses, proposal statuses, support tiers, authority models,
  workflow contracts, generated effective publication routes, or dependencies.
- Any rewrite of `proposal.yml#status`; leave it as `accepted`.
- Treating `.octon/inputs/**`, generated projections, chat history, host UI
  state, or packet support files as runtime authority or implementation proof.
- Broad proposal-program scheduler redesign unrelated to workflow retry run id
  identity.

## Workstreams

1. Inspect current dirty work before editing.
   - `git status --short`
   - `git diff -- .octon/framework/engine/runtime/crates/lifecycle_executor/tests/adapter.rs .octon/framework/engine/runtime/crates/lifecycle_executor/src/codex.rs`
   - Preserve unrelated edits. Do not revert or overwrite existing changes in
     `adapter.rs`; adapt around them.

2. Bind retry attempt identity from existing request data.
   - Reuse `LifecycleExecutionPolicy.retry_attempt` from
     `.octon/framework/engine/runtime/crates/lifecycle_executor/src/request.rs`.
   - In `workflow_leaf.rs`, derive a one-based attempt ordinal from
     `request.policy.retry_attempt`.
   - Use that ordinal in the workflow run id for new workflow dispatches, for
     example `"{request.run_id}-attempt-{ordinal}-workflow"`.
   - Include `retry_attempt`, `attempt_ordinal`, `parent/program context` when
     available, `child_id`, `route_id`, and `workflow_run_id` in retained
     workflow invocation and terminal evidence.

3. Prevent per-attempt evidence overwrite.
   - Make workflow leaf invocation, stdout, stderr, terminal, and completion
     observation evidence paths attempt-qualified, or otherwise retain every
     attempt without replacing an earlier attempt's files.
   - Ensure `LifecycleRouteExecutionResult.evidence_paths` reports the actual
     attempt-specific paths.

4. Separate new dispatch from existing-run resume.
   - Before dispatching the workflow command, detect whether the selected
     `workflow_run_id` already has existing workflow control or evidence state.
   - If it exists and same-input, same-authority, same-target, replay-safe
     proof is absent, do not dispatch. Return a failed route result using an
     existing `LifecycleErrorClass` and write retained evidence explaining the
     denied or ambiguous resume.
   - If explicit replay-safe resume is implemented, retain the proof beside
     the workflow leaf evidence and require it to name the original workflow
     run id, target, bound inputs, invocation authority, route id, and digest
     basis. Do not infer proof from proposal-local files.

5. Preserve program retry accounting.
   - In `lifecycle_program.rs`, keep child route retries using the same child
     route run id for checkpoint continuity, but ensure each executor retry
     passes a distinct `retry_attempt` into the request before dispatch.
   - Verify `ProgramChildExecutionSummary.attempts` still reports total
     executor attempts and that `evidence_paths` includes the attempt-qualified
     workflow leaf evidence.
   - Preserve existing recovery budget, blocker, cancellation, and authority
     behavior.

6. Add regression coverage.
   - Add lifecycle executor tests proving workflow route retry attempts produce
     distinct workflow run ids and retain distinct invocation/terminal
     evidence.
   - Add a negative control proving an existing workflow run id cannot be
     silently reused without replay-safe proof.
   - Add or adjust kernel/program tests proving a child workflow retry after
     an executor failure no longer reuses the same canonical workflow run id
     and that the final duplicate run-id failure pattern is covered.

7. Cleanup pass.
   - Keep helpers local to existing modules unless reuse is clear.
   - Do not add dependencies.
   - Remove any temporary fixture residue produced by tests.

## Required Evidence And Receipts

After durable changes land, create or update:

- `support/implementation-run.md`
  - include at least `verdict`, `implemented_at`, and
    `promotion_evidence_count`
  - count only durable promotion evidence, validation evidence, or retained
    runtime evidence; do not count this prompt as implementation proof
- `support/implementation-conformance-review.md`
  - include `verdict` and `unresolved_items_count`
  - map each acceptance criterion to durable code/tests/evidence
- `support/post-implementation-drift-churn-review.md`
  - include `verdict` and `unresolved_items_count`
  - confirm no scope widening, stale generated output claim, proposal-path
    dependency, or unrelated churn
- `support/validation.md`
  - record commands, verdicts, evidence class, retained evidence path or reason
    retained evidence is not required, and known gaps

Keep `proposal.yml#status` as `accepted`. The later `promote-proposal` route
owns any rewrite to `implemented`.

## Validation Commands

Run the packet gates and subtype validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-workflow-retry-ids
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-workflow-retry-ids
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-workflow-retry-ids --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-workflow-retry-ids
```

Run focused Rust validation from the runtime crate workspace:

```sh
(cd .octon/framework/engine/runtime/crates && cargo test -p octon_lifecycle_executor --test adapter workflow)
(cd .octon/framework/engine/runtime/crates && cargo test -p octon_lifecycle_executor)
(cd .octon/framework/engine/runtime/crates && cargo test -p octon_kernel --bin octon lifecycle_program)
```

After writing the post-implementation receipts, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-workflow-retry-ids
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-workflow-retry-ids
```

If any command fails, record the failure and route to correction or packet
revision. Do not claim implementation success from partial validation.

## Rollback Posture

Rollback is patch reversal of the workflow leaf retry-id changes and related
tests. Because this is atomic clean-break runtime behavior, do not leave a
state where workflow run ids are attempt-qualified but evidence paths,
program summaries, or resume guards still use the old single-id semantics.

## Terminal Criteria

The implementation route may report `verdict: pass` only when all are true:

- every declared promotion target needed by the packet has landed in durable
  repo files outside the proposal path;
- retries after workflow failure do not reuse a canonical workflow run id;
- existing workflow run resume is fail-closed unless replay-safe proof exists;
- ambiguous existing workflow state writes retained evidence and does not
  overwrite control artifacts;
- tests cover the final archive retry duplicate run-id failure pattern;
- `support/implementation-run.md`,
  `support/implementation-conformance-review.md`, and
  `support/post-implementation-drift-churn-review.md` exist and pass their
  validators;
- `proposal.yml#status` remains `accepted`;
- no generated output, registry projection, proposal-local support file, or
  external dashboard is used as implementation proof.

Refuse implemented, closeout, archive-ready, or final success claims while
either post-implementation receipt is missing, failing, unresolved, blocked, or
stale.

## Delegation

Delegation is optional. If used, keep an integration owner and disjoint write
scopes:

- worker A: `workflow_leaf.rs` attempt-qualified dispatch and evidence
- worker B: lifecycle executor adapter tests
- worker C: `lifecycle_program.rs` retry propagation and kernel tests

Do not make subagents a control requirement. The integration owner must review
the combined diff, run validation, and own the receipts.

implementation_prompt_id: proposal-program-retry-step-budget-controls-implementation-20260708T011034Z
generated_at: 2026-07-08T01:10:34Z
packet_path: .octon/inputs/exploratory/proposals/architecture/proposal-program-retry-step-budget-controls
proposal_review_ref: support/proposal-review.md
pre_integration_architecture_review_ref: support/pre-integration-architecture-review.yml
reviewed_packet_digest: sha256:5db977a6c0feef9e62521128c1bca6ca72c5d80926ba235700d572b560056e00
implementation_prompt_authorized: yes
non_authority_classification: operational-aid-only

# Executable Implementation Prompt

## Target End State

Add explicit bounded retry controls to `octon lifecycle program retry` for an
existing proposal-program lifecycle run:

- `--max-steps <n>`
- `--timeout-seconds <n>`
- `--max-child-concurrency <n>`

The retry command must preserve default behavior when these options are
omitted. Supplied retry-time options apply only to the controller execution
attempt and must flow through normal checkpoint/run execution without creating
a new run identity or rewriting event truth.

## Authorized Promotion Targets

Implement only inside these targets:

- `.octon/framework/engine/runtime/crates/kernel/src/main.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/README.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-run-program-lifecycle/SKILL.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle-model.md`

Do not change proposal-program child ordering, child ownership, delivery
semantics, closeout, archive, cleanup, terminal proof, generated/effective
outputs, support-targets, authority routes, or proposal-program membership.

## Workstreams

1. Extend the `LifecycleProgramCmd::Retry` CLI variant with optional
   `max_steps`, `timeout_seconds`, and `max_child_concurrency` arguments.
2. Thread those retry options through lifecycle command dispatch into
   `retry_program_lifecycle_run`.
3. Update program retry execution so supplied retry options override retained
   checkpoint/default retry limits only for the current retry attempt.
4. Preserve omitted-option compatibility by retaining current checkpoint/default
   behavior when no retry-time option is supplied.
5. Add or update focused kernel regression tests proving:
   - default retry compatibility;
   - explicit multi-step retry;
   - timeout and child-concurrency option propagation;
   - child-filtered retry compatibility;
   - retry-time overrides cannot bypass binding, approval, blocker,
     cancellation, worktree, dependency, authority, or child-owned evidence
     gates.
6. Update lifecycle documentation so operators can use
   `octon lifecycle program retry --run-id <id> --max-steps <n>` instead of
   looping one-step retries or falling back to the generic lifecycle run
   workaround.

## Boundary Conditions

Retry-time overrides must not mutate or bypass:

- run id;
- lifecycle id;
- target;
- registry binding;
- run inputs;
- checkpoint identity;
- historical event truth;
- child registry ownership;
- cancellation tokens or cancelled checkpoint state;
- approval pauses;
- blocker states;
- worktree baseline and hygiene gates;
- generated/publication freshness gates;
- child dependency gates;
- stale evidence, timeout, failure, and authority-boundary stops;
- child-owned receipts, validation verdicts, closeout, archive, cleanup, and
  terminal proof.

Proposal-local files, generated prompts, generated outputs, dashboards, host
state, chat, model memory, and tool state are non-authority.

## Required Validation

Run these packet validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-retry-step-budget-controls
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-retry-step-budget-controls
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-retry-step-budget-controls --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-retry-step-budget-controls
```

Run focused kernel tests from `.octon/framework/engine/runtime/crates` using a
temporary cargo target directory when practical.

After implementation, write or refresh:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-retry-step-budget-controls
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-retry-step-budget-controls
```

Refuse closeout, archive-ready, landed, synced, and cleaned claims while
either post-implementation receipt is missing, failing, unresolved, or blocked.

## Evidence Requirements

`support/implementation-run.md` must record at least `verdict`,
`implemented_at`, and `promotion_evidence_count`.

`support/implementation-conformance-review.md` must record a pass verdict,
`unresolved_items_count: 0`, promotion target scope, acceptance criteria
coverage, and validator/test evidence.

`support/post-implementation-drift-churn-review.md` must record a pass verdict,
`unresolved_items_count: 0`, touched path scope, excluded churn, authority
boundary preservation, and validator/test evidence.

`support/validation.md` must list commands, cwd, exit code, and concise results
for packet validators and focused kernel tests.

## Rollback Posture

Rollback is a normal revert of the option additions, retry option plumbing,
tests, documentation changes, and packet support receipts. Do not hand-edit
generated/effective outputs for rollback. If implementation discovers that the
required behavior needs additional promotion targets or changes authority,
product semantics, child ownership, or terminal lifecycle ownership, stop and
route back to `revise-packet` and `review-packet`.

## Terminal Criteria

Leave `proposal.yml#status` as `accepted`. The separate `promote-proposal`
route owns the implemented status transition after implementation evidence
passes. After successful implementation, route to `promote-proposal`, then
`closeout-packet`, `proposal-packet-terminal-closeout`, `archive-proposal`,
and route-bound `branch-no-pr` Change closeout.

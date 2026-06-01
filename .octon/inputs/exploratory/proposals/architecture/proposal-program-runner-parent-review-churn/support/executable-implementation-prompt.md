# Executable Implementation Prompt

implementation_prompt_id: proposal-program-runner-parent-review-churn-implementation-prompt-20260601T204718Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-06-01T20:47:18Z
generator: octon-proposal-lifecycle-generate-packet-implementation-prompt
source_review_gate: passed
implementation_grade_readiness: passed

This prompt is an operational aid for the accepted proposal packet. It does
not approve execution, widen scope, replace the proposal manifest, replace
durable Octon authority, or substitute for retained implementation evidence.

## Prompt Generation Gate Receipt

This command was run before generating this prompt:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

## Mandatory Preflight

Before editing any file, re-read:

- repo ingress and the constitutional kernel required by `AGENTS.md`;
- `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`;
- `.octon/framework/execution-roles/practices/standards/ai-assisted-development-discipline.md`;
- `.octon/framework/execution-roles/practices/standards/repository-reconnaissance.md`;
- `.octon/framework/execution-roles/practices/standards/validation-evidence-quality.md`;
- this packet's `proposal.yml` and `architecture-proposal.yml`;
- `navigation/source-of-truth-map.md`;
- `navigation/artifact-catalog.md`;
- `architecture/target-architecture.md`;
- `architecture/implementation-plan.md`;
- `architecture/acceptance-criteria.md`;
- `validation-plan.md`;
- `resources/source-lineage.md`;
- `support/implementation-grade-completeness-review.md`;
- `support/proposal-review.md`;
- the live promotion targets listed below.

Then run these gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn
```

Refuse implementation unless all commands pass, `proposal.yml#status` is
`accepted`, `support/proposal-review.md` has `verdict: accepted`,
`implementation_prompt_authorized: yes`, `open_blocking_findings_count: 0`,
and the reviewed packet digest is fresh.

Profile Selection Receipt for this packet:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: one coherent review-freshness stabilization across runtime
  planner behavior, review digest scope, and lifecycle contract gates
- transitional exception: not authorized

## Target End State

Implement only the accepted child packet for parent review churn suppression.
The end state is:

- Parent proposal-program review freshness is based on the parent-owned
  proposal and coordination surface.
- The reviewed digest changes when parent-authored coordination facts change,
  including program intent, child registry, authority contract, promotion
  targets, or other parent-owned lifecycle coordination files.
- The reviewed digest does not change solely because volatile run-control
  state, retained route evidence, generated support prompts, implementation
  receipts, conformance receipts, drift receipts, closeout receipts, or
  route-created run residue changed outside the reviewed coordination scope.
- Strict implementation authorization remains enforced before routes that
  require accepted review authorization.
- Implemented-state routes follow the lifecycle contract's implemented-state
  gates and do not regain accepted-only review requirements unless the
  contract declares them.
- Parent receipts summarize parent coordination only; child receipts,
  child validation verdicts, child promotion targets, child archive metadata,
  and child lifecycle outcomes remain child-owned.
- `proposal.yml#status` remains `accepted`; the `promote-proposal` lifecycle
  route owns the implemented-status rewrite.

## In Scope

Durable edits may touch only these approved promotion targets:

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`

Packet-local evidence writes after implementation may touch only:

- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn/support/post-implementation-drift-churn-review.md`

Tests are required by the packet validation plan, but standalone test files are
not promotion targets. Use existing validators and, where durable new test code
is necessary, prefer focused Rust tests embedded in
`.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`. If
credible standalone test edits are required outside the approved targets, stop
and record a blocked implementation outcome that routes to packet revision
instead of widening scope.

## Out Of Scope

Do not:

- edit sibling proposal packets or the parent program packet;
- hand-edit `.octon/generated/effective/**`, `.octon/generated/proposals/**`,
  or generated operator read models;
- mutate `.octon/state/control/**` or `.octon/state/evidence/**` except
  retained evidence created by validation, publication, or lifecycle commands;
- weaken strict review authorization for `generate-packet-implementation-prompt`,
  `run-packet-implementation`, `generate-program-implementation-orchestration-prompt`,
  or `promote-proposal` when the lifecycle contract requires it;
- use parent evidence to satisfy child receipts or child promotion evidence;
- introduce new authority zones, recovery budgets, support targets, lifecycle
  ids, routes, or prompt sets;
- change `proposal.yml#status`;
- claim implemented, promoted, closeout-ready, archive-ready, or archived while
  any required post-implementation receipt is missing, failing, unresolved, or
  blocked.

## Ordered Workstreams

### 1. Baseline And Search Receipt

1. Record the current worktree state and preserve unrelated existing changes.
2. Run the mandatory preflight gates.
3. Search before changing behavior:

```sh
rg -n "reviewed_packet_digest|receipt_fresh|proposal-review|program-review-authorization|generate-program-implementation-orchestration-prompt|promote-proposal|implemented|route-created|support/" .octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml
```

4. Record the reused surfaces and rejected alternatives in
   `support/implementation-run.md` after durable changes land.

### 2. Review Digest Scope

1. Inspect `validate-proposal-review-gate.sh` and its `reviewed_file_inventory`
   behavior.
2. Keep parent-authored coordination files inside the digest.
3. Exclude route-created support receipts and volatile operational artifacts
   that do not alter reviewed parent coordination facts. The exclusion set
   must cover packet and program lifecycle support outputs declared by the
   lifecycle artifact contract, including implementation prompts, follow-up
   verification prompts, correction prompts, closeout prompts, implementation
   run receipts, conformance receipts, post-implementation drift receipts,
   lifecycle residue cleanup receipts, validation scratch files, and route-run
   summaries.
4. Preserve stale-review detection for actual parent coordination changes.
5. Preserve the existing negative behavior where unknown old prompt names or
   unclassified support files still stale review until intentionally classified.

### 3. Program Route Gate Semantics

1. Inspect `proposal-program.contract.yml` and
   `lifecycle_program.rs` program route planning.
2. Ensure strict review gates remain required for accepted-state routes that
   authorize implementation or promotion, especially
   `generate-program-implementation-orchestration-prompt` and
   `promote-proposal`.
3. Ensure implemented-state routes such as program verification, correction,
   closeout, lifecycle-residue cleanup, and archive follow their contract
   `enter_when` conditions and do not fail solely because a parent accepted
   review is no longer an accepted-state gate.
4. If contract metadata is needed to make the boundary explicit, add the
   smallest field to the source lifecycle contract and validate that unknown or
   malformed contract shapes still fail closed.

### 4. Runtime Planner Behavior

1. Re-read `build_target_state`, `receipt_plan_states`, receipt freshness,
   `plan_program_level_route`, parent promotion evidence, and parent/child
   authority-boundary helpers in `lifecycle_program.rs`.
2. Keep receipt freshness generic and contract-driven; do not hard-code a
   proposal-local bypass in the runner when the validator or contract is the
   correct source.
3. Add focused embedded tests in `lifecycle_program.rs` when needed to prove:
   - irrelevant route-created parent support artifacts do not stale the parent
     review gate;
   - parent-owned coordination changes still stale the parent review gate;
   - implemented-state program routes remain enterable under their declared
     gates without accepted-only review churn;
   - child receipts and child promotion evidence remain child-owned.

### 5. Publication And Generated Outputs

If `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
changes, publish generated/runtime projections through canonical scripts only:

```sh
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh
bash .octon/framework/assurance/runtime/_ops/scripts/publish-pack-routes.sh
bash .octon/framework/assurance/runtime/_ops/scripts/publish-runtime-route-bundle.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh
```

Generated files are derived outputs, not promotion targets or authority. Do
not edit generated files by hand. Record generated publication receipt paths
and validation results in `support/implementation-run.md`.

### 6. Blocker Handling

If any required behavior cannot be implemented inside the approved targets,
stop and create `support/implementation-run.md` with:

- `verdict: blocked`
- `implemented_at`
- `promotion_evidence_count: 0`
- the exact blocker class and evidence
- the required next route, such as `revise-packet`
- confirmation that no implemented, promoted, closeout, or archive claim is
  being made

Do not invent authority, widen support claims, accept stale evidence, or use
proposal-local support files as proof of durable implementation.

## Validation Commands

Run packet validators before and after durable edits:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn
```

Run implementation validators relevant to the touched durable targets:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-route-bundle.sh
```

Run focused tests or their updated successors:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-review-gate.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-lifecycle-contracts.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-proposal-program-runner-fixture-matrix.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-authority-boundaries.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-route-resolution.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-pack-shape.sh
(cd .octon/framework/engine/runtime/crates && cargo test -p octon_kernel program_review_workflow -- --nocapture)
(cd .octon/framework/engine/runtime/crates && cargo test -p octon_kernel parent_evidence_cannot_satisfy_child_receipt_or_child_authority_surfaces -- --nocapture)
```

After `support/implementation-run.md` is created or updated, create or update
`support/implementation-conformance-review.md` and run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn
```

Then create or update `support/post-implementation-drift-churn-review.md` and
run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn
```

## Required Evidence Outputs

After durable changes and validation, create or update
`support/implementation-run.md` with at least:

- `verdict`: `pass`, `blocked`, or `fail`
- `implemented_at`
- `promotion_evidence_count`
- implementation summary tied to each approved promotion target
- generated/runtime publication receipts, if any
- validation commands and results
- retained evidence paths
- rollback summary
- explicit confirmation that `proposal.yml#status` remains `accepted`

Then create or update `support/implementation-conformance-review.md` with:

- `verdict`
- `unresolved_items_count`
- `Blockers`
- `Checked Evidence`
- `Promotion Target Coverage`
- `Implementation Map Coverage`
- `Validator Coverage`
- `Generated Output Coverage`
- `Rollback Coverage`
- `Downstream Reference Coverage`
- `Exclusions`
- `Final Closeout Recommendation`

Then create or update `support/post-implementation-drift-churn-review.md`
with:

- `verdict`
- `unresolved_items_count`
- `Blockers`
- `Checked Evidence`
- `Backreference Scan`
- `Naming Drift`
- `Generated Projection Freshness`
- `Manifest And Schema Validity`
- `Repo-Local Projection Boundaries`
- `Target Family Boundaries`
- `Churn Review`
- `Validators Run`
- `Exclusions`
- `Final Closeout Recommendation`

Retained validation evidence should live outside `inputs/**`, preferably under:

```text
.octon/state/evidence/validation/proposals/proposal-program-runner-parent-review-churn/<timestamp>/
```

Do not store retained evidence in `generated/**`, and do not treat generated
support prompts or packet-local support receipts as durable implementation
proof.

## Rollback Posture

Rollback is patch reversal of the approved promotion targets plus regeneration
of derived outputs from the reverted source if publication changed. Rollback
must preserve the parent/child authority boundary: parent review receipts
remain parent-local; child receipts, child promotion evidence, and child
archive metadata remain child-owned.

## Terminal Criteria

Implementation may be called complete only when all of these are true:

- parent review freshness ignores irrelevant route-created or retained
  operational churn;
- parent review freshness still detects parent-owned coordination changes;
- strict implementation authorization remains enforced before routes that
  require it;
- implemented-state routes use contract-declared implemented-state behavior;
- approved promotion targets and only those targets carry durable source
  changes, excluding generated publications produced by canonical scripts;
- required validation passes or a blocked receipt records the exact failing
  gate;
- `support/implementation-run.md` exists with the required fields;
- `support/implementation-conformance-review.md` exists and
  `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn`
  passes;
- `support/post-implementation-drift-churn-review.md` exists and
  `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-parent-review-churn`
  passes;
- `proposal.yml#status` remains `accepted`.

Refuse implemented, closeout, archive-ready, or archived claims while either
post-implementation receipt is missing, failing, unresolved, stale, blocked, or
not validated by its required script.

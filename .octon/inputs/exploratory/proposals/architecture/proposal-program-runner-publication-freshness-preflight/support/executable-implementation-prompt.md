# Executable Implementation Prompt

proposal_id: proposal-program-runner-publication-freshness-preflight
generated_at: 2026-06-01T19:22:19Z
generator: octon-proposal-lifecycle-generate-packet-implementation-prompt
source_review_gate: passed
implementation_grade_readiness: passed
proposal_path: .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-publication-freshness-preflight

## Execution Role

Implement only the accepted packet for proposal-program runner publication
freshness preflight. The target end state is: before the proposal-program
controller dispatches a child route that depends on current runtime-facing
generated/effective state, it can classify stale extension catalog, capability
routing, pack route, runtime route-bundle, or related read-model publication
drift as `publication-drift`; emit one retained, actionable blocker; cite only
canonical publication scripts or the declared `refresh-publication-projections`
recovery action; replan after recovery; and verify `publication-freshness-cleared`
before resuming dispatch.

Keep generated/effective outputs derived-only. Do not use proposal-local
support files, parent evidence, generated projections, raw additive inputs, or
operator comments as implementation proof or runtime authority.

## Promotion Targets

Durable implementation may land only in these packet-approved targets:

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`

Proposal-local writes are limited to post-implementation support receipts under:

- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-publication-freshness-preflight/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-publication-freshness-preflight/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-publication-freshness-preflight/support/post-implementation-drift-churn-review.md`

## Out Of Scope

- Hand-editing `.octon/generated/effective/**`, generated operator read models,
  or retained evidence.
- Widening support targets, capability packs, authority zones, recovery budgets,
  or unattended execution authority.
- Replacing child-owned receipts with parent or program-level evidence.
- Mutating unrelated proposal-program children or their proposal packets.
- Changing `proposal.yml#status`; leave it as `accepted`.
- Claiming implementation, closeout, archive readiness, or promotion before all
  post-implementation gates pass.

## Required Workstreams

1. Re-read this packet's `proposal.yml`, `architecture/target-architecture.md`,
   `architecture/implementation-plan.md`, `architecture/acceptance-criteria.md`,
   `validation-plan.md`, `resources/source-lineage.md`,
   `support/implementation-grade-completeness-review.md`, and
   `support/proposal-review.md`.
2. Reconfirm live repository state before editing:
   `lifecycle_program.rs`, `proposal-program.contract.yml`, the publication
   freshness validators, runtime-effective handle validators, publication
   scripts, proposal-program tests, and current generated/effective locks.
3. Add the smallest pre-dispatch freshness classification path in the
   proposal-program runner. Prefer reusing existing validator or handle-check
   behavior over duplicating digest logic. The classification must cover, at
   minimum, extension catalog/generation lock, capability routing/generation
   lock when present, pack routes, runtime route bundle, and any read-model
   freshness dependency already enforced by publication validators.
4. When drift is found, fail closed before avoidable child-route dispatch. Emit
   one `publication-drift` blocker for the affected child or program step, with
   retained evidence in the existing run evidence/control pattern and a message
   that names exact canonical recovery commands or the declared recovery action.
5. Keep recovery bound to existing authority:
   `refresh-publication-projections`, `publication-freshness-cleared`, and the
   proposal-program recovery policy. If new contract metadata is necessary,
   add it only in `proposal-program.contract.yml` and validate lifecycle
   contract parsing.
6. Add focused tests for both stale and fresh states:
   stale generated/effective state blocks before child dispatch, recovery
   guidance is canonical, generated outputs remain non-authority, parent
   evidence cannot waive stale child state, recovery replans, and freshness
   clearing permits dispatch/resume.
7. If authored changes require generated publication refresh, run only the
   canonical publication scripts. Never edit generated files directly.
8. Record implementation evidence only after durable changes and validation
   land. If a blocker prevents implementation inside the approved targets,
   write `support/implementation-run.md` with `verdict: blocked` and cite the
   concrete evidence instead of broadening scope.

## Canonical Recovery Guidance

Use only these recovery commands or declared route actions in blocker text:

```sh
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/publish-pack-routes.sh
bash .octon/framework/assurance/runtime/_ops/scripts/publish-runtime-route-bundle.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh
```

Declared program recovery action:

- `refresh-publication-projections`

Do not invent a new publication command, recovery action, waiver, or exception
path. If a canonical publisher or validator is missing or fails, report a
blocked implementation outcome with evidence.

## Validation Commands

Run the packet gates before and after implementation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-publication-freshness-preflight --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-publication-freshness-preflight
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-publication-freshness-preflight
```

Run the implementation validators relevant to touched targets:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-effective-freshness.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-artifact-handles.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-route-bundle.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-no-raw-generated-effective-runtime-reads.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
```

Run focused tests or their updated successors:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-publication-freshness-gates.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-runtime-effective-freshness-hard-gate.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-stale-digest-bound-route-bundle-denial.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-runtime-effective-state.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-capability-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-lifecycle-contracts.sh
(cd .octon/framework/engine/runtime/crates && cargo test -p octon_kernel publication -- --nocapture)
(cd .octon/framework/engine/runtime/crates && cargo test -p octon_kernel proposal_program -- --nocapture)
```

If generated publication was refreshed, rerun the publication validators after
the final generated state is in place and retain the publication receipt paths
in `support/implementation-run.md`.

## Required Evidence Outputs

After durable changes and validation, create or update
`support/implementation-run.md` with at least:

- `verdict`: `pass`, `blocked`, or `fail`
- `implemented_at`
- `promotion_evidence_count`
- implementation summary tied to the approved promotion targets
- generated/runtime publication receipts, if any
- validation commands and results
- retained evidence paths
- rollback summary
- explicit confirmation that `proposal.yml#status` remains `accepted`

Then create or update `support/implementation-conformance-review.md` with:

- `verdict`
- `unresolved_items_count`
- sections required by
  `validate-proposal-implementation-conformance.sh`: `Blockers`,
  `Checked Evidence`, `Promotion Target Coverage`,
  `Implementation Map Coverage`, `Validator Coverage`,
  `Generated Output Coverage`, `Rollback Coverage`,
  `Downstream Reference Coverage`, `Exclusions`, and
  `Final Closeout Recommendation`

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-publication-freshness-preflight
```

Then create or update `support/post-implementation-drift-churn-review.md` with:

- `verdict`
- `unresolved_items_count`
- sections required by
  `validate-proposal-post-implementation-drift.sh`: `Blockers`,
  `Checked Evidence`, `Backreference Scan`, `Naming Drift`,
  `Generated Projection Freshness`, `Manifest And Schema Validity`,
  `Repo-Local Projection Boundaries`, `Target Family Boundaries`,
  `Churn Review`, `Validators Run`, `Exclusions`, and
  `Final Closeout Recommendation`

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-publication-freshness-preflight
```

## Rollback Posture

Rollback is patch reversal of the freshness preflight and recovery guidance
changes. Preserve enough evidence to reverse edits to `lifecycle_program.rs`,
any changed assurance scripts/tests, and
`proposal-program.contract.yml`. Generated outputs refreshed by canonical
publication scripts are reversible by rerunning publishers from the reverted
authored state; do not manually edit them for rollback.

## Terminal Criteria

Implementation is complete only when:

- stale generated/effective or read-model freshness drift fails closed before
  avoidable child dispatch;
- fresh state permits route dispatch without a `publication-drift` blocker;
- recovery guidance cites only canonical publication scripts or
  `refresh-publication-projections`;
- replan and `publication-freshness-cleared` validation are proven;
- generated/effective outputs remain non-authority and are never hand-edited;
- parent/program evidence does not waive stale child state;
- required validation commands pass or a blocked receipt records the exact
  failing command and evidence;
- `support/implementation-run.md`,
  `support/implementation-conformance-review.md`, and
  `support/post-implementation-drift-churn-review.md` exist with passing
  verdicts for a success claim;
- both post-implementation validators pass;
- `proposal.yml#status` remains `accepted`.

Refuse implemented, closeout, archive-ready, or promotion claims while any
required receipt is missing, stale, failing, unresolved, or blocked. The
`promote-proposal` lifecycle route owns the eventual implemented-status rewrite.

# Executable Implementation Prompt

prompt_id: proposal-program-runner-archive-observation-recovery-implementation
proposal_path: `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-archive-observation-recovery`
route_id: `run-packet-implementation`
operational_role: implementation aid only

This prompt is not authority, approval, promotion evidence, closeout evidence,
or archive authorization. It is executable guidance for implementing the
accepted packet through its declared promotion targets only.

## Required Preflight

Before making durable changes, re-run the implementation authorization gate:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-archive-observation-recovery --require-implementation-authorization
```

Refuse implementation if the gate fails, the accepted review is stale, open
blocking findings are nonzero, or `implementation_prompt_authorized` is not
`yes`.

Bind the run to:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: one coherent implementation across the declared target set,
  with no partial live state and no success claim before post-cutover
  validation passes.

## Target End State

Archive mutation remains owned by the `archive-proposal` workflow route. The
lifecycle executor observes terminal archive state after the active proposal
path moves to `.octon/inputs/exploratory/proposals/.archive/<kind>/<id>/`,
records machine-readable blocked archive evidence when archive convergence
cannot be proven, and replans from live state.

The parent proposal-program runner must consume blocked archive evidence as a
blocker. It must not claim child terminal completion, parent closeout, or
aggregate closeout from parent-owned summaries while child archive state,
child receipts, child validation verdicts, promotion targets, and archive
metadata remain child-owned.

## In Scope

Durable edits are limited to these promotion targets:

- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/observer.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/workflow_leaf.rs`
- `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`

Use adjacent files only for reading, tests that live with the touched Rust
modules, generated publication outputs required by validated workflow changes,
and retained evidence references.

## Out Of Scope

- Do not move archive mutation into `lifecycle_executor` or
  `lifecycle_program.rs`.
- Do not edit `proposal.yml#status`; leave it `accepted`. The
  `promote-proposal` lifecycle route owns the implemented-status rewrite.
- Do not add new durable promotion targets, lifecycle routes, authority
  surfaces, support claims, or proposal-local child workspaces.
- Do not use proposal-local support files as implementation proof; they may
  point to retained evidence, but proof must come from tests, validators,
  runtime observations, publication receipts, or retained evidence roots.
- Do not claim implemented, closeout-ready, or archive-ready while required
  post-implementation receipts are missing, failing, stale, unresolved, or
  blocked.

## Workstreams

1. Reconfirm current archive behavior.
   Inspect `observer.rs`, `workflow_leaf.rs`, the `archive-proposal` workflow
   contract, and the proposal-program lifecycle paths in `lifecycle_program.rs`.
   Preserve the existing archived-target observation behavior for active-path
   moves.

2. Add blocked archive evidence in `workflow_leaf.rs`.
   Emit retained YAML evidence under the route `evidence_root` for fail-closed
   archive blockers. Cover at least:
   - duplicate workflow run id or existing workflow state without replay-safe
     resume proof;
   - stale or incompatible workflow state for the current target, authority,
     or attempt;
   - missing, incomplete, failed, or non-authorizing archive receipt state
     before dispatch;
   - workflow failure, timeout, cancellation, or successful workflow exit where
     archive completion is not observed at the archived target.

   Use a stable machine-readable schema such as
   `octon-lifecycle-archive-blocked-evidence-v1` with `run_id`, `route_id`,
   `workflow_run_id`, `attempt_ordinal`, `blocker_class`, `reason`,
   `target`, `observation_target`, `completion_observed`, receipt summaries,
   `next_action`, `authority_boundary`, and any source evidence paths. Keep
   `next_action` fail-closed, usually `manual-intervention` or replan only
   when live state can be safely re-observed.

3. Harden archive observation in `observer.rs`.
   Keep the observation target switch limited to `archive-proposal` with
   expected status `archived`. Ensure receipt observation, manifest status,
   and missing expected paths are evaluated against the archived target when
   the active target has moved, and fail closed when neither active nor
   archived target proves terminal state.

4. Preserve workflow-owned archive semantics.
   Update `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`
   only to make the workflow contract, stage guidance, done gate, and evidence
   expectations match the runtime behavior. The workflow remains the only
   surface that moves the proposal packet, rewrites archive metadata, and
   regenerates proposal registry outputs.

5. Update proposal-program consumption in `lifecycle_program.rs`.
   Treat blocked archive evidence and archive route failures as child blockers.
   Do not set `terminal_outcome=archived` unless the child manifest is
   archived at the archived child target and required child-owned receipts are
   fresh. Parent aggregate evidence may summarize blockers, but it must retain
   the authority boundary that child manifests, receipts, validation verdicts,
   promotion evidence, and archive metadata remain child-owned.

6. Add focused tests.
   Cover:
   - archived target observation after active path movement;
   - duplicate workflow run id or stale workflow state emits blocked archive
     evidence;
   - missing archive authorization emits blocked archive evidence;
   - workflow success without terminal archive observation emits blocked
     archive evidence and a non-completed route result;
   - proposal-program parent closeout remains blocked until child terminal
     policy and child-owned receipts pass.

7. Publish generated/runtime outputs only when implicated.
   If `archive-proposal` workflow contract or stage files change in a way that
   affects runtime-effective workflow routing, run the runtime route-bundle
   publisher and freshness gates. Retain publication evidence under existing
   `.octon/state/evidence/validation/**` roots. Do not hand-edit generated
   runtime outputs as authority.

## Validation Commands

Run these from the repository root unless a command says otherwise:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-archive-observation-recovery --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-archive-observation-recovery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-archive-observation-recovery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-archive-observation-recovery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-archive-proposal-workflow.sh
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_lifecycle_executor
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel
```

If workflow publication is implicated, also run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/publish-runtime-route-bundle.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-artifact-handles.sh
```

During development, use focused Rust tests first, then finish with the full
package commands above.

## Required Evidence Outputs

After durable changes land, create or update
`support/implementation-run.md` with at least:

```yaml
verdict: pass|blocked
implemented_at: <RFC3339 timestamp>
promotion_evidence_count: <number>
```

The implementation run receipt must list touched promotion targets, validation
commands run, retained evidence refs, publication receipt refs when any
generated/runtime publication occurs, and blocker evidence refs when verdict
is `blocked`.

Then create or update `support/implementation-conformance-review.md` and run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-archive-observation-recovery
```

The conformance review must include `verdict`, `unresolved_items_count`,
Blockers, Checked Evidence, Promotion Target Coverage, Implementation Map
Coverage, Validator Coverage, Generated Output Coverage, Rollback Coverage,
Downstream Reference Coverage, Exclusions, and Final Closeout Recommendation.

Then create or update
`support/post-implementation-drift-churn-review.md` and run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-archive-observation-recovery
```

The drift/churn review must include `verdict`, `unresolved_items_count`,
Blockers, Checked Evidence, Backreference Scan, Naming Drift, Generated
Projection Freshness, Manifest And Schema Validity, Repo-Local Projection
Boundaries, Target Family Boundaries, Churn Review, Validators Run,
Exclusions, and Final Closeout Recommendation.

Retain validation transcripts or summaries under existing Octon evidence roots,
preferably `.octon/state/evidence/validation/**` or
`.octon/state/evidence/runs/workflows/**` when the implementation run creates
workflow evidence. Do not store evidence in `.octon/generated/**`.

## Rollback Posture

Rollback is patch reversal of archive observation, blocked archive evidence,
workflow guidance, and parent consumption changes. If generated runtime outputs
are published, rollback must include re-running the same publisher and
freshness validators so generated-effective route state matches the reverted
authored workflow inputs.

If any validation, publication, or post-implementation receipt fails, record
`verdict: blocked` in `support/implementation-run.md` with the blocker class,
failed command, retained evidence path, and next route condition. Do not
rewrite `proposal.yml#status`, do not claim implemented, and do not route to
closeout/archive.

## Terminal Criteria

The implementation is complete only when all of these are true:

- durable edits are limited to the four declared promotion target families;
- archive mutation remains workflow-owned;
- blocked archive evidence is emitted for non-converged archive attempts;
- parent proposal-program closeout remains blocked until child terminal policy
  and child-owned receipts pass;
- required Rust tests and proposal/workflow validators pass;
- required generated/runtime publication, if implicated, has fresh validation
  evidence;
- `support/implementation-run.md`,
  `support/implementation-conformance-review.md`, and
  `support/post-implementation-drift-churn-review.md` exist and their
  validators pass;
- `proposal.yml#status` remains `accepted` for the promote route to update.

Delegation is optional. If used, split only by disjoint write scopes, keep one
integration owner, and ensure workers know they are not alone in the codebase
and must not revert or overwrite other changes.

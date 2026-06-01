# Executable Implementation Prompt

generated_at: 2026-06-01T11:34:18Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-aggregate-terminal-blockers
proposal_id: proposal-program-runner-aggregate-terminal-blockers
route: generate-packet-implementation-prompt
review_gate: passed
implementation_grade_readiness: passed

This file is an operational aid. It does not approve implementation, widen
scope, authorize cleanup, authorize Git mutation, replace proposal manifests,
or turn packet-local support files into durable Octon authority.

## Authority And Gate Posture

Before any durable edit, re-run the proposal gates and stop fail-closed on any
error, stale review, missing implementation authorization, open blocker, or
scope mismatch:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-aggregate-terminal-blockers --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-aggregate-terminal-blockers
```

Record a Profile Selection Receipt before implementation:

- release_state: pre-1.0
- change_profile: atomic
- rationale: `proposal.yml` and workspace defaults require one coherent change.
  Runtime evidence emission, active proposal-program closeout policy, runtime
  specs, tests, and generated effective publication must move together so no
  live state either emits uncontracted aggregate blocker evidence or advertises
  blocker evidence the runner cannot produce.
- transitional exception: none

Leave `proposal.yml#status` as `accepted`. The `promote-proposal` lifecycle
route owns any later implemented-status rewrite.

## Target End State

The proposal-program parent controller writes controller-owned aggregate child
terminal blocker evidence when required children are blocked from satisfying
the active program closeout policy. The evidence lists every currently blocked
required child in one pass, including:

- child id
- child lifecycle id and child target
- selected or required route id
- blocker class and blocker message
- child receipt freshness status
- terminal policy status
- worktree or hygiene state
- retry or recovery state
- next route condition
- authority boundary notice

Parent program routes may cite this aggregate evidence for scheduling,
closeout planning, operator guidance, and blocked-gate diagnosis. They must not
treat it as child manifest truth, child receipt truth, child validation
verdict, child promotion evidence, archive metadata, closeout authorization,
or implementation proof.

Child manifests, child receipts, child validation verdicts, child promotion
targets, child archive metadata, and child terminal lifecycle outcomes remain
child-owned. Parent aggregate evidence summarizes only.

## In Scope

Implement only the declared durable promotion targets:

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/spec/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`

Focused tests may be added or updated inside the Rust crate test surface when
needed to prove the runtime behavior of `lifecycle_program.rs`. Runtime spec
changes may add or update a schema or invariant document under
`.octon/framework/engine/runtime/spec/`. Generated effective extension outputs
may be refreshed only through the existing publication path.

## Out Of Scope

Do not change proposal manifest statuses, child packet lifecycle rules, child
receipt schemas, archive workflow authority, Git or hosted-provider behavior,
cleanup authorization, repo hygiene deletion, support-target declarations, or
promotion targets outside the three families above.

Do not make parent program evidence satisfy child receipts, child validation
verdicts, child promotion evidence, child archive metadata, implementation
receipts, closeout receipts, or post-implementation reviews.

Do not treat proposal-local support files, generated projections, chat history,
host state, GitHub metadata, CI dashboards, or external workflow engines as
durable implementation proof or Octon authority.

## Owned File Families

- Runtime controller:
  `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
  owns aggregate blocker discovery, receipt construction, evidence writing,
  status/read-model exposure, replay/checkpoint safety, and focused tests.
- Runtime spec:
  `.octon/framework/engine/runtime/spec/` owns the aggregate blocker evidence
  contract and any invariant wording needed to keep parent summary evidence
  separate from child authority.
- Lifecycle contract:
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
  owns proposal-program closeout policy, receipt declarations, generated
  effective route publication source, and no-widening authority boundaries.
- Generated effective publication:
  `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/context/lifecycles/proposal-program.contract.yml`
  and related extension catalog or generation lock files are derived outputs
  only. Refresh them through publication, never by hand as authority.

## Ordered Workstreams

1. Inspect and preserve current worktree state.

   Run `git status --short` and review current diffs before editing. Preserve
   unrelated changes, including changes in other proposal packets or lifecycle
   run directories.

2. Re-read live runtime and packet surfaces.

   Re-read this packet's manifests, `architecture/target-architecture.md`,
   `architecture/implementation-plan.md`, `architecture/acceptance-criteria.md`,
   `validation-plan.md`, `navigation/source-of-truth-map.md`, and
   `support/proposal-review.md`.

   Re-read the live proposal-program contract, lifecycle-program controller
   code, `lifecycle-program-controller-invariants.md`, and existing
   proposal-program tests before adding a new concept or surface.

3. Define the aggregate blocker evidence contract.

   Add or update a runtime spec under `.octon/framework/engine/runtime/spec/`
   for a parent-owned aggregate terminal blocker receipt. The contract must
   require:

   - stable `schema_version`
   - run id, lifecycle id, target, execution mode, and child registry digest
   - generated timestamp or equivalent retained evidence timestamp
   - one entry per blocked required child
   - the child fields listed in the target end state
   - explicit `authority_boundary` or `authority_notice` stating parent
     evidence summarizes only
   - no field that lets parent evidence overwrite or satisfy child receipts

   If the best existing spec home is an existing invariant document instead of
   a new schema, document why in `support/implementation-run.md` and still
   provide enough machine-readable or validator-backed structure to test the
   evidence.

4. Implement controller-owned aggregate emission.

   Extend `lifecycle_program.rs` so the program controller computes every
   required, non-deferred child that is blocked from satisfying the active
   closeout policy. Include children blocked by missing terminal outcome,
   disallowed terminal outcome, missing receipt, stale receipt, missing receipt
   fields, unresolved child blockers, worktree hygiene or artifact ownership
   blockers, exhausted or unavailable recovery, and missing next route.

   Write one aggregate evidence file for the current program run under the
   existing retained workflow evidence root, for example:

   - `.octon/state/evidence/runs/workflows/<program-run-id>/aggregate-terminal-blockers.yml`

   Keep the exact filename stable and cover it in the runtime spec and tests.
   Also expose the aggregate evidence reference or digest in the program plan,
   checkpoint, status read model, summary, or event log where needed for
   restart and diagnosis. If adding checkpoint fields, preserve backward
   compatibility for existing checkpoints and replay.

5. Preserve active closeout policy enforcement.

   Parent closeout/archive planning must continue to enforce:

   - required child terminal outcomes
   - child-owned receipt existence, completeness, freshness, and field values
   - deferred, superseded, or rejected child evidence
   - parent/child authority separation
   - aggregate evidence presence and freshness when the active policy requires
     aggregate evidence for blocked required children

   Program route receipts may cite aggregate blocker evidence, but they must
   never replace child-owned receipts or parent closeout receipts.

6. Update the proposal-program lifecycle contract.

   Update the proposal-program lifecycle contract only as needed to declare the
   aggregate blocker receipt or aggregate-evidence requirement. Preserve:

   - `parent_coordinates_only: true`
   - `child_receipts_remain_child_owned: true`
   - `child_promotion_targets_remain_child_owned: true`
   - `require_aggregate_evidence: true`
   - existing terminal child receipt requirements for archived and rejected
     children
   - existing recovery policy semantics unless a focused no-widening update is
     required for the aggregate evidence fields

7. Add focused tests and negative controls.

   Add or update tests proving:

   - multiple blocked required children appear in one aggregate blocker receipt
   - mixed archived, rejected, deferred, blocked, and missing-receipt children
     produce the expected closeout policy results
   - child-owned receipt requirements remain enforced even when aggregate
     evidence exists
   - parent closeout blocks when required aggregate blocker evidence is missing,
     stale, or digest-drifted
   - aggregate evidence is diagnostic and non-authorizing
   - generated status/read models, summaries, or route receipts cite aggregate
     evidence without becoming child authority

8. Refresh generated/runtime publications only through existing publication
   paths.

   If the additive proposal-program lifecycle contract changes, run the
   existing extension publisher:

   ```sh
   bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
   ```

   Retain publication evidence under the canonical validation or run evidence
   roots. Do not hand-edit generated effective files as source authority. If no
   publication refresh is required, record the reason in
   `support/implementation-run.md`.

9. Perform minimal cleanup.

   Remove only implementation artifacts created by this work that are not
   retained evidence. Do not delete unrelated untracked files or pre-existing
   local residue.

## Required Evidence And Receipts

After durable changes land, create or update `support/implementation-run.md`
with at least:

- `verdict`
- `implemented_at`
- `promotion_evidence_count`

`promotion_evidence_count` must count durable promotion, validation, runtime,
or publication evidence. This prompt and other generated support prompts do
not count as implementation proof.

Then create or update `support/implementation-conformance-review.md` and run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-aggregate-terminal-blockers
```

The conformance review must cover blockers, checked evidence, promotion target
coverage, implementation-map coverage, validator coverage, generated output
coverage, rollback coverage, downstream reference coverage, exclusions, and a
final closeout recommendation.

Then create or update `support/post-implementation-drift-churn-review.md` and
run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-aggregate-terminal-blockers
```

The drift/churn review must cover blockers, checked evidence, backreference
scan, naming drift, generated projection freshness, manifest and schema
validity, repo-local projection boundaries, target family boundaries, churn
review, validators run, exclusions, and a final closeout recommendation.

Create or update `support/validation.md` with the exact commands run, outcomes,
evidence paths, and any blocked or skipped validation with fail-closed
rationale.

## Validation Commands

Run these proposal and architecture validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-aggregate-terminal-blockers --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-aggregate-terminal-blockers
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-aggregate-terminal-blockers --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-aggregate-terminal-blockers
```

Run lifecycle and extension validation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh --contract .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-effective-freshness.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-route-resolution.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-pack-shape.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-proposal-program-runner-fixture-matrix.sh
```

Run focused Rust tests from the runtime crate workspace:

```sh
(cd .octon/framework/engine/runtime/crates && cargo test -p octon_kernel lifecycle_program)
(cd .octon/framework/engine/runtime/crates && cargo test -p octon_kernel --test proposal_program_cli)
```

If test names differ after implementation, run the smallest equivalent
`octon_kernel` test selection that covers aggregate terminal blocker evidence,
child receipt ownership, mixed child outcomes, closeout blocking, checkpoint or
status exposure, and replay compatibility. Escalate to broader runtime tests
only if the focused selection cannot prove behavior.

If generated effective lifecycle contracts are refreshed, verify source and
generated publication parity or record the exact publication receipt:

```sh
shasum -a 256 .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml .octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/context/lifecycles/proposal-program.contract.yml
```

Finish by validating the post-implementation receipts:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-aggregate-terminal-blockers
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-aggregate-terminal-blockers
```

## Rollback Posture

Rollback is patch reversal of the aggregate blocker evidence contract,
proposal-program lifecycle contract changes, program-runner emission and
consumption logic, focused tests, and generated publications created for this
packet.

Because the packet declares an atomic change profile, do not leave a partial
live state where:

- the lifecycle contract requires aggregate blocker evidence but the runtime
  cannot emit it
- the runtime emits aggregate blocker evidence not described by specs or
  contract tests
- parent closeout can pass with missing, stale, or drifted required aggregate
  blocker evidence
- parent aggregate evidence can satisfy child receipts, child validation,
  child promotion evidence, child archive metadata, implementation receipts,
  conformance receipts, drift receipts, closeout receipts, or archive authority

If any validation, publication, or receipt gate cannot pass, restore the
previous durable state or record a blocked gate outcome with exact evidence.

## Terminal Criteria

Implementation is complete only when all of the following are true:

- every durable change is limited to the declared promotion targets
- aggregate blocker evidence lists all blocked required children in one pass
- aggregate blocker evidence is parent-controller owned and diagnostic only
- child-owned receipt requirements remain enforced
- parent closeout enforces the active closeout policy and fails closed on
  missing, stale, or drifted required aggregate evidence
- focused Rust tests and proposal-program validation prove mixed child
  outcomes and authority boundaries
- generated/runtime publication is fresh where implicated, with retained
  evidence
- `support/implementation-run.md` exists and includes `verdict`,
  `implemented_at`, and `promotion_evidence_count`
- `support/implementation-conformance-review.md` exists and
  `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-aggregate-terminal-blockers`
  passes
- `support/post-implementation-drift-churn-review.md` exists and
  `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-aggregate-terminal-blockers`
  passes
- `proposal.yml#status` remains `accepted`

Refuse any implemented, promoted, closeout-ready, or archive-ready claim while
either post-implementation receipt is missing, failing, unresolved, stale, or
blocked.

## Delegation

Delegation is optional and is not a control requirement. If delegated
implementation is used, keep write scopes disjoint and name one integration
owner.

Suggested bounded scopes:

- runtime worker:
  `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- spec and contract worker:
  `.octon/framework/engine/runtime/spec/` and
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- validation worker:
  focused Rust tests, lifecycle contract validation, extension publication
  validation, generated freshness, and packet post-implementation gates

The integration owner must reconcile all edits, preserve unrelated worktree
changes, run the required gates, and create the implementation, conformance,
drift/churn, and validation receipts.

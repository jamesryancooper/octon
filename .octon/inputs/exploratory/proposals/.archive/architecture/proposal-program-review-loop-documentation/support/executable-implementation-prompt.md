# Executable Implementation Prompt

packet: `.octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation`
route: `run-packet-implementation`
generated_by_route: `generate-packet-implementation-prompt`
run_id: `lifecycle-proposal-program-1782852942821-fba365cc-proposal-program-review-loop-documentation`

Implement only the accepted child packet scope: document the existing
parent-local proposal program review/revision loop, preserve the intentional
absence of a standalone program review-and-revise wrapper, and add or preserve
tests that keep parent program review evidence from satisfying child-owned
receipts.

Leave `proposal.yml#status` as `accepted`. Promotion to `implemented`,
verification, closeout, archive, delivery, Change closeout, branch cleanup, and
repo-hygiene cleanup are separate lifecycle routes.

## Required Preconditions

Before durable edits, rerun the child-owned gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation --mode pre-integration-architecture-review --require-pass
```

Refuse implementation if any gate fails, if the accepted review digest is
stale, if implementation authorization is absent, if
`support/implementation-grade-completeness-review.md` no longer has
`verdict: pass`, `unresolved_questions_count: 0`, and
`clarification_required: no`, or if the implementation would use proposal
inputs, generated projections, host state, or this prompt as durable authority.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `transitional_exception_note`: `none`
- Rationale: the workspace charter and accepted packet both select atomic
  behavior, and this implementation is a bounded documentation and validation
  change with no support-target widening.

## Allowed Durable Scope

The implementation may modify only declared promotion targets and packet-local
implementation receipts:

- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/patterns/proposal-program.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/bundle-matrix.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation/support/post-implementation-drift-churn-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation/support/validation.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation/support/SHA256SUMS.txt`, only if the packet maintains checksums.

Do not edit parent proposal program packets, unrelated child packets, child
packet receipts, child validation verdicts, child archive metadata, generated
effective outputs, runtime control truth, or delivery and closeout state.

## Live Baseline To Preserve

Verify and cite current line-level evidence before editing:

- `context/lifecycles/proposal-program.contract.yml` declares loop
  `program-review-revision` with `receipt_id: proposal-review`,
  `repeat_values: revision-required`, `repeat_route_id: revise-program`,
  terminal values `accepted` and `rejected`, and `max_iterations: 5`.
- `context/patterns/proposal-program.md` has a `Parent Review And Revision`
  section naming parent review coverage, parent-local revision scope, and the
  child-owned surfaces parent review/revision must not edit.
- `context/bundle-matrix.md` maps `review-program` and `revise-program` to
  their prompt sets, commands, and skills.
- `commands/octon-proposal-review-program.md`,
  `commands/octon-proposal-revise-program.md`,
  `skills/octon-proposal-lifecycle-review-program/SKILL.md`, and
  `skills/octon-proposal-lifecycle-revise-program/SKILL.md` describe
  parent-local review/revision boundaries.
- `test-validate-lifecycle-contracts.sh` already asserts the program review
  route, revise route, loop repeat route, strict review gate, and child
  readiness separation.
- `validation/tests/test-authority-boundaries.sh` already checks that parent
  program review/revision preserve child authority boundaries and that parent
  receipts do not satisfy child receipts.

If the live repository already satisfies one of these items, do not rewrite it
for style. Record it as preserved coverage in the implementation evidence.

## Workstreams

1. Baseline and gap map.
   - Run `git status --short` and partition unrelated worktree changes from
     this packet.
   - Search the allowed durable scope for `program-review-revision`,
     `review-program`, `revise-program`, `child receipts`, `child manifests`,
     `child validation verdicts`, `child archive metadata`, and
     `review-and-revise`.
   - Record existing surfaces reused, missing coverage, and rejected new
     surfaces in `support/implementation-run.md`.

2. Preserve lifecycle contract coverage.
   - Keep `program-review-revision` in the proposal program lifecycle
     contract.
   - Ensure `review-program` and `revise-program` remain declared routes and
     the review loop returns to `revise-program` for `revision-required`.
   - Do not add a standalone review-and-revise route, command, skill,
     workflow, prompt bundle, or wrapper unless the implementation discovers
     new accepted evidence that the current lifecycle runner cannot execute
     the existing loop. If that evidence appears, stop and route to packet
     revision instead of expanding scope.

3. Improve discoverability only where gaps remain.
   - Ensure program pattern documentation says review covers the parent
     `proposal.yml`, child registry and index, sequence, child contract,
     validation plan, closeout plan, and parent support artifacts.
   - Ensure revision documentation says revision may change only parent-local
     coordination files and write parent-local revision receipts.
   - Ensure docs explicitly say parent review/revision must not edit child
     manifests, child receipts, child promotion targets, child validation
     verdicts, child archive metadata, runtime truth, or generated effective
     authority.
   - Ensure docs explicitly say parent review/revision receipts may summarize
     child outcomes but never satisfy child receipts.
   - Ensure the intentional omission of a standalone program
     review-and-revise wrapper is documented as a current architecture
     decision, not as a missing feature.

4. Align command, skill, and matrix surfaces.
   - Update only missing or stale review/revise command and skill wording
     inside the approved `commands/` and `skills/` targets.
   - Keep `context/bundle-matrix.md` discoverability aligned with actual
     command and skill ids.
   - Preserve the distinction between generic lifecycle runner wrappers and
     leaf route bundles. Do not make wrapper docs imply independent lifecycle
     authority.

5. Add or preserve validation coverage.
   - Keep `test-validate-lifecycle-contracts.sh` assertions for the
     `program-review-revision` loop, `review-program`, `revise-program`, the
     strict parent review gate, and separate child readiness.
   - Keep or add negative controls proving parent review/revision cannot edit
     child-owned manifests, receipts, promotion targets, validation verdicts,
     archive metadata, runtime truth, or generated effective authority.
   - Keep or add negative controls proving parent support receipts never
     satisfy child receipts.
   - If adding tests, place them in the approved test roots and avoid fixture
     churn unrelated to this packet.

6. Record child-owned implementation evidence.
   - Write `support/implementation-run.md` with the profile receipt,
     repository reconnaissance receipt, impact map, evidence plan, changed
     files, validators run, line-level baseline evidence, and explicit
     statement that no standalone wrapper was added.
   - Write `support/validation.md` with compact validator logs: command, cwd,
     start/end time or bounded timestamp note, exit code, and relevant output
     excerpt.
   - Write `support/implementation-conformance-review.md` with `verdict`,
     `unresolved_items_count`, and required sections for blockers, checked
     evidence, promotion target coverage, implementation map coverage,
     validator coverage, generated output coverage, governed mechanism
     integration coverage, rollback coverage, downstream reference coverage,
     exclusions, and final closeout recommendation.
   - Write `support/post-implementation-drift-churn-review.md` with `verdict`,
     `unresolved_items_count`, and required sections for blockers, checked
     evidence, backreference scan, naming drift, generated projection
     freshness, governed mechanism integration coverage, manifest and schema
     validity, repo-local projection boundaries, target family boundaries,
     churn review, validators run, exclusions, and final closeout
     recommendation.

## Validators

Run from the repository root after durable edits and receipt writes:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-lifecycle-contracts.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-authority-boundaries.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-route-resolution.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-pack-shape.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-routing-guide-docs.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-review-loop-documentation
```

If an approved target is not edited because existing coverage is already
sufficient, the evidence must state the preservation proof and the validators
that cover it.

## Delegation Boundary

Delegation is optional. If used, assign disjoint write scopes: one worker for
documentation surfaces under the approved lifecycle extension targets and one
worker for tests under the approved test roots. Workers must not edit packet
support receipts, proposal status, generated outputs, parent program packets,
child packet lifecycle truth, closeout state, archive state, or cleanup state.
The orchestrator remains accountable for final integration and receipt
accuracy.

## Rollback

Rollback is a governed follow-up route that reverts only this packet's durable
documentation and validation edits in approved promotion targets. Do not delete
retained implementation receipts, state evidence, or unrelated worktree
changes. If a test or doc addition is unnecessary because existing coverage was
already sufficient, remove only that new addition before final receipts and
record the cleanup decision.

## Closeout Refusal Criteria

Refuse closeout, archive, delivery, branch cleanup, and `implemented` claims
from this route. Refuse implementation completion if:

- any prerequisite or post-implementation validator fails;
- `support/implementation-conformance-review.md` or
  `support/post-implementation-drift-churn-review.md` is missing, failing,
  stale, or contains unresolved items;
- parent review/revision docs imply authority over child manifests, child
  receipts, child promotion targets, child validation verdicts, child archive
  metadata, runtime truth, or generated effective authority;
- parent evidence is treated as satisfying child receipts;
- a standalone program review-and-revise wrapper is added without packet
  revision and fresh accepted evidence;
- unrelated dirty worktree changes are mixed into this packet's implementation
  evidence or claimed as this packet's work.

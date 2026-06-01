# Executable Implementation Prompt

generated_at: 2026-06-01T04:46:17Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-change-handoff-checkpoints
proposal_id: proposal-program-runner-change-handoff-checkpoints
route: generate-packet-implementation-prompt

This file is an operational aid. It does not approve implementation, widen
scope, authorize cleanup, authorize Git mutation, replace proposal manifests,
or turn packet-local support files into durable Octon authority.

## Authority And Gate Posture

Before any durable edit, re-run the proposal gates and stop fail-closed on any
error, stale review, missing implementation authorization, open blocker, or
scope mismatch:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-change-handoff-checkpoints --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-change-handoff-checkpoints
```

Record a Profile Selection Receipt before implementation:

- release_state: pre-1.0
- change_profile: atomic
- rationale: `proposal.yml` and workspace defaults require an atomic change.
  The contract, scheduler, closeout guidance, and validation semantics must
  move together so there is no live state where the runner emits uncontracted
  handoff evidence or the contracts advertise handoffs the runner cannot emit.
- transitional exception: none

Leave `proposal.yml#status` as `accepted`. The `promote-proposal` lifecycle
route owns any later implemented-status rewrite.

## Target End State

The proposal-program runner can create retained, non-authorizing lifecycle
interaction handoff evidence after mutating child implementation batches and
after promotion-evidence convergence when route-created residue needs Change or
worktree disposition.

The runner requests evidence and partitioning only. It does not perform Change
closeout, worktree cleanup, repo hygiene deletion, Git mutation, publication,
promotion, archive movement, or hosted-provider authorization.

The handoff request uses `lifecycle-interaction-request-v1` with explicit
include/exclude boundaries, a boundary digest, evidence offered, stop
conditions, and the full forbidden-transfer set. The returned evidence uses
`lifecycle-interaction-return-v1` and may be considered only as
target-owned independent evidence for the terminal parent gate. Returned
handoff evidence must not satisfy child receipts, child promotion evidence, or
packet implementation evidence.

`closeout-change` and `closeout-worktree` remain independent route owners. A
lifecycle interaction request can provide advisory context, but those routes
must still inventory, partition, validate, and emit their own receipts before
claiming any cleanup, landing, preserved, published-branch, or blocked outcome.

## In Scope

Implement only the declared durable promotion targets:

- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`

Focused tests may be added or updated only where needed to prove the runtime
behavior and receipt semantics for those targets.

## Out Of Scope

Do not change proposal lifecycle authority, create new support tiers, introduce
new status values, move proposal workspaces, add dependencies, redesign the
program scheduler, or broaden targets beyond the five paths above.

Do not make the program runner execute Change closeout, cleanup deletion, repo
hygiene deletion, Git mutation, branch cleanup, hosted-provider authorization,
publication, promotion, archive movement, or rollback execution.

Do not treat proposal-local support files, generated projections, chat history,
host state, GitHub metadata, CI dashboards, or external workflow engines as
durable implementation proof or Octon authority.

## Ordered Workstreams

1. Inspect and preserve current worktree state.

   Run `git status --short` and review existing diffs for the runtime and
   lifecycle executor files before editing. Preserve unrelated edits already
   present in:

   - `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
   - `.octon/framework/engine/runtime/crates/lifecycle_executor/src/codex.rs`
   - `.octon/framework/engine/runtime/crates/lifecycle_executor/src/workflow_leaf.rs`
   - `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/adapter.rs`

2. Update lifecycle interaction contracts.

   Preserve the existing proposal-packet lifecycle interaction profile in
   `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`.
   Tighten it only if needed to keep handoff request and return semantics
   explicit.

   Add or clarify proposal-program lifecycle interaction metadata in
   `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
   for route-owned handoff checkpoints after mutating child batches. The
   contract must declare:

   - `non_authorizing: true`
   - request schema `lifecycle-interaction-request-v1`
   - return schema `lifecycle-interaction-return-v1`
   - target-owned independent validation or equivalent gate policy
   - include/exclude path boundaries and a boundary digest expectation
   - accepted evidence classes such as advisory context, validation evidence,
     review evidence, rollback context, and non-authority-only evidence
   - expected return evidence references and blocked-return semantics
   - forbidden transfers for Git ref mutation, hosted-provider authorization,
     branch cleanup authorization, worktree cleanup authorization, repo hygiene
     deletion, archive authorization, promotion authorization, and scope
     expansion

3. Implement program-runner handoff evidence.

   Extend `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
   so the proposal-program runner can detect route-created residue after
   mutating child implementation batches and after promotion-evidence
   convergence, then emit retained `lifecycle-interaction-request-v1` JSON
   evidence under an existing run evidence root such as
   `.octon/state/evidence/runs/workflows/<program-run-id>/lifecycle-interactions/`.

   Each request must include the source lifecycle id, program run id, atomic
   unit type, target reference, phase id, requested capability or route
   surface, requested atomic unit type, requested outcome, include paths,
   exclude paths, boundary digest, evidence offered, stop conditions, expected
   return evidence, and the forbidden-transfer set.

   Record request references in the program checkpoint, child or batch
   execution summary, and event log where they are needed for restart and
   diagnosis. If returned interaction references are supplied by run input,
   validate and record them as non-authorizing context only. They must not be
   counted as child receipts or child promotion evidence.

4. Preserve closeout route ownership.

   Update only the needed skill or reference text under
   `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
   and `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
   so lifecycle interaction input is clearly advisory. The closeout routes
   must still require their own inventories, include/exclude boundaries,
   validation, authorization where applicable, receipts, rollback posture, and
   returned `lifecycle-interaction-return-v1` evidence.

5. Add focused tests.

   Add or update tests proving:

   - a mutating child batch with route-created residue emits a handoff request
     and retained evidence reference
   - the request contains include/exclude paths, a boundary digest, the
     forbidden-transfer set, and non-authorizing semantics
   - returned closeout evidence does not satisfy child receipts, child
     promotion evidence, or implementation receipts
   - the runner performs no Git, cleanup, repo hygiene deletion, publication,
     promotion, archive, hosted-provider, or rollback mutation
   - no handoff is emitted for non-mutating or inspect-only routes with no
     route-created residue

6. Refresh generated/runtime publications only through existing publication
   paths.

   If additive lifecycle contracts or skill surfaces require generated
   effective publication, use the existing repository publication scripts and
   retain publication evidence under `.octon/state/evidence/validation/` or
   `.octon/state/evidence/runs/`. Do not hand-edit generated effective files
   unless the existing publication path explicitly does so.

   After publication, verify generated effective copies of changed lifecycle
   contracts match their additive sources. If no generated refresh is required
   or no publication path is available for a changed target, record the reason
   in `support/implementation-run.md` and `support/validation.md`.

7. Perform minimal cleanup.

   Remove only artifacts created by this implementation that are not retained
   evidence. Do not delete unrelated untracked files or pre-existing local
   residue.

## Required Evidence And Receipts

After durable changes land, create or update
`support/implementation-run.md` with at least:

- `verdict`
- `implemented_at`
- `promotion_evidence_count`

`promotion_evidence_count` must count durable promotion, validation, runtime,
or publication evidence. This prompt and other generated support prompts do
not count as implementation proof.

Then create or update `support/implementation-conformance-review.md` and run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-change-handoff-checkpoints
```

The conformance review must cover blockers, checked evidence, promotion target
coverage, implementation-map coverage, validator coverage, generated output
coverage, rollback coverage, downstream reference coverage, exclusions, and a
final closeout recommendation.

Then create or update `support/post-implementation-drift-churn-review.md` and
run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-change-handoff-checkpoints
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
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-change-handoff-checkpoints --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-change-handoff-checkpoints
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-change-handoff-checkpoints --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-change-handoff-checkpoints
```

Run lifecycle and interaction validation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh --contract .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh --contract .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-interaction-receipts.sh --self-test
```

For any emitted request or returned interaction fixture/evidence, also run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-interaction-receipts.sh --request <request-json-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-interaction-receipts.sh --return <return-json-path>
```

Run focused Rust tests from the runtime crate workspace:

```sh
(cd .octon/framework/engine/runtime/crates && cargo test -p octon_kernel --bin octon lifecycle_program)
```

If test names differ after implementation, run the smallest equivalent
`octon_kernel` test selection that covers program lifecycle handoff emission,
checkpoint persistence, return-reference handling, and non-authorizing evidence
semantics. Escalate to a broader runtime test only if the focused selection
cannot prove the behavior.

If generated effective lifecycle contracts are refreshed, verify source and
generated publication parity:

```sh
shasum -a 256 .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml .octon/generated/effective/extensions/published/octon-proposal-lifecycle/context/lifecycle.contract.yml
shasum -a 256 .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml .octon/generated/effective/extensions/published/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml
```

Finish by validating the post-implementation receipts:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-change-handoff-checkpoints
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-change-handoff-checkpoints
```

## Rollback Posture

Rollback is patch reversal of the lifecycle interaction contract changes,
closeout skill guidance, program-runner checkpoint/emission logic, tests, and
generated publications created for this packet.

Because the packet declares an atomic change profile, do not leave a partial
live state where:

- contracts advertise proposal-program handoffs but the runner cannot emit or
  validate them
- the runner emits handoff evidence not described by contracts
- closeout routes appear to accept transferred cleanup, Git, publication,
  promotion, archive, or hosted-provider authority
- returned handoff evidence can be counted as child receipts or promotion proof

If any validation, publication, or receipt gate cannot pass, restore the
previous durable state or record a blocked gate outcome with exact evidence.

## Terminal Criteria

Implementation is complete only when all of the following are true:

- every required durable change is limited to the declared promotion targets
- lifecycle interaction handoffs are non-authorizing and boundary-scoped
- returned handoff evidence cannot satisfy child receipts, child promotion
  evidence, implementation evidence, cleanup authorization, Git authorization,
  publication, promotion, archive, or closeout authority
- required validators and focused runtime tests pass or are recorded as blocked
  with fail-closed evidence
- generated/runtime publication is fresh where implicated, with retained
  evidence
- `support/implementation-run.md` exists and includes `verdict`,
  `implemented_at`, and `promotion_evidence_count`
- `support/implementation-conformance-review.md` exists and
  `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-change-handoff-checkpoints`
  passes
- `support/post-implementation-drift-churn-review.md` exists and
  `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-change-handoff-checkpoints`
  passes
- `proposal.yml#status` remains `accepted`

Refuse any implemented, closeout-ready, archive-ready, or promoted claim while
either post-implementation receipt is missing, failing, unresolved, stale, or
blocked.

## Delegation

Delegation is optional and is not a control requirement. If delegated
implementation is used, keep write scopes disjoint and name one integration
owner.

Suggested bounded scopes:

- contract/docs worker:
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`,
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`,
  `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`,
  `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- runtime worker:
  `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- validation worker:
  focused runtime tests, lifecycle interaction receipt fixtures, and validation
  evidence

The integration owner must reconcile all edits, preserve unrelated worktree
changes, run the required gates, and create the implementation, conformance,
drift/churn, and validation receipts.

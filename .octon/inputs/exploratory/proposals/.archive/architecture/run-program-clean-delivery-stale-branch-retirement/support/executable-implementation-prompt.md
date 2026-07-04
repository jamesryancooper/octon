# Executable Implementation Prompt

implementation_prompt_id: run-program-clean-delivery-stale-branch-retirement-implementation-prompt-20260703T185042Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement
lifecycle_id: proposal-packet
route_id: run-packet-implementation
prompt_generation_run_id: lifecycle-proposal-program-1783094500385-fbec6b8f-run-program-clean-delivery-stale-branch-retirement
reviewed_packet_digest: sha256:77edfe290485f91b979c082d9d075ae3fd5607e1fce645e462f41b0e9b91249d
release_state: pre-1.0
change_profile: atomic
non_authority_classification: packet-local-operational-support-only
generated_at: 2026-07-03T18:50:42Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, replace retained evidence, authorize
remote mutation, authorize branch deletion by itself, or substitute for Change
closeout, archive authorization, cleanup authorization, generated publication
receipts, final sync proof, terminal current-state proof, or branch-retirement
receipts. The proposal packet remains temporary and non-authoritative.

## Prompt Generation Gate Receipt

Prompt generation was allowed only after these gates passed:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement --require-implementation-authorization
```

The accepted review receipt records `verdict: accepted`,
`implementation_prompt_authorized: yes`, and
`open_blocking_findings_count: 0`.

Observed packet digest at prompt generation time:

```text
sha256:77edfe290485f91b979c082d9d075ae3fd5607e1fce645e462f41b0e9b91249d
```

The required repository anchors and prompt-pack source digests supplied to the
route matched at prompt generation time. If any referenced source, review
digest, or packet digest drifts before implementation, stop and rerun the
owning review or freshness route.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- rationale: stale branch retirement changes local Git cleanup authority and
  must land with exact branch evidence, blocker semantics, rollback posture,
  validator coverage, and closeout/worktree policy alignment.
- transitional exception: not authorized

## Required Starting Reads

Read these before editing:

- `AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/framework/constitution/CHARTER.md`
- `.octon/framework/constitution/charter.yml`
- `.octon/framework/constitution/obligations/fail-closed.yml`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/precedence/normative.yml`
- `.octon/framework/constitution/precedence/epistemic.yml`
- `.octon/framework/constitution/ownership/roles.yml`
- `.octon/instance/charter/workspace.md`
- `.octon/instance/charter/workspace.yml`
- `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`
- `.octon/framework/execution-roles/practices/standards/ai-assisted-development-discipline.md`
- `.octon/framework/execution-roles/practices/standards/repository-reconnaissance.md`
- `.octon/framework/execution-roles/practices/standards/cleanup-pass.md`
- `.octon/framework/execution-roles/practices/standards/dependency-discipline.md`
- `.octon/framework/execution-roles/practices/standards/validation-evidence-quality.md`
- `.octon/inputs/exploratory/proposals/README.md`
- `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- every file in this packet listed by `navigation/source-of-truth-map.md`
- all promotion targets listed below

Before durable edits, emit a Profile Selection Receipt, Repository
Reconnaissance Receipt, Minimal Implementation Plan, Impact Map, Evidence Plan,
Dependency Receipt, cleanup pass plan, and rollback notes. The dependency
receipt should be `none` unless the implementation intentionally changes
dependencies; do not add dependencies without separate justification and
validation.

The current worktree may contain existing local changes and untracked lifecycle
or evidence material from adjacent clean-delivery work. Inspect current diffs
before editing, preserve unrelated changes, and do not reset, restore, stash,
delete, switch branches, or clean residue unless a current route-owned receipt
authorizes the exact action.

## Preconditions

Run these gates before durable target mutation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement
```

Refuse implementation if any gate fails, if `proposal.yml#status` is not
`accepted`, if the review digest is stale, if open blocking findings appear, or
if the implementation would require durable promotion targets outside the
manifest without a packet revision or linked accepted proposal.

## Promotion Targets

Durable implementation may touch only these manifest promotion targets and
their necessary in-family files:

- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

Do not edit generated effective outputs by hand. If an owning publisher must
refresh generated outputs after implementation, run the publisher and retain
freshness evidence; generated outputs remain derived-only.

Do not change `proposal.yml#status`. The implementation route records
implementation evidence for later lifecycle routes; it does not close,
archive, deliver, land, sync, branch-clean, cleanup, or claim `cleaned`.

## Explicit Non-Goals

- Do not authorize or perform remote branch deletion. Remote mutation remains
  out of scope unless a separate current receipt authorizes the exact remote
  ref operation.
- Do not delete branches with unique commits, protected names or status,
  unresolved upstream-only state, unresolved local remote ref ownership, open
  PR ownership, active worktree dependency, or dirty residue that cannot be
  safely preserved or retired.
- Do not create a parallel cleanup authority, scheduler, proposal-local branch
  registry, or host-state dependency.
- Do not treat proposal-local support files, generated outputs, postmortem
  summaries, dashboards, host state, chat, model memory, or tool availability
  as retireability proof or authority.
- Do not claim terminal worktree hygiene, Change closeout, archive readiness,
  parent delivery, landed, synced, or cleaned from this prompt or from
  implementation text alone.

## Repository Starting Points

Extend the existing closeout and worktree machinery:

- `default-work-unit.yml` already owns Change route defaults, cleanup
  downgrade semantics, branch cleanup authorization, local/private evidence
  boundaries, terminal current-state proof, and residue authority routing.
- `git-worktree-autonomy-contract.yml` already requires route selection before
  Git mutation, route-owned clean worktree selection for stale or dirty source
  posture, include-path classification before broad staging, and branch cleanup
  safeguards for protected, active, unmerged, open-PR, or unretained-rollback
  branches.
- `closeout-change` already owns singular Change closeout, branch cleanup,
  local or remote branch deletion diagnostics, governed landing and cleanup
  authorization, final sync, rollback posture, and outcome downgrade.
- `closeout-worktree` already owns dirty-worktree decomposition, candidate
  boundaries, local-worktree residue classification, delegated closeout-change
  routing, repo-hygiene routing, and wrapper reports. It does not authorize
  cleanup from detection alone.
- `validate-run-program-clean-delivery.sh` and
  `test-run-program-clean-delivery-validator.sh` already validate clean
  delivery receipts, branch authorization, final sync, terminal proof,
  worktree hygiene, target-owned evidence, and non-authority boundaries. Extend
  this chain with stale local branch retirement evidence and negative controls.

## Workstream 1: Branch Role Labels And Cleanup Reporting

Add branch role labels used by closeout reports and validators:

- `source-dirty-anchor`
- `route-owned-delivery-branch`
- `correction`
- `cleanup`
- `retained-protected`
- `retired-stale`

Required behavior:

- Cleanup reports must name every retained or retired local branch with role
  label, branch ref, upstream state, locally knowable PR state, protected
  status, worktree attachment, unique-commit status, and retention or
  retirement reason.
- Similar branch names must not allow a dirty anchor branch to be confused with
  a route-owned delivery branch.
- A `retired-stale` label is valid only after current evidence proves the
  branch has no unique commits relative to the surviving branch and every
  blocker class is absent or resolved.
- A `retained-protected` or blocker label must be used when deletion is unsafe
  or unproven.

## Workstream 2: Retireability Inventory And Proof

Add retireability checks for stale local branches before any switch or delete
operation.

Required evidence for each candidate branch:

- current branch and HEAD ref;
- all local worktrees and attached branches;
- local branch refs and target candidate ref;
- surviving branch and surviving ref;
- `main`, `origin/main`, and relevant landed or delivery refs when applicable;
- upstream configuration and locally available remote refs;
- locally knowable PR ownership or explicit not-locally-knowable blocker;
- protected-name or protected-status classification;
- merge base and unique-commit proof relative to the surviving branch;
- dirty worktree residue classification when the candidate is checked out;
- rollback command or recreation note using the receipt-recorded stale ref.

Required behavior:

- No-unique-commit proof must be computed from current refs, not from
  postmortem prose or prior summaries.
- Branches with unique commits block before deletion and must report the commit
  evidence or digest used to prove the blocker.
- Branches with unresolved upstream or PR ownership block before deletion.
- Protected, active, unmerged, open-PR, or unretained-rollback branches block
  before deletion.
- If local PR or upstream ownership cannot be determined, preserve the branch
  and record the missing proof as the blocker.

## Workstream 3: Dirty Checked-Out Stale Branch Retirement

Integrate checked-out dirty stale branches with local-worktree retirement
instead of stopping by default.

Required behavior:

- When the stale branch is checked out and the worktree is dirty, route through
  local-worktree retirement first: inventory residue, classify it, preserve or
  promote required evidence, discard only route-authorized disposable residue,
  and record every include/exclude boundary.
- Do not switch away from the checked-out stale branch until the local-worktree
  retirement receipt proves residue disposition and the surviving branch target
  is current.
- Do not delete the stale branch until after the worktree is no longer
  branch-dependent and the branch-retirement authorization proves no unique
  commits and no unresolved ownership.
- Unpreservable dirty residue blocks deletion and must retain a candidate-keyed
  blocker.
- Detection, report labels, or classifier output alone are not deletion
  authority.

## Workstream 4: Branch-Retirement Receipts And Verification

Emit branch-retirement authorization and post-deletion verification evidence
before reporting any stale local branch as retired.

Use existing branch cleanup authorization and closeout receipt surfaces where
they can express the stale-retirement decision. Do not add a new authority
plane. If the existing declared promotion targets cannot express the required
receipt fields, stop and revise the packet before editing outside scope.

The retirement receipt or receipt section must record:

- candidate branch name and stale ref;
- surviving branch name and surviving ref;
- merge-base or equivalent proof input;
- unique-commit count and proof result;
- upstream, remote-ref, PR, and protected-status checks;
- active worktree and dirty-residue disposition;
- authorized switch action, if any;
- authorized local delete action;
- remote mutation status as `not-authorized` unless a separate current receipt
  authorizes the exact remote operation;
- rollback notes to recreate the local branch from the recorded stale ref;
- post-deletion verification that the local branch is absent and the surviving
  branch/ref remains aligned;
- blocker and downgrade reason when deletion is deferred or blocked.

Permission-sensitive Git mutation failures for checkout, switch, branch
delete, remote delete, fetch, push, final sync, or pruning must record
diagnostic evidence and owning rerun route. Diagnostics are evidence only and
do not authorize retry or mutation.

## Workstream 5: Validator And Fixture Coverage

Extend `validate-run-program-clean-delivery.sh` and tests under
`.octon/framework/assurance/runtime/_ops/tests/` so stale branch retirement is
validated as part of clean-delivery closeout.

Required positive controls:

- A stale local branch with no unique commits, no unresolved upstream or PR
  ownership, no protected status, no active dependency, and valid rollback
  posture can be reported as `retired-stale` after local deletion verification.
- A checked-out dirty stale branch can be retired only after local-worktree
  retirement evidence proves residue disposition, safe switch, authorization,
  local deletion, and post-delete verification.

Required negative controls:

- Unique commits block deletion.
- Protected branch status blocks deletion.
- Unresolved upstream ownership blocks deletion.
- Open or unresolved PR ownership blocks deletion.
- Active worktree dependency blocks deletion until safe switch evidence exists.
- Dirty checked-out branch residue blocks deletion when unpreservable or
  unauthorised.
- Missing branch-retirement authorization blocks `retired-stale`.
- Missing post-deletion verification blocks `retired-stale`.
- Remote deletion without a separate current receipt blocks validation.
- Postmortem summaries, final reports, parent summaries, generated outputs,
  host state, chat, model memory, tool availability, or report labels alone do
  not satisfy retireability proof.

## Validation Plan

After implementation, run at least:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh
```

Run closeout-worktree wrapper validation when implementation creates or
changes representative wrapper report fixtures:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh --report <report>
```

Then produce the implementation support reviews and run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-stale-branch-retirement
```

Refuse closeout, archive-ready, delivered, landed, synced, or cleaned claims
until both implementation conformance and post-implementation drift/churn
validators pass with current receipts.

Record compact validation logs with command, cwd, start time, end time, exit
code, evidence ref, and bounded excerpts. Retain full logs or digests when
available under `.octon/state/evidence/validation/**` or the relevant
run/workflow evidence root.

## Required Post-Implementation Support Reviews

After durable implementation, create or refresh:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

`support/implementation-conformance-review.md` must record `verdict`,
`unresolved_items_count`, and these sections:

- `Blockers`
- `Checked Evidence`
- `Promotion Target Coverage`
- `Implementation Map Coverage`
- `Validator Coverage`
- `Generated Output Coverage`
- `Governed Mechanism Integration Coverage`
- `Rollback Coverage`
- `Downstream Reference Coverage`
- `Exclusions`
- `Final Closeout Recommendation`

`support/post-implementation-drift-churn-review.md` must record `verdict`,
`unresolved_items_count`, and these sections:

- `Blockers`
- `Checked Evidence`
- `Backreference Scan`
- `Naming Drift`
- `Generated Projection Freshness`
- `Governed Mechanism Integration Coverage`
- `Manifest And Schema Validity`
- `Repo-Local Projection Boundaries`
- `Target Family Boundaries`
- `Churn Review`
- `Validators Run`
- `Exclusions`
- `Final Closeout Recommendation`

Both reviews are packet-local evidence aids only. They do not authorize
promotion, archive, delivery, closeout, landing, branch cleanup, cleanup,
generated publication, remote mutation, local branch deletion, or terminal
proof.

## Evidence Requirements

Retain or cite:

- Profile Selection Receipt with `release_state: pre-1.0` and
  `change_profile: atomic`.
- Repository Reconnaissance Receipt covering searches for existing branch
  cleanup, closeout-change, closeout-worktree, default work unit, worktree
  autonomy, validator, helper, and test surfaces.
- Minimal Implementation Plan and Impact Map covering policy contracts,
  closeout skills, validator scripts, tests, evidence, generated outputs, and
  docs.
- Dependency Receipt stating `none` unless dependencies changed.
- Cleanup Pass Receipt covering added surfaces, simplifications, deletion
  candidates, retained residue, and remaining cleanup risk.
- Branch-retirement authorization and post-deletion verification receipt
  examples or fixtures.
- Negative-control evidence for every blocked branch-retirement case.
- Compact validator logs or receipts for every validator run or blocker.
- Rollback notes for each durable target family touched.
- `support/implementation-run.md`.
- `support/implementation-conformance-review.md`.
- `support/post-implementation-drift-churn-review.md`.

## Rollback Posture

Before implementation, rollback is packet rejection, prompt supersession, or
archive. After implementation, rollback belongs to the implementing Change and
must revert policy, worktree autonomy, closeout-change, closeout-worktree,
clean-delivery validator, and fixture changes atomically enough to restore the
previous branch cleanup behavior.

If an implementation or test route deletes an actual local branch, rollback
must recreate it from the receipt-recorded ref. Remote ref restoration remains
out of scope unless a separate current remote-mutation receipt authorized the
original remote operation and supplies a rollback handle.

## Delegation Boundaries

No delegation is required. If the implementer delegates, each delegated task
must have a disjoint write set and must preserve the packet boundaries:

- policy and worktree autonomy contract alignment;
- closeout-change stale-retirement semantics;
- closeout-worktree dirty checked-out branch retirement semantics;
- validator and fixture coverage;
- implementation support-review evidence.

No delegated task may mutate generated outputs by hand, close or archive the
packet, perform remote mutation, delete branches, delete residue, clean
worktrees, claim delivery, or synthesize terminal proof outside the owning
route.

## Terminal Criteria

Implementation is ready for later lifecycle routes only when:

- every declared promotion target is covered or explicitly justified as already
  conforming;
- no durable target depends on this proposal packet as runtime, policy,
  support, or closure authority;
- cleanup reports distinguish dirty anchors from route-owned delivery branches;
- stale local branch retirement requires current no-unique-commit proof,
  upstream/PR/protection checks, dirty-worktree disposition, branch-retirement
  authorization, post-delete verification, and rollback notes;
- unique-commit, protected, upstream/PR-owned, active-worktree, and
  unpreservable-dirty-residue cases fail closed;
- remote deletion remains blocked without a separate current receipt;
- validators and fixtures pass or blockers are recorded;
- `support/implementation-conformance-review.md` exists and validates through
  `validate-proposal-implementation-conformance.sh --package <proposal_path>`;
- `support/post-implementation-drift-churn-review.md` exists and validates
  through `validate-proposal-post-implementation-drift.sh --package
  <proposal_path>`;
- no closeout, archive-ready, delivered, landed, synced, branch-cleaned, or
  cleaned claim is made before the owning validators and receipts pass.

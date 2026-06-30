# Executable Implementation Prompt

implementation_prompt_id: run-program-clean-delivery-workflow-handoff-implementation-prompt-20260629T125900Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff
lifecycle_id: proposal-packet
route_id: run-packet-implementation
prompt_generation_run_id: 20260629T125900Z-run-program-clean-delivery-workflow-handoff-review
reviewed_packet_digest: sha256:fdc0d6f580419331ff105100215b5ca878d20f985a1c83ce526929fffc96c4eb
release_state: pre-1.0
change_profile: atomic
non_authority_classification: packet-local-operational-support-only
generated_at: 2026-06-29T12:59:00Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, replace retained evidence, or
substitute for Change closeout, archive authorization, cleanup authorization,
generated publication receipts, branch authorization, final sync proof, or
terminal current-state proof. The proposal packet remains temporary and
non-authoritative.

## Prompt Generation Gate Receipt

Prompt generation was allowed only after these gates passed:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff
```

The accepted review receipt records `verdict: accepted`,
`implementation_prompt_authorized: yes`, and
`open_blocking_findings_count: 0`.

Observed packet digest at prompt generation time:

```text
sha256:fdc0d6f580419331ff105100215b5ca878d20f985a1c83ce526929fffc96c4eb
```

The required repository and prompt-pack source digests supplied to the route
matched at prompt generation time. If any referenced source, review digest, or
packet digest drifts before implementation, stop and rerun the owning review or
freshness route.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- rationale: this is a bounded accepted architecture implementation that must
  align workflow, command, skill, product contract, closeout-change, and
  closeout-worktree handoff semantics as one coherent change.
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
- `.octon/inputs/exploratory/proposals/README.md`
- `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- every file in this packet listed by `navigation/source-of-truth-map.md`
- all promotion targets listed below

Before durable edits, emit a Profile Selection Receipt, Repository
Reconnaissance Receipt, Minimal Implementation Plan, Impact Map, Evidence Plan,
Dependency Receipt, and rollback notes. The dependency receipt should be
`none` unless the implementation intentionally changes dependencies; do not add
dependencies without separate justification and validation.

The current worktree may contain existing local changes and untracked lifecycle
or evidence material from adjacent clean-delivery work. Inspect current diffs
before editing, preserve unrelated changes, and do not reset, restore, or
delete user or prior-run work.

## Preconditions

Run these gates before durable target mutation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff
```

Refuse implementation if any gate fails, if `proposal.yml#status` is not
`accepted`, if the review digest is stale, if open blocking findings appear, or
if the implementation would require promotion targets outside the manifest
without a packet revision or linked accepted proposal.

## Promotion Targets

Durable implementation may touch only these promotion targets and their
necessary in-family files:

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
- `.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`
- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md`

Do not edit generated effective outputs by hand. If an owning publisher must
refresh generated outputs after implementation, run the publisher and retain
freshness evidence; generated outputs remain derived-only.

Do not change `proposal.yml#status`. The implementation route records
implementation evidence for later lifecycle routes; it does not close,
archive, deliver, land, sync, branch-clean, cleanup, or claim `cleaned`.

## Explicit Non-Goals

- Do not create a second delivery workflow, closeout route, scheduler,
  proposal-local planner, or authority plane.
- Do not replace child packet receipts, child validation, archive
  authorization, generated publication, repo hygiene cleanup, Change closeout,
  branch cleanup, final sync, or terminal proof with aggregate delivery
  evidence.
- Do not mutate Git, hosted branches, PR state, archive locations, generated
  effective outputs, or repo hygiene residue from this implementation route.
- Do not add new validators, schemas, or fixtures unless the existing target
  validators cannot express the accepted handoff contract.
- Do not widen promotion targets, add proposal-path runtime dependencies, or
  treat proposal-local support files as policy or runtime authority.
- Do not claim implemented closeout, archive-ready, delivered, landed, synced,
  or cleaned from this prompt or from implementation text alone.

## Repository Starting Points

Use the existing Proposal Program Delivery and Change closeout machinery:

- `workflow.yml` already defines an active mutating
  `proposal-program-delivery` workflow with profile binding, retained
  readiness preflight, program validation, child lifecycle routing, child
  receipt validation, feature-catalog drift validation, closeout/archive
  routing, Change closeout routing, cleanup/sync proof, delivery receipt
  output, aggregate receipt semantics, and stop-condition taxonomy.
- The workflow stages already cite readiness, parent-summary substitution,
  feature-catalog drift, closeout/archive, branch-no-PR, repo hygiene cleanup,
  final sync, terminal proof, and non-authority boundaries. Align them into one
  consistent stop-condition model instead of adding parallel stage semantics.
- `/proposal-program-delivery` is a thin command over the workflow. Keep it a
  routing surface that accepts `target`, `outcome`, `profile`, and `run-id`;
  do not turn it into an executor that owns child or Change effects.
- The `proposal-program-delivery` skill already requires profile validation,
  child-before-parent order, readiness preflight, child-owned receipt
  validation, generated freshness, Change closeout, worktree hygiene, repo
  hygiene cleanup, terminal proof, aggregate receipt validation, and evidence
  index validation. Tighten source receipt and handoff requirements there.
- `default-work-unit.yml` and `change-closeout-state-machine.yml` already own
  Change route selection, target lifecycle defaults, actual lifecycle outcome,
  local/private evidence boundaries, branch-no-PR landing, branch cleanup,
  final sync, terminal current-state proof, and cleanup downgrade semantics.
- `closeout-change` owns singular Change mutation and receipt behavior.
  `closeout-worktree` owns dirty-worktree decomposition and wrapper reports.
  Delivery may pass handoff context and cite returned evidence, but it must not
  claim their lower-level outcomes as its own `cleaned` proof.

## Workstream 1: Delivery Profile And Runner Handoff

Align the workflow, command, and skill so Proposal Program Delivery can consume
runner handoff evidence through retained readiness evidence.

Required behavior:

- Record `target_outcome`, release state, order policy, PR policy, stash policy,
  operator grant context when supplied, runner handoff refs, include-path
  classification state, and retained preflight refs in profile or workflow
  evidence.
- Preserve `child-before-parent-delivery` as canonical. Require a valid
  target-bound order override receipt for non-canonical order.
- Make `pr_policy.mode: forbid-pr` reject PR creation and PR fallback.
- Make `stash_policy.mode: forbidden` preserve unrelated work without hiding it
  in a stash.
- Treat runner handoff evidence as delivery input only. It is not child packet,
  archive, Change, cleanup, generated-publication, branch, final sync, or
  terminal proof authority.

## Workstream 2: Readiness Preflight And Stop Conditions

Make `delivery-readiness-preflight` the single required blocker discovery gate
before expensive child continuation, parent delivery, Git mutation, publication
checks, archive routing, repo hygiene cleanup, branch deletion, final sync, or
terminal proof.

Required behavior:

- Record Git index and ref write probes as typed blockers without authorizing
  side effects.
- Record worktree cleanliness, source staleness, include-path classification,
  review freshness, child receipt compatibility, generated freshness, route
  legality, tooling availability, and clean-worktree route selection when dirty
  or stale source posture exists.
- Later stages must consume the retained readiness receipt and not rediscover
  or silently bypass readiness blockers.
- Bring workflow-level stop-condition taxonomy and stage citations into
  parity. Cover at least:
  `SC-001-authority-gap`, `SC-002-ownership-conflict`,
  `SC-003-unsafe-mutation`, `SC-004-approval-required`,
  `SC-005-stale-evidence`, `SC-006-generated-freshness-drift`,
  `SC-007-publishable-evidence-gap`, `SC-008-validation-failure`,
  `SC-009-parent-summary-substitution`, and `SC-010-cleaned-proof-gap`.
- Each stop condition must name the machine condition, owning route or
  validator, required evidence, blocked outcome, and next route.

## Workstream 3: Child Receipt And Generated Publication Boundaries

Require direct source receipt refs and digests for target-owned child and
generated-publication gates.

Required behavior:

- Validate child implementation conformance, post-implementation drift/churn,
  governed mechanism integration when applicable, generated publication
  freshness, and feature-catalog drift through their owning validators.
- Reject parent summaries, aggregate delivery receipts, readiness projections,
  compact delivery evidence indexes, generated outputs, host state, chat, tool
  state, and model memory as substitutions for target-owned receipts.
- Ensure the aggregate delivery receipt and evidence index can cite child
  source receipts by path or evidence ref plus digest only.
- Generated effective outputs remain derived-only and are refreshed only by
  owning publishers with freshness evidence.

## Workstream 4: Closeout And Archive Handoff

Represent Proposal Program Delivery as a caller of packet closeout, archive
lifecycle, closeout-worktree, repo-hygiene-cleanup, and closeout-change routes,
not as their replacement.

Required behavior:

- Packet closeout must own packet verdict and `archive_authorized: yes`.
- Archive relocation must belong to the archive lifecycle route, followed by
  terminal freshness, implementation conformance, and post-implementation
  drift/churn validation.
- Fresh archive mutation must block Change closeout until post-archive
  validation is current.
- Dirty or stale source posture must route to closeout-worktree with classifier
  output ref and digest, foreign fingerprint when relevant, exact include and
  exclude paths, required return evidence, and no-substitution boundaries.
- Eligible local Octon run or artifact residue must route to
  `repo-hygiene-cleanup` through its classify-first, receipt-backed helper.
  Delivery and closeout-worktree may cite that route but do not delete residue.

## Workstream 5: Change Closeout And Branch-No-PR Delivery

Align the workflow, product contracts, `closeout-change`, and
`closeout-worktree` so Change closeout owns mutation and lifecycle outcomes.

Required behavior:

- Proposal Program Delivery passes explicit include paths, exclude paths, route
  hints, target lifecycle outcome, validation floor, rollback posture, profile
  constraints, source receipt refs, readiness receipt ref, and blocker context
  into closeout-change or closeout-worktree.
- `closeout-change` owns branch-no-PR hosted preflight, source branch push,
  exact source-SHA checks, governed landing authorization, hosted mutation,
  governed branch cleanup authorization, rollback handle, final sync, terminal
  proof refs, and actual lifecycle outcome.
- `closeout-worktree` owns dirty-worktree decomposition and can return
  non-authorizing proposal-program handoff reports, but those reports do not
  stage, delete, reset, commit, publish, archive, branch-clean, satisfy child
  receipts, satisfy Change receipts, or claim `cleaned`.
- Delivery must downgrade to the highest evidence-backed outcome when
  closeout-change lacks landing, cleanup authorization, cleanup disposition,
  final sync, terminal proof, or current route-owned validation evidence.
- Local/private terminal evidence may be cited only through digest-backed
  retained evidence fields permitted by the closeout contracts. It is not
  hosted/shared proof, landing authorization, cleanup authorization, generated
  publication evidence, archive evidence, mutation authority, or policy
  authority.

## Workstream 6: Aggregate Receipt And Evidence Index

Align delivery receipt and evidence index semantics without making either an
authority source.

Required behavior:

- The aggregate delivery receipt records source receipt refs, digests,
  disclosure tiers, non-authority classifications, stop condition IDs, owning
  next routes, highest evidence-backed outcome, excluded evidence classes,
  clean-worktree route, include-path classification status, lifecycle
  postmortem status when required, and downgrade rationale.
- The compact delivery evidence index remains retained, compact, and
  non-authorizing. It records refs, digests, disclosure tiers, route, outcome,
  validator results, and non-authority classification only.
- Open blockers prevent downstream outcome claims. The receipt must report
  `blocked` or a lower actual outcome with next owning route when any required
  owning receipt is missing, stale, failing, or outside local authority.

## Workstream 7: Operator Surface And Policy Consistency

Keep operator-facing language, skill behavior, and policy contracts consistent.

Required behavior:

- The command surface must state that retained readiness evidence validates
  before runner handoff continuation and that PR fallback, stash policy, and
  target outcome are profile-bound.
- The delivery skill must require direct source receipt refs and digests for
  child, closeout, archive, cleanup, generated publication, feature-catalog
  drift, branch, final sync, and terminal proof evidence.
- `default-work-unit.yml` must remain the source for Change-first routing,
  default `cleaned` target, actual outcome downgrade, local/private evidence
  boundaries, branch-no-PR closeout, and terminal current-state proof.
- `change-closeout-state-machine.yml` must represent delivery as a caller of
  closeout routes, not a competing state machine.
- `closeout-change` and `closeout-worktree` must document proposal-program
  handoff inputs, return evidence, and no-substitution boundaries in the same
  terms used by the delivery workflow.

## Validation Plan

After implementation, run at least:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-effective-freshness.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh
```

Run these when representative inputs, reports, receipts, or changed semantics
make them applicable:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh --profile <profile>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh --receipt <receipt>
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-program-delivery-evidence-index.sh --receipt <receipt> --run-id <run-id> --write
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh --index <index>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh --report <report>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-branch-no-pr-delivery-authorization-envelope.sh --envelope <envelope>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --receipt <receipt>
```

Then produce the implementation support reviews and run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff
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

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

`support/implementation-conformance-review.md` must record:

- review id, reviewed time, reviewer, verdict, packet digest, and implementation
  route id;
- every declared promotion target and whether it was covered, intentionally
  unchanged, or blocked with rationale;
- scope compliance and explicit exclusions;
- target-owner preservation for child receipts, archive, generated
  publication, cleanup, Change closeout, branch cleanup, final sync, and
  terminal proof;
- validation evidence and known gaps;
- final route recommendation.

`support/post-implementation-drift-churn-review.md` must record:

- review id, reviewed time, reviewer, verdict, and packet digest;
- proposal-path dependency sweep results showing durable targets do not depend
  on this proposal packet as runtime, policy, support, or closure authority;
- generated effective freshness and non-authority results;
- input non-authority results;
- churn review covering unnecessary new surfaces, duplicate helpers,
  speculative abstractions, unrelated formatting, and deletion candidates;
- validation evidence and blockers;
- final route recommendation.

Both reviews are packet-local evidence aids only. They do not authorize
promotion, archive, delivery, closeout, landing, branch cleanup, cleanup,
generated publication, or terminal proof.

## Required Negative Controls

Prove these fail closed through validators, fixtures, blocked receipt evidence,
or explicit review findings:

- Parent summary, readiness projection, aggregate delivery receipt, or compact
  delivery evidence index substituted for child-owned receipts.
- Readiness preflight evidence used as Git, archive, cleanup, branch, generated
  publication, final sync, or terminal proof authority.
- Closeout-worktree handoff report used to stage, delete, reset, archive,
  publish, branch-clean, satisfy a child receipt, satisfy a Change receipt, or
  claim `cleaned`.
- Branch-no-PR landing without governed landing authorization.
- Branch cleanup without governed cleanup authorization.
- `cleaned` claimed without current terminal current-state proof after the
  final landing, cleanup, generated publication, proposal artifact, and residue
  classification mutation.
- Local/private terminal evidence used as hosted or shared closeout proof.
- Hand-edited generated effective output used as fresh publication state.
- Generated output, raw input, host state, chat, model memory, or tool state
  used as authority.

## Evidence Requirements

Retain or cite:

- Profile Selection Receipt with `release_state: pre-1.0` and
  `change_profile: atomic`.
- Repository Reconnaissance Receipt covering searches for existing contracts,
  workflows, validators, command surfaces, skills, closeout routes, generated
  publication surfaces, and proposal lineage.
- Minimal Implementation Plan and Impact Map covering workflows, commands,
  skills, product contracts, closeout skills, generated outputs, evidence,
  validators, and docs.
- Dependency Receipt stating `none` unless dependencies changed.
- Cleanup Pass Receipt covering added surfaces, simplifications, deletion
  candidates, retained residue, and remaining cleanup risk.
- Compact validator logs or receipts for every validator run or blocker.
- Publication and freshness receipts when generated outputs are refreshed by an
  owning publisher.
- Rollback notes for each durable target family touched.
- `support/implementation-conformance-review.md`.
- `support/post-implementation-drift-churn-review.md`.

## Rollback Posture

Before implementation, rollback is packet rejection, supersession, or archive.
After implementation, rollback belongs to the implementing Change and must
revert workflow, command, skill, closeout policy, closeout state machine,
closeout-change, and closeout-worktree changes atomically enough to restore the
previous delivery and closeout handoff behavior.

Regenerate derived outputs through owning publishers instead of hand-editing
generated effective files. If validation proves rollback cannot preserve child
authority, generated non-authority, or Change closeout semantics, stop with a
blocked outcome and record the owning repair route.

## Delegation Boundaries

No delegation is required. If the implementer delegates, each delegated task
must have a disjoint write set and must preserve the packet boundaries:

- workflow directory alignment;
- command and delivery skill alignment;
- product closeout contracts;
- closeout-change and closeout-worktree handoff text;
- validation and support-review evidence.

No delegated task may mutate generated outputs by hand, close or archive the
packet, perform Git or hosted mutation, delete residue, clean branches, claim
delivery, or synthesize terminal proof.

## Terminal Criteria

Implementation is ready for later lifecycle routes only when:

- all declared promotion targets are covered or explicitly justified as already
  conforming;
- no durable target depends on this proposal packet as authority;
- parent aggregate evidence cannot replace child, archive, generated
  publication, cleanup, Change, branch, final sync, or terminal proof receipts;
- stop-condition taxonomy is consistent across workflow and stage text;
- delivery, closeout-change, closeout-worktree, default-work-unit, and
  closeout state machine surfaces agree on handoff inputs, returned evidence,
  downgrade behavior, and no-substitution boundaries;
- required validators pass or blockers are recorded;
- `support/implementation-conformance-review.md` exists and validates through
  `validate-proposal-implementation-conformance.sh --package <proposal_path>`;
- `support/post-implementation-drift-churn-review.md` exists and validates
  through `validate-proposal-post-implementation-drift.sh --package
  <proposal_path>`;
- no closeout, archive-ready, delivered, landed, synced, or cleaned claim is
  made before the owning validators and receipts pass.

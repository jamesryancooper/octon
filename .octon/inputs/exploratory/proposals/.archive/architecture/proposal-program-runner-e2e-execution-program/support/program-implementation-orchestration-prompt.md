# Program Implementation Orchestration Prompt

proposal_id: proposal-program-runner-e2e-execution-program
generated_at: 2026-05-30T21:46:51Z
updated_at: 2026-05-30T23:21:25Z
generator: octon-proposal-lifecycle-generate-program-implementation-orchestration-prompt
parent_strict_review_gate: passed
program_child_readiness_gate: passed
child_authority_preserved: yes

## Explicit Implementation Goal

Implement the `proposal-program-runner-e2e-execution-program` end to end so
Octon's `proposal-program` lifecycle runner can reliably drive a full proposal
program lifecycle with `--execute-routes`, while preserving existing route
ownership, delegation, workflow, recovery, cancellation, replay, checkpoint,
lock, phase-loop, disclosure-tier, evidence-retention, publication, registry,
closeout, archive, and authority boundaries.

The implementation must make later proposal-program runs require less manual
handoff work by giving the runner a bounded plan-execute-replan loop. It must
remain proof-gated, recoverable, auditable, and fail-closed in the same way this
program expects future proposal-program lifecycle runs to behave.

## Operating Contract

Use this prompt only when the operator has explicitly authorized implementation
of this program. If implementation authority is absent, stop after recording a
handoff-only plan and do not mutate durable runtime surfaces.

Act as the accountable orchestrator for the parent program. Emulate the target
proposal-program runner behavior during this implementation run:

1. Read live state from the current repository, lifecycle contracts, generated
   effective projections, child manifests, child reviews, child prompts, and
   retained evidence.
2. Select the next eligible parent route or child batch from the program child
   registry and dependency gates.
3. Emit or update retained handoff/checkpoint evidence before dispatching work.
4. Verify before-dispatch gates, including review freshness, child readiness,
   authority, cleanup, lock, and route-declared prerequisites.
5. Execute only the selected child-owned prompt or route boundary.
6. Reread produced receipts and validation evidence after execution.
7. Classify blockers, recover where the contract allows, and continue
   independent child work when safe.
8. Release locks or record stale/unsafe locks on every exit path.
9. Replan from live state after each parent route or runnable child batch.

Do not treat `planned`, `route-ready`, or `program-route-handoff` as completion.
Those states only prove that the next handoff exists.

## Required Program Inputs

- Parent program:
  `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program`
- Child registry:
  `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/child-packet-index.yml`
- Source coverage:
  `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-traceability-matrix.md`
- Child authority contract:
  `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/architecture/child-packet-contract.md`
- Closeout policy plan:
  `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/architecture/program-closeout-plan.md`

## Child Packets

Execute child work through each child packet's own
`support/executable-implementation-prompt.md` and proposal-packet lifecycle.

1. `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-current-state-gap-map`
2. `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-planning-replan-loop`
3. `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-executor-delegation-gates`
4. `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-evidence-run-control`
5. `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-child-scheduling-recovery`
6. `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-verification-correction-routing`
7. `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-cleanup-hygiene`
8. `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-closeout-archive-policy`
9. `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-generated-state-publication`
10. `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-tests-fixtures`

## Sequencing And Batching

Use `gated-parallel` coordination, but keep child authority independent.
Dependency gates are verification gates, not status labels.

1. Execute `proposal-program-runner-current-state-gap-map` first. Use its audit
   to confirm the minimum owned surfaces and avoid reimplementing behavior owned
   by existing routes, validators, workflows, publication scripts, registry
   scripts, evidence-tier contracts, or runtime machinery.
2. Execute `proposal-program-runner-planning-replan-loop` after the gap map.
3. Execute `proposal-program-runner-executor-delegation-gates` and
   `proposal-program-runner-evidence-run-control` after planning/replan passes.
   These may proceed as one child batch only if their write scopes do not
   conflict and all gates pass.
4. Execute `proposal-program-runner-child-scheduling-recovery` after planning,
   delegation, and run-control behavior is bounded.
5. Execute `proposal-program-runner-verification-correction-routing` after
   scheduler behavior is implemented and evidenced.
6. Execute `proposal-program-runner-cleanup-hygiene` after scheduler and
   evidence/run-control requirements are available.
7. Execute `proposal-program-runner-closeout-archive-policy` after
   verification/correction, cleanup/hygiene, and evidence/run-control pass.
8. Execute `proposal-program-runner-generated-state-publication` when authored
   source changes require canonical generated-state refresh. Do not hand-edit
   generated state.
9. Execute `proposal-program-runner-tests-fixtures` last as aggregate assurance
   across all implemented slices.

Do not let non-fatal parent maintenance routes starve runnable child routes.
Continue independent children only when recovery policy and write scopes allow.

## Authority And Delegation Rules

- The runner remains an orchestrator. It coordinates and delegates; it does not
  own route behavior.
- Extension routes and workflow routes must both go through the shared lifecycle
  executor adapter according to contract-declared route metadata and each
  route's `delegation_contract`.
- Durable mutation requires retained delegation proof before dispatch.
- Typed human exception grants unblock only the named route in the named program
  run and must be consumed as evidence before dispatch.
- Parent evidence may summarize child outcomes only. It never satisfies child
  receipts, child promotion targets, child validation verdicts, child terminal
  outcomes, or child archive metadata.
- Child manifests, subtype manifests, receipts, validation verdicts, promotion
  targets, acceptance criteria, and archive metadata remain child-owned.

## Forbidden Shortcuts

- Do not implement runner-local workflow shortcuts.
- Do not infer schedulable routes from available skills or prompt bundles.
- Do not schedule support prompt bundles unless the authored lifecycle contract
  declares the route and generated projections are refreshed.
- Do not introduce new proposal manifest statuses.
- Do not directly rewrite child or parent proposal status; use workflow-owned
  `promote-proposal`.
- Do not move validation, promotion, closeout, cleanup, archive, publication,
  registry, disclosure-tier, or run-lifecycle ownership into the generic runner.
- Do not hand-edit `.octon/generated/**`.
- Do not publish raw local evidence as retained publishable evidence.

## Handoff, Evidence, And Checkpoints

For every selected parent route or child batch:

1. Record the planned route or child batch, selected inputs, gates checked,
   lock posture, and expected receipts.
2. Keep raw executor stdout/stderr, machine paths, cleanup transcripts, and
   private operational detail under `.octon/state/evidence/local/**` if
   retained.
3. Keep concise publishable claim evidence under `.octon/state/evidence/runs/**`
   with disclosure-tier metadata, limitations, redactions, digests, and
   path references when local raw evidence is cited.
4. Keep operator/release-facing disclosure under
   `.octon/state/evidence/disclosure/**`.
5. Treat `.octon/generated/**` as derived, rebuildable, and non-authority.
6. Record checkpoint and event convergence evidence sufficient for replay.

Hosted closeout and archive gates must not depend on local-only raw evidence.

## Recovery And Fail-Closed Behavior

Recover only when the relevant contract, route prompt, validator, workflow, or
runtime policy allows recovery. Otherwise fail closed with retained evidence and
route guidance.

Fail closed for:

- authority ambiguity;
- unsafe destructive actions;
- foreign, ambiguous, manual-review, or user-authored residue;
- approval-gated policy boundaries;
- exhausted recovery budgets;
- unsupported lifecycle modes;
- missing required authority-zone evidence;
- unsafe resume or replay state;
- checkpoint/event divergence;
- stale or ambiguous locks;
- unsupported blocker classes;
- unknown cleanup predicates;
- unregenerable stale receipts or generated projections;
- invalid evidence-tier publication attempts;
- any attempt to require local-only evidence for hosted closeout or archive.

When a child route fails, times out, or emits stale/missing evidence, classify
the blocker, apply configured recovery if safe, write a blocked receipt if
needed, and continue independent children only where policy allows.

## Generated State And Publication

Update authored extension/proposal sources first. Refresh generated state only
through canonical scripts.

Use these commands when their surfaces are affected:

```sh
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write
```

Treat generated projection drift as refreshable only when the artifact is
generated/non-authority and the relevant script can regenerate it.

## Verification And Correction

Run verification through existing route and validator ownership only.

Required coverage includes:

- handoff-only default behavior;
- `--execute-routes` delegation through the shared executor adapter;
- contract-declared route inventory from authored contracts/generated
  projections;
- phase-context non-authority;
- promotion ownership;
- recovery budgets;
- verification/correction sequencing;
- hygiene classification and cleanup predicates;
- evidence-disclosure-tier separation;
- canonical generated-state refresh;
- timeout handling;
- implemented-state review-gate behavior;
- cancellation, resume, replay safety, and lock cleanup;
- no-new-status enforcement;
- current closeout-policy enforcement for archived/rejected required children;
- no forced child archival when an alternate active policy accepts implemented
  children;
- blocked closeout/archive receipt generation.

Run correction only for failed, stale, or missing findings. Supply
route-declared inputs such as `finding_id` from retained verification findings.
Do not synthesize unbound correction work, and do not rerun correction for clean
packets.

After correction, rerun affected validators and required aggregate parent
validators. Bound correction loops by retry budget and write blocked correction
receipts when unsafe.

## Parent Evidence Required After Implementation

After child implementation evidence exists and aggregate validation passes,
write parent-local `support/program-implementation-orchestration-run.md` with:

- `verdict`;
- `implemented_at`;
- `promotion_evidence_count`;
- `child_authority_preserved: yes`;
- child outcome summary;
- aggregate validation summary;
- recovery/blocker summary;
- retained evidence references.

This parent evidence may summarize child outcomes only. It must not satisfy
child receipts or rewrite child lifecycle authority.

Before parent closeout, produce and pass:

- `support/program-implementation-orchestration-conformance-review.md`;
- `support/program-post-implementation-orchestration-drift-churn-review.md`.

Each implemented child must also produce and pass:

- `support/implementation-conformance-review.md`;
- `support/post-implementation-drift-churn-review.md`.

## Closeout And Archive

After verification and targeted correction pass, delegate child packet closeout
routes. Enforce the active proposal-program `program.closeout_policy`.

Under the current authored policy, required non-deferred children must reach
terminal outcomes `archived` or `rejected` unless explicit deferral,
supersession, replacement, or rejection evidence applies. Implemented child
status alone is not enough for current parent closeout.

If child `proposal-closeout` authorizes archive and the active policy requires
archived child terminal outcomes, delegate child `archive-proposal` workflow
routes before parent terminal closeout. Archive mutation remains workflow-owned.

Refuse parent closeout/archive if:

- child terminal outcomes do not satisfy the active closeout policy;
- required child receipts are missing or stale;
- parent aggregate evidence is stale;
- publication/archive hygiene fails;
- generated state is stale and unrefreshed;
- archive authorization is absent;
- evidence-tier boundaries would require local-only raw evidence for hosted
  closeout/archive.

Blocked closeout or archive receipts must include verdict, archive
authorization, selected git route, blocker class, owned/in-scope/foreign counts,
hygiene fingerprint, cleanup summary, and next route condition.

## Minimum Commands Before Claiming Completion

Run the current parent and program gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
.octon/framework/engine/runtime/run lifecycle run --lifecycle proposal-program --target .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program
```

Add every child-selected Rust, shell, lifecycle, publication, registry,
evidence-tier, replay, lock, cancellation, closeout/archive, and
negative-control test from child prompts. Do not claim completion while any
required child or aggregate validator fails.

## Later Durable Route Command

When explicitly authorized to run the program through durable route execution,
use the repo-local launcher:

```sh
.octon/framework/engine/runtime/run lifecycle run --lifecycle proposal-program --target .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program --execute-routes
```

If the current implementation of the runner cannot yet execute the full program
end to end, use this prompt as the orchestration contract: execute the eligible
child prompts in dependency order, retain the same evidence and receipts the
future runner would require, replan after every completed child batch, and stop
with a blocked receipt rather than bypassing a gate.

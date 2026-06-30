# Target Architecture

## Decision

Add a clean-delivery continuation posture to the existing proposal-program
runner. The runner remains an orchestrated replan loop: it reconstructs parent
and child state from live manifests, child-owned receipts, checkpoints, and
retained run evidence; selects the next deterministic parent or child route;
and delegates selected routes only through the existing lifecycle executor
adapter when `--execute-routes` is set.

The target state is a routing improvement, not a new authority plane. The
runner may produce route-decision, retry, resume, and delivery-handoff
evidence. It must not satisfy child receipts, mutate durable targets directly,
promote generated projections by hand, close Changes, clean branches, delete
residue, or synthesize terminal proof.

## Affected Artifacts

### `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`

- current assumption: the program controller already plans from
  `proposal.yml`, `resources/child-packet-index.yml`, lifecycle contracts,
  checkpoints, receipts, and compact planner artifacts.
- required change: extend route selection so a clean-delivery continuation can
  choose the next route when parent state, child state, dependency vector, and
  gate evidence make exactly one route safe.
- owner role: runtime implementation owner.
- priority: required.
- rationale: default unattended continuation must remove operator prompts only
  when the existing route contract already owns the next action.

Required behavior:

- keep non-execute mode as `program-route-handoff` evidence only;
- in execute mode, consume one bounded step per selected parent route or
  runnable child batch;
- choose from route-owned next steps such as child review/revise,
  implementation-prompt generation, implementation, verification/correction,
  promotion, closeout, archive, parent status correction, parent closeout, and
  parent delivery handoff;
- persist `planner-state.yml`, `program-context-capsule.yml`,
  `blocker-ledger.yml`, `route-decision-receipt.yml`,
  `model-routing-receipt.yml`, and `action-slice-ledger.yml` before dispatch;
- replan from live repository state after every material mutation or recovery
  attempt;
- fail closed when child-owned evidence is missing, stale, or replaced by
  parent summaries.

### `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`

- current assumption: the lifecycle contract declares
  `execution_strategy: orchestrated-replan-loop`, delivery mode metadata,
  planner compact artifacts, stop-condition taxonomy, and bounded recovery
  recipes.
- required change: declare the clean-delivery continuation profile, route
  selection inputs, stop conditions, retry fingerprint fields, resume source
  refs, and Proposal Program Delivery handoff requirements.
- owner role: proposal lifecycle contract owner.
- priority: required.
- rationale: the runner must derive allowed continuation behavior from the
  published lifecycle contract rather than from prompt text, proposal-local
  receipts, generated projections, or host state.

Required contract coverage:

- `target_outcome=cleaned` is a handoff input to Proposal Program Delivery, not
  proof that delivery completed;
- child receipts remain child-owned and parent aggregate receipts may cite them
  only by path and digest;
- generated effective extension and capability outputs remain derived-only and
  refresh through owning publisher routes;
- stale receipt refresh is allowed only at a stable digest boundary and through
  the route that owns the stale receipt;
- retry budgets and recovery recipes must name idempotency class,
  route/action owner, post-attempt validation, and human-boundary behavior.

### `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/`

- current assumption: `octon-proposal-run-program-lifecycle.md` documents the
  program runner, `--execute-routes`, deterministic resume, bounded steps, and
  child authority boundaries.
- required change: document the clean-delivery continuation invocation, the
  non-execute handoff behavior, the execute-route step budget, and the stop
  before delivery mutation, hosted mutation, branch cleanup, or deletion.
- owner role: proposal lifecycle command owner.
- priority: required.
- rationale: operator-facing command text must match the runner and lifecycle
  contract so command use does not widen authority.

### `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/`

- current assumption: `octon-proposal-lifecycle-run-program-lifecycle/SKILL.md`
  mirrors the runner command and states that the wrapper has no prompt bundle.
- required change: keep the skill and registry metadata aligned to the
  continuation mode, route-selection proof, retry/resume semantics, and
  forbidden authority transfers.
- owner role: proposal lifecycle skill owner.
- priority: required.
- rationale: generated effective skill projections must remain consistent with
  authored additive inputs and cannot become a second scheduler authority.

### Generated Effective Projections

- current assumption: generated extension catalogs, route bundles, capability
  routing, and published bundled-first-party projections are derived outputs.
- required change: future implementation must refresh generated effective
  outputs through publisher scripts and retained publication/freshness
  receipts after additive extension inputs change.
- owner role: generated publication route owner.
- priority: validation required, not direct packet target.
- rationale: raw additive inputs and generated projections cannot authorize
  runtime routing unless publication and freshness evidence validates.

### Retained Evidence

- current assumption: program runner evidence lives under
  `.octon/state/evidence/runs/workflows/<program-run-id>/` and run control
  lives under `.octon/state/control/execution/runs/<program-run-id>/`.
- required change: future implementation must retain route decisions, retry
  fingerprints, resume source refs, recovery attempts, handoff inputs, child
  receipt digests, and validation outcomes in those roots.
- owner role: runtime evidence owner.
- priority: required.
- rationale: unattended continuation is only debuggable when each route
  selection and retry decision has replayable evidence.

## Route Selection Model

The runner should choose a route only when the next action is uniquely
determined by current state and owned by an existing route:

1. Reconstruct the parent program state from `proposal.yml`, the child packet
   index, current child manifests, child support receipts, checkpoints, and
   retained evidence source refs.
2. Validate child registry integrity, dependency gates, child readiness,
   parent review state, delivery readiness preconditions, and generated
   freshness indicators.
3. Prefer child-owned route progression before parent delivery. Candidate
   child routes include review, revision, prompt generation, implementation,
   verification/correction, promotion, closeout, archive, and residue
   classification only when the child lifecycle contract owns that step.
4. Prefer parent route progression only after child gates prove no child-owned
   blocking route remains and parent receipts are fresh.
5. Produce a route-decision receipt naming selected route, route owner, inputs,
   source refs, digests, blocked alternatives, and authority boundary.
6. Dispatch only through the shared lifecycle executor adapter when execution
   is enabled and the delegation contract proves safe unattended execution.
7. Replan from live state before considering the next route.

## Retry And Resume Model

The runner should treat retries as bounded recovery, not as repeated prompt
attempts:

- fingerprint each blocker by blocker class, child id when present, route id,
  target digest, receipt digest, write-scope digest, and stable digest
  boundary;
- retry only when the lifecycle contract declares an idempotent or bounded
  recovery recipe and the authority zone is allowed;
- stop on unchanged blocker fingerprints after the route budget is exhausted;
- rebaseline only from current-run, child-owned, or route-owned evidence;
- resume only when checkpoint event heads, child registry digest, source refs,
  and model-visible context digests still verify;
- reject parent summaries, generated projections, chat, or host UI state as
  substitutes for child receipts or route evidence.

## Delivery Handoff Model

When child and parent gates pass, the runner may hand off to Proposal Program
Delivery with `target_outcome=cleaned`. The handoff evidence must include:

- parent program path and digest;
- child registry digest;
- selected child receipt refs and digests;
- parent receipt refs and digests;
- delivery-readiness preflight status;
- generated freshness status;
- route-decision receipt ref;
- explicit statement that Proposal Program Delivery owns landing, sync,
  cleanup, branch cleanup, terminal proof, and the final `cleaned` claim.

The runner must stop before any delivery mutation when delivery readiness is
missing, stale, contradicted, or owned by another route.

## Stop Conditions

- `authority-gap`: a route-owned receipt is missing for the claimed transition;
  stop for the owning route.
- `ownership-conflict`: two routes claim the same mutation or evidence; stop
  for proposal review or human governance.
- `stale-evidence`: stored digest, event head, review digest, receipt digest,
  or generated freshness proof mismatches current source; route to the owning
  refresh path or stop.
- `parent-summary-substitution`: parent aggregate evidence is used as child
  evidence; stop and require child-owned receipt evidence.
- `unsafe-mutation`: git write preflight, dirty-source posture, worktree
  baseline, include-path classification, or cleanup authority is missing;
  stop before mutation.
- `approval-required`: hosted, branch, landing, cleanup, exception, or policy
  authorization is required; stop before dispatch unless retained authority
  evidence proves the route is delegated safely.
- `retry-budget-exhausted`: no progress after bounded attempts; stop with
  blocker fingerprint evidence.
- `unsafe-resume`: checkpoint, event log, child registry, or source digest
  cannot be verified; fail closed instead of continuing.
- `generated-authority-drift`: generated projections are stale or direct
  edited; route to publication/freshness owners, never consume them as
  authority.
- `delivery-proof-gap`: `target_outcome=cleaned` is requested before delivery
  receipt, evidence index, terminal proof, branch cleanup, or worktree hygiene
  proof exists; stop before the `cleaned` claim.

## Explicit Exclusions

- delivery workflow stage implementation;
- generated metadata and publication hardening beyond route input and
  freshness references;
- terminal validators and terminal proof synthesis;
- operator command wrappers beyond the program runner command and skill;
- Change closeout, branch cleanup, hosted provider mutation, repo hygiene
  deletion, archive relocation, or final clean-state proof.

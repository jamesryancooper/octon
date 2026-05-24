# Executable Implementation Prompt

implementation_prompt_id: workflow-history-replay-idempotency-compensation-implementation-prompt-2026-05-15
proposal_path: .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-15T21:28:00Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, or substitute for retained evidence.

Durable authority may land only in the declared promotion targets outside the
proposal path. Proposal-local support files, generated proposal registry
entries, source conversations, chat history, tool availability, MCP state,
Durable Object state, external workflow-engine state, and generated
projections are implementation input or derived context only. They are not
runtime, policy, control, support, or closeout authority.

## Mandatory Preflight

Before editing durable targets, re-read:

- repository ingress and the constitutional kernel;
- proposal workspace rules and the architecture proposal standard;
- `proposal.yml` and `architecture-proposal.yml`;
- `navigation/source-of-truth-map.md`;
- `architecture/target-architecture.md`;
- `architecture/implementation-plan.md`;
- `architecture/acceptance-criteria.md`;
- `validation-plan.md`;
- `RISK-REGISTER.md`;
- `support/implementation-grade-completeness-review.md`;
- `support/proposal-review.md`;
- live Run Lifecycle v1, Run Journal v1, Workflow Statechart v1,
  Task-Specific Execution Harness v1, Execution Authorization v1, Context Pack
  Builder v1, Authorized Effect Token v1, Evidence Store v1, runtime contract
  family, support-target, replay-store/runtime-bus, state/control,
  state/evidence, continuity, and generated non-authority surfaces that this
  packet touches.

Then run these gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation --require-implementation-authorization
```

Refuse implementation unless both commands pass, `proposal.yml#status` is
`accepted`, the review verdict is `accepted`,
`implementation_prompt_authorized: yes`, `open_blocking_findings_count: 0`, and
the reviewed packet digest is fresh.

Use this profile selection:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: one coherent workflow history, replay reconstruction,
  idempotency, retry, compensation, failure-receipt, validator, and evidence
  implementation across the approved target families, with no partial live
  state and with post-cutover validation before any success claim
- transitional exception: not authorized by this packet

The dependency `workflow-statechart-task-specific-execution-harness` is already
implemented in the live repository. Treat it as the current durable baseline,
not as authority to widen this packet beyond its own promotion targets.

## Target End State

The implemented end state is a bounded workflow-history and replay contract
that lets Octon reconstruct supported workflow histories from canonical run
journals and retained evidence, classify retry and compensation posture, and
fail closed when replay, idempotency, rollback, or compensation evidence is
insufficient.

The durable implementation must establish all of these facts:

- workflow history is reconstructed from the canonical run journal first:
  `.octon/state/control/execution/runs/<run-id>/events.ndjson`,
  `events.manifest.yml`, `runtime-state.yml`, bounded side artifacts, and
  retained evidence mirrors;
- replay reconstruction reports classify valid, drifted, incomplete, and
  unsupported histories without treating generated projections or proposal
  lineage as reconstruction authority;
- idempotency keys are required and duplicate keys are rejected or classified
  with deterministic retry/compensation posture;
- retry records classify retryable transient, validation, environment,
  rollback-then-retry, manual-review, non-retryable contract, and contamination
  reset cases without silently retrying unsupported work;
- compensation records describe bounded compensating action only and never
  imply full rollback, global transactionality, or universal replay of external
  systems;
- failure receipts and unsupported outcomes are retained and disclosed when
  replay, retry, idempotency, or compensation cannot be proven;
- validators prove positive and negative fixtures for replay reconstruction,
  idempotency, retry, compensation, unsupported rollback, and evidence
  placement;
- existing Run Lifecycle v1, Run Journal v1, Workflow Statechart v1,
  Execution Authorization v1, Context Pack Builder v1, Authorized Effect Token
  v1, Evidence Store v1, support-target, and fail-closed contracts remain
  canonical until a later validated cutover explicitly replaces them.

This packet does not authorize universal replay of arbitrary external systems,
full rollback, global transactionality, external workflow-engine authority,
Durable Object persistence as canonical control or evidence, connector
operation admission changes, generated/effective runtime publication, or
runtime crate edits.

## In Scope

Durable edits may touch only these promotion target families:

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/runtime/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/state/evidence/validation/proposals/workflow-history-replay-idempotency-compensation/20260515T213817Z/`

Expected durable outputs may include the smallest coherent set of files in
those families, such as:

- runtime narrative specs and schemas for workflow history and replay
  reconstruction, or explicit extensions to existing `run-journal-v1.md` and
  `run-lifecycle-reconstruction-v1.schema.json` when those are the correct
  canonical homes;
- strict constitutional runtime schemas for workflow history, replay
  reconstruction, idempotency, retry, compensation, and failure receipts,
  including updates to existing `retry-record-v1.schema.json`,
  `compensation-record-v1.schema.json`, `replay-manifest-v2.schema.json`, and
  `replay-pointers-v1.schema.json` where strengthening existing contracts is
  safer than adding conflicting successors;
- runtime contract family registration and README updates under
  `.octon/framework/constitution/contracts/runtime/` when new or strengthened
  contract files require discoverability;
- a child-specific validator under
  `.octon/framework/assurance/runtime/_ops/scripts/`, preferably
  `validate-workflow-history-replay-idempotency-compensation.sh`;
- retained validation evidence under
  `.octon/state/evidence/validation/proposals/workflow-history-replay-idempotency-compensation/<timestamp>/`.

After durable edits land, packet-local receipt updates are required:

- `.octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation/support/post-implementation-drift-churn-review.md`

Retained validation and promotion evidence must live outside `inputs/**`,
preferably under:

- `.octon/state/evidence/validation/proposals/workflow-history-replay-idempotency-compensation/<timestamp>/`
- `.octon/state/evidence/runs/workflows/<run-id>/` when a lifecycle runner
  creates run evidence

## Out Of Scope

Do not edit these surfaces for this packet:

- `.octon/framework/engine/runtime/crates/**`
- `.octon/instance/**`
- `.octon/state/control/**`, except through a separately authorized lifecycle
  run that records its own control evidence
- `.octon/generated/**`, including `.octon/generated/effective/**`,
  `.octon/generated/cognition/**`, and `.octon/generated/proposals/registry.yml`
- root `README.md`, root `AGENTS.md`, `CLAUDE.md`, or repo-local projection
  adapters
- support-target declarations, connector admissions, governance exclusions,
  connector trust dossiers, capability packs, or support matrices
- external workflow engines, Durable Object adapters, MCP integrations,
  connector operation admission behavior, agent-node/model-call contracts, or
  model routing policy

Do not change `proposal.yml#status`; leave it as `accepted`. The
`promote-proposal` lifecycle route owns the later rewrite to `implemented`.

If implementation requires any out-of-scope file, new authority class, support
claim, runtime cutover, generated/effective publication, runtime crate change,
or target-family widening, stop and report `needs-packet-revision` with
evidence.

## Ordered Workstreams

### 0. Preflight And Evidence Directory

1. Record current worktree state and preserve unrelated existing edits.
2. Run the mandatory implementation-readiness and strict review gates.
3. Create a retained evidence directory under
   `.octon/state/evidence/validation/proposals/workflow-history-replay-idempotency-compensation/<timestamp>/`.
4. Record the Profile Selection Receipt there and in
   `support/implementation-run.md`: `release_state=pre-1.0`,
   `change_profile=atomic`, `transitional_exception_note=not authorized`.
5. Capture baseline searches for current workflow history, replay,
   idempotency, retry, compensation, failure receipt, Run Journal, runtime
   family, validator, generated, state/control, state/evidence, and continuity
   surfaces.

### 1. Runtime Spec Contract

Create or update the smallest runtime spec files under
`.octon/framework/engine/runtime/spec/` needed to define:

- workflow-history inputs, source precedence, reconstruction algorithm, and
  authority boundary;
- replay reconstruction report shape, including valid, drifted, incomplete,
  unsupported, and blocked outcomes;
- event reference roles for state rebuild, transition, replay, disclosure,
  evidence snapshot, and drift;
- idempotency key requirements and duplicate-key behavior;
- retry classes, retry limits, blocked retry outcomes, and contamination reset
  posture;
- compensation posture, including bounded compensating action, unsupported
  rollback, and explicit no-global-transactionality language;
- failure receipts or failure outcome refs for replay, retry, idempotency, and
  compensation gaps;
- evidence placement and disclosure requirements for replay and compensation
  outcomes.

Keep the canonical run journal first. Do not redefine the run journal,
`runtime-state.yml`, `run-contract.yml`, execution authorization, context-pack,
effect-token, evidence-store, support-target, workflow statechart, or
task-specific execution harness contracts except by explicit reference or
bounded extension inside the approved target families.

### 2. Constitutional Runtime Contracts

Under `.octon/framework/constitution/contracts/runtime/`, add or update the
minimal schema and family registration surfaces needed to make the spec
machine-checkable.

The schemas must be strict enough for validators to reject:

- missing or duplicate idempotency keys;
- sequence gaps, hash mismatches, manifest mismatches, or
  `runtime-state.yml` drift in replay reconstruction;
- missing retained evidence mirrors, replay pointers, trace pointers,
  disclosure refs, or evidence placement receipts;
- unsupported live side-effect replay without a fresh authorization grant;
- invalid retry classes, exhausted retry limits, and silent retry of
  non-retryable contract violations;
- compensation records that imply global transactionality, full rollback, or
  external-system replay guarantees;
- missing failure receipts for replay, retry, idempotency, or compensation
  gaps;
- generated projections, raw input refs, proposal-local refs, MCP/tool
  availability, Durable Object state, or external workflow-engine state used
  as runtime, policy, control, support, or evidence authority.

Update `family.yml` and `README.md` only where needed to register new or
strengthened runtime contract files and preserve the existing runtime family
model.

### 3. Child-Specific Validator And Fixtures

Add validator coverage under
`.octon/framework/assurance/runtime/_ops/scripts/`.

Use existing helper style from neighboring validators. Prefer one focused
validator over a broad framework. The validator may create temporary positive
and negative fixtures at runtime and must retain result evidence under the
evidence directory. Do not add durable fixture roots outside the approved
promotion targets unless the packet is revised.

Validator coverage must prove:

- a valid workflow history reconstructs from canonical journal and retained
  evidence mirrors;
- drifted histories fail or classify drift when journal hash, sequence,
  manifest, or `runtime-state.yml` facts disagree;
- incomplete histories fail or classify replay gaps when side artifacts,
  replay pointers, trace pointers, evidence snapshots, or disclosure refs are
  missing;
- unsupported histories fail closed for external workflow-engine authority,
  Durable Object persistence as control/evidence, generated projection
  authority, raw input/proposal authority, and live side-effect replay without
  fresh authorization;
- duplicate idempotency keys are detected;
- retry class, attempt counter, attempt limit, and result rules reject invalid
  retry policy;
- compensation fixtures distinguish bounded compensation from full rollback
  and reject universal transactionality claims;
- failure receipts or blocked outcome records are required for unsupported
  replay, retry, idempotency, and compensation cases;
- retained evidence is written under `.octon/state/evidence/**` and never under
  `.octon/generated/**`.

Suggested validator command:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-workflow-history-replay-idempotency-compensation.sh --evidence-root .octon/state/evidence/validation/proposals/workflow-history-replay-idempotency-compensation/<timestamp>
```

### 4. Evidence Publication

Use `.octon/state/evidence/**` only for retained validation and run evidence.
Do not use evidence files as authored authority, mutable control truth, or
generated output.

The retained evidence directory must include, at minimum:

- `implementation-evidence.md` with files changed, validator results, boundary
  scans, fixture coverage, evidence placement, rollback posture, and remaining
  blockers;
- `validation-summary.yml` with command, result, warning count when known, and
  retained evidence refs for each validator;
- `child-specific-validator.yml` or equivalent receipt naming the child
  validator, positive fixtures, negative fixtures, and final verdict.

No generated/runtime publication is required or authorized by this packet. If
the implementation appears to need `.octon/generated/effective/**`,
`.octon/generated/cognition/**`, or proposal registry publication, stop and
record a blocked outcome or request packet revision.

### 5. Boundary And Compatibility Review

Run searches over the approved durable targets and record results in retained
evidence:

```sh
rg -n "workflow-history-replay-idempotency-compensation|inputs/exploratory/proposals" .octon/framework/engine/runtime/spec .octon/framework/constitution/contracts/runtime .octon/framework/assurance/runtime/_ops/scripts .octon/state/evidence/validation/proposals/workflow-history-replay-idempotency-compensation
rg -n -i "universal replay|full rollback|global transaction|external workflow|Durable Object|generated.*authority|proposal.*authority|MCP.*authority|tool availability.*authority" .octon/framework/engine/runtime/spec .octon/framework/constitution/contracts/runtime .octon/framework/assurance/runtime/_ops/scripts .octon/state/evidence/validation/proposals/workflow-history-replay-idempotency-compensation
```

The first scan must not find durable active dependencies on this proposal path
outside retained evidence or proposal lifecycle validator logic. The second
scan may return negative controls only when surrounding text or test logic
clearly rejects the claim.

### 6. Required Validation

Run these proposal gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation --require-implementation-authorization
```

Run these target-family validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-v1.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-transition-coverage.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-journal-contracts.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-lifecycle-normalization.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-contract-family-version-coherence.sh
bash .octon/framework/assurance/runtime/_ops/scripts/verify-runtime-family-depth.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-no-raw-generated-effective-runtime-reads.sh
```

Run the new child-specific validator added by this implementation. If named
differently, record the exact command in retained evidence:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-workflow-history-replay-idempotency-compensation.sh --evidence-root .octon/state/evidence/validation/proposals/workflow-history-replay-idempotency-compensation/<timestamp>
```

Run checksum verification for the reviewed packet files:

```sh
(cd .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation && shasum -a 256 -c SHA256SUMS.txt)
```

If a validator fails because the packet's existing inventory omits newly
generated support receipts, record it separately. Do not edit reviewed packet
artifacts merely to satisfy inventory churn when doing so would stale the
accepted review digest. If reviewed packet artifacts must change, stop and
route to packet revision.

If existing `replay_store` behavior is cited as proof, run this advisory check
without editing runtime crates:

```sh
(cd .octon/framework/engine/runtime/crates && cargo test -p octon_replay_store)
```

### 7. Retained Evidence And Implementation Run Receipt

Create a retained evidence note under the evidence directory with:

- implementation timestamp;
- files changed;
- exact validation commands and exit statuses;
- search output or summaries with paths;
- diff summary by promotion target family;
- replay reconstruction fixture and negative-control evidence;
- idempotency, retry, compensation, unsupported rollback, and failure-receipt
  evidence;
- evidence placement receipts;
- explicit exclusions preserved;
- rollback posture;
- remaining blockers or `none`.

Then create or update `support/implementation-run.md` with at least:

```markdown
# Implementation Run Receipt

verdict: pass|fail
implemented_at: <UTC timestamp>
promotion_evidence_count: <number>

## Profile Selection Receipt

release_state: pre-1.0
change_profile: atomic
transitional_exception_note: not authorized

## Durable Changes

...

## Retained Evidence

- <retained evidence path>

## Validators Run

...

## Rollback Posture

...

## Blockers

...
```

Use `verdict: pass` only when durable promotion work has landed in the
declared target families, retained evidence exists outside `inputs/**`, and
required validation passed or has explicitly non-blocking warnings. Otherwise
use `verdict: fail` and report a blocked route outcome.

### 8. Post-Implementation Gate Receipts

After durable changes and `support/implementation-run.md`, create or update
`support/implementation-conformance-review.md` with:

- `verdict: pass|fail`
- `unresolved_items_count`
- sections named `Blockers`, `Checked Evidence`, `Promotion Target Coverage`,
  `Implementation Map Coverage`, `Validator Coverage`, `Generated Output
  Coverage`, `Rollback Coverage`, `Downstream Reference Coverage`,
  `Exclusions`, and `Final Closeout Recommendation`

Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation
```

Create or update `support/post-implementation-drift-churn-review.md` with:

- `verdict: pass|fail`
- `unresolved_items_count`
- sections named `Blockers`, `Checked Evidence`, `Backreference Scan`,
  `Naming Drift`, `Generated Projection Freshness`, `Manifest And Schema
  Validity`, `Repo-Local Projection Boundaries`, `Target Family Boundaries`,
  `Churn Review`, `Validators Run`, `Exclusions`, and
  `Final Closeout Recommendation`

Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation
```

## Rollback Posture

Rollback is removal or reversion of the workflow history, replay
reconstruction, idempotency, retry, compensation, failure-receipt, validator,
and retained evidence changes made by this packet, plus retained evidence
showing why rollback occurred.

Before claiming success, verify that rollback would restore the prior Run
Lifecycle v1, Run Journal v1, Workflow Statechart v1, and runtime contract
family posture without leaving:

- partial schemas without validators;
- validators without corresponding contract surfaces;
- retained evidence that claims unsupported full rollback or global
  transactionality;
- generated or proposal-path dependencies in durable targets;
- state/control mutations outside a separately authorized run;
- stale retry, compensation, replay pointer, or failure receipt refs;
- live support claims for excluded future work.

If rollback cannot be cleanly bounded to this packet's durable targets, stop
and report `blocked-unsafe` or `needs-packet-revision`.

## Delegation

Delegation is optional. If used, split work by disjoint write scope and keep one
integration owner accountable for final validation and receipts.

Suggested disjoint scopes:

- runtime specs and constitutional runtime schemas;
- validator and fixture/negative-control strategy;
- retained evidence publication under `.octon/state/evidence/**`;
- integration owner for evidence, receipts, final validation, and status
  discipline.

No subagent, worker, or delegated tool may widen promotion targets, approve
execution, mutate `proposal.yml#status`, edit runtime crates, or treat
proposal-local support files as implementation proof.

## Terminal Criteria

The implementation route may report success only when all of these are true:

- durable changes are limited to the declared promotion targets;
- required retained evidence exists outside `inputs/**`;
- `support/implementation-run.md` exists with `verdict: pass`,
  `implemented_at`, and `promotion_evidence_count`;
- `support/implementation-conformance-review.md` exists with `verdict: pass`
  and `unresolved_items_count: 0`;
- `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation`
  passes;
- `support/post-implementation-drift-churn-review.md` exists with
  `verdict: pass` and `unresolved_items_count: 0`;
- `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation`
  passes;
- no explicit exclusion has been implemented or implied as live support;
- no generated output or proposal-local material is used as authority;
- `proposal.yml#status` remains `accepted`.

Refuse implemented, closeout, or archive-ready claims while either
post-implementation receipt is missing, failing, unresolved, stale, blocked, or
unvalidated. The separate `promote-proposal` lifecycle route owns the
implemented-status rewrite, and later closeout/archive routes own closeout and
archival claims.

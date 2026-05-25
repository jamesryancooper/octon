# Executable Implementation Prompt

implementation_prompt_id: workflow-statechart-task-specific-execution-harness-implementation-prompt-2026-05-15
proposal_path: .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-15T00:43:19Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, or substitute for retained evidence.

Durable authority may land only in the declared promotion targets outside the
proposal path. Proposal-local support files, generated proposal registry
entries, source conversations, chat history, tool availability, MCP state,
Durable Object state, external workflow-engine state, and generated projections
are implementation input or derived context only. They are not runtime,
policy, control, support, or closeout authority.

## Mandatory Preflight

Before editing durable targets, re-read:

- repository ingress and constitutional kernel;
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
- live Run Lifecycle v1, Execution Authorization v1, Context Pack Builder v1,
  Authorized Effect Token v1, Evidence Store v1, support-target, generated
  projection, and runtime contract surfaces that this packet touches.

Then run these gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness --require-implementation-authorization
```

Refuse implementation unless both commands pass, `proposal.yml#status` is
`accepted`, the review verdict is `accepted`,
`implementation_prompt_authorized: yes`, `open_blocking_findings_count: 0`, and
the reviewed packet digest is fresh.

Use this profile selection:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: one coherent statechart and harness contract implementation
  across the approved target families, with no partial live state and with
  post-cutover validation before any success claim
- transitional exception: not authorized by this packet

## Target End State

The implemented end state is a workflow-statechart and task-specific execution
harness contract that overlays and converges with Run Lifecycle v1 without
creating a second control root.

The durable implementation must establish all of these facts:

- workflow statechart semantics define states, legal transitions, invalid
  transitions, reason codes, and Run Lifecycle v1 correspondence;
- the statechart binds to existing run control roots, run journals, runtime
  state, rollback posture, and retained run evidence instead of replacing
  them;
- a task-specific execution harness record or compilation receipt binds the
  objective, run contract, support target, capability envelope, context pack,
  authorization route, effect-token classes, evidence obligations,
  rollback/compensation posture, human-intervention posture, model/cost
  policy, and closeout criteria;
- generated statechart diagrams or read models are derived-only and visibly
  non-authoritative;
- validators prove positive and negative statechart cases, harness envelope
  completeness, Run Lifecycle v1 parity, placement boundaries, and generated
  non-authority;
- existing run lifecycle, execution authorization, context-pack, effect-token,
  evidence-store, support-target, and fail-closed contracts remain canonical
  until later validated cutover evidence says otherwise.

This packet does not authorize a runtime cutover, compatibility retirement,
external workflow engine adoption, Durable Object coordination adapter, MCP
integration, connector operation admission changes, or an agent-node/model-call
contract beyond harness slots needed by a later child packet.

## In Scope

Durable edits may touch only these promotion target families:

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/runtime/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/generated/cognition/projections/materialized/`

Expected durable outputs may include the smallest coherent set of files in
those families, such as:

- runtime narrative specs and schema mirrors for
  `workflow-statechart-v1` and `task-specific-execution-harness-v1`;
- constitutional runtime contract schemas for workflow statechart,
  task-specific execution harness, and harness compilation or validation
  receipts;
- updates to runtime contract family registration files when new contract
  schemas are added;
- validator scripts that create or consume positive and negative fixtures
  without adding durable fixture directories outside the approved targets;
- generated cognition projection files or index entries that describe the
  statechart or harness contract as derived-only read models.

After durable edits land, packet-local receipt updates are required:

- `.octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness/support/post-implementation-drift-churn-review.md`

Retained validation and promotion evidence must live outside `inputs/**`,
preferably under:

- `.octon/state/evidence/validation/proposals/workflow-statechart-task-specific-execution-harness/<timestamp>/`
- `.octon/state/evidence/runs/workflows/<run-id>/` when a lifecycle runner
  creates run evidence

## Out Of Scope

Do not edit these surfaces for this packet:

- `.octon/framework/engine/runtime/crates/**`
- `.octon/instance/**`
- `.octon/state/control/**`, except through a separately authorized lifecycle
  run that records its own control evidence
- `.octon/generated/effective/**`
- `.octon/generated/proposals/registry.yml`, except through normal proposal
  registry generation if a later route explicitly requires it
- root `README.md`, root `AGENTS.md`, `CLAUDE.md`, or repo-local projection
  adapters
- support-target declarations, connector admissions, governance exclusions, or
  support matrices
- external workflow engines, Durable Object adapters, MCP integrations,
  connector operation admission behavior, or agent-node/model-call contracts
  beyond required harness slot references

Do not change `proposal.yml#status`; leave it as `accepted`. The
`promote-proposal` lifecycle route owns the later rewrite to `implemented`.

If implementation requires any out-of-scope file, new authority class, support
claim, runtime cutover, generated/effective publication, or target-family
widening, stop and report `needs-packet-revision` with evidence.

## Ordered Workstreams

### 0. Preflight And Evidence Directory

1. Record current worktree state and preserve unrelated existing edits.
2. Run the mandatory implementation-readiness and strict review gates.
3. Create a retained evidence directory under
   `.octon/state/evidence/validation/proposals/workflow-statechart-task-specific-execution-harness/<timestamp>/`.
4. Record the Profile Selection Receipt there and in
   `support/implementation-run.md`: `release_state=pre-1.0`,
   `change_profile=atomic`, `transitional_exception_note=not authorized`.
5. Capture baseline searches for existing statechart, harness, run lifecycle,
   generated projection, and validation surfaces.

### 1. Runtime Spec Contract

Create or update the smallest runtime spec files under
`.octon/framework/engine/runtime/spec/` needed to define:

- statechart states and transitions;
- invalid transition handling and fail-closed reason posture;
- mapping from statechart states to Run Lifecycle v1 states;
- control roots and evidence roots used by the statechart;
- harness compilation inputs, outputs, and receipt shape;
- required binding fields for objective, run contract, support target,
  capability envelope, context pack, authorization route, effect-token classes,
  evidence obligations, rollback/compensation posture, human intervention,
  model/cost policy, and closeout criteria;
- non-authority posture for generated diagrams and read models.

Keep Run Lifecycle v1 canonical. Do not redefine the run journal,
`runtime-state.yml`, `run-contract.yml`, execution authorization, context-pack,
or effect-token contracts except by explicit reference.

### 2. Constitutional Runtime Contracts

Under `.octon/framework/constitution/contracts/runtime/`, add or update the
minimal schema and family registration surfaces needed to make the spec
machine-checkable.

The schemas must be strict enough for validators to reject:

- missing objective binding;
- missing run-contract binding;
- missing support-target binding;
- missing capability-envelope binding;
- missing context-pack binding;
- missing authorization-route binding;
- missing effect-token class binding;
- missing evidence obligation binding;
- missing rollback or compensation posture;
- missing human-intervention posture;
- missing model/cost policy;
- missing closeout criteria;
- generated projection refs used as authority;
- proposal-path refs used as runtime or policy authority;
- statechart transitions that contradict Run Lifecycle v1.

Update `family.yml` and `README.md` only where needed to register the new
runtime contract files and preserve the existing family model.

### 3. Validators And Fixture Strategy

Add validator coverage under
`.octon/framework/assurance/runtime/_ops/scripts/`.

Use existing helper style from neighboring validators. Prefer one focused
validator or a small pair of validators over a broad framework. The validators
must create positive and negative test data in temporary directories or retain
fixture evidence under the evidence directory. Do not add durable fixture roots
outside the approved promotion targets unless the packet is revised.

Validator coverage must prove:

- statechart schema positive fixtures pass;
- invalid transitions fail;
- every required harness envelope binding is required;
- generated projections are labeled and treated as non-authoritative;
- control refs stay under `.octon/state/control/**`;
- retained evidence refs stay under `.octon/state/evidence/**`;
- generated refs stay under `.octon/generated/cognition/projections/materialized/**`
  and cannot be consumed as authority;
- proposal or raw input refs are rejected as runtime or policy authority;
- Run Lifecycle v1 parity holds for the declared state mapping.

### 4. Generated Projection Publication

If the implementation creates or updates generated cognition projections under
`.octon/generated/cognition/projections/materialized/`, ensure each projection:

- is derived-only and visibly non-authoritative;
- cites durable source specs or schemas, not proposal-local paths;
- preserves traceability to framework or state evidence roots;
- is indexed if local generated projection conventions require it.

If a generation script is needed, place it under the approved assurance script
target and run it. If no generated projection is necessary for the minimal
implementation, record that no-op rationale in retained evidence and in the
conformance review. Do not publish or edit `.octon/generated/effective/**` for
this packet.

### 5. Boundary And Compatibility Review

Run searches over all approved durable targets and record results in retained
evidence:

```sh
rg -n "workflow-statechart-task-specific-execution-harness|inputs/exploratory/proposals" .octon/framework/engine/runtime/spec .octon/framework/constitution/contracts/runtime .octon/framework/assurance/runtime/_ops/scripts .octon/generated/cognition/projections/materialized
rg -n -i "second control plane|agent-owned|agents? own workflow state|live .*Durable Object|live .*MCP|live .*external workflow|generated.*authority|proposal.*authority" .octon/framework/engine/runtime/spec .octon/framework/constitution/contracts/runtime .octon/framework/assurance/runtime/_ops/scripts .octon/generated/cognition/projections/materialized
```

The first scan must not find durable active dependencies on this proposal path.
The second scan may return negative controls only when surrounding text or test
logic clearly rejects the claim.

### 6. Required Validation

Run these proposal gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness --require-implementation-authorization
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

Run the new child-specific validator or validators added by this
implementation. If named differently, record the exact command in retained
evidence:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-workflow-statechart-harness.sh
```

Run checksum verification for the reviewed packet files:

```sh
(cd .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness && shasum -a 256 -c SHA256SUMS.txt)
```

If a validator fails because the packet's existing inventory omits newly
generated support receipts, record it separately. Do not edit reviewed packet
artifacts merely to satisfy inventory churn when doing so would stale the
accepted review digest. If reviewed packet artifacts must change, stop and
route to packet revision.

### 7. Retained Evidence And Implementation Run Receipt

Create a retained evidence note under the evidence directory with:

- implementation timestamp;
- files changed;
- exact validation commands and exit statuses;
- search output or summaries with paths;
- diff summary by promotion target family;
- fixture and negative-control evidence;
- generated projection source and non-authority proof, or no-op rationale;
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
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness
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
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness
```

## Rollback Posture

Rollback is removal or reversion of the statechart, harness, validator, and
generated projection changes made by this packet, plus retained evidence
showing why rollback occurred.

Before claiming success, verify that rollback would restore the prior Run
Lifecycle v1 authority posture without leaving:

- a second control plane;
- generated projections used as authority;
- proposal-path dependencies in durable targets;
- partial schemas without validators;
- validators without corresponding contract surfaces;
- generated projection entries that point at removed specs;
- live support claims for excluded future work.

If rollback cannot be cleanly bounded to this packet's durable targets, stop
and report `blocked-unsafe` or `needs-packet-revision`.

## Delegation

Delegation is optional. If used, split work by disjoint write scope and keep one
integration owner accountable for final validation and receipts.

Suggested disjoint scopes:

- runtime specs and constitutional runtime schemas;
- validators and fixture/negative-control strategy;
- generated projection and non-authority indexing;
- integration owner for evidence, receipts, final validation, and status
  discipline.

No subagent, worker, or delegated tool may widen promotion targets, approve
execution, mutate `proposal.yml#status`, or treat proposal-local support files
as implementation proof.

## Terminal Criteria

The implementation route may report success only when all of these are true:

- durable changes are limited to the declared promotion targets;
- required retained evidence exists outside `inputs/**`;
- `support/implementation-run.md` exists with `verdict: pass`,
  `implemented_at`, and `promotion_evidence_count`;
- `support/implementation-conformance-review.md` exists with `verdict: pass`
  and `unresolved_items_count: 0`;
- `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness`
  passes;
- `support/post-implementation-drift-churn-review.md` exists with
  `verdict: pass` and `unresolved_items_count: 0`;
- `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness`
  passes;
- no explicit exclusion has been implemented or implied as live support;
- generated outputs remain derived-only and non-authoritative;
- `proposal.yml#status` remains `accepted`.

Refuse implemented, closeout, or archive-ready claims while either
post-implementation receipt is missing, failing, unresolved, stale, blocked, or
unvalidated. The separate `promote-proposal` lifecycle route owns the
implemented-status rewrite, and later closeout/archive routes own closeout and
archival claims.

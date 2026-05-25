# Executable Implementation Prompt

implementation_prompt_id: agent-node-model-call-contract-implementation-prompt-2026-05-15
proposal_path: .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-15T21:06:14Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, or substitute for retained evidence.

Durable authority may land only in the declared promotion targets outside the
proposal path. Proposal-local support files, source conversations, generated
proposal registry entries, chat history, host state, tool availability, MCP
state, Durable Object state, external workflow-engine state, and generated
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
- live Run Lifecycle v1, Workflow Statechart v1, Task-Specific Execution
  Harness v1, Execution Authorization v1, Context Pack Builder v1, Authorized
  Effect Token v1, Evidence Store v1, Policy Interface v1, support-target,
  model-adapter, capability-pack, and execution-budget surfaces that this
  packet touches.

Then run these gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract --require-implementation-authorization
```

Refuse implementation unless both commands pass, `proposal.yml#status` is
`accepted`, the review verdict is `accepted`,
`implementation_prompt_authorized: yes`, `open_blocking_findings_count: 0`, and
the reviewed packet digest is fresh.

Use this profile selection:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: one coherent agent-node and model-call contract
  implementation across the approved target families, with no partial live
  state and with post-cutover validation before any success claim
- transitional exception: not authorized by this packet

## Target End State

The implemented end state is a durable agent-node and model-call contract that
admits model calls only as typed, finite, evidenced activity nodes inside a
task-specific execution harness and Workflow Statechart v1 overlay. Agents and
model outputs never own workflow state, policy truth, support claims, authority
grants, run closeout, or workflow transitions.

The durable implementation must establish all of these facts:

- an agent node is a bounded workflow activity node tied to an existing
  task-specific execution harness, Run Lifecycle v1 run root, and Workflow
  Statechart v1 state;
- a model-call receipt binds exact context-pack evidence, model-visible context
  digest, model-routing policy ref, model eligibility, model adapter/tier,
  context/token/cost/retry budgets, fallback policy, retained cost/usage
  evidence, output schema, validation result, terminal state, and replay
  envelope;
- agent-node terminal states, timeout behavior, retry eligibility, fallback
  behavior, revocation behavior, and fail-closed outcomes are machine-checkable;
- tool allowlists and connector references are by-reference only and bind to
  existing effect-token, capability-pack, support-target, and connector
  admission posture without creating a new connector or MCP permission model;
- validators prove positive and negative fixtures for agent nodes, model-call
  receipts, context digest binding, routing/budget/fallback/cost enforcement,
  retry limits, retained receipt requirements, and forbidden authority claims;
- existing run lifecycle, workflow statechart, task-specific harness, execution
  authorization, context-pack, effect-token, evidence-store, support-target,
  model-adapter, and fail-closed contracts remain canonical until later
  validated cutover evidence says otherwise.

This packet does not authorize agent-owned queues, schedules, workflow
transition authority, closeout authority, connector/MCP permission models
beyond references to later connector admission, universal replay guarantees for
probabilistic outputs, runtime crate behavior changes, generated/effective
runtime publication, or live Governed Workflow Runtime support claims.

## In Scope

Durable edits may touch only these promotion target families:

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/runtime/`
- `.octon/instance/governance/policies/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

Expected durable outputs may include the smallest coherent set of files in
those families, such as:

- runtime narrative specs and schemas for `agent-node-v1` and
  `model-call-receipt-v1`;
- constitutional runtime contract mirrors for the new schemas;
- runtime contract family registration updates in `family.yml` and `README.md`
  when new schemas are added;
- a repo-owned model-call routing, budget, fallback, and cost/usage receipt
  policy under `.octon/instance/governance/policies/`;
- one focused validator, or a small pair of validators, under
  `.octon/framework/assurance/runtime/_ops/scripts/` that creates positive and
  negative fixtures in temporary directories or under retained evidence;
- updates to existing validators only when needed to keep new contracts aligned
  with existing runtime family checks.

After durable edits land, packet-local receipt updates are required:

- `.octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract/support/post-implementation-drift-churn-review.md`

Retained validation and promotion evidence must live outside `inputs/**`,
preferably under:

- `.octon/state/evidence/validation/proposals/agent-node-model-call-contract/<timestamp>/`
- `.octon/state/evidence/runs/workflows/<run-id>/` when a lifecycle runner
  creates run evidence

## Out Of Scope

Do not edit these surfaces for this packet:

- `.octon/framework/engine/runtime/crates/**`
- `.octon/framework/capabilities/**`
- `.octon/framework/constitution/contracts/authority/**`
- `.octon/framework/constitution/contracts/adapters/**`
- `.octon/instance/governance/support-targets.yml`
- `.octon/instance/governance/connector-admissions/**`
- `.octon/instance/governance/capability-packs/**`
- `.octon/state/control/**`, except through a separately authorized lifecycle
  run that records its own control evidence
- `.octon/generated/**`, including `.octon/generated/effective/**`
- root `README.md`, root `AGENTS.md`, `CLAUDE.md`, or repo-local projection
  adapters
- external workflow engines, Durable Object adapters, MCP integrations,
  connector operation admission behavior, runtime service implementations, or
  runtime crate behavior

Do not change `proposal.yml#status`; leave it as `accepted`. The
`promote-proposal` lifecycle route owns the later rewrite to `implemented`.

If implementation requires any out-of-scope file, new authority class, support
claim, runtime cutover, generated/effective publication, connector admission,
runtime crate change, or target-family widening, stop and report
`needs-packet-revision` with evidence.

## Ordered Workstreams

### 0. Preflight And Evidence Directory

1. Record current worktree state and preserve unrelated existing edits.
2. Run the mandatory implementation-readiness and strict review gates.
3. Create a retained evidence directory under
   `.octon/state/evidence/validation/proposals/agent-node-model-call-contract/<timestamp>/`.
4. Record the Profile Selection Receipt there and in
   `support/implementation-run.md`: `release_state=pre-1.0`,
   `change_profile=atomic`, `transitional_exception_note=not authorized`.
5. Capture baseline searches for existing agent, model-call, model-routing,
   context-pack, execution-budget, fallback, retry, cost, receipt, authority,
   and validator surfaces.

### 1. Runtime Spec Contract

Create or update the smallest runtime spec files under
`.octon/framework/engine/runtime/spec/` needed to define:

- `agent-node-v1` identity, harness binding, workflow state binding, run root
  binding, node input/output binding, terminal states, timeout behavior,
  retry eligibility, fallback behavior, revocation behavior, and fail-closed
  behavior;
- `model-call-receipt-v1` identity, run id, agent-node ref, request id,
  model adapter/tier, model-routing policy ref, model eligibility decision,
  context-pack ref, context-pack receipt ref, model-visible context ref and
  digest, input/output schema refs, validation result, token budget, context
  budget, retry budget, cost budget, fallback policy, retained cost/usage
  receipt refs, terminal outcome, replay envelope, and timestamps;
- tool allowlist and connector refs as references to existing capability,
  effect-token, support-target, and connector-admission posture;
- explicit authority boundaries that keep agent nodes and model outputs from
  authorizing execution, minting grants, consuming effect tokens by themselves,
  owning workflow state, mutating policy, widening support, or closing runs;
- fail-closed behavior for missing context digest, stale context, missing
  routing policy, ineligible model, budget exceedance, retry exhaustion,
  fallback violation, missing cost/usage receipt, output schema failure,
  missing retained evidence, proposal-path authority, generated authority, and
  agent-owned workflow transition claims.

Keep Run Lifecycle v1, Workflow Statechart v1, Task-Specific Execution Harness
v1, Execution Authorization v1, Context Pack Builder v1, Authorized Effect
Token v1, Evidence Store v1, and Policy Interface v1 canonical. Reference them
instead of redefining them.

### 2. Constitutional Runtime Contracts

Under `.octon/framework/constitution/contracts/runtime/`, add or update the
minimal schema mirrors and family registration surfaces needed to make the
runtime specs machine-checkable.

The schemas must be strict enough for validators to reject:

- missing harness binding;
- missing workflow state binding;
- missing run root binding;
- missing context-pack ref or context-pack receipt ref;
- missing model-visible context digest;
- missing model-routing policy ref;
- missing model eligibility decision;
- missing model adapter/tier binding;
- missing context/token/cost/retry budgets;
- missing fallback policy;
- missing retained cost/usage receipt refs;
- missing output schema or output validation result;
- missing terminal state or replay envelope;
- generated refs used as authority;
- proposal-path refs used as runtime or policy authority;
- agent-owned workflow transition, schedule, queue, closeout, policy, support,
  grant, or effect-token claims.

Update `family.yml` and `README.md` only where needed to register new runtime
contract files and preserve the existing family model.

### 3. Instance Governance Policy

Under `.octon/instance/governance/policies/`, add or update the smallest
repo-owned policy surface needed to bind model-call routing, eligibility,
budget, fallback, retry, and retained cost/usage receipt requirements.

The policy must:

- remain subordinate to support-target declarations, model-adapter manifests,
  execution-budget policy, network egress policy, capability-pack governance,
  execution authorization, and fail-closed obligations;
- require explicit model adapter/tier and support tuple binding before a model
  call can be treated as an admissible agent-node activity;
- define budget classes or references for context, tokens, estimated cost,
  retries, and fallback attempts;
- route missing or stale cost evidence, exceeded budgets, ineligible model
  choices, missing context-pack evidence, invalid output schema, and missing
  retained receipts to `stage_only` or `deny` according to existing fail-closed
  posture;
- state that this policy does not admit new connectors, MCP permissions,
  external workflow engines, Durable Object adapters, universal replay
  guarantees, or runtime support claims.

Do not update support-target declarations or connector admissions in this
packet.

### 4. Validators And Fixture Strategy

Add validator coverage under
`.octon/framework/assurance/runtime/_ops/scripts/`.

Use existing helper style from neighboring validators. Prefer one focused
validator or a small pair of validators over a broad framework. The validators
must create positive and negative test data in temporary directories or retain
fixture evidence under the evidence directory. Do not add durable fixture roots
outside the approved promotion targets unless the packet is revised.

Validator coverage must prove:

- agent-node schema positive fixtures pass;
- model-call receipt schema positive fixtures pass;
- missing harness, workflow state, run root, context-pack receipt, context
  digest, model-routing policy, model eligibility, budget, fallback, cost/usage
  receipt, output schema, validation result, terminal state, or replay envelope
  fails;
- context-pack digest binding rejects stale, missing, mismatched, or
  unverifiable model-visible context;
- routing, fallback, retry-budget, token-budget, context-budget, cost-budget,
  and retained cost/usage receipt rules are enforced;
- generated projections cannot satisfy authority fields;
- proposal paths and raw inputs cannot satisfy runtime or policy authority;
- agent outputs and prompts cannot claim workflow transition, queue, schedule,
  closeout, grant, effect-token, policy, support, connector-admission, or
  runtime-cutover authority.

### 5. Boundary And Compatibility Review

Run searches over all approved durable targets and record results in retained
evidence:

```sh
rg -n "agent-node-model-call-contract|inputs/exploratory/proposals" .octon/framework/engine/runtime/spec .octon/framework/constitution/contracts/runtime .octon/instance/governance/policies .octon/framework/assurance/runtime/_ops/scripts
rg -n -i "agent-owned|agents? own workflow state|agents? own policy|agents? own closeout|agents? own support|agents? own grant|agents? own transition|live .*Durable Object|live .*MCP|live .*external workflow|generated.*authority|proposal.*authority|universal replay" .octon/framework/engine/runtime/spec .octon/framework/constitution/contracts/runtime .octon/instance/governance/policies .octon/framework/assurance/runtime/_ops/scripts
```

The first scan must not find durable active dependencies on this proposal path.
The second scan may return negative controls only when surrounding text or test
logic clearly rejects the claim.

### 6. Required Validation

Run these proposal gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract --require-implementation-authorization
```

Run these target-family validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-v1.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-transition-coverage.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-workflow-statechart-harness.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-authorized-effect-token-enforcement.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-contract-family-version-coherence.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-docs-consistency.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-no-raw-generated-effective-runtime-reads.sh
```

Run Context Pack Builder v1 validation against the positive context-pack and
context-pack receipt fixture created for this implementation. Use the retained
fixture directory, not proposal-local support material:

```sh
CONTEXT_FIXTURE_DIR=".octon/state/evidence/validation/proposals/agent-node-model-call-contract/<timestamp>/fixtures/context-pack-positive"
bash .octon/framework/assurance/runtime/_ops/scripts/validate-context-pack-builder.sh --pack "$CONTEXT_FIXTURE_DIR/context-pack.json" --receipt "$CONTEXT_FIXTURE_DIR/context-pack-receipt.json" --root .
```

Run the new child-specific validator or validators added by this
implementation. If named differently, record the exact command in retained
evidence:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-agent-node-model-call-contract.sh
```

Run checksum verification for the reviewed packet files:

```sh
(cd .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract && shasum -a 256 -c SHA256SUMS.txt)
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
- model-routing, budget, fallback, retry, cost/usage, and output-validation
  proof;
- no-generated-publication rationale, unless a later authorized route owns a
  generated publication;
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
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract
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
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract
```

## Generated And Runtime Publication Posture

This packet authorizes durable runtime specs, constitutional runtime contracts,
instance governance policy, and assurance validators only in the approved
promotion targets. It does not authorize generated/effective publication,
support-matrix publication, connector admission publication, runtime route
bundle publication, or generated cognition projection publication.

If implementation discovers that a generated or runtime-effective publication
is required before the contract can be safely used, stop and report
`needs-packet-revision` or hand off to the lifecycle route that owns that
publication. Do not create generated/effective outputs as proof for this packet.

## Rollback Posture

Rollback is removal or reversion of the agent-node, model-call, policy, and
validator changes made by this packet, plus retained evidence showing why
rollback occurred.

Before claiming success, verify that rollback would restore the prior runtime
authority posture without leaving:

- partial schemas without validators;
- validators without corresponding contract surfaces;
- policy entries without schema or validator enforcement;
- proposal-path dependencies in durable targets;
- generated or raw-input authority dependencies;
- model-call receipts that omit cost/usage or context digest evidence;
- retry or fallback paths without budget controls;
- live support claims for excluded future work;
- any agent-owned queue, schedule, transition, policy, grant, effect-token,
  support, or closeout claim.

If rollback cannot be cleanly bounded to this packet's durable targets, stop
and report `blocked-unsafe` or `needs-packet-revision`.

## Delegation

Delegation is optional. If used, split work by disjoint write scope and keep one
integration owner accountable for final validation and receipts.

Suggested disjoint scopes:

- runtime specs and constitutional runtime schemas;
- instance model-call routing/budget/fallback policy;
- validators and fixture/negative-control strategy;
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
- `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract`
  passes;
- `support/post-implementation-drift-churn-review.md` exists with
  `verdict: pass` and `unresolved_items_count: 0`;
- `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract`
  passes;
- no explicit exclusion has been implemented or implied as live support;
- generated outputs remain derived-only and non-authoritative;
- `proposal.yml#status` remains `accepted`.

Refuse implemented, closeout, or archive-ready claims while either
post-implementation receipt is missing, failing, unresolved, stale, blocked, or
unvalidated. The separate `promote-proposal` lifecycle route owns the
implemented-status rewrite, and later closeout/archive routes own closeout and
archival claims.

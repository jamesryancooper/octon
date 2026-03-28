# Target Architecture

## Decision

Ratify one target state where Octon becomes a fully unified execution
constitution rather than a distributed repository constitution with only a
partially normalized runtime. In the promoted state:

- the five-class super-root remains intact:
  `framework / instance / inputs / state / generated`;
- authored authority remains confined to `framework/**` and `instance/**`;
- raw `inputs/**` remain non-authoritative and never become direct runtime or
  policy dependencies;
- `generated/**` remains derived-only even when runtime consumes fresh,
  receipt-backed effective outputs;
- `framework/constitution/**` becomes the unified constitutional kernel that
  consolidates fail-closed obligations, precedence rules, evidence duties,
  ownership classes, and contract families;
- workspace intent, mission intent, and per-run intent become an explicit
  hierarchy where run contracts are the atomic execution unit and mission
  remains the continuity, ownership, and long-horizon autonomy container;
- every consequential side effect routes through one authority engine that
  evaluates objective binding, ownership, approvals, support tier, risk class,
  reversibility, budget posture, egress posture, and exception state before
  issuing a grant;
- runtime shifts from mission-centric conversational execution to managed
  run-lifecycle execution with stage attempts, checkpoints, resumability,
  rollback posture, replay bundles, and contamination handling;
- every consequential run emits normalized evidence including a run contract,
  decision artifact, grant bundle, receipts, checkpoints, assurance reports,
  intervention records, measurement records, replay pointers, and a RunCard;
- system-level capability and benchmark claims require disclosure through a
  HarnessCard plus bounded support-target declarations;
- verification, authority, and execution remain separate responsibilities;
- a top-level lab domain becomes first-class so behavioral proof, shadow runs,
  replay, adversarial testing, and failure discovery stop living only as ad
  hoc assurance logic;
- persona-heavy agency surfaces leave the kernel path unless they provide real
  separation of duties, context isolation, or concurrency value;
- every compensating mechanism carries retirement metadata so Octon can delete
  obsolete scaffolding as models and adapters improve.

## Status

- status: proposed
- proposal area: constitutional authority, intent binding, policy routing,
  runtime lifecycle, assurance, lab, observability, disclosure, and execution
  governance
- implementation style: staged constitutional cutover with transitional
  coexistence between current mission-first execution and target-state
  run-first execution
- dependencies:
  - `framework-core-architecture`
  - `capability-routing-host-integration`
  - `harness-integrity-tightening`
  - `proposal-system-integrity-and-archive-normalization`
  - `migration-rollout`
  - current repo authority under `/.octon/octon.yml`,
    `/.octon/instance/bootstrap/START.md`,
    `/.octon/instance/bootstrap/OBJECTIVE.md`, and
    `/.octon/instance/cognition/context/shared/intent.contract.yml`
- driving source material:
  - `resources/proposal.md`
  - `resources/design-packet.md`
  - `resources/constitutional-harness-architecture.md`
  - `resources/harness-assessment.md`

## Why This Proposal Exists

Octon already has stronger constitutional structure than most harnesses:

- a single `.octon/` super-root with explicit class-root boundaries;
- clear authored authority separation between `framework/**` and
  `instance/**`;
- deny-by-default and fail-closed execution posture;
- retained continuity, control, and evidence roots;
- mission-autonomy policy, ownership surfaces, and typed execution
  authorization seams;
- structural and governance CI that already treats some architectural claims as
  blocking.

The unresolved problem is normalization. The current architecture distributes
core control logic across `octon.yml`, bootstrap docs, ingress, agency
contracts, mission policy, runtime specs, and workflow-shaped approvals.
Mission is still treated as the primary execution atom, per-run objective
binding is incomplete, approval and exception artifacts are not yet fully
generic, replay and disclosure are not normalized, and behavioral proof is not
yet first-class.

This proposal closes that gap by moving Octon to one coherent control model:
objective -> authority -> runtime -> verification -> disclosure.

## Current Live Signals This Proposal Resolves

| Current live signal | Current live source | Target-state implication |
| --- | --- | --- |
| The class-root super-root and non-authoritative `inputs/**` rule are already strong | `/.octon/README.md`, `/.octon/instance/bootstrap/START.md`, `/.octon/framework/cognition/_meta/architecture/specification.md` | Preserve the macro-topology instead of redesigning it. |
| Canonical ingress, objective brief, and shared intent contract already exist | `/.octon/instance/ingress/AGENTS.md`, `/.octon/instance/bootstrap/OBJECTIVE.md`, `/.octon/instance/cognition/context/shared/intent.contract.yml` | Promote them into an explicit workspace-charter layer rather than replacing them with prompt-only control. |
| Material execution already has an engine-owned authorization seam | engine runtime specs and authorization contracts referenced by the resource docs | Preserve the authorization boundary and extend it into a first-class authority engine. |
| Mission-scoped autonomy is already real and continuity-rich | `/.octon/instance/orchestration/missions/**`, `/.octon/state/control/execution/missions/**`, `/.octon/state/continuity/repo/missions/**` | Keep mission for continuity and governance, but stop treating it as the only legal execution atom. |
| Structural and governance CI are stronger than behavioral proof and disclosure | current assurance and workflow surfaces described in `resources/harness-assessment.md` | Add missing functional, behavioral, recovery, replay, and disclosure layers rather than weakening existing structural gates. |
| The repository still marks intent-layer enforcement as incomplete | continuity backlog cited by `resources/harness-assessment.md` and `resources/proposal.md` | Finish the intent cutover and add a normalized run contract. |
| Host and provider semantics still leak into approval and review flows | GitHub-label and provider-shaped examples described in the resource docs | Demote host glue to adapter projections and centralize approval, exception, and disclosure artifacts in the core model. |

## Preserved Invariants

This proposal is intentionally conservative about Octon's strongest existing
architectural decisions. It preserves:

- one repo-root `.octon/` harness per repository;
- the existing authority boundary between authored authority, mutable state,
  and derived outputs;
- raw-input isolation;
- fail-closed handling for missing or stale required control surfaces;
- repo-owned governance rather than model-defined governance;
- mission-backed long-horizon autonomy;
- retained evidence and continuity as first-class operating surfaces;
- portability as a kernel value rather than a host-specific implementation
  detail.

## Target Contract

### 1. Constitutional Kernel

Octon gets one explicit constitutional kernel under
`/.octon/framework/constitution/**`.

Minimum artifact families:

- `framework/constitution/CHARTER.md`
- `framework/constitution/charter.yml`
- `framework/constitution/precedence/normative.yml`
- `framework/constitution/precedence/epistemic.yml`
- `framework/constitution/obligations/fail-closed.yml`
- `framework/constitution/obligations/evidence.yml`
- `framework/constitution/ownership/roles.yml`
- `framework/constitution/contracts/registry.yml`
- `framework/constitution/contracts/objective/**`
- `framework/constitution/contracts/authority/**`
- `framework/constitution/contracts/runtime/**`
- `framework/constitution/contracts/assurance/**`
- `framework/constitution/contracts/disclosure/**`
- `framework/constitution/contracts/retention/**`
- `framework/constitution/support-targets.schema.json`

Kernel rules:

1. No consequential execution without a bound run contract.
2. No material side effect before authority routing and grant issuance.
3. No host surface, UI state, or chat transcript may become authority.
4. Raw `inputs/**` never become direct runtime or policy dependencies.
5. `generated/**` remains derived-only and may not become a second control
   plane.
6. Every consequential run emits retained evidence and disclosure artifacts.
7. Hidden human intervention is prohibited.
8. Unsupported support tiers fail closed.
9. Long-horizon or recurring autonomy requires mission authority.
10. Every compensating mechanism must carry a removal review and retirement
    trigger.

The constitutional kernel is supreme within repo-local authority beneath any
non-waivable external obligations. Prompts, ingress adapters, workflows, and
generated projections may project the kernel, but may not redefine it.

### 2. Objective And Execution Model

Octon gets an explicit four-layer objective stack:

1. Workspace charter pair.
   - Human narrative: continue using `instance/bootstrap/OBJECTIVE.md`.
   - Machine contract: continue using
     `instance/cognition/context/shared/intent.contract.yml`.
   - These existing surfaces become the stable workspace-charter pair until
     future consolidation chooses a new path.
2. Mission charter pair.
   - Existing durable authority remains under
     `instance/orchestration/missions/<mission-id>/{mission.md,mission.yml}`.
   - Mission stays responsible for ownership, overlap policy, autonomy
     posture, continuity, and long-horizon intent.
3. Run contract.
   - New runtime-bound authority lives under
     `state/control/execution/runs/<run_id>/run-contract.yml`.
   - It binds one concrete execution to scope, exclusions, requested
     capabilities, materiality, reversibility, support tier, required
     approvals, required evidence, and closure conditions.
4. Stage attempt contracts.
   - Runtime writes stage/attempt manifests under the same run root for
     retries, staged execution, rollback posture, and resumability.

Execution rules:

- every consequential run must bind to exactly one workspace charter pair and
  exactly one run contract;
- mission remains mandatory for mission-class work, recurring autonomy,
  overlapping work, and long-horizon continuity;
- explicitly bounded run-only autonomy becomes legal only for declared support
  tiers and may not silently fall back into mission-less execution;
- no material execution may widen objective scope beyond the bound run
  contract;
- assurance and disclosure consume the run contract as the execution-time
  authority rather than reconstructing intent from conversation history.

### 3. Authority And Approval Model

Octon gets one authority engine between objective binding and material
capability use.

Canonical durable inputs:

- `framework/constitution/contracts/authority/**`
- `instance/governance/policies/**`
- `instance/governance/contracts/**`
- `instance/governance/ownership/registry.yml`
- mission authority under `instance/orchestration/missions/**`
- support-target declarations under the constitutional kernel

Canonical live artifacts:

- `state/control/execution/approvals/**`
- `state/control/execution/exceptions/**`
- `state/control/execution/revocations/**`
- `state/evidence/control/execution/**`

Required outputs:

- `ApprovalRequest`
- `ApprovalGrant`
- `ExceptionLease`
- `Revocation`
- `DecisionArtifact`
- `GrantBundle`

Authority rules:

1. Humans own policy content, approvals, exception grants, revocations, and
   irreversible sign-off.
2. The harness owns evaluation, enforcement, and retained evidence.
3. The model may request or propose, but may not mint authority.
4. Route decisions must resolve to `ALLOW`, `STAGE_ONLY`, `ESCALATE`, or
   `DENY`.
5. Missing ownership, policy ambiguity, invalid intent binding, unsupported
   support tier, or missing required evidence fail closed or downgrade to
   `STAGE_ONLY` only where policy explicitly allows.
6. Host-specific affordances such as labels, comments, checks, or chat
   approvals become adapter projections of ApprovalRequests and ApprovalGrants,
   never the authority source themselves.

### 4. Runtime Lifecycle And Evidence Model

Runtime moves from mission-centric execution orchestration to a run-lifecycle
model that can still attach to mission continuity when appropriate.

Canonical state families:

```text
.octon/
├── state/
│   ├── control/
│   │   └── execution/
│   │       ├── runs/<run_id>/
│   │       │   ├── run-contract.yml
│   │       │   ├── stage-attempts/
│   │       │   ├── checkpoints/
│   │       │   ├── runtime-state.yml
│   │       │   └── rollback-posture.yml
│   │       ├── approvals/
│   │       ├── exceptions/
│   │       └── revocations/
│   └── evidence/
│       ├── runs/<run_id>/
│       │   ├── decision-artifact.yml
│       │   ├── grant-bundle.yml
│       │   ├── receipts/
│       │   ├── checkpoints/
│       │   ├── assurance/
│       │   ├── interventions/
│       │   ├── measurements/
│       │   ├── replay/
│       │   ├── disclosure/run-card.md
│       │   └── trace-pointers.yml
│       ├── control/execution/
│       └── lab/
└── generated/
    ├── effective/
    │   ├── constitution/
    │   ├── orchestration/
    │   └── capabilities/
    └── cognition/
        ├── summaries/
        └── projections/
```

Runtime rules:

- runtime binds one run root before any consequential stage begins;
- checkpoint, resume, retry, rollback, and contamination handling use durable
  artifacts under the run root rather than chat continuity;
- material stages emit receipts and evidence incrementally rather than only at
  final closeout;
- replay-heavy telemetry may externalize to immutable stores, but retained
  pointers and replay manifests remain in `state/evidence/**`;
- mission continuity and mission summaries may consume run evidence, but may
  not replace the run root as the execution-time unit of truth.

### 5. Verification, Lab, And Disclosure Model

Octon gets separate first-class proof planes instead of treating structural
conformance as sufficient proof for consequential work.

Required verification planes:

- structural
- functional
- behavioral
- governance
- maintainability
- recovery
- independent evaluator review where deterministic proof is insufficient

Required durable surfaces:

- `framework/assurance/structural/**`
- `framework/assurance/functional/**`
- `framework/assurance/governance/**`
- `framework/assurance/recovery/**`
- `framework/assurance/evaluators/**`
- `framework/lab/**`
- `framework/observability/**`
- `state/evidence/lab/**`

Verification rules:

1. Execution, authority, and consequential acceptance must not collapse into
   one undifferentiated loop.
2. Consequential completion claims require deterministic proof or an
   independent evaluator path.
3. Behavioral claims require lab-grade evidence, scenario proof, replay, or
   shadow-run evidence rather than prose.
4. Every consequential run must produce a RunCard.
5. System-level release, benchmark, or support claims must produce a
   HarnessCard.
6. Disclosure must include enough context to understand support tier, proof
   class, intervention, and known limits without exposing a second control
   plane.

### 6. Agency And Adapter Model

The agency kernel gets simpler and more explicit:

- one accountable orchestrator remains the default execution role;
- verifier or evaluator roles exist only when they provide real separation of
  duties;
- delegation survives only for boundary value such as context isolation,
  concurrency, or independence;
- memory discipline becomes runtime-enforced rather than only prose-defined;
- host adapters and model adapters remain replaceable and non-authoritative;
- support claims become adapter-conformance claims rather than universal
  aspiration.

Adapter rules:

1. Model-family differences belong behind explicit adapter contracts.
2. Host behavior belongs behind host adapters.
3. Neither adapter family may redefine constitutional authority.
4. Support-target declarations must identify where Octon is intentionally
   limited by workload tier, model tier, language/resource tier, or locale
   tier.

### 7. Repository And Boundary Restructuring

The top-level class-root shape stays exactly as it is. The restructuring
happens inside those classes.

Target-state major shape:

```text
.octon/
├── octon.yml
├── framework/
│   ├── constitution/
│   ├── agency/
│   ├── assurance/
│   ├── capabilities/
│   ├── cognition/
│   ├── engine/
│   ├── lab/
│   ├── observability/
│   ├── orchestration/
│   └── scaffolding/
├── instance/
│   ├── ingress/
│   ├── bootstrap/
│   ├── governance/
│   ├── cognition/
│   ├── orchestration/
│   └── locality/
├── inputs/
│   ├── additive/
│   └── exploratory/
├── state/
│   ├── continuity/
│   ├── control/
│   └── evidence/
└── generated/
    ├── effective/
    ├── cognition/
    └── proposals/
```

Boundary rules:

- `framework/**` remains portable authored core;
- `instance/**` remains repo-specific durable authority;
- `state/**` remains mutable operational truth and retained evidence;
- `generated/**` remains derived-only and freshness-bounded;
- `inputs/**` remains additive or exploratory raw material only;
- proposals remain temporary non-authoritative packets and never become runtime
  or policy dependencies.

## Non-Goals

This proposal does not:

- reopen the five-class super-root;
- create a second authored authority plane outside `framework/**` and
  `instance/**`;
- allow raw proposal or input paths to become runtime authority;
- make generated projections authoritative;
- preserve mission as the only execution atom;
- treat labels, comments, transcripts, or UI state as approval authority;
- rely on a single model loop to generate, authorize, verify, and disclose
  consequential work;
- claim universal model, host, or workload support without explicit evidence;
- keep obsolete guardrails indefinitely for compatibility convenience alone.

## Migration And Rollout Shape

This architecture must land as a staged transitional program rather than as a
single atomic swap.

High-level rollout shape:

1. Unify constitutional authority and precedence first.
2. Finish objective binding and add the run contract without breaking current
   mission continuity.
3. Centralize approvals, exception leases, and decision artifacts in one
   authority engine.
4. Normalize runtime around run roots, checkpoints, replay, and disclosure.
5. Add missing proof planes, lab infrastructure, and support-target
   declarations.
6. Retire host-shaped authority, mission-only execution assumptions, and
   obsolete compensating scaffolds once their replacements are proven.

During rollout:

- no new consequential execution path may bypass the authorization boundary;
- no new support claim may land without an explicit support-target declaration;
- no new consequential run path may skip disclosure artifacts once run bundles
  are introduced;
- coexistence between mission-first and run-first surfaces must be explicit,
  temporary, and governed by retirement gates.

## Completion Rule

This proposal is complete only when one durable, machine-checked final state
exists where:

1. the constitutional kernel is the explicit repo-local supreme control
   regime;
2. every consequential execution binds a run contract;
3. mission is preserved for continuity and long-horizon autonomy but no longer
   serves as the atomic execution primitive;
4. authority routing emits normalized decision, grant, exception, and
   revocation artifacts;
5. runtime manages checkpointed, replayable run lifecycles from durable state
   rather than chat history;
6. every consequential run emits normalized evidence and a RunCard;
7. system-level support and benchmark claims emit a HarnessCard;
8. functional, behavioral, governance, recovery, and disclosure proof exist as
   first-class peers to structural conformance;
9. host adapters and model adapters stop carrying hidden authority;
10. obsolete compensating scaffolds have explicit retirement paths or are
    already deleted.

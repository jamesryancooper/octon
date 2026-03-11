# Plan: Orchestration Domain End-to-End Build

- Package Path: `.design-packages/orchestration-domain-design-package`
- Planning Mode: `implementation-guidance`
- Audience: engineering teams building and promoting the orchestration domain
- Goal: implement the orchestration domain end-to-end from the design package without inventing architecture, then promote the resulting surfaces into live `.harmony` authority in a controlled way

## Profile Selection Receipt

- `change_profile`: `transitional`
- `release_state`: `pre-1.0`
- `release_state_evidence`: executable service artifacts in the repository still carry `0.1.0` versions, including `.harmony/capabilities/runtime/services/interfaces/filesystem-snapshot/SERVICE.md:6`, `.harmony/capabilities/runtime/services/interfaces/agent-platform/SERVICE.md:8`, and `.harmony/capabilities/runtime/services/retrieval/query/SERVICE.md:7`
- `selection_mode`: `auto`
- `recommended_transitional_mode`: `Phased Implementation` plus `Phased Rollout`
- `profile_facts`:
  - `downtime_tolerance`: no hard zero-downtime requirement is visible, but a big-bang cutover is unnecessary because live `.harmony/orchestration` surfaces already exist and can be strengthened incrementally.
  - `external_consumer_coordination_ability`: a single repo-wide PR is technically possible, but the package already separates build readiness from live canonicalization and expects staged promotion by surface.
  - `data_migration_backfill_needs`: no large historical backfill is required for the package itself, but temporary coexistence between package-local authority and live `.harmony/orchestration` surfaces is required until each surface is promoted.
  - `rollback_mechanism`: revert the promoted surface or validator change set, keep the package as the design authority, and rerun the package validators plus affected surface validators.
  - `blast_radius_and_uncertainty`: high cross-domain impact across orchestration runtime, continuity evidence, governance, assurance, and existing workflow/mission surfaces; staged validation materially reduces risk.
  - `compliance_policy_constraints`: continuity ownership of `decisions` and durable `runs` must remain intact; workflow and mission live surfaces must not silently outrank package contracts during promotion; incident authority must remain human-governed.
- `hard_gate_evaluation`:
  - `zero_downtime_requirement_prevents_one_step_cutover`: `false`
  - `external_consumers_cannot_migrate_in_one_coordinated_release`: `false`
  - `live_migration_backfill_requires_temporary_coexistence`: `false`
  - `operational_risk_requires_progressive_exposure_and_staged_validation`: `true`
- `rationale`: the package itself defines phased adoption, phased promotion, and explicit prototype-versus-canonical gates. Building this domain as one atomic implementation would ignore the package's own risk controls and would increase the chance of inventing behavior while live surfaces are only partially aligned.
- `target_outcome`: deliver a control plane and promoted runtime surfaces that match the package's contracts, algorithms, lifecycle rules, evidence model, and validation gates.
- `transitional_exception_note`:
  - `rationale`: pre-1.0 normally biases to `atomic`, but the orchestration domain spans existing live workflow and mission surfaces plus new runtime, governance, continuity, and assurance surfaces. Progressive exposure is the smaller robust path.
  - `risks`: temporary dual-authority drift between the package and live `.harmony` surfaces; incomplete promotion leaving engineers unsure which surface is canonical; validators lagging behind contract promotion.
  - `owner`: Harmony orchestration domain owner and repository maintainer
  - `target_removal_decommission_date`: `2026-06-30`

## Implementation Plan

### Operating Rules

1. Treat `.design-packages/orchestration-domain-design-package/navigation/source-of-truth-map.md` as the package-local authority map for all implementation work.
2. Resolve package conflicts in this order: specific contracts, detailed control docs, core normative docs, readiness and canonicalization docs, surface references, history.
3. Never promote a README, registry projection, state file, dashboard, or prose note above a schema-backed contract or control document.
4. Do not invent runtime semantics where the package already defines them. When behavior appears ambiguous, stop and escalate with the conflicting paths.
5. Keep storage engine, transport, worker topology, and dashboard choices subordinate to the package contracts. Those choices are implementation details unless they break required semantics.
6. Do not build `campaigns` in the core path unless mission coordination pressure clearly justifies them.

### Engineer Reading Path

Every engineer joining the implementation should read these documents in order before starting work:

1. `.design-packages/orchestration-domain-design-package/README.md`
2. `.design-packages/orchestration-domain-design-package/navigation/source-of-truth-map.md`
3. `.design-packages/orchestration-domain-design-package/implementation/README.md`
4. `.design-packages/orchestration-domain-design-package/implementation/01-system-purpose-and-production-architecture.md`
5. `.design-packages/orchestration-domain-design-package/implementation/02-service-boundaries-and-data-model.md`
6. `.design-packages/orchestration-domain-design-package/implementation/03-state-machines-and-algorithms.md`
7. `.design-packages/orchestration-domain-design-package/implementation/04-runtime-enforcement-and-failure-handling.md`
8. `.design-packages/orchestration-domain-design-package/implementation/05-first-slice-and-implementation-order.md`
9. `.design-packages/orchestration-domain-design-package/normative/assurance/implementation-readiness.md`
10. `.design-packages/orchestration-domain-design-package/normative/assurance/assurance-and-acceptance-matrix.md`

### Workstream Structure

Split the build into four coordinated workstreams after the authority and contract baseline is locked:

| Workstream | Scope | Primary package authorities | Depends on |
| --- | --- | --- | --- |
| `WS1 Contract and Validation` | schemas, fixtures, validators, authority-order checks, drift checks | `contracts/`, `conformance/`, `normative/assurance/*` | none |
| `WS2 Core Runtime and Persistence` | discovery loader, decision writer, run writer, coordination manager, queue manager, persistent state guarantees | `normative/architecture/runtime-architecture.md`, `contracts/run-linkage-contract.md`, `contracts/coordination-lock-contract.md`, `contracts/queue-item-and-lease-contract.md` | `WS1` |
| `WS3 Admission, Routing, Launch, and Recovery` | event router, automation controller, workflow launcher, executor supervisor, reconciler, approval verification, incident manager | `normative/execution/*`, `normative/governance/*`, `normative/assurance/failure-model.md` | `WS1`, `WS2` |
| `WS4 Surface Promotion and Canonicalization` | live `.harmony/orchestration` runtime surfaces, practices, governance addenda, scaffold updates, surface validators | `navigation/canonicalization-target-map.md`, `history/adoption-roadmap.md`, `normative/assurance/assurance-and-acceptance-matrix.md` | `WS1`; phase-dependent outputs from `WS2` and `WS3` |

### Phase Plan

#### Phase 0: Authority Lock And Backlog Translation

Purpose:
- convert the design package into an implementation backlog without changing semantics

Engineers must use:
- `README.md`
- `navigation/source-of-truth-map.md`
- `normative/assurance/implementation-readiness.md`
- `normative/assurance/assurance-and-acceptance-matrix.md`

Actions:
1. Turn every required contract, control doc, and readiness checklist item into a tracked backlog item.
2. Record the package authority order in the team working agreement.
3. Map each live target surface named in `navigation/canonicalization-target-map.md` to a future implementation or promotion task.
4. Freeze any competing local interpretations of workflow, automation, watcher, queue, run, or incident behavior.

Exit criteria:
- The package validator passes before implementation starts.
- Each backlog item cites at least one package authority document.
- Engineers agree which surfaces are implementation targets now and which remain optional.

#### Phase 1: Lock Contracts, Schemas, Fixtures, And Validation Gates

Purpose:
- make the package executable as an engineering contract before building runtime behavior

Engineers must use:
- `contracts/README.md`
- all required contracts in `normative/assurance/implementation-readiness.md`
- `conformance/README.md`
- `normative/assurance/assurance-and-acceptance-matrix.md`

Actions:
1. Wire `bash .harmony/assurance/runtime/_ops/scripts/validate-orchestration-design-package.sh` into local and CI execution.
2. Keep every schema-backed contract paired with at least one valid and one invalid fixture.
3. Add repo-local validator hooks for future promoted surfaces named in `navigation/canonicalization-target-map.md`.
4. Add drift checks so registry projections and subordinate prose cannot outrank contract artifacts.

Exit criteria:
- Static package validation passes.
- Routing, scheduling, and recovery conformance scenarios pass.
- No implementation PR can merge without the package validation gates.

#### Phase 2: Strengthen Existing Live Foundations Before New Surfaces

Purpose:
- align already-live `workflows` and `missions` with the package so later runtime work has stable definition surfaces

Engineers must use:
- `contracts/workflow-execution-contract.md`
- `contracts/mission-object-contract.md`
- `contracts/mission-workflow-binding-contract.md`
- `navigation/canonicalization-target-map.md`

Actions:
1. Make `workflow.yml` the authoritative execution artifact for workflows.
2. Add the orchestration-required workflow fields: `side_effect_class`, `execution_controls`, `coordination_key_strategy`, and `executor_interface_version`.
3. Make `mission.yml` the authoritative machine-readable mission artifact.
4. Update workflow and mission practices and validators so registry and README projections remain subordinate.
5. Keep durable run evidence in `continuity/runs/`; do not embed durable execution evidence in workflow or mission artifacts.

Exit criteria:
- Existing workflows validate against the strengthened workflow execution contract.
- Existing missions validate against the mission object contract.
- Workflows no longer carry recurrence or scheduler semantics.
- Mission-to-workflow invocation and run linkage are explicit.

#### Phase 3: Build Shared Runtime Primitives

Purpose:
- implement the non-negotiable state and evidence foundation used by every higher-level surface

Engineers must use:
- `normative/architecture/runtime-architecture.md`
- `contracts/decision-record-contract.md`
- `contracts/run-linkage-contract.md`
- `contracts/coordination-lock-contract.md`
- `contracts/queue-item-and-lease-contract.md`
- `implementation/04-runtime-enforcement-and-failure-handling.md`

Actions:
1. Implement the discovery loader as the sole resolved-reference view for runtime consumers.
2. Implement canonical decision writing into `continuity/decisions/`.
3. Implement canonical orchestration-facing run records plus subordinate projections in `runtime/runs/`.
4. Implement coordination lock acquisition, renewal, release, and lineage retention with CAS semantics.
5. Implement queue claim, acknowledgement, retry, dead-letter, and receipt handling with claim-token enforcement.
6. Make atomicity and ordering guarantees explicit: no side effects before decision, lock, run, and executor acknowledgement.

Exit criteria:
- Decision records, run records, lock artifacts, and queue items all validate against their contracts.
- Queue claims and locks provide atomic compare-and-swap semantics.
- Run records and continuity evidence remain separate but linked.
- No component can bypass the material action commit protocol.

#### Phase 4: Deliver The First End-To-End Slice

Purpose:
- prove the architecture with the smallest narrow path the package recommends

Engineers must use:
- `implementation/01-system-purpose-and-production-architecture.md`
- `implementation/05-first-slice-and-implementation-order.md`
- `normative/execution/run-liveness-and-recovery-spec.md`

Actions:
1. Implement one watcher definition, one event-triggered automation, one workflow, and one executor path.
2. Route one emitted event to one automation.
3. Create one queue item, claim it, validate bindings, acquire the coordination lock, write the decision, create the run, and obtain executor acknowledgement.
4. Simulate missing acknowledgement or heartbeat expiry and prove deterministic reconciliation.

Exit criteria:
- The first slice completes the exact path defined in `implementation/05-first-slice-and-implementation-order.md`.
- Recovery behavior matches the package's v1 rule: same-executor resume or abandon-and-escalate.
- Engineers can trace `event_id -> queue_item_id -> decision_id -> run_id -> continuity evidence`.

#### Phase 5: Complete Admission, Scheduling, And Automation Policy

Purpose:
- finish the orchestration controller semantics so unattended launch behavior is fully policy-bounded

Engineers must use:
- `contracts/automation-execution-contract.md`
- `normative/execution/orchestration-execution-model.md`
- `normative/execution/automation-bindings-contract.md`
- `normative/execution/dependency-resolution.md`

Actions:
1. Implement `automation.yml`, `trigger.yml`, `bindings.yml`, and `policy.yml` as split authoritative artifacts.
2. Implement schedule evaluation with timezone and DST semantics exactly as specified.
3. Implement concurrency modes `serialize`, `drop`, `parallel`, and `replace`.
4. Enforce idempotency strategies `event-dedupe` and `schedule-window`.
5. Block `replace` unless the target workflow explicitly declares `execution_controls.cancel_safe: true`.

Exit criteria:
- Event-triggered automations select events only through `trigger.yml`.
- Bindings validate before launch admission.
- Scheduled automations behave deterministically through DST boundaries.
- Conformance scenarios for routing and scheduling pass.

#### Phase 6: Complete Event-Driven Scale Surfaces

Purpose:
- finish watcher and queue behavior so event-driven autonomy is safe, bounded, and inspectable

Engineers must use:
- `contracts/watcher-definition-contract.md`
- `contracts/watcher-event-contract.md`
- `contracts/queue-item-and-lease-contract.md`
- `reference/surfaces/watchers.md`
- `reference/surfaces/queue.md`

Actions:
1. Implement schema-backed watcher authority across `watcher.yml`, `sources.yml`, `rules.yml`, and `emits.yml`.
2. Keep watcher mutable state in `state/` and emitted-event lineage outside mutable state.
3. Implement lexical fan-out ordering, target-hint filtering, severity thresholds, and `source_ref_globs`.
4. Complete queue receipts, retry backoff handling, dead-letter transitions, and stale-ack rejection.

Exit criteria:
- Watchers cannot launch workflows directly.
- Queue remains automation-ingress only.
- Routing conformance proves severity ordering, glob behavior, match modes, target hints, fan-out ordering, and dedupe suppression.
- Queue correctness proves claim-token, retry, and dead-letter behavior.

#### Phase 7: Add Incident And Approval Control

Purpose:
- finish the abnormal-condition and privileged-action path so the control plane can fail closed under stress

Engineers must use:
- `normative/governance/approval-and-override-contract.md`
- `normative/governance/approver-authority-model.md`
- `contracts/incident-object-contract.md`
- `normative/governance/governance-and-policy.md`
- `normative/governance/routing-authority-and-execution-control.md`

Actions:
1. Implement approval artifact validation and approver authority registry checks.
2. Implement incident open, enrich, transition, and close behavior with evidence-backed closure.
3. Route privileged actions through `allow`, `block`, or `escalate` only after approval and authority verification.
4. Connect incident linkage to runs, decisions, and remediation workflows without letting incidents become a policy-authoring surface.

Exit criteria:
- No privileged action can proceed with missing, expired, revoked, or scope-mismatched approval.
- Incident closure requires explicit evidence plus closure authority.
- Incident state remains machine-readable and subordinate evidence does not outrank `incident.yml`.

#### Phase 8: Canonicalize Promoted Surfaces Into Live `.harmony`

Purpose:
- turn the package from package-local design authority into live surface authority one surface at a time

Engineers must use:
- `navigation/canonicalization-target-map.md`
- `normative/assurance/assurance-and-acceptance-matrix.md`
- `history/adoption-roadmap.md`

Promotion order:
1. `runs`
2. `automations`
3. `incidents` runtime state, if needed
4. `queue`
5. `watchers`
6. `campaigns`, only if justified

Additional live addenda required earlier:
- strengthen `workflows`
- strengthen `missions`

Actions for each promoted surface:
1. Add runtime discovery artifacts.
2. Add at least one practices document.
3. Add required governance policy or addendum.
4. Add a surface validator.
5. Prove `G0-G4` before prototype usage.
6. Prove `G0-G7` before canonical rollout.

Exit criteria:
- Promoted surface authority order matches the package.
- Validators enforce that authority order.
- The package no longer serves as the only place where the surface semantics are knowable.

#### Phase 9: Decide On `campaigns` Separately

Purpose:
- keep optional coordination surfaces from contaminating the core build path

Engineers must use:
- `contracts/campaign-object-contract.md`
- `contracts/campaign-mission-coordination-contract.md`
- `reference/surfaces/campaigns.md`

Actions:
1. Gather evidence that multi-mission coordination pressure exists often enough to justify a new surface.
2. If pressure is weak, explicitly defer `campaigns`.
3. If pressure is strong, implement `campaigns` only after `runs`, `automations`, `incidents`, `queue`, and `watchers` are stable.

Exit criteria:
- Either `campaigns` remain deferred with explicit rationale, or they are promoted without becoming execution containers or a second mission system.

### Milestones

| Milestone | Must Be True |
| --- | --- |
| `M0 Authority Locked` | package validators pass; authority order is documented; backlog cites package docs |
| `M1 Contracts Locked` | schemas, fixtures, and conformance are in CI; no unresolved contract ambiguity remains |
| `M2 Foundations Hardened` | workflows and missions align to package contracts; continuity ownership remains intact |
| `M3 Core Primitives Built` | decisions, runs, locks, and queue transitions are canonical and validated |
| `M4 First Slice Proven` | one event-driven path plus one recovery path work end-to-end |
| `M5 Admission Complete` | schedule, binding, concurrency, idempotency, and routing semantics all match the package |
| `M6 Governance Complete` | incidents and approvals fail closed and are evidence-backed |
| `M7 Canonicalization Complete` | required promoted surfaces pass `G0-G7` and live authority order is enforced |

### Test And Conformance Plan

#### Static Gates

1. `bash .harmony/assurance/runtime/_ops/scripts/validate-orchestration-design-package.sh`
2. JSON schema validation for every schema-backed contract fixture
3. Drift checks that block registry or README authority creep
4. Surface validators for promoted `workflows`, `missions`, `runs`, `automations`, `incidents`, `queue`, and `watchers`

#### Semantic Gates

1. Routing scenarios:
   - severity ordering
   - `source_ref_globs`
   - `match_mode=all|any`
   - target-hint behavior
   - lexical fan-out ordering
   - dedupe suppression
2. Scheduling scenarios:
   - spring-forward handling
   - fall-back first-occurrence handling
3. Recovery scenarios:
   - missing executor acknowledgement
   - expired heartbeat same-executor resume
   - abandoned runs blocking new side effects

#### Runtime Integration Gates

1. No side effects before decision, lock, run, and executor acknowledgement.
2. No second exclusive lock owner for the same coordination key.
3. No stale queue acknowledgement with the wrong `claim_token`.
4. No workflow launch with unresolved references, invalid bindings, or missing approval.
5. No incident closure without evidence and authority.
6. No orphan `allow` decision can cause speculative execution.

### Implementation Anti-Patterns To Reject

1. Putting canonical execution metadata in README or registry projections instead of `workflow.yml`, `mission.yml`, `automation.yml`, or other contract artifacts.
2. Letting watchers launch workflows directly.
3. Letting queue target missions directly.
4. Writing side effects before decision, lock, run, and acknowledgement ordering is complete.
5. Treating dashboards, counters, or projections as authoritative state.
6. Using `campaigns` to compensate for weak mission modeling.
7. Replacing the package's algorithms with product-specific convenience logic.

## Impact Map (code, tests, docs, contracts)

| Surface | In-scope impact | Planned action | Out of scope for this plan |
| --- | --- | --- | --- |
| `code` | orchestration runtime, continuity linkage, validators, promotion scaffolds | implement the logical control plane, persistence primitives, routing/admission/launch/recovery logic, and per-surface validators | choosing one mandated storage product, one mandated broker, one mandated RPC technology, or one dashboard stack |
| `tests` | schema validation, semantic conformance, runtime integration, drift checks | run package validation in CI, add surface validators, add end-to-end and failure-path tests for first slice and promotion gates | UI tests or product-specific capability tests outside orchestration responsibilities |
| `docs` | runtime READMEs, practices, governance addenda, scaffolds, promotion docs | promote surface docs in the order defined by the canonicalization target map and keep README/projection authority subordinate | non-orchestration domain documentation refreshes unrelated to promoted surfaces |
| `contracts` | workflow, mission, automation, watcher, queue, run, incident, approval, and campaign contracts | implement to the package contracts first, then promote or defer each contract-backed surface intentionally | inventing new surface families or new authority tiers not defined by the package |

### Planned Live Surface Touch Map

- `.harmony/orchestration/runtime/workflows/`
- `.harmony/orchestration/runtime/missions/`
- `.harmony/orchestration/runtime/runs/`
- `.harmony/orchestration/runtime/automations/`
- `.harmony/orchestration/runtime/incidents/`
- `.harmony/orchestration/runtime/queue/`
- `.harmony/orchestration/runtime/watchers/`
- `.harmony/orchestration/runtime/campaigns/` only if justified
- `.harmony/orchestration/practices/`
- `.harmony/orchestration/governance/`
- `.harmony/continuity/decisions/`
- `.harmony/continuity/runs/`
- `.harmony/assurance/runtime/_ops/scripts/`

## Compliance Receipt

- `planning_scope`: `end-to-end orchestration domain implementation and live promotion planning`
- `implementation_status`: `not started`
- `package_authority`: `.design-packages/orchestration-domain-design-package/`
- `baseline_validation_status`: `validated on 2026-03-10 by running bash .harmony/assurance/runtime/_ops/scripts/validate-orchestration-design-package.sh with zero errors and zero warnings`
- `core_alignment`:
  - preserves Harmony's `agent-first` and `system-governed` framing
  - preserves continuity ownership of durable decision and run evidence
  - preserves `workflows` as bounded procedure definitions
  - preserves `missions` as bounded multi-session intent surfaces
  - preserves `automations` as recurrence and unattended launch policy, not workflow-owned scheduling
  - preserves `watchers` and `queue` as optional scale surfaces for event-driven autonomy
  - preserves `incidents` as a human-governed exception surface
  - preserves `campaigns` as optional and non-core
- `promotion_rule`: no surface is considered live canonical until it has runtime artifacts, practices, governance, and validation coverage
- `required_gates`:
  - `G0-G4` before prototype usage of a promoted surface
  - `G0-G7` before canonical rollout of a promoted surface
- `decision_completeness`: this plan settles implementation order, validation order, promotion order, and anti-drift rules. It does not settle product-specific storage, transport, or presentation tooling because the package explicitly leaves those subordinate.

## Exceptions/Escalations

### Assumptions

1. Engineers are implementing inside this repository and can promote surfaces into `.harmony/`.
2. The package remains the design authority until each target surface is promoted.
3. Existing workflow and mission surfaces will be updated rather than replaced wholesale.
4. Optional surfaces may be deferred if their justification threshold is not met.

### Escalate Immediately If Any Of These Happen

1. A required runtime behavior cannot be mapped cleanly to any package contract or control document.
2. A chosen storage or transport approach cannot provide the package's required atomicity, CAS, lease, or ordering guarantees.
3. Existing live `.harmony/orchestration` documents contradict the package in a way that cannot be solved by promotion sequencing alone.
4. Engineers propose introducing a new top-level orchestration surface or collapsing multiple package surfaces into one.
5. Campaign pressure is claimed before the core `runs`, `automations`, `queue`, `watchers`, and `incidents` path is stable.
6. Transitional coexistence between package authority and live surface authority remains unresolved beyond `2026-06-30`.

### Deferred Choices

- storage backend product choice
- broker or executor transport choice
- operator dashboard or visualization tooling
- exact timeout, heartbeat, retry, and tick default constants

Those choices may vary, but they must not change the package's contracts, ordering rules, or fail-closed behavior.

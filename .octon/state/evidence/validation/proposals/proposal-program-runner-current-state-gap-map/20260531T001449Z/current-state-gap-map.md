# Proposal Program Runner Current State Gap Map

verdict: pass
implemented_at: 2026-05-31T00:14:49Z
proposal_id: proposal-program-runner-current-state-gap-map
run_id: lifecycle-proposal-program-1780186186182-1fbc7b0d-proposal-program-runner-current-state-gap-map
lifecycle_id: proposal-packet
route_id: run-packet-implementation
release_state: pre-1.0
change_profile: atomic
promotion_evidence_class: retained-validation-evidence

## Profile Selection Receipt

- release_state: pre-1.0
- change_profile: atomic
- rationale: the workspace charter and proposal manifest select atomic change
  posture, and no hard gate requires a transitional implementation profile for
  this audit-only child route.

## Scope Boundary

This child route implements the current-state audit and gap map only. The
accepted packet explicitly forbids runner behavior changes in this child. No
runtime crate, executor adapter, lifecycle contract, prompt bundle, validator,
generated projection, workflow route, registry tool, publication tool, cleanup
tool, closeout flow, or archive flow was modified by this route.

The durable artifact promoted by this child is this retained evidence record.
Packet support receipts point to this record and remain packet-local lifecycle
evidence. `proposal.yml#status` remains `accepted`; promotion to
`implemented` is owned by the separate `promote-proposal` lifecycle route.

## Repository Reconnaissance Receipt

Read sets and deterministic inventory checks used for this audit:

- ingress and governance: root `AGENTS.md`,
  `.octon/instance/ingress/AGENTS.md`, the constitutional charter, fail-closed
  obligations, evidence obligations, precedence files, role ownership, contract
  registry, workspace charter, orchestrator role, and applicable practice
  standards.
- packet authority: `proposal.yml`, `architecture-proposal.yml`,
  `navigation/source-of-truth-map.md`, `navigation/artifact-catalog.md`,
  `architecture/target-architecture.md`, `architecture/implementation-plan.md`,
  `architecture/acceptance-criteria.md`, `validation-plan.md`,
  `support/implementation-grade-completeness-review.md`,
  `support/proposal-review.md`, and
  `support/executable-implementation-prompt.md`.
- program lineage: parent source lifecycle improvement notes, source
  traceability matrix, and `resources/child-packet-index.yml`.
- runtime controller: `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`.
- executor adapter: `.octon/framework/engine/runtime/crates/lifecycle_executor/src`.
- contract authority: `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
  and `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`.
- prompt surfaces: `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/`
  and generated effective prompt publications under
  `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/`.
- workflow routes: `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/`,
  `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`,
  and `.octon/generated/effective/runtime/route-bundle.yml`.
- validators and tools: `.octon/framework/assurance/runtime/_ops/scripts/`,
  `.octon/framework/assurance/runtime/_ops/tests/`,
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`,
  publication scripts, proposal registry generation scripts, and hygiene
  cleanup scripts.
- worktree boundary: only this retained evidence file and packet-local support
  receipts are introduced by this route; pre-existing local run residue remains
  untouched.

## Classification Summary

| Classification | Result |
| --- | --- |
| existing-and-preserve | The live repository already contains the core program contract, runner control loop, executor adapter, workflow leaf adapter, generated effective route surfaces, validators, hygiene tools, publication tools, registry tools, run evidence controls, and baseline tests. |
| existing-but-test-gap | Several behaviors exist but need broader scenario and fixture coverage before the parent program can claim complete end-to-end confidence. The tests-fixtures child owns that expansion. |
| implementation-gap | Remaining implementation changes are owned by sibling child packets, not by this audit packet. |
| contract-gap | No current-state contract gap is owned by this child. Contract changes, if required by later implementation packets, must be made in their declared contract write scopes. |
| validator-gap | No validator change is owned by this child. Validator additions or hardening are owned by the sibling packets whose surfaces they verify. |
| route-prompt-gap | No route prompt change is owned by this child. Prompt changes are owned by verification, cleanup, closeout, or generated-state sibling packets when their acceptance criteria require them. |
| out-of-scope | Runner changes, generated projection edits, lifecycle status mutation, closeout, archive, and parent evidence substituting for child-owned receipts are excluded from this child. |

## Surface Inventory

| Surface | Evidence | Source requirements | Classification | Smallest owned surface | Route decision |
| --- | --- | --- | --- | --- | --- |
| Proposal program contract | `proposal-program.contract.yml` declares orchestrated replan loop execution, child registry, execution modes, dependencies, recovery policy, closeout policy, route ids, and program receipts. | R060, R062, child registry contract | existing-and-preserve | Contract file under `context/lifecycles/` | Preserve. Later contract changes belong to sibling implementation packets. |
| Proposal packet contract | `lifecycle.contract.yml` declares proposal packet receipts, review gates, implementation route, promote workflow, verification/correction loop, closeout, and archive workflow. | packet lifecycle route progression | existing-and-preserve | Contract file under `context/lifecycles/` | Preserve. This audit uses the declared route contract. |
| Program plan loading | `plan_program_lifecycle_from_octon_dir` loads parent context, child registry, child plans, receipt states, dependencies, closeout policy, recovery blockers, approval blockers, and runnable batch state. | planning and replan loop | existing-and-preserve | `lifecycle_program.rs` | Preserve for this child. Planning changes belong to `proposal-program-runner-planning-replan-loop`. |
| Default no-dispatch handoff | `run_program_lifecycle_from_octon_dir` plans without route dispatch unless execution is explicitly enabled. | unattended safety, fail-closed execution | existing-and-preserve | `lifecycle_program.rs` | Preserve. No behavior change in audit packet. |
| Program replan loop | `run_program_lifecycle_single_step` records checkpoint/event evidence, dispatches parent or child work, and replans after execution or recovery. | E2E runner loop | existing-and-preserve | `lifecycle_program.rs` | Preserve. Hardening belongs to planning/replan and evidence/run-control children. |
| Child runnable selection | `select_runnable_batch` applies execution mode, dependencies, gates, write-scope independence, and program-atomic rules. | scheduling and recovery | existing-and-preserve | `lifecycle_program.rs` | Preserve. Scheduling changes belong to `proposal-program-runner-child-scheduling-recovery`. |
| Child execution job construction | `build_child_execution_jobs` resolves child route, recovery route, authority zone, invocation authority, worktree hygiene, locks, and executor request payload. | executor delegation gates | existing-and-preserve | `lifecycle_program.rs` plus executor request types | Preserve. Delegation hardening belongs to `proposal-program-runner-executor-delegation-gates`. |
| Child execution and finalization | `execute_child_jobs`, `execute_child_job`, `finish_child_execution`, and lock release code handle attempts, route results, events, and cleanup evidence. | E2E child dispatch | existing-and-preserve | `lifecycle_program.rs` | Preserve. Recovery refinements belong to scheduling/recovery and executor/delegation children. |
| Run control and evidence | Checkpoint snapshots, lifecycle event logs, hash-chain verification, cancellation, resume, binding checks, run input evidence, and aggregate closeout verification are present. | evidence tiers and run lifecycle controls | existing-and-preserve | `lifecycle_program.rs` and state roots | Preserve. Evidence hardening belongs to `proposal-program-runner-evidence-run-control`. |
| Parent closeout boundary | Closeout verification keeps parent summary evidence separate from child-owned implementation, conformance, drift, closeout, and archive receipts. | child-owned receipt boundary | existing-and-preserve | `lifecycle_program.rs` | Preserve. Closeout/archive policy changes belong to `proposal-program-runner-closeout-archive-policy`. |
| Executor adapter | `DefaultLifecycleRouteExecutor` validates paths, observes manifests and receipts, checks authorization and cancellation, performs executor preflight, runs route requests, and writes result evidence. | executor adapter support | existing-and-preserve | `lifecycle_executor/src/adapter.rs` and adjacent modules | Preserve. Delegation and adapter changes belong to executor/delegation child. |
| Generated prompt and workflow resolution | Executor generation code resolves prompt bundles from generated effective extension catalog and workflow bundles from runtime route bundle source refs. | generated-state and publication behavior | existing-and-preserve | `lifecycle_executor/src/generated.rs` | Preserve. Generated-state publication changes belong to `proposal-program-runner-generated-state-publication`. |
| Workflow leaf execution | Workflow leaf adapter invokes repo-local workflow executables and records invocation/stdout/stderr/terminal/observation evidence. | workflow route execution | existing-and-preserve | `lifecycle_executor/src/workflow_leaf.rs` | Preserve. Workflow route changes belong to workflow-owning sibling packets. |
| Generated effective projections | Effective extension catalog, published prompt bundles, and runtime route bundle include proposal-packet and proposal-program routes. | generated projection availability | existing-and-preserve | `.octon/generated/effective/**` | Treat as generated projection, not authority. Publication changes belong to generated-state child. |
| Route prompts | Source prompt bundles exist for packet creation, review, implementation, verification/correction, closeout, program orchestration, program verification, program correction, program closeout, and cleanup residue. | route prompt availability | existing-and-preserve | `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/` | Preserve. Prompt edits are sibling-owned. |
| Workflow routes | `promote-proposal` and `archive-proposal` workflow route surfaces exist and are referenced by generated route bundle state. | promotion and archive behavior | existing-and-preserve | `.octon/framework/orchestration/runtime/workflows/meta/` | Preserve. Promotion/archive changes belong to dedicated workflow or closeout/archive packets. |
| Structural validators | Proposal standard, architecture proposal, review gate, readiness, conformance, drift, program structure, child readiness, lifecycle contracts, publication state, registry, and route validation scripts exist. | validation floor | existing-and-preserve | `.octon/framework/assurance/runtime/_ops/scripts/` and extension validation tests | Preserve. Validator hardening belongs to sibling packets. |
| Hygiene tooling | Worktree hygiene classifier, local run artifact cleanup script, cleanup lifecycle route, and repo hygiene skill surfaces exist. | hygiene and cleanup | existing-and-preserve | assurance scripts, cleanup prompt, repo hygiene skill, governance policy | Preserve. Cleanup behavior changes belong to `proposal-program-runner-cleanup-hygiene`. |
| Publication tooling | Extension publication, runtime route bundle publication, pack route generation, pack route publication, host projection publication, and generated proposal registry tooling exist. | publication behavior | existing-and-preserve | `_ops/scripts/` under framework and capabilities | Preserve. Publication changes belong to generated-state child. |
| Registry tooling | Generated proposal registry tooling exists and remains discovery-only. | proposal registry behavior | existing-and-preserve | registry generation scripts and generated registry output | Preserve. Do not treat generated registry as authority. |
| Baseline runner tests | Runner, executor adapter, program structure, child readiness, route resolution, authority boundary, pack shape, registry, and publication tests exist. | test surface | existing-but-test-gap | test directories under assurance and extension validation | Preserve current tests. Scenario expansion belongs to `proposal-program-runner-tests-fixtures`. |
| R060/R062 edge coverage | Existing tests cover core runner paths but do not exhaustively prove every program-mode, recovery, verification, cleanup, publication, and closeout edge claimed by the parent program. | E2E proof threshold | existing-but-test-gap | `proposal-program-runner-tests-fixtures` write scopes | Route to tests-fixtures after behavior packets land. |
| Planning/replan refinements | The current planner is present; future refinements must avoid duplicate runner-local behavior and update only the smallest owned controller surfaces. | planning/replan loop | implementation-gap | `proposal-program-runner-planning-replan-loop` | Route to sibling packet. |
| Executor/delegation refinements | Executor and authorization paths exist; any extra delegation gates must land in executor-owned surfaces and tests. | executor delegation gates | implementation-gap | `proposal-program-runner-executor-delegation-gates` | Route to sibling packet. |
| Evidence/run-control refinements | Evidence, checkpoint, resume, cancellation, and replay controls exist; extra proof or retention hardening must land in evidence/run-control surfaces. | evidence tiers and run lifecycle controls | implementation-gap | `proposal-program-runner-evidence-run-control` | Route to sibling packet. |
| Child scheduling/recovery refinements | Scheduling and recovery logic exists; additional edge behavior must land in scheduler-owned code and tests. | scheduling and recovery | implementation-gap | `proposal-program-runner-child-scheduling-recovery` | Route to sibling packet. |
| Verification/correction routing refinements | Verification and correction lifecycle routes exist; additional routing behavior must land in lifecycle context, prompts, validators, and runner glue owned by that child. | verification/correction behavior | implementation-gap | `proposal-program-runner-verification-correction-routing` | Route to sibling packet. |
| Cleanup/hygiene refinements | Cleanup route and hygiene tooling exist; extra cleanup safety belongs to cleanup/hygiene surfaces. | hygiene behavior | implementation-gap | `proposal-program-runner-cleanup-hygiene` | Route to sibling packet. |
| Closeout/archive refinements | Closeout and archive concepts exist; terminal policy changes belong to closeout/archive surfaces and workflows. | closeout/archive behavior | implementation-gap | `proposal-program-runner-closeout-archive-policy` | Route to sibling packet. |
| Generated-state publication refinements | Generated projections exist; publication refresh or generation policy changes belong to publication surfaces, not runner code. | generated state publication | implementation-gap | `proposal-program-runner-generated-state-publication` | Route to sibling packet. |

## Duplicate Runner-Local Behavior Rejection

The audit rejects adding duplicate behavior to the generic runner for concerns
already owned elsewhere:

- Do not encode lifecycle policy directly in runner branches when
  `proposal-program.contract.yml` or `lifecycle.contract.yml` is the governing
  source.
- Do not hand-edit generated effective projections or rely on them as authority;
  regenerate through publication tooling when a sibling packet changes source
  inputs.
- Do not let parent program receipts substitute for child packet
  implementation, conformance, drift, closeout, or archive receipts.
- Do not bypass executor adapter authorization, cancellation, preflight,
  observation, or route-result evidence by adding special-purpose child
  dispatch paths.
- Do not fold cleanup, closeout, archive, registry, publication, or validator
  behavior into a runner-only shortcut.

## Downstream Routing

| Gap family | Owning child route | Acceptance gate for that child |
| --- | --- | --- |
| Planning and replan loop | `proposal-program-runner-planning-replan-loop` | Controller code and contract changes stay in declared write scopes and retain replan evidence. |
| Executor delegation gates | `proposal-program-runner-executor-delegation-gates` | Executor adapter and authorization changes include tests and no bypass of route observation. |
| Evidence and run control | `proposal-program-runner-evidence-run-control` | Checkpoint, event, cancellation, resume, and retention changes preserve child-owned evidence boundaries. |
| Child scheduling and recovery | `proposal-program-runner-child-scheduling-recovery` | Scheduling behavior is contract-aligned and independently tested for execution modes and recovery states. |
| Verification and correction routing | `proposal-program-runner-verification-correction-routing` | Prompt, validator, and runner route changes preserve packet authority boundaries. |
| Cleanup and hygiene | `proposal-program-runner-cleanup-hygiene` | Cleanup tooling remains authorization-backed and never deletes unrelated worktree changes. |
| Closeout and archive policy | `proposal-program-runner-closeout-archive-policy` | Closeout/archive decisions require child receipts and retained evidence before parent terminal claims. |
| Generated-state publication | `proposal-program-runner-generated-state-publication` | Generated projections remain publication outputs, with source inputs and route bundles refreshed through tools. |
| Tests and fixtures | `proposal-program-runner-tests-fixtures` | Fixture coverage proves the integrated R060/R062 execution matrix after behavior-owning packets land. |

## Acceptance Criteria Trace

| Criterion | Evidence |
| --- | --- |
| Inventory authored contracts | `proposal-program.contract.yml` and `lifecycle.contract.yml` inspected and classified as existing-and-preserve. |
| Inventory generated projections | Effective extension catalog, published prompt bundles, and runtime route bundle inspected and classified as generated projections, not authority. |
| Inventory runtime controller behavior | `lifecycle_program.rs` planning, execution, scheduling, evidence, closeout, cancellation, resume, and replay surfaces inspected. |
| Inventory executor adapter support | `lifecycle_executor/src` adapter, generated, workflow leaf, observer, authorization, request, and result surfaces inspected. |
| Inventory route prompts and workflows | Source prompts and generated publications inspected; promote/archive workflow routes inspected. |
| Inventory validators, hygiene, publication, registry, evidence tiers, controls, and tests | Assurance scripts, tests, extension validation tests, publication scripts, registry tooling, and hygiene tooling inspected. |
| Classify behaviors | The classification table records preserve, test gap, implementation gap, no owned contract gap, no owned validator gap, no owned route-prompt gap, and out-of-scope decisions. |
| Reject duplicate runner-local behavior | The duplicate behavior rejection section names prohibited shortcuts and sibling ownership boundaries. |

## Final Route Finding

The current-state audit is complete for this child route. The smallest owned
durable surface for this child is retained evidence plus packet-local route
receipts. No implementation change to runner, executor, contract, prompt,
workflow, validator, generated, publication, registry, hygiene, closeout, or
archive surfaces is authorized by this packet.

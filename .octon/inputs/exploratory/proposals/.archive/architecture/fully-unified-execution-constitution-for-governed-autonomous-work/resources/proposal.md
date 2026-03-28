# Fully Unified Execution Constitution for Governed Autonomous Work Proposal

## A. Executive Proposal Thesis

Octon should preserve its strongest current architectural asset: the `.octon/` class-root super-root with authored authority in `framework/**` and `instance/**`, operational truth in `state/**`, rebuildable outputs in `generated/**`, raw additive/exploratory material in `inputs/**`, and fail-closed runtime enforcement through an engine-owned execution-authorization boundary. It should **not** preserve the current fragmentation of that architecture across `octon.yml`, the umbrella specification, agency governance documents, bootstrap docs, mission artifacts, and workflow-host-specific approval semantics. Today Octon is a strong **repository constitution** with an emerging executable kernel. The proposal is to turn it into a **fully unified execution constitution**. ([GitHub][1])

The decisive change is this: **mission stops being the atomic execution primitive** and becomes the continuity/ownership/autonomy container for long-horizon work; **run contracts become the atomic unit of material execution**; all material actions route through a single authority engine; all consequential runs emit a normalized run bundle, checkpoint lineage, assurance reports, intervention records, and a RunCard; all system-level claims publish a HarnessCard; heavy telemetry externalizes through immutable replay stores; and Octon gains a top-level **lab** domain that proves behavior instead of only structure. That preserves Octon’s best current ideas while completing the missing half of the architecture. ([GitHub][2])

The result is a harness whose control is durable, whose authority is explicit, whose runtime is lifecycle-managed, whose evidence is replayable, whose intervention is accountable, whose support claims are bounded, and whose scaffolding is designed to be deleted when models improve. That is the best long-term architecture for Octon. ([GitHub][3])

## B. Repository-Grounded Baseline

Grounded in the repository today, Octon is a governed self-hosting harness built around a single `.octon/` super-root. The root README and `.octon/README.md` define a class-first topology: `framework/` is portable authored core, `instance/` is repo-specific durable authority, `inputs/` is non-authoritative additive/exploratory material, `state/` is operational truth and retained evidence, and `generated/` is rebuildable only. The umbrella specification repeats those invariants, blocks raw `inputs/**` from becoming direct runtime or policy dependencies, and declares `octon.yml` the authoritative root manifest with fail-closed hooks. ([GitHub][4])

Octon already has a serious executable/runtime core. `framework/engine/runtime/README.md` defines `runtime/` as executable artifacts only; the kernel crate builds the `octon` binary; the CLI already exposes service discovery/invocation, workflow execution and validation, stdio serving, Studio launch, and read-only orchestration inspection. The policy interface is explicit and stable: launchers are the invocation boundary, material evaluations must carry intent binding, and wrapper-assisted material runs must emit instruction-layer manifests and receipts. The execution-authorization spec requires all material execution to pass through `authorize_execution(request) -> GrantBundle`, and the existing request/grant/receipt schemas already carry workflow mode, mission/autonomy context, granted capabilities, route decisions, rollback/compensation handles, recovery windows, and budget metadata. ([GitHub][5])

Octon also already has durable control surfaces that are stronger than most current harnesses. The overlay registry restricts repo-specific overlays to declared points and merge modes. The instance manifest explicitly enables those points. The contract registry defines canonical execution/control/evidence roots, policy roots, documentation classes, required doc surfaces, and blocking checks. The instance ingress is canonical and root ingress files must be thin adapters only; runtime-facing compiled outputs under `generated/effective/**` are trusted only when fresh and receipt-backed. This is genuine control architecture, not prompt sprawl. ([GitHub][6])

Governance is also materially real today. The policy interface binds the runtime to repo-owned network egress, execution budgets, mission autonomy, ownership registry, mission registry, budget state, exception leases, control evidence roots, and mission projections. The network-egress policy currently allows only a localhost LangGraph HTTP forwarding path. The mission-autonomy policy already defines oversight modes, execution postures, safe-interrupt boundaries, pause-on-failure triggers, recovery windows, autonomy-burn thresholds, circuit breakers, and quorum templates. PR workflows enforce protected execution posture; deny-by-default gates validate capability/engine boundaries and upload receipts; high-impact PRs currently require an `accept:human` label; and the AI review gate aggregates provider findings, syncs `ai-gate:*` labels, and uploads decision artifacts and protected-execution receipts. ([GitHub][7])

The runtime already looks more like a lifecycle than a chat loop. `state/**` is split into `continuity`, `evidence`, and `control`; mission registries and mission control roots exist; mission summaries and machine mission views are generated; mission creation is authoritative in `instance/orchestration/missions/**`; and active mission continuity lives under `state/continuity/repo/missions/**`. The current live mission is explicitly designed to validate mission-scoped reversible autonomy end to end. ([GitHub][1])

What is still incomplete is just as important. The intent layer is explicitly unfinished in the repo backlog, with pending “contract foundation,” “enforcement,” and “cutover gate” tasks. `instance/governance/contracts/` is still only a reserved overlay directory. `budget-state.yml` is effectively empty and `exception-leases.yml` has no active leases. The ownership registry currently names only one operator. The current architecture is therefore strong on constitutional structure and structural/governance conformance, but still under-normalized around per-run objective binding, first-class approval/exception artifacts, replay/disclosure, behavioral proof, and lab-grade experimentation. ([GitHub][8])

## C. Proposal Design Principles

1. **Preserve the class-root super-root.** The `framework / instance / inputs / state / generated` split is already architecturally correct and should remain the permanent spine of Octon. `generated/**` must remain derived-only, raw `inputs/**` must remain non-authoritative, and runtime must continue to fail closed on class violations and stale required outputs. ([GitHub][1])

2. **Unify the constitution.** Octon’s current constitution is real but distributed across `octon.yml`, the umbrella specification, bootstrap docs, the agency constitution, and mission/autonomy policy. The target state consolidates these into one constitutional kernel with explicit precedence, obligations, and amendment semantics. ([GitHub][9])

3. **Demote mission from execution atom to continuity object.** Mission remains central for long-horizon ownership, overlap policy, autonomy posture, and resumability. But the atomic execution unit becomes the run contract. Current mission-centric execution should survive as a higher-order continuity layer, not the only legal execution model. ([GitHub][1])

4. **Promote run contracts and grants to first-class authority.** Existing execution request/grant/receipt schemas are strong lower-level building blocks. They should be wrapped by higher-level run contracts, approval artifacts, and decision artifacts that unify intent, authority, runtime, and disclosure. ([GitHub][10])

5. **Keep fail-closed, but preserve `STAGE_ONLY` as a constitutional route.** Octon already uses `ALLOW`, `STAGE_ONLY`, `DENY`, and `ESCALATE`, and current budget policy already downgrades missing-cost-evidence cases to `stage_only`. That is a target-state-strength, not a weakness: it gives the harness a safe preparatory mode instead of a false binary between “do it” and “stop.” ([GitHub][11])

6. **Separate execution, verification, and authority.** Octon’s current structural gates are strong, but the target state must forbid one undifferentiated loop where the same model generates, judges, and authorizes. Independent proof and authority routing become kernel obligations. ([GitHub][12])

7. **Add the lab as a first-class domain.** Octon already has live mission validation and autonomy scenario tests, but they are still embedded in assurance and orchestration. Behavioral discovery needs its own home. ([GitHub][12])

8. **Make support claims explicit.** Current locality, portability, release-target, and provider-specific budget surfaces show that Octon already has implicit support assumptions. The target state makes those assumptions explicit in a support-target matrix rather than implying universality. ([GitHub][13])

9. **Simplify the agency kernel.** The current agency manifest’s default of one `architect` agent and no skill-actor delegation is pointing in the right direction. The target state preserves the accountability logic and removes persona-heavy material from the kernel path unless it enforces a real boundary. ([GitHub][14])

10. **Build to delete.** Every compensating mechanism must carry a removal trigger, a review cadence, and an ablation path. Octon’s packetized cutovers and continuity backlog show the right instincts; the target state turns that into an explicit retirement discipline. ([GitHub][8])

## D. Proposed Unified Execution Constitution

Octon should become a **single constitutional kernel** that unifies what is currently split across root manifest, architecture specification, bootstrap objective, agency constitution, mission-autonomy policy, runtime specs, and CI gates. That kernel should live under a new top-level framework domain, `framework/constitution/`, and should be the supreme repo-local authority beneath non-waivable external obligations. It consolidates current non-negotiables already present in `octon.yml`, the umbrella specification, the agency constitution, and the intent/policy interfaces into one explicit regime. ([GitHub][9])

The constitutional kernel should contain these canonical artifacts:

* `framework/constitution/CHARTER.md` — human-readable constitutional charter.
* `framework/constitution/charter.yml` — machine-readable charter manifest.
* `framework/constitution/precedence/normative.yml` — normative authority precedence.
* `framework/constitution/precedence/epistemic.yml` — epistemic grounding precedence.
* `framework/constitution/contracts/registry.yml` — canonical contract registry.
* `framework/constitution/obligations/fail-closed.yml` — non-waivable fail-closed rules.
* `framework/constitution/obligations/evidence.yml` — required evidence classes and retention obligations.
* `framework/constitution/ownership/roles.yml` — role/authority classes for humans, harness, and models.
* `framework/constitution/support-targets.schema.json` — support-target matrix schema.

The constitutional non-negotiables should be:

1. No material execution without a bound run contract.
2. No material side effect before authority routing and grant issuance.
3. No runtime or generated artifact can become a second control plane.
4. Raw `inputs/**` never become direct runtime or policy dependencies.
5. `generated/**` remains derived-only.
6. Material execution always emits receipts and evidence.
7. Long-horizon recurring autonomy requires a mission charter; bounded one-shot autonomy may be run-only but may not silently “fall back” into missionlessness.
8. Hidden human intervention is prohibited.
9. Benchmark or production claims without RunCard/HarnessCard support are invalid.
10. Every compensating mechanism must have a removal review. ([GitHub][1])

## E. Target-State Layered Architecture

### 1. Design Charter / Constitutional Layer

* **Purpose:** define what Octon is, what it is for, what it is not, its non-negotiable obligations, fail-closed behavior, evidence duties, and amendment rules.
* **Responsibilities:** replace the current distributed constitutional lattice with one supreme kernel; define the instruction-layer model for material runs; define support-target obligations; declare constitutional control boundaries that cannot remain in prompt text.
* **Inputs:** current `octon.yml`, the umbrella specification, agency constitution/delegation/memory contracts, bootstrap docs, runtime specs, and governance policy families.
* **Outputs:** charter manifest, precedence matrices, fail-closed obligations, evidence obligations, constitutional contract registry.
* **State ownership:** framework-authored constitutional core; instance-owned overlays only where explicitly declared.
* **Boundary conditions:** prompts and ingress adapters may project the charter, but may not override it; generated outputs remain non-authoritative; runtime fails closed on constitutional divergence.
* **Interaction:** consumed first by the authority engine, runtime, and instruction-layer manifest builder. ([GitHub][9])

### 2. Intent / Objective Layer

* **Purpose:** bind work through four layers: workspace charter, mission charter, run contract, and execution attempt/stage.
* **Responsibilities:** express scope, exclusions, done-when criteria, acceptance criteria, risk/materiality class, protected zones, authority surfaces, required evidence, and versioning.
* **Inputs:** current workspace objective brief, active intent contract, mission registry, mission charters, support-target matrix, and operator triggers.
* **Outputs:** workspace charter pair (`.md` + `.yml`), mission charter v3, run contract v1, execution attempt manifest/stage contracts.
* **State ownership:** workspace and mission charters are durable repo authority under `instance/**`; run contracts are runtime-bound control artifacts under `state/control/execution/runs/**`.
* **Boundary conditions:** no material run without a run contract; mission is mandatory for long-running or recurring autonomy classes; mission is optional only for explicitly bounded run-only classes.
* **Interaction:** authority engine routes on run contract; runtime binds execution request/grant/receipt to the run contract; assurance consumes acceptance criteria. ([GitHub][15])

### 3. Durable Control Layer

* **Purpose:** keep authored authority, operational truth, evidence, and derived outputs sharply separated.
* **Responsibilities:** preserve class-root model, overlay declarations, root ingress discipline, canonical specs, schemas, runbooks, ADRs, continuity artifacts, and compiled effective views.
* **Inputs:** root manifest, framework/instance manifests, overlay registry, contract registry, repo-owned context and decisions.
* **Outputs:** authoritative control surfaces and freshness-bounded runtime views.
* **State ownership:** `framework/**` and `instance/**` remain authored authority; `state/**` remains mutable operational truth/evidence; `generated/**` remains derived-only.
* **Boundary conditions:** normative control and informative docs must be explicitly distinguished; the target state adds dual precedence—normative authority vs epistemic grounding—on top of current SSOT rules.
* **Interaction:** runtime consumes only authoritative or freshness/receipt-bounded compiled surfaces; proposals and raw inputs remain excluded from runtime and policy resolution. ([GitHub][1])

### 4. Policy / Authority Layer

* **Purpose:** convert policy, ownership, mission posture, support targets, and approvals into deterministic route decisions.
* **Responsibilities:** evaluate materiality, capability scope, risk class, reversibility class, action class, ownership, approval requirement, budget posture, egress posture, and exception state; emit `ALLOW`, `STAGE_ONLY`, `ESCALATE`, or `DENY`.
* **Inputs:** run contract, mission charter, policies, ownership registry, approval artifacts, exception leases, revocations, model/capability adapter constraints.
* **Outputs:** ApprovalRequests, ApprovalGrants, ExceptionLeases, Revocations, DecisionArtifacts, GrantBundles.
* **State ownership:** humans own policy content, grants, exceptions, and revocations; the harness owns evaluation and enforcement; the model may only request.
* **Boundary conditions:** unresolved ownership, missing evidence, invalid intent binding, unsupported support tier, or policy ambiguity fail closed or downgrade to `STAGE_ONLY` where policy allows.
* **Interaction:** sits between run contract and any material tool/capability invocation. ([GitHub][7])

### 5. Agency Layer

* **Purpose:** provide mediated action through one accountable orchestrator and a small number of real separation-of-duties roles.
* **Responsibilities:** planning, bounded delegation, handoff packets, capability invocation, and local self-checks.
* **Inputs:** run contract, grant bundle, continuity artifacts, capability pack contracts, model adapter.
* **Outputs:** execution requests, stage plans, handoff packets, local findings.
* **State ownership:** routing manifest, agent profiles, handoff rules, and memory policy.
* **Boundary conditions:** sub-agents exist only for real boundary value—separation of duties, context isolation, or concurrency. Persona-only surfaces are not kernel authority.
* **Interaction:** orchestrator drives runtime; verifier/evaluator roles sit outside execution authority; memory discipline is enforced by runtime, not just prose. ([GitHub][14])

### 6. Runtime Layer

* **Purpose:** manage long-running work as an event-sourced lifecycle instead of a conversation.
* **Responsibilities:** bind run contract, emit run manifest, open worktree/sandbox, checkpoint, resume, classify retries, enforce contamination rules, coordinate rollback/compensation, and finalize replay bundles.
* **Inputs:** run contract, grant bundle, model adapter, capability pack contracts, continuity artifacts, support-target matrix.
* **Outputs:** run manifest, stage attempts, checkpoints, continuity artifacts, receipts, measurements, replay pointers, RunCard.
* **State ownership:** engine runtime owns execution state machine; `state/control/execution/runs/**` owns mutable run state; `state/evidence/runs/**` owns retained run evidence.
* **Boundary conditions:** no chat-history dependency for resumption; every material stage emits receipts; missionless autonomy is legal only for explicit bounded run classes; hard reset is available when contamination is detected.
* **Interaction:** authority engine gates stages; assurance gates closure; observability persists events and measurements. ([GitHub][16])

### 7. Verification / Evaluation Layer

* **Purpose:** prove structural, functional, behavioral, maintainability, governance, and recovery properties separately.
* **Responsibilities:** deterministic validators, capability acceptance suites, mission/run acceptance checks, independent evaluator roles, governance proof, and recovery drills.
* **Inputs:** code/artifacts, run bundle, contracts, compiled effective views, scenario assertions, telemetry.
* **Outputs:** assurance reports by plane, blocked promotions, release recommendations, benchmark records.
* **State ownership:** `framework/assurance/**` for deterministic suites and evaluator contracts; instance overlays for repo-specific acceptance packs.
* **Boundary conditions:** self-checking is allowed only for local deterministic sanity checks; consequential acceptance requires deterministic proof or an independent evaluator; behavioral claims require lab or scenario proof.
* **Interaction:** current structural gates remain blocking; new functional/behavioral/recovery suites become first-class peers, not optional extras. ([GitHub][12])

### 8. Lab / Experimentation Layer

* **Purpose:** discover behavior the library side cannot prove.
* **Responsibilities:** workload replay, scenario packs, shadow runs, fault injection, adversarial/red-team experiments, environment-level discovery, and cross-system validation.
* **Inputs:** run bundles, replay pointers, scenario specs, telemetry probes, adapter packs.
* **Outputs:** behavioral audit reports, robustness findings, hidden checks, new benchmark cases, drift findings.
* **State ownership:** `framework/lab/**` plus `state/evidence/lab/**`.
* **Boundary conditions:** the lab is distinct from assurance because it explores unknowns; it is top-level because its scope spans runtime, authority, adapters, and behavioral proof.
* **Interaction:** feeds new suites into assurance and new guardrails into governance. ([GitHub][2])

### 9. Governance / Safety Layer

* **Purpose:** keep Octon governable in practice.
* **Responsibilities:** approval, revocation, exception leasing, intervention logging, reversibility policy, recovery windows, misuse boundaries, and accountability attribution.
* **Inputs:** authority decisions, grants, leases, intervention events, mission/autonomy policy, support targets.
* **Outputs:** approved authority changes, revocations, intervention records, accountability trails.
* **State ownership:** instance governance policies/contracts plus state control/evidence for live authority artifacts.
* **Boundary conditions:** one-way-door actions, protected zones, public release, credential or identity changes, and broader external commitments always require stronger approval than repo-local reversible work.
* **Interaction:** interlocks with runtime, assurance, observability, and disclosure. ([GitHub][17])

### 10. Observability / Reporting Layer

* **Purpose:** make runs replayable and claims interpretable.
* **Responsibilities:** event schemas, replay bundle assembly, measurement records, failure taxonomies, RunCards, HarnessCards, benchmark disclosure, and operator reporting.
* **Inputs:** runtime events, grants/receipts, assurance reports, intervention records, external trace pointers.
* **Outputs:** RunCards, HarnessCards, benchmark disclosure packets, dashboards/digests, failure ledgers.
* **State ownership:** `framework/observability/**` contracts; `state/evidence/**` retention; external immutable stores for high-volume traces.
* **Boundary conditions:** generated readable summaries remain derived and non-authoritative; disclosure artifacts must be minimal but sufficient for operational/scientific interpretation.
* **Interaction:** fed by runtime, authority engine, assurance, and lab; consumed by operators, reviewers, and future improvement passes. ([GitHub][1])

### 11. Improvement / Evolution Layer

* **Purpose:** evolve the harness while deleting obsolete scaffolding.
* **Responsibilities:** failure harvesting, stale-doc detection, state drift detection, governance drift detection, adapter evolution, rule promotion, ablation, and retirement.
* **Inputs:** continuity logs, tasks, measurement records, benchmark results, replay bundles, intervention records.
* **Outputs:** ADRs, migration packets, contract revisions, support-matrix changes, deletion PRs.
* **State ownership:** repo continuity surfaces and constitutional change process.
* **Boundary conditions:** no new compensating mechanism without owner, success metric, and retirement trigger; no support-target expansion without adapter conformance and disclosure update.
* **Interaction:** closes the loop from runtime and proof back into the constitutional kernel. ([GitHub][8])

## F. Proposed Repository and Boundary Restructuring

Keep the top-level class-root super-root exactly as it is. The core restructuring happens **inside** `framework/`, `instance/`, `state/`, and `generated/`. The goal is not to replace Octon’s best structure, but to make it constitutional, run-first, and disclosure-complete. The current repository already gives the right macro-boundary; the proposal changes what each domain owns. ([GitHub][1])

Proposed target-state major shape:

```text
.octon/
├── octon.yml
├── framework/
│   ├── constitution/                    # NEW constitutional kernel
│   │   ├── CHARTER.md
│   │   ├── charter.yml
│   │   ├── precedence/
│   │   │   ├── normative.yml
│   │   │   └── epistemic.yml
│   │   ├── obligations/
│   │   │   ├── fail-closed.yml
│   │   │   └── evidence.yml
│   │   ├── ownership/
│   │   │   └── roles.yml
│   │   └── contracts/
│   │       ├── registry.yml
│   │       ├── objective/
│   │       ├── authority/
│   │       ├── runtime/
│   │       ├── assurance/
│   │       ├── disclosure/
│   │       └── retention/
│   ├── engine/
│   │   └── runtime/
│   │       ├── adapters/
│   │       │   ├── hosts/
│   │       │   │   ├── github/
│   │       │   │   ├── local-cli/
│   │       │   │   ├── ci/
│   │       │   │   └── studio/
│   │       │   └── models/
│   │       │       ├── openai/
│   │       │       ├── anthropic/
│   │       │       └── local/
│   │       └── crates/
│   │           ├── kernel/
│   │           ├── core/
│   │           ├── policy_engine/
│   │           ├── authority_engine/    # NEW
│   │           ├── replay_store/        # NEW
│   │           └── telemetry_sink/      # NEW
│   ├── capabilities/
│   │   ├── contracts/
│   │   └── packs/
│   │       ├── repo/
│   │       ├── git/
│   │       ├── shell/
│   │       ├── browser/                 # NEW governed packs
│   │       ├── api/                     # NEW governed packs
│   │       └── telemetry/
│   ├── orchestration/
│   │   ├── missions/
│   │   ├── queue/
│   │   ├── incidents/
│   │   └── automations/
│   ├── assurance/
│   │   ├── structural/
│   │   ├── functional/
│   │   ├── governance/
│   │   ├── recovery/
│   │   └── evaluators/
│   ├── lab/                             # NEW top-level domain
│   │   ├── scenario-packs/
│   │   ├── replay/
│   │   ├── shadow/
│   │   ├── faults/
│   │   ├── red-team/
│   │   └── telemetry-probes/
│   ├── observability/                   # NEW top-level domain
│   │   ├── schemas/
│   │   ├── replay/
│   │   ├── disclosure/
│   │   ├── measurements/
│   │   └── failure-taxonomy/
│   ├── agency/                          # slimmed kernel
│   │   ├── manifest.yml
│   │   ├── routing/
│   │   ├── profiles/
│   │   │   ├── orchestrator/
│   │   │   └── verifier/
│   │   └── handoff/
│   ├── scaffolding/
│   └── overlay-points/
├── instance/
│   ├── charter/                         # NEW
│   │   ├── workspace.md
│   │   └── workspace.yml
│   ├── ingress/
│   ├── bootstrap/
│   ├── governance/
│   │   ├── policies/
│   │   ├── contracts/                   # populate, no longer placeholder
│   │   ├── ownership/
│   │   ├── support-targets.yml          # NEW
│   │   └── disclosure/
│   │       └── HarnessCard.yml          # NEW release-governed disclosure
│   ├── orchestration/
│   │   └── missions/
│   ├── capabilities/runtime/packs/
│   ├── assurance/runtime/
│   └── cognition/                       # informational-only during transition
├── state/
│   ├── control/
│   │   └── execution/
│   │       ├── runs/                    # NEW normalized run state
│   │       ├── missions/
│   │       ├── approvals/
│   │       ├── exception-leases/
│   │       ├── revocations/
│   │       └── budgets/
│   ├── continuity/
│   │   ├── repo/
│   │   ├── scopes/
│   │   ├── missions/
│   │   └── runs/                        # NEW
│   └── evidence/
│       ├── runs/
│       ├── control/execution/
│       ├── validation/
│       ├── lab/
│       ├── disclosure/runs/
│       ├── benchmarks/
│       └── external-index/
└── generated/
    ├── effective/
    ├── reports/                         # long-term replacement for summary sprawl
    └── projections/
```

Concrete restructuring decisions:

* **Preserve in place:** class roots, `octon.yml`, `engine/runtime/**`, `capabilities/**`, `orchestration/**`, `state/control/**`, `state/evidence/**`, `state/continuity/**`, overlay registry, portability profiles, release targets. ([GitHub][1])
* **Add:** `framework/constitution/`, `framework/lab/`, `framework/observability/`, `instance/charter/`, `instance/governance/support-targets.yml`, normalized run-state roots, disclosure roots.
* **Re-bound:** normative architecture and governance artifacts out of `framework/cognition/**` and `framework/agency/governance/**` into `framework/constitution/**`; `mission` into continuity/orchestration rather than atomic execution; `AI review` into assurance/lab evaluator adapters; GitHub approvals into host adapters.
* **Populate:** `instance/governance/contracts/**`, which is currently only a placeholder. ([GitHub][18])
* **Eventually rename or shrink:** `generated/cognition/**` into `generated/reports/**` and `generated/projections/**`; keep compatibility shims during transition because the current repo depends on those paths today. ([GitHub][1])

## G. Required Components and Contracts

Octon already has strong lower-level runtime contracts—intent contract, execution request, execution grant, execution receipt. The proposal preserves those and wraps them with a higher-order constitutional contract catalog. ([GitHub][19])

### 1. Harness Charter

* **Fields:** `charter_id`, `version`, `owner`, `purpose`, `non_goals`, `non_negotiables`, `fail_closed_rules_ref`, `evidence_obligations_ref`, `normative_precedence_ref`, `epistemic_precedence_ref`, `support_matrix_ref`, `amendment_policy`, `review_cadence`.
* **Semantics:** supreme repo-local constitutional artifact; no subsystem may override it.

### 2. Workspace Charter

* **Fields:** `workspace_id`, `version`, `owner`, `purpose`, `scope_in`, `scope_out`, `success_signals`, `protected_zones`, `default_risk_posture`, `default_change_profile_policy`, `review_cadence`, `related_support_targets`.
* **Semantics:** durable repo-wide objective and scope authority. It evolves the current workspace objective brief into a pair of human-readable and machine-readable artifacts. ([GitHub][15])

### 3. Mission Charter

* **Fields:** `mission_id`, `version`, `title`, `summary`, `mission_class`, `owner_ref`, `scope_ids`, `allowed_action_classes`, `risk_ceiling`, `default_oversight_mode`, `default_execution_posture`, `overlap_policy`, `success_criteria`, `failure_conditions`, `recovery_defaults`, `continuity_policy`, `status`.
* **Semantics:** long-horizon continuity, ownership, and autonomy posture object. It evolves `octon-mission-v2`, not replaces it. ([GitHub][2])

### 4. Run Contract

* **Fields:** `run_id`, `version`, `workspace_ref`, `mission_ref` (nullable), `trigger`, `objective_summary`, `scope_in`, `scope_out`, `done_when`, `acceptance_criteria`, `risk_class`, `reversibility_class`, `requested_capability_packs`, `protected_zones`, `required_approvals`, `required_evidence`, `expiry`, `created_by`, `approved_by`.
* **Semantics:** atomic execution unit. Mandatory for every material run. It does what mission and intent do not currently do: bind one actual execution to explicit authority and proof expectations.

### 5. ApprovalRequest

* **Fields:** `approval_request_id`, `run_ref`, `requested_by`, `action_classes`, `resource_scope`, `risk_class`, `reversibility_class`, `requested_window`, `rationale`, `quorum_policy_ref`, `evidence_prerequisites`, `status`.
* **Semantics:** canonical human/harness approval request artifact. Host UIs only adapt to and from it.

### 6. ApprovalGrant

* **Fields:** `approval_grant_id`, `approval_request_ref`, `grantors`, `quorum_satisfied`, `decision`, `granted_scope`, `capability_overrides`, `expiry`, `conditions`, `rollback_or_compensation_requirements`, `revocation_policy`.
* **Semantics:** portable approval artifact. GitHub labels/comments may mirror it but must not define it.

### 7. ExceptionLease

* **Fields:** `lease_id`, `run_ref`, `rule_relaxed`, `scope`, `owner`, `issued_at`, `expires_at`, `justification`, `compensation_constraints`, `renewal_policy`, `status`.
* **Semantics:** temporary, scoped relaxation under explicit owner accountability. Evolves current empty `exception-leases.yml` into a first-class system. ([GitHub][20])

### 8. DecisionArtifact

* **Fields:** `decision_id`, `subject_ref`, `route`, `reason_codes`, `remediation`, `policy_inputs`, `decision_engine_version`, `timestamp`, `linked_artifacts`.
* **Semantics:** canonical output of the authority engine. Replaces host-shaped approval facts as the true decision record.

### 9. Model Adapter Contract

* **Fields:** `adapter_id`, `version`, `provider`, `model_family`, `model_ids`, `tool_call_semantics`, `json_contract_strength`, `context_limits`, `cost_model_ref`, `latency_slo_defaults`, `caching_behavior`, `retry_policy`, `reset_policy`, `contamination_signatures`, `supported_workload_tiers`, `supported_locale_tiers`, `conformance_suite_refs`, `known_limitations`.
* **Semantics:** testable portability interface. Model support exists only when this contract passes conformance.

### 10. Capability / Tool Contract

* **Fields:** `capability_id`, `version`, `surface_type`, `side_effect_class`, `input_schema_ref`, `output_schema_ref`, `credential_scope`, `redaction_policy`, `approval_threshold`, `measurement_hooks`, `rollback_or_compensation_notes`, `support_target_refs`.
* **Semantics:** typed governed capability pack contract. Existing service/workflow/capability surfaces map into this higher-order contract. ([GitHub][16])

### 11. Run Manifest

* **Fields:** `run_id`, `attempt_id`, `run_contract_ref`, `mission_ref`, `model_adapter_ref`, `host_adapter_ref`, `worktree_ref`, `environment_class`, `instruction_layers`, `granted_capabilities`, `budget_envelope`, `start_timestamp`.
* **Semantics:** event-sourced runtime envelope for one execution attempt.

### 12. Checkpoint

* **Fields:** `checkpoint_id`, `run_ref`, `stage_ref`, `workspace_hash`, `open_items`, `next_action_hypothesis`, `verification_state`, `contamination_flags`, `resume_prerequisites`, `created_at`.
* **Semantics:** resumability artifact. Must support restart without chat history.

### 13. Continuity Artifact

* **Fields:** `continuity_id`, `scope_type` (`repo|scope|mission|run`), `scope_ref`, `summary`, `decisions`, `open_risks`, `handoff_requirements`, `linked_checkpoints`, `follow_on_work`, `updated_at`.
* **Semantics:** compact handoff state. Evolves current repo/mission continuity ledgers into normalized forms. ([GitHub][1])

### 14. Assurance Report

* **Fields:** `report_id`, `run_ref`, `plane` (`structural|functional|behavioral|maintainability|governance|recovery`), `checks_executed`, `evaluator_refs`, `hidden_check_refs`, `result`, `known_gaps`, `waivers`, `timestamp`.
* **Semantics:** normalized proof artifact across all planes.

### 15. Intervention Record

* **Fields:** `intervention_id`, `run_ref`, `actor`, `intervention_type`, `reason`, `before_after_refs`, `visibility`, `impact_on_outcome`, `timestamp`.
* **Semantics:** mandatory logging of human or privileged intervention.

### 16. Measurement Record

* **Fields:** `measurement_id`, `subject_ref`, `metric_class`, `method`, `window`, `value`, `thresholds`, `source_refs`, `timestamp`.
* **Semantics:** normalized cost, latency, recovery, drift, benchmark, and reliability metrics.

### 17. RunCard

* **Fields:** `run_ref`, `objective_summary`, `mission_ref`, `route_summary`, `adapters`, `capability_packs`, `assurance_summary`, `intervention_summary`, `cost_latency_summary`, `outcome`, `evidence_refs`.
* **Semantics:** minimal per-run disclosure artifact.

### 18. HarnessCard

* **Fields:** `harness_version`, `charter_version`, `support_matrix_ref`, `core_layers`, `authority_model_summary`, `runtime_model_summary`, `adapter_inventory`, `benchmark_suite_refs`, `intervention_policy`, `retention_model_ref`, `known_limitations`.
* **Semantics:** system-level disclosure artifact.

### 19. Evidence Retention Contract

* **Fields:** `artifact_class`, `storage_class` (`git_inline|git_pointer|external_immutable`), `retention_window`, `redaction_rules`, `hash_requirements`, `export_profile_behavior`, `deletion_policy`.
* **Semantics:** classifies what stays Git-tracked, what is pointered, and what externalizes.

## H. Control, Authority, and Governance Model

### Normative authority precedence

1. Non-waivable external obligations, emergency kill switches, and revocations.
2. Harness Charter and constitutional fail-closed rules.
3. Support-target matrix and governance policy families.
4. QuorumPolicy, ApprovalGrant, ExceptionLease, and Revocation artifacts for the subject run.
5. Workspace Charter.
6. Mission Charter.
7. Run Contract.
8. Capability/Tool contracts and model/host adapter contracts.
9. Repo architecture/spec artifacts.
10. Operating-practice guidance.
11. Generated reports and summaries.
12. Raw inputs, chat transcripts, and model priors.

This extends Octon’s current framework/instance/state/generated/inputs precedence and SSOT matrix into a fully explicit normative ladder. ([GitHub][3])

### Epistemic grounding precedence

1. Live runtime observations and validated receipts.
2. Deterministic verifier outputs and measurement records.
3. Current repo/worktree state.
4. Mutable `state/control/**` truth.
5. Freshness/receipt-valid `generated/effective/**` outputs.
6. Continuity artifacts with provenance.
7. Authored documentation and charters.
8. Operator comments and conversation history.
9. Model priors.

If runtime evidence conflicts with docs, runtime reality wins for facts; documentation drift becomes a governance and improvement issue, not a license to ignore facts. This is the dual-precedence split Octon currently lacks. ([GitHub][3])

### Route semantics

Octon should constitutionally standardize four routes:

* **ALLOW** — material execution may proceed within granted scope.
* **STAGE_ONLY** — non-effectful preparation, packetization, validation, and report generation may proceed, but no material side effect is allowed.
* **ESCALATE** — execution pauses pending approval or exception.
* **DENY** — fail closed; only safe observation or re-drafting is permitted.

This preserves Octon’s current execution-grant semantics and its existing use of `stage_only` for missing-cost-evidence cases. ([GitHub][11])

### Human / harness / model decision boundaries

* **Humans own:** charter changes, support-matrix changes, policy changes, ownership rules, one-way-door approvals, exception leases, revocations, public or external commitments, and final HarnessCard release sign-off.
* **Harness owns:** route evaluation, fail-closed enforcement, grant/receipt validation, checkpoint/replay integrity, intervention logging, disclosure assembly, and gating of execution against proof requirements.
* **Model owns:** bounded planning, draft run contracts, execution strategy within grants, low-risk local retries, and self-checks within explicitly allowed boundaries.
* **Model must not own:** approval, exception, revocation, support-target widening, irreversible action authorization, or final consequential acceptance.

This sharpens current repo practice, where approval and routing still partially depend on GitHub labels and workflow logic. ([GitHub][21])

### Approval and revocation rules

* Every material approval is represented by `ApprovalRequest` + `ApprovalGrant`.
* Every temporary policy relaxation is an `ExceptionLease`.
* Every invalidation is a `Revocation`.
* Host surfaces—GitHub labels/comments, CI inputs, Studio UI, CLI prompts—are adapters that project these artifacts; they are never the authority source.
* Existing ACP-2 / ACP-3 / ACP-4 quorum classes from mission-autonomy become default `QuorumPolicy` templates, generalized beyond missions. ([GitHub][17])

### Fail-closed rules

At minimum, Octon must deny or stage-only when any of these are missing or invalid: run contract, intent reference, mission autonomy context when required, valid approval or exception evidence, execution grant, required instruction-layer manifest, freshness receipts for required effective outputs, or support-target eligibility. Octon already fail-closes on many of these conditions; the proposal makes them constitutional rather than partly workflow-local. ([GitHub][22])

## I. Runtime, Continuity, and Evidence Model

### Runtime model

Octon’s correct runtime model is **event-sourced, run-first, and resumable from artifacts**. Every consequential execution becomes:

1. `Run Contract` drafted or derived from explicit trigger.
2. `Authority Route` computed.
3. `Run Manifest` bound with adapters, grants, and instruction layers.
4. `Execution Attempt` opened in isolated worktree/sandbox.
5. `Checkpoint` emitted at stage boundaries and before material effects.
6. `Assurance Reports` executed by required planes.
7. `RunCard` generated at closeout.
8. `Continuity Artifact` updated for repo/mission/run handoff.
9. `Replay Bundle` indexed with inline or external evidence pointers.

This extends current run evidence and mission control roots into a normalized execution lifecycle. ([GitHub][23])

### Mission and run relationship

* **Mission-backed runs** are required for recurring, scheduled, or always-on autonomy, and for any work that depends on overlap policy, mission continuity, or mission-specific autonomy posture.
* **Run-only autonomy** is legal for bounded one-shot work when continuity beyond the run is unnecessary.
* There is **no silent fallback** from mission-backed work into missionless execution. If mission is required by the run class, absence is a denial.
* The current `--mission-id` runtime path becomes one of several legal run-binding modes, not the only autonomous execution form. ([GitHub][16])

### Checkpoint, resume, contamination, and recovery

* Checkpoints are mandatory at material stage boundaries, before risky effects, before human approvals, and before context compaction.
* Resume must succeed from checkpoint + current authoritative surfaces, not from preserved chat history.
* Memory contamination detection should be promoted from the current memory contract into runtime enforcement. Octon should preserve the existing warning and flush thresholds as defaults, but enforce them through the engine and checkpoint system rather than only prose.
* Recovery posture becomes measurable: rollback path available, compensation path available, recovery window remaining, checkpoint-resume success, and safe-state restoration time. Existing receipt fields for rollback, compensation, recovery window, autonomy budget state, and breaker state should be preserved and lifted into run-level metrics. ([GitHub][24])

### Retry classes

* **Deterministic retry** — non-model runtime flake or transient infra issue.
* **Re-plan retry** — allowed when proof failed but authority remains valid.
* **Approval-blocked retry** — suspended until new grant or lease exists.
* **Recovery retry** — allowed only under declared rollback/compensation posture.
* **Contamination reset** — forced hard reset with checkpoint resume when working state is suspect.

### Evidence classes

Octon should formalize three evidence classes:

* **Class A — Git-inline control-plane evidence:** charter changes, workspace/mission charters, approvals, revocations, key decision artifacts, failure taxonomies, benchmark baselines, support targets, HarnessCard, selected RunCards.
* **Class B — Git-tracked pointer/manifests:** replay-critical manifests, run bundles, assurance summaries, external artifact indices, compact measurement summaries.
* **Class C — External immutable evidence:** raw model I/O, browser recordings, HAR files, screenshots, high-frequency event streams, distributed traces, and large telemetry payloads.

This fits Octon’s existing portability/export discipline, which already excludes `state/**` and `generated/**` from clean `repo_snapshot` and treats `full_fidelity` as a normal Git clone rather than a synthetic export. The target state preserves that discipline and adds replay manifests for externalized evidence. ([GitHub][9])

### What remains Git-tracked

Keep Git for low-volume, high-signal control-plane artifacts and disclosure summaries. Do **not** force raw telemetry, browser artifacts, or full event streams into Git. That would destroy reviewability and create entropy. Instead, keep a hash-addressed `external-index/` manifest in Git and treat external stores as replay backends. The target-state `repo_snapshot` should continue to exclude raw operational state by default; `full_fidelity` becomes Git clone + replay manifest + object-store restoration where needed. ([GitHub][1])

## J. Verification, Evaluation, and Lab Model

Octon should preserve its current structural and governance proof spine and add the missing planes rather than replacing what already works. Today it already has strong architecture-conformance, mission-runtime, lifecycle-cutover, effective-state, deny-by-default, and mission-generated-evidence workflows. Those should remain blocking structural/governance gates. ([GitHub][12])

The full proof model should have **six explicit planes**:

1. **Structural verification** — architecture conformance, schema validity, placement rules, publication freshness, capability/engine consistency.
2. **Functional verification** — service/workflow acceptance against declared contracts and run acceptance criteria.
3. **Behavioral verification** — scenario packs, UI/API flows, real-world task behaviors, hidden assertions.
4. **Maintainability verification** — doc freshness, drift suppression, bounded complexity, cleanup burden, contract hygiene.
5. **Governance verification** — route correctness, approval presence, exception scope, intervention completeness, protected-zone enforcement.
6. **Recovery verification** — checkpoint-resume, rollback or compensation, breaker behavior, safe-interrupt boundaries, time-to-safe-state.

That is the correct answer to the structural-vs-functional and behavioral-vs-maintainability blind spots. It keeps Octon’s current strength and fixes what is missing. ([GitHub][12])

### Self-checking vs independent evaluation

* **Self-checking is acceptable** for syntax, schema, local deterministic invariants, and stage-only dry-runs.
* **Independent evaluation is required** for consequential behavioral claims, user-visible outputs, public or external effects, support-target expansion, and benchmark claims.
* **Hidden checks** are required for benchmark and behavioral suites to prevent overfitting.
* **Evaluator diversity** should include deterministic validators, model-based evaluators from at least two adapter families where applicable, and lab-side probes for behavioral tasks.

Octon’s current AI review gate can be preserved as one evaluator adapter, but it must stop being primarily a PR-labeling workflow and become part of a generalized evaluator subsystem. It currently aggregates provider findings, uses OpenAI and Anthropic providers, and syncs labels such as `ai-gate:blocker`; that is useful evidence, but too host-shaped and too PR-centric for the target state. ([GitHub][25])

### Lab design

The lab is top-level because its job is discovery, not just validation. It should own:

* scenario packs for repo-local, repo+API, and repo+browser work;
* workload replay against prior run bundles;
* shadow runs that compare new adapters or policies without material effect;
* fault injection for authority, budget, egress, and capability surfaces;
* red-team/adversarial packs for policy evasion, replay gaps, and hidden-human leakage;
* telemetry probes that let Octon observe behavior under realistic drift, saturation, and interruption.

Current mission-autonomy live validation should migrate into `framework/lab/scenario-packs/mission-autonomy-live-validation/` and become one formal scenario pack among many. ([GitHub][2])

### Honest intervention disclosure

Every human edit, approval, waiver, repair, label sync, override, or emergency stop must produce an `InterventionRecord` linked into the run bundle. RunCards must summarize intervention counts and types. HarnessCards must disclose intervention policy and whether hidden human repair was permitted anywhere in the benchmark or support target. This closes the current invisible-supervision blind spot. ([GitHub][25])

## K. Portability, Adapters, and Support Targets

Octon should formalize a **portable kernel** and a set of explicitly non-portable adapters.

### Portable kernel

Portable across repos and model families:

* class-root super-root and SSOT rules,
* constitutional charter and precedence models,
* run contract / approval / decision / receipt / checkpoint / disclosure schemas,
* route semantics (`ALLOW/STAGE_ONLY/ESCALATE/DENY`),
* evidence retention classes,
* benchmark-plane taxonomy,
* lab contract surfaces,
* support-target matrix schema,
* build-to-delete discipline.

These are the parts Octon should treat as the real product. They are the long-term durable layer. Current portability profiles and cross-platform release targets already point in this direction. ([GitHub][9])

### Non-portable adapters

Allowed and expected to vary:

* model adapters,
* host adapters,
* provider-specific cost models,
* browser drivers and API connectors,
* capability packs,
* evaluator prompts and model-backed reviewer choices,
* repo-local overlay content,
* language/runtime support packs.

Current provider-specific budget rules and AI-gate provider list should move behind model-adapter contracts; current GitHub labels and workflow scripts should move behind host adapters. ([GitHub][26])

### Host adapters

Octon should explicitly support adapters such as:

* `github` — PRs, labels, checks, reviews, comments;
* `ci` — pipeline triggers, artifact uploads, environment metadata;
* `local-cli` — direct operator approval and inspection;
* `studio` — interactive UI surfaces;
* later, `chat` or `slack` only if they map cleanly into authority artifacts.

The rule is simple: the adapter renders or ingests canonical artifacts; it never defines them.

### Model adapters

Every supported model family must ship a Model Adapter Contract plus conformance evidence. Support is not “we tried it and it mostly works.” Support is “the adapter passed the conformance suite for its declared tiers.” Current provider-specific rules show why this is needed: they are workable, but they are still leaking provider details into the kernel. ([GitHub][26])

### Capability packs

Browser/UI and broader API surfaces should arrive as governed packs with:

* typed contracts,
* scoped credentials,
* redaction policy,
* measurement hooks,
* support-target declarations,
* approval thresholds,
* rollback/compensation posture.

This generalizes Octon’s current deny-by-default and network-egress discipline to broader action surfaces without weakening governance. ([GitHub][27])

### Support-target matrix

Octon should publish `instance/governance/support-targets.yml` with at least four axes:

* **Model tier:** frontier managed APIs, mid-tier APIs, local/self-hosted, deterministic-only fallback.
* **Workload tier:** read-only repo analysis, repo-local mutation, repo+browser/API action, long-running mission/incident autonomy.
* **Language/resource tier:** current reference profile (`markdown`, `yaml`, `bash`, `json`, `rust` in `.octon`), supported extension packs, experimental or low-resource modes.
* **Locale tier:** English-first reference, supported multilingual packs, unsupported/restricted locales.

The current locality scope already makes it clear Octon is operating within a reference envelope; the proposal simply makes that envelope explicit and governable. ([GitHub][13])

## L. Simplification, Deletion, and Evolution Model

### What stays stable

* class-root super-root,
* authored-authority vs operational-truth vs derived-output split,
* fail-closed root manifest posture,
* execution authorization boundary,
* `STAGE_ONLY` route,
* mission as continuity/ownership layer,
* state/control vs state/evidence vs state/continuity separation,
* structural/governance blocking checks,
* portability profiles and release-target discipline. ([GitHub][1])

### What stays replaceable

* model adapters,
* host adapters,
* evaluator providers,
* capability pack implementations,
* scaffolding prompts/templates,
* support tiers,
* profile defaults,
* UI/browser drivers,
* telemetry backends.

### What should be simplified or deleted from the current shape

1. **`architect` as the kernel identity** should become an `orchestrator` execution profile. “Architect” may remain a persona overlay if useful, but not the kernel default identity. The current manifest already points toward a single accountable default agent; preserve the accountability, simplify the persona. ([GitHub][14])

2. **`SOUL.md` and persona-heavy surfaces** should leave the kernel path unless they enforce a real boundary. They are acceptable as optional overlays, not constitutional dependency. The current ingress still names both execution and identity contracts; target-state ingress should not require identity/persona layers for safe execution. ([GitHub][28])

3. **Assistants/teams registries** should remain only if they back real isolation, quorum, or concurrency roles. If they are not load-bearing, remove them from the default critical path. The manifest already blocks arbitrary skill-actor delegation and disallows assistant mission ownership; build on that simplification. ([GitHub][14])

4. **GitHub labels as authority** must be deleted as a kernel assumption. Keep them only as host-adapter projections. Current `accept:human`, `ai-gate:blocker`, and `ai-gate:waive` logic should survive only as adapter glue. ([GitHub][21])

5. **Mission as mandatory execution atom** should be deleted. Replace it with “mission required for mission-class runs; run contract required for all material runs.” This preserves current mission-scoped autonomy where it belongs and removes an unnecessary global constraint. ([GitHub][3])

6. **Distributed constitutional prose** should be consolidated. Keep shims during migration, then retire duplicate constitutional statements in `cognition`, `agency/governance`, and bootstrap docs once the charter kernel exists. ([GitHub][3])

### Build-to-delete rules

Every new scaffold, prompt, policy workaround, evaluator trick, or host/provider adapter must carry:

* owner,
* justification,
* success metric,
* support-target scope,
* review date,
* deletion trigger.

After every model-family change or support-tier expansion, Octon should run an ablation review: if a compensating mechanism no longer improves structural, functional, behavioral, governance, or recovery outcomes, it is removed. This turns Octon’s current packetized migration habit into an explicit retirement discipline. ([GitHub][8])

## M. Major Architectural Moves

**Preserve**

* the super-root class model,
* fail-closed runtime posture,
* typed execution request/grant/receipt path,
* mission-autonomy policy concepts,
* control/evidence/continuity root separation,
* structural and governance CI gates. ([GitHub][1])

**Introduce**

* `framework/constitution/`,
* run contracts,
* approval/exception/revocation artifacts,
* authority engine,
* lab domain,
* observability/disclosure domain,
* RunCard and HarnessCard,
* support-target matrix,
* evidence-retention contract,
* model adapter contract.

**Re-bound**

* mission into continuity/orchestration,
* cognition’s normative material into constitution,
* AI review into evaluator infrastructure,
* GitHub labels into host adapters,
* agency into orchestrator + verifier/handoff primitives.

**Reverse**

* mission-as-only-autonomous-unit,
* label-centric approvals,
* provider-specific core governance,
* persona-first kernel identity,
* any assumption that structural conformance alone proves behavior.

**Delete**

* kernel dependence on `SOUL.md`,
* duplicated constitutional prose,
* unused assistants/teams from the critical path,
* host-specific approval semantics as authority,
* any generated summary being treated as source of truth.

**Postpone**

* large-scale naming cleanup for residual informational `cognition/**` until constitutional extraction is done,
* broad browser/API surface expansion until authority engine and evidence model are stable,
* support-target widening until model adapters and disclosure are live.

## N. Transition Program and Stabilization Order

### Phase 0 — Baseline freeze and constitutional inventory

**Work:** record current constitutional surfaces, runtime specs, CI gates, evidence roots, and adapter assumptions; publish a baseline internal HarnessCard v0.
**Acceptance criteria:** one canonical baseline packet exists; no hidden authority surfaces remain undocumented; current strong structural gates remain green.
**Why first:** Octon already has many strong pieces; the first step is to stop losing them during restructuring. ([GitHub][3])

### Phase 1 — Constitutional extraction

**Work:** create `framework/constitution/`; move charter, precedence, fail-closed rules, evidence obligations, and contract registry there; reduce `/.octon/AGENTS.md` and `instance/ingress/AGENTS.md` to a minimal constitutional ingress bundle; make old constitutional docs shims or references.
**Compatibility:** keep current paths readable; existing validators accept both old and new constitutional locations during the compatibility window.
**Acceptance criteria:** a single constitutional kernel exists; instruction-layer manifests for material runs include constitutional layers; no conflicting constitutional text remains authoritative. ([GitHub][29])

### Phase 2 — Objective and authority cutover

**Work:** add workspace charter pair, mission charter v3, run contract v1, ApprovalRequest/Grant, ExceptionLease, Revocation, and DecisionArtifact; implement authority engine crate and host-adapter projection.
**Compatibility:** autonomous workflow runs may temporarily derive run contracts from current mission + intent artifacts, but must emit explicit run contract refs in receipts; GitHub labels become mirrored projections of grants during the cutover.
**Acceptance criteria:** every material execution path has a bound run contract; labels are no longer the source of authority; unresolved authority fails closed or stage-only. ([GitHub][16])

### Phase 3 — Runtime and evidence normalization

**Work:** add normalized run manifests, checkpoints, run continuity, intervention records, measurement records, RunCards, and evidence-retention contract; create external replay index and immutable-store integration; evolve `budget-state` and `exception-leases` from thin files into real runtime surfaces.
**Compatibility:** dual-write current receipt roots and new run-bundle roots; mission control/evidence roots remain valid.
**Acceptance criteria:** a run can be resumed from artifacts alone; replay bundle pointers resolve; high-volume telemetry is externalized by class; every consequential run emits a RunCard. ([GitHub][30])

### Phase 4 — Proof expansion and lab introduction

**Work:** keep existing structural/governance workflows; add functional, behavioral, maintainability, and recovery suites; introduce `framework/lab/` with scenario packs, replay, shadow runs, faults, and red-team packs; convert the AI review gate into an evaluator adapter.
**Compatibility:** current architecture-conformance and deny-by-default gates stay blocking; lab starts advisory, then becomes required for target workload tiers.
**Acceptance criteria:** Octon has measurable proof on all benchmark planes; hidden-check policy exists; intervention records are mandatory; mission-autonomy live validation is a formal lab pack, not a one-off mission. ([GitHub][12])

### Phase 5 — Adapter and support-target hardening

**Work:** add model-adapter contracts and conformance suites; move provider-specific policies behind adapters; add host adapters; add support-target matrix and HarnessCard; introduce governed browser/API packs.
**Compatibility:** current OpenAI/Anthropic budget and AI-review surfaces continue as adapter implementations until replaced.
**Acceptance criteria:** new model families are unsupported until adapter conformance passes; browser/API packs cannot bypass authority routing; support-target matrix is published and enforced. ([GitHub][26])

### Phase 6 — Simplification and deletion

**Work:** rename kernel execution profile from `architect` to `orchestrator`; remove `SOUL.md` from default ingress; trim assistant/team registries from the kernel path unless load-bearing; remove mission-only execution assumption; remove label-as-authority assumptions.
**Compatibility:** keep aliases and shims during one deprecation window.
**Acceptance criteria:** default ingress is constitution + workspace + mission/run + continuity only; at least one persona-heavy surface and one host-specific authority path are deleted with no regression in benchmark planes. ([GitHub][14])

### Phase 7 — Build-to-delete governance

**Work:** add ablation workflow, retirement registry, and mandatory removal review after model or adapter upgrades.
**Acceptance criteria:** every new compensating mechanism carries a deletion trigger; every release reviews at least one candidate scaffold for removal; HarnessCard records what was removed and why.

## O. Risks, Tradeoffs, and Unresolved Questions

The main tradeoff is **architectural coherence vs migration complexity**. Octon already has a dense but capable control architecture. Extracting a constitution domain and introducing run contracts will temporarily increase duplication. That is acceptable, because the current alternative is worse: continuing to add features to a mission-centric, label-adapted, structurally strong but execution-fragmented harness. ([GitHub][3])

A second tradeoff is **Git reviewability vs evidence completeness**. Keeping everything in Git makes replay noisy and brittle; externalizing too much makes review opaque. The proposal resolves this by classing evidence rather than choosing one storage medium. The remaining open design choice is which immutable store and which retention windows Octon should standardize around. That is implementation uncertainty, not architectural uncertainty. ([GitHub][1])

A third tradeoff is **support honesty vs support ambition**. Publishing a strict support-target matrix will initially make Octon look narrower than generic agent frameworks. That is a feature, not a bug. Current locality and provider-specific budget surfaces already show that Octon has support assumptions; the matrix simply makes them explicit. ([GitHub][13])

Blind spots this proposal explicitly closes:

* structural vs functionality verification — separated planes;
* behavioral vs maintainability verification — separated planes;
* stale documentation detection — constitutional drift and doc-freshness checks;
* state drift — run/mission/control reconciler;
* memory contamination — runtime-enforced contamination detection and reset;
* context authority conflicts — dual precedence model;
* verifier overfitting — hidden checks, evaluator diversity, held-out suites;
* hidden human repair / invisible supervision — mandatory intervention records and disclosure;
* governance opacity — canonical authority artifacts and published HarnessCard;
* portability vs local optimization — portable kernel + explicit adapters;
* transferability across model families — Model Adapter Contract and conformance gating;
* harness-specific overfitting — lab replay and multi-repo support targets;
* evaluation validity — multi-plane benchmarks plus RunCard/HarnessCard;
* recovery quality — dedicated proof and measurement plane;
* topology/service-template implications — support-target matrix plus pack model;
* constrained-runtime implications — capability packs and route classes;
* rollout/adoption implications — phased cutover with shims and compatibility windows;
* multilingual / low-resource / non-frontier applicability — explicit support tiers, not implied universality;
* long-term entropy management — retirement registry and deletion reviews;
* resilience under stronger models — adapter evolution and build-to-delete ablations;
* what should be built to delete — persona-heavy kernel docs, label-native authority, provider-specific core logic, mission-only execution assumption. ([GitHub][24])

What remains genuinely open is mostly implementation detail: exact external replay store, exact threshold between run-only and mission-backed autonomy, and whether the remaining informational `cognition/**` domain should ultimately be renamed or only de-normativized. None of those should block the constitutional cutover.

## P. Final Recommendation

The single best path is:

**Do not grow Octon sideways. Constitutionalize it.**

Preserve the super-root, the fail-closed engine boundary, the typed execution request/grant/receipt path, the mission continuity model, and the current structural/governance proof spine. Then make one decisive architectural cut:

1. extract a constitutional kernel,
2. make run contracts atomic,
3. centralize authority into one engine,
4. normalize runtime and evidence around replayable run bundles,
5. add lab-grade behavioral proof and disclosure,
6. simplify agency and delete host/provider-specific authority assumptions.

If Octon does those six things, it stops being an unusually well-structured repo harness and becomes what it is architecturally trying to be already: **a fully unified execution constitution for governed autonomous work**. ([GitHub][1])

[1]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/README.md "raw.githubusercontent.com"
[2]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/orchestration/missions/mission-autonomy-live-validation/mission.yml "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/orchestration/missions/mission-autonomy-live-validation/mission.yml"
[3]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/_meta/architecture/specification.md "raw.githubusercontent.com"
[4]: https://raw.githubusercontent.com/jamesryancooper/octon/main/README.md "raw.githubusercontent.com"
[5]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/README.md "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/README.md"
[6]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/manifest.yml "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/manifest.yml"
[7]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/engine/runtime/config/policy-interface.yml "octon/.octon/framework/engine/runtime/config/policy-interface.yml at main · jamesryancooper/octon · GitHub"
[8]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/state/continuity/repo/tasks.json "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/state/continuity/repo/tasks.json"
[9]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/octon.yml "raw.githubusercontent.com"
[10]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/execution-request-v2.schema.json "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/execution-request-v2.schema.json"
[11]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json"
[12]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.github/workflows/architecture-conformance.yml "https://raw.githubusercontent.com/jamesryancooper/octon/main/.github/workflows/architecture-conformance.yml"
[13]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/locality/scopes/octon-harness/scope.yml "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/locality/scopes/octon-harness/scope.yml"
[14]: https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/manifest.yml "https://github.com/jamesryancooper/octon/blob/main/.octon/framework/agency/manifest.yml"
[15]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/bootstrap/OBJECTIVE.md "raw.githubusercontent.com"
[16]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/crates/kernel/src/main.rs "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/crates/kernel/src/main.rs"
[17]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/policies/mission-autonomy.yml "raw.githubusercontent.com"
[18]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/contracts/README.md "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/contracts/README.md"
[19]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/intent-contract-v1.schema.json "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/intent-contract-v1.schema.json"
[20]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/state/control/execution/exception-leases.yml "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/state/control/execution/exception-leases.yml"
[21]: https://github.com/jamesryancooper/octon/blob/main/.github/workflows/pr-autonomy-policy.yml "https://github.com/jamesryancooper/octon/blob/main/.github/workflows/pr-autonomy-policy.yml"
[22]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/policy-interface-v1.md "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/policy-interface-v1.md"
[23]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/_meta/architecture/contract-registry.yml "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/_meta/architecture/contract-registry.yml"
[24]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/agency/governance/MEMORY.md "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/agency/governance/MEMORY.md"
[25]: https://github.com/jamesryancooper/octon/blob/main/.github/workflows/ai-review-gate.yml "https://github.com/jamesryancooper/octon/blob/main/.github/workflows/ai-review-gate.yml"
[26]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/policies/execution-budgets.yml "raw.githubusercontent.com"
[27]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/policies/network-egress.yml "raw.githubusercontent.com"
[28]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/ingress/AGENTS.md "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/ingress/AGENTS.md"
[29]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/AGENTS.md "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/AGENTS.md"
[30]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/state/control/execution/budget-state.yml "https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/state/control/execution/budget-state.yml"

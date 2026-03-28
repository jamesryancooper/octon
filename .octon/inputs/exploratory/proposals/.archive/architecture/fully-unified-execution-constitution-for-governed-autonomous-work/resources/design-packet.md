# Fully Unified Execution Constitution for Governed Autonomous Work Design Packet

## A. Executive Design Packet Thesis

Octon should preserve its strongest current structural asset—the `.octon/` class-root super-root with authored authority in `framework/**` and `instance/**`, operational truth in `state/**`, rebuildable outputs in `generated/**`, and a fail-closed runtime boundary rooted in engine-owned authorization—and convert that structure into a **fully unified execution constitution**. Today the repository already has real constitutional material, a typed runtime seam, mission-scoped autonomy policy, retained continuity/evidence roots, and strong structural/governance CI gates. What it does not yet have is one unified regime that makes **run-level objective binding, authority routing, runtime lifecycle, proof, intervention accounting, replay, and disclosure mandatory on every consequential execution**. ([GitHub][1])

The target state in this packet is therefore not “more agents,” “more prompts,” or “a nicer workflow wrapper.” It is a **constitutional, contract-governed control plane for autonomous work** with a stable portable kernel and explicit non-portable adapters. Mission remains a first-class continuity and governance object, but **run contracts become the atomic execution unit**. GitHub labels become host-adapter projections rather than authority. Evidence becomes classed. Behavioral proof moves into a top-level lab domain. Model support becomes adapter-conformance rather than aspiration. RunCard and HarnessCard become required disclosure artifacts. Persona-heavy agency surfaces leave the kernel path unless they provide real boundary value. ([GitHub][1])

This packet turns the prior proposal into an implementation-grade program: exact repository deltas, contract catalog, constitutional kernel, authority model, runtime model, proof model, disclosure model, staged cutovers, compatibility windows, and phase exit criteria. The standard for success is not “Octon looks directionally better.” The standard is that Octon can validly claim to be a **fully unified execution constitution** because the repository structure, runtime, authority, proof, replay, and disclosure surfaces all enforce that claim. ([GitHub][1])

## B. Repository-Grounded Baseline

Octon today is a **repository constitution with an emerging executable kernel**. The live repo defines a single authoritative `.octon/` super-root with class-first top-level roots: `framework/` for portable authored core, `instance/` for repo-specific durable authority, `inputs/` for non-authoritative additive/exploratory inputs, `state/` for operational truth and retained evidence, and `generated/` for rebuildable outputs only. Only `framework/**` and `instance/**` are authored authority, raw `inputs/**` are barred from direct runtime or policy participation, and `generated/**` is explicitly non-authoritative. The root manifest is already fail-closed and drives profile-based portability rather than raw tree copying. ([GitHub][1])

The repo already has real runtime and authority seams. `framework/engine/runtime/README.md` says `runtime/` contains executable runtime artifacts only. The kernel CLI exposes services, one-shot tool invocation, workflow execution, stdio serving, Studio launch, and read-only orchestration inspection. The engine-owned execution-authorization spec requires all material execution to pass through `authorize_execution(request) -> GrantBundle`, and the current request/receipt contracts already carry requested capabilities, side-effect flags, workflow mode, mission/autonomy context, intent references, policy mode, decisions, rollback/compensation handles, recovery windows, and budget/breaker state. ([GitHub][2])

Octon also already has stronger durable control than most harness repos. The umbrella architecture spec, `.octon/README.md`, the instance manifest, and the overlay registry define authoritative classes, legal overlay points, merge modes, canonical ingress/bootstrap/state/evidence roots, runtime trust in `generated/effective/**` only when freshness and receipts are valid, and thin adapter rules for repo-root `AGENTS.md`/`CLAUDE.md`. The instance manifest enables only four overlay points today: governance policies, governance contracts, agency runtime, and assurance runtime. ([GitHub][1])

Governance is materially real already. The runtime policy interface binds the engine to deny-by-default policy, intent contracts, instruction-layer manifest schema, repo network-egress policy, execution-budget policy, mission-autonomy policy, ownership registry, mission registry, budget state, exception leases, mission control roots, and control/evidence roots. The network-egress policy presently allows only a localhost LangGraph HTTP forwarding path. The mission-autonomy policy already defines oversight defaults, execution postures, overlap rules, recovery windows, safe-interrupt boundaries, autonomy-burn thresholds, circuit breakers, quorum classes, and safing subsets. ([GitHub][3])

CI already protects structural and governance integrity. `architecture-conformance.yml` runs mission-runtime contract validation, runtime-effective-state validation, mission-autonomy scenarios, and generated mission-view/control-evidence validation. `deny-by-default-gates.yml` checks protected execution posture, validates capability/engine consistency, and uploads protected-execution receipts into `state/evidence/runs/ci/**`. `pr-autonomy-policy.yml` still uses `accept:human` for high-impact changes, and `ai-review-gate.yml` still syncs `ai-gate:blocker` labels and runs provider-specific reviewers for OpenAI and Anthropic. Those workflows show serious enforcement, but they also show that host-shaped approval semantics and provider-shaped evaluator logic are still in the kernel path today. ([GitHub][4])

The strongest current assets are therefore: the super-root and class-root regime; explicit authored-authority vs state vs generated boundaries; fail-closed runtime posture; typed execution authorization and receipts; mission-scoped autonomy policy; continuity/evidence/control roots; and structural/governance CI. The main current gaps are equally clear: the intent layer is still explicitly incomplete in the backlog; governance contracts overlays are reserved but effectively unpopulated; budget state and exception leases are skeletal; ownership is thinly populated; mission is still treated as the canonical autonomous operating model; approvals are still partly label-shaped; and behavioral, recovery, and disclosure architecture lag behind structural conformance. ([GitHub][1])

Repository reality also still differs from target-state aspiration in one important way: the current super-root contract says no autonomous runtime path may silently fall back to mission-less execution. The proposal in this thread deliberately refines that: **mission-backed execution remains mandatory for mission-class work, but bounded run-only autonomy becomes legal for explicitly supported workload tiers**. That is an intentional target-state change, not a current fact. ([GitHub][1])

I re-grounded this packet in the live repo surfaces above, but I did **not** line-audit every Rust crate or every shell validator. Where I specify implementation deltas inside crates or scripts not fully inspected, treat those as design decisions anchored to the visible repo seams rather than verbatim descriptions of hidden internals.

## C. Proposal Design Principles

1. **Preserve the class-root super-root.** The `framework / instance / inputs / state / generated` split is already correct and remains permanent.
2. **Unify the constitution.** Current constitutional material is real but fragmented; the target state makes it singular and supreme.
3. **Make run contracts atomic.** Workspace charter and mission charter remain durable authority; run contracts become the execution atom.
4. **Keep fail-closed routing, including `STAGE_ONLY`.** Octon’s current routing posture is a strength and should be generalized, not weakened.
5. **Keep authority outside host glue.** Labels, PR state, comments, and chat affordances become adapters, never authority.
6. **Keep execution, verification, and authority separate.** No single loop may generate, authorize, and accept consequential work.
7. **Preserve structural/governance proof, then add the missing planes.** Functional, behavioral, maintainability, and recovery proof are additive, not replacements.
8. **Class evidence.** Git remains for low-volume, high-signal control-plane evidence; replay-heavy telemetry externalizes.
9. **Constrain support claims.** Octon must publish what it supports by model tier, workload tier, language/resource tier, and locale tier.
10. **Simplify the agency kernel.** Preserve routing, ownership, delegation, and memory discipline; demote persona-heavy surfaces unless they enforce a real boundary.
11. **Build to delete.** Every compensating mechanism must carry a retirement trigger and ablation path. ([GitHub][1])

## D. Unified Execution Constitution

The constitutional kernel Octon should become is a **single repo-local supreme control regime** that unifies: charter, objective binding, authority routing, runtime lifecycle, proof obligations, intervention accounting, replay, disclosure, and deletion discipline. The current repo already distributes these functions across `octon.yml`, `.octon/README.md`, the umbrella specification, ingress, agency governance docs, runtime policy interface, mission-autonomy policy, and CI gates. The target state consolidates them into a new domain, `framework/constitution/**`, while preserving the current super-root and engine seams. ([GitHub][1])

The constitutional kernel should contain these canonical artifacts:

* `framework/constitution/CHARTER.md`
* `framework/constitution/charter.yml`
* `framework/constitution/precedence/normative.yml`
* `framework/constitution/precedence/epistemic.yml`
* `framework/constitution/obligations/fail-closed.yml`
* `framework/constitution/obligations/evidence.yml`
* `framework/constitution/ownership/roles.yml`
* `framework/constitution/contracts/**`
* `framework/constitution/support-targets.schema.json`

Its non-negotiable rules should be:

* No material execution without a bound run contract.
* No material side effect before authority routing and grant issuance.
* No host surface may become authority.
* No external UI, chat transcript, or in-memory state may become a second control plane.
* Raw `inputs/**` never become direct runtime or policy dependencies.
* `generated/**` remains derived-only.
* Every consequential run emits replayable evidence and disclosure artifacts.
* Hidden human repair is forbidden.
* Unsupported support tiers fail closed.
* Every compensating mechanism must carry retirement metadata.

This is the move from a **repository constitution** to an **execution constitution**. ([GitHub][1])

## E. Target-State Layered Architecture

### 1. Design Charter / Constitutional Layer

* **Purpose:** define what Octon is, what it is for, what it is not, and which obligations are kernel-grade.
* **Responsibilities:** constitutional precedence, amendment policy, fail-closed rules, evidence obligations, authority-role taxonomy, support-target declaration.
* **Inputs:** current `octon.yml`, umbrella architecture spec, ingress stack, agency governance docs, runtime specs, governance policies.
* **Outputs:** constitutional manifest set, precedence matrices, obligations, role maps, contract registry.
* **State ownership:** `framework/constitution/**` is authored core; `instance/governance/contracts/**` may overlay only declared extension points.
* **Boundary conditions:** prompts and ingress adapters may project the constitution, never redefine it.
* **Interaction:** consumed by authority engine, runtime manifest builder, assurance, disclosure.
* **Current anchor surfaces:** `octon.yml`, `.octon/README.md`, the umbrella architecture spec, and canonical ingress already express fragments of this layer; the proposal consolidates them. ([GitHub][1])

### 2. Intent / Objective Layer

* **Purpose:** bind work through four levels: workspace charter, mission charter, run contract, execution attempt/stage.
* **Responsibilities:** scope, exclusions, done-when, acceptance criteria, risk/materiality, reversibility, protected zones, capability requests, required evidence.
* **Inputs:** workspace objective, active intent contract, mission registry/charters, operator or automation triggers.
* **Outputs:** authored workspace charter, mission charter, runtime-issued run contract, stage contracts.
* **State ownership:** workspace and mission charters are durable authored authority; run and stage contracts are runtime control artifacts.
* **Boundary conditions:** all material runs require run contracts; mission is required only for mission-class work.
* **Interaction:** authority engine routes on run contract; runtime and assurance bind to its fields.
* **Current anchor surfaces:** current ingress already reads `OBJECTIVE.md` and an intent contract; mission charters already exist; the missing piece is the normalized run contract. ([GitHub][5])

### 3. Durable Control Layer

* **Purpose:** keep control durable, explicit, and versioned.
* **Responsibilities:** preserve class-root boundaries, root ingress discipline, overlay declarations, authored specs, schemas, ADRs, continuity artifacts, and compiled effective views.
* **Inputs:** framework and instance manifests, overlay registry, contract registry, repo-authored decisions.
* **Outputs:** authoritative control surfaces and freshness-bounded effective outputs.
* **State ownership:** `framework/**` and `instance/**` remain authored authority; `state/**` remains mutable operational truth; `generated/**` remains rebuildable.
* **Boundary conditions:** normative control and informative documentation must be distinguished; compiled effective views never become authored authority.
* **Interaction:** runtime trusts only canonical authored surfaces or receipt/freshness-bounded effective outputs.
* **Current anchor surfaces:** this is already Octon’s strongest implemented layer. The major addition is the dual precedence split between normative authority and epistemic grounding. ([GitHub][1])

### 4. Policy / Authority Layer

* **Purpose:** turn policies, ownership, approvals, exceptions, and support tiers into route decisions.
* **Responsibilities:** classify action, evaluate risk/reversibility, resolve owners, require approvals, issue grants, apply leases and revocations, compute `ALLOW / STAGE_ONLY / ESCALATE / DENY`.
* **Inputs:** run contract, mission charter, policy families, ownership registry, approval artifacts, exception leases, revocations, adapter constraints.
* **Outputs:** ApprovalRequest, ApprovalGrant, ExceptionLease, Revocation, DecisionArtifact, GrantBundle.
* **State ownership:** humans own policy content and approvals; harness owns route evaluation and enforcement.
* **Boundary conditions:** unresolved ownership, invalid intent, missing evidence, unsupported support tier, or policy ambiguity fail closed or downgrade to `STAGE_ONLY`.
* **Interaction:** mandatory gate before any material capability invocation.
* **Current anchor surfaces:** the runtime policy interface, execution-authorization spec, mission-autonomy policy, ownership registry, and label-based PR workflow show the current ingredients that must be unified here. ([GitHub][3])

### 5. Agency Layer

* **Purpose:** provide mediated execution through a small set of roles with real boundary value.
* **Responsibilities:** orchestration, bounded delegation, handoff packets, local deterministic self-checks, capability invocation.
* **Inputs:** run contract, grant bundle, continuity artifacts, model adapter, capability packs.
* **Outputs:** execution requests, stage plans, handoffs, local findings.
* **State ownership:** agency manifest, role profiles, handoff contracts, memory discipline.
* **Boundary conditions:** sub-agents only for separation of duties, context isolation, or concurrency; persona-only surfaces are overlays, not kernel authority.
* **Interaction:** orchestrator drives runtime; verifier/evaluator roles sit outside execution authority.
* **Current anchor surfaces:** current agency manifest already defaults to one agent, disallows skill-actor delegation, and limits mission ownership; ingress still ties execution to `architect` + `SOUL`, which should be simplified. ([GitHub][6])

### 6. Runtime Layer

* **Purpose:** manage long-running work as a lifecycle rather than a conversation.
* **Responsibilities:** run binding, worktree/sandbox creation, checkpointing, resume, compaction/reset, retry classification, rollback/compensation posture, replay bundle assembly.
* **Inputs:** run contract, grant bundle, mission context, adapters, continuity artifacts, support-target matrix.
* **Outputs:** run manifest, execution attempts, stage contracts, checkpoints, receipts, continuity artifacts, measurements, RunCard.
* **State ownership:** runtime engine owns state transitions; `state/control/execution/runs/**` owns live run control; `state/evidence/runs/**` owns retained run evidence.
* **Boundary conditions:** no resumption depends on chat continuity; mission-backed execution and run-only execution are both explicit modes; contamination can force hard reset.
* **Interaction:** authority gates stages; assurance gates closure; observability assembles replay and disclosure.
* **Current anchor surfaces:** the kernel CLI, execution request/receipt schemas, continuity/control/evidence roots, and current mission control model provide the substrate. ([GitHub][7])

### 7. Verification / Evaluation Layer

* **Purpose:** prove different properties separately.
* **Responsibilities:** structural, functional, behavioral, maintainability, governance, and recovery proof; deterministic validators; independent evaluators; hidden-check support.
* **Inputs:** code/artifacts, run bundle, contracts, effective views, telemetry, scenario packs.
* **Outputs:** assurance reports by plane, blocking failures, benchmark records.
* **State ownership:** `framework/assurance/**` for validators and evaluator contracts; `instance/assurance/runtime/**` for repo overlays.
* **Boundary conditions:** self-checking is limited to local deterministic checks; consequential acceptance requires deterministic proof or independent evaluation.
* **Interaction:** feeds authority, disclosure, and improvement.
* **Current anchor surfaces:** architecture-conformance and deny-by-default workflows are strong structural/governance proof; functional, behavioral, and recovery proof need to be added as first-class peers. ([GitHub][4])

### 8. Lab / Experimentation Layer

* **Purpose:** discover behavior the library side cannot prove.
* **Responsibilities:** scenario packs, workload replay, shadow runs, fault injection, red-team experiments, cross-system validation, telemetry probes.
* **Inputs:** run bundles, replay pointers, adapters, scenario definitions, probe configs.
* **Outputs:** behavioral audits, robustness findings, new hidden checks, support-target evidence.
* **State ownership:** `framework/lab/**` plus `state/evidence/lab/**`.
* **Boundary conditions:** lab is top-level and distinct from assurance because it explores unknown failure modes.
* **Interaction:** feeds new suites into assurance and new guardrails into governance.
* **Current anchor surfaces:** the current live mission and autonomy scenario tests are seeds for this domain, but they are not yet a domain in their own right. ([GitHub][8])

### 9. Governance / Safety Layer

* **Purpose:** keep Octon governable in practice.
* **Responsibilities:** approval, exception leasing, revocation, intervention logging, reversibility policy, recovery windows, one-way-door classification, misuse constraints.
* **Inputs:** authority decisions, mission posture, support matrix, intervention events.
* **Outputs:** approved/denied transitions, intervention records, accountability trails.
* **State ownership:** `instance/governance/**` for repo policy; `state/control/execution/**` and `state/evidence/control/execution/**` for live artifacts.
* **Boundary conditions:** one-way-door and externally binding actions always require stronger approval than repo-local reversible work.
* **Interaction:** interlocks with runtime, authority engine, assurance, and disclosure.
* **Current anchor surfaces:** mission-autonomy, network-egress, execution-budget, ownership, PR policy, and AI gate show the current fragments of this layer. ([GitHub][9])

### 10. Observability / Reporting Layer

* **Purpose:** make runs replayable and claims interpretable.
* **Responsibilities:** event schemas, replay bundles, measurement records, failure taxonomy, RunCards, HarnessCards, benchmark disclosure.
* **Inputs:** runtime events, grants/receipts, assurance reports, intervention records, external evidence pointers.
* **Outputs:** run bundles, replay manifests, RunCards, HarnessCards, benchmark packets.
* **State ownership:** `framework/observability/**` contracts; `state/evidence/**` retention; external immutable stores for high-volume traces.
* **Boundary conditions:** summaries remain derived; disclosure artifacts must be minimal but sufficient for operational and scientific interpretation.
* **Interaction:** consumed by operators, reviewers, evaluators, and improvement processes.
* **Current anchor surfaces:** Octon already retains evidence and CI receipts in `state/evidence/**`, but disclosure and replay are not yet normalized. ([GitHub][1])

### 11. Improvement / Evolution Layer

* **Purpose:** improve the harness while deleting obsolete scaffolding.
* **Responsibilities:** failure harvesting, stale-doc detection, state drift detection, governance drift detection, rule promotion, adapter evolution, ablations, retirement.
* **Inputs:** continuity logs, tasks, measurements, replay bundles, benchmark results, intervention records.
* **Outputs:** ADRs, migration packets, contract revisions, support-target updates, deletion proposals.
* **State ownership:** repo continuity surfaces and constitutional change workflow.
* **Boundary conditions:** no compensating mechanism without owner, metric, and retirement trigger.
* **Interaction:** closes the loop from runtime and proof back into constitution and adapters.
* **Current anchor surfaces:** the continuity/task system already shows a packetized migration culture and explicit pending intent-layer work; the proposal formalizes that into a permanent evolution model. ([GitHub][10])

## F. Proposed Repository and Boundary Restructuring

Keep the `.octon/` super-root and the five class roots exactly as they are. The restructuring happens **inside** those classes. The goal is to consolidate authority, normalize execution artifacts, and add missing top-level domains without disturbing the class-root regime that is already correct. ([GitHub][1])

Proposed target-state shape:

```text
.octon/
├── octon.yml                                # preserve as bootstrap/topology manifest
├── framework/
│   ├── constitution/                       # NEW constitutional kernel
│   │   ├── CHARTER.md
│   │   ├── charter.yml
│   │   ├── precedence/
│   │   │   ├── normative.yml
│   │   │   └── epistemic.yml
│   │   ├── obligations/
│   │   │   ├── fail-closed.yml
│   │   │   └── evidence.yml
│   │   ├── ownership/roles.yml
│   │   ├── support-targets.schema.json
│   │   └── contracts/
│   │       ├── objective/
│   │       ├── authority/
│   │       ├── runtime/
│   │       ├── adapters/
│   │       ├── disclosure/
│   │       └── retention/
│   ├── agency/
│   │   ├── manifest.yml                    # preserve, simplify semantics
│   │   ├── profiles/
│   │   │   ├── orchestrator/
│   │   │   └── verifier/
│   │   ├── routing/
│   │   └── handoff/
│   ├── assurance/
│   │   ├── structural/
│   │   ├── functional/
│   │   ├── governance/
│   │   ├── recovery/
│   │   └── evaluators/
│   ├── capabilities/
│   │   ├── contracts/
│   │   └── packs/
│   │       ├── repo/
│   │       ├── git/
│   │       ├── shell/
│   │       ├── browser/                    # NEW governed packs
│   │       ├── api/                        # NEW governed packs
│   │       └── telemetry/
│   ├── engine/
│   │   └── runtime/
│   │       ├── adapters/
│   │       │   ├── hosts/
│   │       │   │   ├── github/
│   │       │   │   ├── ci/
│   │       │   │   ├── local-cli/
│   │       │   │   └── studio/
│   │       │   └── models/
│   │       │       ├── openai/
│   │       │       ├── anthropic/
│   │       │       └── local/
│   │       ├── spec/
│   │       └── crates/
│   │           ├── kernel/                 # preserve
│   │           ├── core/                   # preserve
│   │           ├── policy_engine/          # preserve
│   │           ├── authority_engine/       # NEW
│   │           ├── replay_store/           # NEW
│   │           └── telemetry_sink/         # NEW
│   ├── lab/                                # NEW top-level domain
│   │   ├── scenario-packs/
│   │   ├── replay/
│   │   ├── shadow/
│   │   ├── faults/
│   │   ├── red-team/
│   │   └── telemetry-probes/
│   ├── observability/                      # NEW top-level domain
│   │   ├── schemas/
│   │   ├── replay/
│   │   ├── disclosure/
│   │   ├── measurements/
│   │   └── failure-taxonomy/
│   ├── orchestration/                      # preserve, mission becomes continuity object
│   ├── overlay-points/                     # preserve
│   └── scaffolding/                        # preserve
├── instance/
│   ├── charter/                            # NEW
│   │   ├── workspace.md
│   │   └── workspace.yml
│   ├── ingress/                            # preserve, slim
│   ├── bootstrap/                          # preserve, slim
│   ├── governance/
│   │   ├── policies/                       # preserve
│   │   ├── contracts/                      # populate
│   │   ├── ownership/                      # preserve
│   │   ├── support-targets.yml             # NEW
│   │   └── disclosure/
│   │       └── HarnessCard.yml             # NEW authored disclosure source
│   ├── orchestration/
│   │   └── missions/                       # preserve mission charters
│   ├── capabilities/runtime/packs/         # NEW repo-specific capability overlays
│   └── assurance/runtime/                  # preserve overlay point
├── state/
│   ├── control/
│   │   └── execution/
│   │       ├── runs/                       # NEW canonical live run control
│   │       ├── missions/                   # preserve
│   │       ├── approvals/                  # NEW
│   │       ├── exception-leases/           # evolve from single file
│   │       ├── revocations/                # NEW
│   │       └── budgets/                    # evolve from single file
│   ├── continuity/
│   │   ├── repo/                           # preserve
│   │   ├── scopes/                         # preserve
│   │   ├── missions/                       # preserve
│   │   └── runs/                           # NEW
│   └── evidence/
│       ├── runs/                           # preserve, normalize by run id
│       ├── control/execution/              # preserve
│       ├── validation/                     # preserve
│       ├── lab/                            # NEW
│       ├── disclosure/runs/                # NEW
│       ├── disclosure/releases/            # NEW
│       ├── benchmarks/                     # NEW
│       └── external-index/                 # NEW external evidence pointers
└── generated/
    ├── effective/                          # preserve
    ├── reports/                            # NEW long-term replacement for summary sprawl
    └── projections/                        # NEW long-term replacement for mixed cognition outputs
```

Path-specific restructuring decisions:

* **Preserve:** `.octon/octon.yml`, `.octon/README.md`, `framework/engine/runtime/**`, `framework/capabilities/**`, `framework/orchestration/**`, `framework/overlay-points/**`, `state/control/**`, `state/continuity/**`, and `state/evidence/**` as the macro-structure. ([GitHub][1])
* **Add:** `framework/constitution/**`, `framework/lab/**`, `framework/observability/**`, `instance/charter/**`, `instance/governance/support-targets.yml`, normalized run state under `state/control/execution/runs/**`, run continuity under `state/continuity/runs/**`, and disclosure roots under `state/evidence/disclosure/**`.
* **Re-bound:** move normative architecture material out of `framework/cognition/_meta/architecture/**` into `framework/constitution/**`; move repo-wide governance semantics out of agency/governance docs into the constitutional kernel; move mission from execution atom to continuity object; move AI review from PR-host workflow semantics into evaluator adapters. ([GitHub][11])
* **Populate:** `instance/governance/contracts/**`, which is currently only a reserved overlay directory. ([GitHub][12])
* **Simplify:** `instance/ingress/AGENTS.md` so it references the constitutional kernel and minimal role profiles, not persona-heavy execution identity. Today it still binds execution to `architect/AGENT.md` and `architect/SOUL.md`. ([GitHub][13])
* **Eventually rename or shrink:** `generated/cognition/**` into `generated/reports/**` and `generated/projections/**`, keeping compatibility shims for one deprecation window because current runtime and docs still reference those families. ([GitHub][1])

## G. Required Components and Contract Catalog

Contract lifecycle classes:

* **Authored constitutional contracts:** human-reviewed, versioned in `framework/**` or `instance/**`, compiled into effective views, immutable between approved amendments.
* **Runtime control contracts:** created or updated by the engine under `state/control/**`, mutable until closeout, then locked by evidence receipts.
* **Evidence and disclosure contracts:** emitted into `state/evidence/**` and optionally projected into `generated/**`; immutable once finalized.
* **External replay payloads:** stored outside Git, referenced through content-hashed manifests in `state/evidence/external-index/**`. ([GitHub][1])

### 1. Harness Charter

* **Fields:** `charter_id`, `version`, `owner`, `purpose`, `non_goals`, `non_negotiables`, `fail_closed_rules_ref`, `evidence_obligations_ref`, `normative_precedence_ref`, `epistemic_precedence_ref`, `support_targets_ref`, `amendment_policy`, `review_cadence`.
* **Semantics:** supreme repo-local constitutional artifact.
* **Lifecycle:** authored, reviewed, versioned; changes require explicit constitutional amendment workflow.
* **Ownership:** human governance owners only.
* **Authoring location:** `framework/constitution/CHARTER.md`, `framework/constitution/charter.yml`.
* **Runtime projection:** `generated/effective/constitution/charter.yml`.
* **Validator/enforcement owner:** `framework/assurance/structural/validate-constitution.sh` + `authority_engine`.
* **Migration:** consolidate current `octon.yml`, umbrella specification, ingress obligations, and agency/governance constitutional fragments. ([GitHub][14])

### 2. Workspace Charter

* **Fields:** `workspace_id`, `version`, `owner`, `purpose`, `scope_in`, `scope_out`, `success_signals`, `protected_zones`, `default_risk_posture`, `default_change_profile`, `support_target_refs`, `review_cadence`.
* **Semantics:** durable repo-wide objective authority.
* **Lifecycle:** authored, reviewed, low-frequency updates.
* **Ownership:** repo governance owners.
* **Authoring location:** `instance/charter/workspace.md`, `instance/charter/workspace.yml`.
* **Runtime projection:** `generated/effective/constitution/workspace.yml`.
* **Validator/enforcement owner:** `authority_engine`, `validate-workspace-charter.sh`.
* **Migration:** lift current `instance/bootstrap/OBJECTIVE.md` plus stable bootstrap intent into a real charter pair. ([GitHub][15])

### 3. Mission Charter

* **Fields:** `mission_id`, `version`, `title`, `summary`, `mission_class`, `owner_ref`, `scope_ids`, `allowed_action_classes`, `risk_ceiling`, `default_oversight_mode`, `default_execution_posture`, `overlap_policy`, `success_criteria`, `failure_conditions`, `recovery_defaults`, `status`.
* **Semantics:** long-horizon continuity, ownership, and autonomy posture.
* **Lifecycle:** authored, activated, paused/retired; versioned across mission evolution.
* **Ownership:** repo governance / mission owners.
* **Authoring location:** `instance/orchestration/missions/<mission-id>/mission.yml`, `mission.md`.
* **Runtime projection:** `state/control/execution/missions/<mission-id>/charter.effective.yml`.
* **Validator/enforcement owner:** existing mission validators plus new mission-charter validator.
* **Migration:** evolve current `octon-mission-v2` files in place. ([GitHub][8])

### 4. Run Contract

* **Fields:** `run_id`, `version`, `workspace_ref`, `mission_ref` (nullable), `trigger`, `objective_summary`, `scope_in`, `scope_out`, `done_when`, `acceptance_criteria`, `risk_class`, `reversibility_class`, `requested_capability_packs`, `protected_zones`, `required_approvals`, `required_evidence`, `support_tier_ref`, `expiry`, `created_by`, `approved_by`.
* **Semantics:** atomic execution unit for every material run.
* **Lifecycle:** drafted → routed → granted/denied → active → closed.
* **Ownership:** authored by operator/automation/model as proposal, ratified by harness/humans depending on route.
* **Authoring location:** canonical source in `state/control/execution/runs/<run-id>/run.yml`.
* **Runtime projection:** `generated/effective/execution/runs/<run-id>/run.effective.yml`.
* **Validator/enforcement owner:** `authority_engine`.
* **Migration:** initially derive from current intent contract + mission + workflow input; after cutover, become mandatory source artifact.

### 5. ApprovalRequest

* **Fields:** `approval_request_id`, `run_ref`, `requested_by`, `action_classes`, `resource_scope`, `risk_class`, `reversibility_class`, `requested_window`, `quorum_policy_ref`, `evidence_prerequisites`, `rationale`, `status`.
* **Semantics:** canonical request for authority.
* **Lifecycle:** created → pending → granted/denied/cancelled.
* **Ownership:** request created by harness/model/operator; fulfilled by humans or authorized automation.
* **Authoring location:** `state/control/execution/approvals/<run-id>/<approval-request-id>.yml`.
* **Runtime projection:** summarized in run manifest and RunCard.
* **Validator/enforcement owner:** `authority_engine`, host adapters.
* **Migration:** host adapters mirror current GitHub signals into this artifact during compatibility.

### 6. ApprovalGrant

* **Fields:** `approval_grant_id`, `approval_request_ref`, `grantors`, `quorum_satisfied`, `decision`, `granted_scope`, `capability_overrides`, `expiry`, `conditions`, `rollback_or_compensation_requirements`, `revocation_policy`.
* **Semantics:** canonical approval artifact.
* **Lifecycle:** issued → active → expired/revoked/consumed.
* **Ownership:** humans or break-glass authorities only.
* **Authoring location:** `state/control/execution/approvals/<run-id>/<approval-grant-id>.yml`.
* **Runtime projection:** grant digest in run manifest, receipts, RunCard.
* **Validator/enforcement owner:** `authority_engine`.
* **Migration:** replace label-native “accept:human” semantics as authority source. ([GitHub][16])

### 7. ExceptionLease

* **Fields:** `lease_id`, `run_ref`, `rule_relaxed`, `scope`, `owner`, `issued_at`, `expires_at`, `justification`, `compensation_constraints`, `renewal_policy`, `status`.
* **Semantics:** scoped, temporary relaxation of a rule.
* **Lifecycle:** issued → active → expired/revoked/renewed.
* **Ownership:** human authorities only.
* **Authoring location:** `state/control/execution/exception-leases/<run-id>/<lease-id>.yml`.
* **Runtime projection:** route digest and run manifest references.
* **Validator/enforcement owner:** `authority_engine`.
* **Migration:** evolve current flat `exception-leases.yml` into per-run lease artifacts. ([GitHub][17])

### 8. Revocation

* **Fields:** `revocation_id`, `subject_ref`, `revoked_artifact_ref`, `reason`, `effective_at`, `issued_by`, `required_safing_action`, `status`.
* **Semantics:** cancels an approval, lease, or live run authority state.
* **Lifecycle:** issued → enforced → closed.
* **Ownership:** human or break-glass roles.
* **Authoring location:** `state/control/execution/revocations/<run-id>/<revocation-id>.yml`.
* **Runtime projection:** breaker/safing state in run manifest and continuity.
* **Validator/enforcement owner:** `authority_engine` + runtime.

### 9. QuorumPolicy

* **Fields:** `quorum_policy_id`, `required`, `rules`, `applicable_action_classes`, `support_tiers`, `escalation_paths`.
* **Semantics:** reusable approval policy template.
* **Lifecycle:** authored and versioned; referenced by ApprovalRequests.
* **Ownership:** governance owners.
* **Authoring location:** `framework/constitution/contracts/authority/quorum-policies.yml`; instance overrides in `instance/governance/contracts/**`.
* **Runtime projection:** resolved into approval requests.
* **Validator/enforcement owner:** `authority_engine`.
* **Migration:** absorb current ACP-2/3/4 quorum semantics from mission-autonomy into portable policy templates. ([GitHub][9])

### 10. DecisionArtifact

* **Fields:** `decision_id`, `subject_ref`, `route`, `reason_codes`, `policy_inputs`, `required_followups`, `decision_engine_version`, `timestamp`, `linked_artifacts`.
* **Semantics:** canonical result of authority routing.
* **Lifecycle:** emitted on every route evaluation; immutable.
* **Ownership:** harness-generated.
* **Authoring location:** `state/evidence/control/execution/decisions/<run-id>/<decision-id>.yml`.
* **Runtime projection:** latest route mirrored into `state/control/execution/runs/<run-id>/decision.latest.yml`.
* **Validator/enforcement owner:** `authority_engine`.
* **Migration:** supersede host-only workflow findings as the authoritative decision record.

### 11. Model Adapter Contract

* **Fields:** `adapter_id`, `version`, `provider`, `model_family`, `model_ids`, `tool_call_semantics`, `json_contract_strength`, `context_limits`, `cost_model_ref`, `latency_defaults`, `caching_behavior`, `retry_policy`, `reset_policy`, `contamination_signatures`, `supported_workload_tiers`, `supported_locale_tiers`, `conformance_suite_refs`, `known_limitations`.
* **Semantics:** testable model portability interface.
* **Lifecycle:** authored, conformance-tested, admitted, deprecated, retired.
* **Ownership:** framework runtime owners.
* **Authoring location:** `framework/engine/runtime/adapters/models/<family>/<adapter-id>/adapter.yml`.
* **Runtime projection:** adapter digest embedded in run manifest and HarnessCard.
* **Validator/enforcement owner:** `adapter-conformance.yml` suite + runtime loader.
* **Migration:** pull provider-specific behavior out of budget policy and AI gate workflows into adapter-owned contracts. ([GitHub][18])

### 12. Capability / Tool Contract

* **Fields:** `capability_id`, `version`, `surface_type`, `side_effect_class`, `input_schema_ref`, `output_schema_ref`, `credential_scope`, `redaction_policy`, `approval_threshold`, `measurement_hooks`, `rollback_or_compensation_notes`, `support_target_refs`.
* **Semantics:** typed governed capability pack contract.
* **Lifecycle:** authored, validated, published, activated, retired.
* **Ownership:** capability/domain owners.
* **Authoring location:** `framework/capabilities/contracts/<pack>/<capability>.yml`; instance overlays in `instance/capabilities/runtime/packs/**`.
* **Runtime projection:** effective capability set under `generated/effective/capabilities/**`.
* **Validator/enforcement owner:** capability validators + authority engine.
* **Migration:** wrap current services/skills/runtime capabilities in pack contracts. ([GitHub][19])

### 13. Host Adapter Contract

* **Fields:** `host_adapter_id`, `version`, `host_type`, `projected_artifacts`, `ingest_surfaces`, `outbound_actions`, `auth_scope`, `rate_limits`, `failure_modes`, `projection_rules`, `redaction_policy`.
* **Semantics:** canonical mapping between host affordances and Octon authority/disclosure artifacts.
* **Lifecycle:** authored, tested, admitted, versioned.
* **Ownership:** runtime host adapter owners.
* **Authoring location:** `framework/engine/runtime/adapters/hosts/<host>/<adapter>.yml`.
* **Runtime projection:** host-adapter digest in run manifest and HarnessCard.
* **Validator/enforcement owner:** host adapter tests + authority engine.
* **Migration:** GitHub labels/comments/checks become projections of Approval/Decision artifacts rather than authority themselves. ([GitHub][16])

### 14. Run Manifest

* **Fields:** `run_id`, `attempt_id`, `run_contract_ref`, `mission_ref`, `model_adapter_ref`, `host_adapter_ref`, `worktree_ref`, `environment_class`, `instruction_layers`, `granted_capabilities`, `budget_envelope`, `start_timestamp`.
* **Semantics:** canonical live execution envelope.
* **Lifecycle:** opened at execution start; immutable except for linked stage/checkpoint references.
* **Ownership:** runtime-generated.
* **Authoring location:** `state/control/execution/runs/<run-id>/manifest.yml`.
* **Runtime projection:** external replay index and RunCard.
* **Validator/enforcement owner:** runtime kernel + authority engine.
* **Migration:** layer atop current execution request/grant/receipt artifacts.

### 15. Execution Attempt / Stage Contract

* **Fields:** `attempt_id`, `stage_id`, `run_ref`, `stage_type`, `goal`, `inputs`, `allowed_surfaces`, `effect_class`, `preconditions`, `success_conditions`, `checkpoint_policy`, `status`.
* **Semantics:** bounded stage unit inside a run.
* **Lifecycle:** created → prepared → running → passed/failed/staged.
* **Ownership:** runtime-generated, may include model-authored plan fields.
* **Authoring location:** `state/control/execution/runs/<run-id>/attempts/<attempt-id>/stages/<stage-id>.yml`.
* **Runtime projection:** summarized in checkpoints and RunCard.
* **Validator/enforcement owner:** runtime kernel + assurance hooks.

### 16. Checkpoint

* **Fields:** `checkpoint_id`, `run_ref`, `stage_ref`, `workspace_hash`, `open_items`, `next_action_hypothesis`, `verification_state`, `contamination_flags`, `resume_prerequisites`, `created_at`.
* **Semantics:** resumability anchor.
* **Lifecycle:** emitted during run; immutable.
* **Ownership:** runtime-generated.
* **Authoring location:** `state/control/execution/runs/<run-id>/attempts/<attempt-id>/checkpoints/<checkpoint-id>.yml`.
* **Runtime projection:** latest checkpoint pointer in `state/continuity/runs/<run-id>/latest.yml`.
* **Validator/enforcement owner:** runtime + recovery suite.

### 17. Continuity Artifact

* **Fields:** `continuity_id`, `scope_type`, `scope_ref`, `summary`, `decisions`, `open_risks`, `handoff_requirements`, `linked_checkpoints`, `follow_on_work`, `updated_at`.
* **Semantics:** handoff and resumability artifact at repo/scope/mission/run levels.
* **Lifecycle:** append/update during active work; stabilized at closeout.
* **Ownership:** runtime-generated, human-amendable with audit trail.
* **Authoring location:** `state/continuity/{repo|scopes|missions|runs}/...`.
* **Runtime projection:** generated reports/digests.
* **Validator/enforcement owner:** continuity validators + runtime.
* **Migration:** normalize existing continuity ledgers rather than replace them. ([GitHub][1])

### 18. Assurance Report

* **Fields:** `report_id`, `run_ref`, `plane`, `checks_executed`, `evaluator_refs`, `hidden_check_refs`, `result`, `known_gaps`, `waivers`, `timestamp`.
* **Semantics:** proof artifact for one plane.
* **Lifecycle:** emitted per suite/plane; immutable.
* **Ownership:** assurance/lab subsystems.
* **Authoring location:** `state/evidence/validation/runs/<run-id>/<plane>/<report-id>.yml`.
* **Runtime projection:** assurance summary in RunCard.
* **Validator/enforcement owner:** assurance domain owners.
* **Migration:** preserve current CI proof and expand it into plane-specific reports. ([GitHub][4])

### 19. Intervention Record

* **Fields:** `intervention_id`, `run_ref`, `actor`, `intervention_type`, `reason`, `before_after_refs`, `visibility`, `impact_on_outcome`, `timestamp`.
* **Semantics:** mandatory record of human or privileged intervention.
* **Lifecycle:** emitted whenever intervention occurs; immutable.
* **Ownership:** harness-generated when possible, host-adapter-assisted when necessary.
* **Authoring location:** `state/evidence/control/execution/interventions/<run-id>/<id>.yml`.
* **Runtime projection:** intervention summary in RunCard/HarnessCard.
* **Validator/enforcement owner:** authority engine + disclosure validator.
* **Migration:** absorb current label/approval/manual gate actions into standardized intervention logging.

### 20. Measurement Record

* **Fields:** `measurement_id`, `subject_ref`, `metric_class`, `method`, `window`, `value`, `thresholds`, `source_refs`, `timestamp`.
* **Semantics:** normalized metric artifact for cost, latency, drift, reliability, recovery, benchmark planes.
* **Lifecycle:** emitted continuously or per run; immutable snapshots.
* **Ownership:** runtime/observability/lab.
* **Authoring location:** `state/evidence/measurements/<scope>/<measurement-id>.yml`.
* **Runtime projection:** benchmark packets, HarnessCard.
* **Validator/enforcement owner:** observability validators.

### 21. RunCard

* **Fields:** `run_ref`, `objective_summary`, `mission_ref`, `route_summary`, `adapters`, `capability_packs`, `assurance_summary`, `intervention_summary`, `cost_latency_summary`, `outcome`, `evidence_refs`.
* **Semantics:** minimal per-run disclosure artifact.
* **Lifecycle:** emitted at run closeout; immutable.
* **Ownership:** runtime + observability.
* **Authoring location:** `state/evidence/disclosure/runs/<run-id>/RunCard.yml`.
* **Runtime projection:** optional rendered markdown under `generated/reports/runs/<run-id>.md`.
* **Validator/enforcement owner:** disclosure validator.
* **Migration:** new artifact; current receipts feed it.

### 22. HarnessCard

* **Fields:** `harness_version`, `charter_version`, `support_matrix_ref`, `core_layers`, `authority_model_summary`, `runtime_model_summary`, `adapter_inventory`, `benchmark_suite_refs`, `intervention_policy`, `retention_model_ref`, `known_limitations`.
* **Semantics:** system-level disclosure artifact.
* **Lifecycle:** authored per release or support-tier change; immutable snapshots archived.
* **Ownership:** governance owners with runtime/observability input.
* **Authoring location:** source in `instance/governance/disclosure/HarnessCard.yml`.
* **Runtime projection:** immutable release snapshot in `state/evidence/disclosure/releases/<release>/HarnessCard.yml`.
* **Validator/enforcement owner:** release/disclosure validator.
* **Migration:** new artifact.

### 23. Evidence Retention Contract

* **Fields:** `artifact_class`, `storage_class`, `retention_window`, `redaction_rules`, `hash_requirements`, `export_profile_behavior`, `deletion_policy`.
* **Semantics:** classifies Git-inline vs pointered vs external immutable evidence.
* **Lifecycle:** authored constitutional contract with governed updates.
* **Ownership:** observability/governance owners.
* **Authoring location:** `framework/constitution/contracts/retention/evidence-retention.yml`; instance overlays in `instance/governance/contracts/**`.
* **Runtime projection:** `generated/effective/observability/evidence-retention.yml`.
* **Validator/enforcement owner:** replay/telemetry sink + export validator.
* **Migration:** codifies current export exclusions and receipt roots into a formal evidence model. ([GitHub][1])

Representative schema skeletons:

```yaml
# instance/orchestration/missions/<mission-id>/run-contract-template.yml
schema_version: octon-run-contract-v1
run_id: run-2026-04-01T12-30-00Z-abc123
workspace_ref: charter://instance/workspace@1.0.0
mission_ref: mission://mission-autonomy-live-validation@3.0.0
trigger:
  type: workflow
  source: workflow://maintain-live-mission
objective_summary: "Reconcile live mission control/evidence surfaces without external side effects."
scope_in:
  - ".octon/state/control/execution/missions/mission-autonomy-live-validation/**"
  - ".octon/generated/effective/orchestration/missions/**"
scope_out:
  - ".github/**"
  - "public_release"
done_when:
  - "mission control state is coherent"
  - "required summaries and mission-view are fresh"
acceptance_criteria:
  - "structural pass"
  - "governance pass"
  - "recovery drill pass"
risk_class: ACP-1
reversibility_class: reversible
requested_capability_packs: [repo, git, shell]
protected_zones:
  - ".octon/inputs/exploratory/ideation/**"
required_evidence:
  - execution_receipt
  - assurance_reports
  - runcard
support_tier_ref: support://frontier/repo-mutation/en
expiry: 2026-04-01T16:30:00Z
```

```yaml
# state/control/execution/approvals/<run-id>/<grant-id>.yml
schema_version: octon-approval-grant-v1
approval_grant_id: grant-01
approval_request_ref: approval-request-01
grantors:
  - operator://octon-maintainers
quorum_satisfied: ACP-2
decision: granted
granted_scope:
  action_classes: [fs.write, git.commit]
  capability_packs: [repo, git, shell]
expiry: 2026-04-02T00:00:00Z
conditions:
  - "no external network egress"
  - "must remain within scope_id octon-harness"
rollback_or_compensation_requirements:
  rollback_required: true
  compensation_required: false
revocation_policy: immediate_on_breaker_or_owner_revocation
```

```yaml
# framework/engine/runtime/adapters/models/openai/gpt-5.4-pro/adapter.yml
schema_version: octon-model-adapter-v1
adapter_id: openai-gpt-5.4-pro
provider: openai
model_family: gpt-5.4
model_ids: [gpt-5.4-pro]
tool_call_semantics: strict-json-tool
json_contract_strength: strong
context_limits:
  prompt_bytes_max: 400000
  output_tokens_max: 32000
caching_behavior: provider-managed
retry_policy: idempotent-tool-retry-only
reset_policy: hard-reset-on-contamination-or-serializer-failure
contamination_signatures:
  - repeated goal restatement drift
  - schema-output degradation
supported_workload_tiers:
  - repo-readonly
  - repo-mutation
supported_locale_tiers:
  - en-reference
conformance_suite_refs:
  - suite://adapters/model/openai-gpt-5.4-pro/core
known_limitations:
  - "browser/UI packs unsupported until browser capability pack is admitted"
```

```yaml
# state/evidence/disclosure/runs/<run-id>/RunCard.yml
schema_version: octon-runcard-v1
run_ref: run://run-2026-04-01T12-30-00Z-abc123
objective_summary: "Reconcile live mission control/evidence surfaces."
mission_ref: mission://mission-autonomy-live-validation@3.0.0
route_summary:
  initial: STAGE_ONLY
  promoted_to: ALLOW
  reason_codes: [INTENT_VALID, ACP1_WITHIN_SCOPE]
adapters:
  host: github-actions
  model: openai-gpt-5.4-pro
capability_packs: [repo, git, shell]
assurance_summary:
  structural: pass
  governance: pass
  recovery: pass
intervention_summary:
  count: 0
cost_latency_summary:
  estimated_cost_usd: 0.18
  wall_clock_seconds: 94
outcome: succeeded
evidence_refs:
  - receipt://execution/...
  - assurance://...
```

## H. Control, Authority, and Governance Model

### Normative authority precedence

1. Non-waivable external obligations, break-glass, and live revocations.
2. Harness Charter and constitutional fail-closed obligations.
3. Support-target matrix and governance policy families.
4. QuorumPolicy, ApprovalGrant, ExceptionLease, and Revocation applicable to the current run.
5. Workspace Charter.
6. Mission Charter.
7. Run Contract.
8. Capability/Tool contracts and Model/Host Adapter contracts.
9. Repo architecture/specification artifacts.
10. Informative docs, generated summaries, chat history, and model priors.

This preserves the current class-root SSOT logic while making authority ordering explicit. The current repo already encodes class-root precedence and runtime trust boundaries, but not this full normative ladder. ([GitHub][1])

### Epistemic grounding precedence

1. Live runtime observations and validated receipts.
2. Deterministic validator outputs and measurement records.
3. Current repo/worktree state.
4. Mutable `state/control/**` truth.
5. Freshness-valid `generated/effective/**` outputs.
6. Provenance-backed continuity artifacts.
7. Authored docs and charters.
8. Conversation history and operator comments.
9. Model priors.

If runtime evidence conflicts with docs, runtime evidence wins for factual state; the conflict becomes a drift incident. That is the dual-precedence split Octon currently needs. ([GitHub][1])

### Human / harness / model decision boundaries

* **Humans own:** charter changes, support-target changes, policy changes, ownership rules, one-way-door approvals, exception leases, revocations, public/external commitments, and HarnessCard release sign-off.
* **Harness owns:** route evaluation, fail-closed enforcement, grant/receipt validation, run-state integrity, intervention logging, replay integrity, disclosure assembly, and gating execution against proof.
* **Model owns:** bounded planning, run-contract drafts, capability invocation strategy within grant, local deterministic self-checks, and low-risk retries.
* **Model must not own:** approval, exception, revocation, support-tier widening, irreversible authorization, or final consequential acceptance.

This sharpens what is currently split across mission-autonomy policy, runtime authorization, and workflow-host logic. ([GitHub][20])

### Route semantics

* **ALLOW:** material execution may proceed within granted scope.
* **STAGE_ONLY:** packetization, planning, validation, preview, and report generation are allowed; material effects are not.
* **ESCALATE:** execution pauses pending approval, exception, or owner resolution.
* **DENY:** fail closed; only safe observation or re-drafting is allowed.

Octon already uses these four decisions in its current receipt contract and budget policy. The target state keeps them and makes them universal. ([GitHub][21])

### Approval rules

* Every material approval uses `ApprovalRequest` + `ApprovalGrant`.
* `accept:human` and similar host labels become projections only.
* Approval scope must include action classes, capability packs, resource scope, validity window, and revocation policy.
* Approval for unsupported support tiers is invalid by construction.
* QuorumPolicy templates govern who must sign and when.

Current ACP-2/3/4 semantics from mission-autonomy become portable quorum templates. Current PR label enforcement is re-bound as a host adapter. ([GitHub][9])

### Exception-lease rules

* Exception leases are temporary, scoped, owner-bound, and revocable.
* Leases must specify what rule is relaxed, why, for how long, and what compensating constraints apply.
* Lease expiry is hard fail-closed; silent carryover is forbidden.
* Repeated lease demand for the same rule should trigger policy or architecture review.

### Revocation rules

* Revocation is immediate and authoritative.
* Revocation can target a grant, lease, capability pack, adapter, or live run.
* Revocation triggers safing action defined in mission policy or run contract.
* All revocations emit DecisionArtifacts, InterventionRecords, and continuity updates.

### Fail-closed rules

At minimum, Octon must `DENY` or `STAGE_ONLY` when any of these are missing or invalid: run contract, intent binding, required mission context, approval evidence, grant bundle, required instruction-layer manifest, freshness receipts for required effective outputs, valid support-target tier, or mandatory evidence from prior step transitions. The current runtime policy interface and execution-authorization boundary already imply much of this; the target state makes it constitutional. ([GitHub][3])

### Ambiguity and missing-evidence behavior

* **Ambiguous ownership:** `ESCALATE` or `DENY`; never infer owner.
* **Missing evidence for a material side effect:** `STAGE_ONLY` or `DENY`.
* **Unsupported tier or unknown adapter behavior:** `DENY`.
* **Policy conflict without explicit precedence:** `ESCALATE`.
* **Runtime/doc mismatch:** continue only against live runtime facts if safe, emit drift incident, and block publication/promotion until reconciled.

## I. Runtime, Continuity, and Evidence Model

### Run lifecycle

1. **Triggered** — host adapter or operator creates a run request.
2. **Drafted** — run contract materializes.
3. **Routed** — authority engine emits DecisionArtifact.
4. **Granted / Staged / Denied / Escalated** — route result becomes live state.
5. **Prepared** — instruction layers, adapter set, worktree, and initial checkpoint materialize.
6. **Running** — execution attempts/stages proceed under grants.
7. **Checkpointed** — stage or risk boundary reached.
8. **Verification pending** — assurance planes execute.
9. **Succeeded / Failed / Compensating / Revoked** — terminal or transitional closeout state.
10. **Closed** — RunCard, continuity update, replay bundle, and disclosure snapshot emitted.

Current receipts, mission control, evidence roots, and continuity roots become the substrate for this model. ([GitHub][20])

### Run vs mission relationship

* **Mission-backed runs:** mandatory for scheduled, recurring, incident, campaign, or always-on autonomy.
* **Run-only autonomy:** allowed for bounded one-shot tasks in admitted support tiers.
* **Mission ref is nullable**, but only for workload tiers whose policy explicitly allows run-only execution.
* **No silent fallback:** if a workload tier requires mission context, mission absence is a denial.

This is the deliberate refinement of the current “no mission-less fallback” rule. ([GitHub][1])

### Checkpoint / resume model

* Checkpoints are required before material side effects, after stage boundaries, before human approvals, before resets, and before context compaction.
* Resume must require only authoritative repo state + run bundle + checkpoint, not prior chat history.
* Continuity artifacts exist at repo, scope, mission, and run levels; run continuity is new and mission continuity remains.
* Checkpoint lineage must support replay and recovery proof.

### Reset / compaction / contamination model

* **Compaction** is allowed only when checkpoint exists and contamination flags are clear.
* **Hard reset** is mandatory when contamination signatures fire, schema output degrades, or state coherence is doubtful.
* **Contamination sources:** stale generated/effective state, conflicting continuity artifacts, model drift inside long contexts, or unsupported adapter behavior.
* **Contamination evidence** is logged and fed into recovery/benchmark metrics.

The current memory contract already encodes flush and ambiguity posture; the proposal moves that into runtime enforcement. ([GitHub][13])

### Retry classes

* **Deterministic retry:** transient infra or tool flake.
* **Re-plan retry:** proof failed but authority still valid.
* **Approval-blocked retry:** suspended until grant or lease changes.
* **Recovery retry:** allowed only with declared rollback/compensation posture.
* **Contamination reset retry:** new execution attempt from last safe checkpoint.

### Rollback / compensation posture

Every material run and every material stage declares one of:

* `rollback_required`
* `compensation_required`
* `none_allowed_only_if_no_material_effect`

This extends the current receipt contract, which already has rollback, compensation, and recovery-window fields. ([GitHub][21])

### Worktree / sandbox / environment lifecycle

* One run gets one canonical worktree/sandbox by default.
* Environment class is recorded in the run manifest.
* Support-target tier determines which capability packs and environment classes are legal.
* Cleanup produces a terminal checkpoint, continuity closeout, receipt finalization, and evidence flush.

The kernel already exposes run evidence root, execution control root, and execution temp root through `octon info`; the proposal normalizes them under per-run state. ([GitHub][7])

### What is event-sourced

Event-source at least these:

* route decisions,
* approvals/grants/leases/revocations,
* stage transitions,
* capability invocations,
* checkpoints,
* assurance reports,
* interventions,
* measurements,
* RunCard finalization.

### Evidence classes

* **Class A — Git-inline:** charters, approvals, decision artifacts, failure taxonomies, selected RunCards, HarnessCard, support targets.
* **Class B — Git-pointer:** replay manifests, assurance summaries, external artifact indices, compact measurement summaries.
* **Class C — External immutable:** raw model transcripts, browser artifacts, HAR files, videos, screenshots, high-frequency traces, large replay payloads.

This formalizes the repo’s current portability stance, where clean repo snapshots exclude `state/**` and `generated/**`, and `full_fidelity` is a normal Git clone rather than a synthetic export. ([GitHub][1])

### Compatibility period and cutover plan

* **Compatibility window:** two release waves minimum.
* **Dual-write:** old receipt roots and new per-run bundle roots both receive artifacts during phases 2–4.
* **Dual-read:** runtime prefers new run bundle artifacts when feature toggle enabled, else old mission/control paths.
* **Cutover trigger:** parity validator shows no semantic loss across dual-written artifacts for two consecutive releases.
* **Fallback:** disable new feature toggles in `instance/manifest.yml`, continue using old mission-centric/control receipts while preserving new authored contracts. Current manifest already has feature toggles; extend that pattern. ([GitHub][22])

## J. Verification, Evaluation, and Lab Model

### Proof planes

1. **Structural proof** — architecture conformance, schema validity, placement rules, freshness/publication coherence, capability/engine integrity.
2. **Functional proof** — service/workflow acceptance against run contract acceptance criteria.
3. **Behavioral proof** — scenario packs, UI/API flows, hidden assertions, real-world behavior checks.
4. **Maintainability proof** — drift, stale-doc detection, bounded complexity, cleanup burden, contract hygiene.
5. **Governance proof** — route correctness, approval presence, exception scope, intervention completeness, protected-zone enforcement.
6. **Recovery proof** — checkpoint/resume, rollback/compensation, breaker behavior, safe-state restoration.

The first and fifth already have strong current coverage in CI. The proposal adds the rest as peers, not appendices. ([GitHub][4])

### Preserve existing strong structural assurance

Keep current workflows and re-home them under the new plane model:

* `architecture-conformance.yml` remains the top-level structural/governance gate.
* `deny-by-default-gates.yml` remains the protected-execution and capability-boundary gate.
* Mission runtime/source-of-truth validators remain structural/governance suites.
* Current generated mission-view and control-evidence validators remain structural/governance suites until replaced by run-bundle validators. ([GitHub][4])

Add new top-level workflows:

* `.github/workflows/functional-acceptance.yml`
* `.github/workflows/behavioral-scenarios.yml`
* `.github/workflows/recovery-drills.yml`
* `.github/workflows/governance-disclosure.yml`
* `.github/workflows/adapter-conformance.yml`
* `.github/workflows/lab-shadow-replay.yml`

### Self-checking boundaries

* Allowed: schema validation, deterministic local invariants, dry-run packetization, stage-only previews.
* Not sufficient: consequential completion, public/external effect, behavioral claims, recovery claims, or benchmark claims.
* Required: independent evaluator or deterministic proof for any consequential acceptance.

### Independent evaluator roles

* **Deterministic validator** — existing scripts and schema checks.
* **Behavioral evaluator** — lab-side scenario runner or UI/API checker.
* **Model-based reviewer** — adapter-specific reviewer, e.g., current AI gate providers, but as evaluator adapters rather than PR-labeling workflows.
* **Owner attestor** — human or break-glass sign-off when policy requires.

Current AI review gate becomes an evaluator adapter feeding Assurance Reports and Intervention Records instead of directly shaping authority through GitHub label sync. ([GitHub][23])

### Hidden vs visible checks

* **Visible checks:** deterministic structural, governance, and basic functional suites in-repo.
* **Hidden checks:** off-repo or sealed scenario assertions for benchmark integrity and anti-overfitting.
* **Constraint:** because Octon is public, truly hidden checks cannot live fully in-tree; they must use sealed assets or private CI-backed scenario packs.

### Anti-overfitting protections

* hidden-check rotation,
* held-out scenario packs,
* evaluator diversity across deterministic and model-backed evaluators,
* adapter conformance separate from benchmark suites,
* explicit intervention disclosure,
* layer-specific scorecards instead of a single blended pass.

### Intervention disclosure

Every human approval, waiver, override, manual patch, host-side label sync, or break-glass action emits an `InterventionRecord`. RunCards summarize interventions; HarnessCard discloses intervention policy and whether any benchmark relied on hidden human repair.

### Top-level lab design and interfaces

`framework/lab/**` owns:

* `scenario-packs/**`
* `replay/**`
* `shadow/**`
* `faults/**`
* `red-team/**`
* `telemetry-probes/**`

Interface contracts:

* `lab-scenario-v1.schema.json`
* `replay-bundle-v1.schema.json`
* `fault-injection-plan-v1.schema.json`
* `shadow-run-manifest-v1.schema.json`
* `probe-contract-v1.schema.json`

Current `mission-autonomy-live-validation` migrates into `framework/lab/scenario-packs/mission-autonomy-live-validation/` and remains one supported scenario pack, not the lab itself. ([GitHub][8])

## K. Portability, Adapters, and Support Targets

### Portable kernel

Portable across repos and model families:

* super-root and class-root rules,
* constitutional charter and precedence models,
* run/approval/decision/checkpoint/assurance/disclosure schemas,
* route semantics,
* evidence classes,
* proof-plane taxonomy,
* lab contracts,
* support-target schema,
* build-to-delete rules.

These are Octon’s durable product surface. Current portability/export profiles already point in this direction. ([GitHub][1])

### Non-portable adapters

Explicitly non-portable:

* model adapters,
* host adapters,
* browser drivers,
* API connectors,
* provider-specific cost models,
* evaluator prompts/scripts,
* repo-local overlays,
* workload- or locale-specific capability packs.

Current OpenAI/Anthropic budget thresholds and AI gate provider scripts are good evidence that these concerns already exist; the target state just moves them behind contracts. ([GitHub][18])

### Model adapters

* Live under `framework/engine/runtime/adapters/models/**`.
* Are admitted only after conformance tests pass.
* Can narrow autonomy envelopes by support tier.
* Must declare contamination/reset policy and known limitations.
* Unsupported model families fail `DENY` or `STAGE_ONLY` depending on workload class.

### Host adapters

* Live under `framework/engine/runtime/adapters/hosts/**`.
* Render and ingest canonical artifacts for GitHub, CI, CLI, and Studio.
* May not define authority semantics.
* Current GitHub labels/comments/checks become projections only. ([GitHub][16])

### Capability packs

* Preserve current repo/git/shell surfaces.
* Add browser and API packs only through governed contracts.
* Each pack declares credential scope, redaction policy, approval threshold, and support tiers.
* Unsupported capability pack on a given support tier fails closed.

The current localhost-only network-egress policy should remain the default envelope until broader packs are admitted. ([GitHub][24])

### Support-target matrix

Authoritative source: `instance/governance/support-targets.yml`.

Minimum axes:

* **Model tier**

  * `MT-A`: frontier managed APIs; full supported autonomy envelope
  * `MT-B`: mid-tier managed APIs; reduced autonomy envelope
  * `MT-C`: local/self-hosted; read-only or stage-only by default
* **Workload tier**

  * `WT-1`: repo read-only
  * `WT-2`: repo mutation
  * `WT-3`: repo + browser/API
  * `WT-4`: long-running mission/incident autonomy
* **Language/resource tier**

  * `LT-REF`: current `.octon` reference profile
  * `LT-EXT`: admitted extension packs
  * `LT-EXP`: experimental/low-resource
* **Locale tier**

  * `LOC-EN`: English reference
  * `LOC-MX`: admitted multilingual packs
  * `LOC-EXP`: experimental locales

The current `octon-harness` locality scope makes clear the reference profile is `.octon` with `markdown`, `yaml`, `bash`, `json`, and `rust`; the support matrix should formalize rather than obscure that limitation. ([GitHub][25])

### Unsupported cases

Unsupported combinations fail closed:

* `DENY` if action would create unsupported material side effects.
* `STAGE_ONLY` if safe preview/packetization is still useful.
* `ESCALATE` only if a human is explicitly allowed to bridge the gap under policy.

### Admitting new support tiers

A new tier is admitted only after:

1. adapter contract exists,
2. conformance suite passes,
3. proof-plane minimums are met,
4. disclosure updated,
5. governance approves the support-target change.

## L. Simplification, Deletion, and Evolution Model

### What stays stable

* class-root super-root,
* fail-closed root manifest posture,
* execution-authorization boundary,
* `ALLOW / STAGE_ONLY / ESCALATE / DENY`,
* mission as continuity/ownership layer,
* continuity/evidence/control separation,
* structural and governance CI gates,
* portability/export discipline. ([GitHub][1])

### What remains replaceable

* model adapters,
* host adapters,
* capability pack implementations,
* evaluator providers,
* browser/API connectors,
* telemetry backends,
* support-target defaults,
* scaffolding prompts and presentation layers.

### Load-bearing current actor/agency surfaces

* `framework/agency/manifest.yml` routing and ownership defaults,
* delegation policy,
* memory discipline,
* one accountable default orchestrator,
* mission ownership routing,
* no arbitrary skill-actor delegation. ([GitHub][6])

### Transitional current surfaces

* `architect` as kernel identity,
* `SOUL.md` as required ingress dependency,
* assistants/teams registries in the kernel discovery path,
* provider-specific AI review scripts in PR workflow,
* mission as the canonical autonomous operating model for all cases. ([GitHub][13])

### Demote to overlays

* `SOUL.md`
* persona/voice guidance
* archetype-heavy execution prose that is not machine-enforced
* optional assistant/team overlays that do not carry authority or concurrency value

### Delete from kernel path

* GitHub-label-native authority assumptions,
* mission-only autonomy assumption,
* persona-heavy mandatory ingress dependencies,
* duplicated constitutional prose in multiple domains,
* any generated summary treated as authority. ([GitHub][16])

### Build-to-delete rules

Every new scaffold must declare:

* owner,
* justification,
* supported tiers,
* metric of value,
* review date,
* retirement trigger,
* required ablation suite.

Retirement triggers include:

* model adapter upgrade removes need,
* support-target contraction or expansion invalidates old workaround,
* hidden-check failure shows scaffold is ineffective,
* intervention density stays flat after scaffold removal.

The current packetized architecture work in `state/continuity/repo/tasks.json` should become the basis for a permanent retirement registry and deletion review cycle. ([GitHub][10])

## M. Major Architectural Moves

### 1. Constitutional extraction

* **Current paths:** `.octon/octon.yml`, `.octon/README.md`, `.octon/framework/cognition/_meta/architecture/specification.md`, `.octon/instance/ingress/AGENTS.md`, `.octon/framework/agency/governance/**`.
* **Target artifacts:** `framework/constitution/**`.
* **Move:** **consolidate / re-bound / harden**.
* **Migration:** dual-write constitutional content with shims for one release wave.
* **Enforcement:** new `validate-constitution.sh` gate; instruction-layer manifest includes constitution refs.
* **Evidence/uncertainty:** current constitution is distributed but real; consolidation is high-confidence. ([GitHub][14])

### 2. Objective stack formalization

* **Current paths:** `.octon/instance/bootstrap/OBJECTIVE.md`, active intent contract, mission charters.
* **Target artifacts:** `instance/charter/workspace.{md,yml}`, mission charter v3, run contract v1.
* **Move:** **add / normalize / harden**.
* **Migration:** derive run contracts from existing intent+mission during compatibility.
* **Enforcement:** no material execution without `run.yml`.
* **Evidence/uncertainty:** repo backlog confirms intent-layer work is still pending, so this is both necessary and aligned with current repo reality. ([GitHub][15])

### 3. Authority engine and host-adapter cutover

* **Current paths:** runtime policy interface, policy_engine crate, PR autonomy workflow, AI gate workflow.
* **Target artifacts:** `framework/engine/runtime/crates/authority_engine/`, host adapters, Approval/Grant/Lease/Revocation artifacts.
* **Move:** **add / re-bound / simplify**.
* **Migration:** labels remain projections until grants become canonical.
* **Enforcement:** all material actions require DecisionArtifact + GrantBundle.
* **Evidence/uncertainty:** current repo already has execution authorization and label-based approval; the missing step is centralization. ([GitHub][3])

### 4. Run-state normalization

* **Current paths:** mission control, continuity roots, receipt roots, kernel workflow execution.
* **Target artifacts:** `state/control/execution/runs/**`, `state/continuity/runs/**`, per-run evidence bundles.
* **Move:** **add / normalize**.
* **Migration:** dual-write mission-centric and run-centric artifacts for two release waves.
* **Enforcement:** resume path only through checkpoints and run manifests.
* **Evidence/uncertainty:** current runtime is lifecycle-shaped but not yet run-normalized. ([GitHub][1])

### 5. Evidence retention externalization

* **Current paths:** `state/evidence/**`, export profiles in `octon.yml`.
* **Target artifacts:** `framework/constitution/contracts/retention/**`, `state/evidence/external-index/**`, replay store.
* **Move:** **externalize / normalize**.
* **Migration:** keep control-plane evidence in Git; pointer large payloads to immutable store.
* **Enforcement:** export validator blocks invalid evidence-class placement.
* **Evidence/uncertainty:** current repo already excludes `state/**` and `generated/**` from clean repo snapshots; externalization is a natural extension. ([GitHub][1])

### 6. Proof-plane expansion

* **Current paths:** `architecture-conformance.yml`, `deny-by-default-gates.yml`, AI gate, mission scenario scripts.
* **Target artifacts:** functional/behavioral/recovery/governance disclosure suites under `framework/assurance/**`.
* **Move:** **preserve / add / harden**.
* **Migration:** current workflows stay blocking while new planes begin advisory, then become required by tier.
* **Enforcement:** release and support-tier promotion require multi-plane pass.
* **Evidence/uncertainty:** structural proof is already strong; behavioral and recovery proof are the primary gap. ([GitHub][4])

### 7. Lab domain introduction

* **Current paths:** mission live-validation and mission-autonomy scenario scripts.
* **Target artifacts:** `framework/lab/**`, `state/evidence/lab/**`.
* **Move:** **add / re-bound**.
* **Migration:** move current live-validation mission into a scenario pack while keeping mission artifact for legacy continuity until cutover.
* **Enforcement:** behavioral claims require lab evidence for supported workload tiers.
* **Evidence/uncertainty:** lab should be top-level because current evidence shows behavior testing exists but is not first-class. ([GitHub][8])

### 8. Model adapter formalization

* **Current paths:** provider-specific execution budgets, provider-specific AI review scripts.
* **Target artifacts:** `framework/engine/runtime/adapters/models/**`, adapter conformance suites.
* **Move:** **add / re-bound / simplify**.
* **Migration:** current OpenAI/Anthropic handling becomes adapter implementations.
* **Enforcement:** unsupported adapters fail closed.
* **Evidence/uncertainty:** high-confidence, because provider-specific seams are already visible today. ([GitHub][18])

### 9. Capability-pack expansion for browser/API

* **Current paths:** current capability/runtime surfaces and network-egress policy.
* **Target artifacts:** `framework/capabilities/packs/browser/**`, `framework/capabilities/packs/api/**`.
* **Move:** **add / harden**.
* **Migration:** admit only observe-only or stage-only modes first.
* **Enforcement:** capability contracts carry redaction, credential scope, and approval thresholds.
* **Evidence/uncertainty:** current egress policy is intentionally narrow; broader surfaces should arrive only after authority/disclosure are stable. ([GitHub][24])

### 10. Support-target matrix publication

* **Current paths:** locality scope and implicit provider/workload assumptions.
* **Target artifacts:** `instance/governance/support-targets.yml`, HarnessCard support declarations.
* **Move:** **add / harden**.
* **Migration:** start with reference support matrix matching current repo reality.
* **Enforcement:** authority engine denies unsupported tier combinations.
* **Evidence/uncertainty:** current scope file and provider-specific policy already imply a bounded support envelope. ([GitHub][25])

### 11. Agency-kernel simplification

* **Current paths:** agency manifest, architect AGENT, SOUL, ingress references.
* **Target artifacts:** `framework/agency/profiles/orchestrator/**`, optional overlays for identity/persona.
* **Move:** **simplify / re-bound / delete**.
* **Migration:** alias `architect` to `orchestrator` for one compatibility window.
* **Enforcement:** ingress reads orchestrator profile, not persona contract, by default.
* **Evidence/uncertainty:** current agency manifest already favors one accountable agent and disallows arbitrary delegation, which supports simplification. ([GitHub][6])

### 12. Disclosure normalization

* **Current paths:** retained evidence and workflow artifacts, but no RunCard/HarnessCard.
* **Target artifacts:** `state/evidence/disclosure/runs/**`, `instance/governance/disclosure/HarnessCard.yml`, `state/evidence/disclosure/releases/**`.
* **Move:** **add / normalize**.
* **Migration:** current receipts and decision artifacts feed first-generation RunCards.
* **Enforcement:** release or benchmark claims without disclosure artifacts are invalid.
* **Evidence/uncertainty:** current repo has the evidence plumbing but not the disclosure layer. ([GitHub][1])

## N. Transition Program and Stabilization Order

Use an explicit multi-wave program with compatibility windows and hard exit criteria. The guiding rule is: **stabilize authority and evidence before expanding action breadth**. Current repo reality already supports staged packetized cutovers, so the program should use that operating style rather than a big-bang rewrite. ([GitHub][10])

### Phase 0 — Baseline freeze and architectural inventory

* **Goal:** lock current repo constitution, runtime seams, and evidence surfaces into a baseline packet.
* **Workstreams:** architecture inventory, current-workflow evidence capture, baseline internal HarnessCard v0.
* **Repo deltas:** add `instance/governance/disclosure/HarnessCard.yml` as a baseline draft; add `framework/observability/disclosure/README.md`.
* **Dependencies:** none.
* **Compatibility window:** none; no behavior change.
* **Cutover trigger:** baseline packet merged.
* **Rollback/fallback:** none needed.
* **Exit criteria:** every current authoritative surface and live workflow seam is cataloged; current structural gates remain green.
* **Evidence required:** baseline packet, inventory log, baseline HarnessCard draft.

### Phase 1 — Constitutional extraction

* **Goal:** create the constitutional kernel without breaking existing behavior.
* **Workstreams:** create `framework/constitution/**`; extract charter, precedence, fail-closed, and evidence obligations; thin ingress.
* **Repo deltas:** add `framework/constitution/**`; convert `framework/cognition/_meta/architecture/specification.md` and ingress docs into shim-forwarders; update `octon.yml` to reference the charter manifest.
* **Dependencies:** phase 0 baseline.
* **Compatibility window:** one release wave where old and new constitutional surfaces both exist.
* **Cutover trigger:** instruction-layer manifest generation reads constitutional kernel first.
* **Rollback/fallback:** keep old docs authoritative until parity validator passes.
* **Exit criteria:** one canonical constitutional kernel exists; old surfaces are non-conflicting shims.
* **Evidence required:** constitution parity report; ingress parity report; green structural/gov gates.

### Phase 2 — Objective and authority cutover

* **Goal:** make run contracts and authority artifacts real.
* **Workstreams:** workspace charter pair, mission charter v3, run contract v1, Approval/Grant/Lease/Revocation/DecisionArtifact schemas, authority engine crate skeleton, GitHub adapter projection.
* **Repo deltas:** add `instance/charter/**`; populate `instance/governance/contracts/**`; add `state/control/execution/runs/**`, `approvals/**`, `revocations/**`; add `authority_engine` crate.
* **Dependencies:** phase 1.
* **Compatibility window:** two release waves; GitHub labels mirrored from grants.
* **Cutover trigger:** every material workflow emits a run contract and DecisionArtifact.
* **Rollback/fallback:** keep mission+intent-derived grants valid until explicit run-contract coverage reaches 100%.
* **Exit criteria:** no material execution path lacks a run contract; labels are no longer the source of authority.
* **Evidence required:** run-contract coverage report; authority parity report; zero unlabeled-authority paths.

### Phase 3 — Runtime and evidence normalization

* **Goal:** normalize execution around run manifests, checkpoints, run continuity, and evidence classes.
* **Workstreams:** run manifest, stage contract, checkpoint, continuity, replay index, evidence-retention contract, external evidence sink.
* **Repo deltas:** add `state/continuity/runs/**`, `state/evidence/external-index/**`, `framework/constitution/contracts/retention/**`, `replay_store` and `telemetry_sink` crates or modules.
* **Dependencies:** phase 2.
* **Compatibility window:** dual-write old receipts and new run bundles for two releases.
* **Cutover trigger:** replay validator can reconstruct supported runs from new artifacts alone.
* **Rollback/fallback:** runtime can still read old receipt roots if feature flag disabled.
* **Exit criteria:** runs can resume from checkpoints without chat history; evidence classes enforced; dual-write parity passes.
* **Evidence required:** replay success report, checkpoint-resume drills, evidence-class placement validator pass.

### Phase 4 — Proof expansion and lab introduction

* **Goal:** preserve strong structural proof while adding missing proof planes and first-class lab.
* **Workstreams:** functional suites, behavioral suites, recovery drills, governance disclosure checks, lab domain, scenario pack migration, evaluator adapters.
* **Repo deltas:** add `framework/assurance/functional/**`, `framework/assurance/recovery/**`, `framework/lab/**`, new CI workflows.
* **Dependencies:** phase 3.
* **Compatibility window:** new proof planes advisory for one release, then required by tier.
* **Cutover trigger:** at least one supported workload tier has passing behavioral and recovery suites.
* **Rollback/fallback:** structural/governance suites remain blocking while new planes iterate.
* **Exit criteria:** all six proof planes exist; live mission validation is a lab scenario pack; intervention logging mandatory.
* **Evidence required:** multi-plane benchmark packet, hidden-check policy, lab scenario run evidence.

### Phase 5 — Adapters and support-target hardening

* **Goal:** formalize model/host/capability adapters and publish support targets.
* **Workstreams:** model adapter contracts, host adapter contracts, adapter conformance suite, support-target matrix, browser/API pack admission policy.
* **Repo deltas:** add `framework/engine/runtime/adapters/**`, `instance/governance/support-targets.yml`, `framework/capabilities/packs/browser/**`, `api/**`.
* **Dependencies:** phase 4.
* **Compatibility window:** current provider workflows keep running as adapters until conformance suite is authoritative.
* **Cutover trigger:** first released model adapters pass conformance; support matrix published.
* **Rollback/fallback:** unsupported cases stay denied or stage-only.
* **Exit criteria:** provider-specific core logic removed from kernel governance; unsupported tiers fail closed deterministically.
* **Evidence required:** adapter conformance reports; support-target policy pass; browser/API admission packet if enabled.

### Phase 6 — Simplification and deletion

* **Goal:** remove host-shaped authority and persona-heavy kernel dependencies.
* **Workstreams:** rename kernel profile to orchestrator, demote `SOUL.md`, remove mission-only execution assumption, shrink assistants/teams from critical path, delete label-authority assumptions.
* **Repo deltas:** slim ingress, move persona docs to overlays, deprecate `architect` identity in kernel, retire duplicated constitutional prose.
* **Dependencies:** phases 1–5.
* **Compatibility window:** one release with aliases and shim readers.
* **Cutover trigger:** default ingress and runtime no longer depend on persona surfaces or host-shaped authority.
* **Rollback/fallback:** alias `architect` back to orchestrator for one release if needed.
* **Exit criteria:** one persona-heavy surface and one host-shaped authority path are actually deleted, not just deprecated.
* **Evidence required:** ablation report showing no regression in proof planes; ingress simplification report.

### Phase 7 — Build-to-delete operationalization

* **Goal:** make deletion and drift control permanent.
* **Workstreams:** retirement registry, ablation workflow, stale-doc detector, state drift detector, governance drift detector.
* **Repo deltas:** add `framework/observability/failure-taxonomy/**`, `framework/assurance/maintainability/**`, `state/evidence/benchmarks/**`, retirement registry under `instance/governance/contracts/retirement-policy.yml`.
* **Dependencies:** all prior phases.
* **Compatibility window:** none; this becomes normal operation.
* **Cutover trigger:** first release completes a formal retirement review and removes a compensating mechanism.
* **Rollback/fallback:** none, beyond reverting the deleted artifact if benchmark regressions emerge.
* **Exit criteria:** each release includes drift review, support-target review, adapter review, and deletion review.
* **Evidence required:** retirement ledger, drift reports, release HarnessCard with deletion summary.

### Final acceptance criteria — proof Octon is a unified execution constitution

Octon may claim the target state only when all of the following are true:

* The repo has a live constitutional kernel under `framework/constitution/**`.
* Every material run has a run contract, decision artifact, grant or denial, run manifest, checkpoint lineage, assurance reports, and RunCard.
* GitHub labels are adapters, not the authority source.
* Mission-backed and run-only autonomy are both explicitly modeled by policy and support tier.
* Structural, functional, behavioral, maintainability, governance, and recovery proof planes all exist and at least one supported tier requires all six.
* Lab is a top-level framework domain with replay/shadow/fault/scenario capabilities.
* Evidence retention classes are enforced and external replay payloads are hash-indexed.
* HarnessCard is published for the current release/support target.
* Hidden human repair is impossible without InterventionRecords.
* At least one mission-backed supported run and one run-only supported run complete end-to-end under the new pipeline.
* At least one persona-heavy or host-shaped scaffold has been deleted with no regression in proof planes.

If any of those are false, Octon is still in transition, not yet a fully unified execution constitution.

## O. Risks, Tradeoffs, and Unresolved Questions

The biggest risk is **constitutional duplication during migration**. Octon already has many real control surfaces; extracting a new constitutional kernel before deleting the old ones will temporarily increase redundancy. That is acceptable so long as the new kernel is clearly supreme and the old surfaces are shims with expiration dates. ([GitHub][14])

A second risk is **run-first vs mission-first tension**. Current repo law says no autonomous runtime path may silently fall back to mission-less execution. The proposal deliberately changes that for supported bounded run-only tiers. That refinement must therefore be treated as a constitutional amendment, not a quiet implementation detail. ([GitHub][1])

A third risk is **reviewability vs evidence completeness**. Externalizing replay-heavy artifacts is architecturally correct, but it adds operational dependency on immutable storage, signing, retention policy, and replay tooling. That is still preferable to forcing high-volume telemetry into Git, but it needs explicit ops ownership. ([GitHub][1])

A fourth risk is **public-repo benchmark leakage**. Truly hidden checks cannot live fully in a public tree. Octon therefore needs either sealed CI assets or private benchmark packs for anti-overfitting to be real rather than rhetorical. That is an operational dependency, not a design flaw, but it must be acknowledged. ([GitHub][23])

A fifth risk is **self-hosting overfit**. Octon’s current locality scope is tightly centered on `.octon` and the reference language/resource profile. If the support-target matrix is not made explicit, the project may mistake self-host success for generality. ([GitHub][25])

A sixth risk is **simplification backlash**. Demoting `architect` and `SOUL.md` from kernel path may feel like a loss of identity or ergonomics. The right response is to keep those surfaces as overlays, not to preserve them as mandatory execution dependencies. ([GitHub][13])

Additional unresolved questions worth validating during implementation:

* exact external replay backend and retention window,
* exact admission threshold for run-only autonomy vs mission-backed autonomy,
* whether `framework/cognition/**` should be renamed after constitutional extraction or simply de-normativized,
* how much of current generated summary structure should survive as operator UX vs be replaced by RunCards and reports.

## P. Final Recommendation

The single best path is:

**Keep Octon’s super-root and engine seams. Replace its fragmented constitutional logic with one constitutional kernel. Make run contracts atomic. Centralize authority. Normalize runtime around replayable run bundles. Add lab-grade behavioral proof. Publish support and disclosure honestly. Then simplify the agency kernel and delete host- and persona-shaped scaffolding that no longer carries architectural weight.** ([GitHub][1])

If Octon follows this packet, it will stop being merely a strong repository-shaped harness and become what its current architecture is already trying to be: a **constitutional, contract-governed, replayable, governable operating system for autonomous work**. The right implementation program is not to add more surface area first. It is to **finish the constitution, normalize the run, and let every other capability attach to that kernel**.

[1]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/README.md "raw.githubusercontent.com"
[2]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/README.md "raw.githubusercontent.com"
[3]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/config/policy-interface.yml "raw.githubusercontent.com"
[4]: https://github.com/jamesryancooper/octon/blob/main/.github/workflows/architecture-conformance.yml "octon/.github/workflows/architecture-conformance.yml at main · jamesryancooper/octon · GitHub"
[5]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/AGENTS.md "raw.githubusercontent.com"
[6]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/agency/manifest.yml "raw.githubusercontent.com"
[7]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/crates/kernel/src/main.rs "raw.githubusercontent.com"
[8]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/orchestration/missions/mission-autonomy-live-validation/mission.yml "raw.githubusercontent.com"
[9]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/policies/mission-autonomy.yml "raw.githubusercontent.com"
[10]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/state/continuity/repo/tasks.json "raw.githubusercontent.com"
[11]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/_meta/architecture/specification.md "raw.githubusercontent.com"
[12]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/contracts/README.md "raw.githubusercontent.com"
[13]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/ingress/AGENTS.md "raw.githubusercontent.com"
[14]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/octon.yml "raw.githubusercontent.com"
[15]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/bootstrap/OBJECTIVE.md "raw.githubusercontent.com"
[16]: https://github.com/jamesryancooper/octon/blob/main/.github/workflows/pr-autonomy-policy.yml "octon/.github/workflows/pr-autonomy-policy.yml at main · jamesryancooper/octon · GitHub"
[17]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/state/control/execution/exception-leases.yml "raw.githubusercontent.com"
[18]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/policies/execution-budgets.yml "raw.githubusercontent.com"
[19]: https://github.com/jamesryancooper/octon/blob/main/.github/workflows/deny-by-default-gates.yml "octon/.github/workflows/deny-by-default-gates.yml at main · jamesryancooper/octon · GitHub"
[20]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/execution-authorization-v1.md "raw.githubusercontent.com"
[21]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/execution-receipt-v2.schema.json "raw.githubusercontent.com"
[22]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/manifest.yml "raw.githubusercontent.com"
[23]: https://github.com/jamesryancooper/octon/blob/main/.github/workflows/ai-review-gate.yml "octon/.github/workflows/ai-review-gate.yml at main · jamesryancooper/octon · GitHub"
[24]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/policies/network-egress.yml "raw.githubusercontent.com"
[25]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/locality/scopes/octon-harness/scope.yml "raw.githubusercontent.com"

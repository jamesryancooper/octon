# Constitutional, Contract-Governed Control Plane for Autonomous Work

## A. Executive Architectural Thesis

The complete ideal target-state harness is a **constitutional, contract-governed control plane for autonomous work**. It is the extra-model system that binds intent to explicit objectives, routes all material action through deterministic authority checks, executes through mediated capabilities inside managed runtimes, verifies outcomes through layered proof mechanisms, records evidence sufficient for replay and audit, and continuously improves while deleting obsolete scaffolding as models strengthen. The model is a pluggable reasoning component inside this system, not the system itself.

Its irreducible kernel is: **objective contract, durable control surfaces, policy/authority router, mediated agency, managed runtime, multi-class verification, experimentation/lab infrastructure, governance and evidence plane, observability/disclosure plane, and an explicit evolution loop**. Full maturity requires both the **library side** of the harness—control artifacts, tools, memory, routing—and the **lab side**—behavioral auditing, scenario replay, fault injection, and experimental proof. Without both, the system may look structured yet still be ungoverned, behaviorally unverified, and scientifically under-specified.

The correct long-term design is therefore neither “thin loop plus prompt” nor “maximal orchestration.” It is a **stable portable kernel with replaceable adapters**, where the non-negotiables are machine-enforced and replayable, while model-specific tuning, topology choices, domain packs, and optimization tricks remain modular and deletable.

## B. Design Charter

**Normative language.** In this design, **MUST** means required for target-state correctness, **SHOULD** means required unless a justified exception is recorded, and **MAY** means optional within defined bounds.

**What the harness is.**
The harness is the governing operating layer for autonomous work. It turns a workspace or environment into a bounded execution domain by combining contracts, policy, runtime control, verification, and evidence into one system of record. It exists to make long-running autonomy reliable, reversible where possible, recoverable where needed, auditable always, and fail-closed under policy uncertainty.  

**What it is for.**
It is for converting human intent into bounded machine execution; for keeping action inside approved authority surfaces; for preserving continuity across long horizons; for producing evidence that supports accountability, debugging, reproducibility, and scientific reporting; and for concentrating human effort on policy authorship, exceptions, and review rather than routine execution.  

**What it is not.**
It is not a prompt wrapper, not product business logic, not an eval harness bolted on later, not a loose collection of tools or MCP servers, not a workflow framework that leaves authority implicit, and not a bypass around human governance. It does not replace application architecture decisions by fiat. It governs how such decisions are executed, verified, and evidenced.  

**Non-negotiable architectural obligations.**

1. No material execution without an explicit objective contract.
2. No material side effect before deterministic `allow`, `escalate`, or `block` routing.
3. No authority without bounded capability surfaces and least privilege.
4. No long-running work that depends on chat continuity instead of externalized state.
5. No consequential completion claim without deterministic or independent proof.
6. No meaningful autonomy claim without intervention accounting and replayable evidence.
7. No benchmark or production claim without harness disclosure.
8. No harness component is permanent unless it continues to prove load-bearing value.

## C. Target-State Architecture Overview

The complete target state is a **ten-layer architecture** with a stable kernel and modular overlays:

1. **Intent / Objective Layer** — binds work to explicit objective contracts.
2. **Durable Control Layer** — stores policy, architecture rules, specs, and system-of-record artifacts.
3. **Policy / Authority Layer** — resolves permission, approval, and escalation deterministically.
4. **Agency Layer** — exposes mediated action substrates through typed tool contracts.
5. **Runtime Layer** — manages lifecycle, state, checkpoints, recovery, resets, and budgets.
6. **Verification / Evaluation Layer** — proves structural, functional, behavioral, maintainability, and governance correctness.
7. **Lab / Experimentation Layer** — investigates real behavior under dynamic and adversarial conditions.
8. **Governance / Safety Layer** — enforces accountability, provenance, reversibility, and misuse boundaries.
9. **Observability / Reporting Layer** — records traces, replay bundles, metrics, and disclosure artifacts.
10. **Improvement / Evolution Layer** — mines failures, promotes rules, detects drift, and deletes obsolete scaffolding.  

The canonical operating loop is **PLAN → SHIP → LEARN**. PLAN binds objective, scope, materiality, and routing prerequisites. SHIP executes within approved bounds while emitting decision, execution, and assurance evidence. LEARN updates continuity, rules, docs, and policies based on observed gaps and outcomes. This loop is paired with a second loop: **observe failure → classify by layer → add minimal durable fix → validate → monitor → delete when obsolete**.

What many teams still treat as “outside the harness” but this architecture includes inside it: bootstrap/init logic, objective formalization, approval systems, lab environments, benchmark disclosure, doc-freshness maintenance, intervention logging, recovery posture, service-template governance, and model-adapter management. Those are not peripheral conveniences. They are part of the system that determines what the agent can know, do, and safely claim.

## D. Layered Architecture Specification

### 1. Intent / Objective Layer

**Purpose.** Bind every consequential run to an explicit, versioned objective rather than a conversational instruction.

**Responsibilities.**

* Define mission, scope, exclusions, success criteria, done-when criteria, acceptance context, materiality class, authority assumptions, protected zones, escalation triggers, and required evidence.
* Provide both a human-readable objective brief and a machine-readable intent contract.
* Prevent material execution when objective artifacts are missing, invalid, or divergent.

**Inputs.**

* Human intent.
* Applicable policy bounds.
* Workspace/domain context.
* Prior approved objective versions.

**Outputs.**

* Objective brief.
* Intent contract.
* Objective binding reference attached to every material run.
* Divergence records when artifacts drift.

**State ownership.**

* Owned by human policy/objective authorities.
* Runtime may read and bind to it, but may not silently widen it.

**Boundary conditions.**

* If brief and intent contract are not mutually consistent, the harness MUST block material execution and allow only read-only planning until reconciliation evidence exists.
* The intent contract is the execution-time authority; the brief is the interpretive narrative. Neither alone is sufficient.  

**Interactions.**

* Feeds Policy/Authority with routing prerequisites.
* Feeds Runtime with run scope and budgets.
* Feeds Verification with success criteria and acceptance tests.

### 2. Durable Control Layer

**Purpose.** Convert human judgment into versioned, machine-legible control surfaces that outlast any single session.  

**Responsibilities.**

* Maintain root ingress instructions, repo maps, architecture rules, schemas, feature ledgers, runbooks, decision records, specs, and done-when criteria.
* Separate normative surfaces from informative surfaces and mutable operational state.
* Keep the workspace/repository as the operational system of record.

**Inputs.**

* Policy and charter requirements.
* Domain architecture decisions.
* Runtime-discovered constraints promoted into durable artifacts.

**Outputs.**

* Canonical control surfaces.
* Discovery metadata that resolves to canonical runtime and governance surfaces.
* Drift signals when docs and reality diverge.

**State ownership.**

* Governance owns normative policy surfaces.
* Runtime owns executable contracts.
* Practices own operational guidance.
* `_meta` is explanatory only; `_ops` is operational only.

**Boundary conditions.**

* Monolithic always-on instruction files are not acceptable as the primary system of record.
* Workspace-local guidance MAY specialize higher layers but MUST NOT override them.

**Interactions.**

* Supplies authoritative context to Runtime and Agency.
* Supplies constraints and acceptance surfaces to Verification.
* Receives updates from Improvement when rules are promoted or docs are refreshed.

### 3. Policy / Authority Layer

**Purpose.** Determine what actions are permitted, who may authorize exceptions, and how ambiguity is resolved.  

**Responsibilities.**

* Classify materiality.
* Resolve applicable policy owner.
* Route actions to `allow`, `escalate`, or `block`.
* Enforce fail-closed behavior when prerequisites are missing.
* Maintain capability grants and protected zones.

**Inputs.**

* Objective contract.
* Authority surfaces and delegation boundaries.
* Applicable governance contracts.
* Materiality and risk classification.

**Outputs.**

* Decision artifact.
* Approval requirement or block result.
* Bound authority envelope for the run.

**State ownership.**

* Humans own policy content, owners, and exceptions.
* The harness owns routing execution and evidence validation.

**Boundary conditions.**

* The model may not interpret ambiguous authority into existence.
* Missing policy, tied ownership, or unresolved precedence MUST fail closed.

**Interactions.**

* Gates Agency before side effects.
* Feeds Governance and Observability with decision artifacts.
* Constrains Runtime recovery and retries when authority changes mid-run.

### 4. Agency Layer

**Purpose.** Give the model action surfaces that are useful enough to do real work but mediated enough to remain governable.  

**Responsibilities.**

* Expose filesystem, shell, browser, API, code execution, retrieval, observability, and experiment tools through typed contracts.
* Validate tool inputs server-side.
* Enforce capability scope and tool quotas.
* Support delegation when it buys isolation, specialization, or concurrency.

**Inputs.**

* Approved authority surfaces.
* Tool contract registry.
* Runtime context package.
* Delegation rules.

**Outputs.**

* Tool invocations and results.
* Action transcripts.
* Side-effect intents routed through policy.

**State ownership.**

* Tool state is external; invocation semantics are owned by tool contracts.
* The model owns only proposal and selection within allowed envelopes.

**Boundary conditions.**

* No unrestricted side effects.
* Multi-agent use is justified only for separation of duties, context isolation, or explicit parallelism.
* “Specialist roleplay” without real boundary value is disallowed.

**Interactions.**

* Uses Runtime for context assembly and checkpoints.
* Uses Policy for routing.
* Feeds Verification and Observability with action evidence.

### 5. Runtime Layer

**Purpose.** Manage long-running work as a lifecycle rather than a chat transcript.  

**Responsibilities.**

* Assemble context progressively.
* Externalize state into durable artifacts.
* Manage checkpoints, compaction, hard resets, retries, rollback posture, cleanup, budgets, and resumability.
* Provision workspaces, worktrees, sandboxes, and environment bootstrap.

**Inputs.**

* Objective contract.
* Control surfaces.
* Tool results.
* Checkpoints and continuity artifacts.
* Budgets and runtime policy.

**Outputs.**

* Run manifests.
* Checkpoints.
* Continuity artifacts.
* Archived replay bundles.
* Budget and latency metrics.

**State ownership.**

* Runtime owns ephemeral orchestration state.
* Continuity artifacts own cross-run memory.
* Workspace/repo own operational truth.

**Boundary conditions.**

* Chat history is not canonical continuity.
* Resumption MUST work from artifacts, not memory of the same thread.
* Hard reset is preferred over compaction when contamination or coherence failure is detected.

**Interactions.**

* Feeds Agency with context packages.
* Feeds Verification with environment state and run checkpoints.
* Feeds Improvement with failure and drift traces.

### 6. Verification / Evaluation Layer

**Purpose.** Produce proof, not reassurance.  

**Responsibilities.**

* Run deterministic validation first.
* Distinguish structural, functional, behavioral, maintainability, and governance verification.
* Invoke independent evaluators where deterministic proof runs out.
* Categorize failures and escalation triggers.

**Inputs.**

* Objective success criteria.
* Code, artifacts, and output state.
* Runtime traces.
* Telemetry and browser/UI surfaces.
* Hidden checks where appropriate.

**Outputs.**

* Assurance reports.
* Pass/fail verdicts per verification class.
* Escalation requests.
* Failure taxonomy entries.

**State ownership.**

* Acceptance criteria live in control artifacts.
* Evaluation results live in assurance artifacts.
* Hidden checks remain outside generator-visible context.

**Boundary conditions.**

* Self-verification is limited to low-risk local checks or non-consequential sanity checks.
* Consequential completion, subjective quality, and user-visible functionality require independent or deterministic proof.

**Interactions.**

* Gates Runtime completion.
* Feeds Improvement with missed-error categories.
* Feeds Governance when proof is insufficient for autonomy.

### 7. Lab / Experimentation Layer

**Purpose.** Discover behavior that static repo-aware execution cannot reveal.

**Responsibilities.**

* Run scenario tests, workload replay, fault injection, shadow mode, adversarial audits, and environment-level experiments.
* Validate behavior under dynamic, deceptive, or cross-system conditions.
* Produce behavioral evidence distinct from structural correctness.

**Inputs.**

* Candidate harness or run configuration.
* Scenario catalogs.
* Telemetry probes.
* Adversarial conditions.

**Outputs.**

* Behavioral audit reports.
* Fault-response traces.
* Robustness findings.
* New hidden checks and policy updates.

**State ownership.**

* Lab artifacts are durable but separated from routine work artifacts.
* Test scenario libraries are versioned and governed.

**Boundary conditions.**

* Lab results do not directly rewrite policy; they propose changes through the Improvement layer.
* Behavioral proof cannot be reduced to unit tests alone.

**Interactions.**

* Extends Verification beyond static checks.
* Feeds Governance and Improvement with red-team and robustness findings.

### 8. Governance / Safety Layer

**Purpose.** Make the system governable in practice, not merely constrained in prose.  

**Responsibilities.**

* Enforce permissioning, sandboxing, provenance, intervention logging, misuse boundaries, and recovery/irreversibility policy.
* Define human-led zones and protected governance surfaces.
* Maintain accountability ownership maps.

**Inputs.**

* Policy contracts.
* Decision artifacts.
* Authority grants.
* Intervention records.
* Risk-class taxonomy.

**Outputs.**

* Enforced boundaries.
* Governance incidents.
* Approval records.
* Compliance and risk summaries.

**State ownership.**

* Policy owners own rules and approvals.
* Harness owns enforcement and evidence.
* Humans own exceptions and adjudication.

**Boundary conditions.**

* Human steering does not erase required evidence.
* Silent privileged intervention is forbidden.
* Recovery posture must exist before risky material changes.

**Interactions.**

* Consumes decisions from Policy layer.
* Constrains Agency and Runtime.
* Feeds Observability and Disclosure with accountability artifacts.

### 9. Observability / Reporting Layer

**Purpose.** Make every consequential run reconstructable and every harness claim interpretable.  

**Responsibilities.**

* Persist traces, state transitions, approvals, failures, costs, latencies, checkpoints, and interventions.
* Support replay and comparison.
* Emit run-level and system-level reporting artifacts.

**Inputs.**

* Event streams from Runtime and Agency.
* Assurance artifacts.
* Decision and approval records.
* Measurement records.

**Outputs.**

* Replay bundles.
* Run reports.
* HarnessCard releases.
* Comparative dashboards and benchmark disclosures.

**State ownership.**

* Event and measurement storage are harness-owned.
* Public disclosure is governance-approved.

**Boundary conditions.**

* Claims without required evidence are invalid.
* Redaction is allowed only when the redaction itself is disclosed.

**Interactions.**

* Serves Verification, Governance, and Improvement.
* Provides reproducibility artifacts for benchmarking and research.

### 10. Improvement / Evolution Layer

**Purpose.** Improve the harness without letting it calcify into a pile of stale compensating mechanisms.  

**Responsibilities.**

* Harvest failures.
* Detect stale docs, state drift, and governance drift.
* Promote repeated failure patterns into durable rules, tools, or contracts.
* Run ablations to identify load-bearing vs obsolete scaffolding.
* Prune and delete expired harness components.

**Inputs.**

* Failure taxonomies.
* Replay bundles.
* Benchmark results.
* Intervention logs.
* Model-adapter performance deltas.

**Outputs.**

* Rule promotions.
* Updated docs and policies.
* Deleted or simplified components.
* Regression suites and updated support targets.

**State ownership.**

* Improvement artifacts are durable and versioned.
* No silent self-modification of kernel rules.

**Boundary conditions.**

* Every new harness component must carry a hypothesis of value and a deletion criterion.
* Build-to-delete is a mandatory maintenance practice, not an aspiration.

**Interactions.**

* Writes back into Control, Verification, Runtime, and Adapters through governed change processes.

## E. First-Class Components and Contracts

The following components MUST exist in the complete target state. They are first-class because leaving them implicit pushes control back into prompts, conventions, or hidden human memory.  

**Core components**

1. **Harness Charter** — constitutional document defining scope, precedence, ownership, and success signals.
2. **Objective Contract Compiler** — produces objective brief plus machine-readable intent contract.
3. **Policy Router** — performs materiality classification and `allow/escalate/block`.
4. **Authority Registry** — owners, delegation boundaries, protected zones, authority surfaces.
5. **System-of-Record Index** — repo map, canonical docs, feature ledgers, architecture rules.
6. **Tool Contract Registry** — schemas, semantics, scopes, failure classes, reversibility.
7. **Runtime Orchestrator** — run lifecycle, context assembly, checkpointing, retry, resume.
8. **Workspace Manager** — worktrees/sandboxes/init/bootstrap/cleanup.
9. **Continuity Manager** — append-only progress, decisions, follow-on work, checkpoint lineage.
10. **Deterministic Verifier Stack** — lint, type, tests, structural and policy gates.
11. **Independent Evaluator Stack** — graders, browser/UI checks, telemetry checks, hidden checks.
12. **Lab Runner** — behavioral audits, adversarial scenarios, workload replay, fault injection.
13. **Evidence Store** — decisions, actions, assurance artifacts, interventions, metrics, replay bundles.
14. **Disclosure Layer** — RunCard and HarnessCard generation.
15. **Improvement Engine** — failure harvesting, drift detection, rule promotion, deletion workflow.  

**Contract types**

**1. Objective Contract**
Mandatory fields:

* `objective_id`, `version`, `owner`
* `mission`
* `scope_in`, `scope_out`
* `constraints`
* `acceptance_criteria`
* `done_when`
* `risk_class`
* `authority_surfaces`
* `protected_zones`
* `required_evidence`
* `budget_envelope`
* `success_metrics`
* `escalation_conditions`
* `rollback_or_compensation_expectation`
* `expiry_or_review_date`
  The brief is human-readable; the intent contract is machine-readable and execution-authoritative.  

**2. Policy Rule Contract**
Mandatory fields:

* `policy_id`, `version`, `owner`
* `applies_to`
* `decision_class`
* `permitted_actions`
* `blocked_actions`
* `approval_requirements`
* `escalation_owner`
* `evidence_requirements`
* `exception_process`
* `effective_window`

**3. Tool Contract**
Mandatory fields:

* `tool_name`, `version`, `purpose`
* `input_schema`, `output_schema`
* `side_effect_class`
* `required_authority`
* `sandbox_scope`
* `idempotency`
* `reversible`
* `timeout_budget`
* `error_taxonomy`
* `observability_hooks`
* `server_side_validations`
* `allowed_callers`

**4. Run Manifest**
Mandatory fields:

* `run_id`
* bound `objective_ref`
* `policy_snapshot_ref`
* `workspace_ref`
* `model_adapter_ref`
* `topology`
* `budget`
* `start_state_ref`
* `verification_plan`
* `risk_class`
* `allowed_surfaces`

**5. Decision Artifact**
Mandatory fields:

* `run_id`, `decision_type`
* `deciding_actor`
* `controlling_rule_ref`
* `route` (`allow/escalate/block`)
* `time_or_sequence_marker`
* `prerequisites_satisfied`
* `approval_refs`
* `blocked_state_reason` if not allowed
* `linked_evidence_refs`

**6. Checkpoint Artifact**
Mandatory fields:

* `checkpoint_id`, `run_id`
* `workspace_snapshot_ref`
* `objective_ref`
* `open_tasks`
* `known_failures`
* `last_good_verification_ref`
* `next_step_hypothesis`
* `budget_remaining`
* `resume_instructions`
* `contamination_flags`

**7. Assurance Report**
Mandatory fields:

* `run_id`
* `verification_class`
* `check_set`
* `evaluator_identity`
* `pass_fail`
* `evidence`
* `known_gaps`
* `escalation_required`
* `anti_gaming_status`

**8. Continuity Artifact**
Mandatory fields:

* `run_id`
* `delta_summary`
* `decisions_made`
* `state_left`
* `follow_on_work`
* `learned_constraints`
* `append_only_sequence`
* `linked_checkpoint_ref`

**9. Intervention Record**
Mandatory fields:

* `run_id`
* `intervention_type`
* `human_actor`
* `reason`
* `what_changed`
* `before_after_refs`
* `visibility` (internal/public/redacted)
* `impact_on_result`

**10. Measurement Record**
Mandatory fields:

* `metric_id`, `owner`
* `method`
* `scope`
* `threshold`
* `evidence_artifact`
* `reporting_artifact`
* `review_cadence`

**11. RunCard**
A new required addition. It is the per-run disclosure artifact containing bound objective, route history, topology, model adapter, tool surfaces used, verification classes executed, interventions, costs, failures, and completion evidence.

**12. HarnessCard**
The system-level disclosure artifact describing base model(s), control artifacts, runtime policy, action substrate, execution topology, feedback stack, governance layer, observability, evaluation protocol, release artifacts, and known risks.  

## F. Control and Authority Model

The target state requires **two distinct precedence models**: one for **normative authority** and one for **epistemic grounding**. The conversation strongly implied the need for this split; the architecture now makes it explicit.  

**1. Normative authority precedence — what governs permission and obligation**

1. Applicable law and non-waivable external obligations.
2. Root ingress / organizational governance explicitly governing the same decision.
3. Harness charter / constitutional governance.
4. Domain governance contracts.
5. Active objective contract.
6. Capability delegation boundaries and tool/runtime contracts.
7. Workspace standards, architecture rules, specs, and approved conventions.
8. Informative documentation.
9. Mutable operational state.
10. Conversation residue and model priors, which never create authority.  

**2. Epistemic grounding precedence — what to believe about current reality**

1. Verified runtime observations and tool outputs.
2. Successful assurance results and telemetry.
3. Current repository/workspace state and canonical system-of-record artifacts.
4. Checkpoints and continuity artifacts with provenance.
5. Retrieved context and documentation.
6. Conversation history and user descriptions of past state.
7. Model priors.
   If runtime evidence contradicts documentation, reality wins for factual state, while documentation becomes a drift problem requiring update or escalation. It does not silently change normative policy.  

**Policy routing**

* Every material run MUST yield exactly one route: `allow`, `escalate`, or `block`, before any material side effect.
* `allow` authorizes execution only within the current objective contract and authority envelope.
* `escalate` pauses material execution pending a named owner decision.
* `block` denies execution and leaves the system fail-closed.
* If materiality, precedence, policy ownership, or objective validity cannot be resolved deterministically, the harness MUST fail closed.  

**Human vs machine authority**

* **Humans MUST own:** charter changes, policy changes, authority grants, exceptions, human-led zone overrides, destructive or irreversible actions above threshold, external commitments, disclosure sign-off, and incident adjudication.
* **Harness MUST mediate:** routing, evidence validation, capability issuance, fail-closed blocking, trace retention, replay, and measurement.
* **Model MAY own:** planning, bounded decomposition, read-only investigation, routine implementation, low-risk retries, and local strategy choice within approved bounds.
* **Model MAY NOT own:** policy interpretation under ambiguity, unapproved widening of scope, irreversible commitments, silent privilege acquisition, or final acceptance on consequential work.  

**Fail-closed rules**

* Missing objective artifacts, unresolved divergence, missing approval evidence, missing tool schema validation, unresolved owner ambiguity, or missing routing prerequisites MUST block material execution.
* Read-only planning, inspection, and drafting MAY continue while blocked, but cannot mutate governed state.  

## G. Execution and Runtime Model

The correct runtime model is **event-sourced, checkpointed, append-only, and resumable from artifacts rather than memory**. Long-running autonomous work is not a conversation; it is a managed run lifecycle.  

**Run lifecycle**

1. **Bootstrap** — establish canonical surfaces, init script, schemas, repo map, feature ledger, and minimum routing/assurance entry artifacts.
2. **Orient** — load objective, progress, feature ledger, recent decisions, and workspace state.
3. **Bind** — attach objective/version, classify materiality, resolve policy owner, and compute authority envelope.
4. **Plan** — produce bounded step plan and verification plan.
5. **Execute** — run mediated actions inside isolated workspace.
6. **Verify** — execute required validation classes.
7. **Checkpoint** — persist state, open issues, and recovery posture.
8. **Route again** — every newly proposed material action re-enters policy routing.
9. **Complete / Recover / Escalate** — based on proof and failure class.
10. **Learn / Archive** — emit continuity artifact, update ledgers, archive replay bundle.  

**State externalization and memory tiers**

* **Tier 0: Normative state** — charter, governance, objective contract.
* **Tier 1: System-of-record state** — repo/workspace facts, feature ledgers, specs, tests.
* **Tier 2: Continuity state** — progress logs, checkpoints, decision logs, follow-on work.
* **Tier 3: Ephemeral working state** — current reasoning context, scratchpads, temporary summaries.
* **Tier 4: Evidence state** — traces, assurance reports, telemetry, intervention logs.
* **Tier 5: Improvement state** — failure catalog, drift issues, rule backlog, deletion candidates.
  Only Tier 3 is disposable. Everything else is durable and versioned.  

**Checkpoint / resume**

* Checkpoints MUST occur before and after risky material changes, before delegation handoffs, on approaching context limits, and after verification milestones.
* Resume MUST require only the checkpoint bundle plus canonical surfaces, not prior chat continuity.
* Context compaction is an optimization; hard reset with structured handoff is the correctness mechanism when context contamination or “wrap-up pressure” appears.

**Retry model**

* **Transient retry** — infra/network/tool flake; bounded automatic retries.
* **Repair retry** — deterministic or likely-fixable failure with evidence.
* **Strategic retry** — plan changed after evaluator or lab result.
* **Blocked retry** — not allowed until approval or missing evidence is resolved.
  Retries are class-based and budgeted; they are not open-ended “try again.”

**Rollback and compensation**

* Every material change MUST declare rollback or compensation posture before execution.
* Reversible internal actions may proceed inside pre-approved rollback windows.
* Irreversible or external binding actions require stronger approval, explicit compensation plans, or both.  

**Environment and workspace lifecycle**

* One run or worker gets one isolated worktree/sandbox by default.
* Environment startup MUST be deterministic through bootstrap/init artifacts rather than rediscovery each session.
* Credentials are scoped, ephemeral, and capability-specific.
* Cleanup includes branch/worktree GC, stale lock cleanup, summary archival, and secret revocation.  

**Cost, latency, and token economy**

* Progressive disclosure is default.
* Stable prefixes and append-only context are preferred for cache efficiency where relevant.
* Hard resets are allowed when they increase coherence enough to justify orchestration overhead.
* Evaluators and sub-agents are used only where they buy reliability beyond their token and latency tax.  

## H. Verification and Evaluation Model

The correct model is **layered proof**, not “tests plus vibes.” Verification is partitioned into distinct classes because structural conformance, functional correctness, behavioral safety, maintainability, and governance are not the same property.  

**Validation classes**

1. **Structural verification** — lint, types, schemas, architecture rules, dependency boundaries, naming, conformance.
2. **Functional verification** — required behavior against explicit acceptance tests, feature ledgers, APIs, workflows.
3. **Behavioral verification** — real interaction under dynamic conditions, adversarial scenarios, UI/browser flows, organizational pressure tests, misuse opportunities.
4. **Maintainability verification** — future editability, architectural clarity, doc freshness, cleanup burden, bounded entropy.
5. **Governance verification** — correct routing, approval presence, provenance completeness, traceability, intervention disclosure.

**Self-verification boundaries**

* Acceptable for syntax, local invariant checks, and low-risk non-consequential sanity passes.
* Not acceptable as the sole acceptance mechanism for subjective quality, consequential user-visible output, external actions, or any work near the edge of current model capability. Separate evaluators are required there.  

**Independent evaluation requirements**
Independent evaluation is REQUIRED when:

* acceptance depends on judgment rather than a binary test,
* the generator can benefit from optimism bias,
* the run is high-risk or user-facing,
* completion claims would otherwise rest mainly on self-assessment,
* benchmark/reporting integrity matters,
* the task sits beyond what the current model reliably does solo.  

**Library vs lab**

* The **library side** is the durable apparatus for routine work: control artifacts, tools, memory, routing, and runtime.
* The **lab side** is the apparatus for discovering what the library misses: behavioral audits, shadow runs, replay, fault injection, cross-system validation, and adversarial experiments.
  A mature harness MUST contain both. Without the lab side, the system cannot justify claims about actual behavior in dynamic environments.

**Anti-overfitting protections**

* Hidden checks separated from tuning-visible checks.
* Held-out acceptance suites.
* Rotating evaluator prompts or models.
* Cross-model or diverse-grader review for high-risk cases.
* Adversarial scenario sampling.
* Mandatory logging of harness tuning changes against evaluator behavior.
* Layer-aware baselines that vary one layer at a time.

**Intervention disclosure**

* Hidden human repair, privileged intervention, and silent reviewer cleanup are prohibited as invisible inputs to success claims.
* Every intervention must be recorded with actor, reason, delta, and impact on the reported outcome.  

## I. Governance, Safety, and Accountability Model

The correct governance model is **deny-by-default, least-privilege, evidence-bound autonomy with named human ownership over exceptions and irreversible risk**. Governance is internal to the harness, not an external wrapper.  

**Permissioning and side-effect classes**

* **Class 0: Read-only / non-material.** Auto-allow within normal runtime.
* **Class 1: Internal reversible.** Auto-allow within objective and sandbox bounds if rollback posture exists.
* **Class 2: Internal durable shared-state mutation.** Allow only within approved authority surface and required verification plan.
* **Class 3: External non-binding or resource-consuming action.** Escalate unless pre-approved by policy.
* **Class 4: External binding, destructive, privacy/security sensitive, or irreversible action.** Human approval required; dual approval where policy demands.
  The target state uses this action-class model rather than vague “sensitive vs not sensitive” prompts.  

**Provenance and auditability**
Every material run MUST have:

* bound objective/version,
* route decision,
* owning authority,
* tool/action transcript or reference,
* verification artifacts,
* intervention history,
* completion or recovery result,
* replay bundle sufficient to reconstruct what happened and why.  

**Operational accountability**

* Humans own policy and exceptions.
* Agents own routine execution within bounds.
* The harness owns enforcement, evidence, and fail-closed behavior.
* Any new flow that can widen or suspend autonomy MUST have explicit decision owner, execution owner, and escalation owner before it is allowed.

**Misuse and dual-use**

* High-risk domains require domain-specific governance packs, reduced capability surfaces, stronger sandboxing, and stricter disclosure.
* Reliability improvements are recognized as dual-use; capability work and governance work are inseparable.

**Recovery windows and irreversible actions**

* Internal reversible changes MUST have named rollback owners and trigger conditions.
* Irreversible actions MUST disclose irreversibility explicitly and obtain elevated approval or compensation plans before execution.

## J. Observability, Replay, and Disclosure Model

The target state is **event-sourced and evidence-bearing**. If a run cannot be replayed at the level needed to understand objective, route, action, verification, and intervention, it is under-observed. If a harness claim cannot be disclosed at system level, it is under-specified.  

**Required trace model**
Every material run MUST persist:

* run manifest,
* route decisions,
* state transitions,
* tool/action events,
* checkpoint lineage,
* assurance results,
* cost and latency ledger,
* intervention records,
* final outcome and continuity artifact.

**Replay**
Replay MUST support:

* reconstruction of route-before-side-effect ordering,
* deterministic rehydration of control artifacts used,
* inspection of verification history,
* attribution of human intervention,
* comparison across harness versions and model adapters.
  Replay may use redacted references for sensitive artifacts, but the redaction boundary itself must be visible.  

**Disclosure model**

* **RunCard** is the per-run artifact.
* **HarnessCard** is the system release artifact.
  A valid HarnessCard discloses at minimum: base model(s), control artifacts, runtime policy, action substrate, execution topology, feedback stack, governance layer, observability, evaluation protocol, release artifacts, and known limitations/risks.  

**Scientifically meaningful claims require**

* explicit task set and number of runs,
* success criteria,
* budgets and variance treatment,
* hidden checks disclosure at the right abstraction,
* intervention accounting,
* layer-aware baselines,
* model vs harness attribution effort,
* known limitations and withheld elements.  

**Success signals**
At minimum, the harness should measure: objective binding rate, routing determinism, fail-closed enforcement, recovery readiness, traceability completeness, governance-drift rate, behavioral pass rate for critical scenarios, stale-doc rate, intervention density, and delivery efficiency within policy envelope. The first six are already directly implied by the charter-style success model; the remaining four are necessary to complete it.

## K. Portability and Adaptation Model

The correct approach is **portable kernel, non-portable adapters, explicit local overlays**. Portability is valuable for contracts, evidence, lifecycle, and disclosure. Non-portability is justified for model behavior, stack-specific enforcement, cache tactics, and environment-specific tools.  

**Portable kernel**
The following MUST remain portable across projects and model families:

* objective contract schema,
* policy routing semantics,
* precedence model,
* decision/evidence schemas,
* run lifecycle states,
* checkpoint/continuity model,
* verification class taxonomy,
* disclosure artifacts,
* intervention accounting,
* success-signal definitions.  

**Non-portable adapters**
The following SHOULD remain modular and replaceable:

* model prompt/adapter logic,
* decoding/effort configuration,
* context compaction and reset heuristics,
* tool descriptions and browser drivers,
* stack-specific linters and architecture checks,
* evaluator prompts/models,
* domain rule packs,
* cache and routing optimizations,
* UI automation specifics.  

**Model-family adaptation boundaries**
Every model family gets a **Model Adapter Contract** describing:

* tool-call semantics,
* context limits and contamination patterns,
* compaction/reset strategy,
* evaluator needs,
* known blind spots,
* safe autonomy envelope,
* supported action surfaces,
* regression suite expectations.
  No model-specific trick may mutate kernel governance semantics without a versioned design change.

**Local optimization boundaries**
Teams MAY optimize:

* topology,
* context packing,
* specific toolsets,
* stack-specific rules,
* evaluation intensity,
  but MUST NOT change:
* objective binding semantics,
* routing semantics,
* evidence completeness,
* intervention disclosure,
* replay requirements,
* policy ownership rules,
  without explicit governance versioning.

**Service-template implications**
For organizational rollout, the right form is a shared kernel plus installable domain packs, lint packs, testing packs, and policy packs. This avoids both full reinvention and a rigid monolith. Composable overlays must be order-safe and versioned to avoid drift across teams.

## L. Build-to-Delete and Evolution Model

The harness must improve the way good distributed systems improve: through explicit feedback loops, convergence criteria, and disciplined deletion. Every component encodes an assumption about current model weakness. When that weakness moves, the component becomes either optional or harmful.  

**What must stay stable**

* constitutional charter,
* precedence and routing semantics,
* objective binding,
* evidence schemas,
* replay requirements,
* intervention accounting,
* verification class taxonomy,
* disclosure minimums.

**What should remain replaceable**

* prompts and wording,
* decomposition heuristics,
* evaluator intensity,
* topology selection,
* cache and compaction strategies,
* tool masking/loading tactics,
* stack-specific rule implementations,
* model adapters.  

**Improvement loop**

1. Observe failure or recurring human intervention.
2. Classify the failure by layer.
3. Decide whether the fix belongs in control, agency, runtime, verification, governance, or documentation.
4. Add the smallest durable fix that closes the failure class.
5. Measure whether it helped.
6. Promote it to a rule/gate only if repeated and load-bearing.
7. Re-test under changed models.
8. Delete or demote when the component stops paying rent.  

**Stale-doc and drift detection**
The target state now formalizes three drift detectors:

* **Documentation drift detector** — docs/specs disagree with verified runtime behavior.
* **State drift detector** — checkpoints, progress ledgers, and actual workspace state disagree.
* **Governance drift detector** — runtime or operators behave outside approved policy.
  All three create first-class incidents and improvement backlog items.  

**Deletion protocol**
A harness component may be removed only after:

* layer-aware ablation,
* regression checks on representative workloads,
* no increase in intervention density or governance drift,
* no degradation in required verification classes,
* support-target review.
  Deletion is therefore governed, not ad hoc.

## M. Blind Spots Resolved

The following underweighted concerns are now explicit architectural objects:

* **Structural vs functionality verification:** separated into structural and functional verification classes with distinct gates.
* **Behavioral vs maintainability verification:** separated into behavioral and maintainability classes so neither hides inside the other.
* **Stale documentation detection:** formal documentation drift detector and doc-freshness obligations.
* **State drift:** state reconciler across repo state, progress ledgers, and checkpoints.
* **Memory contamination:** tiered memory, provenance, contamination flags, and reset triggers.
* **Context authority conflicts:** explicit split between normative precedence and epistemic precedence.
* **Verifier overfitting:** hidden checks, held-out suites, evaluator diversity, and tuning logs.
* **Hidden human repair / invisible supervision:** mandatory intervention records and disclosure.
* **Governance opacity:** named policy owners, decision artifacts, route traces, success signals.
* **Portability vs local optimization:** portable kernel plus explicit adapters and overlays.
* **Transferability across model families:** Model Adapter Contract and cross-family regression expectations.
* **Harness-specific overfitting:** layer-aware baselines and one-layer-at-a-time ablations.
* **Evaluation validity:** RunCard plus HarnessCard plus budget/intervention disclosure.
* **Recovery quality:** checkpoint lineage, recovery posture, and recovery-specific metrics.
* **Topology and service-template implications:** shared kernel, composable packs, order-safe overlays.
* **Constrained-runtime implications:** side-effect classes, protected zones, scoped authority surfaces.
* **Rollout/adoption shape:** stabilization order plus service-template model.
* **Multilingual / low-resource applicability:** support targets must include language/resource envelopes, not just frontier English environments.
* **Long-term entropy management:** cleanup agents, drift detection, deletion protocol.
* **Model-improvement resilience:** routine ablations and deletion reviews when models get stronger.
* **Built-to-delete:** formal component retirement policy rather than informal simplification hopes.

## N. Failure Modes and Anti-Patterns

1. **Prompt-centric pseudo-harness.** Control lives in giant instruction files and tribal memory. Result: brittle, opaque, non-replayable behavior.
2. **Implicit authority.** The model infers permission from vague context. Result: silent scope creep and unsafe side effects.
3. **Chat-as-runtime.** Continuity depends on thread history rather than artifacts. Result: context rot, premature completion, failed resumption.
4. **Generator as judge.** Same model generates and accepts consequential work. Result: lenient self-grading and under-detected defects.
5. **Structural-only assurance.** Linters and CI pass, but behavior is wrong. Result: elegant broken systems.
6. **No lab layer.** Static checks exist, but dynamic/adversarial behavior is untested. Result: false confidence in production behavior.
7. **Hidden-human harness.** Manual cleanup props up reported autonomy. Result: unscientific claims and operational surprise.
8. **Swarm theater.** Too many “specialists” without real boundary value. Result: cost, latency, and ambiguity without reliability.
9. **Ossified scaffolding.** Old compensating mechanisms remain after models improve. Result: drag, complexity, and overfit behavior.
10. **Unreported harness claims.** Benchmark or product claims omit runtime policy, interventions, or topology. Result: irreproducible and misleading comparisons.

## O. Delta from Implied Current/Near-Term State to Full Target State

The conversation had already established the right direction: harness over model, durable control over prompt tricks, objective binding, explicit policy routing, state externalization, managed runtime lifecycle, separate generation and verification, first-class observability, and build-to-delete discipline.  

To reach the **full** target state, this specification had to add or harden several things that were still underformalized:

* a **constitutional charter** rather than only directional principles,
* a split between **normative authority** and **epistemic grounding**,
* an explicit **side-effect taxonomy** and risk/routing model,
* formal **contract schemas** for objective, tools, decisions, checkpoints, assurance, and measurements,
* a required **RunCard** in addition to HarnessCard,
* a fully explicit **lab layer**, not just “better evals,”
* a **documentation/state/governance drift subsystem**,
* a **Model Adapter Contract** boundary for future model changes,
* a governed **deletion protocol**,
* and an organizational **kernel + overlay** model for rollout at scale.

Those additions are what make the design complete rather than merely directionally good.

## P. Recommended Stabilization Order

The correct order is the one that stabilizes authority and evidence before optimization. Teams that start with context tricks, topology, or observability polish before control semantics is coherent will build an instrumented mess.

**Phase 1 — Stabilize constitutional control**

* Charter, scope, authority owners, precedence ladder, canonical surfaces.
* Objective contract schema and routing prerequisites.
* Side-effect taxonomy and protected zones.

**Phase 2 — Make intent and evidence explicit**

* Run manifest, decision artifact, checkpoint, continuity artifact, measurement record.
* Objective compiler and approval artifact flow.
* Minimum replay bundle.

**Phase 3 — Machine-enforce the hard boundaries**

* Tool contract registry.
* Capability scoping and least privilege.
* Deterministic lint/schema/type/policy gates.
* Fail-closed blocking on missing prerequisites.

**Phase 4 — Stabilize runtime lifecycle**

* Worktree/sandbox isolation.
* Bootstrap/init flow.
* Progress ledgers, checkpoints, resets, resume, cleanup.
* Budget envelopes and retry classes.  

**Phase 5 — Separate proof from generation**

* Deterministic verifier stack first.
* Independent evaluators next where tasks exceed solo model reliability.
* Browser/UI and telemetry checks for user-visible behavior.

**Phase 6 — Add the lab**

* Scenario replay, adversarial audits, fault injection, shadow mode.
* Behavioral verification for critical workflows.
* Hidden-check discipline and anti-overfitting guardrails.

**Phase 7 — Standardize disclosure**

* RunCard and HarnessCard.
* Intervention reporting.
* Layer-aware benchmark baselines and attribution studies.

**Phase 8 — Optimize and modularize**

* Model adapters, domain packs, plugin packs, service templates.
* Cache/cost optimizations.
* Context and topology tuning.
  These can remain adaptable longer because kernel correctness does not depend on fixing them early.

**Phase 9 — Institutionalize deletion**

* Quarterly load-bearing review.
* Component ablations after model upgrades.
* Rule retirement and documentation pruning.

## Q. Open Questions

1. What is the best empirical threshold for when an independent evaluator pays for itself versus becoming overhead?
2. How should recovery quality be measured beyond “eventual completion”?
3. What is the right balance between compaction and hard reset across different model families?
4. Which parts of the control-precedence model can be standardized across domains, and which must remain domain-specific?
5. How should hidden checks be disclosed so evaluation remains honest without making the system trivial to game?
6. What is the minimal disclosure set for a community-standard HarnessCard that remains practical under proprietary constraints?
7. How well do these patterns transfer to multilingual, low-resource, and community-run settings?
8. What is the right formal interface for model adapters so portability claims become testable rather than rhetorical?
9. How can service-template and plugin-pack ecosystems avoid organizational drift while preserving local flexibility?
10. Which current scaffolding components are genuinely structural, and which are temporary crutches that should be deleted as models improve?

This is the complete target state: a **first-class, governed, evidence-rich operating system for autonomous work**. The architecture is complete only when intent, authority, action, runtime, proof, governance, replay, disclosure, and evolution are all formalized as one coherent system.

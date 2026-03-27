# Octon Harness Assessment

## A. Executive Assessment

Octon’s current repository is **not** a prompt wrapper or a thin agent loop. It is already a **repository-constitutionalized harness substrate** built around a single `.octon/` super-root, explicit class roots, fail-closed defaults, mission/autonomy policy files, retained continuity/evidence/control state, a Rust runtime workspace with launchers and schemas, and a large CI gate surface that validates architecture, deny-by-default posture, mission invariants, and protected-execution receipts. In current reality, Octon is best described as **a governed self-hosting harness with an emerging executable kernel**, not yet as a fully complete autonomous work control plane. ([GitHub][1])

Against the formal target-state harness model, Octon aligns **strongly** on durable control, explicit authority surfaces, repo/workspace system-of-record thinking, state externalization, fail-closed posture, typed runtime specs, and mission-scoped autonomy. It aligns only **partially** on unified constitutionalization, per-run objective binding, fully centralized policy routing, generalized runtime lifecycle semantics, behavioral proof, intervention accounting, replay/disclosure, and build-to-delete governance. The repository shows clear architectural intent in these directions, but several of its own continuity tasks still mark the intent layer and enforcement cutover as unfinished. ([GitHub][2])

The correct long-term Octon architecture is a **constitutional, contract-governed autonomous work control plane** that preserves Octon’s strongest current ideas—class-root separation, fail-closed routing, mission control, retained evidence, overlays, and portability discipline—but hardens them into a unified execution constitution: every consequential run bound to an explicit objective contract, every material side effect routed through a single authority engine, every runtime transition checkpointed and replayable, every completion backed by layered proof, every intervention recorded, and every obsolete scaffold explicitly deletable as models improve. ([GitHub][3])

## B. Repository-Grounded Current-State Architecture

I inspected the repository’s manifests, bootstrap and ingress surfaces, governance policies, mission artifacts, runtime launchers and command surfaces, continuity/evidence roots, and representative CI workflows. I did **not** line-audit every Rust crate or every shell validator, so where I discuss enforcement depth, that judgment is bounded to the surfaces I inspected directly.

What Octon currently **is**: a self-hosting harness organized around a single authoritative `.octon/` root with `framework/`, `instance/`, `inputs/`, `state/`, and `generated/` class roots. The repo-level README and `.octon/README.md` make that topology normative: only `framework/**` and `instance/**` are authored authority, `state/**` holds operational truth/evidence/control, `generated/**` is derived, and `inputs/**` is non-authoritative raw material. The root manifest `octon.yml` is the authoritative top-level manifest and sets fail-closed rejection mode, authority ordering, human-led zones, execution-governance modes, protected workflows, critical action types, and receipt roots. ([GitHub][4])

How the repository is actually structured: the top-level framework subsystems are `agency`, `assurance`, `capabilities`, `cognition`, `engine`, `orchestration`, `overlay-points`, and `scaffolding`. The engine/runtime area contains shell launchers, release target matrices, runtime config, schemas, WIT contracts, and a Rust workspace with crates including `kernel`, `core`, `policy_engine`, `assurance_tools`, `studio`, and `wasm_host`. The kernel CLI already exposes service discovery/invocation, workflow execution, validation, orchestration lookup/summary, stdio serving, and Studio launch surfaces. ([GitHub][5])

The major current control mechanisms are unusually explicit. The umbrella architecture specification defines root invariants, authoritative classes, SSOT rules, overlay semantics, fail-closed cases, and precedence across `framework`, `instance`, `state`, `generated`, and `inputs`. The contract registry defines canonical write roots, forbidden write prefixes, documentation classes, and blocking checks. The overlay registry restricts overlays to four legal points with defined merge semantics instead of allowing freeform shadowing. Root ingress files are adapter surfaces only; canonical ingress lives under `instance/ingress`, and root `AGENTS.md` or `CLAUDE.md` may not add extra runtime or policy text. ([GitHub][2])

The major current intent and authority mechanisms are also real, though incomplete. Octon has a workspace objective brief, a shared machine-readable intent contract, a canonical ingress that requires change-profile selection and receipts, a default agent manifest, an agency constitution, a delegation contract, a memory contract, repo-specific mission-autonomy/network-egress/execution-budget policies, and an ownership registry. At the same time, the repo’s own continuity backlog still shows `intent-layer-wave1-contract-foundation`, `intent-layer-wave2-enforcement`, and the final cutover gate as pending or blocked, which is strong evidence that Octon itself does **not** yet consider this layer fully complete. ([GitHub][6])

The major current runtime and continuity mechanisms are stronger than in most agent repos. Octon has retained `state/control`, `state/continuity`, and `state/evidence` roots; repo-wide continuity ledgers (`log.md`, `next.md`, `tasks.json`); mission registries and mission control roots; run/evidence retention roots; kernel command surfaces that require a `mission-id` for autonomous workflow execution; and execution-request objects in the kernel that enumerate requested capabilities and side-effect flags before write/report actions. CI workflows further enforce architecture conformance, runtime-effective-state checks, mission-runtime contracts, deny-by-default checks, and smoke validations. ([GitHub][7])

What is absent or still aspirational is just as important. I found no unified top-level harness charter, no explicit dual precedence model separating normative authority from epistemic grounding, no fully generalized per-run objective artifact, no fully populated governance-contract overlay set, no clearly normalized intervention-record artifact, no dedicated lab subsystem, and no standardized RunCard/HarnessCard disclosure surface. Some operational state scaffolds also exist in sparse form—`budget-state.yml` and `exception-leases.yml` are present but largely empty, and the governance contracts overlay directory is currently just a README placeholder. ([GitHub][8])

## C. Evaluation Against the Formal Target-State Harness Model

### 1. Design Charter / Constitutional Layer — **Status: partial-to-strong**

**Current Octon reality.** Octon already has constitutional material, but it is distributed across `octon.yml`, the umbrella architecture spec, ingress/bootstrap docs, and the agency constitution rather than unified in one canonical charter. Those surfaces already express non-negotiables such as fail-closed behavior, authoritative roots, protected workflows, no direct dependence on raw inputs, and no extra runtime-policy text in ingress adapters. ([GitHub][3])

**Strengths.** This is one of Octon’s strongest layers. It already treats “what may not be left to prompt convention” as architecture: class-root invariants, protected execution posture, authoritative ingress order, overlay boundaries, and hard-fail conditions are all spelled out in repository control surfaces, not just README prose. CI workflows then back some of those claims with structural enforcement. ([GitHub][2])

**Missing or weak.** The constitutional layer is still fragmented. There is no single explicit document or schema that says, in one place, what the harness is, what it is not, who owns which authority classes, what evidence is mandatory on every consequential run, and which fail-closed rules are kernel obligations rather than advisory practices. That fragmentation matters because target-state governance should not require reconstructing the constitution from several different surfaces. **Verdict:** directionally correct and unusually mature, but not yet fully formalized. ([GitHub][3])

### 2. Intent / Objective Layer — **Status: partial / transitional**

**Current Octon reality.** Octon has a workspace-level objective brief, a shared intent contract, and mission charters. The objective brief defines scope, out-of-scope constraints, and success signals; the shared intent contract adds authorized actions, hard boundaries, and tradeoff hierarchy; the active mission charter adds mission class, owner, risk ceiling, allowed action classes, and success/failure criteria. Kernel workflow execution also requires a `mission-id` for autonomous workflow runs. ([GitHub][6])

**Strengths.** Octon already understands that objective binding should be explicit and machine-legible. It also already distinguishes between workspace-wide purpose and mission-scoped autonomy, which is a strong target-state instinct. The mission-autonomy policy adds further behavioral posture by mission class. ([GitHub][9])

**Missing or weak.** The intent layer is not fully cut over, by Octon’s own admission: the continuity backlog still marks contract foundation and enforcement phases as pending. More importantly, I did not find a normalized **per-run** objective contract that binds a specific autonomous execution to scope, approvals, materiality, required evidence, and closure. Octon currently has workspace objective + shared intent + mission charter, but not yet the full three-way target-state split of workspace charter, mission charter, and run-specific objective contract. **Verdict:** strong direction, incomplete execution architecture. ([GitHub][10])

### 3. Durable Control Layer — **Status: strong**

**Current Octon reality.** This is Octon’s strongest layer. The super-root and class-root model are explicit; authoritative vs derived vs raw classes are clear; `framework/**` and `instance/**` are authored authority; `state/**` is operational truth/evidence/control; `generated/**` is rebuildable; the contract registry classifies documentation and write roots; overlay points are restricted and validated; root ingress surfaces are adapter-only. ([GitHub][11])

**Strengths.** Octon already distinguishes normative control from non-authoritative inputs far better than most harnesses. It already refuses freeform overlaying, directly encodes source-of-truth classes, and treats repository-local control artifacts as genuinely authoritative rather than advisory. Its control design is much closer to “versioned operating model” than “prompt pack.” ([GitHub][2])

**Missing or weak.** The current control-precedence model is strong but still incomplete relative to the target state. It orders class roots and agent-surface precedence, but it does not yet fully formalize the distinction between **normative authority precedence** and **epistemic grounding precedence** when runtime evidence conflicts with docs or task-local state. Some agency-facing prose surfaces are still much more verbose than they are enforceable. **Verdict:** largely target-state correct, but it needs a sharper authority/epistemics split and less dependence on long prose contracts. ([GitHub][2])

### 4. Policy / Authority Layer — **Status: partial-to-strong**

**Current Octon reality.** Octon has a real policy posture: fail-closed root manifest, policy-interface config that binds the runtime to mission autonomy, ownership, budget, network-egress, intent schema, and receipt surfaces, plus a formal execution-authorization spec that requires every material execution to pass through `authorize_execution(request) -> GrantBundle` before side effects. Repo-specific policy overlays include mission autonomy, network egress, and execution budgets. Ownership precedence is machine-readable. PR workflows add required `accept:human` labels for certain high-impact changes and upload protected-execution receipts. ([GitHub][3])

**Strengths.** Octon clearly understands explicit routing, bounded authority, and deny-by-default. The network-egress policy is especially tight today, allowing only a localhost LangGraph forwarding path. Mission policy includes autonomy burn thresholds, pause-on-failure triggers, safe-interrupt boundaries, and recovery windows. That is serious governance thinking, not generic “guardrails.” ([GitHub][9])

**Missing or weak.** This layer is not yet unified enough. Governance-contract overlays are mostly absent, the ownership registry is still very small, exception leases and budget state are sparsely populated, and approval semantics are still partly embodied in workflow-specific logic such as PR labels rather than a single generic approval/exception engine. I also did not find a complete, repository-wide decision matrix that cleanly separates what humans own, what the harness mediates, and what the model may decide autonomously in all cases. **Verdict:** powerful proto-governance, not yet a fully centralized authority control plane. ([GitHub][8])

### 5. Agency Layer — **Status: mixed**

**Current Octon reality.** Octon has real mediated agency surfaces: capabilities are separated from engine execution, typed specs and WIT contracts exist, the kernel CLI exposes service/workflow/orchestration commands, and service/workflow actions construct `ExecutionRequest` objects with explicit requested capabilities and side-effect flags. The default agent manifest names a single default agent (`architect`) and explicitly disables skill-actor delegation by default. ([GitHub][12])

**Strengths.** The mediated action substrate is good. Octon is not giving the model an untyped bag of tools; it is already closer to a typed capability regime. The default stance against freeform delegation is also target-state correct: better a single accountable orchestrator than swarm theater. ([GitHub][13])

**Missing or weak.** The actor layer is still a little too persona-centric relative to the target state. The `architect` contract and agency document stack are rich in prose, but the most important separation-of-duties boundaries—generator vs verifier vs approver vs operator—are not yet fully reified as kernel-level role contracts. I also did not see a first-class browser action substrate in the inspected capability/runtime surfaces; Octon today is mainly repo/runtime-oriented rather than a general multi-surface action harness. **Verdict:** action mediation is good; agency abstraction needs simplification and harder role boundaries. ([GitHub][14])

### 6. Runtime Layer — **Status: partial-to-strong**

**Current Octon reality.** Octon already treats runtime more as a lifecycle than as a conversation. It has launchers, a kernel, runtime config, mission registries, control/evidence/continuity roots, continuity ledgers, mission control/effective route/summaries roots, and receipt roots for kernel/services/workflows/executors/CI. Workflow execution requires `mission-id` for autonomous runs. The memory contract defines memory classes and flush rules, and continuity surfaces are append-oriented. ([GitHub][15])

**Strengths.** This is stronger than most current harnesses. Octon clearly does not think chat history is enough. It has durable operational state, append-oriented evidence, mission-aware routing, and CI/runtime artifacts that preserve continuity and provenance. The launcher/runtime also show real packaging and cross-platform execution concern. ([GitHub][16])

**Missing or weak.** The runtime is still not yet a fully normalized event-sourced run model. I did not find a canonical run manifest, checkpoint schema, intervention record, or replay bundle contract that every consequential run must produce. Rollback/compensation semantics are still stronger in policy language than in normalized runtime artifacts. Some control scaffolds are present but not yet richly populated. **Verdict:** runtime is already lifecycle-shaped, but still short of complete run-state constitutionalization. ([GitHub][17])

### 7. Verification / Evaluation Layer — **Status: structurally strong, behaviorally weak**

**Current Octon reality.** Octon has a large assurance surface and many CI gates. Architecture conformance validates version parity, architecture conformance, mission runtime contracts, mission intent invariants, lifecycle cutover, runtime effective state, route normalization, mission-generated summaries, and mission control evidence. Deny-by-default gates enforce protected execution posture and capability/engine consistency. Smoke checks validate structure, repo-instance boundary, locality registry/publication state, and workflows. There is also an AI review gate that generates a decision artifact, blocker labeling, and protected-execution receipt. ([GitHub][18])

**Strengths.** Structural verification, governance verification, and conformance validation are already very strong. Octon is unusually serious about proving that its architecture, policy surfaces, mission routing, and generated/effective state remain coherent. That is a real strength, and it should be preserved. ([GitHub][19])

**Missing or weak.** Octon is still much better at proving **structural correctness** than **functional or behavioral correctness**. I did not find a comparably mature layer for end-to-end user-behavior proof, evaluator diversity, hidden checks, browser/UI validation, or systematic adversarial testing beyond mission/autonomy scenario scripts. The AI review gate is helpful, but it is a PR review control, not yet a generalized independent evaluator architecture for all consequential runs. **Verdict:** excellent structural assurance, incomplete proof of real behavior. ([GitHub][19])

### 8. Lab / Experimentation Layer — **Status: weak / emerging**

**Current Octon reality.** Octon has some seeds of a lab side: the `mission-autonomy-live-validation` mission is explicitly meant to exercise mission-scoped reversible autonomy end-to-end, and architecture-conformance runs mission autonomy scenarios and an autonomy burn reducer test. But there is no dedicated top-level experimentation or lab subsystem in the framework; current scenario work is attached to assurance workflows and a single live-validation mission. ([GitHub][20])

**Strengths.** Octon at least recognizes that autonomy behavior should be exercised on live surfaces, not just reasoned about abstractly. That is good target-state instinct. ([GitHub][20])

**Missing or weak.** The lab side is still underformed. There is no first-class subsystem for workload replay, fault injection, shadow runs, environment-level experimentation, evaluator red-teaming, or operational discovery as its own governed layer. **Verdict:** emerging, but far from target-state complete. ([GitHub][5])

### 9. Governance / Safety Layer — **Status: strong for repo engineering, incomplete as a general control plane**

**Current Octon reality.** Governance is real, not ornamental. Octon has hard-enforce policy modes, protected workflows and refs, critical action types, deny-by-default capability gates, network egress restrictions, budget thresholds, mission risk ceilings, safe-interrupt and pause-on-failure semantics, and PR-level human-accept labels for certain high-impact changes. It also retains decision/control evidence and CI receipts. ([GitHub][3])

**Strengths.** For a repo engineering harness, Octon is already materially governable. The combination of protected execution posture, egress constraints, receipt emission, and policy overlays is much better than “be careful” prompt text. ([GitHub][21])

**Missing or weak.** I did not find a generalized intervention ledger, explicit compensation records for irreversible actions, or a broad misuse/dual-use governance model beyond the current repo-engineering context. Human intervention is partly surfaced through labels and approvals, but not yet normalized as a first-class artifact across all run types. **Verdict:** serious governance core, incomplete accountability instrumentation. ([GitHub][17])

### 10. Observability / Reporting Layer — **Status: partial**

**Current Octon reality.** Octon already stores retained evidence under `state/evidence/**`, including runs, decisions, validation, migration, and control/execution evidence. The root manifest defines receipt roots for kernel, services, workflows, executors, and CI. The AI gate uploads decision artifacts and protected-execution receipts. The kernel also exposes read-only orchestration lookup, summary, and incident-closure-readiness surfaces. ([GitHub][17])

**Strengths.** The raw plumbing is good: Octon already believes in evidence retention, receipts, and operator inspection. This is a strong substrate for target-state observability. ([GitHub][17])

**Missing or weak.** The evidence is not yet fully normalized into a run-level and system-level disclosure model. I did not find a standardized RunCard, HarnessCard, replay bundle contract, or layer-aware benchmark disclosure artifact. Cost/budget policy exists, but live measurement, latency accounting, and categorized failure analytics are not yet obviously unified in one reporting plane. **Verdict:** good evidence plumbing, incomplete disclosure architecture. ([GitHub][22])

### 11. Improvement / Evolution Layer — **Status: partial**

**Current Octon reality.** Octon has an active continuity log, next-step ledger, and task backlog; it archives completed architecture proposal packets; it ships migration workflows in the root manifest; and it has extension profiles and portability/export logic. That shows ongoing self-evolution and willingness to cut over architecture deliberately rather than accumulating only ad hoc patches. ([GitHub][23])

**Strengths.** The project already operates with architectural packets, cutovers, continuity, and migration thinking. That is a strong base for build-to-delete discipline. ([GitHub][10])

**Missing or weak.** What is still missing is the explicit target-state evolution machinery: formal stale-doc detection as a generalized subsystem, state/governance drift detectors with incident semantics, model-adapter contracts, layer-aware ablation benchmarks, and a component retirement protocol that says when scaffolding must be removed after models improve. **Verdict:** disciplined evolution culture, incomplete evolution architecture. ([GitHub][10])

## D. Formal Long-Term Octon Target-State Harness Architecture

The complete ideal future Octon should preserve its **super-root and class-root architecture**, but elevate it into a fully unified **execution constitution**.

**Charter / constitutional layer.** Octon should add a single canonical harness charter—human-readable plus machine-readable—that supersedes the current fragmentation across `octon.yml`, umbrella spec, ingress, and agency constitution. That charter should state what Octon is, what it is not, which invariants are kernel-enforced, what evidence every consequential run owes, who owns exceptions, and which fail-closed rules are non-waivable. The current distributed constitutional surfaces are the right raw material; they should become one constitutional kernel. ([GitHub][3])

**Objective layer.** Octon should formalize three objective strata: a **workspace charter** for the repo, a **mission charter** for long-running autonomous programs, and a **per-run objective contract** for each consequential execution. The current workspace objective brief, shared intent contract, and mission file are a start, but the target state requires per-run contracts that bind scope, exclusions, risk class, approval requirements, protected zones, required evidence, and closure semantics to a specific run ID. ([GitHub][6])

**Durable control layer.** Octon should keep the framework/instance/inputs/state/generated split, restricted overlay points, and authored-authority rules. What it should add is a fully formal **dual precedence model**: one ladder for normative authority, one for epistemic grounding. That would let Octon resolve the common target-state problem where runtime evidence contradicts docs or generated summaries without collapsing governance and factual reality into one ambiguous precedence scheme. ([GitHub][2])

**Policy / authority layer.** Octon should centralize its current policy fragments into a single authority engine that resolves materiality class, owner, required approvals, allowed capability surface, rollback/compensation requirement, and `allow/escalate/block` route before any material side effect. Current policies—mission autonomy, egress, budgets, ownership, protected workflows—should become inputs to that engine rather than partially parallel governance surfaces. ([GitHub][24])

**Agency layer.** Octon should keep its typed capability substrate, service boundaries, and single-orchestrator bias. But it should simplify agency from persona-heavy contracts toward explicit execution roles with real boundary value: planner, worker, verifier, operator, and possibly specialized capability adapters. Multi-agent execution should remain optional and justified only for separation of duties, context isolation, or real concurrency—not as theater. ([GitHub][13])

**Runtime layer.** Octon should become fully event-sourced at the run level. Every consequential run should produce a run manifest, objective binding, route decision, capability grants, checkpoints, continuity artifact, assurance report, intervention record, and replay bundle. Current state/control, state/continuity, and state/evidence roots are the right substrate; the missing step is to normalize every run through them rather than relying on a mix of receipts, ledgers, and implicit conventions. ([GitHub][7])

**Verification / evaluation layer.** Octon should preserve its structural/governance validators and add equally strong functional, behavioral, maintainability, and governance acceptance classes. The AI review gate and mission scenario tests are useful beginnings, but the target state requires explicit independent evaluator roles, hidden checks where appropriate, and separate proof classes so “the architecture is coherent” never masquerades as “the autonomous work actually succeeded.” ([GitHub][19])

**Lab / experimentation layer.** Octon should introduce a first-class lab subsystem. The current live-validation mission and scenario scripts should evolve into a formal experimentation plane for workload replay, fault injection, shadow execution, red-team scenarios, and operational discovery. The lab side should not remain buried in assurance scripts. ([GitHub][20])

**Governance / safety layer.** Octon should make intervention accounting, approval leases, exception lifecycles, compensation posture, and irreversible-action rules first-class artifacts. PR labels and workflow gates are directionally useful, but in the target state those approvals should be generic control-plane artifacts rather than repo-host-specific special cases. ([GitHub][25])

**Observability / reporting layer.** Octon should normalize its evidence plane into **RunCard** and **HarnessCard** disclosures. It already has evidence roots and receipts; it should add standardized replay bundles, failure taxonomies, intervention logs, measurement records, and explicit benchmark disclosure schemas so its claims are operationally and scientifically interpretable. ([GitHub][17])

**Improvement / evolution layer.** Octon should formalize build-to-delete. Proposal cutovers and migration workflows show the right instincts, but the target state requires explicit ablation reviews, stale-control retirement, model-adapter contracts, and deletion criteria for scaffolding that no longer carries its weight. ([GitHub][23])

## E. Required First-Class Components, Contracts, and Boundaries

In the full target state, Octon must contain the following as **first-class** architectural objects:

* A **unified Harness Charter** and machine-readable charter manifest.
* A three-tier objective system: **workspace charter**, **mission charter**, and **per-run objective contract**.
* A centralized **authority router** that resolves materiality, owner, approval, capability scope, and `allow/escalate/block`.
* A formal **normative precedence model** and separate **epistemic grounding model**.
* A typed **capability/tool contract registry** for services, workflows, executors, and external surfaces.
* A normalized **Run Manifest** contract.
* A normalized **Decision Artifact** contract.
* A normalized **Execution Grant / Receipt** contract.
* A normalized **Checkpoint** and **Continuity Artifact** contract.
* A normalized **Assurance Report** contract covering structural, functional, behavioral, maintainability, and governance proof classes.
* A normalized **Intervention Record** contract.
* A normalized **Measurement Record** contract.
* A standardized **RunCard** and **HarnessCard** disclosure surface.
* A first-class **Lab subsystem** with scenario, replay, fault injection, and red-team contracts.
* A formal **Model Adapter Contract** boundary for future model-family differences.
* A formal **Deletion / Retirement Protocol** for obsolete controls.

The essential control boundaries should be:

* `framework` vs `instance` vs `state` vs `generated` vs `inputs` must remain hard architectural boundaries.
* Humans own policy, exceptions, irreversible approvals, and disclosure sign-off.
* The harness owns routing, enforcement, evidence, replay, and fail-closed behavior.
* The model owns bounded planning and execution strategy **within** the approved envelope.
* Generation, verification, and authority must stay separated.
* No material side effect may happen before routing and grant issuance.
* No consequential completion may be accepted without required assurance artifacts.

## F. Major Gaps, Tensions, Contradictions, and Incompletions

The biggest architectural gap is that Octon is currently **better constitutionalized than it is execution-normalized**. It knows how authority should be laid out, but not every consequential run is yet forced through a single typed objective → route → execute → verify → disclose pipeline. That is the core gap between “governed harness repository” and “complete autonomous work control plane.” ([GitHub][3])

A second gap is that Octon’s **intent layer is acknowledged incomplete by the repo itself**. The current surfaces are good, but pending tasks around contract foundation and enforcement mean the project has not yet closed the loop from objective prose and contract artifacts into fully generalized runtime enforcement. ([GitHub][10])

A third gap is **verification asymmetry**. Octon is much stronger on architecture conformance, governance posture, and source-of-truth integrity than it is on proving that autonomous work product is functionally and behaviorally correct under realistic conditions. This is the classic failure mode of architecture-heavy harnesses, and Octon is not yet past it. ([GitHub][19])

A fourth gap is that the **policy/authority layer is still partly repository-host-shaped**. GitHub labels and workflow-specific rules are useful, but they are not yet the same thing as a fully generic control-plane approval and exception model. That makes current governance stronger in GitHub PR flows than in the full abstract harness architecture Octon aspires to be. ([GitHub][25])

A fifth gap is **over-documentation risk**. Octon’s document and contract surfaces are impressive, but some actor and agency layers remain more richly narrated than they are runtime-enforced. That is not fatal, but it is exactly where sophisticated harnesses can accumulate architectural theater if they do not keep consolidating prose into machine-enforced contracts. ([GitHub][14])

A sixth gap is **underformalized disclosure**. Evidence roots and receipts exist, but there is still no single normalized story for “what happened on this run,” “who intervened,” “what was proved,” and “what claim is justified.” Octon has the plumbing; it still needs the reporting constitution. ([GitHub][17])

## G. Blind Spots and Underformalized Concerns

* **Structural vs functionality verification:** strong on the former, weaker on the latter. Octon’s CI is rich in conformance checks, but I did not find equally mature functional acceptance machinery for autonomous outcomes. ([GitHub][19])
* **Behavioral vs maintainability verification:** maintainability/architecture health are foregrounded; behavioral proof is still light outside mission-autonomy scenarios. ([GitHub][20])
* **Stale documentation detection:** Octon already fail-closes on some generated staleness and runs alignment checks, which is better than most repos. But doc-freshness detection is still not a generalized subsystem spanning all authoritative docs and runtime-observed behavior. ([GitHub][3])
* **State drift:** continuity, evidence, and control roots exist, which is excellent; what is still missing is a generalized state reconciler that can classify and repair drift across repo state, mission state, run state, and generated state. ([GitHub][7])
* **Memory contamination:** the memory contract is explicit about memory classes and flush rules, but I did not find a formal contamination detector or universal hard-reset policy across runtime paths. ([GitHub][26])
* **Context authority conflicts:** Octon has class-root precedence, but it still needs the explicit normative-vs-epistemic split so runtime reality and governance authority are never conflated. ([GitHub][2])
* **Verifier overfitting:** there is little visible evidence yet of hidden checks, evaluator diversity, or held-out behavioral suites. ([GitHub][27])
* **Hidden human repair / invisible supervision:** PR labels and gate outcomes are surfaced, but I did not find a universal intervention ledger for all run types. ([GitHub][27])
* **Governance opacity:** governance exists, but ownership is still thinly populated and governance contracts are still sparse. ([GitHub][28])
* **Portability vs local optimization:** Octon is already serious about portability—export profiles, extension trust, release targets, runtime packaging—but model-family adaptation is not yet formalized as its own contract boundary. ([GitHub][3])
* **Transferability across model families:** current budget policy explicitly references OpenAI- and Anthropic-backed workflow stages, which is practical but not yet a full model-adapter architecture. ([GitHub][22])
* **Harness-specific overfitting:** Octon is self-hosting on itself, which is powerful but creates real risk of overfitting to Octon’s own repository topology and governance shape. ([GitHub][6])
* **Evaluation validity:** evidence is retained, but no standardized RunCard/HarnessCard or layer-aware benchmark disclosure artifact is visible yet. ([GitHub][17])
* **Recovery quality:** mission policy talks about recovery windows and pause triggers, but run-level recovery quality is not yet a first-class measured contract. ([GitHub][9])
* **Topology and service-template implications:** overlays and extensions exist, but organizational rollout as a stable kernel + domain pack ecosystem is not yet fully formalized. ([GitHub][29])
* **Constrained-runtime implications:** current agency is heavily repo-centric and network-egress constrained; that is good for safety, but Octon still needs an explicit statement of where its support target ends. ([GitHub][30])
* **Rollout/adoption implications:** the architecture is strong, but the repo is already cognitively dense. Adoption needs a clearer kernel/overlay packaging model or Octon risks becoming easier to admire than to adopt. ([GitHub][3])
* **Multilingual / low-resource / non-frontier applicability:** the active locality scope lists Markdown, YAML, Bash, JSON, and Rust; I saw no explicit support-target articulation for broader language/resource regimes. ([GitHub][31])
* **Long-term entropy management:** continuity logs and packet archives are good beginnings, but deletion criteria for scaffolding are not yet explicit. ([GitHub][23])
* **Resilience under stronger future models:** current agency and ingress prose may preserve assumptions about current model weakness longer than necessary unless Octon adds formal deletion reviews. ([GitHub][14])
* **Built to delete:** Octon archives proposal packets, but it does not yet require every compensating mechanism to carry a retirement test. ([GitHub][10])

## H. Failure Modes and Anti-Patterns

If Octon remains in its current incomplete state, the biggest failure mode is **constitutional prose outrunning execution reality**: the architecture becomes impressively specified, but runs are still not uniformly bound, routed, evidenced, and disclosed. That would make Octon legible on paper yet still inconsistent in practice. ([GitHub][2])

A second failure mode is **structural assurance masquerading as total assurance**. Octon could keep passing architecture, alignment, and mission-integrity gates while still lacking proof that the autonomous work output was functionally or behaviorally right. ([GitHub][19])

A third failure mode is **governance fragmentation**: part policy file, part workflow logic, part label convention, part operator habit. Octon already has enough governance that fragmentation is now the risk, not lack of governance. ([GitHub][9])

A fourth failure mode is **actor-model theater**. If agency remains persona-heavy and only partially runtime-enforced, Octon can accumulate role complexity without gaining real separation of duties. ([GitHub][13])

A fifth failure mode is **self-hosting overfit**. Because Octon evolves itself inside its own architecture, it can become extremely optimized for the Octon repo while under-testing transfer to other repository shapes and model families. ([GitHub][6])

A sixth failure mode is **evidence without disclosure**. Retained receipts and state roots are good, but without a normalized run/reporting model they can become an archive that is difficult to interpret or compare. ([GitHub][17])

## I. Delta from Current Octon Reality to Full Target State

The delta is not “add more agent features.” The delta is to turn Octon’s current **repository constitution** into a full **execution constitution**.

What must be added or hardened:

* Consolidate the distributed constitution into a single top-level charter plus machine-readable charter manifest.
* Finish the intent-layer cutover and add a first-class **per-run objective contract**.
* Separate normative authority precedence from epistemic grounding precedence.
* Centralize policy, approval, exception, and ownership resolution into one authority engine.
* Normalize runtime around run manifests, checkpoints, decision artifacts, intervention records, and replay bundles.
* Keep structural assurance but add equally serious functional, behavioral, and independent evaluation layers.
* Create a dedicated lab subsystem instead of leaving experimentation implicit.
* Add RunCard and HarnessCard disclosure artifacts.
* Add model-adapter contracts and support-target declarations.
* Add formal build-to-delete governance and deletion criteria for scaffolding.

The key point is that Octon does **not** need to abandon its current best ideas. It needs to finish them, unify them, and make them kernel-obligatory instead of partially distributed across docs, CI, and operator conventions. ([GitHub][2])

## J. Recommended Stabilization and Transition Order

**1. Stabilize constitutional authority first.**
Unify the charter, authority ownership, fail-closed rules, evidence obligations, and precedence model before adding more runtime or agency complexity. This is the highest-leverage change because Octon already has the raw material; it is just distributed. ([GitHub][3])

**2. Finish the intent layer next.**
Promote the current workspace objective + shared intent + mission charter arrangement into a complete objective system with per-run contracts. Octon’s own backlog already points here; that is the right next hardening step. ([GitHub][6])

**3. Machine-enforce the authority router.**
Generalize current policy-interface, execution-authorization, PR-autonomy, and AI-gate logic into a single route engine with approvals, exception leases, ownership resolution, and intervention records. Replace workflow-local approval hacks where possible with generic control-plane contracts. ([GitHub][24])

**4. Normalize the runtime lifecycle.**
Introduce canonical run manifests, checkpoint contracts, replay bundles, and continuity artifacts for every consequential run. Keep existing `state/control`, `state/continuity`, and `state/evidence` roots, but make them the mandatory runtime output model rather than a partial substrate. ([GitHub][7])

**5. Separate proof from generation.**
Keep structural assurance, but add independent evaluator roles and functional/behavioral acceptance classes. Do not let “alignment-check passed” stand in for “autonomous work succeeded.” ([GitHub][19])

**6. Create the lab subsystem.**
Elevate mission-autonomy live validation and scenario tests into a formal experimentation layer with replay, fault injection, shadow mode, and adversarial scenario packs. ([GitHub][20])

**7. Standardize disclosure.**
Add RunCard and HarnessCard artifacts, intervention ledgers, and benchmark disclosure rules. That will make Octon’s claims interpretable and keep the architecture honest. ([GitHub][17])

**8. Only then optimize adapters and rollout.**
After the kernel is stable, invest further in extension packs, executor/model adapters, portability/export flows, and service-template adoption. These can remain adaptable longer without compromising architectural correctness. ([GitHub][3])

**9. Institutionalize deletion.**
After each model/runtime generation change, require layer-aware ablation and scaffold retirement review. Octon should not allow old compensating mechanisms to persist indefinitely just because they were once helpful. ([GitHub][10])

## K. Open Questions

* Should **mission** remain Octon’s primary long-horizon autonomy unit, or should it become one layer beneath a more general run/objective model?
* How much evidence should remain Git-tracked in `state/**`, and when should Octon externalize replay stores or high-volume telemetry?
* What is the right generic replacement for current GitHub-label approval semantics in a host-agnostic authority engine?
* Where should Octon place a first-class lab subsystem: as a new top-level framework domain, or as a sibling kernel beside assurance and orchestration?
* What is the right formal **Model Adapter Contract** so portability across model families becomes testable rather than aspirational?
* How should Octon benchmark **behavioral correctness and recovery quality**, not just structural integrity and governance conformance?
* What is the minimum viable **RunCard / HarnessCard** disclosure set that is rigorous without becoming unmanageably heavy?
* How should Octon support repos that need browser/UI automation or broader API action surfaces while preserving its current strong governance posture?
* What are Octon’s explicit support targets for non-frontier, multilingual, or non-repo-centric environments?
* Which current actor/agency surfaces are truly load-bearing, and which are already candidates for simplification or deletion?

My bottom line: **Octon is converging toward the right architecture more than away from it**. Its super-root, class-root authority model, fail-closed posture, retained state/evidence, mission autonomy surfaces, and executable kernel are all solid long-term ingredients. But the repository is still one major architectural move short of completion: it must convert its impressive constitutional structure into a single, typed, execution-wide control plane where objective, authority, runtime, proof, intervention, replay, and disclosure are all first-class and mandatory.

[1]: https://github.com/jamesryancooper/octon "GitHub - jamesryancooper/octon · GitHub"
[2]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/_meta/architecture/specification.md "raw.githubusercontent.com"
[3]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/octon.yml "raw.githubusercontent.com"
[4]: https://raw.githubusercontent.com/jamesryancooper/octon/main/README.md "raw.githubusercontent.com"
[5]: https://github.com/jamesryancooper/octon/tree/main/.octon/framework "octon/.octon/framework at main · jamesryancooper/octon · GitHub"
[6]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/bootstrap/OBJECTIVE.md "raw.githubusercontent.com"
[7]: https://github.com/jamesryancooper/octon/tree/main/.octon/state/continuity "octon/.octon/state/continuity at main · jamesryancooper/octon · GitHub"
[8]: https://github.com/jamesryancooper/octon/tree/main/.octon/instance/governance/contracts "octon/.octon/instance/governance/contracts at main · jamesryancooper/octon · GitHub"
[9]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/policies/mission-autonomy.yml "raw.githubusercontent.com"
[10]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/state/continuity/repo/tasks.json "raw.githubusercontent.com"
[11]: https://github.com/jamesryancooper/octon/tree/main/.octon "octon/.octon at main · jamesryancooper/octon · GitHub"
[12]: https://github.com/jamesryancooper/octon/tree/main/.octon/framework/capabilities "octon/.octon/framework/capabilities at main · jamesryancooper/octon · GitHub"
[13]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/agency/manifest.yml "raw.githubusercontent.com"
[14]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/agency/runtime/agents/architect/AGENT.md "raw.githubusercontent.com"
[15]: https://github.com/jamesryancooper/octon/tree/main/.octon/framework/engine/runtime "octon/.octon/framework/engine/runtime at main · jamesryancooper/octon · GitHub"
[16]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/run "raw.githubusercontent.com"
[17]: https://github.com/jamesryancooper/octon/tree/main/.octon/state/evidence "octon/.octon/state/evidence at main · jamesryancooper/octon · GitHub"
[18]: https://github.com/jamesryancooper/octon/tree/main/.octon/framework/assurance "octon/.octon/framework/assurance at main · jamesryancooper/octon · GitHub"
[19]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.github/workflows/architecture-conformance.yml "raw.githubusercontent.com"
[20]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/orchestration/missions/mission-autonomy-live-validation/mission.yml "raw.githubusercontent.com"
[21]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.github/workflows/deny-by-default-gates.yml "raw.githubusercontent.com"
[22]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/policies/execution-budgets.yml "raw.githubusercontent.com"
[23]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/state/continuity/repo/log.md "raw.githubusercontent.com"
[24]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/config/policy-interface.yml "raw.githubusercontent.com"
[25]: https://github.com/jamesryancooper/octon/blob/main/.github/workflows/pr-autonomy-policy.yml "octon/.github/workflows/pr-autonomy-policy.yml at main · jamesryancooper/octon · GitHub"
[26]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/agency/governance/MEMORY.md "raw.githubusercontent.com"
[27]: https://github.com/jamesryancooper/octon/blob/main/.github/workflows/ai-review-gate.yml "octon/.github/workflows/ai-review-gate.yml at main · jamesryancooper/octon · GitHub"
[28]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/ownership/registry.yml "raw.githubusercontent.com"
[29]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/overlay-points/registry.yml "raw.githubusercontent.com"
[30]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/governance/policies/network-egress.yml "raw.githubusercontent.com"
[31]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/locality/scopes/octon-harness/scope.yml "raw.githubusercontent.com"

## Answers to Open Questions

These are the **ideal target-state answers**, not the smallest next steps. The common pattern across all ten is to move Octon from a repo-constitutionalized harness into a fully execution-constitutionalized control plane: keep its strongest current primitives—class roots, fail-closed posture, mission/autonomy policy, retained state/evidence, typed runtime specs—but rebind them around portable kernel contracts, host/model adapters, and run-level proof. Octon already has the raw ingredients for that shift in its super-root design, mission/autonomy policy, execution-authorization boundary, agency manifest, memory contract, and evidence roots. ([GitHub][1])

### 1. Mission should **not** remain the primary execution primitive

In the ideal architecture, **mission becomes a mid-level continuity and governance object beneath a more general objective/run model**. Octon should use four stacked units: **workspace charter** for repo-wide purpose, **mission charter** for long-horizon continuity and ownership, **run contract** for one bounded execution episode, and **execution attempt/stage** for a concrete material action sequence. Mission remains valuable, but as the durable container for scheduling, ownership, autonomy posture, overlap rules, and long-horizon continuity—not as the atomic execution unit. That fits Octon’s current mission-centric design, where policy-interface points to a missions registry and mission-autonomy policy, `.octon/README` declares canonical mission continuity and mission control truth, and the live-validation mission already defines risk ceiling, allowed action classes, and success/failure criteria. ([GitHub][2])

The reason to demote mission one layer is simple: **authority, evidence, and replay need a per-run binding**, and Octon’s own backlog still shows the intent layer and its enforcement cutover as incomplete. A mission can span days or weeks; a run needs explicit scope, grant, evidence, and closure semantics. In target state, every consequential run should bind to both a mission (optional for long-horizon work, absent for one-off work) and a run contract (mandatory for every material execution). That preserves Octon’s mission strengths while fixing the missing run-level objective contract. ([GitHub][3])

### 2. Git should hold **control-plane evidence**, not all telemetry

The ideal answer is a **three-class evidence model**. First, keep **small, durable, diff-worthy, human-auditable control-plane artifacts in Git**: objective contracts, mission charters, decision artifacts, approvals, policy digests, checkpoint summaries, continuity ledgers, assurance summaries, failure taxonomies, and RunCards. Second, store **Git-indexed evidence pointers** for artifacts that matter to replay but are too large or noisy to version inline. Third, externalize **high-volume telemetry** such as raw model I/O, browser traces, videos, screenshots, HAR files, high-frequency counters, and full step-by-step event streams into immutable object storage or an event store, with content hashes and retention metadata referenced from Git-tracked manifests. ([GitHub][1])

That split is already foreshadowed by the repository. Octon treats `state/**` as operational truth and retained evidence, but its export profiles explicitly exclude `state/**` and `generated/**` from `repo_snapshot`, and the root manifest says a normal Git clone is required for exact repository reproduction. The target-state interpretation is: **Git remains the durable constitutional ledger for low-volume, high-signal evidence; external stores carry high-volume replay payloads**. Octon should therefore add an evidence-retention contract that classifies artifacts as `inline_git`, `git_pointer`, or `external_immutable`. ([GitHub][1])

### 3. Replace GitHub labels with a canonical approval/exception engine

The right generic replacement is **not** “different labels.” It is a host-agnostic **Authority Engine** with first-class artifacts: `ApprovalRequest`, `ApprovalGrant`, `ExceptionLease`, `Revocation`, `QuorumPolicy`, and `DecisionArtifact`. GitHub labels, PR comments, Checks, CLI confirmations, Slack approvals, or future UI approvals should all be treated as **adapters** that project into and out of those canonical artifacts. In other words, GitHub can remain a surface, but it must stop being the authority source. Today the repo still uses `accept:human` for some high-impact merges and `ai-gate:required` / `ai-gate:blocker` for PR gating, which is useful but host-shaped. ([GitHub][4])

Octon already has the conceptual pieces for a better engine: ownership precedence in the ownership registry, mission-autonomy quorum classes (`ACP-2`, `ACP-3`, `ACP-4`), and an execution-authorization boundary that requires grants before material execution. The target-state engine should unify those into one portable authority model: approvals carry scope, objective/run reference, action classes, validity window, owner identity, quorum requirement, and compensation/rollback constraints; labels become projections only. ([GitHub][5])

### 4. The lab should be a new **top-level framework domain**

The lab should live as **`framework/lab/`**, a first-class top-level domain alongside `assurance`, `orchestration`, `engine`, and the other major framework domains. It should **not** be hidden under assurance, because assurance proves against known contracts, while the lab exists to discover what those contracts miss. It also should not be buried as a runtime subkernel, because its job is not just execution plumbing; it is scenario design, replay, fault injection, shadow mode, behavioral probing, and red-team experimentation. The current framework tree has `agency`, `assurance`, `capabilities`, `cognition`, `engine`, `orchestration`, `overlay-points`, and `scaffolding`, but no first-class lab domain yet. ([GitHub][6])

A top-level lab keeps the **library side** and **lab side** distinct. Assurance remains the proof layer for known invariants; orchestration remains the planning/execution layer; lab becomes the discovery layer that houses scenario catalogs, workload replay, environment fault injection, shadow-run controllers, adversarial packs, and telemetry probes. Octon’s current `mission-autonomy-live-validation` mission can then move from being a one-off live test into a governed scenario pack inside that lab domain. ([GitHub][7])

### 5. The Model Adapter Contract should be a testable interface, not an informal provider choice

The ideal **Model Adapter Contract** should make portability falsifiable. At minimum it should declare: adapter identity and version; provider/model family/model IDs; supported control semantics (system prompt behavior, tool-call grammar, JSON guarantees, stop reasons); context and budget semantics (prompt-byte ceiling, token window, output limits, caching behavior, truncation strategy); action semantics (parallel tool calls, partial responses, retry safety); measurement hooks (cost, latency, request IDs); safety envelope (supported autonomy classes, contamination signatures, reset/compaction rules); evaluation hooks (required regression suites, fallback evaluator policy); and disclosure metadata. A model adapter is therefore not “a prompt template.” It is a **conformance surface with measurable behavior**. ([GitHub][8])

That is the clean architectural response to Octon’s current provider-shaped seams. Today the execution-budget policy contains separate OpenAI and Anthropic budget thresholds, and the AI review gate runs an explicit OpenAI/Anthropic provider matrix. That is practical, but it is still provider-specific policy leaking into the harness core. In target state, those differences should live behind model adapters, and Octon should ship an **adapter conformance suite** so a new model family is “supported” only when it passes the declared contract. ([GitHub][9])

### 6. Benchmark five planes, not one

The right benchmarking model is **five-dimensional**: **structural correctness, functional correctness, behavioral correctness, governance correctness, and recovery quality**. Octon’s current architecture-conformance workflow already gives it a strong structural/governance spine: version parity, architecture conformance, alignment checks, mission runtime contracts, lifecycle cutover checks, runtime effective state, mission-autonomy scenarios, and generated-evidence validation. That should remain, but it should become only one axis of the benchmark, not the headline score. ([GitHub][10])

Behavioral correctness should be measured through **scenario bundles** with hidden assertions, end-state checks, UI/API interactions where relevant, and lab-driven perturbations. Recovery quality should be measured separately through metrics like checkpoint-resume success, time to safe state, rollback or compensation success, intervention density, contamination detection, repeated-failure suppression, and evidence completeness after recovery. The live mission validation is a useful seed, but target-state Octon should formalize these as benchmark classes with explicit failure taxonomies and separate scorecards instead of one blended “pass/fail.” ([GitHub][7])

### 7. RunCard and HarnessCard should be minimal, but they must still support interpretation

The minimum viable **RunCard** should include: `run_id`; objective/run contract reference; mission reference if present; trigger; actor and model adapter; policy route taken; granted capability surfaces; side-effect classes attempted; checkpoints emitted; assurance classes executed; interventions or waivers; final outcome; evidence references; and a compact cost/latency summary. That is the minimum set that lets an operator understand what happened without reading raw logs. Octon already has the ingredients—retained run evidence, execution receipts, AI gate decision artifacts, and protected-execution receipts—but not yet a normalized run disclosure artifact. ([GitHub][1])

The minimum viable **HarnessCard** should include: harness version; charter version; control-precedence model; authority model; runtime lifecycle model; supported action surfaces; supported model adapters; default fail-closed posture; core evaluation suites; evidence-retention model; and known limitations/blind spots. That is enough to make claims interpretable without requiring publication of raw provider traces or sensitive internals. Minimality here should mean “smallest disclosure that still makes comparison honest,” not “marketing summary.” ([GitHub][11])

### 8. Broader browser/API action surfaces should arrive as governed capability packs

Octon should support browser/UI automation and wider API action surfaces through **typed capability packs**, not through an unrestricted new tool pool. Every new surface should come with its own tool contract, side-effect classes, credential scope rules, DOM/network redaction policy, observability hooks, and approval thresholds, but all of them should still pass through the same execution-authorization boundary before any material effect occurs. The current repo already has the right safety instinct: execution authorization requires a valid grant before material execution, and the present network-egress policy is extremely constrained—`execution/flow` via `langgraph-http`, over `POST`, only to `127.0.0.1` or `localhost`. ([GitHub][8])

The target-state pattern is: keep the current deny-by-default core, then open new surfaces only through explicit policy packs. Browser automation should default to **observe-only**, then graduate to **effectful-but-reversible**, then to higher-risk classes only with stronger approvals and clearer compensation rules. API access should be run-scoped, credential-scoped, and capability-scoped. In other words, Octon should expand action breadth **without weakening its routing model**. ([GitHub][12])

### 9. Octon should publish an explicit support matrix, not imply universality

The ideal answer is an explicit **Support Target Matrix** with four dimensions: model tier, workload tier, language/resource tier, and locale tier. Current Octon is still clearly centered on repo-local harness work: the active locality scope is `.octon`, with language tags `markdown`, `yaml`, `bash`, `json`, and `rust`, and its budget policy is explicitly OpenAI/Anthropic-shaped. That is a perfectly reasonable reference profile, but it is not the same thing as a declared universal support target. ([GitHub][13])

So target-state Octon should publish support levels such as: **Tier A** frontier managed APIs in repo-centric environments; **Tier B** mid-tier or smaller models with tighter autonomy envelopes and stricter externalized state; **Tier C** local/self-hosted models with heavily reduced autonomy and stronger deterministic validators; plus separate workload modes for repo-only, repo+browser/API, and non-repo knowledge-work. It should also add locality packs for broader language families and multilingual contexts rather than pretending the current `.octon` harness scope already generalizes. The right design is explicit support envelopes, not aspirational universality. ([GitHub][13])

### 10. Keep the orchestrator and memory/governance core; simplify the persona-heavy actor layer

The current **load-bearing** agency surfaces are the ones that encode real boundary value: a single accountable default orchestrator, explicit routing/ownership controls in the agency manifest, a hard stance against arbitrary skill-actor delegation, mission ownership rules, delegation boundaries, and the memory contract. Those are kernel-grade because they affect authority, continuity, and safety. The agency manifest’s current defaults—`default_agent: architect`, `allow_skill_actor_delegation: false`, `mission_owner_types: [agent, human]`, and `assistant_mission_ownership: false`—are all signs that Octon already knows simplicity and accountability matter. ([GitHub][14])

The best candidates for simplification or deletion are the parts of the actor layer that do **not** create distinct authority, capability scope, context isolation, or proof obligations. In practice that means persona and voice surfaces like `SOUL.md` should remain optional overlays rather than kernel; assistant/team registries should remain non-essential unless they power real isolation or quorum roles; and large archetype-heavy guidance in the `architect` contract should be progressively demoted out of the kernel unless it becomes machine-enforced. The likely target-state rename is also more architectural: the kernel actor should really be an **orchestrator/execution agent**, with “architect” as a profile overlay rather than the core identity. ([GitHub][15])

The through-line across all ten answers is consistent: **mission becomes a continuity layer, approvals become artifacts, evidence becomes classed, lab becomes first-class, models become adapters, benchmarking becomes multidimensional, browser/API power arrives through governed capability packs, support becomes explicit, and the agency kernel gets simpler as its contracts get stronger**. That is the most complete and durable long-term shape for Octon given what the repository already is today. ([GitHub][1])


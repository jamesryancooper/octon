# Full Architectural Evaluation Resource

proposal_id: `octon-architecture-10of10-remediation`  
resource_role: mandatory analytical basis  
source_basis: prior architecture evaluation in this conversation, preserved as a review artifact  
status: non-authoritative proposal resource while under `inputs/**`

---

# 1. Executive judgment

**Overall architecture score: 7.1 / 10.**  
**Confidence: medium-high for repository structure and declared architecture; medium for implemented runtime enforcement because the public repository surfaces were inspected but the runtime was not executed locally.**  
**Severity judgment: moderate restructuring, not architectural re-foundation.**

Octon’s architecture is genuinely strong in its authority model, governance posture, class-root separation, support-envelope realism, and mission/run conceptual model. The core architectural thesis is not superficial. The repository is not merely a prompt bundle; it is organized around a serious constitutional control-plane architecture.

But Octon is not yet target-state-grade. Its current architecture has three main limitations:

1. **The authority/governance model is stronger than the demonstrated runtime enforcement model.** The repo contains an execution authorization contract, schemas, CLI surfaces, Rust runtime crates, CI gates, and policy engines, but the public architecture still relies heavily on specs, YAML contracts, scripts, and generated/CI projections. It is not yet obviously an end-to-end, hardened, easily inspectable runtime system.

2. **The information architecture is coherent but too elaborate and too duplicated.** The same structural truth is repeated across `/.octon/README.md`, `/.octon/framework/cognition/_meta/architecture/specification.md`, `/.octon/instance/bootstrap/START.md`, `/.octon/octon.yml`, constitutional files, manifests, and support-target declarations. That makes the design navigable after study, but brittle under evolution.

3. **The architecture lacks a sufficiently simple operator-facing target shape.** It has run roots, missions, evidence roots, support tuples, fail-closed rules, adapters, overlays, service contracts, skills, observability, lab, assurance, generated effective views, state/control/evidence roots, and CI gates. Those are mostly justifiable. But the current system does not yet present a compact operating model that a serious operator can use to predict behavior without reading a constitutional map.

The right conclusion is:

> Octon’s architecture is directionally correct and unusually sophisticated, but it needs focused consolidation, runtime hardening, proof automation, and simplification before it deserves a 9-10 score. It does not need a new foundation; it needs the current foundation made executable, testable, legible, and less repetitive.

---

# 2. Current architectural reality

## What Octon is, in reality, today

Octon is currently a **repo-native constitutional engineering harness with an emerging governed runtime**.

The actual architecture consists of five primary classes of surfaces:

| Surface type | Current role |
|---|---|
| Authored framework authority | `/.octon/framework/**`, especially `framework/constitution/**`, runtime contracts, capabilities, assurance, lab, observability, orchestration, and engine/runtime. |
| Repo-specific authored authority | `/.octon/instance/**`, including ingress, manifest, governance, support targets, locality, missions, repo-specific context, and capabilities. |
| Operational state/control/evidence | `/.octon/state/**`, split into continuity, control, and evidence. |
| Generated read/effective models | `/.octon/generated/**`, explicitly rebuildable and non-authoritative. |
| Inputs/proposals/additive material | `/.octon/inputs/**`, explicitly non-authoritative until promoted through authored activation chains. |

The top-level `/.octon/README.md` is explicit: `.octon/` is the single authoritative super-root; only `framework/**` and `instance/**` are authored authority; `inputs/**` never participate directly in runtime or policy decisions; `state/**` stores continuity/evidence/control truth; and `generated/**` is rebuildable output only. This is one of the strongest parts of the architecture.

The umbrella architecture specification reinforces the same invariants: the canonical class roots are `framework`, `instance`, `inputs`, `state`, and `generated`; generated artifacts are never source of truth; raw inputs must not become direct runtime or policy dependencies; material execution must pass through the engine-owned `authorize_execution(...)` boundary; labels/comments/checks are non-authoritative projections; and autonomous runtime paths must not silently fall back to mission-less execution.

## Actual vs emergent vs aspirational architecture

### Actual architecture

These are present and structurally real today:

- Five-class super-root information architecture: `framework`, `instance`, `inputs`, `state`, `generated`.
- Constitutional kernel under `/.octon/framework/constitution/**`.
- Explicit normative precedence where external obligations and live revocations outrank the constitutional kernel, repo governance, run artifacts, missions, contracts, and lower informational layers.
- Fail-closed obligations with default route `DENY`.
- Evidence obligations with retained evidence roots.
- Support-target declaration with live, stage-only, and non-live support surfaces.
- Overlay-point registry limiting where instance overlays may occur.
- Runtime source tree with engine runtime crates, CLI surfaces, adapters, specs, launchers, and packaging rules.
- Service and skill domains with manifests, validators, deny-by-default rules, and allowed-tool scoping.
- CI workflows enforcing deny-by-default gates, AI review gates, PR autonomy policy, architecture conformance, runtime binaries, skills validation, and related checks.

The constitutional charter states that Octon is a Constitutional Engineering Harness whose execution core is a Governed Agent Runtime, that live support is bounded by `/.octon/instance/governance/support-targets.yml`, and that consequential autonomous engineering work must be scoped, authorized, fail-closed, observable, reviewable, and recoverable.

### Emergent architecture

These are partially implemented, but not yet proven enough to grade as target-state-complete:

- **Execution authorization as a universal runtime boundary.** The contract exists and the CLI imports `authorize_execution`, but public proof that every material path is impossible to bypass is not yet obvious from the inspected surfaces.
- **Mission-scoped reversible autonomy.** The mission/run model is well designed, and mission policies are rich, but this still looks like an emerging operating model rather than a fully mature long-running runtime.
- **RunCards, HarnessCards, replay, and disclosure.** Evidence obligations and CLI commands exist, but operator-grade artifacts and end-to-end proof bundles need stronger surfacing.
- **Runtime packaging and deployability.** The runtime README describes launchers, release targets, source fallback, strict packaging mode, and CLI surfaces, but the productized installation/runtime story is still architecturally rough.
- **Adapter discipline.** The adapter manifests are strong and non-authoritative, but broader adapter support remains stage-only or non-live in the support matrix.

### Aspirational architecture

These are not yet safe to treat as fully real:

- Broad governed frontier-model execution.
- Browser/API/GitHub/Studio control planes as fully supported live surfaces.
- Mature always-on autonomous mission operation.
- Complete proof-plane automation.
- Rich operator UX.
- Generalized pack ecosystem.
- Fully self-orienting, self-improving repo runtime.
- Enterprise-grade multi-operator governance.

The repo itself is appropriately conservative: the bootstrap file says the currently proved live consequential envelope is the retained `MT-B / WT-2 / LT-REF / LOC-EN` tuple using the `repo-shell` host adapter and `repo-local-governed` model adapter; broader adapter coverage remains architectural intent until proof and support-target publication promote it into a live claim.

---

# 3. Target-state comparison

The strongest plausible target-state for Octon is:

> A repo-native governed autonomy runtime where every consequential agent action is authorized, support-bounded, reversible or explicitly compensable, evidence-retained, replayable, inspectable, and governed by a small set of stable canonical contracts.

Against that target, Octon is architecturally promising but not complete.

The ideal target-state architecture would have:

1. A small constitutional kernel that defines authority, precedence, fail-closed rules, evidence obligations, generated/read-model status, and support claims.
2. A runtime enforcement kernel that makes bypassing authorization structurally difficult or impossible.
3. A normalized state machine for missions, runs, stage attempts, approvals, exceptions, revocations, checkpoints, rollback posture, replay, and closeout.
4. A proof plane that automatically emits durable receipts, RunCards, HarnessCards, replay bundles, denial bundles, and support-claim evidence.
5. A compact operator interface over the above, so users can see what is active, blocked, approved, denied, staged, or recoverable.
6. A validator suite that prevents architectural drift: generated artifacts becoming authoritative, host projections minting authority, stale effective outputs, unsupported support claims, invalid overlays, missing evidence, or runtime/docs mismatch.
7. A pack/adapter lifecycle that supports extensibility without turning Octon into an unsafe plugin swamp.
8. A durable evidence store where retained evidence is not merely a temporary CI artifact or generated convenience file.

Octon is unusually strong on context and constraint declarations, but weaker on visible convergence: proof automation, end-to-end benchmarks, and runtime enforcement coverage are not yet as strong as the constitutional model.

---

# 4. Architecture scorecard

| Dimension | Score | Assessment |
|---|---:|---|
| Architectural clarity | 7.0 | The architecture is explicit and deeply documented. The limiting factor is volume and repetition: many surfaces restate topology, authority, support, and run models. Clear after study; not immediately clear. |
| Conceptual coherence | 8.1 | The core concepts reinforce each other: constitutional kernel, class roots, fail-closed obligations, support targets, mission/run split, generated non-authority. The system has a real worldview. |
| Structural integrity | 7.8 | The class-root model is strong, and placement rules are well specified. Integrity is weakened by many transitional/cutover references and repeated canonical path lists. |
| Separation of concerns | 8.3 | Authored authority, generated projections, state/control/evidence, and inputs are well separated. The `state/**` split into continuity/evidence/control is particularly good. |
| Authority-model correctness | 8.6 | This is Octon’s strongest area. Generated artifacts, raw inputs, host UI, chat, comments, labels, and checks are explicitly denied authority. |
| Governance-model strength | 8.0 | Fail-closed rules, evidence obligations, support targets, exclusions, overlays, and policies are first-class. The limiting factor is enforcement proof and operator usability. |
| Runtime architecture quality | 6.4 | There is a real Rust runtime workspace, CLI, specs, adapters, policy engine, authority engine, services, and run-first surfaces. But runtime maturity is harder to verify than governance intent. |
| Maintainability | 6.1 | Strong structure helps maintenance, but the system is document-heavy, path-heavy, and likely drift-prone. The authority engine implementation is large/monolithic enough to be a maintainability concern. |
| Evolvability | 7.5 | Overlay points, adapters, support targets, capability packs, services, skills, and profile-driven portability support evolution. Complexity and duplication create drag. |
| Scalability | 6.8 | Conceptually scalable for more missions/adapters/packs. Operational scaling is less proven: runtime persistence, evidence storage, concurrency, long-running workloads, and UX still need hardening. |
| Reliability | 6.3 | Deny-by-default posture and CI gates help. But reliability depends on runtime enforcement coverage, durable evidence, replay, rollback, and operator visibility that are still emerging. |
| Recoverability / reversibility | 7.0 | Rollback posture, run roots, checkpoints, replay pointers, revocations, exceptions, mission policies, and recovery windows are architecturally present. Practical recovery demos/proofs need to be stronger. |
| Observability / inspectability | 6.7 | Observability has an authored domain for measurement, intervention accounting, telemetry, drift incidents, failure taxonomy, and report bundles. It is structurally present but still reads more like a taxonomy than a mature operating surface. |
| Evidence and auditability | 7.6 | Evidence roots are well classified, append-oriented, and distinguished from generated output. Evidence obligations are detailed. The gap is automated completeness and durable user-facing proof. |
| Portability / adapter discipline | 7.4 | Replaceable non-authoritative host/model adapters and profile-driven portability are strong. The live support envelope is intentionally narrow, which is good governance but limits practical portability today. |
| Extensibility | 7.7 | Skills, services, overlays, capability packs, adapters, and extensions give Octon a serious extension model. The limiting factor is lifecycle simplicity and safety of pack promotion/activation. |
| Complexity management | 5.6 | This is the weakest core dimension. Much complexity is load-bearing, but too much is exposed at once. The architecture needs consolidation and sharper hierarchy. |
| Boundary discipline | 8.2 | Boundary discipline is excellent in principle: host adapters cannot widen authority; generated outputs remain read models; overlays are restricted; support claims are bounded. |
| Implementation consistency with stated architecture | 6.8 | Many implementation surfaces align: CLI, runtime crates, CI gates, services, validators, support targets. But the docs/specs are ahead of the publicly visible runtime/proof plane. |
| Fitness for long-running governed agentic work | 7.4 | The mission/run model, evidence model, support targets, and fail-closed policy are highly relevant. The missing pieces are polished run lifecycle UX, durable proof bundles, concurrency, and recovery demonstrations. |
| Support-matrix realism | 8.5 | The architecture is admirably honest about what is live, stage-only, and unsupported. This is a real strength. |
| Operator ergonomics | 5.2 | CLI commands exist, and Studio is mentioned, but the operator experience is not yet architecture-grade. The system still requires too much constitutional knowledge to operate confidently. |
| Failure isolation | 6.8 | Worktrees, run roots, checkpoints, stage attempts, support tuples, and deny routes are directionally strong. Isolation is not yet as explicit as the authority model. |
| Deployment practicality | 5.8 | Packaging contracts and launchers exist, but installability, binary distribution, source fallback behavior, and support matrices need product-grade hardening. |
| Policy enforcement quality | 7.0 | CI and runtime policy hooks are real. The deny-by-default workflow validates strict policy, engine capability boundaries, and protected execution posture. But enforcement needs clearer full-path coverage. |
| Generated-vs-authored discipline | 8.7 | This is elite by current agent-harness standards. Generated surfaces are explicitly non-authoritative and freshness/receipt-bound when runtime-facing. |
| Repo legibility for humans and agents | 6.4 | The repo is highly structured but hard to absorb. Several YAML/JSON authority surfaces appear as dense raw files; even if machine-parseable, they are diff- and review-hostile. |
| Testability / validation surface quality | 7.2 | Many validators and workflows exist, including skills/services validation, overlay validation, capability/engine consistency, protected execution posture, and runtime checks. The gap is unified evidence of coverage. |
| Anti-entropy mechanisms | 6.7 | The architecture anticipates drift through validation, lab, evidence, decisions, generated/effective views, and support declarations. It still needs stronger automated convergence loops. |
| Mission / mode / run model quality | 7.8 | Mission as continuity container and run as atomic execution unit is a strong architectural choice. It should survive into target-state. |

---

# 5. Overall architecture score

## Overall: 7.1 / 10

This is a strong architecture with serious target-state potential, not a weak architecture wrapped in sophisticated language.

But a 7.1 is appropriate because Octon currently has a gap between:

- the precision of the constitutional architecture, and
- the visible maturity of the executable runtime, proof plane, operator surface, and simplification mechanisms.

A 10/10 architecture would be smaller at the conceptual center, harder to bypass at runtime, easier to validate end-to-end, and easier for an operator to inspect. Octon is not there yet.

---

# 6. What Octon is doing especially well

## A. The source-of-truth model is unusually good

The class-root model is not ornamental. It correctly separates authored authority, non-authoritative inputs, mutable state/control/evidence, generated projections, and runtime-facing effective outputs.

This directly addresses a real failure mode in agent systems: generated summaries, chat state, host UI affordances, or stale docs accidentally becoming control-plane truth. Octon’s answer is structurally clear: they may guide, mirror, or project, but they do not mint authority.

## B. The constitutional kernel is not just branding

The charter is load-bearing. It defines non-goals, non-negotiables, support claims, authority routing, adapter non-authority, evidence obligations, support targets, and final disclosure requirements. It also explicitly rejects hidden human intervention and silent authority widening.

That is architecturally meaningful because it creates a stable top-level regime against which lower surfaces can be judged.

## C. Fail-closed behavior is concrete

`/.octon/framework/constitution/obligations/fail-closed.yml` has specific cases: raw inputs as policy dependencies, generated artifacts as source of truth, host UI/chat as authority, ambiguous ownership, missing grants, stale instruction manifests, missing mission context, missing support-targets, invalid run contracts, missing evidence, unsupported claims, adapter authority widening, and prohibited action classes.

## D. Support-target honesty is excellent

Most agent systems overclaim. Octon declares a finite live support universe and marks broader surfaces as stage-only or non-live. That is architecturally mature. It prevents capability theater.

## E. Mission/run separation is a strong long-horizon model

The mission model is well framed: missions are durable continuity containers; consequential runs bind per-run objective contracts under `state/control/execution/runs/<run-id>/**`; mission-local control truth, evidence, generated views, and continuity each have distinct homes.

This is the right architecture for long-running agentic work.

## F. Runtime surfaces are real enough to matter

The runtime is not imaginary. The engine runtime has launchers, specs, adapters, policies, WIT contracts, runtime crates, packaging contracts, run-first CLI surfaces, orchestration lookup/summary, incident closure readiness, Studio, and a lifecycle model that binds run control/evidence roots before side effects.

## G. Services and skills have real contract discipline

Services have typed contracts, manifest/runtime registries, scoped permissions, deny-by-default guardrails, explicit rejection of bare shell/write, exception leases, and validation preflight through the policy engine.

Skills have progressive disclosure, manifests, registries, I/O mappings, single-source allowed-tools frontmatter, validation scripts, scoped write permissions, deny-by-default rules, and host projections.

## H. CI gates are architecturally aligned

The repo includes workflows for deny-by-default gates, architecture conformance, AI review, PR autonomy, runtime binaries, skills validation, smoke tests, and other governance-related checks.

---

# 7. What is structurally weak, missing, or misframed

## A. The architecture is over-exposed

Octon exposes too much internal conceptual machinery at the same level. Many concepts are real and useful, but the hierarchy is not yet sharp enough. A target-state architecture should let an operator or contributor understand Octon in three layers:

1. Authority: what is allowed.
2. Execution: what runs.
3. Evidence: what proves it.

Octon has these layers, but they are buried inside a wider vocabulary cloud.

## B. The same truth is repeated in too many places

The super-root topology and canonical path matrix appear in multiple locations: `/.octon/README.md`, the umbrella specification, `/.octon/instance/bootstrap/START.md`, `/.octon/octon.yml`, ingress docs, and constitutional references.

A target-state system should have one machine-readable canonical topology registry, generated human docs, validators that prevent drift, and no repeated hand-maintained canonical path lists.

## C. Runtime enforcement is not yet visibly as strong as runtime specification

The execution authorization spec is excellent, but the implementation must prove that every material execution path is impossible to run without the same enforcement boundary.

## D. Evidence exists as a class, but proof is not yet operator-grade

The evidence model is strong on paper. A target-state architecture needs evidence that is automatically complete, easy to inspect, content-addressably durable where needed, tied to support claims, linked to run/mission state, replayable, and retained beyond ephemeral CI artifact windows.

## E. Some authority-promotion paths are too loose

The bootstrap file says project findings flow from `ideation/projects/` directly to `instance/cognition/context/shared/` without a separate promotion step. This weakens Octon’s otherwise excellent generated/input promotion discipline.

## F. Runtime code may be too centralized

The authority engine implementation is large and central. Authority routing should be highly auditable. A large monolithic implementation makes it harder to reason about policy boundaries, test slices, failure modes, denial reason generation, support-target routing, and run/evidence binding.

## G. Operator ergonomics is architecturally underdeveloped

In a governed runtime, operator ergonomics is architecture. The human must understand what is running, why it is allowed, why it is blocked, what evidence exists, whether rollback is available, whether support is admitted, what changed, and whether the mission is healthy.

---

# 8. Severity judgment: how much change is actually needed

## Overall severity: moderate restructuring

Octon does not need a foundational architectural rethink. The following should survive largely intact:

- super-root/class-root model,
- constitutional kernel,
- normative/epistemic precedence,
- generated non-authority,
- raw-input non-authority,
- fail-closed obligations,
- evidence obligations,
- support-target matrix,
- mission/run split,
- adapter non-authority,
- overlay-point registry,
- state/control/evidence split.

But Octon does need moderate restructuring in four areas:

| Area | Required severity | Why |
|---|---|---|
| Runtime enforcement | Focused gap-closing to moderate restructuring | The enforcement boundary must be proven and hard to bypass. |
| Contract/information architecture | Moderate restructuring | Too much duplicate path/authority truth across docs. |
| Evidence/proof plane | Moderate restructuring | Evidence needs durable, automated, operator-grade proof bundles. |
| Operator surface | Focused gap-closing | The architecture needs a primary human operating model. |
| Runtime code decomposition | Moderate restructuring | Authority/policy code must be smaller and more auditable. |
| Generated/input promotion lifecycle | Focused correction | Any path into `instance/**` authority needs explicit promotion semantics. |

No area obviously requires re-foundation. The kernel is sound. The work is consolidation, enforcement, and operationalization.

---

# 9. What prevents a 10/10

Octon is not a 10/10 because:

1. The architecture is more complete as a constitutional map than as a proven runtime.
2. It has too many canonical surfaces.
3. It exposes too much complexity to the operator.
4. Runtime code auditability is not yet ideal.
5. Evidence retention and proof completeness are not yet visibly hardened.
6. Productized deployment is immature.
7. Some transitional/cutover language remains in the active architecture.

---

# 10. Exact changes required to reach a 10/10

## Mandatory architectural corrections

### 1. Create a single canonical topology/authority registry

Collapse repeated topology/source-of-truth statements into one canonical machine-readable registry. Because the live repository already identifies `/.octon/framework/cognition/_meta/architecture/contract-registry.yml` as the machine-readable execution/path/policy invariant registry, the remediation should extend and harden that existing surface rather than introduce a rival registry.

### 2. Prove total authorization-boundary coverage

Add tests and static checks that assert every material side-effect path calls the same authorization gateway.

Required proof artifacts:

- call-path coverage report,
- workflow-stage enforcement tests,
- service invocation enforcement tests,
- executor launch enforcement tests,
- repo mutation enforcement tests,
- publication enforcement tests,
- protected CI enforcement tests,
- adapter projection enforcement tests,
- negative tests showing direct bypass fails.

The target invariant should be:

> No side-effect-capable code path can execute without a GrantBundle, receipt obligation, support-target resolution, and evidence root binding.

### 3. Decompose the authority engine

Break authority runtime logic into auditable modules around stable concepts:

- request normalization,
- support-target resolution,
- ownership resolution,
- risk/materiality,
- capability admission,
- rollback/reversibility,
- budget/egress,
- mission/run binding,
- grant/receipt emission,
- denial/stage/escalation reason coding,
- evidence binding,
- finalization.

### 4. Make evidence durable and complete by construction

Define a retained evidence backend/store contract specifying append-only semantics, content hashes, retention class, local vs external immutable storage, CI artifact limitations, replay pointer validity, support-claim linkage, RunCard/HarnessCard generation, and evidence completeness validation.

### 5. Normalize promotion semantics

Every movement from `inputs/**` or `generated/**` into `instance/**` or `state/control/**` should require a promotion/activation receipt.

### 6. Define the run lifecycle as a formal state machine

Create a canonical run lifecycle spec and transition contract.

### 7. Make support-target admission executable

For each admitted tuple, require conformance suite, proof bundle, live scenario, denied unsupported scenario, evidence completeness test, and disclosure artifact.

### 8. Reduce active architecture vocabulary

Move historical cutover/wave/proposal-lineage material out of active operational docs and into decision/evidence history.

### 9. Build operator-grade read models

Generated read models are non-authoritative, but they are essential for usability: active missions, pending runs, denied/staged actions, grant bundles, rollback posture, evidence completeness, support envelope, open interventions, closeout readiness, stale generated/effective outputs, and adapter status.

### 10. Add architecture-conformance tests for the architecture itself

The architecture should test itself: generated never referenced as source of truth, inputs never used as runtime/policy dependencies, host projections never mint authority, state/evidence never used as active control unless explicitly in `state/control`, overlays only exist at declared enabled overlay points, support claims reference admitted tuples, runtime-facing generated/effective outputs have fresh generation locks and receipts, and dense authority files are normalized/formatted for reviewability.

---

# 11. Priority-ordered improvement sequence

1. Authorization-boundary proof.
2. Evidence completeness validator.
3. Contract de-duplication.
4. Authority engine decomposition.
5. Operator run dashboard.
6. Support-target proof packs.
7. Promotion lifecycle hardening.
8. Simplify active docs.
9. Packaging hardening.
10. Long-running mission demonstration.

---

# 12. What should be preserved unchanged

These are strong enough that changing them would likely make Octon worse:

1. Five-class super-root model: `framework`, `instance`, `inputs`, `state`, `generated`.
2. Authored-authority limitation: only `framework/**` and `instance/**` as authored authority.
3. Generated non-authority.
4. Raw inputs non-authority.
5. Constitutional kernel placement.
6. Normative precedence model.
7. Fail-closed obligations.
8. Evidence root separation.
9. Support-target boundedness.
10. Mission/run separation.
11. Adapter non-authority.
12. Overlay-point restriction.
13. Services/skills deny-by-default discipline.

---

# 13. What should be simplified, relocated, or removed

## Simplify

- The support-target taxonomy presentation.
- The active operator-facing vocabulary.
- The read order and bootstrap path.
- The number of documents that restate topology.
- The profile/wave/cutover language in active docs.
- The generated/effective/publication receipt explanation.

## Relocate

- Historical wave/cutover/proposal-lineage explanations should live in `instance/cognition/decisions/**` or `state/evidence/migration/**`.
- Generated operator summaries should live under `generated/cognition/**`, with links back to canonical authority/evidence.
- CI artifacts should be treated as projections/transport unless retained in the canonical evidence store.

## Remove or de-emphasize

- Any stage-only architecture presented too close to live architecture.
- Any duplicated canonical path inventory not generated from a single source.
- Any direct promotion path into `instance/**` lacking a promotion receipt.
- Any operator-facing docs that require understanding all constitutional layers before the first run.
- Any OS framing that implies Octon owns more runtime surface than it actually does.

---

# 14. Risks of not changing the architecture

1. Governance theater: runtime enforcement and evidence proof fail to catch up to constitutional language.
2. Architectural drift: repeated canonical truth creates contradictions.
3. Operator abandonment: the system remains too hard to use.
4. Evidence insufficiency: recovery, auditability, and support-bound execution remain under-proven.
5. Runtime bypass: any side-effect path that bypasses `authorize_execution` compromises the core architecture.
6. Pack/extension sludge: weak promotion lifecycle creates hidden authority or stale capability expansion.
7. Maintainability collapse: large centralized runtime files and dense policy artifacts become difficult to review safely.

---

# 15. Final verdict

Octon’s architecture is materially above average and in several areas genuinely excellent. The authority model, generated-vs-authored discipline, fail-closed governance, support-target honesty, adapter non-authority, and mission/run separation are all strong architectural choices.

But the current architecture is not yet elite. It is a strong constitutional blueprint with an emerging runtime, not a fully hardened autonomous engineering control plane.

The correct path is not re-foundation. The current foundation should be preserved. The necessary work is:

1. Make the authorization boundary mechanically unavoidable.
2. Make evidence complete and durable by construction.
3. Collapse duplicated topology truth into generated docs from one registry.
4. Decompose the authority/runtime implementation into auditable modules.
5. Give operators simple mission/run/grant/evidence views.
6. Make support-target claims proof-backed rather than merely declared.
7. Harden promotion semantics so generated/input artifacts never become quiet authority.
8. Move historical migration/cutover material out of active architecture paths.

If those changes are made, Octon could plausibly become a 9+ architecture. To deserve a true 10/10, it would need not only the right structure, but also strong proof that the runtime enforces that structure across all consequential execution paths.

**Final score: 7.1 / 10.**  
**Final severity: moderate restructuring, with no foundational architectural rethink required.**

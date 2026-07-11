> From: https://chatgpt.com/g/g-p-6a2aee23ec0c8191a107cc9e7b14e5bc/c/6a29beaa-19d8-83ea-87e9-29e346a4f9f3

# you asked

message time: 2026-07-03 19:23:26

You are a senior AI-systems architect, agent-runtime designer, governed-workflow reviewer, software architecture critic, and implementation-planning strategist.

Your task is to perform a deep, repo-grounded review of Octon:

https://github.com/jamesryancooper/octon

I have limited access to Octon Architect, so I want to use it only for the highest-leverage reasoning tasks — the things that would benefit most from unusually strong deep reasoning, architectural judgment, design critique, planning ability, and review quality.

Do **not** simply summarize the repository. Do **not** give generic advice. Do **not** propose implementation work prematurely.

Instead, determine exactly how Octon Architect should be used to improve Octon.

Frame the answer around these categories:

1. **Deep Reasoning**

   * What hard architectural questions should Octon Architect answer?
   * What unresolved tensions, contradictions, or hidden assumptions in Octon should it analyze?
   * What long-term product or system-design decisions would benefit most from Octon Architect-level reasoning?

2. **Architecture**

   * What parts of Octon’s architecture should Octon Architect review first?
   * Where should it evaluate boundaries, control planes, governance layers, runtime responsibilities, memory/context systems, workflow execution, assurance/evaluation, and tool/plugin interfaces?
   * What architectural decisions should it validate, challenge, or refine?

3. **Reviews**

   * What kinds of reviews should Octon Architect perform on Octon?
   * Examples may include architecture review, failure-mode review, authority-boundary review, governance review, security/safety review, implementation-readiness review, proposal review, or roadmap review.
   * For each review type, explain what the review should inspect, what questions it should answer, and what output it should produce.

4. **Planning**

   * What planning work is worth spending Octon Architect capacity on?
   * Identify the highest-value planning artifacts it should create, such as proposal packets, implementation sequences, migration plans, schema-change plans, test strategies, acceptance gates, rollback plans, or milestone roadmaps.
   * Distinguish between planning that requires deep reasoning and planning that a weaker model or implementation agent could handle later.

5. **Design Critiques**

   * What design proposals, concepts, or architectural directions should Octon Architect critique before they become implementation work?
   * Identify where Octon may be overcomplicated, under-specified, too abstract, insufficiently governed, too flexible, too rigid, or vulnerable to becoming a second uncontrolled agent runtime.
   * Recommend specific critique prompts that would expose weaknesses before coding begins.

For each recommended use of Octon Architect, provide:

* A clear task name
* Why this task deserves scarce Octon Architect usage
* The specific Octon areas or files it should inspect
* The exact questions it should answer
* The expected output artifact
* How the output should be judged for quality
* Whether the result should feed into architecture, planning, implementation, tests, documentation, or governance

Also produce a prioritized usage plan:

* **Tier 1:** Must-use Octon Architect tasks
* **Tier 2:** Valuable if additional Octon Architect access remains
* **Tier 3:** Tasks that should be delegated to cheaper models, coding agents, or standard review passes

Finally, provide a set of ready-to-use follow-up prompts I can paste directly into Octon Architect. These prompts should be optimized for limited usage and should force repo-grounded, evidence-based, implementation-useful outputs.

Important constraints for Octon:

* Octon should remain the governing control layer.
* Do not introduce a second control plane.
* Provider sessions, assistants, generated outputs, and raw model responses are not sources of authority.
* Preserve mission-scoped, reversible autonomy.
* Preserve deny-by-default execution.
* Preserve evidence, receipts, replay, rollback, and auditability.
* Prefer file-native, inspectable, portable artifacts.
* Separate architecture evaluation from implementation planning.
* Separate implementation planning from actual implementation.
* Be explicit about assumptions, risks, missing information, and acceptance criteria.

---

# source model response

I’ll ground this in Octon’s actual repository structure, docs, and key runtime/governance paths, then turn that evidence into a prioritized Octon Architect usage plan rather than implementation work.

---

# source model response

Octon’s own framing is governance-heavy, so I’m focusing Octon Architect use on authority-boundary coherence, journal/control-flow ownership, runtime-evidence enforceability, and roadmap containment.

---

# source model response

## Working recommendation

Use Octon Architect as an **architectural adversary and governance reviewer**, not as a coding agent. Octon’s own docs already make a strong claim: it is not a generic agent framework, but a governed harness where consequential work is bound to objectives, run contracts, capabilities, authorization decisions, retained evidence, rollback posture, continuity, and review/disclosure surfaces.  The scarce Octon Architect budget should therefore be spent on finding places where Octon’s own control model might accidentally become false: hidden authority, unsupported live claims, generated-output drift, insufficient proof, unbounded autonomy, weak evidence closure, or a second control plane.

The highest-value review target is the **distance between Octon’s constitutional promises and its executable/runtime enforcement**. The Charter says generated and input surfaces must not become authority, support must remain finite and proof-backed, material side effects need explicit routing, long-horizon autonomy must remain mission-backed, and host/model adapters are replaceable non-authoritative boundaries.  Octon Architect should pressure-test whether the runtime, specs, validators, support targets, connectors, stewardship, self-evolution, and context-pack machinery actually preserve those constraints.

---

# Tier 1 — must-use Octon Architect tasks

## 1. Authority Topology and Second-Control-Plane Review

**Why this deserves Octon Architect:**  
This is the core existential risk for Octon. The repo repeatedly says Octon has one authoritative super-root, with authored authority only in `framework/**` and `instance/**`, control truth in `state/control/**`, retained evidence in `state/evidence/**`, continuity in `state/continuity/**`, generated outputs as derived-only, and inputs as non-authoritative.  A weaker model can list those rules; Octon Architect should find where they become ambiguous, contradicted, or operationally unenforceable.

**Specific Octon areas/files to inspect:**

- `README.md`
- `.octon/README.md`
- `.octon/framework/constitution/CHARTER.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/framework/engine/runtime/spec/runtime-resolution-v1.md`
- `.octon/instance/governance/runtime-resolution.yml`
- `.octon/framework/engine/runtime/spec/publication-freshness-gates-v4.md`
- `.octon/framework/engine/runtime/spec/compatibility-retirement-cutover-v2.md`

**Exact questions Octon Architect should answer:**

1. Is there any path by which `generated/**`, `inputs/**`, host UI state, comments, checks, labels, model memory, chat, connector state, or read models can become de facto authority?
2. Are “runtime-facing generated/effective handles” genuinely derived handles, or do they function as a hidden control surface?
3. Are compatibility projections, especially capability-pack projections, sufficiently de-authorized and successor-bound?
4. Does the architecture contain duplicated authority registries whose precedence could diverge?
5. Are the five class roots sufficient, or are there missing authority classes such as “external trust,” “connector operation truth,” or “private local evidence” that are only partially modeled?
6. Where does Octon rely on convention rather than executable denial?

**Expected output artifact:**  
An **Authority Topology Findings Memo** with:

- authority graph;
- source-of-truth matrix;
- “must never authorize” surface inventory;
- suspected second-control-plane risks;
- contradiction list;
- concrete acceptance criteria for closing each risk;
- no implementation plan.

**Quality bar:**  
Good output must cite exact repo paths and line/file evidence, distinguish canonical authority from projections, identify at least one falsifiable negative-control test per risk, and explicitly say when a suspected issue is only a hypothesis.

**Feeds into:** architecture, governance, tests, documentation.

---

## 2. Material Side-Effect Boundary and Authorized-Effect Completeness Review

**Why this deserves Octon Architect:**  
This is the highest-stakes runtime claim. Octon’s execution authorization spec says all material execution must pass through `authorize_execution(request) -> GrantBundle`, and material APIs must consume typed `AuthorizedEffect<T>` values and verify them into `VerifiedEffect<T>` before mutation.  The authorization coverage spec says coverage is only complete when inventory, negative controls, authority evidence, runtime receipts, token records, and consumption receipts point to the same boundary.  Octon Architect should determine whether this claim is actually complete.

**Specific Octon areas/files to inspect:**

- `.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
- `.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md`
- `.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/effects.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/pipeline.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/workflow.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/stdio.rs`
- `.github/workflows/**`
- authorization negative-control tests under `.octon/framework/assurance/runtime/_ops/tests/`

**Exact questions Octon Architect should answer:**

1. Is every material side-effect path inventoried?
2. Does every inventoried live path require a verified effect token before mutation?
3. Are there material paths created by shell scripts, workflow stages, closeout helpers, host projections, publication scripts, or CI workflows that bypass Rust-side token verification?
4. Is the `control-plane-preparation` class safely non-material, or is it a quiet exception class that could grow into a bypass?
5. Are protected CI, host-projected controls, publication, generated/effective updates, extension activation, and capability-pack activation equally covered?
6. Do token issuance, consumption, rejection, expiry, revocation, and already-consumed cases all emit retained evidence and journal coverage?
7. Are “allow,” “stage_only,” “escalate,” and “deny” behaviorally distinct and tested?

**Expected output artifact:**  
A **Material Side-Effect Coverage Dossier** with:

- path inventory reconciliation;
- missing-path candidates;
- bypass-risk classification;
- token-verification coverage table;
- negative-control gaps;
- acceptance gates for claiming “complete authorization coverage.”

**Quality bar:**  
Good output must identify both declared and implicit side-effect paths, cite source files, separate “spec says” from “code enforces,” and propose tests only after establishing the architectural gap. It should not write code.

**Feeds into:** architecture, tests, governance, later implementation planning.

---

## 3. Run Journal / Lifecycle Truth Review

**Why this deserves Octon Architect:**  
Octon’s control truth depends on a canonical journal model. The run lifecycle contract says `events.ndjson` and `events.manifest.yml` are the canonical transition record, while `runtime-state.yml` is a mutable derived view.  The Run Journal spec says `runtime_bus` is the only canonical append path and no component may write raw journal lines, rewrite/delete prior entries, mutate the manifest directly, or treat generated/operator read models as journal inputs.  This deserves top-tier reasoning because a subtle journal/state/evidence confusion would compromise replay, rollback, closeout, and auditability.

**Specific Octon areas/files to inspect:**

- `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `.octon/framework/engine/runtime/spec/run-journal-v1.md`
- `.octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/runtime_state.rs`
- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- run lifecycle validators and fixtures:
  - `.octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-v1.sh`
  - `.octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-transition-coverage.sh`
  - `.octon/framework/assurance/runtime/_ops/fixtures/run-lifecycle-v1/**`

**Exact questions Octon Architect should answer:**

1. Is `runtime_bus` truly the only append path, or do closeout, publication, repair, or migration scripts mutate journal-adjacent state?
2. Are allowed state transitions sufficient and minimal?
3. Can `runtime-state.yml` drift create stale-but-accepted control truth?
4. Are closeout requirements strong enough to prevent “closed without evidence completeness”?
5. Are `staged`, `denied`, `revoked`, `failed`, and `rolled_back` semantically clear, or do they overlap?
6. Can replay reconstruct state without trusting generated projections, compact summaries, or mutable views?
7. Are denial/rejection events safely non-advancing?

**Expected output artifact:**  
A **Lifecycle Truth and Replay Review** containing:

- state-machine critique;
- forbidden mutation-path inventory;
- journal/state/evidence boundary map;
- closeout insufficiency scenarios;
- replay falsifiability checklist.

**Quality bar:**  
Good output should include at least five adversarial scenarios, identify which invariant catches each scenario, and flag scenarios that are not currently caught.

**Feeds into:** architecture, tests, documentation, governance.

---

## 4. Support-Claim Envelope and Proof Sufficiency Review

**Why this deserves Octon Architect:**  
Octon’s live claim is intentionally finite: repo-local governed work, selected workloads, English-primary, supported host adapters, and admitted capability packs.  The support-target file also contains stage-only and non-live surfaces, plus adapter criteria and future-looking tiers.  Octon Architect should pressure-test whether live claims are actually narrower than future-facing design, generated matrices, support cards, capability-pack routes, and documentation language.

**Specific Octon areas/files to inspect:**

- `.octon/instance/governance/support-targets.yml`
- `.octon/instance/governance/support-target-admissions/**`
- `.octon/instance/governance/support-dossiers/**`
- `.octon/instance/governance/contracts/support-target-proofing.yml`
- `.octon/state/evidence/validation/support-targets/**`
- `.octon/generated/effective/governance/support-target-matrix.yml`
- `.octon/generated/cognition/projections/materialized/support-cards/**`
- `.octon/instance/governance/capability-packs/*.yml`
- `.octon/framework/engine/runtime/spec/architecture-health-contract-v3.md`

**Exact questions Octon Architect should answer:**

1. Do admitted-live tuples have executable or replayable proof, representative retained runs, negative controls, disclosure coverage, and current freshness?
2. Are stage-only, unadmitted, unsupported, and retired surfaces impossible to cite as live support?
3. Do host/model adapter declarations accidentally allow more than the tuple admissions actually support?
4. Are browser/API packs safely unadmitted despite existing manifests and future-facing references?
5. Is “frontier-governed” sufficiently fenced from live claims?
6. Is support proof metadata-only anywhere that should be executable/replayable?
7. Does generated support-target matrix narrowing ever become support widening?

**Expected output artifact:**  
A **Support Envelope Certification Review** with:

- live tuple table;
- evidence sufficiency judgment per tuple;
- non-live leakage risks;
- support-widening hazards;
- proof-executability gap list;
- recommended acceptance gates before any support expansion.

**Quality bar:**  
Good output must distinguish “declared supported” from “proved supported,” and it must reject summary-only proof where runnable/replayable proof is required. The support proofing contract explicitly says metadata-only or summary-only proof is insufficient for admitted-live claims. 

**Feeds into:** governance, assurance, release disclosure, tests.

---

## 5. Context, Memory, and Model-Visible Evidence Review

**Why this deserves Octon Architect:**  
Octon’s memory/context design is subtle. Execution roles are forbidden from owning canonical memory, and context packs must bind authoritative sources, derived sources, excluded sources, hashes, freshness checks, authority labels, omissions, retrieval steps, and evidence receipts.  The Context Pack Builder says it is not a control plane, approval authority, memory subsystem, or policy interpreter; it is subordinate to authorization.  This is exactly the kind of layered boundary a strong reasoning model should attack.

**Specific Octon areas/files to inspect:**

- `.octon/framework/execution-roles/governance/MEMORY.md`
- `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `.octon/framework/engine/runtime/spec/context-pack-receipt-v1.schema.json`
- `.octon/instance/governance/policies/context-packing.yml`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs`
- context-pack validators/tests:
  - `.octon/framework/assurance/runtime/_ops/scripts/validate-context-pack-builder.sh`
  - `.octon/framework/assurance/runtime/_ops/tests/test-context-pack-builder.sh`

**Exact questions Octon Architect should answer:**

1. Can context-pack evidence become hidden authority or durable model memory?
2. Are generated, proposal-local, raw input, chat, host UI, and labels always labeled non-authoritative when model-visible?
3. Does context-pack freshness rely on explicit receipt/TTL/digest semantics, or are there fake freshness assumptions?
4. Is the `CONTEXT_RECEIPT_VALID_UNTIL = "9999-12-31T23:59:59Z"` constant in `execution.rs` safe in context, or does it conflict with the broader rejection of fake far-future freshness for runtime-effective trust?  
5. Can an invalid supplied context binding be silently rebuilt or laundered?
6. Are omissions/redactions replayable and audit-preserving?
7. Does compact context reuse preserve model-visible hash and authority labels?

**Expected output artifact:**  
A **Context and Memory Boundary Review** with:

- context source-class map;
- laundering/freshness risks;
- model-visible contamination scenarios;
- required denial cases;
- acceptance criteria for context-pack trust.

**Quality bar:**  
Good output should separate “context as evidence” from “context as authority,” and it should produce adversarial examples where model-visible context contains tempting but non-authoritative instructions.

**Feeds into:** architecture, tests, governance, documentation.

---

## 6. Long-Horizon Autonomy, Stewardship, and Self-Evolution Safety Review

**Why this deserves Octon Architect:**  
Octon wants long-running usefulness without unbounded autonomy. Continuous Stewardship explicitly says the service may remain available indefinitely, but the work may not become unbounded; stewardship never executes material work directly and must hand off through Mission Runner, Action Slice, Run Contract, and Governed Run.  Self-evolution is even more dangerous: it is meant to improve Octon’s own contracts and runtime without allowing proposals, simulations, generated summaries, or lab success to become authority. 

**Specific Octon areas/files to inspect:**

- `.octon/framework/engine/runtime/spec/continuous-stewardship-runtime-v3.md`
- `.octon/framework/engine/runtime/README.md`
- `.octon/instance/cognition/decisions/102-self-evolution-proposal-to-promotion-runtime.md`
- `.octon/framework/engine/runtime/spec/evolution-program-v1.schema.json`
- `.octon/framework/engine/runtime/spec/promotion-runtime-v1.md`
- `.octon/framework/engine/runtime/spec/recertification-runtime-v1.md`
- `.octon/state/control/evolution/**`
- `.octon/state/evidence/evolution/**`
- `.octon/instance/governance/evolution/**`

**Exact questions Octon Architect should answer:**

1. Does stewardship ever schedule itself, renew itself, or admit work without bounded mission/run handoff?
2. Can mission state, queue state, continuation decisions, or generated mission projections become run authority?
3. Can self-evolution propose, approve, promote, recertify, or rollback itself without human/quorum authority?
4. Are simulation success, evidence distillation, lab success, generated summaries, or proposal packets structurally unable to authorize change?
5. Are rollback and recertification mandatory for self-evolution promotions?
6. Are there loops where “evidence of good behavior” becomes “permission to widen behavior”?
7. Are long-horizon autonomy and self-evolution clearly separated from implementation execution?

**Expected output artifact:**  
A **Bounded Autonomy and Self-Evolution Risk Memo** with:

- autonomy loop diagram;
- self-approval impossibility analysis;
- renewal/admission risk list;
- human/quorum boundary map;
- acceptance gates for future autonomy expansions.

**Quality bar:**  
Good output must identify possible feedback loops and authority laundering paths, not merely restate that the docs prohibit them.

**Feeds into:** architecture, governance, roadmap, tests.

---

# Tier 2 — valuable if Octon Architect access remains

## 7. Connector, Tool, Plugin, Browser, and API Admission Critique

**Why it is worth Octon Architect:**  
Connectors and tool/plugin interfaces are where a governed runtime can accidentally become a generic agent framework. Octon currently treats connector commands as administrative inspection/preparation surfaces; they must not execute MCP/API/browser/service operations, and material connector execution is deferred until run contracts, context packing, authorization, effect-token verification, journal evidence, and connector receipts exist.  Browser and API capability packs are explicitly unadmitted with `default_route: escalate`.  

**Inspect:**

- `.octon/framework/engine/runtime/spec/connector-admission-v1.schema.json`
- `.octon/instance/governance/connectors/**`
- `.octon/state/control/connectors/**`
- `.octon/state/evidence/connectors/**`
- `.octon/instance/governance/capability-packs/browser.yml`
- `.octon/instance/governance/capability-packs/api.yml`
- `.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml`

**Questions:**

1. Is connector admission only governance preparation, or can it become operation authority?
2. Are connector “live” admissions confusingly named if they remain non-effectful?
3. What exact proof is needed before browser/API packs become admitted?
4. Are connector receipts sufficient to preserve replay, audit, and rollback?
5. Can MCP/server availability become authority?

**Expected artifact:**  
A **Connector Admission Architecture Critique**.

**Quality bar:**  
Must produce concrete admission gates and “deny until” scenarios.

**Feeds into:** architecture, governance, future planning.

---

## 8. Generated-Effective Handle, Freshness, and Compatibility Retirement Review

**Why it is worth Octon Architect:**  
Runtime-effective generated outputs are intentionally weird: they are generated, but the runtime may consume them only through resolver-verified handles. Runtime resolution says trust resolves only through handles, never raw string paths, and fails closed on missing/drifted digests, stale receipts, bad non-authority classification, or forbidden consumer class.  Publication Freshness v4 adds recursive dependency checks and rejects raw-path bypasses and fake far-future trust. 

**Inspect:**

- `.octon/framework/engine/runtime/spec/runtime-resolution-v1.md`
- `.octon/instance/governance/runtime-resolution.yml`
- `.octon/framework/engine/runtime/spec/runtime-effective-artifact-handle-v2.md`
- `.octon/framework/engine/runtime/spec/runtime-effective-route-bundle-lock-v3.schema.json`
- `.octon/framework/engine/runtime/spec/publication-freshness-gates-v4.md`
- `.octon/framework/engine/runtime/spec/compatibility-retirement-cutover-v2.md`
- `.octon/generated/effective/**`
- `.octon/instance/governance/retirement-register.yml`

**Questions:**

1. Are generated/effective handles a safe derived-runtime-handle pattern?
2. Are all runtime consumers forced through the resolver?
3. Are dependency handles recursively checked?
4. Do compatibility projections still influence support or runtime?
5. Are legacy freshness fields fully de-authorized?

**Expected artifact:**  
A **Generated-Effective Trust and Retirement Review**.

**Quality bar:**  
Must separate safe resolver consumption from raw-path consumption and identify direct-read negative controls.

**Feeds into:** architecture, tests, governance.

---

## 9. Evidence, Disclosure, Replay, and Rollback Completeness Review

**Why it is worth Octon Architect:**  
Evidence is not just logging in Octon; it is the basis for closeout, replayability, support proofing, and disclosure. The evidence store says retained evidence proves/replays/discloses but does not become live lifecycle control truth.  Closeout is valid only when required artifacts are present, journal snapshots hash-match live control, disclosure is generated from retained evidence, generated read models are not used as proof, and missing required evidence blocks closure/promotion/live claim activation. 

**Inspect:**

- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/contracts/disclosure/**`
- `.octon/framework/constitution/contracts/retention/**`
- `.octon/state/evidence/runs/**`
- `.octon/state/evidence/disclosure/**`
- `.octon/generated/cognition/projections/materialized/runs/**`

**Questions:**

1. Can a run close without reconstructable retained evidence?
2. Are raw private evidence, repo-publishable evidence, disclosure, and generated read models properly separated?
3. Are rollback posture and replay readiness mandatory before closure?
4. Are compact evidence summaries safe, or can they replace raw/full evidence?
5. Are redactions lineage-preserving?

**Expected artifact:**  
An **Evidence Closure Review**.

**Quality bar:**  
Must include at least one closeout-blocking checklist and one replay reconstruction checklist.

**Feeds into:** tests, documentation, governance.

---

## 10. Architecture-Health Gate and Validator Sufficiency Review

**Why it is worth Octon Architect:**  
Octon already defines an architecture health contract with depth classes from existence to closure-grade, and requires runtime/proof/semantic depths across dimensions such as runtime-effective handles, freshness, authorization coverage, support proof executability, operator read models, and publication receipts.   Octon Architect should determine whether the validators actually prove those depths or mostly check shape.

**Inspect:**

- `.octon/framework/engine/runtime/spec/architecture-health-contract-v3.md`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-health.sh`
- validators for runtime resolution, authorization coverage, generated freshness, support proof, operator read models, and compatibility retirement
- evidence under `.octon/state/evidence/validation/architecture/10of10-target-transition/**`

**Questions:**

1. Which validators are semantic, runtime, proof, or merely schema/existence checks?
2. Are required closure-grade dimensions actually proven?
3. Are negative controls executed or just referenced?
4. Is the aggregate architecture-health certificate itself non-authoritative?
5. Where are depth claims overstated?

**Expected artifact:**  
A **Validator Depth Audit**.

**Quality bar:**  
Must classify validators by achieved depth, not intended depth.

**Feeds into:** tests, governance, release/readiness documentation.

---

## 11. Roadmap and Migration Sequencing Review

**Why it is worth Octon Architect:**  
Only after the above architecture reviews should Octon Architect help with planning. The valuable planning work is not “make tasks”; it is sequencing architectural risk reduction without widening support or introducing a second control plane.

**Inspect:**

- findings from Tasks 1–10
- `CHANGELOG.md`
- `.octon/instance/cognition/decisions/**`
- `.octon/instance/governance/retirement-register.yml`
- `.octon/framework/engine/runtime/README.md`
- `.octon/framework/product/features/catalog.yml`

**Questions:**

1. Which risks block live support claims?
2. Which risks block future connector/browser/API admission?
3. Which work must be architecture-first, planning-second, implementation-third?
4. Which migrations require rollback plans?
5. Which generated or compatibility surfaces should be retired first?

**Expected artifact:**  
A **Risk-Burn-Down Roadmap** with milestones, gates, rollback posture, and non-goals.

**Quality bar:**  
Must not include code tasks until architecture acceptance criteria exist.

**Feeds into:** planning, governance, implementation sequencing.

---

# Tier 3 — delegate to cheaper models, coding agents, or standard review passes

These are useful, but not worth scarce Octon Architect unless they become blockers.

1. **Plain repo summaries and feature inventories.** The README, `.octon/README.md`, and feature catalog already provide orientation; a cheaper model can summarize them.   
2. **Schema-by-schema documentation cleanup.** Use cheaper models once Octon Architect has identified architectural contradictions.  
3. **Validator script linting and shell style cleanup.** Standard static review is enough unless a validator is being used as proof for a live claim.  
4. **Rust refactor suggestions inside already-accepted boundaries.** Coding agents can handle modularization after Octon Architect defines boundary acceptance criteria.  
5. **Generating test fixtures from an already-approved negative-control matrix.** Cheaper implementation agents can create fixtures.  
6. **Changelog/release note drafting.** Delegate after governance and disclosure claims are settled.  
7. **Mechanical path parity checks.** Use scripts and lightweight agents for adapter parity, symlink/copy checks, and catalog consistency.  
8. **Routine issue/PR triage.** Use cheaper models unless the PR changes authority, support, runtime, governance, evidence, or generated/effective semantics.

---

# How this maps to your requested categories

## 1. Deep Reasoning

Use Octon Architect for these hard questions:

- **Can Octon remain the governing control layer while adding stewardship, connectors, self-evolution, generated effective handles, and external trust?**
- **Where does “derived but runtime-facing” become an authority ambiguity?**
- **Are mission, stewardship, planning, engagement compilation, and self-evolution layers genuinely preparation/coordination layers, or do any of them become execution authority?**
- **Is deny-by-default still true when the system has many stage-only, projection-only, compatibility-only, and generated surfaces?**
- **What is the smallest safe future expansion path for browser/API/connectors without turning Octon into a second uncontrolled agent runtime?**
- **Is support proof actually executable/replayable, or is it mostly declarative?**

The unresolved tensions worth Octon Architect attention are:

- **Generated/effective runtime handles:** generated artifacts are non-authority, yet runtime may consume them through handles. This is legitimate but fragile.  
- **Context packs:** context is evidence, not authority, yet it is model-visible and participates in authorization.  
- **Long-running autonomy:** stewardship may remain available indefinitely, but work must remain finite and run-bound.  
- **Self-evolution:** Octon can improve itself but must never self-approve or self-promote.  
- **Compatibility surfaces:** retained shims are useful for migration but dangerous if any runtime/policy/support consumer still reads them.  
- **Stage-only surfaces:** stage-only is safer than live, but only if disclosures, generated maps, and docs never imply support.

## 2. Architecture

Octon Architect should review architecture in this order:

1. **Authority and class-root topology** — `framework`, `instance`, `state`, `generated`, `inputs`.  
2. **Execution authorization boundary** — `GrantBundle`, `AuthorizedEffect<T>`, `VerifiedEffect<T>`, side-effect inventory.  
3. **Run lifecycle and journal truth** — `runtime_bus`, `events.ndjson`, `runtime-state.yml`, closeout.  
4. **Runtime resolution and generated/effective handles** — resolver-only consumption, freshness, publication receipts.  
5. **Support universe and capability packs** — admitted tuples, unadmitted packs, proof bundles.  
6. **Context/memory** — context-pack evidence, model-visible serializations, omissions, freshness, source classes.  
7. **Long-horizon layers** — stewardship, missions, self-evolution, recertification.  
8. **Tool/plugin/connector interfaces** — connector admission, browser/API capability packs, external operations.  
9. **Assurance/evaluation** — validator depth, proof executability, negative controls.  
10. **Disclosure/replay/rollback** — retained evidence closure and auditability.

## 3. Reviews Octon Architect should perform

The most valuable review types are:

- **Architecture review:** inspect whether the structural model has one control plane and clean authority boundaries. Output: authority topology findings memo.
- **Failure-mode review:** inspect ways generated outputs, context, continuity, host surfaces, compatibility projections, or connector state could bypass governance. Output: adversarial scenario matrix.
- **Authority-boundary review:** inspect authorization, effect tokens, support tuples, capability packs, approvals, exceptions, revocations. Output: boundary coverage dossier.
- **Governance review:** inspect support-target admissions, proof bundles, stage-only declarations, exclusions, amendment rules, self-evolution. Output: governance sufficiency report.
- **Security/safety review:** inspect material side effects, egress, executor launch, repo mutation, CI, connector/API/browser plans. Output: threat model and negative-control plan.
- **Implementation-readiness review:** only after architecture decisions; inspect whether a proposal has acceptance criteria, rollback, tests, docs, and governance gates. Output: implementation-readiness gate.
- **Roadmap review:** inspect sequencing and risk burn-down, not code tasks. Output: milestone plan with gates and non-goals.

## 4. Planning

Spend Octon Architect on planning artifacts only when they require architectural judgment:

Worth Octon Architect:

- **Architecture decision packets** for support expansion, connector admission, generated/effective trust, or self-evolution changes.
- **Implementation-readiness gates** for authority/runtime/governance changes.
- **Migration plans** for retiring compatibility surfaces.
- **Schema-change plans** where schema changes alter authority, evidence, support, or runtime semantics.
- **Negative-control test strategies** for authorization, generated raw-read denial, support widening, and context laundering.
- **Rollback and recertification plans** for self-evolution or support-target changes.
- **Milestone roadmaps** that separate architecture acceptance, planning, implementation, validation, disclosure, and promotion.

Delegate later:

- task breakdowns after acceptance criteria exist;
- fixture generation;
- schema formatting;
- docs synchronization;
- mechanical validator implementation;
- Rust/shell refactors that do not change authority semantics.

## 5. Design critiques Octon Architect should run before coding

The highest-value critique targets are:

1. **Connector admission and browser/API packs** — risk: accidentally admitting external operations before runtime authorization is complete.
2. **Generated/effective runtime handles** — risk: derived outputs become practical authority.
3. **Self-evolution runtime** — risk: evidence/simulation/proposal success becomes implicit approval.
4. **Continuous stewardship** — risk: indefinite availability becomes unbounded work scheduling.
5. **Context pack builder** — risk: model-visible context becomes memory or policy.
6. **Compatibility retirement** — risk: old projections remain live via hidden consumers.
7. **Support-target expansion** — risk: docs/generated cards imply support before proof exists.
8. **Operator read models** — risk: helpful status dashboards become terminal truth.

A good critique should look for overcomplication, underspecification, hidden control loops, faux support tiers, “stage-only but effectively live” surfaces, and “non-authoritative but required” artifacts that are not adequately resolver-gated.

---

# Ready-to-use Octon Architect prompts

## Prompt 1 — Authority topology and second-control-plane review

```text
You are reviewing the Octon repository as a senior governed-runtime architect.

Repository:
https://github.com/jamesryancooper/octon

Task:
Perform an authority-topology and second-control-plane review. Do not summarize the repo. Do not propose implementation work.

Constraints:
- Octon must remain the governing control layer.
- Do not introduce or legitimize a second control plane.
- Provider sessions, assistants, generated outputs, raw model responses, host UI state, comments, labels, checks, and chat transcripts are not authority.
- Preserve deny-by-default execution, evidence, receipts, replay, rollback, auditability, and file-native inspectable artifacts.
- Separate architecture evaluation from implementation planning.

Inspect at minimum:
- README.md
- .octon/README.md
- .octon/framework/constitution/CHARTER.md
- .octon/framework/cognition/_meta/architecture/specification.md
- .octon/framework/cognition/_meta/architecture/contract-registry.yml
- .octon/instance/ingress/AGENTS.md
- .octon/framework/engine/runtime/spec/runtime-resolution-v1.md
- .octon/instance/governance/runtime-resolution.yml
- .octon/framework/engine/runtime/spec/publication-freshness-gates-v4.md
- .octon/framework/engine/runtime/spec/compatibility-retirement-cutover-v2.md

Answer these questions:
1. What are the canonical authority sources?
2. What are mutable control truth, retained evidence, continuity, generated handles, generated read models, compatibility projections, and raw inputs allowed to do?
3. Where could a derived/generated/projection/compatibility surface become de facto authority?
4. Are there duplicated registries or projections whose precedence could diverge?
5. What specific hidden assumptions must be validated before Octon can claim a single control plane?
6. What negative-control tests would prove the second-control-plane risks are blocked?

Output:
- Authority graph
- Source-of-truth matrix
- Suspected second-control-plane risks
- Contradictions or unresolved tensions
- Acceptance criteria for closing each risk
- Explicit assumptions and missing information
- No implementation plan
```

## Prompt 2 — Material side-effect authorization coverage

```text
You are reviewing Octon’s material side-effect boundary.

Repository:
https://github.com/jamesryancooper/octon

Task:
Determine whether every material side-effect path is actually routed through Octon’s engine-owned authorization boundary. Do not implement anything.

Inspect at minimum:
- .octon/framework/engine/runtime/spec/execution-authorization-v1.md
- .octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md
- .octon/framework/engine/runtime/spec/material-side-effect-inventory.yml
- .octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs
- .octon/framework/engine/runtime/crates/authority_engine/src/implementation/effects.rs
- .octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs
- .octon/framework/engine/runtime/crates/kernel/src/pipeline.rs
- .octon/framework/engine/runtime/crates/kernel/src/workflow.rs
- .octon/framework/engine/runtime/crates/kernel/src/stdio.rs
- .github/workflows/**
- .octon/framework/assurance/runtime/_ops/tests/*authorized* and *material-side-effect*

Questions:
1. What counts as material execution in Octon?
2. Is every material path inventoried?
3. For each live path, where is authorize_execution called?
4. For each live path, where is AuthorizedEffect<T> verified into VerifiedEffect<T> before mutation?
5. Are any shell scripts, workflows, publication helpers, closeout helpers, host projections, or CI flows able to mutate without token verification?
6. Are effect-token issuance, verification, consumption, rejection, expiry, revocation, and already-consumed cases journaled and receipted?
7. Which declared coverage claims are only documented rather than enforced?

Output:
- Material side-effect coverage table
- Missing or suspect paths
- Bypass scenarios
- Negative-control gap list
- Acceptance gates for “complete authorization coverage”
- Evidence citations to exact files/paths
- No implementation plan
```

## Prompt 3 — Run lifecycle and journal truth review

```text
You are reviewing Octon’s run lifecycle and journal-as-control-truth model.

Repository:
https://github.com/jamesryancooper/octon

Task:
Pressure-test whether the Run Journal, runtime-state materialization, lifecycle transitions, closeout, replay, and evidence snapshots preserve one canonical execution truth.

Inspect at minimum:
- .octon/framework/engine/runtime/spec/run-lifecycle-v1.md
- .octon/framework/engine/runtime/spec/run-journal-v1.md
- .octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs
- .octon/framework/engine/runtime/crates/authority_engine/src/implementation/runtime_state.rs
- .octon/framework/engine/runtime/spec/evidence-store-v1.md
- .octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-v1.sh
- .octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-transition-coverage.sh
- .octon/framework/assurance/runtime/_ops/fixtures/run-lifecycle-v1/**

Questions:
1. Is runtime_bus truly the only append path?
2. Can any runtime or script mutate events.ndjson, events.manifest.yml, runtime-state.yml, or closeout snapshots in a way that bypasses lifecycle validation?
3. Are all lifecycle transitions necessary, sufficient, and non-overlapping?
4. Can denied, staged, revoked, failed, or rolled_back states accidentally advance work?
5. Is closeout impossible without evidence-store completeness, rollback posture, disclosure, review/risk disposition, and hash-matching journal snapshots?
6. Can replay reconstruct truth without generated/operator projections?
7. What adversarial scenarios would break auditability?

Output:
- Lifecycle state-machine critique
- Journal/control/evidence boundary map
- Forbidden mutation-path inventory
- Closeout failure scenarios
- Replay falsifiability checklist
- Acceptance criteria
- No implementation plan
```

## Prompt 4 — Support envelope and proof sufficiency

```text
You are reviewing Octon’s support-claim envelope.

Repository:
https://github.com/jamesryancooper/octon

Task:
Determine whether admitted-live support claims are finite, proof-backed, and impossible to widen through generated projections, support cards, docs, adapters, or capability-pack routing.

Inspect at minimum:
- .octon/instance/governance/support-targets.yml
- .octon/instance/governance/support-target-admissions/**
- .octon/instance/governance/support-dossiers/**
- .octon/instance/governance/contracts/support-target-proofing.yml
- .octon/state/evidence/validation/support-targets/**
- .octon/generated/effective/governance/support-target-matrix.yml
- .octon/generated/cognition/projections/materialized/support-cards/**
- .octon/instance/governance/capability-packs/*.yml
- .octon/framework/engine/runtime/spec/architecture-health-contract-v3.md

Questions:
1. What exactly is admitted live today?
2. Which surfaces are stage-only, unadmitted, retired, or unsupported?
3. Does every admitted-live tuple have executable or replayable proof, representative retained runs, negative controls, disclosure coverage, and current freshness?
4. Can generated support matrices or support cards widen support claims?
5. Do host/model adapter declarations imply broader support than tuple admissions?
6. Are browser/API/frontier/studio surfaces sufficiently fenced from live support?
7. What gates must pass before any support expansion?

Output:
- Live tuple proof table
- Non-live leakage risks
- Support-widening hazards
- Proof-executability gaps
- Required acceptance gates
- No implementation plan
```

## Prompt 5 — Context, memory, and model-visible evidence review

```text
You are reviewing Octon’s context and memory discipline.

Repository:
https://github.com/jamesryancooper/octon

Task:
Determine whether context packs and model-visible context remain evidence only, never authority, memory, policy, approval, support, or control truth.

Inspect at minimum:
- .octon/framework/execution-roles/governance/MEMORY.md
- .octon/framework/engine/runtime/spec/context-pack-builder-v1.md
- .octon/framework/engine/runtime/spec/context-pack-receipt-v1.schema.json
- .octon/instance/governance/policies/context-packing.yml
- .octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs
- .octon/framework/assurance/runtime/_ops/scripts/validate-context-pack-builder.sh
- .octon/framework/assurance/runtime/_ops/tests/test-context-pack-builder.sh

Questions:
1. Can context-pack evidence become hidden canonical memory?
2. Are generated, raw, proposal-local, host UI, labels, comments, chat, and model outputs always classified as non-authoritative when included?
3. Is supplied context binding validated as-is, without silent laundering/rebuild?
4. Does context freshness rely on acceptable freshness modes, or are there fake-freshness assumptions?
5. Is the 9999-12-31 valid_until pattern safe here or a contradiction with runtime freshness policy?
6. Are omissions, redactions, compaction, and semantic cache reuse replayable and audit-preserving?
7. What negative controls should prove context cannot authorize execution?

Output:
- Context source-class map
- Hidden-memory and laundering scenarios
- Freshness-risk analysis
- Model-visible contamination tests
- Acceptance criteria
- No implementation plan
```

## Prompt 6 — Long-horizon autonomy and self-evolution review

```text
You are reviewing Octon’s long-horizon autonomy and self-evolution architecture.

Repository:
https://github.com/jamesryancooper/octon

Task:
Determine whether Continuous Stewardship, Mission Autonomy, and Self-Evolution preserve mission-scoped, reversible autonomy without self-approval, unbounded work, or a second control plane.

Inspect at minimum:
- .octon/framework/engine/runtime/spec/continuous-stewardship-runtime-v3.md
- .octon/framework/engine/runtime/README.md
- .octon/instance/cognition/decisions/102-self-evolution-proposal-to-promotion-runtime.md
- .octon/framework/engine/runtime/spec/evolution-program-v1.schema.json
- .octon/framework/engine/runtime/spec/promotion-runtime-v1.md
- .octon/framework/engine/runtime/spec/recertification-runtime-v1.md
- .octon/state/control/evolution/**
- .octon/state/evidence/evolution/**
- .octon/instance/governance/evolution/**

Questions:
1. Can stewardship remain available indefinitely without creating unbounded work?
2. Does every path to material work pass through Mission Runner, Action Slice, Run Contract, Governed Run, authorization, and journal evidence?
3. Can mission plans, queues, continuation decisions, or generated mission views become execution authority?
4. Can self-evolution propose, approve, promote, recertify, or rollback itself?
5. Are simulation success, lab success, evidence distillation, generated summaries, and proposal packets unable to authorize change?
6. Are rollback and recertification mandatory for self-evolution promotions?
7. What feedback loops could widen authority over time?

Output:
- Autonomy loop diagram
- Self-approval impossibility analysis
- Feedback-loop risks
- Human/quorum boundary map
- Acceptance gates for future autonomy expansion
- No implementation plan
```

## Prompt 7 — Connector/browser/API admission critique

```text
You are reviewing Octon’s connector, browser, API, plugin, and external-tool admission model.

Repository:
https://github.com/jamesryancooper/octon

Task:
Critique whether connector admission and future browser/API packs can be added without turning Octon into a generic uncontrolled agent runtime or second control plane.

Inspect at minimum:
- .octon/framework/engine/runtime/README.md
- .octon/framework/engine/runtime/spec/connector-admission-v1.schema.json
- .octon/instance/governance/connectors/**
- .octon/state/control/connectors/**
- .octon/state/evidence/connectors/**
- .octon/instance/governance/capability-packs/browser.yml
- .octon/instance/governance/capability-packs/api.yml
- .octon/framework/engine/runtime/spec/material-side-effect-inventory.yml

Questions:
1. What is the current connector posture: observe/read/admin preparation versus material operation?
2. Does any connector admission state imply operation authority?
3. Are browser/API packs correctly unadmitted and escalate-by-default?
4. What proof is required before browser/API or connector operations can become live?
5. How should connector receipts relate to run evidence, replay, rollback, and support proof?
6. What names or states are misleading enough to cause operator/model confusion?
7. What must be denied until runtime authorization is complete?

Output:
- Connector admission critique
- Browser/API admission gates
- Misleading-state/name risks
- Deny-until matrix
- Acceptance criteria
- No implementation plan
```

## Prompt 8 — Roadmap after architecture review

```text
You are creating a planning artifact for Octon, but only after architecture review. Do not propose implementation before architecture gates.

Repository:
https://github.com/jamesryancooper/octon

Inputs:
Use the findings from prior reviews of authority topology, material side-effect coverage, run lifecycle, support proof, context/memory, generated-effective trust, connectors, and autonomy.

Task:
Create a risk-burn-down roadmap that sequences architecture clarification, governance decisions, proof gaps, validator/test gaps, compatibility retirement, and only then implementation planning.

Rules:
- Separate architecture evaluation from implementation planning.
- Separate implementation planning from implementation.
- Preserve Octon as the sole governing control layer.
- Preserve deny-by-default, mission-scoped reversible autonomy, evidence, receipts, replay, rollback, and auditability.
- Prefer file-native, inspectable, portable artifacts.
- Be explicit about assumptions, risks, missing information, and acceptance criteria.

Output:
- Milestone roadmap
- For each milestone: purpose, blocking risks, files/areas, decision gates, proof gates, rollback posture, output artifact
- Explicit “not yet implementation” items
- Work suitable for cheaper agents after gates pass
- Stop conditions
```

---

# you asked

message time: 2026-07-03 19:43:19

You are a senior AI-systems architect, governed-runtime reviewer, agent-harness critic, and implementation-planning strategist.

Your task is to **verify, challenge, and refine the previously identified highest-value review targets for Octon**.

Do not simply confirm the existing list. Treat the current review targets as hypotheses that must be tested against Octon’s architecture, governance model, runtime boundaries, support claims, evidence requirements, and long-term product direction.

Repository:

```text
https://github.com/jamesryancooper/octon
```

Primary objective:

```text
Verify whether the identified highest-value review targets are truly the best use of scarce Octon Architect-level reasoning, and determine whether any additional high-value review targets were missed.
```

Important constraints:

* Octon must remain the governing control layer.
* Do not introduce or legitimize a second control plane.
* Provider sessions, assistants, generated outputs, raw model responses, host UI state, comments, labels, checks, chat transcripts, and generated read models are not authority.
* Preserve mission-scoped, reversible autonomy.
* Preserve deny-by-default execution.
* Preserve evidence, receipts, replay, rollback, disclosure, and auditability.
* Prefer file-native, inspectable, portable artifacts.
* Separate architecture evaluation from implementation planning.
* Separate implementation planning from implementation.
* Do not propose coding tasks prematurely.

Review the previously identified targets and answer:

1. Which targets are correctly identified as highest value?
2. Which targets are overstated, redundant, too broad, too narrow, or better delegated to cheaper models?
3. Which targets should be merged, split, promoted, demoted, or reframed?
4. What additional high-value review targets were overlooked?
5. Are there hidden architectural risks not covered by the current target list?
6. Are there important Octon surfaces that deserve Octon Architect review because they involve authority, governance, runtime execution, support claims, context/memory, evidence, autonomy, connectors, generated outputs, or external trust?
7. Does the current prioritization reflect the real risk to Octon’s core invariants?
8. What should the final prioritized Octon Architect usage plan be?

For each confirmed or newly identified high-value target, provide:

* Task name
* Why it deserves scarce Octon Architect usage
* Specific Octon areas or files to inspect
* Key questions the review must answer
* Expected output artifact
* Quality criteria for judging the output
* Whether the result should feed into architecture, planning, implementation, tests, documentation, governance, or roadmap decisions
* Recommended priority tier: Tier 1, Tier 2, or Tier 3

Also provide:

* A revised prioritized usage plan
* A list of omitted or underweighted review targets, if any
* A list of targets that should be delegated to cheaper models or implementation agents
* Any assumptions, uncertainties, or missing repository information
* A final recommendation for the most efficient use of limited Octon Architect access

The output should be repo-grounded, evidence-based, critical, and implementation-useful, but it should remain an architectural review and prioritization exercise—not an implementation plan.

---

# source model response

I’ll treat the prior target list as provisional, re-rank it against Octon’s core invariants, and probe underweighted surfaces like policy precedence, ownership, overlays, external trust, portability, egress/budgets, closeout, and disclosure.

---

# source model response

The ranking is shifting toward promoting policy/preflight conflict handling and external-trust/imported-proof boundaries, because they can alter authority without appearing as runtime execution.

---

# source model response

# Verdict

The prior target list was directionally right, but not optimized for scarce Octon Architect usage. The strongest targets were correctly centered on **authority boundaries, material side effects, run truth, support claims, context/memory, and autonomy**. However, the list underweighted four areas that are high-risk in Octon’s actual architecture:

1. **Policy/ACP, budget, egress, and instruction-layer enforcement** as a first-class review target, not merely a subtopic of material side effects.
2. **Human authority artifact lifecycle**: approvals, exceptions, revocations, ownership, break-glass, and run-specific authority.
3. **Generated-effective resolver/freshness/compatibility retirement**: previously Tier 2, but it is central to preventing generated outputs from becoming authority.
4. **External trust, portability, adoption, federation, and imported proof**: not a live execution path today, but architecturally dangerous enough to deserve Octon Architect review before it expands.

The prior plan also treated **evidence closure** as Tier 2. I would promote it and merge it with run lifecycle/replay/rollback review, because Octon’s core trust claim depends on retained evidence being sufficient to close, replay, disclose, and audit consequential runs.

Octon’s own architecture makes this prioritization clear: its runtime is framed as a Governed Workflow Runtime where workflow state owns control flow and agents participate only as bounded evidenced activity nodes.  The Charter then makes the hard invariants explicit: generated and input surfaces are not authority, missing evidence/support/ownership fails closed, material effects require authority routing, host/model adapters are replaceable non-authoritative boundaries, and final disclosure must exclude unsupported or unadmitted surfaces. 

---

# Assessment of the previous target list

## Correctly identified as highest value

The following previous targets are genuinely high leverage:

**Authority topology / second-control-plane review.** Correct, but it should be expanded to include normative and epistemic precedence, run-specific authority artifacts, and generated-effective resolver trust. Octon’s normative precedence explicitly places external obligations/break-glass/live revocations above repo-local authority, then the constitutional kernel, governance declarations, run-specific approval/exception/revocation artifacts, mission authority, run contracts, and lifecycle control. 

**Material side-effect boundary review.** Correct, but too narrow if limited to `authorize_execution` and effect tokens. It must include policy launcher semantics, ACP receipts, egress, budgets, instruction-layer manifests, inferred capability packs, host/model adapters, and unadmitted pack denial. The policy interface says material HTTP/model-backed execution must satisfy egress, budget, ownership, support-target, adapter, capability-pack, evidence, receipt, assurance, measurement, replay, trace, and disclosure requirements. 

**Run lifecycle / journal truth review.** Correct, and it should remain Tier 1. The run lifecycle contract says `events.ndjson` and `events.manifest.yml` are canonical transition records, while `runtime-state.yml` is only a mutable derived view.  The Run Journal spec says `runtime_bus` is the only canonical append path and forbids raw journal writes, rewrites, direct manifest mutation, or generated/operator read models as journal inputs. 

**Support envelope / proof sufficiency review.** Correct. Octon’s live support universe is bounded and finite, while stage-only/unadmitted surfaces coexist in the same support model.  That makes leakage from stage-only to live support a primary risk.

**Context and memory review.** Correct. Octon explicitly says no execution role owns canonical memory, and generated cognition may appear only as labeled derived input, never as authority, approval, override, publication, or evidence fulfillment. 

**Long-horizon autonomy and self-evolution review.** Correct. Stewardship may remain available indefinitely, but work may not become unbounded, and stewardship must hand off to mission/run machinery rather than execute material work directly.  Self-evolution is also high-risk because it improves Octon itself while prohibiting models, proposals, lab success, simulations, generated summaries, and evidence distillation from becoming authority. 

## Overstated, redundant, or better reframed

**Architecture-health review was slightly overstated as an early target.** It is valuable, but it is a meta-review. Octon Architect should first review the actual authority, runtime, evidence, support, context, and autonomy surfaces. Then architecture-health validator depth can determine whether validators truly prove those findings.

**Roadmap review was premature.** A Octon Architect-generated roadmap is useful only after the architectural reviews produce concrete findings. Before that, roadmap work risks becoming generic sequencing.

**Connector review was correctly identified but should be conditional Tier 2.** Connectors/browser/API become Tier 1 only if those surfaces are about to be admitted. Today, browser/API packs are unadmitted and escalate-by-default.  

**Generated-effective handle review was under-ranked.** It should not remain a mere Tier 2 review. Runtime-facing generated/effective outputs are exactly where “generated but consumed by runtime” can become a hidden control plane. Runtime resolution says trust resolves through resolver-verified handles and fails closed on missing/drifted digests, stale receipts, invalid non-authority classification, or forbidden consumers. 

**Evidence closure was under-ranked.** It should be merged with run lifecycle/replay/rollback as Tier 1. Evidence Store v1 says closeout is valid only when required artifacts exist, journal snapshots hash-match control truth, disclosure is generated from retained evidence, generated read models are not used as proof, and missing required evidence blocks closure/promotion/live claim activation. 

---

# Revised highest-value Octon Architect targets

## Tier 1

## 1. Single-Control-Plane, Authority Precedence, and Human Authority Artifact Review

**Why it deserves Octon Architect:**  
This is the foundation. Octon has many surfaces that look authoritative: constitutional docs, governance policies, support targets, run contracts, approvals, exceptions, revocations, mission state, generated effective outputs, evidence, and read models. Octon Architect should determine whether precedence is coherent enough to prevent implicit or competing control planes.

**Inspect:**

- `.octon/framework/constitution/CHARTER.md`
- `.octon/framework/constitution/precedence/normative.yml`
- `.octon/framework/constitution/precedence/epistemic.yml`
- `.octon/framework/constitution/ownership/roles.yml`
- `.octon/framework/constitution/obligations/fail-closed.yml`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `.octon/state/control/execution/approvals/**`
- `.octon/state/control/execution/exceptions/**`
- `.octon/state/control/execution/revocations/**`

**Key questions:**

- Does Octon cleanly distinguish normative authority from factual/epistemic truth?
- Can validated evidence or generated-effective state describe facts without becoming authority?
- Are approvals, exceptions, revocations, break-glass directives, and ownership unambiguous and current?
- Are host labels/comments/checks always ignored when canonical authority disagrees?
- Can a model, assistant, provider session, generated summary, or operator comment mint authority indirectly?

**Expected artifact:**  
A **Control-Plane and Authority Precedence Memo** with an authority graph, precedence conflict matrix, human authority lifecycle map, and second-control-plane risk register.

**Quality criteria:**  
It must cite exact repo files, distinguish “authority,” “control truth,” “evidence,” “factual observation,” and “read model,” and provide negative-control scenarios for host labels, generated outputs, model memory, stale approvals, and revoked authority.

**Feeds into:** architecture, governance, tests, documentation.

**Priority:** Tier 1.

---

## 2. Generated-Effective Resolver, Freshness, and Compatibility De-Authorization Review

**Why it deserves Octon Architect:**  
This is the most subtle architectural tension. Octon says generated outputs never mint authority, yet some generated/effective artifacts are runtime-facing. The only safe pattern is resolver-verified, freshness-checked, non-authoritative handle consumption. Publication Freshness v4 rejects raw-path bypass, stale/missing handles, drifted receipts, fake far-future trust, dependency drift, and direct use of publication-only support matrices as runtime authority. 

**Inspect:**

- `.octon/framework/engine/runtime/spec/runtime-resolution-v1.md`
- `.octon/instance/governance/runtime-resolution.yml`
- `.octon/framework/engine/runtime/spec/runtime-effective-artifact-handle-v2.md`
- `.octon/framework/engine/runtime/spec/runtime-effective-route-bundle-lock-v3.schema.json`
- `.octon/framework/engine/runtime/spec/publication-freshness-gates-v4.md`
- `.octon/framework/engine/runtime/spec/compatibility-retirement-cutover-v2.md`
- `.octon/instance/governance/retirement-register.yml`
- `.octon/generated/effective/**`
- `.octon/instance/capabilities/runtime/packs/**`

**Key questions:**

- Are all runtime-facing generated/effective artifacts consumed only through resolver-verified handles?
- Can any raw generated/effective path influence authorization, support, policy, or runtime routing?
- Are publication receipts, source digests, dependency handles, freshness modes, and forbidden consumers enforced recursively?
- Are compatibility projections truly compatibility-only?
- Are old capability-pack projections or ingress shims still live in any hidden consumer?

**Expected artifact:**  
A **Generated-Effective Trust Review** with handle graph, direct-read risk table, freshness failure matrix, compatibility retirement findings, and no-authority acceptance criteria.

**Quality criteria:**  
It must identify exact resolver gates, exact forbidden consumers, direct-read negative controls, and any gap between “declared non-authority” and “runtime actually consumes this.”

**Feeds into:** architecture, tests, governance, documentation.

**Priority:** Tier 1.

---

## 3. Material Side-Effect Authorization and Policy/ACP Enforcement Review

**Why it deserves Octon Architect:**  
The previous target correctly focused on material side effects, but it must be broadened. Octon’s execution authorization spec requires all material execution to pass through `authorize_execution(request) -> GrantBundle`, with material APIs consuming typed `AuthorizedEffect<T>` and verifying them into `VerifiedEffect<T>` before mutation.  But the policy interface also governs egress, budgets, instruction-layer manifests, support routing, adapter metadata, and capability-pack inference.

**Inspect:**

- `.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
- `.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md`
- `.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml`
- `.octon/framework/engine/runtime/spec/policy-interface-v1.md`
- `.octon/instance/governance/policies/network-egress.yml`
- `.octon/instance/governance/policies/execution-budgets.yml`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/effects.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/**`
- `.github/workflows/**`

**Key questions:**

- Is every material side-effect path inventoried and token-gated?
- Are policy/ACP receipts required before material paths?
- Can egress policy or budget policy be mistaken for execution authority?
- Does `missing_cost_evidence_action: stage_only` ever become de facto continuation?
- Are outbound HTTP and browser-driving metadata correctly mapped to unadmitted `api`/`browser` packs and denied unless admitted? 
- Are shell scripts, CI workflows, closeout helpers, publication scripts, and host projections covered?
- Are instruction-layer manifests mandatory for material policy evaluations? 

**Expected artifact:**  
A **Material Boundary and Policy Enforcement Dossier** with material-path inventory, policy/authorization sequence diagram, token coverage table, bypass scenarios, and negative-control gaps.

**Quality criteria:**  
It must separate `ALLOW`, `STAGE_ONLY`, `ESCALATE`, and `DENY`; distinguish “policy permits” from “execution authorized”; and cite both spec and code/runtime entrypoints.

**Feeds into:** architecture, governance, tests, later implementation planning.

**Priority:** Tier 1.

---

## 4. Run Lifecycle, Journal Truth, Evidence Closure, Replay, and Rollback Review

**Why it deserves Octon Architect:**  
This should merge two previous targets: run journal review and evidence closure review. If the journal, evidence store, replay, rollback, and closeout rules diverge, Octon loses auditability even if authorization is correct.

**Inspect:**

- `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `.octon/framework/engine/runtime/spec/run-journal-v1.md`
- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/runtime_state.rs`
- lifecycle validators and fixtures under `.octon/framework/assurance/runtime/_ops/**`
- representative run evidence under `.octon/state/evidence/runs/**`

**Key questions:**

- Is `runtime_bus` actually the only append path?
- Can `runtime-state.yml` drift be accepted as truth?
- Are denied/staged/revoked/failed/rolled-back states non-advancing where required?
- Is closeout impossible without evidence completeness, disclosure, rollback posture, review/risk disposition, and hash-matching journal snapshots?
- Can replay reconstruct from canonical journal and retained evidence without trusting generated views?
- Are compact evidence views helpful without replacing raw/full retained evidence?

**Expected artifact:**  
A **Lifecycle Truth and Evidence Closure Review** with state-machine critique, journal mutation-path inventory, closeout gate checklist, replay reconstruction checklist, rollback gap analysis, and evidence-boundary risks.

**Quality criteria:**  
It must include adversarial closeout scenarios and specify which invariant catches each one. It should explicitly flag any scenario not caught by current contracts or validators.

**Feeds into:** architecture, tests, disclosure, governance.

**Priority:** Tier 1.

---

## 5. Support Claim Envelope and Proof Executability Review

**Why it deserves Octon Architect:**  
Octon’s product claim is bounded support, not universal autonomy. The support proofing contract requires each admitted support tuple to carry current proof linking admission, dossier sufficiency, representative runs, proof planes, negative controls, execution receipts, and disclosure coverage. It also says metadata-only or summary-only proof is insufficient for admitted-live claims. 

**Inspect:**

- `.octon/instance/governance/support-targets.yml`
- `.octon/instance/governance/support-target-admissions/**`
- `.octon/instance/governance/support-dossiers/**`
- `.octon/instance/governance/contracts/support-target-proofing.yml`
- `.octon/state/evidence/validation/support-targets/**`
- `.octon/generated/effective/governance/support-target-matrix.yml`
- `.octon/generated/cognition/projections/materialized/support-cards/**`
- `.octon/instance/governance/capability-packs/*.yml`

**Key questions:**

- What is actually admitted live today?
- Does every admitted-live tuple have executable or replayable proof?
- Do representative retained runs and negative controls exist for each claim?
- Can generated support matrices/cards widen claims?
- Do adapter declarations imply broader support than tuple admissions?
- Are browser, API, frontier, studio, and boundary-sensitive surfaces safely non-live unless admitted?

**Expected artifact:**  
A **Support Envelope Certification Review** with live tuple proof table, non-live leakage risks, proof-executability gaps, and support-expansion gates.

**Quality criteria:**  
It must separate “declared,” “generated,” “proved,” “stage-only,” “unadmitted,” and “unsupported.” It should reject summary-only proof.

**Feeds into:** governance, tests, disclosure, roadmap.

**Priority:** Tier 1.

---

## 6. Context, Memory, and Model-Visible Integrity Review

**Why it deserves Octon Architect:**  
Context is both necessary and dangerous. The Context Pack Builder deterministically produces retained context evidence before authorization, but it is explicitly not a control plane, approval authority, memory subsystem, or policy interpreter.  This boundary should be attacked hard.

**Inspect:**

- `.octon/framework/execution-roles/governance/MEMORY.md`
- `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `.octon/framework/engine/runtime/spec/context-pack-receipt-v1.schema.json`
- `.octon/instance/governance/policies/context-packing.yml`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs`
- context-pack validators/tests

**Key questions:**

- Can context packs become durable model memory?
- Are raw inputs, generated outputs, proposal-local files, host UI state, labels, comments, and chat always classified as non-authoritative when included?
- Can invalid supplied context be silently rebuilt or laundered?
- Are omissions/redactions/compactions replayable?
- Is the context freshness model coherent, especially any far-future `valid_until` patterns, given Octon’s broader rejection of fake far-future freshness for runtime trust?
- Can model-visible context prompt an agent to treat non-authority as authority?

**Expected artifact:**  
A **Context and Memory Boundary Review** with source-class map, laundering scenarios, contamination tests, freshness risks, and acceptance criteria.

**Quality criteria:**  
It must include concrete adversarial model-visible context examples and expected denial behavior.

**Feeds into:** architecture, tests, documentation, governance.

**Priority:** Tier 1.

---

## 7. Mission-Scoped Autonomy, Stewardship, and Self-Evolution Feedback-Loop Review

**Why it deserves Octon Architect:**  
This review is not about whether Octon can be autonomous; it is about whether autonomy remains mission-scoped, reversible, interruptible, and non-self-authorizing. Mission autonomy policy includes proceed-on-silence constraints, forbidden action classes, autonomy burn states, circuit breakers, safing defaults, quorum rules, and proposal-classification defaults. 

**Inspect:**

- `.octon/instance/governance/policies/mission-autonomy.yml`
- `.octon/framework/engine/runtime/spec/continuous-stewardship-runtime-v3.md`
- `.octon/framework/engine/runtime/README.md`
- `.octon/instance/cognition/decisions/102-self-evolution-proposal-to-promotion-runtime.md`
- `.octon/framework/engine/runtime/spec/evolution-program-v1.schema.json`
- `.octon/framework/engine/runtime/spec/promotion-runtime-v1.md`
- `.octon/framework/engine/runtime/spec/recertification-runtime-v1.md`
- `.octon/state/control/evolution/**`
- `.octon/state/evidence/evolution/**`

**Key questions:**

- Can stewardship renew or admit work without bounded mission/run handoff?
- Can mission queues, continuation decisions, or generated mission views become execution authority?
- Are proceed-on-silence paths limited to reversible/compensable cases?
- Do circuit breakers actually downgrade/suspend/pause autonomy?
- Can self-evolution propose, approve, promote, recertify, or rollback itself?
- Can lab success, simulations, generated summaries, or evidence distillation become implicit approval?

**Expected artifact:**  
A **Bounded Autonomy and Self-Evolution Risk Memo** with feedback-loop diagram, self-approval impossibility analysis, safing/circuit-breaker critique, and acceptance gates.

**Quality criteria:**  
It must identify feedback loops where “evidence of good behavior” could become “permission to widen behavior.”

**Feeds into:** architecture, governance, roadmap, tests.

**Priority:** Tier 1.

---

# Tier 2 targets

## 8. Connector, Browser, API, Plugin, and External Operation Admission Review

**Why it deserves Octon Architect if access remains:**  
Connectors and browser/API packs are the most likely path from governed repo-local runtime into uncontrolled external agency. Connector commands are currently administrative/preparation surfaces and must not execute MCP/API/browser/service operations; material connector execution is deferred through run contracts, context packing, authorization, effect-token verification, journal evidence, and connector receipts. 

**Inspect:**

- `.octon/framework/engine/runtime/spec/connector-admission-v1.schema.json`
- `.octon/instance/governance/connectors/**`
- `.octon/state/control/connectors/**`
- `.octon/state/evidence/connectors/**`
- `.octon/instance/governance/capability-packs/browser.yml`
- `.octon/instance/governance/capability-packs/api.yml`
- connector runtime tests

**Key questions:**

- Does connector admission ever imply execution authority?
- Are `--live` or similar terms potentially misleading?
- What proof is required before browser/API operations become admitted?
- Are connector receipts sufficient but not substitutive for run evidence?
- Can connector availability, MCP server state, or API metadata become authority?

**Expected artifact:**  
A **Connector Admission Critique** with deny-until matrix and admission gates.

**Quality criteria:**  
It must distinguish connector trust, connector admission, connector operation, support admission, and material execution.

**Feeds into:** architecture, governance, future roadmap.

**Priority:** Tier 2, promoted to Tier 1 only if connector/browser/API admission is imminent.

---

## 9. External Trust, Portability, Adoption, Federation, and Imported Proof Review

**Why it was missed:**  
This was the biggest omission in the prior list. Octon already has external project adoption and trust/federation posture. The adoption policy forbids blind `.octon` copies, copying `instance/**` as authority, copying `state/**` as current truth, copying `generated/**` as source truth, and requires local generated rebuild, repo-specific instance authority, support-target admission, and bootstrap checks.  Trust compatibility profiles also repeatedly state that external artifacts do not authorize execution and non-Octon systems cannot be federation peers. 

**Inspect:**

- `.octon/instance/governance/trust/compatibility-profile.yml`
- `.octon/instance/governance/trust/policies/external-project-adoption.yml`
- `.octon/state/control/trust/compatibility/status.yml`
- `.octon/state/evidence/trust/**`
- trust/federation/attestation/proof-bundle schemas
- fail-closed and evidence obligations for external trust

**Key questions:**

- Can imported proof become local authority?
- Can federation compact state become a second control plane?
- Are delegated authority leases merely local authorization inputs, not external execution authority?
- Does portability preserve repo-specific instance authority?
- Are external evidence, attestations, and portable proof bundles retained as evidence only?

**Expected artifact:**  
An **External Trust and Portability Review** with adoption threat model, imported-proof authority boundary, federation risk matrix, and local-acceptance gates.

**Quality criteria:**  
It must prove that external trust coordinates evidence and decisions without authorizing execution, widening support, or mutating local authority.

**Feeds into:** architecture, governance, roadmap.

**Priority:** Tier 2, Tier 1 if federation/portable proof is near-term product direction.

---

## 10. Change Closeout, Branch Landing/Cleanup, and Hosted-Control Surface Review

**Why it was underweighted:**  
Closeout is not just documentation. The default work-unit policy includes branch-no-PR flows that may create/select branches, stage, commit, push, run hosted preflight, emit landing authorization, land hosted main, emit cleanup authorization, clean refs, sync main, and record closeout receipt.  That makes closeout a high-risk Git/GitHub/governance intersection.

**Inspect:**

- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- closeout workflows under `.octon/framework/orchestration/runtime/workflows/meta/closeout/**`
- closeout skills under `.octon/framework/capabilities/runtime/skills/remediation/**`
- Git branch landing/cleanup helpers
- repo-hygiene policy and validators

**Key questions:**

- Can “cleaned” closeout become too aggressive?
- Are branch landing and cleanup always separately authorized?
- Are local-private evidence, publishable closeout evidence, terminal proof, generated publications, and cleanup receipts separated?
- Can repeated closeout-worktree delegation become unbounded autonomy?
- Are host checks/GitHub state treated only as projections unless bound to canonical evidence?

**Expected artifact:**  
A **Closeout Authority and Git/GitHub Boundary Review**.

**Quality criteria:**  
It must produce stop conditions, not implementation steps, and must identify any path where closeout can mutate repo/GitHub state without the same authorization standard as other material effects.

**Feeds into:** architecture, governance, tests, documentation.

**Priority:** Tier 2.

---

## 11. Architecture-Health and Validator Depth Review

**Why it remains valuable but not first:**  
Architecture Health v3 defines achieved-depth classes and requires dimensions such as runtime-effective handles, freshness, authorization coverage, support proof executability, publication receipts, and aggregate health to meet semantic/runtime/proof/closure-grade depths.   This review should follow the Tier 1 reviews because it asks whether validators prove the right claims.

**Inspect:**

- `.octon/framework/engine/runtime/spec/architecture-health-contract-v3.md`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-health.sh`
- validators for authorization, support proof, generated freshness, compatibility retirement, context, lifecycle, read models
- closure evidence under `.octon/state/evidence/validation/architecture/**`

**Key questions:**

- Are validators proving existence, schema, semantic, runtime, proof, or closure-grade depth?
- Are negative controls actually executed?
- Are proof claims runnable/replayable?
- Does the aggregate certificate avoid becoming authority?

**Expected artifact:**  
A **Validator Depth Audit**.

**Quality criteria:**  
It must classify achieved depth, not intended depth.

**Feeds into:** tests, governance, release readiness.

**Priority:** Tier 2.

---

## 12. Product Claim, Disclosure, and Operator Read-Model Claim Discipline Review

**Why it deserves review if release/positioning matters:**  
Octon’s README makes product-facing claims about controlled autonomy, bounded admitted work, and non-authoritative generated/read-model surfaces.  The feature catalog is explicitly navigation-only and says it does not mint authority, support claims, runtime routes, generated-effective state, or durable evidence.  Product language can accidentally widen support even when runtime does not.

**Inspect:**

- `README.md`
- `.octon/README.md`
- `.octon/framework/product/features/catalog.yml`
- disclosure contracts and HarnessCard/RunCard outputs
- generated operator read models
- support cards and release disclosure surfaces

**Key questions:**

- Do product docs overclaim beyond admitted support?
- Do generated/operator read models have visible non-authority posture?
- Do HarnessCard/RunCard disclosures exclude stage-only/unadmitted claims?
- Are roadmap/future-facing surfaces clearly marked non-live?

**Expected artifact:**  
A **Claim Envelope and Disclosure Review**.

**Quality criteria:**  
It must compare product claims to support-targets, proof bundles, and disclosure evidence.

**Feeds into:** documentation, governance, roadmap.

**Priority:** Tier 2.

---

# Tier 3 / delegate

These should not consume scarce Octon Architect unless they are directly implicated by a Tier 1 finding:

- Plain repo summaries or onboarding maps.
- Mechanical schema cleanup.
- Markdown wording passes after architecture decisions are made.
- Fixture generation from an approved negative-control matrix.
- Shell/Rust style review.
- Validator implementation details after Octon Architect defines proof gaps.
- Path parity checks for host projections, symlinks, generated catalogs, or registry references.
- Changelog, release-note, and roadmap copy drafting.
- Routine issue/PR triage.
- Implementation sequencing for already-approved narrow fixes.

---

# Revised prioritized Octon Architect usage plan

## Tier 1: must-use

1. **Single-Control-Plane, Authority Precedence, and Human Authority Artifact Review**
2. **Generated-Effective Resolver, Freshness, and Compatibility De-Authorization Review**
3. **Material Side-Effect Authorization and Policy/ACP Enforcement Review**
4. **Run Lifecycle, Journal Truth, Evidence Closure, Replay, and Rollback Review**
5. **Support Claim Envelope and Proof Executability Review**
6. **Context, Memory, and Model-Visible Integrity Review**
7. **Mission-Scoped Autonomy, Stewardship, and Self-Evolution Feedback-Loop Review**

## Tier 2: use if more Octon Architect access remains or if roadmap focus requires it

8. **Connector, Browser, API, Plugin, and External Operation Admission Review**
9. **External Trust, Portability, Adoption, Federation, and Imported Proof Review**
10. **Change Closeout, Branch Landing/Cleanup, and Hosted-Control Surface Review**
11. **Architecture-Health and Validator Depth Review**
12. **Product Claim, Disclosure, and Operator Read-Model Claim Discipline Review**

## Tier 3: delegate

Mechanical inventories, schema formatting, implementation task breakdowns, fixture writing, docs cleanup, code refactors, generated parity checks, and summaries.

---

# Hidden architectural risks not fully covered by the previous list

The previous list covered the obvious core, but these risks were underweighted:

**Normative vs epistemic authority confusion.** Epistemic precedence lets validated runtime evidence win factual disputes, while normative precedence controls authority. That is correct but subtle; evidence must not become permission.

**Run-specific human authority lifecycle.** Approvals, exceptions, revocations, break-glass, and ownership are canonical authority artifacts, not comments or labels. Any stale, missing, duplicated, or host-mirrored artifact could create confusion.

**Policy-as-authority confusion.** Egress and budget policies constrain execution but do not authorize execution. Network egress policy explicitly says it does not authorize execution and material execution still requires run authorization. 

**Stage-only as accidental progress.** Several failures route to `STAGE_ONLY`, not always `DENY`. Octon Architect should check whether stage-only can ever become a “soft allow” in operator workflows or generated projections.

**Capability-pack inference gaps.** The policy interface infers packs from execution features: outbound HTTP implies `api`; browser-driving metadata implies `browser`; unadmitted or unsupported packs fail closed.  This is a critical control point.

**External trust/imported proof laundering.** External proof and federation artifacts are intended to remain evidence or local inputs, never execution authority. The trust profile allows federation-style operations only under local constraints and still says material execution enters local run lifecycle. 

**Closeout over-autonomy.** Closeout has enough authority-adjacent Git/GitHub behavior to deserve review, especially around “cleaned” outcomes, branch landing, branch cleanup, terminal proof, and local vs publishable evidence.

**Context freshness exception risk.** The context system should be reviewed for any far-future freshness patterns. This may be legitimate for context evidence if bounded by source digests and invalidation, but it must not undermine the broader runtime freshness rule.

---

# Assumptions and uncertainties

I am assuming the inspected files represent the current default-branch architecture. I did not exhaustively inspect every Rust module, shell validator, generated artifact, or retained evidence bundle. The revised prioritization is based on the canonical specs, governance files, policy surfaces, and selected runtime implementation files that define Octon’s control model.

The priority of connectors, browser/API packs, and external trust should be raised to Tier 1 if they are near-term product work. If they remain future-facing and unadmitted, they are Tier 2.

The priority of product claim/disclosure review should be raised if Octon is approaching public release, external adoption, or a support-widening milestone.

---

# Most efficient use of limited Octon Architect access

Use Octon Architect in this order:

1. **Control plane + authority precedence + generated-effective trust**  
   This catches the biggest conceptual failure: a hidden second control plane.

2. **Authorization + policy/ACP + material side effects**  
   This catches the biggest operational failure: mutation without valid authority.

3. **Run lifecycle + evidence closure + replay/rollback**  
   This catches the biggest auditability failure: inability to prove what happened.

4. **Support proof + context/memory**  
   This catches the biggest claim-widening and model-contamination failures.

5. **Autonomy/self-evolution feedback loops**  
   This catches the biggest long-term product risk: Octon improving or extending itself into unbounded authority.

Only after those should Octon Architect be used for connector admission, external trust/federation, closeout-specific Git/GitHub review, validator-depth audit, or roadmap planning.

---

# you asked

message time: 2026-07-03 19:54:28

Create a comprehensive **Octon Architect prompt library** for Octon architecture and governance review.

The library should contain one ready-to-use, copy/paste prompt for each high-value review target previously identified. Each prompt should be optimized for scarce Octon Architect usage and should force repo-grounded, evidence-based, implementation-useful analysis without drifting into premature implementation.

Repository:

```text
https://github.com/jamesryancooper/octon
```

The prompt library must cover, at minimum, the following review areas:

1. Single-control-plane, authority precedence, and human authority artifacts
2. Generated-effective resolver, freshness, and compatibility de-authorization
3. Material side-effect authorization and policy/ACP enforcement
4. Run lifecycle, journal truth, evidence closure, replay, and rollback
5. Support claim envelope and proof executability
6. Context, memory, and model-visible integrity
7. Mission-scoped autonomy, stewardship, and self-evolution feedback loops
8. Connector, browser, API, plugin, and external operation admission
9. External trust, portability, adoption, federation, and imported proof
10. Change closeout, branch landing/cleanup, and hosted-control surfaces
11. Architecture-health and validator-depth review
12. Product claim, disclosure, and operator read-model claim discipline

For each prompt in the library, include:

* Prompt title
* Purpose of the review
* Why this review deserves Octon Architect-level reasoning
* Specific Octon files, directories, or surfaces to inspect
* Core invariants the review must preserve
* Exact questions Octon Architect must answer
* Required output format
* Quality criteria for judging the result
* Explicit non-goals, including no implementation unless specifically requested
* Expected downstream use: architecture, governance, tests, documentation, roadmap, planning, or implementation-readiness

Each prompt should require Octon Architect to:

* Cite repository evidence by file path
* Distinguish documented intent from implemented/enforced behavior
* Identify contradictions, hidden assumptions, and unresolved risks
* Separate architecture evaluation from implementation planning
* Separate implementation planning from actual implementation
* Avoid generic advice
* Avoid summarizing the repository
* Avoid legitimizing a second control plane
* Preserve Octon’s core constraints:

  * Octon remains the governing control layer
  * provider sessions, assistants, raw model responses, generated outputs, generated read models, host UI state, labels, comments, checks, and chat transcripts are not authority
  * autonomy remains mission-scoped, reversible, and bounded
  * execution remains deny-by-default
  * evidence, receipts, replay, rollback, disclosure, and auditability are preserved
  * artifacts remain file-native, inspectable, and portable

Also include a final section titled **“How to Use This Prompt Library”** that explains:

* Which prompts should be run first
* Which prompts can be run independently
* Which prompts should be run only after earlier findings exist
* How to combine Octon Architect outputs into an Octon architecture review packet
* Which follow-up work should be delegated to cheaper models or implementation agents
* How to avoid spending Octon Architect capacity on low-leverage summarization, formatting, or coding tasks

The final deliverable should be a polished prompt library that I can paste into Octon Architect prompt-by-prompt.

---

# source model response

I’ll turn the refined target set into self-contained, copy/paste-ready prompts so each can be run independently with limited Octon Architect access.

---

# source model response

# Octon Architect Prompt Library for Octon Architecture and Governance Review

Each prompt below is standalone and ready to paste into Octon Architect. The prompts are designed to force repo-grounded review, distinguish intent from enforcement, and produce architecture-useful outputs without drifting into coding or generic summarization.

These prompts are grounded in Octon’s stated core model: workflow state owns control flow, while agents participate only as bounded evidenced activity nodes.  The Charter also makes the key invariants explicit: generated and input surfaces are not authority, missing ownership/evidence/support fails closed, material side effects require explicit authority routing, host/model adapters are replaceable non-authoritative boundaries, and final disclosure must exclude unsupported or unadmitted surfaces. 

---

## Prompt 1 — Single-Control-Plane, Authority Precedence, and Human Authority Artifacts

```text
You are a senior AI-systems architect, governed-runtime reviewer, authority-boundary critic, and constitutional control-plane auditor.

Repository:
https://github.com/jamesryancooper/octon

Prompt title:
Single-Control-Plane, Authority Precedence, and Human Authority Artifact Review

Purpose:
Evaluate whether Octon preserves one governing control layer across constitutional authority, governance declarations, run-specific authority artifacts, mission authority, run contracts, lifecycle control, evidence, generated outputs, host surfaces, and human approvals/exceptions/revocations.

Why this deserves Octon Architect-level reasoning:
This review tests Octon’s most important invariant: there must be no second control plane. Octon has many surfaces that look authority-adjacent—constitutional docs, support targets, policies, approvals, exceptions, revocations, mission state, run contracts, runtime state, evidence, generated effective outputs, read models, host labels/comments/checks, and model-visible context. A weaker review may list those surfaces; this review must reason about precedence, hidden authority laundering, conflict handling, and whether human authority artifacts remain explicit, current, revocable, and file-native.

Inspect at minimum:
- README.md
- .octon/README.md
- .octon/framework/constitution/CHARTER.md
- .octon/framework/constitution/charter.yml
- .octon/framework/constitution/precedence/normative.yml
- .octon/framework/constitution/precedence/epistemic.yml
- .octon/framework/constitution/ownership/roles.yml
- .octon/framework/constitution/obligations/fail-closed.yml
- .octon/framework/constitution/obligations/evidence.yml
- .octon/framework/constitution/contracts/registry.yml
- .octon/framework/cognition/_meta/architecture/specification.md
- .octon/framework/cognition/_meta/architecture/contract-registry.yml
- .octon/instance/ingress/AGENTS.md
- .octon/instance/governance/ownership/registry.yml
- .octon/state/control/execution/approvals/**
- .octon/state/control/execution/exceptions/**
- .octon/state/control/execution/revocations/**
- .octon/state/control/execution/runs/**

Core invariants to preserve:
- Octon remains the governing control layer.
- No generated artifact, read model, provider session, assistant, raw model response, host UI state, label, comment, check, chat transcript, or model memory may mint authority.
- Human approvals, exceptions, revocations, break-glass directives, and one-way-door decisions must remain explicit, file-native, inspectable, current, bounded, and revocable where applicable.
- Execution remains deny-by-default on missing ownership, missing support, missing evidence, stale authority, unresolved conflict, or policy ambiguity.
- Evidence may prove facts but must not become permission.
- Runtime state may describe current execution truth but must not override higher authority.
- Architecture evaluation must remain separate from implementation planning.

Exact questions to answer:
1. What is the actual authority hierarchy in Octon, from external obligations and break-glass controls down through generated/read-model surfaces?
2. Does Octon cleanly distinguish normative authority from epistemic/factual grounding?
3. Where can validated evidence, generated-effective state, runtime observations, or read models describe facts without becoming authority?
4. Are approvals, exceptions, revocations, and break-glass controls represented as first-class authority artifacts, or can they be implied from host UI, comments, labels, checks, chat, or model output?
5. Can stale, duplicated, missing, revoked, or conflicting human authority artifacts cause ambiguous execution behavior?
6. Are run contracts and mission authority properly bounded beneath constitutional and governance authority?
7. Are host and model adapters consistently replaceable and non-authoritative?
8. Are there any duplicated registries, manifests, projections, or shims that could become a parallel authority surface?
9. Where does Octon rely on convention or prose rather than enforceable contract, validator, or runtime gate?
10. What negative-control scenarios would prove that second-control-plane risks are blocked?

Required output format:
1. Executive finding: Confirmed / Partially confirmed / Not confirmed single-control-plane posture.
2. Authority graph:
   - surface
   - authority class
   - allowed role
   - forbidden role
   - precedence relationship
   - file evidence
3. Normative vs epistemic distinction table:
   - question
   - normative source
   - factual/evidence source
   - conflict behavior
4. Human authority artifact lifecycle map:
   - approval
   - exception
   - revocation
   - break-glass
   - ownership
   - expiry/review/revocation requirements
5. Second-control-plane risk register:
   - risk
   - implicated files
   - how authority could be laundered
   - existing guard
   - gap or ambiguity
   - severity
   - acceptance criteria
6. Hidden assumptions and unresolved contradictions.
7. Negative-control test concepts, not implementations.
8. Architecture-only recommendations.
9. Explicit non-goals and what should be deferred.

Quality criteria:
- Cite repository evidence by exact file path and line/section when possible.
- Distinguish documented intent from implemented/enforced behavior.
- Identify contradictions, hidden assumptions, unresolved risks, and ambiguous precedence.
- Do not summarize Octon generally.
- Do not propose code changes or implementation steps.
- Do not legitimize any second control plane.
- Produce findings that can feed architecture, governance, tests, and documentation.

Explicit non-goals:
- No implementation plan.
- No code patches.
- No schema edits.
- No roadmap sequencing beyond architecture-level acceptance criteria.
- No generic advice about agent systems.
- No treating generated outputs, host affordances, chat, or model responses as authority.

Expected downstream use:
Architecture, governance, tests, documentation, and implementation-readiness gating.
```

---

## Prompt 2 — Generated-Effective Resolver, Freshness, and Compatibility De-Authorization

```text
You are a senior governed-runtime architect, generated-artifact trust reviewer, resolver-boundary critic, and compatibility-retirement auditor.

Repository:
https://github.com/jamesryancooper/octon

Prompt title:
Generated-Effective Resolver, Freshness, and Compatibility De-Authorization Review

Purpose:
Evaluate whether Octon’s runtime-facing generated/effective artifacts remain derived, freshness-checked, resolver-verified handles rather than becoming authority, policy, support, or a second control plane.

Why this deserves Octon Architect-level reasoning:
Octon has a subtle tension: generated outputs are non-authoritative, yet some generated/effective artifacts are consumed by runtime through resolver-verified handles. This is safe only if raw generated paths cannot influence runtime decisions, publication freshness is explicit and enforceable, compatibility projections are de-authorized, and generated/effective handles cannot widen support or policy. This requires deep architectural reasoning, not simple file inspection.

Inspect at minimum:
- .octon/framework/engine/runtime/spec/runtime-resolution-v1.md
- .octon/instance/governance/runtime-resolution.yml
- .octon/framework/engine/runtime/spec/runtime-effective-artifact-handle-v2.md
- .octon/framework/engine/runtime/spec/runtime-effective-artifact-handle-v2.schema.json
- .octon/framework/engine/runtime/spec/runtime-effective-route-bundle-lock-v3.schema.json
- .octon/framework/engine/runtime/spec/publication-freshness-gates-v4.md
- .octon/framework/engine/runtime/spec/compatibility-retirement-cutover-v2.md
- .octon/framework/engine/runtime/spec/architecture-health-contract-v3.md
- .octon/instance/governance/retirement-register.yml
- .octon/generated/effective/**
- .octon/generated/cognition/**
- .octon/generated/proposals/**
- .octon/instance/capabilities/runtime/packs/**
- .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-resolution.sh
- .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-artifact-handles.sh
- .octon/framework/assurance/runtime/_ops/scripts/validate-generated-effective-freshness.sh
- .octon/framework/assurance/runtime/_ops/scripts/validate-no-raw-generated-effective-runtime-reads.sh

Core invariants to preserve:
- Generated outputs never mint authority.
- Runtime-facing generated/effective artifacts may be consumed only through resolver-verified handles.
- Raw generated paths must not influence authorization, support claims, policy, promotion, closeout, or lifecycle truth.
- Freshness must be explicit, falsifiable, and fail-closed.
- Fake far-future freshness must not satisfy runtime trust.
- Compatibility projections must remain de-authorized, successor-bound, and forbidden to runtime/policy/support consumers unless explicitly allowed as compatibility-only.
- Architecture review remains separate from implementation planning.

Exact questions to answer:
1. Which generated/effective artifacts are runtime-facing?
2. Which generated/effective artifacts are operator/read-model-only?
3. Are all runtime-facing generated/effective artifacts consumed through resolver-verified handles?
4. Can any raw path under .octon/generated/** influence authorization, support, policy, runtime routing, promotion, publication, closeout, or lifecycle truth?
5. Are handle records sufficient: output ref, lock ref, source refs/digests, publication receipt, generation id, freshness mode, allowed consumers, forbidden consumers, invalidation conditions, and non-authority classification?
6. Are dependency handles recursively verified?
7. Are publication receipts current, digest-bound or receipt-bound as declared, and drift-detecting?
8. Are generated support matrices and support cards capable of narrowing but never widening support?
9. Are compatibility projections registered, successor-bound, forbidden-consumer-protected, and covered by negative controls?
10. Are older v1/v2/v3 contracts and compatibility aliases safely retained as lineage only?
11. Where is enforcement implemented versus merely documented?
12. What hidden assumptions could allow generated-effective artifacts to become a second control plane?

Required output format:
1. Executive finding on generated-effective trust posture.
2. Generated surface classification table:
   - path/surface
   - generated class
   - allowed consumers
   - forbidden consumers
   - authority posture
   - resolver/freshness gate
   - evidence file path
3. Runtime-facing handle graph:
   - parent handle
   - dependency handle
   - receipt/freshness mode
   - drift conditions
   - failure behavior
4. Direct-read risk table:
   - raw path
   - possible consumer
   - risk
   - existing validator/gate
   - gap
5. Compatibility retirement findings:
   - compatibility surface
   - canonical successor
   - current consumer risk
   - retirement or retain-as-compatibility-only criteria
6. Contradictions, hidden assumptions, and unresolved risks.
7. Negative-control concepts for raw generated reads, stale receipts, digest drift, forbidden consumers, and support widening.
8. Architecture-only acceptance criteria.
9. No implementation plan.

Quality criteria:
- Cite exact file paths and line/section evidence.
- Distinguish “documented non-authority” from “enforced non-authority.”
- Identify any place where generated/effective artifacts are required by runtime and explain why this is safe or unsafe.
- Treat compatibility projections as high-risk until proven de-authorized.
- Avoid generic advice and repo summarization.
- Do not propose patches.

Explicit non-goals:
- No code implementation.
- No validator implementation.
- No generated artifact regeneration.
- No migration plan unless requested later.
- No treating generated/effective outputs as authority.

Expected downstream use:
Architecture, governance, tests, documentation, compatibility retirement, and implementation-readiness gating.
```

---

## Prompt 3 — Material Side-Effect Authorization and Policy/ACP Enforcement

```text
You are a senior runtime-boundary auditor, policy/authorization reviewer, side-effect safety critic, and governed-execution architect.

Repository:
https://github.com/jamesryancooper/octon

Prompt title:
Material Side-Effect Authorization and Policy/ACP Enforcement Review

Purpose:
Determine whether every material side-effect path in Octon is routed through the engine-owned authorization boundary, policy/ACP enforcement, support-target and capability-pack routing, egress/budget checks, instruction-layer evidence, authorized-effect token issuance/verification/consumption, retained receipts, and Run Journal coverage.

Why this deserves Octon Architect-level reasoning:
This is Octon’s highest operational safety claim. It is not enough that specs say material effects require authorization. The review must reason across Rust code, shell scripts, CI workflows, policy launcher semantics, support targets, capability packs, egress, budgets, publication paths, closeout helpers, host projections, generated/effective updates, and negative controls. The main risk is mutation without valid authority or “stage_only” behaving like a soft allow.

Inspect at minimum:
- .octon/framework/engine/runtime/spec/execution-authorization-v1.md
- .octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md
- .octon/framework/engine/runtime/spec/material-side-effect-inventory.yml
- .octon/framework/engine/runtime/spec/policy-interface-v1.md
- .octon/framework/engine/runtime/spec/policy-receipt-v2.schema.json
- .octon/framework/engine/runtime/spec/policy-digest-v2.md
- .octon/framework/engine/runtime/spec/instruction-layer-manifest-v1.schema.json
- .octon/instance/governance/policies/network-egress.yml
- .octon/instance/governance/policies/execution-budgets.yml
- .octon/instance/governance/support-targets.yml
- .octon/instance/governance/capability-packs/registry.yml
- .octon/instance/governance/capability-packs/*.yml
- .octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs
- .octon/framework/engine/runtime/crates/authority_engine/src/implementation/effects.rs
- .octon/framework/engine/runtime/crates/kernel/src/commands/**
- .octon/framework/engine/runtime/crates/kernel/src/pipeline.rs
- .octon/framework/engine/runtime/crates/kernel/src/workflow.rs
- .octon/framework/engine/runtime/crates/kernel/src/stdio.rs
- .github/workflows/**
- .octon/framework/assurance/runtime/_ops/tests/*authorized*
- .octon/framework/assurance/runtime/_ops/tests/*material-side-effect*
- .octon/framework/assurance/runtime/_ops/tests/*protected-ci*
- .octon/framework/assurance/runtime/_ops/tests/*publication*

Core invariants to preserve:
- Material execution is deny-by-default.
- No material side effect may occur before valid authorization.
- GrantBundle alone is not a consumable side-effect capability.
- Material APIs must consume typed AuthorizedEffect<T> and verify into VerifiedEffect<T> before mutation.
- Policy, egress, budget, and support checks constrain execution but do not independently authorize execution.
- Unadmitted or unsupported capability packs fail closed.
- Stage-only is not allow.
- All material attempts emit retained receipts and journal coverage.
- Host labels/comments/checks are projections only.
- Architecture evaluation remains separate from implementation planning.

Exact questions to answer:
1. What material side-effect classes exist in Octon?
2. Is the material-side-effect inventory complete?
3. Which paths are live, stage-only, denied, or compatibility-only?
4. For each live material path, where is authorize_execution invoked?
5. For each live material path, where is AuthorizedEffect<T> verified into VerifiedEffect<T> before mutation?
6. Are policy/ACP receipts mandatory and retained?
7. Are instruction-layer manifests mandatory for material policy evaluations?
8. Does outbound HTTP imply api pack and browser-driving imply browser pack, and are unadmitted packs denied?
9. Can egress policy or budget policy be mistaken for execution authority?
10. Can missing cost evidence route to stage_only and then accidentally proceed?
11. Do shell scripts, closeout helpers, generated/effective publishers, workflow stages, host projections, protected CI, or GitHub automation mutate outside token enforcement?
12. Are token issuance, verification, consumption, rejection, expiry, revocation, and already-consumed cases journaled and receipted?
13. Are negative controls representative and actually tied to the same boundary?
14. Where is enforcement implemented versus only documented?

Required output format:
1. Executive finding on material side-effect safety.
2. Material path inventory reconciliation:
   - path_id
   - class
   - owner/entrypoint
   - material root
   - authorize_execution binding
   - AuthorizedEffect type
   - VerifiedEffect consumer
   - policy/ACP receipt
   - journal/receipt evidence
   - support/capability pack posture
   - coverage state
   - risk
3. Policy/authorization sequence diagram in text.
4. Bypass scenario table:
   - path
   - bypass mode
   - existing guard
   - missing proof
   - severity
5. Stage-only/escalate/deny behavior analysis.
6. Negative-control gap list.
7. Acceptance criteria for claiming complete material authorization coverage.
8. Explicit distinction between architecture findings and later implementation planning.
9. No implementation plan.

Quality criteria:
- Cite repository evidence by exact file path and line/section when possible.
- Distinguish documented intent from implemented/enforced behavior.
- Identify both declared and implicit material side-effect paths.
- Treat “policy allows” and “execution authorized” as separate states.
- Do not write code, propose patches, or create implementation tasks.
- Avoid generic advice.

Explicit non-goals:
- No implementation.
- No code patching.
- No writing tests or fixtures.
- No changing policy.
- No widening support.
- No treating stage-only as allow.

Expected downstream use:
Architecture, governance, tests, implementation-readiness, and later implementation planning only after acceptance criteria are approved.
```

---

## Prompt 4 — Run Lifecycle, Journal Truth, Evidence Closure, Replay, and Rollback

```text
You are a senior workflow-runtime architect, journal-integrity reviewer, replay/rollback critic, and evidence-closure auditor.

Repository:
https://github.com/jamesryancooper/octon

Prompt title:
Run Lifecycle, Journal Truth, Evidence Closure, Replay, and Rollback Review

Purpose:
Evaluate whether Octon’s Run Journal, runtime-state materialization, lifecycle state machine, retained evidence store, closeout gates, replay model, rollback posture, and disclosure requirements preserve one canonical execution truth and make consequential runs inspectable, replayable, recoverable, and auditable.

Why this deserves Octon Architect-level reasoning:
Octon’s trust model depends not only on preventing unauthorized mutation, but also on proving what happened afterward. The subtle risk is that mutable runtime state, compact evidence summaries, generated read models, local residue, closeout receipts, or evidence snapshots could substitute for the canonical journal or retained proof. This requires reasoning across state machine legality, append-only integrity, closeout sufficiency, replay reconstruction, rollback posture, disclosure, and evidence tiers.

Inspect at minimum:
- .octon/framework/engine/runtime/spec/run-lifecycle-v1.md
- .octon/framework/engine/runtime/spec/run-journal-v1.md
- .octon/framework/engine/runtime/spec/evidence-store-v1.md
- .octon/framework/constitution/obligations/evidence.yml
- .octon/framework/constitution/contracts/runtime/run-event-v2.schema.json
- .octon/framework/constitution/contracts/runtime/runtime-state-v2.schema.json
- .octon/framework/constitution/contracts/runtime/state-reconstruction-v2.md
- .octon/framework/constitution/contracts/disclosure/run-card-v2.schema.json
- .octon/framework/constitution/contracts/retention/**
- .octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs
- .octon/framework/engine/runtime/crates/authority_engine/src/implementation/runtime_state.rs
- .octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-v1.sh
- .octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-transition-coverage.sh
- .octon/framework/assurance/runtime/_ops/fixtures/run-lifecycle-v1/**
- representative run evidence under .octon/state/evidence/runs/** when available

Core invariants to preserve:
- The Run Journal is the canonical execution history.
- runtime-state.yml is a derived mutable view, not source authority over the journal.
- runtime_bus must be the only canonical append path.
- Generated/operator read models must never be lifecycle truth.
- Control refs and retained evidence refs must remain distinct.
- Closeout requires evidence completeness, rollback posture, disclosure, review/risk disposition, and hash-matching journal snapshots.
- Replay reconstructs from canonical journal and retained evidence, not summaries.
- Rollback/compensation must be evidenced and bounded.
- Architecture evaluation remains separate from implementation planning.

Exact questions to answer:
1. Is runtime_bus actually the only append path for events.ndjson and events.manifest.yml?
2. Are there scripts, closeout helpers, migrations, repair paths, validators, or runtime components that mutate journal-adjacent state outside the append boundary?
3. Are lifecycle states necessary, sufficient, and non-overlapping?
4. Can denied, staged, revoked, failed, paused, succeeded, or rolled_back states accidentally advance work?
5. Can runtime-state.yml drift be accepted as current truth?
6. Is closeout impossible without required durable control/evidence/disclosure/rollback/review/risk artifacts?
7. Are evidence snapshots mirrors of the control journal, not repair sources?
8. Can replay reconstruct from canonical journal and retained evidence without generated projections or compact summaries?
9. Are compact evidence views, structured closeout views, and raw-log summaries safe aids rather than substitutes?
10. Are redactions lineage-preserving and audit-linked?
11. Are missing evidence, stale snapshots, local-only residue, and generated read models fail-closed for closure?
12. Where does documentation exceed enforcement?

Required output format:
1. Executive finding on lifecycle truth and evidence closure.
2. State-machine critique:
   - state
   - entry requirements
   - allowed exits
   - risk of overlap or accidental progress
   - evidence requirement
3. Journal integrity map:
   - canonical files
   - writer path
   - mutation risks
   - validators
   - gaps
4. Control/evidence/disclosure boundary table.
5. Closeout gate checklist:
   - required artifact
   - source root
   - proof role
   - failure behavior
6. Replay reconstruction checklist.
7. Rollback/compensation gap analysis.
8. Adversarial scenarios:
   - scenario
   - expected invariant
   - caught today?
   - evidence
   - unresolved risk
9. Architecture-only acceptance criteria.
10. No implementation plan.

Quality criteria:
- Cite repository evidence by exact path and line/section when possible.
- Distinguish documented lifecycle intent from code-enforced behavior.
- Include adversarial closeout and replay scenarios.
- Identify when evidence is retained proof versus mutable control truth versus disclosure versus generated read model.
- Do not propose implementation unless specifically requested later.
- Avoid generic workflow advice.

Explicit non-goals:
- No code patches.
- No fixture generation.
- No closeout execution.
- No rollback execution.
- No implementation plan.
- No treating evidence snapshots or generated read models as lifecycle authority.

Expected downstream use:
Architecture, governance, tests, disclosure, audit readiness, and implementation-readiness gating.
```

---

## Prompt 5 — Support Claim Envelope and Proof Executability

```text
You are a senior support-governance reviewer, proof-sufficiency critic, assurance architect, and bounded-support auditor.

Repository:
https://github.com/jamesryancooper/octon

Prompt title:
Support Claim Envelope and Proof Executability Review

Purpose:
Evaluate whether Octon’s admitted-live support claims are finite, explicit, proof-backed, executable or replayable, disclosure-covered, negative-control-tested, and impossible to widen through generated matrices, support cards, docs, adapter declarations, capability-pack routes, or stage-only surfaces.

Why this deserves Octon Architect-level reasoning:
Octon’s product and governance posture depends on bounded admitted support, not universal agent autonomy. The risk is not just “missing tests”; it is support laundering—where stage-only, unadmitted, generated, adapter-declared, compatibility, or future-facing surfaces are read as live support. A strong model should reason across admissions, dossiers, proof bundles, representative runs, negative controls, adapter criteria, capability packs, generated support matrices, and disclosure.

Inspect at minimum:
- .octon/instance/governance/support-targets.yml
- .octon/instance/governance/support-target-admissions/**
- .octon/instance/governance/support-dossiers/**
- .octon/instance/governance/contracts/support-target-review.yml
- .octon/instance/governance/contracts/support-target-proofing.yml
- .octon/instance/governance/contracts/support-dossier-evidence-depth.yml
- .octon/state/evidence/validation/support-targets/**
- .octon/generated/effective/governance/support-target-matrix.yml
- .octon/generated/cognition/projections/materialized/support-cards/**
- .octon/instance/governance/capability-packs/registry.yml
- .octon/instance/governance/capability-packs/*.yml
- .octon/framework/constitution/contracts/assurance/support-target-proof-bundle-v1.schema.json
- .octon/framework/assurance/runtime/_ops/scripts/validate-proof-bundle-executability.sh
- .octon/framework/engine/runtime/spec/architecture-health-contract-v3.md

Core invariants to preserve:
- Live support remains bounded, admitted, finite, explicit, and proof-backed.
- Stage-only, unadmitted, unsupported, retired, and deny-only surfaces remain non-live.
- Generated support matrices and support cards may narrow or describe but never widen support.
- Adapter declarations may narrow but never widen authority or support.
- Browser/API/frontier/studio/boundary-sensitive surfaces remain non-live unless explicitly admitted and proven.
- Metadata-only or summary-only proof is insufficient for admitted-live claims.
- Support expansion requires governance approval, evidence, disclosure, and recertification where applicable.
- Architecture evaluation remains separate from implementation planning.

Exact questions to answer:
1. What exactly is admitted live today?
2. Which tuples/surfaces are stage-only, unadmitted, unsupported, retired, or deny-only?
3. For each admitted-live tuple, what proof bundle exists?
4. Is the proof bundle executable or replayable?
5. Does each admitted-live tuple have representative retained run evidence, negative controls, proof-plane coverage, disclosure coverage, and current freshness?
6. Do adapter declarations imply broader support than tuple admissions?
7. Do capability-pack manifests imply broader support than support targets admit?
8. Can generated support-target matrix, support cards, or disclosure artifacts widen live claims?
9. Are proof freshness and review cadence enforceable?
10. Are unsupported action classes represented as exclusions rather than faux support tiers?
11. What support claims are product-facing but not yet proof-backed?
12. What gates must pass before support expansion?

Required output format:
1. Executive finding on support envelope integrity.
2. Live support table:
   - tuple_id
   - workload/model/context/locale/host/model adapter
   - claim effect
   - admission ref
   - dossier ref
   - proof bundle ref
   - proof executability status
   - representative run refs
   - negative-control refs
   - disclosure refs
   - freshness/review status
   - risk
3. Non-live surface table:
   - surface
   - posture
   - why non-live
   - leakage risk
4. Support-widening risk register:
   - source of widening
   - existing guard
   - gap
   - severity
   - acceptance criteria
5. Adapter and capability-pack mismatch analysis.
6. Proof-executability gap list.
7. Support expansion gate checklist.
8. Architecture-only recommendations.
9. No implementation plan.

Quality criteria:
- Cite repository evidence by exact path and line/section when possible.
- Distinguish declared support from proved support.
- Reject summary-only proof where executable/replayable proof is required.
- Identify support laundering through generated, adapter, compatibility, or documentation surfaces.
- Avoid generic assurance advice.
- Do not propose implementation.

Explicit non-goals:
- No support widening.
- No proof bundle creation.
- No generated support matrix update.
- No coding or validator work.
- No roadmap unless requested after architecture findings.

Expected downstream use:
Governance, support certification, tests, disclosure, roadmap, and implementation-readiness gating.
```

---

## Prompt 6 — Context, Memory, and Model-Visible Integrity

```text
You are a senior AI context-governance architect, memory-boundary reviewer, model-visible integrity critic, and contamination-risk analyst.

Repository:
https://github.com/jamesryancooper/octon

Prompt title:
Context, Memory, and Model-Visible Integrity Review

Purpose:
Evaluate whether Octon’s context packs, model-visible context, context receipts, omissions, redactions, compaction, semantic caches, continuity sources, generated summaries, and execution-role memory rules preserve the boundary between evidence/context and authority/control/memory.

Why this deserves Octon Architect-level reasoning:
Context is where agent systems most often launder authority. Octon must allow models to see useful context without letting that context become durable memory, policy, approval, support, execution authority, or evidence replacement. This review requires reasoning about source classification, model-visible bytes, retained hashes, freshness, invalidation, omissions, redactions, semantic cache reuse, proposal-local inputs, generated views, and authorization binding.

Inspect at minimum:
- .octon/framework/execution-roles/governance/MEMORY.md
- .octon/framework/execution-roles/runtime/orchestrator/ROLE.md
- .octon/framework/engine/runtime/spec/context-pack-builder-v1.md
- .octon/framework/engine/runtime/spec/context-pack-receipt-v1.schema.json
- .octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json
- .octon/instance/governance/policies/context-packing.yml
- .octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs
- .octon/framework/assurance/runtime/_ops/scripts/validate-context-pack-builder.sh
- .octon/framework/assurance/runtime/_ops/tests/test-context-pack-builder.sh
- .octon/state/evidence/runs/**/context/** when representative examples exist
- .octon/generated/cognition/**
- .octon/inputs/**

Core invariants to preserve:
- No execution role owns canonical memory.
- Context packs are evidence, not authority.
- Model-visible context cannot approve, authorize, override, publish, widen support, or satisfy evidence obligations by itself.
- Raw inputs, generated outputs, proposal-local files, host UI state, labels, comments, checks, chat transcripts, provider sessions, and model responses remain non-authoritative.
- Context freshness, source digests, policy digests, omissions, redactions, and invalidation must be explicit and replayable.
- Invalid supplied context binding must fail closed, not be silently laundered.
- Architecture evaluation remains separate from implementation planning.

Exact questions to answer:
1. Can context-pack evidence become hidden canonical memory?
2. Are source classes explicit and preserved from candidate discovery through model-visible serialization and receipts?
3. Are generated, raw, proposal-local, host, chat, and provider-originated sources always labeled non-authoritative when included?
4. Can a context pack or receipt satisfy authorization without valid retained source refs, source digests, model-visible hash, policy ref, and freshness state?
5. Can invalid supplied context be silently rebuilt or laundered into valid evidence?
6. Are omissions and redactions deterministic, replayable, and audit-preserving?
7. Are compact context, semantic cache, and context-layer reuse safe aids rather than substitutes for retained evidence or authority?
8. Are context freshness rules coherent with Octon’s broader generated/effective freshness rules?
9. Is any far-future valid_until pattern safe because of digest/invalidation binding, or does it create fake freshness risk?
10. Can continuity artifacts, generated summaries, or operator digests become implicit memory?
11. What adversarial model-visible context examples could trick an agent into treating non-authority as authority?
12. Where is enforcement implemented versus documented?

Required output format:
1. Executive finding on context/memory boundary integrity.
2. Source-class map:
   - source class
   - allowed use
   - forbidden use
   - model-visible posture
   - authority label
   - evidence path
3. Context-pack lifecycle analysis:
   - request
   - candidate discovery
   - classification
   - model-visible serialization
   - receipt
   - authorization binding
   - invalidation/rebuild/compaction
4. Context laundering risk register.
5. Freshness and invalidation risk analysis.
6. Adversarial model-visible examples and expected denial/labeling behavior.
7. Omissions/redactions/replay checklist.
8. Architecture-only acceptance criteria.
9. No implementation plan.

Quality criteria:
- Cite exact repository files and sections.
- Distinguish documented context policy from enforced runtime validation.
- Identify hidden-memory and authority-laundering scenarios.
- Include concrete adversarial examples.
- Avoid generic advice about prompts or memory.
- Do not propose implementation.

Explicit non-goals:
- No code changes.
- No context-pack generation.
- No policy editing.
- No prompt rewriting except adversarial examples.
- No treating model-visible context as authority.

Expected downstream use:
Architecture, governance, tests, documentation, and implementation-readiness gating.
```

---

## Prompt 7 — Mission-Scoped Autonomy, Stewardship, and Self-Evolution Feedback Loops

```text
You are a senior autonomy-governance architect, mission-runtime reviewer, self-evolution critic, and feedback-loop risk analyst.

Repository:
https://github.com/jamesryancooper/octon

Prompt title:
Mission-Scoped Autonomy, Stewardship, and Self-Evolution Feedback-Loop Review

Purpose:
Evaluate whether Octon’s mission autonomy, continuous stewardship, queues, continuation decisions, self-evolution, proposal-to-promotion flow, recertification, rollback, and safing/circuit-breaker mechanisms preserve mission-scoped, reversible, bounded autonomy without self-approval, unbounded scheduling, or a second control plane.

Why this deserves Octon Architect-level reasoning:
Long-horizon autonomy and self-evolution are where a governed runtime can accidentally become self-authorizing. Octon needs availability over time without unbounded work, and self-improvement without models, generated summaries, proposal packets, lab success, simulations, or evidence distillation becoming authority. This requires deep reasoning about feedback loops, renewal, proceed-on-silence, circuit breakers, safing, quorum, mission ownership, run handoff, promotion gates, and recertification.

Inspect at minimum:
- .octon/instance/governance/policies/mission-autonomy.yml
- .octon/framework/engine/runtime/spec/continuous-stewardship-runtime-v3.md
- .octon/framework/engine/runtime/README.md
- .octon/framework/engine/runtime/spec/mission-plan-v1.md
- .octon/framework/engine/runtime/spec/engagement-change-package-compiler-v1.md
- .octon/instance/orchestration/missions/**
- .octon/state/control/execution/missions/**
- .octon/state/continuity/repo/missions/**
- .octon/generated/cognition/projections/materialized/missions/**
- .octon/instance/cognition/decisions/102-self-evolution-proposal-to-promotion-runtime.md
- .octon/framework/engine/runtime/spec/evolution-program-v1.schema.json
- .octon/framework/engine/runtime/spec/promotion-runtime-v1.md
- .octon/framework/engine/runtime/spec/recertification-runtime-v1.md
- .octon/state/control/evolution/**
- .octon/state/evidence/evolution/**
- .octon/instance/governance/evolution/**

Core invariants to preserve:
- Autonomy remains mission-scoped, reversible or compensable where applicable, bounded, interruptible, and auditable.
- Stewardship may observe and admit but must not execute material work directly.
- Mission planning, queues, continuation decisions, and generated mission views do not authorize execution.
- Material work still enters run contracts, authorization, effect-token verification, journal evidence, and closeout.
- Self-evolution cannot self-approve, self-promote, self-recertify, or self-authorize material changes.
- Proposal packets, simulations, lab success, evidence distillation, generated summaries, chat, and model output are not authority.
- Deny-by-default applies to missing mission context, missing proposal refs where required, exhausted autonomy burn, circuit breaker trips, and unsupported/destructive action classes.
- Architecture evaluation remains separate from implementation planning.

Exact questions to answer:
1. Can stewardship remain available indefinitely without creating unbounded work?
2. Does every path from stewardship trigger to material work pass through mission handoff, action slice, run contract, authorization, journal evidence, and closeout?
3. Can mission queues, continuation decisions, mission plans, generated mission projections, or operator digests become execution authority?
4. Are proceed-on-silence paths limited to reversible or compensable work and blocked for forbidden action classes?
5. Do autonomy burn states, circuit breakers, safing defaults, pause-on-failure triggers, and quorum rules actually constrain autonomy?
6. Can repeated renewal, retry, or queue admission create hidden indefinite scheduling?
7. Can self-evolution propose, approve, promote, recertify, or rollback itself?
8. Can lab success, simulation success, evidence distillation, generated summaries, or proposal packets become implicit approval?
9. Are promotion, rollback, retirement, and recertification evidence mandatory and bounded?
10. Are human/quorum boundaries explicit and file-native?
11. What feedback loops could widen authority over time?
12. Where does the documentation exceed enforcement?

Required output format:
1. Executive finding on bounded autonomy and self-evolution safety.
2. Autonomy flow map:
   - stewardship program
   - epoch
   - trigger
   - admission
   - mission handoff
   - mission queue
   - action slice
   - run contract
   - governed run
3. Mission authority boundary table:
   - surface
   - allowed role
   - forbidden role
   - authority posture
4. Self-evolution lifecycle map:
   - candidate
   - simulation
   - lab/proof
   - proposal packet
   - decision/amendment
   - promotion
   - recertification
   - rollback/retirement
5. Feedback-loop risk register.
6. Safing/circuit-breaker/quorum critique.
7. Self-approval impossibility analysis.
8. Acceptance criteria for future autonomy expansion.
9. No implementation plan.

Quality criteria:
- Cite repository evidence by exact file path and section.
- Identify feedback loops, not just static policy rules.
- Distinguish mission continuity from run authority.
- Distinguish evidence/proof from approval/promotion authority.
- Do not propose coding or implementation steps.
- Avoid generic autonomy advice.

Explicit non-goals:
- No implementation plan.
- No self-evolution proposal creation.
- No promotion or recertification.
- No mission execution.
- No roadmap unless requested later.

Expected downstream use:
Architecture, governance, roadmap, tests, and implementation-readiness gating.
```

---

## Prompt 8 — Connector, Browser, API, Plugin, and External Operation Admission

```text
You are a senior connector-admission architect, external-tool governance reviewer, plugin-runtime critic, and material-operation safety auditor.

Repository:
https://github.com/jamesryancooper/octon

Prompt title:
Connector, Browser, API, Plugin, and External Operation Admission Review

Purpose:
Evaluate whether Octon’s connector, browser, API, plugin, MCP, and external operation surfaces remain governed, non-authoritative, deny-by-default, and unable to execute material operations unless routed through support admission, run contracts, context packing, authorization, effect-token verification, journal evidence, connector receipts, replay, rollback, and disclosure.

Why this deserves Octon Architect-level reasoning:
Connectors and external tools are the most likely path from repo-local governed execution into uncontrolled agent behavior. A connector can look like a capability, a trust surface, an external authority, and an execution channel at the same time. This review must reason about connector identity, operation contracts, admissions, trust dossiers, capability maps, support posture, API/browser packs, quarantine, receipts, and material operation boundaries.

Inspect at minimum:
- .octon/framework/engine/runtime/README.md
- .octon/framework/engine/runtime/spec/connector-admission-v1.schema.json
- .octon/framework/engine/runtime/spec/connector-execution-receipt-v1.schema.json
- .octon/instance/governance/connectors/**
- .octon/instance/governance/connector-admissions/**
- .octon/state/control/connectors/**
- .octon/state/evidence/connectors/**
- .octon/generated/cognition/projections/materialized/connectors/**
- .octon/instance/governance/capability-packs/browser.yml
- .octon/instance/governance/capability-packs/api.yml
- .octon/framework/capabilities/packs/browser/**
- .octon/framework/capabilities/packs/api/**
- .octon/framework/engine/runtime/spec/material-side-effect-inventory.yml
- .octon/framework/assurance/runtime/_ops/tests/test-connector-admission-runtime-v4.sh
- connector-related validators under .octon/framework/assurance/runtime/_ops/scripts/**

Core invariants to preserve:
- Connector availability is not authority.
- Connector admission does not itself authorize material execution.
- Browser/API/plugin/MCP/external operation paths are deny-by-default unless admitted, supported, authorized, and evidenced.
- Connector proof does not replace run evidence.
- Material connector operations must enter the local governed run lifecycle.
- API/browser packs remain unadmitted unless explicitly admitted with proof.
- Generated connector views are operator read models only.
- Quarantine and revocation block admission or operation as applicable.
- Architecture evaluation remains separate from implementation planning.

Exact questions to answer:
1. What is the current connector posture: observe-only, read-only, stage-only, live admission, or material operation?
2. Does any connector admission state imply execution authority?
3. Are terms like “live” or “admit” potentially misleading if material operation remains deferred?
4. Are connector identity, operation contracts, trust dossiers, capability maps, and support posture clearly separated?
5. Are browser and API capability packs correctly unadmitted and escalate/deny-by-default?
6. What proof is required before browser/API/plugin/external operations can become admitted?
7. Can MCP/server availability, tool availability, provider metadata, or connector status become authority?
8. Are connector receipts sufficient for connector evidence without substituting for run evidence?
9. Are connector quarantine, drift, revocation, and recertification boundaries enforceable?
10. Are external operations inventoried as material side-effect paths?
11. What deny-until conditions must remain in place before any live external operation?

Required output format:
1. Executive finding on connector/external operation safety.
2. Connector surface map:
   - surface
   - role
   - authority posture
   - allowed operation
   - forbidden operation
   - evidence root
3. Admission vs execution distinction table.
4. Browser/API/plugin capability-pack gate analysis.
5. Material external operation risk register:
   - operation class
   - possible externality
   - required support proof
   - required authorization path
   - missing gate
6. Misleading naming/state risks.
7. Deny-until matrix.
8. Acceptance criteria for future connector/browser/API admission.
9. No implementation plan.

Quality criteria:
- Cite exact file paths and sections.
- Distinguish connector governance preparation from material connector execution.
- Treat all external effects as denied until proven admitted and authorized.
- Identify terminology that could confuse operators or models.
- Do not propose implementation.
- Avoid generic plugin advice.

Explicit non-goals:
- No connector implementation.
- No browser/API admission.
- No MCP integration plan.
- No capability-pack activation.
- No code or test creation.
- No treating connector proof as run evidence.

Expected downstream use:
Architecture, governance, roadmap, support admission, tests, and implementation-readiness gating.
```

---

## Prompt 9 — External Trust, Portability, Adoption, Federation, and Imported Proof

```text
You are a senior trust-boundary architect, portability reviewer, federation-risk critic, and imported-proof governance auditor.

Repository:
https://github.com/jamesryancooper/octon

Prompt title:
External Trust, Portability, Adoption, Federation, and Imported Proof Review

Purpose:
Evaluate whether Octon’s external project adoption, portability, trust compatibility, attestations, portable proof bundles, federation compacts, delegated leases, external evidence, and imported proof remain local-evidence and coordination surfaces rather than authority, support widening, local execution authorization, or a second control plane.

Why this deserves Octon Architect-level reasoning:
External trust surfaces are future-facing but architecturally dangerous. Imported proof, federation compacts, delegated leases, trust domains, and adoption workflows can easily become hidden authority or support laundering. Octon must remain locally governed: local instance authority, local support admission, local run contracts, local authorization, local evidence, and local disclosure must remain required.

Inspect at minimum:
- .octon/instance/governance/trust/compatibility-profile.yml
- .octon/instance/governance/trust/policies/external-project-adoption.yml
- .octon/state/control/trust/compatibility/status.yml
- .octon/state/evidence/trust/**
- .octon/framework/constitution/obligations/fail-closed.yml
- .octon/framework/constitution/obligations/evidence.yml
- .octon/framework/constitution/contracts/retention/**
- .octon/framework/engine/runtime/spec/octon-compatibility-profile-v1.schema.json
- trust/federation/attestation/proof-bundle schemas under .octon/framework/**
- any federation compact, delegated lease, attestation envelope, portable proof bundle, trust domain, certification, recertification, revocation, expiry, dispute, or acceptance decision surfaces

Core invariants to preserve:
- External artifacts do not authorize local execution.
- Imported proof remains retained evidence or locally accepted proof, not authority.
- Federation compacts coordinate trust but do not override local authority.
- Delegated leases are local authorization inputs only and cannot bypass run contracts or execution authorization.
- Blind full .octon copies are forbidden.
- Repo-specific instance authority is required.
- State and generated outputs from another project cannot become current local truth or source authority.
- Local support-target admission remains required for local support claims.
- Material execution still enters the local run lifecycle.
- Architecture evaluation remains separate from implementation planning.

Exact questions to answer:
1. What external trust participation tiers exist?
2. What is each tier allowed to do and forbidden to do?
3. Can imported attestations, portable proof bundles, external evidence, or connector receipts satisfy evidence requirements without becoming authority?
4. Can imported proof widen local support claims?
5. Can federation compact membership become a second control plane?
6. Can delegated authority leases bypass local approval, run contracts, or execution authorization?
7. Does portability/adoption prevent blind copying of instance, state, generated outputs, or stale authority?
8. Are local acceptance, revocation, expiry, freshness, issuer, digest, scope, and redaction checks explicit?
9. Are non-Octon systems prevented from becoming federation peers?
10. Are external evidence sources clearly evidence-only?
11. Are failure states deny-by-default and auditable?
12. What hidden assumptions must be resolved before federation or portable proof becomes product-critical?

Required output format:
1. Executive finding on external trust boundary integrity.
2. Trust tier matrix:
   - profile/tier
   - required artifacts
   - allowed operations
   - forbidden operations
   - authority posture
   - local acceptance requirements
   - revocation behavior
3. Adoption threat model:
   - blind copy
   - stale octon
   - partial octon
   - generated-as-truth
   - state-as-current-truth
   - instance-as-imported-authority
4. Imported proof boundary analysis.
5. Federation/delegated lease risk register.
6. Local acceptance and revocation gate checklist.
7. Acceptance criteria for future external trust expansion.
8. No implementation plan.

Quality criteria:
- Cite exact repository files and sections.
- Distinguish external proof, local evidence, local acceptance, local authority, and execution authorization.
- Identify support-widening and second-control-plane risks.
- Treat federation as dangerous until local governance boundaries are proven.
- Do not propose implementation.

Explicit non-goals:
- No federation design implementation.
- No trust schema changes.
- No imported proof acceptance.
- No adoption migration plan.
- No authority delegation.
- No roadmap unless requested later.

Expected downstream use:
Architecture, governance, roadmap, external trust planning, and implementation-readiness gating.
```

---

## Prompt 10 — Change Closeout, Branch Landing/Cleanup, and Hosted-Control Surfaces

```text
You are a senior governed-workflow reviewer, Git/GitHub authority-boundary critic, closeout-governance auditor, and hosted-control-surface safety analyst.

Repository:
https://github.com/jamesryancooper/octon

Prompt title:
Change Closeout, Branch Landing/Cleanup, and Hosted-Control Surface Review

Purpose:
Evaluate whether Octon’s Change closeout, dirty-worktree wrapper, branch landing, branch cleanup, PR/no-PR routes, repo hygiene, local/private evidence, publishable evidence, generated publication, terminal proof, and hosted GitHub control surfaces preserve authority boundaries, material-effect authorization, evidence closure, rollback, and auditability.

Why this deserves Octon Architect-level reasoning:
Closeout is authority-adjacent and operationally dangerous. It can involve staging, committing, pushing, hosted preflight, landing main, branch cleanup, generated publication, evidence cleanup, terminal proof, and claim closure. The risk is that “cleaned,” “closeout,” “repo hygiene,” or hosted UI state becomes a broad mutation authority or that local/private evidence is mistaken for publishable proof.

Inspect at minimum:
- .octon/framework/product/contracts/default-work-unit.yml
- .octon/framework/product/contracts/default-work-unit.md
- .octon/framework/product/contracts/change-closeout-state-machine.yml
- .octon/framework/product/contracts/change-closeout-state-machine.md
- .octon/framework/product/contracts/change-receipt-v1.schema.json
- .octon/framework/product/contracts/branch-landing-authorization-v1.schema.json
- .octon/framework/product/contracts/branch-cleanup-authorization-v1.schema.json
- .octon/framework/orchestration/runtime/workflows/meta/closeout/**
- .octon/framework/capabilities/runtime/skills/remediation/closeout-change/**
- .octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/**
- .octon/framework/capabilities/runtime/skills/remediation/closeout-pr/**
- .octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml
- .octon/framework/execution-roles/_ops/scripts/git/**
- .octon/instance/governance/policies/repo-hygiene.yml
- .octon/instance/governance/contracts/closeout-reviews.yml
- closeout/repo-hygiene validators and tests under .octon/framework/assurance/runtime/_ops/**

Core invariants to preserve:
- Default work unit remains singular Change; wrappers do not become replacement authority.
- Closeout-worktree may partition, delegate, and report but must not become broad mutation authority.
- Branch landing and branch cleanup require explicit governed authorization.
- Hosted labels, checks, comments, branch status, and UI state are projections only.
- Local/private raw evidence is not publishable closeout proof unless represented through approved digest-backed receipts.
- Generated publication and cleanup remain owned by their proper routes.
- “Cleaned” claims must be evidence-backed and downgraded when proof is missing.
- Material Git/GitHub operations remain authorized, receipted, rollback-aware, and auditable.
- Architecture evaluation remains separate from implementation planning.

Exact questions to answer:
1. Does the default work-unit model preserve Change as the unit of closeout authority?
2. Can closeout-worktree overreach by directly mutating instead of partitioning/delegating/reporting?
3. Are branch-no-PR, branch-PR, hosted landing, cleanup, and direct-main routes clearly distinguished?
4. Are branch landing and branch cleanup separately authorized?
5. Can “cleaned” become an overbroad terminal claim?
6. Are local-private evidence, publishable evidence, terminal proof, closeout receipts, and hosted proof separated?
7. Can generated publication or repo-hygiene cleanup replace route-owned evidence?
8. Are host checks/GitHub state only projections unless bound to canonical evidence?
9. Can recursive closeout/delegation become unbounded autonomy?
10. Are rollback posture, validation evidence, branch identity, and receipt refs sufficient before hosted mutation?
11. Are stop conditions explicit for ambiguous residue, protected branches, missing validation, stale authorization, provider denial, or unresolved ownership?
12. Where does closeout policy exceed runtime enforcement?

Required output format:
1. Executive finding on closeout authority safety.
2. Closeout route matrix:
   - route
   - selected when
   - allowed actions
   - forbidden actions
   - required evidence
   - authority artifacts
   - rollback/disclosure posture
3. Branch landing/cleanup authority map.
4. Evidence boundary table:
   - local-private raw evidence
   - publishable closeout evidence
   - terminal proof
   - generated publication evidence
   - repo-hygiene residue
5. Hosted-control-surface risk register.
6. Cleaned-claim downgrade/stop-condition analysis.
7. Negative-control concepts.
8. Architecture-only acceptance criteria.
9. No implementation plan.

Quality criteria:
- Cite exact repository files and sections.
- Distinguish route policy, runtime enforcement, host projection, evidence, and authority.
- Identify mutation paths and required authorization artifacts.
- Do not propose implementation or run closeout.
- Avoid generic Git workflow advice.

Explicit non-goals:
- No closeout execution.
- No branch landing or cleanup.
- No code patches.
- No GitHub operation.
- No implementation plan.
- No widening closeout autonomy.

Expected downstream use:
Architecture, governance, tests, documentation, closeout readiness, and implementation-readiness gating.
```

---

## Prompt 11 — Architecture-Health and Validator-Depth Review

```text
You are a senior assurance architect, validator-depth reviewer, proof-quality critic, and closure-grade architecture auditor.

Repository:
https://github.com/jamesryancooper/octon

Prompt title:
Architecture-Health and Validator-Depth Review

Purpose:
Evaluate whether Octon’s validators, architecture-health aggregation, retained validation evidence, negative controls, proof bundles, runtime tests, publication receipts, and closure-grade certificates actually prove the depth they claim rather than merely checking existence, schema shape, or documentation alignment.

Why this deserves Octon Architect-level reasoning:
Octon defines depth classes from existence to closure-grade. The risk is claim inflation: a validator may claim runtime/proof/closure-grade depth while only checking file presence or schema shape. A strong review must reason about whether validators prove semantic correctness, runtime enforcement, negative controls, proof executability, publication freshness, authorization coverage, and support sufficiency.

Inspect at minimum:
- .octon/framework/engine/runtime/spec/architecture-health-contract-v3.md
- .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-health.sh
- .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-resolution.sh
- .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-artifact-handles.sh
- .octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh
- .octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh
- .octon/framework/assurance/runtime/_ops/scripts/validate-proof-bundle-executability.sh
- .octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-v1.sh
- .octon/framework/assurance/runtime/_ops/scripts/validate-context-pack-builder.sh
- .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
- .octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh
- .octon/framework/assurance/runtime/_ops/tests/**
- .octon/framework/assurance/runtime/_ops/fixtures/**
- .octon/state/evidence/validation/architecture/**
- .octon/state/evidence/validation/support-targets/**
- .octon/state/evidence/validation/publication/**

Core invariants to preserve:
- Validator output must not become authority.
- Architecture-health aggregation may orchestrate narrower validators but must not mint a second authority surface.
- Claimed depth must not exceed achieved depth.
- Closure-grade claims require actual semantic/runtime/proof coverage.
- Negative controls must be real and representative where claimed.
- Support proof must be executable or replayable where required.
- Generated/read-model validators must preserve non-authority posture.
- Architecture evaluation remains separate from implementation planning.

Exact questions to answer:
1. What validators contribute to architecture-health or closure-grade claims?
2. For each validator, what depth is claimed and what depth is actually achieved: existence, schema, semantic, runtime, proof, or closure-grade?
3. Which validators execute runtime behavior versus inspect files?
4. Which validators execute negative controls versus reference them?
5. Which proof bundles are executable or replayable?
6. Are publication receipts, generated-effective freshness, authorization coverage, support proof, operator read models, and compatibility retirement validated at the required depth?
7. Can a validator pass while the underlying runtime boundary is unenforced?
8. Are limitations retained and surfaced?
9. Does the aggregate health certificate avoid becoming authority?
10. Where are proof claims overstated?

Required output format:
1. Executive finding on validator-depth credibility.
2. Validator depth table:
   - validator
   - claimed dimension
   - claimed depth
   - achieved depth
   - evidence refs
   - runtime tests executed
   - negative controls executed
   - limitations
   - overclaim risk
3. Required architecture-health dimension coverage matrix.
4. Proof-executability findings.
5. Negative-control sufficiency analysis.
6. Overstated claim register.
7. Acceptance criteria for closure-grade claims.
8. No implementation plan.

Quality criteria:
- Cite exact scripts, tests, fixtures, and evidence files.
- Classify achieved depth conservatively.
- Distinguish schema/existence checks from semantic/runtime/proof checks.
- Identify missing or weak negative controls.
- Do not propose implementation or write validators.
- Avoid generic QA advice.

Explicit non-goals:
- No validator coding.
- No fixture generation.
- No closure certificate creation.
- No architecture-health promotion.
- No implementation plan.

Expected downstream use:
Tests, governance, release readiness, documentation, and implementation-readiness gating.
```

---

## Prompt 12 — Product Claim, Disclosure, and Operator Read-Model Claim Discipline

```text
You are a senior product-architecture reviewer, disclosure-governance auditor, operator-read-model critic, and support-claim discipline analyst.

Repository:
https://github.com/jamesryancooper/octon

Prompt title:
Product Claim, Disclosure, and Operator Read-Model Claim Discipline Review

Purpose:
Evaluate whether Octon’s product-facing claims, README language, feature catalog, RunCards, HarnessCards, support cards, generated operator read models, run-health projections, release disclosures, and navigation surfaces accurately reflect admitted support and retained evidence without widening authority, support, runtime routing, closeout truth, or product promises.

Why this deserves Octon Architect-level reasoning:
Even if runtime governance is correct, product language and operator read models can create false trust. Octon must not overclaim safe autonomy, supported surfaces, external operations, self-evolution, connectors, generated outputs, or closure status. Generated read models are helpful but dangerous if operators or models treat them as terminal truth. This review requires cross-checking product claims against support targets, proof bundles, evidence obligations, generated non-authority rules, and disclosure contracts.

Inspect at minimum:
- README.md
- .octon/README.md
- .octon/framework/product/features/catalog.yml
- .octon/framework/product/features/**
- .octon/framework/constitution/CHARTER.md
- .octon/instance/governance/support-targets.yml
- .octon/instance/governance/disclosure/harness-card.yml
- .octon/framework/constitution/contracts/disclosure/**
- .octon/framework/constitution/contracts/retention/**
- .octon/state/evidence/disclosure/**
- .octon/generated/cognition/projections/materialized/**
- .octon/generated/cognition/summaries/**
- .octon/generated/cognition/projections/materialized/support-cards/**
- .octon/generated/cognition/projections/materialized/runs/**
- .octon/framework/engine/runtime/spec/operator-read-models-v1.md
- .octon/framework/engine/runtime/spec/evidence-store-v1.md

Core invariants to preserve:
- Product claims must not exceed admitted, proof-backed support.
- Feature catalog and operator read models are navigation/read-model surfaces only.
- Generated read models do not authorize execution, widen support, satisfy evidence, or close work.
- RunCard/HarnessCard disclosures are subordinate to durable authority and retained evidence.
- Stage-only, unadmitted, unsupported, stale, future-facing, and experimental surfaces must remain clearly non-live.
- Evidence, receipts, replay, rollback, disclosure, and auditability must be preserved.
- Architecture evaluation remains separate from implementation planning.

Exact questions to answer:
1. Do README and product docs accurately describe current admitted support?
2. Do any claims imply broader support than support-targets and proof bundles justify?
3. Is the feature catalog clearly navigation-only and non-authoritative?
4. Are RunCards, HarnessCards, support cards, and release disclosures generated from retained evidence rather than summaries or chat?
5. Do generated operator read models carry explicit non-authority posture, freshness metadata, canonical refs, receipt refs, and forbidden-consumer classification?
6. Can run-health projections or support cards become terminal status truth?
7. Are future-facing surfaces clearly marked stage-only, unadmitted, unsupported, or exploratory?
8. Are connector/browser/API/federation/self-evolution claims bounded to actual support?
9. Are disclosure artifacts truthful about exclusions and limitations?
10. Where could product language train models or operators to bypass governance?

Required output format:
1. Executive finding on claim discipline.
2. Product claim matrix:
   - claim
   - source file
   - implied capability
   - canonical authority/support/evidence backing
   - live/stage-only/unadmitted/unsupported status
   - overclaim risk
3. Generated read-model boundary table:
   - surface
   - source refs
   - freshness metadata
   - allowed consumers
   - forbidden consumers
   - non-authority statement
4. Disclosure sufficiency analysis:
   - RunCard
   - HarnessCard
   - support card
   - release disclosure
5. Overclaim and ambiguity register.
6. Recommended architecture/documentation acceptance criteria, not edits.
7. No implementation plan.

Quality criteria:
- Cite exact file paths and sections.
- Cross-check product language against support targets and proof evidence.
- Distinguish navigation, disclosure, retained evidence, generated read model, and authority.
- Identify model/operator confusion risks.
- Do not rewrite docs unless requested later.
- Avoid generic marketing advice.

Explicit non-goals:
- No documentation edits.
- No claim rewriting.
- No generated read-model changes.
- No support widening.
- No implementation plan.
- No treating read models as authority.

Expected downstream use:
Documentation, governance, disclosure, product roadmap, release readiness, and implementation-readiness gating.
```

---

# How to Use This Prompt Library

## Run these first

Start with the prompts that protect Octon’s core invariants directly:

1. **Single-Control-Plane, Authority Precedence, and Human Authority Artifacts**
2. **Generated-Effective Resolver, Freshness, and Compatibility De-Authorization**
3. **Material Side-Effect Authorization and Policy/ACP Enforcement**
4. **Run Lifecycle, Journal Truth, Evidence Closure, Replay, and Rollback**

These four establish whether Octon has one authority model, safe generated/effective consumption, enforced material-effect boundaries, and reconstructable execution truth.

## Run these next

After the first four, run:

5. **Support Claim Envelope and Proof Executability**
6. **Context, Memory, and Model-Visible Integrity**
7. **Mission-Scoped Autonomy, Stewardship, and Self-Evolution Feedback Loops**

These test whether Octon’s support claims, model-visible context, and autonomy loops preserve the same boundaries.

## Prompts that can be run independently

These can be run independently if that area is under active design review:

- **Connector, Browser, API, Plugin, and External Operation Admission**
- **External Trust, Portability, Adoption, Federation, and Imported Proof**
- **Change Closeout, Branch Landing/Cleanup, and Hosted-Control Surfaces**
- **Product Claim, Disclosure, and Operator Read-Model Claim Discipline**

They are also good focused reviews before any proposal touches those surfaces.

## Prompts to run only after earlier findings exist

Run **Architecture-Health and Validator-Depth Review** after at least some Tier 1 findings exist. Its job is to judge whether validators prove the right architecture claims. Without prior architecture findings, it may collapse into a script inventory.

Roadmap or implementation-readiness work should come only after Octon Architect produces architecture findings and acceptance criteria.

## How to combine outputs into an Octon architecture review packet

Create a file-native review packet with this structure:

```text
octon-architecture-review-packet/
  00-index.md
  01-control-plane-authority.md
  02-generated-effective-trust.md
  03-material-authorization-policy.md
  04-lifecycle-evidence-replay-rollback.md
  05-support-proof-envelope.md
  06-context-memory-integrity.md
  07-autonomy-self-evolution.md
  08-connectors-external-ops.md
  09-external-trust-portability.md
  10-closeout-hosted-control.md
  11-validator-depth.md
  12-product-claim-disclosure.md
  risk-register.yml
  acceptance-gates.yml
  negative-control-matrix.yml
  unresolved-assumptions.md
  implementation-readiness-notes.md
```

The packet should separate:

- **Findings** — what is true or risky now.
- **Evidence** — exact repo paths and cited sections.
- **Acceptance criteria** — what must be true before claims expand.
- **Negative controls** — what must fail closed.
- **Open assumptions** — what is not yet proven.
- **Implementation-readiness notes** — not implementation tasks, only prerequisites.

## What to delegate to cheaper models or implementation agents

Do not spend Octon Architect on:

- generic repo summaries;
- Markdown cleanup;
- schema formatting;
- mechanical path inventories after Octon Architect defines the scope;
- fixture generation from an approved negative-control matrix;
- shell/Rust style review;
- validator implementation;
- generated projection regeneration;
- changelog or release-note drafting;
- routine issue/PR triage;
- implementation task breakdowns before architecture gates are accepted.

Use cheaper models or coding agents after Octon Architect outputs:

- risk registers;
- acceptance criteria;
- missing evidence lists;
- negative-control matrices;
- validator-depth gaps;
- documentation claim gaps;
- implementation-readiness prerequisites.

## How to avoid wasting scarce Octon Architect capacity

Do not ask Octon Architect to “summarize Octon.” Ask it to **falsify a claim**.

Good Octon Architect tasks look like:

```text
Can this surface become a second control plane?
Can this generated artifact influence runtime without resolver verification?
Can this material operation mutate without VerifiedEffect<T>?
Can this support claim be cited without executable/replayable proof?
Can this context pack launder non-authority into model-visible authority?
Can this autonomy loop renew itself into unbounded work?
```

Bad Octon Architect tasks look like:

```text
Summarize the repository.
List all files related to runtime.
Write tests for this validator.
Clean up this documentation.
Implement the missing check.
Create a roadmap from scratch.
```

The most efficient pattern is:

1. Run a Octon Architect architecture review prompt.
2. Extract findings, assumptions, risks, and acceptance criteria.
3. Ask a cheaper model to turn accepted criteria into mechanical inventories or implementation-readiness checklists.
4. Use implementation agents only after architecture and planning are separated and approved.
5. Return to Octon Architect only for hard judgment calls, contradictions, authority-boundary disputes, support-widening decisions, or proposal reviews before coding.

---

# you asked

message time: 2026-07-03 20:10:31

You are a senior Octon architecture reviewer, governed-runtime architect, authority-boundary critic, and architecture-review method selector.

Your task is to determine whether Octon Architect reasoning should be used to run a **Balanced Architecture Review**, a **Clean-Sheet / clean-room critique lens**, or both, against Octon’s authoritative super-root architecture.

Repository:

```text
https://github.com/jamesryancooper/octon
```

Primary review-method reference:

```text
.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md
```

## Review Question

Should Octon Architect run:

1. a full **Balanced Architecture Review** of Octon’s authoritative super-root;
2. a **Clean-Sheet critique lens** to challenge whether the current architecture is the right shape for Octon’s intended purpose;
3. both, in a staged sequence; or
4. neither, because another review method would be higher leverage?

Do not assume the answer. Evaluate the fit of each method against Octon’s architecture, governance model, runtime boundaries, support claims, evidence requirements, and long-term product direction.

## Octon Architecture Context

Evaluate the review-method choice against Octon’s intended architecture:

```text
.octon/ is the authoritative super-root.

Authored authority may live only under:
- framework/**
- instance/**

Mutable control truth lives under:
- state/control/**

Retained evidence lives under:
- state/evidence/**

Continuity and resumable context live under:
- state/continuity/**

Generated outputs are derived-only and must not mint authority:
- generated/**

Inputs are non-authoritative:
- inputs/**
```

Also evaluate the super-root topology, class-root model, authority boundaries, generated/effective surfaces, runtime control paths, support-target posture, evidence/receipt model, replay/rollback requirements, and operator read-model boundaries against Octon’s intended purpose.

## Core Constraints

Preserve these invariants:

* Octon remains the governing control layer.
* Do not introduce or legitimize a second control plane.
* Provider sessions, assistants, raw model responses, generated outputs, generated read models, host UI state, labels, comments, checks, chat transcripts, and model memory are not authority.
* Autonomy remains mission-scoped, reversible, bounded, and auditable.
* Execution remains deny-by-default.
* Evidence, receipts, replay, rollback, disclosure, and auditability are preserved.
* Artifacts remain file-native, inspectable, and portable.
* Separate architecture evaluation from implementation planning.
* Separate implementation planning from implementation.
* Do not propose coding tasks prematurely.

## Required Analysis

Answer the following:

1. Is a **Balanced Architecture Review** the right first Octon Architect task for Octon’s super-root architecture?
2. Is a **Clean-Sheet critique lens** useful here, or would it risk producing abstract redesign ideas that conflict with Octon’s existing authority model?
3. Should the Clean-Sheet lens be used inside the Balanced Review rather than as a separate review?
4. What specific questions should each method answer?
5. Which Octon surfaces should be included in scope?
6. Which surfaces should be explicitly out of scope?
7. What risks would the review expose that the current Octon Architect target list might miss?
8. What risks would the review *not* be well suited to expose?
9. What output artifact should Octon Architect produce?
10. What quality criteria should determine whether the review was useful?

## Required Output

Produce:

1. **Recommendation**

   * Run Balanced Review only
   * Run Clean-Sheet lens only
   * Run both, staged
   * Run neither / use another review first

2. **Rationale**

   * Why this is or is not a high-leverage use of Octon Architect.

3. **Method Fit Table**

   * Review method
   * Strengths
   * Risks
   * Best questions
   * Expected artifact
   * Whether it should be Tier 1, Tier 2, or delegated

4. **Recommended Scope**

   * Files/directories/surfaces to inspect
   * Authority, runtime, support, evidence, generated, input, continuity, and topology surfaces to include

5. **Review Questions**

   * Exact repo-grounded questions Octon Architect should answer

6. **Expected Review Artifact**

   * Structure of the final architecture-review output

7. **Quality Criteria**

   * How to judge whether the review was rigorous, repo-grounded, and implementation-useful

8. **Non-Goals**

   * No implementation plan
   * No code changes
   * No speculative redesign detached from Octon’s constraints
   * No generic architecture advice
   * No second-control-plane framing

Keep the response critical and evidence-oriented. Treat the review method itself as a hypothesis to validate, not as an assumed best choice.

---

# source model response

I’ll treat the review method itself as the object under review, grounding the choice in Octon’s Balanced Architecture Review guidance and authority/runtime constraints. The method already includes a bounded clean-sheet comparison, so I’ll test whether that lens belongs inside the review or should be staged separately.

---

# source model response

## 1. Recommendation

**Run both, staged — but not as two equal, free-form reviews.**

The highest-leverage use of Octon Architect is:

1. **Run a full Balanced Architecture Review first** against Octon’s authoritative super-root architecture.
2. **Use the Clean-Sheet critique lens inside that Balanced Review**, exactly as the method intends.
3. **Only run a separate Clean-Sheet follow-up if the Balanced Review exposes unresolved foundational doubts** about Octon’s shape, such as whether the five-root model, generated/effective handle pattern, mission/run split, or support-target proof model is carrying too much accidental complexity.

I would **not** run a standalone clean-room critique first. That risks producing attractive but detached redesigns that violate Octon’s constitutional constraints: single control plane, authored authority only in `framework/**` and `instance/**`, generated outputs as derived-only, input surfaces as non-authority, mission-scoped autonomy, deny-by-default execution, and retained evidence/replay/rollback/auditability. The Balanced Architecture Review method is explicitly designed to avoid that failure mode: it starts from first principles, restores current-system context, steelmans the current design, applies Chesterton’s Fence, and only then builds a clean-sheet reference design for comparison. 

So the answer is: **Run both, staged, with Balanced Review as Tier 1 and Clean-Sheet as a constrained lens, not as an unconstrained redesign exercise.**

---

## 2. Rationale

A full Balanced Architecture Review is a high-leverage Octon Architect task because Octon’s super-root is not a small component; it is the governing architecture for authority, runtime execution, evidence, generated projections, support claims, context, autonomy, and governance. The method’s required sequence is a good match: it explicitly requires mapping current reality across architecture, runtime behavior, state ownership, workflows, validators, generated projections, evidence roots, and recovery.  Those are exactly the surfaces where Octon’s core invariants can fail.

The method also includes the necessary safeguards. Its “Octon Fit Gates” require durable meaning to live in authored `framework/**` or `instance/**`, reject raw inputs, proposal analysis, chat, host state, model memory, dashboards, and generated views as authority, require retained evidence for lifecycle-impacting conclusions, require validators/tests/fixtures or an owned blocker for durable changes, require canonical publication scripts for generated outputs, and route constitutional conflicts to Constitutional Challenge. 

That makes Balanced Review the right first task. It is not just a broad review; it is Octon-native and specifically built to compare clean-sheet possibilities against current constraints without prematurely discarding those constraints.

A clean-sheet lens is still useful, but only if bounded. It should ask, “If Octon were designed today to satisfy the same constitutional constraints and product purpose, would this super-root shape still be the best architecture?” It should not ask, “What agent runtime would we design from scratch?” The latter would likely drift into generic agent-framework advice and risk legitimizing a second control plane.

Another review method is not higher leverage as the first pass. Octon’s review routing distinguishes narrower modes such as current-state mechanism review, architecture readiness audit, domain audit, and surface audit. Those are useful after scoping or implementation-readiness questions exist.  For the authoritative super-root itself, the broad native Balanced Review is the better Octon Architect entry point.

---

## 3. Method Fit Table

| Review method | Strengths | Risks | Best questions | Expected artifact | Priority |
|---|---|---|---|---|---|
| **Full Balanced Architecture Review** | Best fit for Octon because it starts from first principles, restores current reality, steelmans current design, applies Chesterton’s Fence, separates essential from accidental complexity, compares clean-sheet and realistic target designs, and defines authority/evidence/validation/publication/rollback posture.  | Can become too broad if not scoped tightly to the authoritative super-root and core invariants. Can drift into planning if the output contract’s “plan” language is interpreted as implementation planning rather than architecture-level posture. | Does the super-root architecture remain the right shape for Octon’s purpose? Which constraints are essential vs accidental? Where are hidden contracts, stale constraints, bottlenecks, and leverage points? | **Octon Super-Root Balanced Architecture Review Packet** | **Tier 1** |
| **Clean-Sheet critique lens inside Balanced Review** | Provides first-principles pressure without discarding current constraints. The method already requires a clean-sheet reference design as a comparison tool after current reality, steelman, and Chesterton’s Fence.  | If treated as unconstrained redesign, it may produce abstract agent-runtime ideas that violate Octon’s authority model. | If we had to satisfy the same Octon invariants today, would we still choose five roots, generated/effective handles, mission/run split, support-target proofing, and retained file-native evidence? | **Bounded Clean-Sheet Comparison Section** inside the Balanced Review | **Tier 1 as embedded lens** |
| **Standalone Clean-Sheet / clean-room critique** | Useful only after Balanced Review identifies unresolved foundational doubts. Can expose overfitting, excessive compensating mechanisms, unnecessary topology, or product-shape mismatch. | High risk of speculative redesign, second-control-plane framing, generic “agent platform” ideas, or implementation proposals detached from Octon’s constitutional regime. | Which parts of the current shape are accidental complexity rather than necessary governance? Could the same invariants be satisfied with fewer surfaces or clearer boundaries? | **Constrained Clean-Sheet Delta Memo** | **Tier 2 / conditional** |
| **Current-state mechanism architecture review** | Good for a bounded mechanism that needs cross-surface review. The routing taxonomy names this route for “a current governed mechanism” needing cross-surface architecture review.  | Too narrow for the whole authoritative super-root. | Is one current mechanism coherent across runtime, state, validators, evidence, and generated projections? | Mechanism-specific architecture review | Delegated or Tier 2 |
| **Architecture readiness audit** | Useful when implementation readiness is the question; routing says it applies when whole-harness or bounded-domain implementation readiness is being evaluated.  | Premature here because the user is asking architecture-method selection, not implementation readiness. | Are accepted architecture gates, validators, tests, rollback posture, and evidence complete enough for implementation? | Readiness audit | Tier 2 after Balanced Review |
| **Constitutional Challenge** | Required if a proposed architecture conflicts with constitutional, precedence, authority, fail-closed, or evidence obligations.  | Not the first review unless the Balanced Review finds a constitutional conflict. | Does a proposed change violate the constitution or require amendment? | Constitutional challenge packet | Triggered only by conflict |

---

## 4. Recommended Scope

### Include these authoritative and structural surfaces

**Core super-root topology and authority model**

- `.octon/README.md`
- `.octon/octon.yml`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `.octon/framework/constitution/CHARTER.md`
- `.octon/framework/constitution/charter.yml`
- `.octon/framework/constitution/precedence/normative.yml`
- `.octon/framework/constitution/precedence/epistemic.yml`
- `.octon/framework/constitution/obligations/fail-closed.yml`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/ownership/roles.yml`
- `.octon/framework/constitution/contracts/registry.yml`

**Ingress, bootstrap, and execution-role surfaces**

- `.octon/AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/instance/ingress/manifest.yml`
- `.octon/instance/bootstrap/START.md`
- `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`
- `.octon/framework/execution-roles/governance/MEMORY.md`

**Runtime control paths**

- `.octon/framework/engine/runtime/README.md`
- `.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
- `.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md`
- `.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml`
- `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `.octon/framework/engine/runtime/spec/run-journal-v1.md`
- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `.octon/framework/engine/runtime/spec/policy-interface-v1.md`
- `.octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/**`

**Generated/effective and read-model boundaries**

- `.octon/framework/engine/runtime/spec/runtime-resolution-v1.md`
- `.octon/instance/governance/runtime-resolution.yml`
- `.octon/framework/engine/runtime/spec/runtime-effective-artifact-handle-v2.md`
- `.octon/framework/engine/runtime/spec/publication-freshness-gates-v4.md`
- `.octon/framework/engine/runtime/spec/compatibility-retirement-cutover-v2.md`
- `.octon/generated/effective/**`
- `.octon/generated/cognition/**`
- `.octon/generated/proposals/**`
- `.octon/instance/governance/retirement-register.yml`

**Support, capability, adapter, and proof posture**

- `.octon/instance/governance/support-targets.yml`
- `.octon/instance/governance/support-target-admissions/**`
- `.octon/instance/governance/support-dossiers/**`
- `.octon/instance/governance/contracts/support-target-proofing.yml`
- `.octon/instance/governance/capability-packs/**`
- `.octon/framework/engine/runtime/adapters/**`
- `.octon/state/evidence/validation/support-targets/**`

**Evidence, disclosure, replay, rollback, and operator views**

- `.octon/state/control/execution/**`
- `.octon/state/evidence/runs/**`
- `.octon/state/evidence/disclosure/**`
- `.octon/state/evidence/validation/**`
- `.octon/framework/constitution/contracts/disclosure/**`
- `.octon/framework/constitution/contracts/retention/**`

**Mission autonomy, stewardship, and self-evolution**

- `.octon/instance/governance/policies/mission-autonomy.yml`
- `.octon/framework/engine/runtime/spec/continuous-stewardship-runtime-v3.md`
- `.octon/instance/orchestration/missions/**`
- `.octon/state/control/execution/missions/**`
- `.octon/state/continuity/repo/missions/**`
- `.octon/instance/cognition/decisions/102-self-evolution-proposal-to-promotion-runtime.md`
- `.octon/state/control/evolution/**`
- `.octon/state/evidence/evolution/**`

**External/admission surfaces if super-root review includes future product direction**

- `.octon/instance/governance/connectors/**`
- `.octon/state/control/connectors/**`
- `.octon/state/evidence/connectors/**`
- `.octon/instance/governance/trust/**`
- `.octon/state/evidence/trust/**`
- browser/API capability pack manifests

### Explicitly out of scope

These should not be primary scope for the first Balanced Review unless they become evidence for a core finding:

- Routine implementation details that do not affect authority, runtime, evidence, support, generated/effective trust, or autonomy.
- Full line-by-line Rust refactoring critique.
- Shell style review.
- Markdown polish.
- Generated read-model content quality except where it affects non-authority boundaries.
- Archived proposal packet content except as lineage/evidence for why current surfaces exist.
- Implementation planning, coding, test writing, or migration sequencing.
- Any redesign that ignores the constitutional model.

---

## 5. Review Questions Octon Architect Should Answer

### Balanced Architecture Review questions

1. **Review charter:** What decision is this review actually supporting: retain current super-root shape, refine it, split/merge surfaces, retire compatibility layers, or trigger a constitutional challenge?
2. **Fundamental job:** What is the irreducible job of Octon’s authoritative super-root?
3. **Current reality:** How does current Octon distribute authority, mutable control truth, retained evidence, continuity, generated effective handles, generated read models, and inputs?
4. **Steelman:** What is the strongest case for the current five-root model and super-root architecture?
5. **Chesterton’s Fence:** Which existing surfaces look complicated but are necessary to preserve deny-by-default execution, auditability, support proofing, replay, rollback, or non-authority boundaries?
6. **Complexity ledger:** Which complexity is essential, and which is accidental, compensating, operational, integration, migration, or historical compatibility complexity?
7. **Hidden contracts:** What implicit contracts exist between authority, runtime, generated/effective outputs, evidence, validators, support targets, and operator read models?
8. **Stale constraints:** Which constraints are historical and may now be candidates for retirement?
9. **Bottlenecks:** Where does the architecture concentrate too much responsibility: contract registry, runtime-resolution, support-targets, generated/effective handles, evidence store, context packs, or authority engine?
10. **Leverage points:** Which small architecture clarifications would reduce the most risk without changing implementation?
11. **Failure modes:** Where can Octon accidentally produce a second control plane?
12. **Second-order effects:** What future product direction could stress the current shape: connectors, browser/API packs, external trust, federation, self-evolution, long-running stewardship, or support expansion?
13. **Realistic target architecture:** What should be preserved, moved, merged, split, renamed, retired, or left alone?
14. **Governance fit:** Does the resulting target still preserve Octon’s constitutional gates and native authority model?

### Clean-Sheet lens questions

The clean-sheet lens should be used only under Octon’s existing invariants:

1. If designing from scratch for the same purpose and constraints, would `.octon/` still be the single super-root?
2. Would the five class roots still be the right root model?
3. Would authored authority still live only in `framework/**` and `instance/**`?
4. Would generated/effective handles exist, or would runtime resolution be modeled differently?
5. Is the split between `state/control/**`, `state/evidence/**`, and `state/continuity/**` necessary and sufficient?
6. Is mission authority correctly separate from run authority?
7. Is support-target proofing the right way to keep claims finite?
8. Is the context-pack model the simplest safe way to provide model-visible context?
9. Are operator read models useful enough to justify their risk?
10. What would a simpler architecture lose in evidence, replay, rollback, auditability, or governance?
11. What would a stricter architecture make impossible or too costly?
12. Which current surfaces are likely compensating mechanisms for missing deeper abstractions?

---

## 6. Risks This Review Could Expose That the Current Octon Architect Target List Might Miss

The prior target list is strong on specific risk areas. A Balanced Review adds value by finding **cross-cutting shape problems**, not just per-domain defects.

It may expose:

- **Over-distribution of authority references:** too many surfaces repeat or point to authority, making precedence hard to reason about.
- **Essential vs accidental topology complexity:** whether five roots are sufficient or whether some sub-roots are doing too much.
- **Compatibility-layer drag:** retained shims that remain because of migration history rather than current need.
- **Contract-registry centrality risk:** whether too much interpretive burden lives in one registry.
- **Generated/effective ambiguity at architectural shape level:** not merely whether handles are fresh, but whether runtime-facing generated artifacts are the right pattern.
- **Operator usability vs governance tension:** whether file-native governance is inspectable for humans or too fragmented to operate reliably.
- **Product-shape mismatch:** whether Octon is becoming a full agent-runtime platform despite claiming to be a governed harness.
- **Review-method gaps:** whether specific domain reviews are missing a higher-level architectural constraint.

---

## 7. Risks This Review Is Not Well Suited to Expose

A Balanced Review is not the best first tool for:

- Line-by-line authorization bypass detection.
- Exhaustive Rust call-graph verification.
- Shell-script safety audit.
- Validator implementation correctness.
- CI permission-hardening details.
- Schema conformance edge cases.
- Concrete exploit testing.
- Performance or scalability benchmarking.
- Product-market positioning.
- Implementation sequencing.

Those should be delegated to targeted audits after the Balanced Review identifies architecture-level risk and acceptance criteria.

---

## 8. Expected Review Artifact

Octon Architect should produce an **Octon Authoritative Super-Root Balanced Architecture Review Packet** with this structure:

```text
# Octon Authoritative Super-Root Balanced Architecture Review

## 1. Review Charter
- Decision under review
- Scope
- Stakeholders
- Risk tolerance
- Time horizon
- Non-goals
- Required outcome

## 2. Fundamental System Job
- What Octon’s super-root must do
- What it must not become
- Core invariants

## 3. Current Reality Map
- Class-root topology
- Authority hierarchy
- Runtime control paths
- Support-target posture
- Evidence/receipt/replay/rollback model
- Generated/effective surfaces
- Operator read-model boundaries
- Continuity and mission autonomy
- Input and proposal boundaries

## 4. Steelman of Current Design
- Strongest case for five roots
- Strongest case for generated/effective handles
- Strongest case for mission/run separation
- Strongest case for support proofing
- Strongest case for file-native evidence

## 5. Chesterton’s Fence Analysis
- Preserve
- Move
- Merge
- Split
- Rename
- Retire
- Leave alone
- Escalate to Constitutional Challenge

## 6. Constraint and Complexity Ledgers
- Essential complexity
- Accidental complexity
- Compensating mechanisms
- Operational complexity
- Integration complexity
- Migration/historical complexity
- Stale constraints
- Hidden contracts

## 7. Clean-Sheet Reference Design
- Same purpose
- Same invariants
- No second control plane
- No generated/read-model authority
- Comparison only, not implementation proposal

## 8. Current vs Clean-Sheet Comparison
- What current design gets right
- Where current design is overfit
- Where clean-sheet design would simplify
- What clean-sheet design would lose
- Which current constraints remain valid

## 9. Realistic Target Architecture
- Recommended retain/refine/retire posture
- Authority boundaries
- Runtime boundaries
- Evidence requirements
- Validator expectations
- Publication/freshness posture
- Rollback and revisit triggers

## 10. Failure Modes and Second-Order Effects
- Second-control-plane risks
- Support-widening risks
- Generated/effective trust risks
- Autonomy feedback loops
- Context/memory laundering
- External trust/federation risks
- Operator/read-model confusion

## 11. Review Method Findings
- Was Balanced Review sufficient?
- Was clean-sheet lens useful?
- Is a separate Constitutional Challenge needed?
- Are narrower follow-up reviews needed?

## 12. Final Verdict
- Preserve as-is
- Preserve with refinements
- Needs bounded architecture revision
- Needs constitutional challenge
- Not enough evidence

## 13. Unresolved Blockers
- Blocker
- Evidence needed
- Owner
- Review route
- Revisit trigger
```

The method’s own output contract supports this shape: it requires a review charter, system job/current reality map, steelman and Chesterton’s Fence analysis, constraint and complexity ledgers, bottleneck/leverage analysis, failure-mode and second-order-effect analysis, clean-sheet reference design, option comparison, recommendation, authority/evidence/validation/publication/rollback plan, final verdict, and unresolved blocker count. 

For this task, “plan” should mean **architecture-level posture and acceptance gates**, not implementation sequencing.

---

## 9. Quality Criteria

A useful Octon Architect review should meet all of these criteria:

1. **Repo-grounded:** Every major claim cites concrete repository files or explicitly states that evidence was not found.
2. **Method-faithful:** It follows the Balanced Architecture Review sequence rather than jumping straight to redesign.
3. **Clean-sheet bounded:** The clean-sheet comparison preserves Octon’s invariants and does not invent an alternate agent runtime.
4. **Current design steelmanned:** It explains why existing complexity may be necessary before criticizing it.
5. **Chesterton’s Fence applied:** It does not recommend retiring, merging, moving, or renaming surfaces without explaining what safety role they currently serve.
6. **Authority-safe:** It never treats generated outputs, read models, chat, host UI, labels, comments, checks, provider sessions, or model memory as authority.
7. **Intent vs enforcement separated:** It distinguishes documented intent from validators, runtime enforcement, evidence, receipts, and actual path boundaries.
8. **Essential vs accidental complexity separated:** It classifies complexity rather than merely calling the architecture “complex.”
9. **Architecture vs implementation separated:** It produces acceptance criteria and review gates, not coding tasks.
10. **Second-order effects included:** It analyzes how future connectors, external trust, self-evolution, support expansion, and long-running autonomy could stress the current shape.
11. **Blockers explicit:** It ends with unresolved blockers, missing evidence, and revisit triggers.
12. **No generic advice:** It should read like an Octon-specific architectural judgment, not a generic agent-system review.

---

## 10. Non-Goals

The review must not do any of the following:

- No implementation plan.
- No code changes.
- No validator implementation.
- No migration sequence unless a later planning task requests it.
- No speculative redesign detached from Octon’s constitutional constraints.
- No generic architecture advice.
- No product pivot framing.
- No second-control-plane framing.
- No treating provider sessions, assistants, raw model responses, generated outputs, generated read models, host UI state, labels, comments, checks, chat transcripts, or model memory as authority.
- No support widening.
- No connector/browser/API admission.
- No self-evolution promotion.
- No publication or generated/effective regeneration.

---

## Final Recommendation

Use Octon Architect for a **Tier 1 Balanced Architecture Review of Octon’s authoritative super-root**, with a **bounded Clean-Sheet critique lens embedded inside it**. Do not run clean-room redesign as a standalone first step.

A separate Clean-Sheet follow-up is justified only if the Balanced Review finds that the current architecture may be preserving obsolete constraints, compensating mechanisms, or accidental topology complexity that cannot be resolved by ordinary refinement. Otherwise, the clean-sheet lens should remain a comparison tool inside the Balanced Review.

The most efficient Octon Architect prompt would be: “Run Octon’s Balanced Architecture Review Method against the authoritative super-root, including a bounded clean-sheet reference design under Octon’s existing invariants, and produce an architecture review packet with no implementation plan.”

---

# you asked

message time: 2026-07-03 20:24:29

# Create an Octon Architecture Review Prompt Library

You are a senior Octon architecture reviewer, governed-runtime architect, authority-boundary critic, architecture-review method designer, and Octon Architect prompt engineer.

Your task is to create a comprehensive **Octon Architect prompt library** for running additional Octon architecture reviews.

The prompt library should produce ready-to-use, copy/paste prompts that help Octon Architect perform high-leverage architecture and governance reviews without drifting into premature implementation, generic redesign, or second-control-plane framing.

Repository:

```text
https://github.com/jamesryancooper/octon
```

Primary method reference:

```text
.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md
```

## Context

A prior method-selection review concluded:

1. Octon Architect should run a **Tier 1 Balanced Architecture Review** of Octon’s authoritative super-root architecture.
2. The **Clean-Sheet / clean-room critique lens** should be embedded inside the Balanced Review as a constrained comparison tool.
3. A separate Clean-Sheet follow-up should be run only if the Balanced Review exposes unresolved foundational doubts about Octon’s shape, such as:

   * the five-root model;
   * the generated/effective handle pattern;
   * the mission/run split;
   * support-target proofing;
   * retained file-native evidence;
   * whether current topology includes excessive compensating or accidental complexity.
4. A standalone clean-room critique should **not** be the first review, because unconstrained redesign risks violating Octon’s constitutional constraints.

The Balanced Architecture Review Method is considered the right first method because it:

* starts from first principles;
* restores current-system context;
* maps current reality;
* steelmans the current design;
* applies Chesterton’s Fence;
* separates essential from accidental complexity;
* identifies hidden contracts, stale constraints, bottlenecks, and leverage points;
* builds a bounded clean-sheet reference design only as a comparison tool;
* produces a realistic target architecture that fits Octon’s governance model.

## Octon Core Constraints

Every generated prompt must preserve these invariants:

* Octon remains the governing control layer.
* Do not introduce or legitimize a second control plane.
* Authored authority may live only under:

  * `framework/**`
  * `instance/**`
* Mutable control truth lives under:

  * `state/control/**`
* Retained evidence lives under:

  * `state/evidence/**`
* Continuity and resumable context live under:

  * `state/continuity/**`
* Generated outputs are derived-only and must not mint authority:

  * `generated/**`
* Inputs are non-authoritative:

  * `inputs/**`
* Provider sessions, assistants, raw model responses, generated outputs, generated read models, host UI state, labels, comments, checks, chat transcripts, and model memory are not authority.
* Autonomy remains mission-scoped, reversible, bounded, and auditable.
* Execution remains deny-by-default.
* Evidence, receipts, replay, rollback, disclosure, and auditability are preserved.
* Artifacts remain file-native, inspectable, and portable.
* Separate architecture evaluation from implementation planning.
* Separate implementation planning from implementation.
* Do not propose coding tasks prematurely.

## Prompt Library Scope

Create one comprehensive prompt for each of the following review types:

1. **Octon Authoritative Super-Root Balanced Architecture Review**

   * Full Tier 1 review.
   * Includes bounded Clean-Sheet lens inside the Balanced Review.

2. **Bounded Clean-Sheet Delta Review**

   * Conditional follow-up only if the Balanced Review finds unresolved foundational doubts.
   * Must preserve Octon’s existing constitutional constraints.

3. **Current-State Mechanism Architecture Review**

   * For reviewing one current governed mechanism across authority, runtime, state, validators, evidence, generated projections, and recovery.
   * Should be narrower than the full super-root review.

4. **Architecture Readiness Audit**

   * For determining whether an accepted architecture is ready for implementation planning.
   * Must not become implementation itself.

5. **Domain Architecture Audit**

   * For reviewing a bounded Octon domain, such as support targets, generated/effective trust, context packing, connector admission, self-evolution, or evidence closure.

6. **Surface Architecture Audit**

   * For reviewing one durable surface, contract, registry, schema family, policy, adapter boundary, generated/effective handle family, or evidence root.

7. **Constitutional Challenge Review**

   * For proposed architecture that may conflict with Octon’s constitutional, precedence, authority, fail-closed, or evidence obligations.
   * Should be triggered only when the Balanced Review or another architecture review identifies a constitutional conflict.

## Required Content for Each Prompt

For each generated prompt, include:

1. **Prompt title**
2. **When to use this review**
3. **Purpose of the review**
4. **Why this deserves Octon Architect-level reasoning**
5. **Repository and required method references**
6. **Specific files, directories, or surfaces to inspect**
7. **Core invariants the review must preserve**
8. **Exact repo-grounded questions Octon Architect must answer**
9. **Required output format**
10. **Quality criteria for judging the result**
11. **Explicit non-goals**
12. **Expected downstream use**

    * architecture;
    * governance;
    * tests;
    * documentation;
    * roadmap;
    * planning;
    * implementation-readiness.

## Global Requirements for All Prompts

Every prompt must require Octon Architect to:

* cite repository evidence by file path;
* distinguish documented intent from implemented or enforced behavior;
* identify contradictions, hidden assumptions, stale constraints, unresolved risks, bottlenecks, leverage points, and second-order effects;
* separate architecture evaluation from implementation planning;
* separate implementation planning from actual implementation;
* avoid generic advice;
* avoid summarizing the repository;
* avoid speculative redesign detached from Octon’s constitutional model;
* avoid legitimizing a second control plane;
* preserve Octon’s authority, evidence, generated-output, support, runtime, autonomy, and disclosure boundaries.

## Required Scope Guidance

The prompt library should reuse the following scope guidance where appropriate.

### Core super-root topology and authority model

```text
.octon/README.md
.octon/octon.yml
.octon/framework/cognition/_meta/architecture/specification.md
.octon/framework/cognition/_meta/architecture/contract-registry.yml
.octon/framework/constitution/CHARTER.md
.octon/framework/constitution/charter.yml
.octon/framework/constitution/precedence/normative.yml
.octon/framework/constitution/precedence/epistemic.yml
.octon/framework/constitution/obligations/fail-closed.yml
.octon/framework/constitution/obligations/evidence.yml
.octon/framework/constitution/ownership/roles.yml
.octon/framework/constitution/contracts/registry.yml
```

### Ingress, bootstrap, and execution-role surfaces

```text
.octon/AGENTS.md
.octon/instance/ingress/AGENTS.md
.octon/instance/ingress/manifest.yml
.octon/instance/bootstrap/START.md
.octon/framework/execution-roles/runtime/orchestrator/ROLE.md
.octon/framework/execution-roles/governance/MEMORY.md
```

### Runtime control paths

```text
.octon/framework/engine/runtime/README.md
.octon/framework/engine/runtime/spec/execution-authorization-v1.md
.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md
.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml
.octon/framework/engine/runtime/spec/run-lifecycle-v1.md
.octon/framework/engine/runtime/spec/run-journal-v1.md
.octon/framework/engine/runtime/spec/evidence-store-v1.md
.octon/framework/engine/runtime/spec/context-pack-builder-v1.md
.octon/framework/engine/runtime/spec/policy-interface-v1.md
.octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs
.octon/framework/engine/runtime/crates/authority_engine/src/implementation/**
```

### Generated/effective and read-model boundaries

```text
.octon/framework/engine/runtime/spec/runtime-resolution-v1.md
.octon/instance/governance/runtime-resolution.yml
.octon/framework/engine/runtime/spec/runtime-effective-artifact-handle-v2.md
.octon/framework/engine/runtime/spec/publication-freshness-gates-v4.md
.octon/framework/engine/runtime/spec/compatibility-retirement-cutover-v2.md
.octon/generated/effective/**
.octon/generated/cognition/**
.octon/generated/proposals/**
.octon/instance/governance/retirement-register.yml
```

### Support, capability, adapter, and proof posture

```text
.octon/instance/governance/support-targets.yml
.octon/instance/governance/support-target-admissions/**
.octon/instance/governance/support-dossiers/**
.octon/instance/governance/contracts/support-target-proofing.yml
.octon/instance/governance/capability-packs/**
.octon/framework/engine/runtime/adapters/**
.octon/state/evidence/validation/support-targets/**
```

### Evidence, disclosure, replay, rollback, and operator views

```text
.octon/state/control/execution/**
.octon/state/evidence/runs/**
.octon/state/evidence/disclosure/**
.octon/state/evidence/validation/**
.octon/framework/constitution/contracts/disclosure/**
.octon/framework/constitution/contracts/retention/**
```

### Mission autonomy, stewardship, and self-evolution

```text
.octon/instance/governance/policies/mission-autonomy.yml
.octon/framework/engine/runtime/spec/continuous-stewardship-runtime-v3.md
.octon/instance/orchestration/missions/**
.octon/state/control/execution/missions/**
.octon/state/continuity/repo/missions/**
.octon/instance/cognition/decisions/102-self-evolution-proposal-to-promotion-runtime.md
.octon/state/control/evolution/**
.octon/state/evidence/evolution/**
```

### External/admission surfaces

Include only when relevant to the review type:

```text
.octon/instance/governance/connectors/**
.octon/state/control/connectors/**
.octon/state/evidence/connectors/**
.octon/instance/governance/trust/**
.octon/state/evidence/trust/**
browser/API capability pack manifests
```

## Required Balanced Review Questions

The **Octon Authoritative Super-Root Balanced Architecture Review** prompt must require Octon Architect to answer:

1. What decision is this review supporting?

   * retain current super-root shape;
   * refine it;
   * split or merge surfaces;
   * retire compatibility layers;
   * trigger a Constitutional Challenge;
   * identify insufficient evidence.
2. What is the irreducible job of Octon’s authoritative super-root?
3. How does current Octon distribute:

   * authority;
   * mutable control truth;
   * retained evidence;
   * continuity;
   * generated/effective handles;
   * generated read models;
   * inputs?
4. What is the strongest case for the current five-root model?
5. What is the strongest case for generated/effective handles?
6. What is the strongest case for mission/run separation?
7. What is the strongest case for support-target proofing?
8. What is the strongest case for retained file-native evidence?
9. Which current surfaces look complicated but are necessary under Chesterton’s Fence?
10. Which complexity is essential, accidental, compensating, operational, integration-related, migration-related, or historical?
11. What hidden contracts exist between authority, runtime, generated/effective outputs, evidence, validators, support targets, and operator read models?
12. Which constraints are stale or candidates for retirement?
13. Where does the architecture concentrate too much responsibility?
14. Where can Octon accidentally produce a second control plane?
15. What future product directions stress the current shape?
16. What should be preserved, moved, merged, split, renamed, retired, or left alone?
17. Does the realistic target architecture still preserve Octon’s constitutional gates and native authority model?

## Required Clean-Sheet Lens Questions

The Balanced Review prompt must include a bounded Clean-Sheet lens that asks:

1. If designing from scratch for the same purpose and constraints, would `.octon/` still be the single super-root?
2. Would the five class roots still be the right root model?
3. Would authored authority still live only in `framework/**` and `instance/**`?
4. Would generated/effective handles exist, or would runtime resolution be modeled differently?
5. Is the split between `state/control/**`, `state/evidence/**`, and `state/continuity/**` necessary and sufficient?
6. Is mission authority correctly separate from run authority?
7. Is support-target proofing the right way to keep claims finite?
8. Is the context-pack model the simplest safe way to provide model-visible context?
9. Are operator read models useful enough to justify their risk?
10. What would a simpler architecture lose in evidence, replay, rollback, auditability, or governance?
11. What would a stricter architecture make impossible or too costly?
12. Which current surfaces are likely compensating mechanisms for missing deeper abstractions?

## Required Output for the Super-Root Balanced Review Prompt

The generated prompt for the full Balanced Review must require this artifact:

```text
# Octon Authoritative Super-Root Balanced Architecture Review

## 1. Review Charter
- Decision under review
- Scope
- Stakeholders
- Risk tolerance
- Time horizon
- Non-goals
- Required outcome

## 2. Fundamental System Job
- What Octon’s super-root must do
- What it must not become
- Core invariants

## 3. Current Reality Map
- Class-root topology
- Authority hierarchy
- Runtime control paths
- Support-target posture
- Evidence/receipt/replay/rollback model
- Generated/effective surfaces
- Operator read-model boundaries
- Continuity and mission autonomy
- Input and proposal boundaries

## 4. Steelman of Current Design
- Strongest case for five roots
- Strongest case for generated/effective handles
- Strongest case for mission/run separation
- Strongest case for support proofing
- Strongest case for file-native evidence

## 5. Chesterton’s Fence Analysis
- Preserve
- Move
- Merge
- Split
- Rename
- Retire
- Leave alone
- Escalate to Constitutional Challenge

## 6. Constraint and Complexity Ledgers
- Essential complexity
- Accidental complexity
- Compensating mechanisms
- Operational complexity
- Integration complexity
- Migration/historical complexity
- Stale constraints
- Hidden contracts

## 7. Clean-Sheet Reference Design
- Same purpose
- Same invariants
- No second control plane
- No generated/read-model authority
- Comparison only, not implementation proposal

## 8. Current vs Clean-Sheet Comparison
- What current design gets right
- Where current design is overfit
- Where clean-sheet design would simplify
- What clean-sheet design would lose
- Which current constraints remain valid

## 9. Realistic Target Architecture
- Recommended retain/refine/retire posture
- Authority boundaries
- Runtime boundaries
- Evidence requirements
- Validator expectations
- Publication/freshness posture
- Rollback and revisit triggers

## 10. Failure Modes and Second-Order Effects
- Second-control-plane risks
- Support-widening risks
- Generated/effective trust risks
- Autonomy feedback loops
- Context/memory laundering
- External trust/federation risks
- Operator/read-model confusion

## 11. Review Method Findings
- Was Balanced Review sufficient?
- Was clean-sheet lens useful?
- Is a separate Constitutional Challenge needed?
- Are narrower follow-up reviews needed?

## 12. Final Verdict
- Preserve as-is
- Preserve with refinements
- Needs bounded architecture revision
- Needs Constitutional Challenge
- Not enough evidence

## 13. Unresolved Blockers
- Blocker
- Evidence needed
- Owner
- Review route
- Revisit trigger
```

For this artifact, “plan” must mean architecture-level posture, acceptance gates, rollback posture, and revisit triggers — not implementation sequencing.

## Prompt Quality Criteria

The prompt library itself should be judged by whether each prompt:

1. Is standalone and copy/paste-ready.
2. Clearly states when to use the review.
3. Forces repo-grounded evidence.
4. Forces Octon Architect to distinguish intent from enforcement.
5. Preserves Octon’s authority model.
6. Prevents generic clean-room redesign.
7. Prevents second-control-plane framing.
8. Separates architecture evaluation from implementation planning.
9. Separates implementation planning from implementation.
10. Produces a clear review artifact.
11. Defines quality criteria for the review result.
12. Defines explicit non-goals.
13. Identifies expected downstream use.

## Final Deliverable

Produce a polished prompt library with one prompt per review type.

Use this structure:

```text
# Octon Architecture Review Prompt Library

## How to Use This Library
- Which prompt to run first
- Which prompts are conditional
- Which prompts are narrower follow-ups
- Which prompts should be run only after Balanced Review findings exist
- Which work should be delegated to cheaper models or implementation agents

## Prompt 1: [Title]
...

## Prompt 2: [Title]
...

[Continue for all review types]
```

Do not run the reviews. Create the prompt library only.

---

# source model response

I’ll turn the method-selection conclusion into a reusable prompt set, with each prompt scoped to a distinct review route and constrained to architecture evaluation rather than implementation.

---

# source model response

# Octon Architecture Review Prompt Library

The prompts below are copy/paste-ready for Octon Architect. They are designed to use Octon’s own Balanced Architecture Review Method, which starts from first principles, restores current-system context, maps current reality, steelmans the current design, applies Chesterton’s Fence, separates essential from accidental complexity, uses clean-sheet design only as a comparison tool, and then produces a realistic target architecture that fits Octon’s governance model. 

The method’s own fit gates are important: durable meaning belongs in authored `framework/**` or `instance/**`; raw inputs, proposal analysis, chat, host state, model memory, dashboards, and generated views are not authority; lifecycle-impacting conclusions require retained evidence; durable changes require validators/tests/fixtures or owned blockers; generated outputs are refreshed only by canonical scripts; and constitutional conflicts route to Constitutional Challenge. 

---

## How to Use This Library

Run **Prompt 1: Octon Authoritative Super-Root Balanced Architecture Review** first. It is the Tier 1 whole-architecture review and already includes a bounded Clean-Sheet lens as a comparison tool. Do not run the standalone Clean-Sheet follow-up first.

Run **Prompt 2: Bounded Clean-Sheet Delta Review** only if Prompt 1 finds unresolved foundational doubts about Octon’s shape: the five-root model, generated/effective handles, mission/run separation, support-target proofing, retained file-native evidence, or excessive compensating complexity.

Use **Prompt 3: Current-State Mechanism Architecture Review** for a current governed mechanism that spans multiple surfaces but is narrower than the whole super-root.

Use **Prompt 4: Architecture Readiness Audit** only after an architecture has already been accepted and the question is whether it is ready for implementation planning. It must not become implementation.

Use **Prompt 5: Domain Architecture Audit** for a bounded domain such as support targets, generated/effective trust, context packing, connector admission, self-evolution, evidence closure, or autonomy.

Use **Prompt 6: Surface Architecture Audit** for one durable surface: a contract, registry, schema family, policy, adapter boundary, generated/effective handle family, evidence root, or read-model family.

Use **Prompt 7: Constitutional Challenge Review** only when a prior review finds a likely conflict with Octon’s constitutional, precedence, authority, fail-closed, or evidence obligations. Octon’s routing taxonomy treats Constitutional Challenge as a separate governance route for proposed architecture that conflicts with those obligations. 

Delegate low-leverage work to cheaper models or implementation agents: file inventories, markdown cleanup, schema formatting, validator implementation, fixture writing, code patches, migration sequencing, changelog drafting, and implementation task breakdowns. Octon Architect should be reserved for architecture judgment, authority-boundary critique, contradiction discovery, method selection, and review-quality assessment.

---

## Prompt 1: Octon Authoritative Super-Root Balanced Architecture Review

```text
You are a senior Octon architecture reviewer, governed-runtime architect, authority-boundary critic, architecture-method reviewer, and clean-sheet comparison analyst.

Repository:
https://github.com/jamesryancooper/octon

Primary method reference:
.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md

Prompt title:
Octon Authoritative Super-Root Balanced Architecture Review

When to use this review:
Use this as the first Tier 1 Octon Architect review for Octon’s authoritative super-root architecture. Use it when the question is whether Octon’s current super-root shape, class-root model, authority topology, runtime boundaries, generated/effective trust model, support posture, evidence model, context/memory model, autonomy posture, and operator/read-model boundaries are still the right architecture for Octon’s intended purpose.

Purpose:
Run Octon’s native Balanced Architecture Review Method against the authoritative super-root architecture. Include a bounded Clean-Sheet lens inside the review as a comparison tool, not as an unconstrained redesign exercise.

Why this deserves Octon Architect-level reasoning:
This review requires deep architectural judgment across authority, runtime, governance, evidence, generated surfaces, support claims, autonomy, and long-term product direction. The risk is not a local bug; the risk is that Octon’s core shape could accidentally create a second control plane, over-distribute authority, preserve stale constraints, overfit to historical compatibility, or make generated/read-model/evidence surfaces authority-adjacent in practice. A weaker model may summarize the repository; Octon Architect should reason about hidden contracts, Chesterton’s Fence, complexity type, bottlenecks, leverage points, failure modes, and whether the current shape should be preserved, refined, or challenged.

Repository and required method references:
- Repository: https://github.com/jamesryancooper/octon
- Required method: .octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md
- Follow the method sequence:
  1. Frame review charter.
  2. Identify fundamental system job.
  3. Map current reality.
  4. Steelman current design.
  5. Apply Chesterton’s Fence.
  6. Separate essential, accidental, compensating, operational, integration, and migration complexity.
  7. Identify stale constraints, valid constraints, hidden contracts, bottlenecks, and leverage points.
  8. Build a bounded clean-sheet reference design as comparison only.
  9. Compare current state against clean-sheet reference.
  10. Produce realistic target architecture that fits Octon’s governance model.
  11. Define architecture-level routing, authority boundaries, evidence requirements, validators, rollback posture, and revisit triggers.
- Treat “plan” as architecture-level posture, acceptance gates, rollback posture, and revisit triggers, not implementation sequencing.

Specific files, directories, or surfaces to inspect:

Core super-root topology and authority model:
- .octon/README.md
- .octon/octon.yml
- .octon/framework/cognition/_meta/architecture/specification.md
- .octon/framework/cognition/_meta/architecture/contract-registry.yml
- .octon/framework/constitution/CHARTER.md
- .octon/framework/constitution/charter.yml
- .octon/framework/constitution/precedence/normative.yml
- .octon/framework/constitution/precedence/epistemic.yml
- .octon/framework/constitution/obligations/fail-closed.yml
- .octon/framework/constitution/obligations/evidence.yml
- .octon/framework/constitution/ownership/roles.yml
- .octon/framework/constitution/contracts/registry.yml

Ingress, bootstrap, and execution-role surfaces:
- .octon/AGENTS.md
- .octon/instance/ingress/AGENTS.md
- .octon/instance/ingress/manifest.yml
- .octon/instance/bootstrap/START.md
- .octon/framework/execution-roles/runtime/orchestrator/ROLE.md
- .octon/framework/execution-roles/governance/MEMORY.md

Runtime control paths:
- .octon/framework/engine/runtime/README.md
- .octon/framework/engine/runtime/spec/execution-authorization-v1.md
- .octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md
- .octon/framework/engine/runtime/spec/material-side-effect-inventory.yml
- .octon/framework/engine/runtime/spec/run-lifecycle-v1.md
- .octon/framework/engine/runtime/spec/run-journal-v1.md
- .octon/framework/engine/runtime/spec/evidence-store-v1.md
- .octon/framework/engine/runtime/spec/context-pack-builder-v1.md
- .octon/framework/engine/runtime/spec/policy-interface-v1.md
- .octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs
- .octon/framework/engine/runtime/crates/authority_engine/src/implementation/**

Generated/effective and read-model boundaries:
- .octon/framework/engine/runtime/spec/runtime-resolution-v1.md
- .octon/instance/governance/runtime-resolution.yml
- .octon/framework/engine/runtime/spec/runtime-effective-artifact-handle-v2.md
- .octon/framework/engine/runtime/spec/publication-freshness-gates-v4.md
- .octon/framework/engine/runtime/spec/compatibility-retirement-cutover-v2.md
- .octon/generated/effective/**
- .octon/generated/cognition/**
- .octon/generated/proposals/**
- .octon/instance/governance/retirement-register.yml

Support, capability, adapter, and proof posture:
- .octon/instance/governance/support-targets.yml
- .octon/instance/governance/support-target-admissions/**
- .octon/instance/governance/support-dossiers/**
- .octon/instance/governance/contracts/support-target-proofing.yml
- .octon/instance/governance/capability-packs/**
- .octon/framework/engine/runtime/adapters/**
- .octon/state/evidence/validation/support-targets/**

Evidence, disclosure, replay, rollback, and operator views:
- .octon/state/control/execution/**
- .octon/state/evidence/runs/**
- .octon/state/evidence/disclosure/**
- .octon/state/evidence/validation/**
- .octon/framework/constitution/contracts/disclosure/**
- .octon/framework/constitution/contracts/retention/**

Mission autonomy, stewardship, and self-evolution:
- .octon/instance/governance/policies/mission-autonomy.yml
- .octon/framework/engine/runtime/spec/continuous-stewardship-runtime-v3.md
- .octon/instance/orchestration/missions/**
- .octon/state/control/execution/missions/**
- .octon/state/continuity/repo/missions/**
- .octon/instance/cognition/decisions/102-self-evolution-proposal-to-promotion-runtime.md
- .octon/state/control/evolution/**
- .octon/state/evidence/evolution/**

External/admission surfaces, only as future-shape stressors:
- .octon/instance/governance/connectors/**
- .octon/state/control/connectors/**
- .octon/state/evidence/connectors/**
- .octon/instance/governance/trust/**
- .octon/state/evidence/trust/**
- browser/API capability pack manifests

Core invariants the review must preserve:
- Octon remains the governing control layer.
- Do not introduce or legitimize a second control plane.
- Authored authority may live only under framework/** and instance/**.
- Mutable control truth lives under state/control/**.
- Retained evidence lives under state/evidence/**.
- Continuity and resumable context live under state/continuity/**.
- generated/** is derived-only and must not mint authority.
- inputs/** is non-authoritative.
- Provider sessions, assistants, raw model responses, generated outputs, generated read models, host UI state, labels, comments, checks, chat transcripts, and model memory are not authority.
- Autonomy remains mission-scoped, reversible, bounded, and auditable.
- Execution remains deny-by-default.
- Evidence, receipts, replay, rollback, disclosure, and auditability are preserved.
- Artifacts remain file-native, inspectable, and portable.
- Separate architecture evaluation from implementation planning.
- Separate implementation planning from actual implementation.
- Do not propose coding tasks prematurely.

Exact repo-grounded questions Octon Architect must answer:
1. What decision is this review supporting: retain current super-root shape, refine it, split or merge surfaces, retire compatibility layers, trigger Constitutional Challenge, or identify insufficient evidence?
2. What is the irreducible job of Octon’s authoritative super-root?
3. How does current Octon distribute authority, mutable control truth, retained evidence, continuity, generated/effective handles, generated read models, and inputs?
4. What is the strongest case for the current five-root model?
5. What is the strongest case for generated/effective handles?
6. What is the strongest case for mission/run separation?
7. What is the strongest case for support-target proofing?
8. What is the strongest case for retained file-native evidence?
9. Which current surfaces look complicated but are necessary under Chesterton’s Fence?
10. Which complexity is essential, accidental, compensating, operational, integration-related, migration-related, or historical?
11. What hidden contracts exist between authority, runtime, generated/effective outputs, evidence, validators, support targets, and operator read models?
12. Which constraints are stale or candidates for retirement?
13. Where does the architecture concentrate too much responsibility?
14. Where can Octon accidentally produce a second control plane?
15. What future product directions stress the current shape: connectors, browser/API packs, external trust, federation, self-evolution, stewardship, support expansion, or product disclosure?
16. What should be preserved, moved, merged, split, renamed, retired, or left alone?
17. Does the realistic target architecture still preserve Octon’s constitutional gates and native authority model?
18. What evidence is missing before making a stronger conclusion?
19. Which follow-up review route, if any, is needed: current-state mechanism review, architecture readiness audit, domain audit, surface audit, or Constitutional Challenge?

Bounded Clean-Sheet lens questions:
Use this lens inside the Balanced Review only. Preserve Octon’s existing purpose and constitutional constraints.
1. If designing from scratch for the same purpose and constraints, would .octon/ still be the single super-root?
2. Would the five class roots still be the right root model?
3. Would authored authority still live only in framework/** and instance/**?
4. Would generated/effective handles exist, or would runtime resolution be modeled differently?
5. Is the split between state/control/**, state/evidence/**, and state/continuity/** necessary and sufficient?
6. Is mission authority correctly separate from run authority?
7. Is support-target proofing the right way to keep claims finite?
8. Is the context-pack model the simplest safe way to provide model-visible context?
9. Are operator read models useful enough to justify their risk?
10. What would a simpler architecture lose in evidence, replay, rollback, auditability, or governance?
11. What would a stricter architecture make impossible or too costly?
12. Which current surfaces are likely compensating mechanisms for missing deeper abstractions?

Required output format:
Produce this exact artifact structure:

# Octon Authoritative Super-Root Balanced Architecture Review

## 1. Review Charter
- Decision under review
- Scope
- Stakeholders
- Risk tolerance
- Time horizon
- Non-goals
- Required outcome

## 2. Fundamental System Job
- What Octon’s super-root must do
- What it must not become
- Core invariants

## 3. Current Reality Map
- Class-root topology
- Authority hierarchy
- Runtime control paths
- Support-target posture
- Evidence/receipt/replay/rollback model
- Generated/effective surfaces
- Operator read-model boundaries
- Continuity and mission autonomy
- Input and proposal boundaries

## 4. Steelman of Current Design
- Strongest case for five roots
- Strongest case for generated/effective handles
- Strongest case for mission/run separation
- Strongest case for support proofing
- Strongest case for file-native evidence

## 5. Chesterton’s Fence Analysis
- Preserve
- Move
- Merge
- Split
- Rename
- Retire
- Leave alone
- Escalate to Constitutional Challenge

## 6. Constraint and Complexity Ledgers
- Essential complexity
- Accidental complexity
- Compensating mechanisms
- Operational complexity
- Integration complexity
- Migration/historical complexity
- Stale constraints
- Hidden contracts

## 7. Clean-Sheet Reference Design
- Same purpose
- Same invariants
- No second control plane
- No generated/read-model authority
- Comparison only, not implementation proposal

## 8. Current vs Clean-Sheet Comparison
- What current design gets right
- Where current design is overfit
- Where clean-sheet design would simplify
- What clean-sheet design would lose
- Which current constraints remain valid

## 9. Realistic Target Architecture
- Recommended retain/refine/retire posture
- Authority boundaries
- Runtime boundaries
- Evidence requirements
- Validator expectations
- Publication/freshness posture
- Rollback and revisit triggers

## 10. Failure Modes and Second-Order Effects
- Second-control-plane risks
- Support-widening risks
- Generated/effective trust risks
- Autonomy feedback loops
- Context/memory laundering
- External trust/federation risks
- Operator/read-model confusion

## 11. Review Method Findings
- Was Balanced Review sufficient?
- Was clean-sheet lens useful?
- Is a separate Constitutional Challenge needed?
- Are narrower follow-up reviews needed?

## 12. Final Verdict
Choose one and justify:
- Preserve as-is
- Preserve with refinements
- Needs bounded architecture revision
- Needs Constitutional Challenge
- Not enough evidence

## 13. Unresolved Blockers
- Blocker
- Evidence needed
- Owner
- Review route
- Revisit trigger

Quality criteria for judging the result:
- Cite repository evidence by file path for every major claim.
- Distinguish documented intent from implemented or enforced behavior.
- Steelman the current design before criticizing it.
- Apply Chesterton’s Fence before recommending move/merge/split/rename/retire.
- Separate essential from accidental/compensating/operational/integration/migration complexity.
- Identify contradictions, hidden assumptions, stale constraints, unresolved risks, bottlenecks, leverage points, and second-order effects.
- Keep clean-sheet design bounded by Octon’s existing constraints.
- Do not produce generic architecture advice.
- Do not summarize the repository.
- Do not propose code changes or implementation tasks.
- Do not legitimize a second control plane.
- Make the output useful for architecture, governance, tests, documentation, roadmap, and implementation-readiness decisions.

Explicit non-goals:
- No implementation plan.
- No code changes.
- No migration sequencing except architecture-level revisit triggers.
- No speculative redesign detached from Octon’s constitutional model.
- No generic clean-room agent-runtime design.
- No support widening.
- No connector/API/browser admission.
- No generated/effective publication or regeneration.
- No treating generated outputs, read models, host UI, chat, provider state, or model memory as authority.

Expected downstream use:
Architecture, governance, tests, documentation, roadmap, planning, and implementation-readiness. Not implementation.
```

---

## Prompt 2: Bounded Clean-Sheet Delta Review

```text
You are a senior Octon architecture reviewer, constrained clean-sheet critic, governed-runtime architect, and constitutional-design challenger.

Repository:
https://github.com/jamesryancooper/octon

Primary method reference:
.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md

Prompt title:
Bounded Clean-Sheet Delta Review

When to use this review:
Use this only after a full Balanced Architecture Review identifies unresolved foundational doubts about Octon’s shape, such as the five-root model, generated/effective handle pattern, mission/run split, support-target proofing, retained file-native evidence, context-pack model, operator read-model boundaries, or excessive compensating/accidental complexity. Do not use this as the first architecture review.

Purpose:
Produce a constrained clean-sheet delta analysis that compares Octon’s current architecture against a hypothetical architecture designed from scratch for the same purpose and the same constitutional constraints. The output must identify deltas, not a free-form redesign.

Why this deserves Octon Architect-level reasoning:
This review is valuable only when the Balanced Review reveals possible foundational overfitting or accumulated compensating complexity. The challenge is to reason from first principles without violating Octon’s core authority model. Octon Architect should expose whether the current super-root shape is necessary, overcomplicated, under-specified, or preserving stale constraints, while avoiding generic agent-platform redesign.

Repository and required method references:
- Repository: https://github.com/jamesryancooper/octon
- Method reference: .octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md
- Required input: findings from the prior Octon Authoritative Super-Root Balanced Architecture Review.
- Treat the clean-sheet design as a comparison tool only, not an implementation proposal.

Specific files, directories, or surfaces to inspect:
- Prior Balanced Review output and unresolved blockers
- .octon/README.md
- .octon/octon.yml
- .octon/framework/cognition/_meta/architecture/specification.md
- .octon/framework/cognition/_meta/architecture/contract-registry.yml
- .octon/framework/constitution/CHARTER.md
- .octon/framework/constitution/precedence/normative.yml
- .octon/framework/constitution/precedence/epistemic.yml
- .octon/framework/constitution/obligations/fail-closed.yml
- .octon/framework/constitution/obligations/evidence.yml
- .octon/framework/engine/runtime/spec/runtime-resolution-v1.md
- .octon/framework/engine/runtime/spec/run-lifecycle-v1.md
- .octon/framework/engine/runtime/spec/run-journal-v1.md
- .octon/framework/engine/runtime/spec/evidence-store-v1.md
- .octon/framework/engine/runtime/spec/context-pack-builder-v1.md
- .octon/instance/governance/support-targets.yml
- .octon/instance/governance/contracts/support-target-proofing.yml
- .octon/generated/effective/**
- .octon/generated/cognition/**
- .octon/state/control/**
- .octon/state/evidence/**
- .octon/state/continuity/**
- .octon/inputs/**

Core invariants the review must preserve:
- Same Octon purpose and constitutional model as the current architecture.
- .octon/ remains a candidate single super-root unless the review explicitly proves why another shape would preserve Octon’s constraints better.
- No second control plane.
- Authored authority may live only under framework/** and instance/**.
- state/control/** remains mutable control truth.
- state/evidence/** remains retained evidence.
- state/continuity/** remains continuity/resumable context.
- generated/** remains derived-only.
- inputs/** remains non-authoritative.
- Provider sessions, assistants, raw model responses, generated outputs, read models, host UI state, labels, comments, checks, chat transcripts, and model memory are not authority.
- Autonomy remains mission-scoped, reversible, bounded, and auditable.
- Execution remains deny-by-default.
- Evidence, receipts, replay, rollback, disclosure, and auditability are preserved.
- Artifacts remain file-native, inspectable, and portable.
- Separate architecture evaluation from implementation planning and implementation.

Exact repo-grounded questions Octon Architect must answer:
1. What foundational doubt from the Balanced Review is this clean-sheet delta addressing?
2. If designing from scratch for the same purpose and constraints, would .octon/ still be the single authoritative super-root?
3. Would the five class roots still be the right root model?
4. Would authored authority still live only in framework/** and instance/**?
5. Would generated/effective handles exist, or would runtime resolution be modeled differently?
6. Is the split between state/control/**, state/evidence/**, and state/continuity/** necessary and sufficient?
7. Is mission authority correctly separate from run authority?
8. Is support-target proofing the right mechanism for finite support claims?
9. Is the context-pack model the simplest safe way to provide model-visible context?
10. Are generated operator read models useful enough to justify their risk?
11. What would a simpler architecture lose in evidence, replay, rollback, disclosure, auditability, portability, or governance?
12. What would a stricter architecture make impossible or too costly?
13. Which current surfaces are likely compensating mechanisms for missing deeper abstractions?
14. Which current surfaces are essential under Chesterton’s Fence?
15. Which deltas are architectural insights versus implementation ideas?
16. Does any clean-sheet alternative create or imply a second control plane?
17. Which deltas should feed back into Balanced Review findings, and which should be rejected?

Required output format:
# Bounded Clean-Sheet Delta Review

## 1. Trigger and Input Findings
- Balanced Review finding that triggered this review
- Foundational doubt being tested
- Scope
- Non-goals

## 2. Same-Purpose Constraint Restatement
- Octon purpose
- Preserved invariants
- Authority model
- Evidence/replay/rollback/auditability requirements
- Non-authority surfaces

## 3. Current Shape Under Test
- Five-root model
- Generated/effective handles
- Mission/run separation
- Support-target proofing
- Retained file-native evidence
- Context-pack model
- Operator read models
- Other surfaces identified by Balanced Review

## 4. Bounded Clean-Sheet Reference
- Minimal shape that satisfies the same constraints
- Authority topology
- Runtime/control topology
- Evidence and replay topology
- Generated/read-model posture
- Support-claim posture
- Autonomy posture
- Why it does not create a second control plane

## 5. Delta Analysis
- Current design vs bounded clean-sheet
- What current design gets right
- What current design overcomplicates
- What clean-sheet simplifies
- What clean-sheet loses
- What current constraints remain valid

## 6. Compensating Mechanism Analysis
- Surface/mechanism
- Current safety role
- Why it exists
- Whether it is essential or compensating
- Risk if removed
- Alternative if any

## 7. Rejected Clean-Sheet Ideas
- Idea
- Why it violates Octon constraints
- Risk introduced

## 8. Architecture-Level Recommendations
- Preserve
- Refine
- Revisit
- Escalate to Constitutional Challenge
- Not enough evidence

## 9. Follow-Up Routing
- Balanced Review update
- Domain audit
- Surface audit
- Architecture readiness audit
- Constitutional Challenge
- No follow-up

Quality criteria for judging the result:
- It must be grounded in the prior Balanced Review findings.
- It must cite repository evidence by file path.
- It must preserve Octon’s constitutional constraints.
- It must reject clean-sheet ideas that create second control planes or generated/read-model authority.
- It must separate architecture deltas from implementation plans.
- It must explain what a simpler design would lose.
- It must identify compensating mechanisms carefully, not casually.
- It must not propose code changes.

Explicit non-goals:
- No unconstrained redesign.
- No generic agent runtime architecture.
- No implementation plan.
- No code changes.
- No migration plan.
- No support widening.
- No new control plane.
- No treating generated/read-model/context/evidence as authority.

Expected downstream use:
Architecture, governance, roadmap, planning, and possible Constitutional Challenge routing. Not implementation.
```

---

## Prompt 3: Current-State Mechanism Architecture Review

```text
You are a senior Octon mechanism reviewer, cross-surface architecture auditor, governed-runtime critic, and evidence-boundary analyst.

Repository:
https://github.com/jamesryancooper/octon

Primary method reference:
.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md

Prompt title:
Current-State Mechanism Architecture Review

When to use this review:
Use this for one current governed mechanism that already exists and spans multiple Octon surfaces, such as generated/effective route-bundle publication, support-target proofing, context pack building, run closeout, connector admission, self-evolution promotion, runtime authorization, run journal lifecycle, or operator read-model publication. This is narrower than a whole-super-root review and broader than a one-file surface audit.

Purpose:
Review one current mechanism across authority, runtime behavior, state ownership, validators, generated projections, retained evidence, recovery, replay, rollback, and operator visibility. Determine whether the mechanism is coherent, governed, bounded, evidence-backed, and aligned with Octon’s super-root constraints.

Why this deserves Octon Architect-level reasoning:
Current mechanisms often cross boundaries: authored authority, mutable state, retained evidence, generated outputs, validators, runtime code, support claims, and operator read models. A weak review may inspect one file; Octon Architect should reason about the full mechanism lifecycle and whether it accidentally creates hidden authority, stale state, support widening, generated-output trust, or recovery gaps.

Repository and required method references:
- Repository: https://github.com/jamesryancooper/octon
- Method reference: .octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md
- Routing reference if relevant: .octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml
- Mechanism under review: [INSERT MECHANISM NAME]
- Mechanism scope: [INSERT BOUNDARIES]
- Known concern or trigger: [INSERT TRIGGER]

Specific files, directories, or surfaces to inspect:
Always inspect:
- .octon/framework/constitution/CHARTER.md
- .octon/framework/constitution/precedence/normative.yml
- .octon/framework/constitution/precedence/epistemic.yml
- .octon/framework/constitution/obligations/fail-closed.yml
- .octon/framework/constitution/obligations/evidence.yml
- .octon/framework/cognition/_meta/architecture/specification.md
- .octon/framework/cognition/_meta/architecture/contract-registry.yml

Also inspect all mechanism-specific surfaces:
- Authoritative contracts: [INSERT PATHS]
- Instance governance/policies: [INSERT PATHS]
- Runtime specs and code: [INSERT PATHS]
- Mutable control roots: [INSERT PATHS]
- Retained evidence roots: [INSERT PATHS]
- Continuity roots: [INSERT PATHS]
- Generated/effective outputs: [INSERT PATHS]
- Generated cognition/read models: [INSERT PATHS]
- Validators/tests/fixtures: [INSERT PATHS]
- Support-target/capability/adapter references: [INSERT PATHS]
- Recovery/replay/rollback surfaces: [INSERT PATHS]

Core invariants the review must preserve:
- Octon remains the governing control layer.
- The mechanism must not create or imply a second control plane.
- Authored authority lives only under framework/** and instance/**.
- state/control/** is mutable control truth, not retained evidence.
- state/evidence/** is retained proof, not live control truth.
- state/continuity/** informs resumption but does not authorize execution.
- generated/** is derived-only and must not mint authority.
- inputs/** is non-authoritative.
- Provider sessions, assistants, raw model responses, generated outputs, generated read models, host UI state, labels, comments, checks, chat transcripts, and model memory are not authority.
- Material execution remains deny-by-default and authorization-bound.
- Evidence, receipts, replay, rollback, disclosure, and auditability must be preserved.
- Architecture evaluation remains separate from implementation planning.

Exact repo-grounded questions Octon Architect must answer:
1. What is the mechanism’s fundamental job?
2. What authority authorizes or constrains the mechanism?
3. What mutable control state does the mechanism own or read?
4. What retained evidence proves the mechanism’s behavior?
5. What generated/effective outputs or read models does the mechanism produce or consume?
6. Are generated outputs used only through permitted resolver/freshness/read-model boundaries?
7. Does the mechanism include any raw input, host UI, chat, provider session, or model-output dependency that could become authority?
8. What validators, tests, fixtures, receipts, or negative controls prove the mechanism?
9. What recovery, replay, rollback, or closeout posture exists?
10. What support-target, capability-pack, adapter, or governance posture does the mechanism depend on?
11. What is the strongest case for the current mechanism shape?
12. What hidden contracts connect the mechanism’s surfaces?
13. Which complexity in the mechanism is essential, accidental, compensating, operational, integration-related, or migration-related?
14. Where can the mechanism produce hidden authority or a second control plane?
15. What stale constraints or compatibility layers should be revisited?
16. What should be preserved, moved, merged, split, renamed, retired, or left alone?
17. Does this mechanism need a surface audit, domain audit, architecture readiness audit, or Constitutional Challenge follow-up?

Required output format:
# Current-State Mechanism Architecture Review: [MECHANISM NAME]

## 1. Review Charter
- Mechanism under review
- Scope
- Non-goals
- Stakeholders
- Risk tolerance
- Required outcome

## 2. Mechanism Job
- Fundamental job
- What it must not become
- Core invariants

## 3. Current Reality Map
- Authority surfaces
- Runtime behavior
- State ownership
- Evidence roots
- Generated/effective outputs
- Operator read models
- Validators/tests/fixtures
- Recovery/replay/rollback posture

## 4. Steelman of Current Mechanism
- Why the current shape exists
- Safety role of current complexity
- What would break if simplified prematurely

## 5. Chesterton’s Fence Analysis
- Preserve
- Move
- Merge
- Split
- Rename
- Retire
- Leave alone
- Escalate

## 6. Hidden Contracts and Complexity Ledger
- Hidden contracts
- Essential complexity
- Accidental complexity
- Compensating mechanisms
- Operational/integration/migration complexity
- Stale constraints

## 7. Failure Modes and Second-Order Effects
- Authority laundering
- Generated-output trust leakage
- Support widening
- Evidence gaps
- Replay/rollback gaps
- Operator/read-model confusion

## 8. Findings and Verdict
- Coherent as-is
- Coherent with architecture refinements
- Needs bounded architecture revision
- Needs domain/surface audit
- Needs Constitutional Challenge
- Not enough evidence

## 9. Acceptance Criteria and Revisit Triggers
- Architecture-level acceptance criteria
- Required evidence
- Required validator depth
- Revisit triggers
- No implementation tasks

Quality criteria for judging the result:
- It must cite repository evidence by file path.
- It must distinguish documented intent from implemented/enforced behavior.
- It must review the mechanism across all relevant surfaces, not one file.
- It must steelman before critique.
- It must apply Chesterton’s Fence.
- It must identify contradictions, hidden assumptions, stale constraints, unresolved risks, bottlenecks, leverage points, and second-order effects.
- It must not propose code changes.
- It must not summarize the repository.

Explicit non-goals:
- No implementation plan.
- No code changes.
- No test writing.
- No migration sequencing.
- No support widening.
- No generated artifact regeneration.
- No second-control-plane framing.

Expected downstream use:
Architecture, governance, tests, documentation, roadmap, planning, and implementation-readiness gating.
```

---

## Prompt 4: Architecture Readiness Audit

```text
You are a senior Octon architecture-readiness auditor, implementation-readiness gate reviewer, governed-runtime planner, and authority/evidence acceptance-criteria critic.

Repository:
https://github.com/jamesryancooper/octon

Primary method reference:
.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md

Prompt title:
Architecture Readiness Audit

When to use this review:
Use this only after an architecture has been accepted or provisionally accepted and the question is whether it is ready for implementation planning. Do not use this to decide the architecture itself, and do not implement anything.

Purpose:
Determine whether an accepted architecture has enough authority clarity, scope boundaries, evidence requirements, validator/test expectations, rollback posture, support posture, generated-output boundaries, and acceptance gates to begin implementation planning safely.

Why this deserves Octon Architect-level reasoning:
Implementation planning before architecture readiness is dangerous in Octon. It can turn ambiguous authority, missing evidence, weak validators, support-widening assumptions, or generated/read-model confusion into code. Octon Architect should judge whether the architecture is ready for implementation planning, not write the plan.

Repository and required method references:
- Repository: https://github.com/jamesryancooper/octon
- Method reference: .octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md
- Routing reference if relevant: .octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml
- Accepted architecture under audit: [INSERT ARCHITECTURE/PROPOSAL/DECISION]
- Prior architecture review artifact: [INSERT PATH OR SUMMARY]
- Accepted decision/ADR/proposal refs: [INSERT PATHS]

Specific files, directories, or surfaces to inspect:
- Prior architecture review output
- Accepted proposal/ADR/decision refs: [INSERT PATHS]
- .octon/framework/constitution/CHARTER.md
- .octon/framework/constitution/precedence/normative.yml
- .octon/framework/constitution/obligations/fail-closed.yml
- .octon/framework/constitution/obligations/evidence.yml
- .octon/framework/cognition/_meta/architecture/contract-registry.yml
- Relevant authoritative contracts: [INSERT PATHS]
- Relevant runtime specs/code entrypoints: [INSERT PATHS]
- Relevant governance/policy/support-target files: [INSERT PATHS]
- Relevant state/control roots: [INSERT PATHS]
- Relevant state/evidence roots: [INSERT PATHS]
- Relevant generated/effective/read-model surfaces: [INSERT PATHS]
- Relevant validators/tests/fixtures: [INSERT PATHS]
- Relevant rollback/replay/disclosure surfaces: [INSERT PATHS]

Core invariants the review must preserve:
- Implementation planning must not begin until architecture acceptance gates are explicit.
- Octon remains the governing control layer.
- No second control plane.
- Authored authority stays under framework/** and instance/**.
- generated/** remains derived-only.
- inputs/** remains non-authoritative.
- state/control/**, state/evidence/**, and state/continuity/** retain separate roles.
- Execution remains deny-by-default.
- Support is not widened without support-target admission and proof.
- Evidence, receipts, replay, rollback, disclosure, and auditability are preserved.
- Implementation planning remains separate from implementation.
- This audit must not produce code or implementation steps beyond readiness categories and gate requirements.

Exact repo-grounded questions Octon Architect must answer:
1. What accepted architecture is being audited for readiness?
2. What decision or review accepted it?
3. Are authority boundaries explicit?
4. Are control/evidence/continuity/generated/input roots correctly assigned?
5. Are generated/effective outputs classified and bounded?
6. Are support-target, capability-pack, adapter, and governance impacts explicit?
7. Are evidence obligations and retained evidence roots specified?
8. Are replay, rollback, disclosure, and auditability requirements specified?
9. Are validators/tests/fixtures/negative controls specified at the right depth?
10. Are failure modes and deny-by-default behavior specified?
11. Are migration, compatibility, retirement, or publication impacts identified?
12. Are human authority artifacts, approvals, exceptions, revocations, or Constitutional Challenge needs resolved?
13. Are open assumptions or unresolved blockers present?
14. Is the architecture ready for implementation planning, not implementation?
15. What must be resolved before implementation planning begins?

Required output format:
# Architecture Readiness Audit: [ARCHITECTURE NAME]

## 1. Audit Charter
- Architecture under audit
- Prior acceptance evidence
- Scope
- Non-goals
- Readiness decision requested

## 2. Architecture Acceptance Summary
- What was accepted
- What was explicitly not accepted
- Known constraints
- Known blockers

## 3. Boundary Readiness Matrix
- Authority boundaries
- Runtime boundaries
- State/control boundaries
- Evidence boundaries
- Continuity boundaries
- Generated/read-model boundaries
- Input boundaries
- Support/capability/adapter boundaries

## 4. Evidence and Validation Readiness
- Required evidence
- Required receipts
- Required validators
- Required tests/fixtures
- Required negative controls
- Claimed validator depth vs needed depth

## 5. Replay, Rollback, Disclosure, and Auditability Readiness
- Replay requirements
- Rollback posture
- Disclosure requirements
- Audit trail requirements
- Closeout requirements

## 6. Governance and Support Readiness
- Support-target posture
- Policy impacts
- Ownership
- Human approval/exception/revocation needs
- Constitutional Challenge needs

## 7. Implementation-Planning Gate
Choose one:
- Ready for implementation planning
- Ready only after listed architecture blockers are resolved
- Not ready; needs additional architecture review
- Needs Constitutional Challenge
- Not enough evidence

## 8. Blockers and Acceptance Criteria
- Blocker
- Required evidence
- Required decision
- Required validator/test/negative control
- Owner if declared
- Revisit trigger

## 9. Explicitly Deferred Implementation Work
- Categories of work that cheaper models or implementation agents may handle after gates pass
- No implementation steps

Quality criteria for judging the result:
- It must cite repository evidence by file path.
- It must distinguish architecture readiness from implementation planning and implementation.
- It must identify blockers and acceptance gates, not tasks.
- It must flag missing authority, evidence, support, validator, rollback, or disclosure posture.
- It must not write code or propose patches.
- It must not accept vague architecture as implementation-ready.

Explicit non-goals:
- No implementation plan.
- No code changes.
- No test writing.
- No migration sequence.
- No support widening.
- No generated publication.
- No architecture redesign except routing back to architecture review if not ready.

Expected downstream use:
Planning, implementation-readiness, governance, tests, documentation, and roadmap. Not implementation.
```

---

## Prompt 5: Domain Architecture Audit

```text
You are a senior Octon domain architecture auditor, governed-runtime reviewer, authority-boundary critic, and cross-surface domain analyst.

Repository:
https://github.com/jamesryancooper/octon

Primary method reference:
.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md

Prompt title:
Domain Architecture Audit

When to use this review:
Use this for a bounded Octon domain that spans multiple mechanisms and durable surfaces, such as:
- support targets and proof executability
- generated/effective trust and publication freshness
- context packing and model-visible integrity
- connector admission and external operations
- self-evolution and promotion/recertification
- evidence closure, replay, rollback, and disclosure
- mission autonomy and stewardship
- policy/ACP and material side-effect authorization

Purpose:
Evaluate whether a bounded Octon domain is architecturally coherent, authority-safe, governed, evidence-backed, validator-covered, support-bounded, generated-output-safe, and ready for either continued operation, narrower mechanism/surface audits, or implementation-readiness review.

Why this deserves Octon Architect-level reasoning:
A domain audit requires cross-surface reasoning without expanding to the whole super-root. It must identify whether the domain’s contracts, policies, runtime paths, evidence roots, generated projections, validators, support posture, and operator surfaces align with Octon’s constitutional model. This is high-leverage when a domain is too broad for a surface audit and too narrow for a full super-root review.

Repository and required method references:
- Repository: https://github.com/jamesryancooper/octon
- Method reference: .octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md
- Domain under review: [INSERT DOMAIN]
- Domain boundary: [INSERT BOUNDARY]
- Review trigger: [INSERT TRIGGER]

Specific files, directories, or surfaces to inspect:
Always inspect:
- .octon/framework/constitution/CHARTER.md
- .octon/framework/constitution/precedence/normative.yml
- .octon/framework/constitution/precedence/epistemic.yml
- .octon/framework/constitution/obligations/fail-closed.yml
- .octon/framework/constitution/obligations/evidence.yml
- .octon/framework/cognition/_meta/architecture/specification.md
- .octon/framework/cognition/_meta/architecture/contract-registry.yml

Domain-specific scope:
- Domain authoritative contracts: [INSERT PATHS]
- Domain governance/policies: [INSERT PATHS]
- Domain runtime specs/code: [INSERT PATHS]
- Domain state/control roots: [INSERT PATHS]
- Domain retained evidence roots: [INSERT PATHS]
- Domain continuity roots: [INSERT PATHS]
- Domain generated/effective outputs: [INSERT PATHS]
- Domain generated read models: [INSERT PATHS]
- Domain support/capability/adapter surfaces: [INSERT PATHS]
- Domain validators/tests/fixtures: [INSERT PATHS]
- Domain disclosure/replay/rollback surfaces: [INSERT PATHS]
- External/admission surfaces if relevant: [INSERT PATHS]

Suggested domain presets:
1. Support domain:
   - .octon/instance/governance/support-targets.yml
   - .octon/instance/governance/support-target-admissions/**
   - .octon/instance/governance/support-dossiers/**
   - .octon/instance/governance/contracts/support-target-proofing.yml
   - .octon/state/evidence/validation/support-targets/**
   - .octon/generated/effective/governance/support-target-matrix.yml
   - .octon/generated/cognition/projections/materialized/support-cards/**
2. Generated/effective trust domain:
   - .octon/framework/engine/runtime/spec/runtime-resolution-v1.md
   - .octon/instance/governance/runtime-resolution.yml
   - .octon/framework/engine/runtime/spec/publication-freshness-gates-v4.md
   - .octon/framework/engine/runtime/spec/compatibility-retirement-cutover-v2.md
   - .octon/generated/effective/**
3. Context/memory domain:
   - .octon/framework/engine/runtime/spec/context-pack-builder-v1.md
   - .octon/framework/execution-roles/governance/MEMORY.md
   - .octon/instance/governance/policies/context-packing.yml
   - .octon/state/evidence/runs/**/context/**
4. Connector/external operation domain:
   - .octon/instance/governance/connectors/**
   - .octon/state/control/connectors/**
   - .octon/state/evidence/connectors/**
   - browser/API capability pack manifests
5. Self-evolution domain:
   - .octon/instance/cognition/decisions/102-self-evolution-proposal-to-promotion-runtime.md
   - .octon/state/control/evolution/**
   - .octon/state/evidence/evolution/**

Core invariants the review must preserve:
- Domain must not create a second control plane.
- Domain authority must remain under framework/** and instance/** where durable.
- Domain control truth, evidence, continuity, generated outputs, and inputs must preserve their class-root roles.
- Generated/read-model surfaces may inform but not authorize.
- Domain support claims must remain admitted, finite, and proof-backed.
- Domain material effects must remain deny-by-default and authorization-bound.
- Domain evidence, receipts, replay, rollback, disclosure, and auditability must be preserved.
- Architecture evaluation remains separate from implementation planning.

Exact repo-grounded questions Octon Architect must answer:
1. What is the domain’s fundamental job?
2. What is the domain boundary, and what is explicitly outside it?
3. What authoritative surfaces define the domain?
4. What runtime paths enforce or consume the domain?
5. What state/control roots represent mutable truth?
6. What evidence roots prove domain behavior?
7. What generated/effective outputs or read models exist, and what are their allowed/forbidden consumers?
8. What support-target, capability-pack, adapter, policy, or governance posture applies?
9. What validators/tests/fixtures/negative controls cover the domain?
10. What recovery, replay, rollback, disclosure, and auditability posture exists?
11. What hidden contracts connect domain surfaces?
12. What complexity is essential, accidental, compensating, operational, integration-related, migration-related, or historical?
13. What stale constraints or compatibility layers exist?
14. What bottlenecks and leverage points exist?
15. Where could this domain accidentally create a second control plane, support widening, generated authority, context laundering, or evidence substitution?
16. Does the domain need mechanism review, surface audit, readiness audit, or Constitutional Challenge follow-up?

Required output format:
# Domain Architecture Audit: [DOMAIN]

## 1. Domain Review Charter
- Domain
- Boundary
- Review trigger
- Non-goals
- Required outcome

## 2. Domain Job and Invariants
- Fundamental job
- What the domain must not become
- Core invariants

## 3. Domain Current Reality Map
- Authority surfaces
- Runtime paths
- Control state
- Evidence roots
- Continuity roots
- Generated/effective outputs
- Generated read models
- Support/capability/adapter posture
- Validators/tests/fixtures
- Replay/rollback/disclosure posture

## 4. Steelman of Current Domain Design
- Why the current shape exists
- Safety role of current complexity
- What current design gets right

## 5. Chesterton’s Fence and Complexity Ledger
- Preserve
- Move
- Merge
- Split
- Rename
- Retire
- Leave alone
- Essential/accidental/compensating/operational/integration/migration complexity
- Stale constraints
- Hidden contracts

## 6. Domain Failure Modes
- Authority leakage
- Runtime bypass
- Generated/read-model authority
- Support widening
- Evidence substitution
- Replay/rollback gaps
- Operator confusion
- Future product stressors

## 7. Findings and Recommended Follow-Up
- Coherent as-is
- Needs bounded refinement
- Needs mechanism review
- Needs surface audit
- Needs architecture readiness audit
- Needs Constitutional Challenge
- Not enough evidence

## 8. Acceptance Criteria and Revisit Triggers
- Criteria
- Required evidence
- Required validator depth
- Revisit triggers
- No implementation tasks

Quality criteria for judging the result:
- Cite repository evidence by file path.
- Distinguish documented intent from enforcement.
- Stay within the domain boundary.
- Identify cross-surface contradictions and hidden contracts.
- Avoid generic advice.
- Avoid implementation planning.
- Avoid second-control-plane framing.

Explicit non-goals:
- No implementation plan.
- No code changes.
- No schema edits.
- No test writing.
- No support widening.
- No generated publication.
- No unrestricted clean-room redesign.

Expected downstream use:
Architecture, governance, tests, documentation, roadmap, planning, and implementation-readiness.
```

---

## Prompt 6: Surface Architecture Audit

```text
You are a senior Octon surface auditor, contract-boundary reviewer, registry critic, schema-family analyst, and authority/evidence classification reviewer.

Repository:
https://github.com/jamesryancooper/octon

Primary method reference:
.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md

Prompt title:
Surface Architecture Audit

When to use this review:
Use this for one durable surface or tightly bounded surface family, such as a contract, registry, schema family, policy, adapter boundary, generated/effective handle family, evidence root, operator read-model family, support dossier family, or runtime spec. This review is narrower than a domain audit.

Purpose:
Evaluate whether a single Octon surface has the correct authority class, ownership, placement, consumers, forbidden consumers, evidence requirements, validation coverage, generated/read-model posture, compatibility posture, and failure behavior.

Why this deserves Octon Architect-level reasoning:
A single surface can quietly become over-authoritative, under-specified, stale, duplicated, or consumed by the wrong runtime path. Octon Architect should reason about the surface’s role in Octon’s broader topology, whether it is source-of-truth or derived, whether it is enforceable, and whether its consumers match its authority posture.

Repository and required method references:
- Repository: https://github.com/jamesryancooper/octon
- Method reference: .octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md
- Surface under review: [INSERT SURFACE PATH OR FAMILY]
- Surface type: [contract | registry | schema family | policy | adapter | generated/effective handle family | evidence root | read model | other]
- Review trigger: [INSERT TRIGGER]

Specific files, directories, or surfaces to inspect:
Always inspect:
- Surface under review: [INSERT PATH]
- .octon/framework/cognition/_meta/architecture/contract-registry.yml
- .octon/framework/cognition/_meta/architecture/specification.md
- .octon/framework/constitution/CHARTER.md
- .octon/framework/constitution/precedence/normative.yml
- .octon/framework/constitution/obligations/fail-closed.yml
- .octon/framework/constitution/obligations/evidence.yml

Also inspect:
- Declared owner/registry entries: [INSERT PATHS]
- Upstream authority sources: [INSERT PATHS]
- Downstream consumers: [INSERT PATHS]
- Forbidden consumers or non-authority declarations: [INSERT PATHS]
- Related schemas/contracts: [INSERT PATHS]
- Validators/tests/fixtures: [INSERT PATHS]
- Evidence roots or receipts: [INSERT PATHS]
- Generated projections/read models: [INSERT PATHS]
- Compatibility or retirement records: [INSERT PATHS]

Core invariants the review must preserve:
- Surface must not become a second control plane.
- Surface authority must match its class-root placement.
- Authored authority must live under framework/** or instance/**.
- state/control/** surfaces are mutable control truth.
- state/evidence/** surfaces are retained proof.
- generated/** surfaces are derived-only.
- inputs/** surfaces are non-authoritative.
- Read models, host UI, labels, comments, checks, chat, model memory, and provider sessions are not authority.
- Consumers must match allowed/forbidden posture.
- Failure behavior must preserve deny-by-default where applicable.
- Architecture evaluation remains separate from implementation planning.

Exact repo-grounded questions Octon Architect must answer:
1. What is the surface’s intended role?
2. What class-root and authority class does it belong to?
3. Is the placement correct under Octon’s topology?
4. Is it source authority, mutable control truth, retained evidence, continuity, generated derived output, compatibility projection, raw input, or navigation/read model?
5. Who owns it?
6. What upstream sources does it depend on?
7. What downstream consumers read it?
8. Are any consumers forbidden or suspicious?
9. Does the surface widen support, policy, runtime, closeout, or authority claims?
10. Are evidence, freshness, receipts, replay, rollback, or disclosure requirements explicit where needed?
11. Are validators/tests/fixtures sufficient for the surface’s claim?
12. Is the surface duplicated, stale, compatibility-only, or superseded?
13. Are there hidden contracts or ambiguous precedence with other surfaces?
14. What should be preserved, moved, merged, split, renamed, retired, or left alone?
15. Does this surface require domain audit, mechanism review, architecture readiness audit, or Constitutional Challenge follow-up?

Required output format:
# Surface Architecture Audit: [SURFACE]

## 1. Surface Review Charter
- Surface
- Surface type
- Scope
- Non-goals
- Review trigger

## 2. Surface Role and Placement
- Intended role
- Class-root placement
- Authority class
- Owner
- Source-of-truth status
- Allowed consumers
- Forbidden consumers

## 3. Dependency and Consumer Map
- Upstream sources
- Downstream consumers
- Generated/read-model projections
- Evidence or receipt dependencies
- Compatibility/retirement links

## 4. Enforcement and Validation
- Documented intent
- Implemented/enforced behavior
- Validators/tests/fixtures
- Evidence requirements
- Failure behavior

## 5. Boundary Risks
- Authority overreach
- Consumer mismatch
- Generated/read-model leakage
- Support widening
- Runtime bypass
- Evidence substitution
- Stale/duplicate/superseded surface risk

## 6. Chesterton’s Fence Findings
- Preserve
- Move
- Merge
- Split
- Rename
- Retire
- Leave alone
- Escalate

## 7. Verdict and Follow-Up
- Surface is correctly placed and bounded
- Surface needs architecture refinement
- Surface needs domain/mechanism review
- Surface needs readiness audit
- Surface needs Constitutional Challenge
- Not enough evidence

## 8. Acceptance Criteria
- Architecture-level criteria
- Required evidence
- Required validator depth
- Revisit triggers
- No implementation tasks

Quality criteria for judging the result:
- Cite repository evidence by file path.
- Distinguish documented intent from enforcement.
- Identify actual and forbidden consumers.
- Judge placement and authority class explicitly.
- Avoid broad domain drift.
- Do not propose code changes.

Explicit non-goals:
- No implementation plan.
- No code changes.
- No schema edits.
- No validator writing.
- No migration plan.
- No support widening.
- No treating generated/read-model surfaces as authority.

Expected downstream use:
Architecture, governance, tests, documentation, planning, and implementation-readiness.
```

---

## Prompt 7: Constitutional Challenge Review

```text
You are a senior Octon constitutional reviewer, authority-precedence auditor, fail-closed/evidence obligation critic, and governance-conflict analyst.

Repository:
https://github.com/jamesryancooper/octon

Primary method reference:
.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md

Prompt title:
Constitutional Challenge Review

When to use this review:
Use this only when a Balanced Architecture Review, Current-State Mechanism Review, Domain Audit, Surface Audit, Architecture Readiness Audit, proposal review, or implementation-readiness audit identifies a possible conflict with Octon’s constitutional, precedence, authority, fail-closed, ownership, evidence, support, generated-output, runtime, disclosure, or autonomy obligations.

Purpose:
Determine whether a proposed architecture, target-state direction, mechanism, surface, or implementation-readiness claim conflicts with Octon’s constitutional regime and whether it must be rejected, revised, escalated to human governance, or treated as a constitutional amendment candidate.

Why this deserves Octon Architect-level reasoning:
Constitutional conflicts are high-risk because they can silently widen authority, create second control planes, convert generated/read-model/input/context/evidence surfaces into authority, weaken deny-by-default execution, bypass support proofing, or undermine auditability. Octon Architect should reason across precedence, authority, fail-closed, evidence, ownership, support, runtime, and disclosure obligations.

Repository and required method references:
- Repository: https://github.com/jamesryancooper/octon
- Method reference: .octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md
- Routing reference: .octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml
- Challenge trigger: [INSERT TRIGGERING REVIEW/FINDING]
- Proposed architecture/surface/mechanism under challenge: [INSERT PATHS OR SUMMARY]

Specific files, directories, or surfaces to inspect:
Always inspect:
- .octon/framework/constitution/CHARTER.md
- .octon/framework/constitution/charter.yml
- .octon/framework/constitution/precedence/normative.yml
- .octon/framework/constitution/precedence/epistemic.yml
- .octon/framework/constitution/obligations/fail-closed.yml
- .octon/framework/constitution/obligations/evidence.yml
- .octon/framework/constitution/ownership/roles.yml
- .octon/framework/constitution/contracts/registry.yml
- .octon/framework/cognition/_meta/architecture/specification.md
- .octon/framework/cognition/_meta/architecture/contract-registry.yml
- .octon/instance/governance/support-targets.yml
- .octon/instance/governance/exclusions/action-classes.yml
- .octon/instance/governance/policies/**
- .octon/instance/governance/contracts/**
- .octon/framework/engine/runtime/spec/execution-authorization-v1.md
- .octon/framework/engine/runtime/spec/evidence-store-v1.md
- .octon/framework/engine/runtime/spec/runtime-resolution-v1.md
- .octon/framework/engine/runtime/spec/publication-freshness-gates-v4.md

Also inspect challenge-specific surfaces:
- Proposed architecture/proposal/ADR: [INSERT PATHS]
- Affected runtime specs/code: [INSERT PATHS]
- Affected support/capability/adapter files: [INSERT PATHS]
- Affected generated/effective/read-model surfaces: [INSERT PATHS]
- Affected evidence/disclosure roots: [INSERT PATHS]
- Affected autonomy/mission/connector/trust surfaces: [INSERT PATHS]

Core invariants the review must preserve:
- The constitutional kernel remains supreme repo-local authority beneath non-waivable external obligations, break-glass controls, and live revocations.
- Octon remains the governing control layer.
- No second control plane.
- Authored authority may live only under framework/** and instance/**.
- state/control/**, state/evidence/**, state/continuity/**, generated/**, and inputs/** preserve their roles.
- Generated outputs, generated read models, raw inputs, host UI state, labels, comments, checks, chat transcripts, provider sessions, assistants, raw model responses, and model memory are not authority.
- Mission-scoped autonomy remains bounded, reversible, and auditable.
- Execution remains deny-by-default.
- Evidence, receipts, replay, rollback, disclosure, and auditability are preserved.
- Constitutional amendments require human governance approval and aligned docs/validator updates.
- Architecture evaluation remains separate from implementation planning.

Exact repo-grounded questions Octon Architect must answer:
1. What specific constitutional conflict or suspected conflict triggered this review?
2. Which constitutional, precedence, authority, fail-closed, evidence, ownership, support, runtime, generated-output, disclosure, or autonomy obligations are implicated?
3. Does the proposed architecture create or legitimize a second control plane?
4. Does it move durable authority outside framework/** or instance/**?
5. Does it allow generated outputs, read models, inputs, host UI, chat, provider state, model memory, or evidence to mint authority?
6. Does it weaken deny-by-default behavior?
7. Does it bypass run contracts, execution authorization, effect-token verification, retained receipts, Run Journal coverage, replay, rollback, or disclosure?
8. Does it widen support claims without support-target admission and proof?
9. Does it let external trust, federation, connectors, browser/API packs, or provider state authorize local execution?
10. Does it confuse mission continuity with run authority?
11. Does it require a constitutional amendment, or can it be revised within existing constitutional constraints?
12. If amendment is needed, what exact constitutional surfaces are implicated?
13. What must be rejected, revised, staged, escalated, or retained as non-authoritative lineage?
14. What evidence is missing before a constitutional decision can be made?

Required output format:
# Constitutional Challenge Review

## 1. Challenge Charter
- Triggering finding
- Proposed architecture/surface/mechanism
- Scope
- Non-goals
- Required decision

## 2. Constitutional Surfaces Implicated
- Charter obligations
- Normative precedence
- Epistemic precedence
- Fail-closed obligations
- Evidence obligations
- Ownership obligations
- Support-target obligations
- Runtime authorization obligations
- Generated-output obligations
- Disclosure/retention obligations
- Autonomy obligations

## 3. Conflict Analysis
For each suspected conflict:
- Conflict statement
- Implicated files
- Evidence
- Severity
- Existing guard
- Why guard is sufficient or insufficient
- Required disposition

## 4. Authority and Control-Plane Risk
- Second-control-plane risk
- Authority relocation risk
- Generated/read-model/input authority risk
- Evidence-as-authority risk
- Host/provider/model authority risk

## 5. Fail-Closed and Evidence Impact
- Deny-by-default impact
- Evidence/receipt impact
- Replay/rollback/disclosure impact
- Support proof impact
- Validator/test/fixture impact

## 6. Disposition
Choose one:
- No constitutional conflict
- Conflict resolved by bounded architecture revision
- Conflict requires staged/non-live treatment
- Conflict requires human governance decision
- Conflict requires constitutional amendment path
- Conflict must be rejected
- Not enough evidence

## 7. Required Conditions Before Proceeding
- Required authority decision
- Required evidence
- Required validator/test/fixture proof
- Required rollback/revisit posture
- Required disclosure
- Required owner
- No implementation tasks

Quality criteria for judging the result:
- Cite repository evidence by file path.
- Identify exact constitutional obligations implicated.
- Distinguish conflict, ambiguity, missing evidence, and implementation-readiness gap.
- Preserve Octon’s constitutional authority model.
- Avoid generic governance advice.
- Do not propose implementation.
- Do not frame any second control plane as acceptable.
- Be explicit about whether amendment is required or avoidable.

Explicit non-goals:
- No implementation plan.
- No code changes.
- No constitutional amendment drafting unless explicitly requested later.
- No migration sequence.
- No support widening.
- No generated publication.
- No treating challenge evidence as approval.

Expected downstream use:
Governance, architecture, documentation, roadmap, planning, and implementation-readiness gating. Not implementation.
```

---

## Final Notes for Using These Prompts

Use Octon Architect only where architectural judgment is scarce and valuable. The best uses are to falsify assumptions, identify hidden authority paths, classify complexity, test method fit, and decide whether architecture is coherent enough for planning.

Do not spend Octon Architect on:

- repository summaries;
- formatting;
- ordinary docs edits;
- schema cleanup;
- fixture generation;
- implementation task decomposition;
- code patching;
- validator implementation;
- generated artifact regeneration.

The strongest workflow is:

1. Run Prompt 1.
2. Route findings to Prompt 2 only if foundational doubts remain.
3. Use Prompts 3, 5, and 6 for narrower findings.
4. Use Prompt 4 only after an architecture is accepted and readiness is the question.
5. Use Prompt 7 only when a constitutional conflict is identified.
6. Delegate mechanical follow-up work to cheaper models or implementation agents after acceptance criteria are clear.

---

# you asked

message time: 2026-07-03 21:49:09

Where should the results of these reviews end up in Octon? Should the output create a proposal program or an intake pack?

---

# source model response

The placement hinges on whether a review result is evidence, a candidate architecture change, or raw intake. I’m checking Octon’s proposal/intake conventions before giving a routing recommendation.

---

# you asked

message time: 2026-07-03 21:49:27

Where should the results of these reviews end up in Octon? Should the output create a proposal program or an intake pack?

---

# source model response

I found that Octon already treats proposal packets as exploratory lineage and review receipts/evidence as retained evidence. That points to a two-lane answer: store the review result as evidence first, and open a proposal program only if the review recommends architecture change.

**Default answer: the review result should become retained evidence first — not a proposal program and not an intake pack.**

A proposal program should be created **only if the review identifies one or more candidate architecture changes that need governed decisioning, packetization, or implementation-readiness work**. An intake pack is the wrong default unless the material is raw/untriaged external input that has not yet been reviewed.

## Recommended routing

| Review outcome | Where it should go | Why |
|---|---|---|
| Review result, findings, risk register, acceptance gates, blocker list | `/.octon/state/evidence/validation/architecture/<review-id>/` | It is retained review evidence. It proves/records analysis but does not itself change authority. Octon separates live control truth from retained evidence; evidence proves/replays/discloses but does not become the live control plane.  |
| Operator-friendly summary of review | Optional `/.octon/generated/cognition/...` read model | Only if useful for navigation. Must be explicitly non-authoritative. Generated cognition is a read model, not authority.  |
| Review finds “preserve as-is” or “not enough evidence” | Evidence only | No proposal program. Store the review and maybe open a follow-up review route/blocker list. |
| Review finds bounded architecture changes | Create proposal packet/program under `/.octon/inputs/exploratory/proposals/architecture/<slug>/` | Proposal packets belong under `inputs/exploratory/proposals/**` and remain lineage-only; generated proposal discovery is non-authoritative.  |
| Review finds constitutional conflict | Retained evidence + Constitutional Challenge route | Octon’s review routing has a separate `constitutional-challenge` route for architecture that conflicts with constitutional, precedence, authority, fail-closed, or evidence obligations.  |
| Raw Octon Architect output before triage/classification | Temporary intake-like holding area only if needed | Treat as non-authoritative raw input until classified. Inputs are non-authoritative by design.  |

## Practical placement convention

For the **Balanced Architecture Review of the super-root**, I would use:

```text
.octon/state/evidence/validation/architecture/super-root-balanced-review/<review-id>/
  review.md
  evidence-index.yml
  source-manifest.yml
  risk-register.yml
  acceptance-gates.yml
  follow-up-routing.yml
  unresolved-blockers.yml
  method-receipt.yml
```

For narrower reviews:

```text
.octon/state/evidence/validation/architecture/reviews/<review-type>/<review-id>/
```

Examples:

```text
.octon/state/evidence/validation/architecture/reviews/domain/generated-effective-trust-2026-07-03/
.octon/state/evidence/validation/architecture/reviews/surface/runtime-resolution-v1-2026-07-03/
.octon/state/evidence/validation/architecture/reviews/mechanism/context-pack-builder-2026-07-03/
```

If the result is used in a run, also link it from the run evidence root, but do not make run-local evidence the only copy. Octon already treats architecture validation/closure evidence as retained validation evidence, and the architecture-health contract places closure certificates under `state/evidence/validation/architecture/.../closure/**`. 

## When to create a proposal program

Create a proposal program only when the review output contains **actionable architecture change candidates** that require decisioning across multiple artifacts.

Create one if the review says things like:

- “Needs bounded architecture revision.”
- “Split/merge/retire these surfaces.”
- “Generated/effective trust model needs a new contract.”
- “Support-target proofing needs a new proof regime.”
- “This requires validator, schema, runtime, evidence, and documentation changes.”
- “This may require Constitutional Challenge or governance approval.”

Then the review evidence should be referenced by the proposal, not moved into the proposal as authority:

```text
.octon/inputs/exploratory/proposals/architecture/<proposal-slug>/
  proposal.yml
  architecture-proposal.yml
  README.md
  architecture/
    target-architecture.md
    decision-context.md
    acceptance-criteria.md
  resources/
    source-review-ref.md
    risk-register.md
    evidence-map.md
  support/
    proposal-review.md
```

If it becomes a multi-child effort, the proposal program’s generated/non-authoritative program artifacts can live under:

```text
.octon/generated/proposals/artifacts/architecture/<proposal-slug>/
  proposal-program-spine.yml
  proposal-artifact-index.yml
  child-handoff-capsule.yml
```

But those generated proposal artifacts must remain discovery/navigation only, not authority.

## When to create an intake pack

Use an intake pack only for **unreviewed, untrusted, raw incoming material**. For example:

- pasted Octon Architect output before classification;
- external research notes;
- raw transcripts;
- unsorted architectural ideas;
- third-party framework comparisons;
- imported review material that has not been normalized into retained evidence.

Do **not** use intake as the final destination for a completed Octon Architect review. Once reviewed, classified, and source-bound, it should become retained evidence.

A good intake pattern would be:

```text
.octon/inputs/exploratory/architecture-reviews/<review-id>/
  raw-octon-architect-output.md
  source-prompt.md
  operator-notes.md
  intake-manifest.yml
```

Then, after classification:

```text
.octon/state/evidence/validation/architecture/reviews/<review-id>/
```

## Recommended rule

Use this decision rule:

```text
Raw / untriaged material         → inputs/exploratory/** intake
Completed review finding        → state/evidence/validation/architecture/**
Candidate architecture change   → inputs/exploratory/proposals/architecture/**
Generated proposal navigation   → generated/proposals/**
Accepted durable authority      → framework/** or instance/** only, after governance
Runtime/control truth           → state/control/**
Operator summary/read model     → generated/cognition/**, non-authoritative
```

So for these Octon Architect reviews: **store the review outputs as retained architecture evidence first. Create a proposal program only when the review recommends actual architecture change. Use intake only as a temporary raw-input envelope, not as the final review home.**

---

# you asked

message time: 2026-07-03 22:00:19

Create an amendment that can be appended to each prompt that outlines how to output review results.

---

# source model response

Append this amendment to the end of each Octon Architect review prompt.

**Document Title: **

## Review Result Output and Artifact Placement Amendment

In addition to the review-specific output requested above, include a final section titled:

```text
## Review Result Routing and Artifact Placement
```

This section must determine where the review result should live in Octon and whether it should remain retained evidence, open a proposal packet/program, trigger a Constitutional Challenge, or remain temporary raw intake.

### Placement Principles

Preserve Octon’s class-root and authority model:

- Completed review findings are **retained evidence**, not authority.
- Review findings must not mutate authority, runtime state, support claims, generated outputs, or implementation plans by themselves.
- Proposal packets/programs are **lineage-only candidate decision artifacts**, not authority.
- Intake packs are for **raw, unreviewed, untrusted, or unclassified material**, not the final home of a completed review.
- Generated proposal artifacts and generated cognition/read models are **navigation/read-model surfaces only** and must not become authority.
- Durable authority may be created or changed only through the proper governed route and only under `framework/**` or `instance/**`.

### Required Routing Decision

Classify the review result into exactly one primary routing outcome:

1. **Evidence-only review result**
   - Use when the review records findings, risks, blockers, acceptance criteria, or “preserve as-is / not enough evidence” conclusions.
   - Recommended destination:

   ```text
   .octon/state/evidence/validation/architecture/reviews/<review-type>/<review-id>/
   ```

2. **Architecture change candidate**
   - Use when the review recommends a bounded architecture revision, surface split/merge/retirement, new or revised contract, validator regime, support-proof change, generated/effective trust change, or governance change.
   - Recommended retained review evidence destination:

   ```text
   .octon/state/evidence/validation/architecture/reviews/<review-type>/<review-id>/
   ```

   - Recommended proposal destination, if packetization is justified:

   ```text
   .octon/inputs/exploratory/proposals/architecture/<proposal-slug>/
   ```

   - The proposal must cite the retained review evidence by path. Do not move the review result into the proposal as authority.

3. **Proposal program candidate**
   - Use only when the review identifies a multi-part architecture change requiring multiple child packets, staged decisioning, cross-surface governance, or coordinated follow-up reviews.
   - Recommended proposal destination:

   ```text
   .octon/inputs/exploratory/proposals/architecture/<program-slug>/
   ```

   - Optional generated proposal navigation, if later created by the proper route:

   ```text
   .octon/generated/proposals/artifacts/architecture/<program-slug>/
   ```

   - Generated proposal artifacts must remain non-authoritative navigation/read-model outputs.

4. **Constitutional Challenge candidate**
   - Use when the review identifies a likely conflict with Octon’s constitutional, precedence, authority, fail-closed, ownership, support, generated-output, evidence, disclosure, or autonomy obligations.
   - Recommended retained review evidence destination:

   ```text
   .octon/state/evidence/validation/architecture/reviews/constitutional-challenge-candidates/<review-id>/
   ```

   - Recommended follow-up route:

   ```text
   Constitutional Challenge Review
   ```

   - Do not draft or apply a constitutional amendment unless explicitly requested later.

5. **Raw intake only**
   - Use only when the material is unreviewed, untrusted, externally supplied, incomplete, or not yet classified.
   - Recommended temporary destination:

   ```text
   .octon/inputs/exploratory/architecture-reviews/<intake-id>/
   ```

   - This is temporary raw intake. Once reviewed and classified, the result should be promoted into retained evidence or routed to a proposal/constitutional review path as appropriate.

### Required Artifact Placement Section

In the final review output, include this structure:

```text
## Review Result Routing and Artifact Placement

### Primary Classification
Choose one:
- Evidence-only review result
- Architecture change candidate
- Proposal program candidate
- Constitutional Challenge candidate
- Raw intake only

### Recommended Primary Destination
Path:
Reason:

### Secondary/Linked Destinations
- Proposal packet needed: yes/no
- Proposal program needed: yes/no
- Constitutional Challenge needed: yes/no
- Generated navigation/read model useful: yes/no
- Raw intake needed: yes/no

### Required Files for Retained Review Evidence
Recommend a file-native evidence bundle such as:

- review.md
- evidence-index.yml
- source-manifest.yml
- risk-register.yml
- acceptance-gates.yml
- follow-up-routing.yml
- unresolved-blockers.yml
- method-receipt.yml

For specialized reviews, add relevant files, such as:

- authority-boundary-map.yml
- generated-effective-risk-register.yml
- support-proof-gap-map.yml
- validator-depth-matrix.yml
- constitutional-conflict-map.yml
- clean-sheet-delta.md
- readiness-gate.yml

### Proposal Packet or Program Trigger
Explain whether the review result justifies creating:

- no proposal;
- a single architecture proposal packet;
- a proposal program with multiple child packets;
- a Constitutional Challenge route.

Do not create the proposal itself unless explicitly requested in a later task.

### Authority and Non-Authority Statement
State explicitly:

- This review result is retained evidence only.
- It does not create authority.
- It does not change support claims.
- It does not authorize implementation.
- It does not mutate runtime/control truth.
- It does not publish generated/effective outputs.
- It does not approve constitutional, governance, support, connector, autonomy, or runtime changes.
- Any later authority change must occur through the proper governed Octon route.

### Follow-Up Routing
List recommended follow-up review or planning routes, if any:

- No follow-up
- Surface Architecture Audit
- Domain Architecture Audit
- Current-State Mechanism Architecture Review
- Architecture Readiness Audit
- Bounded Clean-Sheet Delta Review
- Constitutional Challenge Review
- Proposal packet creation
- Proposal program creation
- Cheaper-model mechanical follow-up
- Implementation agent follow-up only after architecture and planning gates pass

### Delegation Guidance
Identify which follow-up work should be delegated to cheaper models or implementation agents, such as:

- file inventories;
- documentation cleanup;
- schema formatting;
- validator implementation;
- fixture generation;
- implementation task breakdown;
- changelog drafting;
- generated navigation updates.

Do not spend Octon Architect reasoning on these unless they become architecture-critical.

### Blockers Before Implementation Planning
List any blockers that must be resolved before implementation planning begins:

- missing authority decision;
- unresolved ownership;
- missing retained evidence;
- missing support proof;
- missing validator depth;
- missing negative controls;
- missing rollback posture;
- generated-output authority ambiguity;
- constitutional conflict;
- unclear proposal/program boundary;
- insufficient repo evidence.

### Final Routing Verdict
Choose one:

- Retain as review evidence only.
- Retain as evidence and open a single architecture proposal packet.
- Retain as evidence and open a proposal program.
- Retain as evidence and trigger Constitutional Challenge Review.
- Keep as raw intake until classified.
- Not enough information to route safely.
```

### Non-Goals for This Amendment

Do not:

- create files;
- create a proposal packet;
- create a proposal program;
- create an intake pack;
- write implementation tasks;
- modify authority;
- modify runtime/control truth;
- publish generated artifacts;
- widen support;
- approve any change.

This amendment defines where the review result should go and what downstream route it should trigger. It does not execute that route.

---

# you asked

message time: 2026-07-03 22:27:40

Create a downloadable archive with all the prompt files appending the Review Result Output and Artifact Placement Amendment to each prompt.

---

# source model response

I’ll package the seven review-route prompts from the latest library as individual Markdown files, append the routing amendment to each one, and include a README plus the amendment as a standalone reference.

Created the archive with all seven prompt files, each with the Review Result Output and Artifact Placement Amendment appended.

[Download the Octon prompt library archive](sandbox:/mnt/data/octon-architecture-review-prompt-library-with-routing-amendment.zip)
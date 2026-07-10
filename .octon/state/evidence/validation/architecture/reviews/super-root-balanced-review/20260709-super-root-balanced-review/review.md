# Octon Authoritative Super-Root Balanced Architecture Review

Review id: `20260709-super-root-balanced-review` — persona: Octon Architect — model actually used: claude-fable-5 — repo `main` @ `eff350fcfec641e59665e74544f104f2e5bc6a4d` — method: `.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md` (11-step sequence followed).

Epistemic labels used throughout: **[E]** repository evidence (cited), **[I]** inference from evidence, **[U]** uncertainty, **[R]** recommendation.

## 1. Review Charter

- **Decision under review:** whether Octon's current super-root shape — five class roots, authority topology, generated/effective handle model, mission/run separation, support-target proofing, retained file-native evidence, context/memory model, autonomy posture, operator/read-model boundaries — should be preserved, refined, revised, or constitutionally challenged.
- **Scope:** whole `.octon/` super-root at the recorded commit. Architecture evaluation only.
- **Stakeholders:** operator/human governance (`.octon/framework/constitution/ownership/roles.yml:4-32`), harness enforcement plane (`roles.yml:33-57`), model execution plane (`roles.yml:58-78`).
- **Risk tolerance:** low for authority boundaries and fail-closed behavior; moderate for documentation/index debt.
- **Time horizon:** current shape plus the declared future stressors (connectors, browser/API packs, federation, self-evolution).
- **Non-goals:** no implementation plan, no code changes, no migration sequencing, no support widening, no generated publication, no proposal creation.
- **Required outcome:** one verdict, routed findings, and a placement decision under the appended amendment.

## 2. Fundamental System Job

**[E]** Octon's declared job: "a Constitutional Engineering Harness for controlled autonomy: agents get governed room to work only inside admitted, evidenced, reviewable boundaries" (`.octon/README.md:7-9`); execution core is "a Governed Agent Runtime… deterministic enough to trust, observable enough to debug, bounded enough to govern, and flexible enough to evolve" (`.octon/framework/constitution/CHARTER.md:24-26`).

**[I]** The irreducible job reduces to four guarantees: (1) exactly one control plane authorizes material effects; (2) every consequential action is deny-by-default, evidence-producing, replayable, and reversible or compensable; (3) every live claim is finite, admitted, and executable-proof-backed; (4) derived surfaces (generated, inputs, host, chat, memory) can inform but never authorize.

**What it must not become:** a generic agent platform with implicit capability growth; a system where generated projections, host state, or continuity records mint authority; an unbounded support claim.

**Core invariants:** the prompt's invariant list (source-prompt.md, "Core invariants") is confirmed as the correct live invariant set — each item traces to an active constitutional surface (charter non-negotiables `CHARTER.md:48-83`; FCR-001/002/003/026/032/033/038 in `obligations/fail-closed.yml`; structural invariants 1-16 in `_meta/architecture/specification.md:137-176`).

## 3. Current Reality Map

- **Class-root topology [E]:** five roots declared in `.octon/octon.yml:2-9` and `.octon/README.md:29-41`; ten steady-state surface classes with authority postures in `specification.md:49-68`; machine registry `contract-registry.yml` (2,003 lines, schema `architecture-contract-registry-v2`, 78 validator bindings, 43 forbidden-consumer declarations).
- **Authority hierarchy [E]:** 12-rank normative precedence (`precedence/normative.yml`): external obligations → constitutional kernel → repo governance → run-specific human authority artifacts (approvals/exceptions/revocations, rank 4) → workspace charter → mission charter → run contract (rank 7) → stage attempts → run lifecycle → capability/adapter contracts (narrow-only, rank 10) → structural specs → informative context (rank 12, never mints authority). 9-rank epistemic precedence with retained evidence > validators > worktree > control > fresh generated > continuity > docs > chat > model priors (`precedence/epistemic.yml`).
- **Runtime control paths [E]:** deny-by-default is enforced in Rust, not just specified: `verify_authorized_effect<T>` rejects any grant whose decision ≠ ALLOW (`crates/authority_engine/src/implementation/effects.rs:229-236`), plus kind/request-id/grant-id/run-id/token-record/token-digest/support-tuple mismatch rejections (`effects.rs:238-306,388-398`). `runtime_bus` is the single journal append path with hash-linked events and rejection of `generated/**` and `inputs/**` lifecycle refs (`crates/runtime_bus/src/lib.rs:329-400`; `spec/run-journal-v1.md:24-36`). Run lifecycle: 12 states, all transitions fail closed on missing authority/evidence/rollback/visibility facts (`spec/run-lifecycle-v1.md:62-123`).
- **Support-target posture [E]:** finite universe — 6 admitted tuples (4 live, 2 stage-only, 1 retired), `default_route: deny` (`instance/governance/support-targets.yml:3`); executable-or-replayable proof mandatory, "metadata-only or summary-only proof is insufficient" (`instance/governance/contracts/support-target-proofing.yml:59-60`); all 4 live tuples carry current passing proof bundles under `state/evidence/validation/support-targets/`; envelope reconciliation status `reconciled` with zero diagnostics (`generated/effective/governance/support-envelope-reconciliation.yml:2,124-184`).
- **Evidence/receipt/replay/rollback model [E]:** 34 active evidence obligations (`obligations/evidence.yml`), 38 fail-closed rules (`obligations/fail-closed.yml`); evidence store contract separates mutable control from retained proof (`spec/evidence-store-v1.md:33-48`); ~1,085 RunCards retained under `state/evidence/disclosure/`; 1,160 publication receipts under `state/evidence/validation/publication/`; replay defaults to dry-run, live replay requires fresh authorization (`spec/run-journal-v1.md:141-148`).
- **Generated/effective surfaces [E]:** six handle families declared in `instance/governance/runtime-resolution.yml:42-74`; all locks carry `allowed_consumers: [runtime_resolver, validators]`, `forbidden_consumers: [direct_runtime_raw_path_read, generated_cognition_as_authority]`, `non_authority_classification: derived-runtime-handle`, `freshness.mode: digest_bound` (`generated/effective/runtime/route-bundle.lock.yml:20-35`); publication is script-only (three `publish-*.sh` wrappers); raw runtime reads are blocked by a negative-control validator (`validate-no-raw-generated-effective-runtime-reads.sh`).
- **Operator read-model boundaries [E]:** `generated/cognition/**` marked `derived-non-authority` in `instance/governance/non-authority-register.yml:66-94`; listed under `forbidden_runtime_authority_roots` (`runtime-resolution.yml:32-35`); FCR-032 denies read-model consumption as runtime/policy/support/authority input.
- **Continuity and mission autonomy [E]:** continuity informs resumption only — "Continuation Decisions are evidence-bearing mission control decisions, not execution approvals" (`spec/mission-continuation-v1.md:21`); mission autonomy is class-scoped with burn states, circuit breakers, and proceed-on-silence restricted to reversible/compensable classes (`instance/governance/policies/mission-autonomy.yml:91-145`).
- **Input and proposal boundaries [E]:** `inputs/**` non-authoritative with envelope-bounded intake (`inputs/README.md`); proposals lineage-only (`specification.md:175-176`); ideation human-led (`octon.yml:70-72`).

## 4. Steelman of Current Design

- **Five roots [E→I]:** the root split is not taxonomy for its own sake — each root carries a distinct trust operation: `framework/instance` = authored authority (amendable only by governed route), `state/control` = current truth (mutable, precedence rank 4-9), `state/evidence` = append-oriented proof (epistemic rank 1), `generated` = rebuildable (commit/rebuild policy per family, `octon.yml:63-69`), `inputs` = quarantine. Collapsing any pair destroys a needed distinction: merging control+evidence lets current state overwrite proof; merging generated+authored invites laundering. FCR-001/002 exist precisely at these seams.
- **Generated/effective handles [E→I]:** raw derived files cannot carry trust; the handle model attaches trust conditions (digest-bound freshness, publication receipt, consumer allowlist, non-authority classification) to every runtime-facing derived artifact, with a negative-control validator proving raw reads stay denied (EVI-025). FCR-031 explicitly de-authorized the earlier fake far-future `fresh_until` pattern — evidence the model was hardened from a real failure, not designed speculatively.
- **Mission/run separation [E→I]:** long-horizon continuity (missions, rank 6) never collapses into atomic execution authority (run contracts, rank 7). Stewardship v3 sits above both and is barred from executing material work (`spec/continuous-stewardship-runtime-v3.md:11-14`). This triple layering is what makes proceed-on-silence autonomy safe to offer at all.
- **Support-target proofing [E→I]:** the tuple universe converts "what does this system support?" from prose into an enumerable, provable, reconcilable set. The generated matrix may narrow but not widen (`support-targets.yml:21`), and reconciliation fails closed on widening (`validate-support-envelope-reconciliation.sh:211-216`). This is the strongest anti-overclaim mechanism in the repository.
- **Retained file-native evidence [E→I]:** file-native receipts make the harness portable, diffable, and auditable without external services; epistemic precedence rank 1 gives evidence teeth against stale docs. 34 EVI obligations tie every consequential behavior to a retained artifact.

## 5. Chesterton's Fence Analysis

- **Preserve:** five class roots; normative/epistemic precedence pair; run contract as atomic execution authority; effect-token verification chain; runtime_bus single-writer journal; support-tuple universe and executable proofing; handle/freshness/receipt model; non-authority register; deny-until connector doctrine; trust v6 "federate proof, not authority."
- **Move:** nothing warrants relocation at architecture level.
- **Merge:** none — apparent duplication (support matrix appearing both standalone and as route-bundle dependency) is recursive dependency closure, not duplication (`route-bundle.lock.yml:52-57`).
- **Split:** none required.
- **Rename:** none — terminology is registry-governed (`naming-constitution.md` referenced from `CHARTER.md:131-132`).
- **Retire:** (a) overdue-review compatibility surfaces once their reviews run (7 of 8 retirement-register entries have `next_review_due: "2026-06-30"`, already past at run date 2026-07-09 — `instance/governance/retirement-register.yml:19,33,48,61,74,97,127`); (b) evidence-classification v1 Class A/B/C records without proof-plane arrays, via migration to v2.
- **Leave alone:** the 201-file spec directory's retained version lineage — active versions are declared centrally (`octon.yml:82-108` `runtime_contract_refs` + `historical_lineage`; `specification.md:70-79`); the lineage is governed history, not dead weight, though it earns an index (Section 12, F-05).
- **Escalate to Constitutional Challenge:** none required. The strongest candidate (F-01, ambient env overrides vs FCR-025) is resolvable within existing constitutional constraints by declaring the override a governed break-glass affordance (rank-1 slot already exists in `precedence/normative.yml:11-18`) or removing it — see Section 12.

## 6. Constraint and Complexity Ledgers

- **Essential complexity:** authority precedence layering; effect-token lifecycle; digest-bound freshness; per-tuple executable proofing; evidence classification tiers. These are irreducible given the four guarantees in Section 2.
- **Accidental complexity:** spec-directory sprawl without a local index (201 files, up to 4 retained generations per contract family — `ls spec/` census) **[E]**; dual evidence-classification schemas (v1 A/B/C and v2 proof-plane) coexisting **[E]**.
- **Compensating mechanisms (each requires owner + retirement trigger per `CHARTER.md:61-62`):** (a) compatibility projections in the retirement register — governed, but review cadence lapsed **[E]**; (b) `OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE` publication-bootstrap bypass — compensates for the chicken-and-egg of publishing a route bundle while the bundle is stale (`kernel/src/commands/mod.rs:1111-1114` sets it for `route_bundle_bypass` publications), **currently lacks a declared owner, contract, and retirement trigger — the one compensating mechanism that violates the charter's own rule [E→I]**; (c) repo-root `AGENTS.md`/`CLAUDE.md` ingress shims — governed (`retirement-register.yml:10-14`).
- **Operational complexity:** 331 validator scripts; quarterly recertification cadences; publication wrappers. Proportionate to the guarantee set **[I]**.
- **Integration complexity:** GitHub/CI projections kept non-authoritative via FCR-003 plus alignment validators (`validate-github-projection-alignment.sh` et al.) **[E]**.
- **Migration/historical complexity:** wave lineage confined to ADRs/evidence per `README.md:115-120`; historical evidence alias de-authorized by FCR-036 **[E]**.
- **Stale constraints:** the far-future-freshness and legacy `fresh_until` patterns are already retired (FCR-031) — a previously live tension seed now closed **[E]**. The overdue retirement-register reviews are the only currently-lapsed governance clock found **[E]**.
- **Hidden contracts:** (a) ambient process environment as an input to authority decisions (F-01) — the only material hidden contract found; (b) `stage_only_behavior: Option<AcpStageOnlyBehavior>` config field in `policy_engine/src/lib.rs:195` absent from `policy-interface-v1.md` (F-02); (c) the `immutable://` external evidence store's operational contract (F-03).

## 7. Clean-Sheet Reference Design (comparison only)

Designing from scratch for the same purpose and constitutional constraints **[I]**:

1. `.octon/` as single super-root: **retained.** A single quarantineable root is the only shape that keeps a portable harness's authority boundary auditable inside a host repository.
2. Five class roots: **retained.** A clean sheet reaches the same five by walking trust operations (author / mutate / prove / derive / quarantine). A minimal design might merge `state/continuity` into `state/control`; the current split is justified because continuity is deliberately *weaker* than control (epistemic rank 6 vs 4) — merging would silently upgrade resumption hints into current truth.
3. Authored authority only in `framework/instance`: **retained.**
4. Generated/effective handles: **retained**, with the observation that a clean sheet would put resolver-verification in exactly one code path — which the current design already does (`runtime_resolver` + raw-read negative control).
5. Control/evidence/continuity split: **necessary and sufficient.** No missing sixth root; engagement/objective candidate state correctly lands under `state/control/engagements/` (`specification.md:111-114`).
6. Mission vs run authority: **retained** as separate ranks; a clean sheet confirms the run contract must stay the *only* atomic execution authority.
7. Support-target proofing: **retained**; the clean sheet has no cheaper mechanism that keeps claims finite *and* falsifiable.
8. Context-pack model: **retained.** Simplest safe alternative (ad-hoc prompt assembly with logging) loses the pre-authorization hash binding that makes model-visible context replayable and non-launderable (`spec/context-pack-builder-v1.md:261-286,308-330`).
9. Operator read models: **worth their risk** — they are the pressure-release that keeps humans from reading control/evidence roots directly and mistaking them for dashboards; risk is contained by FCR-021/032 and the non-authority register.
10. **What a simpler architecture loses:** replayability from retained evidence alone, provable non-widening of support claims, and the ability to say "no" mechanically (deny-by-default with reason codes). **What a stricter one costs:** removing compatibility projections and the publication bypass would break migration ergonomics and route-bundle bootstrap; removing proceed-on-silence would make long-horizon missions operator-bound.
11. **No clean-sheet alternative surfaced that creates a second control plane advantageously.** The clean sheet's one genuine improvement over current state: ambient-environment inputs to authority decisions would be forbidden by construction and replaced with explicit, receipted break-glass artifacts (feeds F-01).

## 8. Current vs Clean-Sheet Comparison

- **Current design gets right:** enforcement-in-code (not spec-only) at every authority seam checked; single journal writer; digest-bound trust; finite proof-backed support; non-authority classifications on every derived family; self-approval impossibility in evolution (`kernel/src/commands/evolution.rs:197-633`, six explicit blockers).
- **Where current is overfit:** retained multi-generation spec lineage in the active spec directory (history where an index should stand); dual evidence-classification schemas.
- **Where clean sheet simplifies:** explicit break-glass artifact instead of env-var bypass; one evidence-classification schema; spec index.
- **What clean sheet would lose:** governed compatibility bridges that make real migrations survivable; the retained lineage that lets FCR-036-style de-authorizations be verified.
- **Constraints that remain valid:** every core invariant in Section 2; all 38 FCR rules; the narrow-only rule for capability/adapter contracts.

## 9. Realistic Target Architecture

**Posture: preserve with refinements** — the current super-root shape *is* the target architecture. Refinements (architecture-level, no implementation sequencing):

- **Authority boundaries:** unchanged, plus: declare ambient-environment overrides as a governed surface — either a contracted break-glass affordance with mandatory retained receipts, or removed in favor of explicit flags on the publication path only (F-01, F-02).
- **Runtime boundaries:** unchanged.
- **Evidence requirements:** add an operational contract for the `immutable://` store (authority, backup, verification) (F-03); complete v1→v2 evidence-classification migration (F-09); define retention-duration enforcement or explicitly declare durations policy-only (F-06).
- **Validator expectations:** add a negative control proving authority decisions are invariant under unauthorized env-var settings in protected modes; add a pre-resumption continuity-coherence check (F-07); add retroactive RunCard support-ref audit or declare historical RunCards frozen-as-of-issuance (F-08).
- **Publication/freshness posture:** unchanged (digest-bound model confirmed sound).
- **Rollback and revisit triggers:** run the overdue retirement-register reviews (F-04); revisit quorum default (currently 1, `quorum-policies/default.yml:6`) upon any multi-operator adoption (F-10); revisit this whole review upon connector live admission, browser/API pack admission, first federation compact, or first self-evolution promotion touching constitutional surfaces.

## 10. Failure Modes and Second-Order Effects

- **Second-control-plane risks [E→I]:** the designed surfaces are clean — all material paths converge on `authorize_execution()` + `runtime_bus`; no shadow admission or shadow journal found. The residual vector is ambient: process environment altering policy mode, execution role, intent, or bundle-freshness enforcement (F-01). Second-order: an inherited CI environment or operator shell profile could silently weaken enforcement in ways receipts only partially disclose.
- **Support-widening risks [E]:** blocked at four layers (deny-default universe, admission gating, matrix widening-forbidden, reconciliation fail-closed). Residual: historical disclosure drift after future support refactors (F-08).
- **Generated/effective trust risks [E]:** digest-bound; the bypass env var is the only route around it and is confined to publication bootstrap in intended use — the risk is unintended ambient use, not the mechanism itself.
- **Autonomy feedback loops [E]:** stewardship cannot execute; evolution cannot self-approve; missions cannot self-widen (operator-issued authorize-updates only); burn states + circuit breakers bound cascade within PT24H windows. Residual: proceed-on-silence in `reconcile` class depends on correct reversibility classification of actions — misclassification is the loop's weak point **[U]**.
- **Context/memory laundering [E]:** context packs hash model-visible bytes pre-authorization; generated read models, chat, host UI, and memory are prohibited sources (`context-pack-builder-v1.md:77-110`); MEMORY.md: "No execution role owns canonical memory."
- **External trust/federation risks [E]:** FCR-037/038 + trust v6 deny external state authorization; imported proof is evidence-only with 90-day staleness denial. Residual: this machinery is largely stage-only today — its enforcement depth is untested by live federation **[U]**.
- **Operator/read-model confusion [E→I]:** structurally mitigated (non-authority register, FCR-021/032, freshness metadata), but nothing prevents a human *informally* trusting a generated summary over canonical ADRs — an irreducible human-factors residual.

## 11. Review Method Findings

- **Was Balanced Review sufficient?** Yes. The 11-step sequence fit; no step was inapplicable.
- **Was the clean-sheet lens useful?** Yes — it isolated the one place current reality diverges from a from-scratch design (ambient env inputs) and confirmed everything else converges.
- **Is a separate Constitutional Challenge needed?** No. F-01 brushes FCR-025 but is resolvable within existing constitutional constraints (break-glass slot exists at precedence rank 1; the fix is declaration/gating, not amendment).
- **Are narrower follow-up reviews needed?** Optional, not blocking: a Surface Architecture Audit of the policy-interface spec + runtime configuration surface (would carry F-01/F-02 remediation design); a Domain Architecture Audit of evidence retention (F-03/F-06/F-09) if the proposal packet below is not opened.

## 12. Final Verdict

**Preserve with refinements.**

The super-root architecture is sound, current, and — unusually — *enforced at the depth it is documented*: every load-bearing authority claim checked in this review traced to executing code or validators, not just prose. The five-root model, precedence pair, effect-token chain, handle/freshness model, support proofing, and autonomy bounds all survive steelman, fence, and clean-sheet testing. The findings are bounded governance and documentation gaps — the most significant being ambient environment-variable overrides that touch authority decisions without a declared contract (F-01) — none of which challenge the architecture's shape. Refinements are enumerated in Section 9 and `findings.yml` (1 high, 3 medium, 6 low/info).

## 13. Unresolved Blockers

None blocking retention of this review. Open items with owners and routes are recorded in `findings.yml` and `open-questions.md`; the highest-priority blocker *for the recommended follow-up packet* is F-01 (owner: Octon governance per `roles.yml:79-81`; route: single architecture proposal packet; revisit trigger: any protected-mode run executed with an OCTON_* override set).

---

## Review Result Routing and Artifact Placement

### Primary Classification

**Architecture change candidate** — the review recommends bounded revisions (runtime override governance, evidence-store operational contract, validator additions) while preserving the current shape.

### Recommended Primary Destination

Path: `.octon/state/evidence/validation/architecture/reviews/super-root-balanced-review/20260709-super-root-balanced-review/`
Reason: completed whole-architecture review findings are retained evidence; this bundle is already persisted at that destination per the pilot protocol.

### Secondary/Linked Destinations

- Proposal packet needed: **yes** (one, covering F-01/F-02 runtime-override governance with F-03/F-05 documentation refinements attachable)
- Proposal program needed: **no** (findings do not require multi-packet staged decisioning)
- Constitutional Challenge needed: **no**
- Generated navigation/read model useful: no
- Raw intake needed: no

### Required Files for Retained Review Evidence

Present in this bundle: `review.md`, `evidence-index.yml`, `source-prompt.md`, `repo-scope.yml`, `model-and-run-context.yml`, `repository-citations.yml`, `findings.yml`, `authority-boundary-map.yml`, `generated-effective-risk-register.yml`, `support-proof-gap-map.yml`, `validator-depth-matrix.yml`, `route-decision.yml`, `open-questions.md`, `validation.md`.

### Proposal Packet or Program Trigger

A **single architecture proposal packet** is justified: "Runtime environment-override governance" — declare, gate, or remove the OCTON_* authority-affecting overrides; contract the publication bootstrap bypass as break-glass with mandatory receipts; document `stage_only_behavior`; add the invariance negative control. Lower-severity findings (F-03 through F-09) may ride in the same packet or be handled as maintenance. No proposal program and no Constitutional Challenge route is warranted. This review does not create the packet.

### Authority and Non-Authority Statement

- This review result is retained evidence only.
- It does not create authority.
- It does not change support claims.
- It does not authorize implementation.
- It does not mutate runtime/control truth.
- It does not publish generated/effective outputs.
- It does not approve constitutional, governance, support, connector, autonomy, or runtime changes.
- Any later authority change must occur through the proper governed Octon route.

### Follow-Up Routing

- Proposal packet creation (recommended next, operator-authorized)
- Surface Architecture Audit — optional, targeted: policy-interface spec + runtime configuration surface (carries F-01/F-02 design)
- Domain Architecture Audit — optional, targeted: evidence retention domain (F-03/F-06/F-09), only if not folded into the packet
- No Bounded Clean-Sheet Delta Review needed (no unresolved foundational doubts)
- No Constitutional Challenge Review needed
- No Architecture Readiness Audit yet (no newly accepted architecture pending)

### Delegation Guidance

Delegate to cheaper models or implementation agents after gates pass: spec-directory index generation (F-05); evidence-classification v1→v2 migration mechanics (F-09); retirement-register review paperwork (F-04); documentation of existing env vars once the governance decision is made. Reserve architect-grade reasoning for the F-01 break-glass-vs-removal decision and the invariance negative-control design.

### Blockers Before Implementation Planning

- Missing authority decision: whether OCTON_* overrides become contracted break-glass or are removed (F-01) — human governance owns this (`roles.yml:7-13`).
- Missing validator depth: env-override invariance negative control does not yet exist.
- Missing retained evidence: none — this bundle suffices to open the packet.

### Final Routing Verdict

**Retain as evidence and open a single architecture proposal packet.**

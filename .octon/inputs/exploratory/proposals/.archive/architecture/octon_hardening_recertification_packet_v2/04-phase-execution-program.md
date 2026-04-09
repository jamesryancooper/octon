# Execution Program: Octon Hardening and Recertification

This appendix turns the main packet into an implementation program.

## Program principles

1. **Freeze support scope.** No casual widening during hardening.
2. **Close claim-critical items before elegance work.**
3. **Prefer new validators and receipts over new abstractions.**
4. **Use existing canonical roots whenever possible.**
5. **Every phase must emit evidence that the hardening actually happened.**

---

## Workstreams

### WS-A — Lab Integrity
Owner domain: `framework/lab`, support dossiers/admissions, proof-plane owners  
Goal: authored-lab ↔ dossier ↔ admission ↔ proof ↔ retained-evidence closure

### WS-B — Authority Purity
Owner domain: host adapters, governance validators, workflow maintainers  
Goal: labels/comments/checks/workflows remain projections only

### WS-C — Runtime Depth
Owner domain: runtime contracts, runtime validators, disclosure owners  
Goal: stage/checkpoint/continuity/contamination/retry families become explicitly validator-covered and disclosed

### WS-D — Disclosure Calibration
Owner domain: disclosure, closure, release-lineage, claim-truth conditions  
Goal: keep bounded claim precise and honest

### WS-E — Retirement Discipline
Owner domain: governance closeout, retirement register, maintainability/build-to-delete validation  
Goal: no silent carry-forward of transitional surfaces

### WS-F — Agency Simplification
Owner domain: ingress / agency / overlay surfaces  
Goal: reduce interpretive ambiguity around orchestrator-kernel authority

### WS-G — Evidence Deepening
Owner domain: assurance, lab, support dossiers/admissions, exemplar runs  
Goal: deepen empirical confidence across admitted tuples without widening them

---

## Phase plan

### Phase 0 — Scope Freeze and Baseline Capture

**Goal**
- freeze the admitted live support universe for the hardening cycle
- capture baseline disclosure, closure, and current residual issue set

**Repo deltas**
- update active authored disclosure to state hardening-cycle scope freeze
- create a baseline internal issue snapshot under release validation roots

**Dependencies**
- none

**Compatibility window**
- none

**Exit criteria**
- support-target change window is closed unless explicit exception is approved
- baseline issue ledger is checked in or generated into release validation roots

**Evidence to advance**
- baseline issue snapshot
- release governance note confirming no planned support widening

---

### Phase 1 — Lab Reference Integrity

**Goal**
- deterministic scenario ID and path integrity across authored lab, dossiers, admissions, proof reports, and retained evidence

**Repo deltas**
- extend `/.octon/framework/lab/scenarios/registry.yml`
- add `/.octon/state/evidence/lab/index/by-scenario.yml`
- normalize dossier / admission / pack / proof references to scenario IDs
- add release closure report `lab-reference-integrity-report.yml`

**Dependencies**
- Phase 0

**Compatibility window**
- one release cycle for backfilling alias mappings if scenario names drifted historically

**Cutover trigger**
- all active dossier/admission/proof references resolve through the registry

**Fallback posture**
- use temporary alias map for legacy scenario names during one compatibility window only

**Exit criteria**
- zero unresolved scenario IDs
- zero dossier/admission/proof refs pointing outside authored registry without alias
- release closure report passes

**Evidence to advance**
- green lab-reference-integrity report
- updated support dossiers and admissions

---

### Phase 2 — Host Projection Purity

**Goal**
- prove mechanically that host surfaces cannot become authority

**Repo deltas**
- extend host adapter contracts with projection constraints
- add `verify-host-authority-purity.sh` validator
- add `verify-host-adapter-projection-parity.sh` validator
- integrate into governance / closure / workflow CI
- emit release closure report `host-authority-purity-report.yml`

**Dependencies**
- Phase 0

**Compatibility window**
- one release cycle for workflow cleanup if any projection-only violations are found

**Cutover trigger**
- all authority-visible workflow effects reference canonical artifacts

**Fallback posture**
- block release; no acceptable fallback that preserves honesty without canonical refs

**Exit criteria**
- zero authority-minting label/comment/check paths
- all host adapters pass projection purity checks
- release purity report passes

**Evidence to advance**
- green host-authority-purity report
- workflow scan output archived

---

### Phase 3 — Runtime Artifact-Depth Hardening

**Goal**
- make runtime-family depth deterministic and disclosed

**Repo deltas**
- add/confirm schema coverage and validators for stage-attempt, checkpoint, continuity, contamination, retry families
- add `verify-runtime-family-depth.sh` validator
- add runtime-family validation status into RunCard or linked artifact
- add replay integrity validator and receipt

**Dependencies**
- Phase 0

**Compatibility window**
- dual acceptance of existing family outputs plus new validation metadata for one release cycle

**Cutover trigger**
- all admitted exemplar runs pass runtime-family-depth and replay integrity

**Fallback posture**
- keep claim frozen and do not recertify until resolved

**Exit criteria**
- green `runtime-family-depth-report.yml`
- green `replay-integrity.yml`
- per-run disclosure shows validation state for runtime families

**Evidence to advance**
- validation artifacts for every admitted exemplar run
- release-level aggregate report

---

### Phase 4 — Disclosure and Closure Recalibration

**Goal**
- make the active claim-bearing disclosure precisely match reality

**Repo deltas**
- update authored HarnessCard and release HarnessCard `known_limits`
- add `hardening-delta.yml`
- tighten `claim-truth-conditions.yml`
- update release-lineage for next hardened release format
- add authored-vs-projection closure/disclosure parity report

**Dependencies**
- Phase 1–3 preferred for final wording, but can begin earlier

**Compatibility window**
- none for claim-bearing disclosure; updated disclosure becomes immediately authoritative once merged

**Cutover trigger**
- known limits accurately reflect residuals and no claim-critical gap remains undisclosed

**Fallback posture**
- keep old release active if new disclosure cannot yet be written honestly

**Exit criteria**
- non-empty, accurate known-limits block
- hardening delta exists
- parity report passes
- closure invalidators cover current claim-critical classes

**Evidence to advance**
- updated HarnessCard
- updated claim-truth conditions
- green disclosure parity report

---

### Phase 5 — Retirement and Retain-Rationale Discipline

**Goal**
- ensure residual transitional surfaces are not silently carried forward

**Repo deltas**
- expand retirement-register fields
- update closeout review contracts to require explicit retain/retire/demote decisions
- emit release retirement review receipt

**Dependencies**
- Phase 0

**Compatibility window**
- one release cycle to backfill rationale for known transitional surfaces

**Cutover trigger**
- all residual transitional surfaces are classified explicitly

**Fallback posture**
- release may proceed only if all retained surfaces have documented rationale and next review date

**Exit criteria**
- retirement register materially expanded
- closeout requires retirement review receipt
- no implicit transitional surfaces remain

**Evidence to advance**
- retirement review receipt
- updated retirement register

---

### Phase 6 — Agency Simplification and Projection Demotion

**Goal**
- reduce operator-facing ambiguity around orchestrator-kernel authority

**Repo deltas**
- add explicit non-authoritative headers to ingress/projection surfaces
- update or retire residual persona-heavy overlays where safe
- add canonical surface map doc

**Dependencies**
- Phase 4 and 5 preferred

**Compatibility window**
- one release cycle for user-facing documentation transition

**Cutover trigger**
- all major non-canonical user-facing surfaces self-identify and point to canonical roots

**Fallback posture**
- retain demoted surfaces with clear banners if deletion is too disruptive

**Exit criteria**
- projection/shim surfaces are obviously labeled
- at least one transitional persona-heavy surface is retired or reclassified with explicit rationale

**Evidence to advance**
- updated registry / retirement entries
- operator-facing surface map published

---

### Phase 7 — Empirical Evidence Deepening

**Goal**
- deepen evidence on the existing admitted universe before any support widening

**Repo deltas**
- add fresh exemplar runs per tuple class where coverage is thin
- refresh dossiers and support-universe coverage bundle
- add evaluator-diversity note where relevant

**Dependencies**
- Phase 1 and 3 preferred so new evidence benefits from hardened integrity/depth rules

**Compatibility window**
- none; this is ongoing evidence accumulation

**Cutover trigger**
- each admitted tuple class has fresh nominal/adversarial/recovery evidence per policy

**Fallback posture**
- keep support scope unchanged; stale tuples cannot justify expansion

**Exit criteria**
- freshness receipt green across all admitted tuple classes
- support-universe coverage bundle refreshed

**Evidence to advance**
- updated coverage artifacts
- new RunCards / proof bundles

---

### Phase 8 — Hardened Recertified Release

**Goal**
- publish the next release that can honestly continue the bounded attainment claim

**Repo deltas**
- update active release lineage
- publish new HarnessCard
- publish updated closure bundle
- publish hardening delta
- supersede prior active release

**Dependencies**
- Phases 1–5 mandatory
- Phase 6–7 strongly recommended, with any remaining non-critical residuals explicitly disclosed

**Compatibility window**
- old active release remains historically retained and non-claim-bearing after supersession

**Cutover trigger**
- zero unresolved claim-critical issues and two consecutive clean passes

**Fallback posture**
- do not supersede the current active release until all claim-critical items are closed

**Exit criteria**
- zero unresolved claim-critical items
- explicit rationale for all remaining non-critical items
- two consecutive validation passes
- updated disclosure and lineage published

**Evidence to complete**
- final closure certificate
- final hardening delta
- updated HarnessCard
- updated release-lineage
- two-pass validation record

---

## Minimum recertification gate checklist

A next hardened release may be certified only if all boxes are checked:

- [ ] support scope unchanged or explicitly re-admitted under the full process
- [ ] lab-reference-integrity green
- [ ] host-authority-purity green
- [ ] runtime-family-depth green
- [ ] replay-integrity green
- [ ] active HarnessCard accurately states known limits
- [ ] hardening delta published
- [ ] retirement review receipt published
- [ ] no stale admission or dossier past review_due
- [ ] two consecutive validation passes with no new claim-critical findings

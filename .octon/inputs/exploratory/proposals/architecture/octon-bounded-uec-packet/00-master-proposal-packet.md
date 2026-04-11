# Octon Closure-Hardening Proposal Packet

## Packet identity

- **Packet type:** repository-grounded closure-hardening, remediation, and certification program
- **Target:** honestly claimable bounded Unified Execution Constitution (UEC) for the admitted live support universe
- **Primary authority:** current live Octon repository
- **Secondary authority:** live canonical constitutional / runtime / governance / disclosure / closure surfaces inside the repository
- **Binding acceptance-delta:** the implementation audit already completed against the current repo
- **Historical lineage:** prior proposal and design packet only where live repo surfaces are silent

## Packet operating rule

This packet does **not** redesign Octon from scratch. It hardens the already-existing constitutional architecture until the bounded complete claim can be stated without inflation.

## Recommended decision

**Use Path B — claim-safe recertification.**

The repository already exposes an active bounded closure release and a `claim_status: complete`, but the active claim depends on truth conditions that require canonical authority, durable run semantics, classed evidence, complete proof, and claim-calibrated disclosure. The sampled live artifacts still show: (1) authority-ledger incoherence, (2) governance-exercise residue in live authority files, and (3) skeletal instruction/evidence manifests. The smallest honest path is therefore to **downgrade the active complete claim immediately, preserve the admitted support universe, harden the blockers, and only then mint a fresh recertified-complete release**.

---

### A. Executive Recommendation

**Recommendation:** adopt a **claim-safe recertification path** immediately.

Why:

1. **The current repo is close enough that a rewrite would be dishonest and wasteful.** The constitutional kernel, objective hierarchy, control families, support-target governance, lab, observability, adapters, capability packs, and disclosure machinery already exist in substantive form.
2. **The active complete claim is still ahead of the strongest retained proof.** The current active release says the bounded claim is complete, but the repo’s own truth conditions make that invalid if authority, run semantics, classed evidence, proof-plane coverage, or disclosure calibration are weak or mismatched.
3. **The blockers are narrow and hardenable.** The problem is not missing top-level architecture. It is closure-grade normalization, validator coverage, evidence depth, and claim honesty.
4. **The smallest honest path is staged, not big-bang.** Octon should keep one canonical constitutional kernel, one active release lineage, one clear claim state, and one recertification cutover point.

Recommended immediate state change:

- Retire the current `claim_status: complete` as the active public closure state.
- Activate a new release state: **`bounded-recertification-open`**.
- Preserve the same bounded admitted support universe during hardening.
- Re-attain `complete` only after dual-pass recertification with zero unresolved closure blockers.

Supporting files in this packet:

- `specs/04-claim-governance-and-disclosure-plan.md`
- `traceability/01-master-closure-blocker-register.md`
- `specs/05-migration-cutover-recertification-checklists.md`

---

### B. Audited Baseline and Claim Scope

#### Current repo reality

Octon already materially implements the following:

- a singular constitutional kernel under `/.octon/framework/constitution/**`
- a machine-addressable contract registry and claim-truth surface
- a canonical workspace-charter root under `/.octon/instance/charter/**`
- mission authority as a continuity container under `/.octon/instance/orchestration/missions/**`
- canonical run-control roots under `/.octon/state/control/execution/runs/**`
- canonical approvals, exceptions, and revocations under `/.octon/state/control/execution/**`
- retained execution authority evidence under `/.octon/state/evidence/control/execution/**`
- top-level authored `framework/lab/**` and `framework/observability/**`
- host/model adapter roots and governed capability packs
- support-target declarations, admissions, and dossiers
- canonical RunCard / HarnessCard disclosure surfaces
- release-lineage and closure artifacts

#### Active claim scope

The live repo does **not** currently claim universal support. It claims a **bounded Unified Execution Constitution** for the **admitted live support universe** declared in support-target governance and release disclosure.

#### Why this packet is needed

The current repo has already crossed the line from “proposal” to “implemented architecture,” but it has **not yet crossed the line from “architecturally close” to “closure-grade proven.”**

The remaining problems are:

- ledger coherence in live authority artifacts
- thin runtime/evidence constitutionalization in claim-bearing runs
- insufficiently tight run-to-release disclosure coupling
- host non-authority not yet proven across workflows
- uneven proof-plane closure
- incomplete closure proof for agency simplification
- incomplete operationalization of retirement / build-to-delete
- support-target tuple proof still weaker than the live bounded claim requires

This packet therefore treats the repo as **substantially correct in architecture, not yet honest in complete closure status**.

---

### C. Closure Blocker Register

This master packet uses eight top-level closure blockers that correspond directly to the audited baseline.

| Blocker ID | Top-level blocker | Primary paths | Severity | Classification |
|---|---|---|---|---|
| CB-01 | Authority ledger coherence gap | `state/control/execution/runs/**`, `approvals/**`, `exceptions/**`, `revocations/**` | Critical | Closure-blocking |
| CB-02 | Runtime/evidence constitutionalization too thin | `state/evidence/runs/**/instruction-layer-manifest.json`, `evidence-classification.yml` | Critical | Closure-blocking |
| CB-03 | Claim-calibrated disclosure too weak | `state/evidence/disclosure/**`, `instance/governance/disclosure/**`, `generated/effective/**` | Critical | Closure-blocking |
| CB-04 | Host/workflow non-authority not proven | `framework/engine/runtime/adapters/host/**`, `.github/workflows/**` | Critical | Closure-blocking |
| CB-05 | Proof-plane substantiation uneven | `framework/assurance/**`, `framework/lab/**`, `state/evidence/lab/**`, `state/evidence/runs/**/assurance/**` | Critical | Closure-blocking |
| CB-06 | Agency simplification and overlay demotion not closure-proven | `framework/agency/**`, `instance/ingress/**`, root adapter surfaces | High | Closure-blocking |
| CB-07 | Retirement / ablation / build-to-delete not operational enough | `instance/governance/retirement-register.yml`, `state/evidence/validation/publication/build-to-delete/**` | Medium | Non-blocking hardening unless trigger present |
| CB-08 | Support-target tuple coverage not closure-grade | `instance/governance/support-targets.yml`, admissions, dossiers, adapter contracts, disclosure bundles | Critical | Closure-blocking under preserved-universe path |

Detailed register: `traceability/01-master-closure-blocker-register.md`

---

### D. Target-State Definition

The target state is **not** “Octon looks complete.” It is this exact state:

1. **One live constitutional kernel.** `framework/constitution/**` remains singular, supreme, and uncontested.
2. **One live objective hierarchy.** Workspace charter pair → mission continuity container → bound run contract → execution attempts / stages.
3. **One live control truth.** Approvals, exceptions, and revocations are the sole authority families; host labels, comments, checks, and env flags remain projections only.
4. **Claim-bearing runs are closure-grade.** Every claim-bearing exemplar run has a substantive instruction-layer manifest, a substantive evidence classification, coherent authority ledgers, replay pointers, and disclosure alignment.
5. **Release claims are derived, not asserted.** HarnessCards, RunCards, release manifests, and generated/effective projections must all be traceable to retained run bundles.
6. **Every admitted live tuple is dossier-backed, runtime-backed, proof-backed, and disclosure-backed.**
7. **All six proof planes are closed at bounded-universe strength:** structural, functional, behavioral, maintainability, governance, recovery.
8. **Single accountable orchestration is proven.** Residual overlays are either non-authoritative and registered as such, or deleted.
9. **Retirement discipline is operational.** Shims, projections, and obsolete scaffolding are either retired, justified, or explicitly queued.
10. **The active complete claim is only reissued after dual-pass recertification.**

See `specs/01-target-state-specification.md`.

---

### E. Canonical Artifact Normalization Plan

This plan addresses the blocker family around **authority-ledger coherence** and **artifact purity**.

#### E1. Immediate handling of the named blocker artifacts

The following sampled files are treated as live closure blockers and may not remain silently claim-bearing:

- `/.octon/state/control/execution/runs/uec-bounded-repo-shell-boundary-sensitive-20260409/run-contract.yml`
- `/.octon/state/control/execution/approvals/requests/uec-bounded-repo-shell-boundary-sensitive-20260409.yml`
- `/.octon/state/control/execution/exceptions/leases/lease-uec-bounded-repo-shell-boundary-sensitive-20260409.yml`
- `/.octon/state/control/execution/revocations/revoke-uec-bounded-repo-shell-boundary-sensitive-20260409.yml`

#### E2. Recommended normalization strategy

**Preferred resolution:** do **not** rewrite governance-exercise lineage into a “clean” live exemplar. Instead:

1. mark the sampled 2026-04-09 boundary-sensitive run and its contaminated authority chain as **non-claim-bearing historical exercise lineage**, and
2. mint a **fresh clean claim-bearing boundary-sensitive exemplar run** under a new run id.

Why this is preferred:

- it preserves provenance
- it avoids silent rewriting of retained control truth
- it makes the active closure claim depend only on artifacts generated under the final bounded-hardening rules

#### E3. Family-wide normalization rules

For any claim-bearing run:

- `run-contract`, `approval request`, `approval grant`, `exception lease` (if applicable), `revocation` (if applicable), `run-card`, and release disclosure must agree on:
  - run id
  - workload tier / support tier
  - target id semantics
  - actor and ownership refs
  - reversibility class
  - reason code family
  - authority materialization status
- no claim-bearing live authority artifact may contain exercise-only markers such as:
  - `safe-stage`
  - `governance/exercise`
  - `example.invalid`
  - exercise-specific reason codes

#### E4. Required new validators

Add, at minimum:

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-run-authority-ledger-coherence.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-live-authority-no-exercise-residue.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-run-card-ledger-parity.sh`

#### E5. Required new evidence outputs

Per release candidate:

- `state/evidence/disclosure/releases/<release-id>/closure/authority-ledger-coherence-report.yml`
- `state/evidence/disclosure/releases/<release-id>/closure/no-exercise-residue-report.yml`
- `state/evidence/disclosure/releases/<release-id>/closure/run-card-ledger-parity-report.yml`

Detailed file-level changes: `specs/02-path-specific-remediation-specs.md`.

---

### F. Runtime, Evidence, and Disclosure Hardening Plan

This plan hardens the **claim-bearing run bundle**.

#### F1. Instruction-layer manifest hardening

Current closure-grade rule:

A claim-bearing run may not ship with a manifest that only says `schema_version` and `run_id`.

Required minimum content for `instruction-layer-manifest-v2`:

- run id
- mission id (or explicit run-only declaration)
- workspace charter refs and digests
- mission charter refs and digests
- run contract ref and digest
- support-target tuple id
- authority artifact refs (request / grant / lease / revocation as applicable)
- effective precedence order
- adapter projections in force
- generated-at / generated-by metadata
- integrity digests

#### F2. Evidence-classification hardening

A claim-bearing run may not ship with `artifacts: []`.

Required minimum content for `run-evidence-classification-v2`:

For every retained artifact used by runtime, proof, or disclosure:

- artifact id
- artifact path or immutable external pointer
- evidence class (`git-inline`, `git-pointer`, `external-immutable`, `generated-derived`, `disclosure-derived`)
- required-for-claim flag
- proof-plane mapping
- retention policy
- digest / immutable locator
- provenance source

#### F3. Claim-bearing run bundle contract

Introduce a claim-bearing run bundle manifest under disclosure, e.g.:

- `state/evidence/disclosure/runs/<run-id>/manifest.yml`

This manifest must bind:

- run contract
- run manifest
- runtime state
- instruction-layer manifest
- evidence classification
- replay pointers
- trace pointers
- measurement summary
- intervention summary
- proof-plane refs
- RunCard

#### F4. Run-to-release coupling

A release HarnessCard or closure bundle may only cite runs whose bundle manifests validate green. No release claim may be stronger than the weakest claim-bearing run bundle it aggregates.

#### F5. Fail conditions

The following must fail closure certification immediately:

- empty `artifacts` array on a claim-bearing run
- instruction-layer manifest missing canonical layer refs
- run bundle missing replay / trace / measurement / disclosure links required by the support-target tuple
- release disclosure citing a run bundle that failed validation

Detailed design: `specs/03-validator-and-evidence-program.md` and `specs/04-claim-governance-and-disclosure-plan.md`.

---

### G. Workflow / Adapter / Non-Authority Proof Plan

The repo already says host projections are non-authoritative. The remaining task is to **prove** this.

#### G1. Static proof

Audit and harden at least:

- `.github/workflows/pr-autonomy-policy.yml`
- `.github/workflows/ai-review-gate.yml`
- `.github/workflows/closure-certification.yml`
- `.github/workflows/uec-cutover-validate.yml`
- `.github/workflows/uec-cutover-certify.yml`
- `.github/workflows/unified-execution-constitution-closure.yml`

Required invariant:

No workflow may mint authority from labels, comments, checks, workflow env, or GitHub-native state alone.

#### G2. Dynamic negative tests

Introduce negative-path tests proving:

- label says “approved” but no canonical `ApprovalGrant` exists → fail closed
- check says “green” but no canonical authority artifact exists → fail closed
- canonical revocation exists but host label absent → authority is revoked anyway
- host projection differs from canonical authority family → canonical family wins

#### G3. Required validators

- `validate-host-projection-purity.sh`
- `validate-workflow-authority-derivation.sh`
- `validate-host-canonical-parity.sh`

#### G4. Required outputs

- `closure/host-projection-purity-report.yml`
- `closure/workflow-authority-derivation-report.yml`
- `closure/host-canonical-parity-report.yml`

This plan is detailed in `specs/02-path-specific-remediation-specs.md` and `specs/03-validator-and-evidence-program.md`.

---

### H. Proof-Plane Completion Plan

Octon’s complete bounded claim needs six proof planes, not one or two.

| Proof plane | Required artifacts | Required validators | Minimum disclosure |
|---|---|---|---|
| Structural | schema conformance, registry parity, family completeness, cross-artifact consistency | structural validators, contract validators, closure consistency validators | release closure summary + tuple coverage refs |
| Functional | end-to-end acceptance bundles, scenario pass results, consequence-safe run outcomes | scenario validators, task completion validators, run-bundle validators | tuple-level outcome summary + exemplar run refs |
| Behavioral | lab scenarios, hidden checks, shadow runs, adversarial / fault results | lab validators, hidden-check breadth, evaluator diversity | behavioral plane summary + failure classes |
| Maintainability | architecture conformance, drift detection, stale-doc detection, code hygiene, simplification evidence | architecture / drift / stale-doc validators | maintainability summary + open debt boundary |
| Governance | authority integrity, support-target coverage, disclosure calibration, host non-authority proof | authority + support + disclosure + workflow validators | governance plane summary + exclusions / boundedness statement |
| Recovery | checkpoint / resume drills, rollback / compensation, contamination reset, replay integrity | recovery validators, replay validators, recovery-drill validators | recovery summary + replay / rollback refs |

Closure-grade sufficiency for the admitted live universe means:

- every admitted workload / adapter tuple has the proofs appropriate to its risk tier
- no plane is satisfied merely by prose if the repo already claims machine-verifiable closure
- every plane is represented in release disclosure
- every plane is independently gateable in CI

Detailed plan: `specs/01-target-state-specification.md` and `specs/03-validator-and-evidence-program.md`.

---

### I. Support-Target and Claim-Boundedness Plan

#### I1. Recommended stance

- **Preserve** the current authoritative support-target declaration as the admitted live support universe.
- **Do not** silently widen it.
- **Do not** claim complete bounded closure for it until tuple-by-tuple proof is closed.

#### I2. Closure-grade tuple requirements

For each admitted tuple, require:

- support-target admission artifact
- current support dossier
- bound host / model adapter contracts
- required capability-pack declarations
- required evidence depth for the tuple’s workload class
- required proof-plane coverage
- disclosure row in HarnessCard
- at least one claim-bearing exemplar run bundle for consequential classes
- unsupported-case fail-closed behavior

#### I3. If closure work slips

If full tuple coverage cannot be closed on the preserved universe inside the recertification window, the fallback is **temporary public claim narrowing**, not silent overclaiming.

That fallback is second-best. This packet recommends preserving the universe and finishing the hardening.

Detailed support plan: `specs/01-target-state-specification.md` and `traceability/01-master-closure-blocker-register.md`.

---

### J. Agency Simplification and Overlay Demotion Plan

The repo directionally claims a default single accountable orchestrator with optional non-authoritative overlays. The packet makes that auditable.

#### J1. Canonical rule

- one accountable orchestrator default
- overlays may alter presentation or ergonomics
- overlays may not alter authority, routing, support-target selection, or claim state

#### J2. Required actions

- audit `framework/agency/**`
- audit `instance/ingress/**`
- audit repo-root ingress projection surfaces (`AGENTS.md`, `CLAUDE.md`, `.octon/AGENTS.md`)
- add every surviving overlay / projection / persona surface to the non-authority register
- delete or demote any surface that still carries hidden operational authority

#### J3. Required validators and evidence

- `validate-agency-overlay-containment.sh`
- `validate-non-authority-register-completeness.sh`
- `closure/agency-overlay-containment-report.yml`
- `closure/non-authority-register-parity-report.yml`

Detailed plan: `specs/02-path-specific-remediation-specs.md`.

---

### K. Retirement, Ablation, and Build-to-Delete Plan

The repo already names build-to-delete and retains a retirement register. The packet turns that into an operational closure input.

#### K1. Release requirement

Every active closure bundle must include one of:

- a retirement / ablation evidence set proving candidate cleanup was reviewed and handled, or
- an explicit “no current retirement candidates” attestation produced by validator-backed scan

#### K2. Required cadence

- per-release retirement scan
- recurring monthly shim / projection / obsolete-workflow review
- pre-recertification build-to-delete review

#### K3. Required outputs

- `closure/retirement-review-report.yml`
- `closure/build-to-delete-report.yml`
- `closure/shim-retention-rationale-report.yml`

This remains non-blocking **unless** a material trigger exists. If a material trigger exists and no review occurred, it becomes recertification-blocking.

---

### L. Migration / Cutover / Recertification Sequence

This packet explicitly avoids a fake clean-break rewrite. The program is staged.

#### Stage 0 — Immediate honesty patch

Create a new active release, e.g.:

- `2026-04-11-uec-bounded-recertification-open`

Actions:

- switch `release-lineage.yml` active release to the recertification-open release
- mark the current 2026-04-09 complete release as superseded by recertification
- downgrade public claim wording in authored HarnessCard / closure state
- publish the blocker register and traceability bundle

#### Stage 1 — Quarantine contaminated exemplar lineage

- quarantine or supersede the sampled 2026-04-09 boundary-sensitive exemplar from claim-bearing status
- open a fresh clean claim-bearing boundary-sensitive exemplar run

#### Stage 2 — Authority normalization and workflow proof

- install family-wide ledger-coherence validators
- harden workflows to derive from canonical authority only
- generate host non-authority proof outputs

#### Stage 3 — Runtime/evidence backfill

- ship new instruction-layer manifest and evidence-classification requirements
- backfill every claim-bearing exemplar run
- reject skeletal bundles in CI

#### Stage 4 — Proof-plane equalization and support-target closure

- close missing functional / behavioral / maintainability / recovery proof
- close tuple-by-tuple dossier / proof / disclosure gaps

#### Stage 5 — Agency / retirement hardening

- close overlay containment proof
- publish retirement / ablation evidence

#### Stage 6 — Dual-pass recertification

- run full certification suite twice in clean environments
- require zero new material blockers
- require parity between run-level and release-level disclosure

#### Stage 7 — Complete-claim cutover

Mint a fresh release, e.g.:

- `2026-04-XX-uec-bounded-recertified-complete`

Only then:

- set `claim_status: complete`
- update active HarnessCard and closure certificate
- regenerate effective closure projections

No stage may produce dual canonical authority. No stage may leave unclear which release is active. No stage may allow overclaiming.

Detailed checklist file: `specs/05-migration-cutover-recertification-checklists.md`.

---

### M. Validation and Certification Program

#### M1. Required validator families

| Validator ID | Purpose | Output | Gate |
|---|---|---|---|
| V-01 | constitutional singularity / registry parity | `closure/kernel-singularity-report.yml` | hard fail |
| V-02 | objective hierarchy binding | `closure/objective-hierarchy-report.yml` | hard fail |
| V-03 | support-target coverage | `closure/support-target-coverage-report.yml` | hard fail |
| V-04 | run-authority ledger coherence | `closure/authority-ledger-coherence-report.yml` | hard fail |
| V-05 | no exercise residue in claim-bearing artifacts | `closure/no-exercise-residue-report.yml` | hard fail |
| V-06 | instruction-layer manifest completeness | `closure/instruction-manifest-completeness-report.yml` | hard fail |
| V-07 | evidence-classification completeness | `closure/evidence-classification-completeness-report.yml` | hard fail |
| V-08 | run disclosure / release disclosure alignment | `closure/claim-calibration-report.yml` | hard fail |
| V-09 | host projection purity | `closure/host-projection-purity-report.yml` | hard fail |
| V-10 | workflow authority derivation | `closure/workflow-authority-derivation-report.yml` | hard fail |
| V-11 | proof-plane coverage | `closure/proof-plane-coverage.yml` | hard fail |
| V-12 | evaluator diversity / hidden-check breadth / dossier evidence depth | `closure/evaluator-diversity-report.yml`, `closure/hidden-check-breadth-report.yml`, `closure/support-universe-evidence-depth-report.yml` | hard fail |
| V-13 | recovery drills / replay integrity | `closure/recovery-drill-report.yml`, `closure/replay-integrity-report.yml` | hard fail |
| V-14 | agency overlay containment | `closure/agency-overlay-containment-report.yml` | hard fail |
| V-15 | retirement / build-to-delete review completeness | `closure/build-to-delete-report.yml` | conditional hard fail |
| V-16 | generated/effective projection parity | `closure/generated-effective-parity-report.yml` | hard fail |
| V-17 | release bundle integrity | `closure/release-bundle-integrity-report.yml` | hard fail |
| V-18 | dual-pass certification comparison | `closure/dual-pass-diff-report.yml` | hard fail |

#### M2. Consecutive-pass rule

A complete bounded closure claim requires:

- **Pass A:** all validators green, all run bundles regenerated, all release disclosure regenerated.
- **Pass B:** repeat in a fresh environment; no new blocker, no material divergence except allowed timestamp / digest drift.

If any material issue reappears, the pass counter resets.

#### M3. Certification prerequisites

The packet defines closure certification as satisfied only when all of the following are true:

- zero unresolved closure-blocking findings within the admitted live support universe
- two consecutive full validation passes with no new material issues
- no live authority-ledger incoherence
- no residual exercise/test lineage contamination in live claim-bearing authority artifacts
- substantive, non-skeletal instruction-layer and evidence-classification artifacts for claim-bearing runs
- run-level and release-level disclosure alignment with claim-truth conditions
- explicit proof that host/workflow surfaces are non-authoritative
- closure-grade substantiation across structural, functional, behavioral, maintainability, governance, and recovery proof planes
- honest HarnessCard / RunCard / release-lineage / closure state

Detailed validator design: `specs/03-validator-and-evidence-program.md`.

---

### N. Final Closure Decision

Octon may honestly state that it has attained the **bounded Unified Execution Constitution** target state **only when**:

1. the constitutional kernel remains singular and active,
2. the bounded admitted support universe is fully coverage-backed,
3. claim-bearing run bundles are authority-coherent and evidence-complete,
4. release disclosure is derived from those bundles,
5. workflows are proven non-authoritative,
6. all six proof planes are closed at bounded-universe strength,
7. overlay / agency claims are either proven or removed from public wording,
8. retirement / build-to-delete obligations are satisfied, and
9. dual-pass recertification completes green.

Until then, the only honest public wording is a **recertification-open bounded architecture statement**, not a complete-attainment statement.

---

### O. Resources and Traceability

This packet includes:

- the full implementation audit in `resources/01-full-implementation-audit.md`
- the master blocker register in `traceability/01-master-closure-blocker-register.md`
- the end-to-end crosswalk in `traceability/02-audit-finding-to-remediation-to-validator-to-evidence-matrix.md`
- the file/workflow change register in `traceability/03-file-and-workflow-change-register.md`
- target-state, remediation, validator, disclosure, and checklist specs in `specs/**`
- key repo evidence excerpts in `resources/04-key-evidence-excerpts.md`

The packet is intentionally staged, path-specific, validator-backed, evidence-backed, and claim-honest.

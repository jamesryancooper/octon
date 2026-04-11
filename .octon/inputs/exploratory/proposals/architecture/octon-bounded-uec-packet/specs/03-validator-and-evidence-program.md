# Validator and Evidence Program

## 1. Operating model

This program defines the validator suite, evidence outputs, and gate semantics required for honest bounded closure.

### 1.1 Gate classes

- **Hard fail:** blocks recertification and complete-claim issuance
- **Conditional hard fail:** blocks recertification if a material trigger exists
- **Advisory:** non-blocking, but must be reviewed before final cutover

## 2. Validator catalog

| ID | Validator | Purpose | Inputs | Output | Gate |
|---|---|---|---|---|---|
| V-01 | `validate-kernel-singularity.sh` | ensure no co-equal authority outside the constitutional kernel | registry, charter surfaces, non-authority register | `closure/kernel-singularity-report.yml` | Hard fail |
| V-02 | `validate-objective-hierarchy.sh` | ensure workspace → mission → run hierarchy is intact | workspace charter, mission roots, run roots | `closure/objective-hierarchy-report.yml` | Hard fail |
| V-03 | `validate-support-target-coverage.sh` | tuple-by-tuple support coverage | support targets, admissions, dossiers, adapters, packs | `closure/support-target-coverage-report.yml` | Hard fail |
| V-04 | `validate-run-authority-ledger-coherence.sh` | run / approval / lease / revocation / run-card coherence | control roots + disclosure roots | `closure/authority-ledger-coherence-report.yml` | Hard fail |
| V-05 | `validate-live-authority-no-exercise-residue.sh` | ban exercise lineage in claim-bearing authority artifacts | claim-bearing run bundles | `closure/no-exercise-residue-report.yml` | Hard fail |
| V-06 | `validate-instruction-layer-manifests.sh` | substantive instruction-layer manifests | run evidence roots | `closure/instruction-manifest-completeness-report.yml` | Hard fail |
| V-07 | `validate-evidence-classification.sh` | substantive evidence classification | run evidence roots | `closure/evidence-classification-completeness-report.yml` | Hard fail |
| V-08 | `validate-claim-calibration.sh` | run-to-release disclosure alignment | RunCards, HarnessCards, release bundle, effective projections | `closure/claim-calibration-report.yml` | Hard fail |
| V-09 | `validate-host-projection-purity.sh` | ensure host adapters remain projection-only | host adapter contracts + workflows | `closure/host-projection-purity-report.yml` | Hard fail |
| V-10 | `validate-workflow-authority-derivation.sh` | ensure workflows derive authority from canonical artifacts only | `.github/workflows/**` | `closure/workflow-authority-derivation-report.yml` | Hard fail |
| V-11 | `validate-proof-plane-coverage.sh` | ensure all six proof planes are represented | assurance, lab, disclosure, run bundles | `closure/proof-plane-coverage.yml` | Hard fail |
| V-12 | `validate-evaluator-diversity.sh` | ensure evaluator independence / hidden-check breadth / dossier evidence depth | assurance contracts + closure reports | `closure/evaluator-diversity-report.yml`, `closure/hidden-check-breadth-report.yml`, `closure/support-universe-evidence-depth-report.yml` | Hard fail |
| V-13 | `validate-recovery-drills.sh` | recovery / replay / rollback proof | run bundles, recovery reports, replay pointers | `closure/recovery-drill-report.yml`, `closure/replay-integrity-report.yml` | Hard fail |
| V-14 | `validate-agency-overlay-containment.sh` | prove overlay non-authority and orchestrator default | agency roots, ingress roots, non-authority register | `closure/agency-overlay-containment-report.yml` | Hard fail |
| V-15 | `validate-build-to-delete-evidence.sh` | retirement / ablation / shim review completeness | retirement register, build-to-delete evidence | `closure/build-to-delete-report.yml` | Conditional hard fail |
| V-16 | `validate-generated-effective-parity.sh` | ensure generated/effective surfaces match authored truth and remain non-authoritative | generated/effective roots + authored sources | `closure/generated-effective-parity-report.yml` | Hard fail |
| V-17 | `validate-release-bundle-integrity.sh` | ensure release bundle is complete and self-consistent | release manifest, HarnessCard, closure refs | `closure/release-bundle-integrity-report.yml` | Hard fail |
| V-18 | `validate-dual-pass-diff.sh` | compare pass A vs pass B artifacts for material drift | two full closure candidate bundles | `closure/dual-pass-diff-report.yml` | Hard fail |

## 3. Evidence output contract

Every validator output must include at minimum:

- `validator_id`
- `generated_at`
- `repo_rev`
- `input_refs[]`
- `status`
- `blocking`
- `findings[]`
- `resolved_by_refs[]` (optional)
- `notes`

## 4. Run-level evidence outputs required for claim-bearing runs

Each claim-bearing run must produce or reference:

- `run-contract.yml`
- `run-manifest.yml`
- `runtime-state.yml`
- `instruction-layer-manifest.json`
- `evidence-classification.yml`
- `replay-pointers.yml`
- `trace-pointers.yml`
- `measurement-summary.yml`
- `intervention-summary.yml` (or explicit `no-interventions.yml`)
- proof-plane references
- `run-card.yml`
- disclosure `manifest.yml`

## 5. Release-level outputs required for recertification

Each release candidate bundle must contain:

- `manifest.yml`
- `harness-card.yml`
- closure validator outputs V-01..V-18
- blocker register
- traceability matrix reference
- list of claim-bearing exemplar runs
- support-target coverage reference
- proof-plane coverage reference
- closure certificate or provisional certificate

## 6. Dual-pass certification rule

### Pass A

- generated from a clean repo state
- all validators green
- all claim-bearing run bundles regenerated
- all release disclosure regenerated

### Pass B

- generated from a fresh clean environment
- rerun complete validator set
- compare against Pass A
- only allowed differences: timestamps, deterministic digest updates, non-semantic artifact IDs

### Reset conditions

If any of the following occur, the two-pass counter resets:

- new authority-ledger mismatch
- new exercise residue in claim-bearing artifacts
- empty or skeletal run evidence artifact
- support-target coverage regression
- disclosure stronger than ledgers
- any hard-fail validator red

## 7. Workflow integration

### Must update existing workflows

- `.github/workflows/closure-certification.yml`
- `.github/workflows/closure-validator-sufficiency.yml`
- `.github/workflows/pr-autonomy-policy.yml`
- `.github/workflows/uec-cutover-validate.yml`
- `.github/workflows/uec-cutover-certify.yml`
- `.github/workflows/unified-execution-constitution-closure.yml`

### Suggested additional workflow

- `.github/workflows/uec-recertification-open.yml`

Purpose: run staged recertification suite and publish provisional status while active complete claim is withdrawn.

## 8. Human review requirements

Even though this is validator-heavy, the following still require human accountable review:

- claim-state transition from `recertification_open` to `complete`
- support-universe narrowing decision, if needed
- retirement decisions for material shims or overlays
- acceptance of any exception to the no-rewrite / preserve-provenance rule for contaminated historical artifacts

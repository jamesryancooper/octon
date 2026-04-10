# 08. Validation and verification program

## 8.1 Validation model

The target state requires both **structural** and **evidentiary** validation.

The validator stack must answer:

1. Is the architecture constitutionally singular and non-ambiguous?
2. Does the active claim remain bounded?
3. Is the current support universe fully covered by dossiers and proof?
4. Are non-authority surfaces clearly prevented from masquerading as authority?
5. Is the release bundle internally consistent and fresh enough to certify?

## 8.2 Validation families

### A. Structural validators

- constitutional singularity / registry integrity
- family README normalization
- contract-family version coherence
- ingress manifest parity
- support-target / admissions / dossiers / matrix parity
- host projection purity
- projection-shell boundary discipline
- generated/effective/operator non-authority labeling

### B. Contract validators

- support-dossier-evidence-depth schema
- evaluator-diversity schema
- hidden-check-breadth schema
- retirement-register depth schema
- non-authority register schema
- closure-summary / closure-certificate / residual-ledger schemas

### C. Evidence validators

- per-tuple retained run count
- per-tuple scenario coverage count
- proof-plane completeness by workload class
- replay integrity for applicable tuples
- contamination / retry coverage for applicable tuples
- freshness of representative runs

### D. Disclosure consistency validators

- bounded claim wording checker
- active release citation checker
- stale review packet checker
- active/historical scope contradiction checker
- residual-ledger to HarnessCard consistency checker

### E. Review freshness validators

- last support-target-changing commit date <= latest review packet date
- ablation review packet ref == latest review packet ref
- retirement register claim-adjacent entries reference current closeout review regime

## 8.3 Proposed validator set

| Validator | Purpose | Expected output |
|---|---|---|
| `validate-support-target-live-claims.sh` (updated) | parity of support-targets / admissions / dossiers / matrix | pass/fail |
| `validate-bounded-claim-nomenclature.sh` | no overbroad wording in active artifacts | pass/fail |
| `validate-audit-crosswalk.sh` | every current audit finding has disposition + evidence | pass/fail |
| `validate-review-packet-freshness.sh` | latest review packet is fresh enough for active support universe | pass/fail |
| `validate-non-authority-register.sh` | all permanent non-authority surfaces are inventoried and labeled | pass/fail |
| `validate-retirement-register-depth.sh` | claim-adjacent retained surfaces have mature rationale | pass/fail |
| `validate-ingress-manifest-parity.sh` | ingress adapter files match the manifest | pass/fail |
| `validate-support-dossier-evidence-depth.sh` | all admitted dossiers meet retained-run and scenario minima | pass/fail |
| `validate-evaluator-diversity.sh` | evaluator minima per tuple satisfied | pass/fail |
| `validate-hidden-check-breadth.sh` | hidden-check breadth minima per tuple satisfied | pass/fail |
| `validate-contract-family-version-coherence.sh` | active family version declarations match live artifact usage | pass/fail |
| `validate-projection-shell-boundaries.sh` | workflow shells do not become sole durable approval/evaluator logic | pass/fail |

## 8.4 Required closure reports

The cutover must generate at least the following release-level reports:

- `support-universe-coverage.yml`
- `support-universe-evidence-depth-report.yml`
- `proof-plane-coverage.yml`
- `evaluator-diversity-report.yml`
- `hidden-check-breadth-report.yml`
- `cross-artifact-consistency.yml`
- `review-packet-freshness-report.yml`
- `non-authority-surface-report.yml`
- `contract-family-normalization-report.yml`
- `contract-version-coherence-report.yml`
- `audit-resolution-report.yml`
- `disclosure-calibration-report.yml`
- `host-authority-purity-report.yml`
- `projection-shell-boundary-report.yml`
- `runtime-family-depth-report.yml`
- `continuity-linkage-report.yml`
- `retirement-rationale-report.yml`

## 8.5 Dual-pass recertification logic

The target state requires **two consecutive clean passes**.

### Pass 1
Run the entire validator suite against the staged cutover branch.

### Pass 2
Run the same suite from a clean checkout or freshly materialized workspace.

### Rule
The release is certifiable only if:

- pass 1 clean,
- pass 2 clean,
- no intervening support-target or release-lineage mutation,
- no new evidence drift between passes.

## 8.6 Proof-plane expectations by workload

| Workload class | Required proof planes |
|---|---|
| observe-and-read | structural, functional, governance, maintainability |
| repo-consequential | structural, functional, behavioral, governance, recovery, maintainability |
| boundary-sensitive | structural, functional, behavioral, governance, recovery, maintainability |

## 8.7 Human review expectations

This packet remains machine-first, but not machine-only.

Human sign-off is required for:

- bounded wording changes in active claim-bearing artifacts;
- audit crosswalk final dispositions;
- review packet approval;
- closure certificate issuance.

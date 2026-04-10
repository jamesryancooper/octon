# 05. Repository change manifest

## 5.1 Manifest policy

### Placeholder convention

- `<CUTOVER_DATE>` = the actual promotion date used consistently across the fresh audit bundle, fresh build-to-delete review packet, and new active release bundle.


This packet follows a **minimal-change, full-closure** rule:

- prefer adding missing governance/validation surfaces over redesigning stable families;
- prefer new release bundles over rewriting historical release evidence;
- prefer relabeling/normalizing active claim-bearing artifacts over deleting historical lineage;
- do **not** delete retained historical mirrors/shims unless their continued existence is disproven by ablation and their rationale has been migrated.

## 5.2 Files to add

### New governance / authority-normalization files

- `/.octon/instance/governance/closure/current-audit-crosswalk.yml`
- `/.octon/instance/governance/non-authority-register.yml`
- `/.octon/instance/governance/contracts/non-authority-surface-policy.yml`
- `/.octon/instance/governance/contracts/projection-shell-boundary-policy.yml`
- `/.octon/instance/ingress/manifest.yml`
- `/.octon/instance/governance/contracts/support-dossier-evidence-depth.yml`
- `/.octon/instance/governance/contracts/evaluator-diversity.yml`
- `/.octon/instance/governance/contracts/hidden-check-breadth.yml`

### New validator scripts

Add under `/.octon/framework/assurance/runtime/_ops/scripts/`:

- `validate-bounded-claim-nomenclature.sh`
- `validate-audit-crosswalk.sh`
- `validate-non-authority-register.sh`
- `validate-ingress-manifest-parity.sh`
- `validate-support-dossier-evidence-depth.sh`
- `validate-evaluator-diversity.sh`
- `validate-hidden-check-breadth.sh`
- `validate-review-packet-freshness.sh`
- `validate-retirement-register-depth.sh`
- `validate-contract-family-version-coherence.sh`
- `validate-projection-shell-boundaries.sh`

### New review packet and audit bundle (fresh evidence, not historical rewrite)

- `/.octon/state/evidence/validation/publication/build-to-delete/<CUTOVER_DATE>-bounded-uec-hardening/README.md`
- `/.octon/state/evidence/validation/publication/build-to-delete/<CUTOVER_DATE>-bounded-uec-hardening/drift-review.yml`
- `/.octon/state/evidence/validation/publication/build-to-delete/<CUTOVER_DATE>-bounded-uec-hardening/support-target-review.yml`
- `/.octon/state/evidence/validation/publication/build-to-delete/<CUTOVER_DATE>-bounded-uec-hardening/adapter-review.yml`
- `/.octon/state/evidence/validation/publication/build-to-delete/<CUTOVER_DATE>-bounded-uec-hardening/retirement-review.yml`
- `/.octon/state/evidence/validation/publication/build-to-delete/<CUTOVER_DATE>-bounded-uec-hardening/ablation-deletion-receipt.yml`

- `/.octon/state/evidence/validation/audits/<CUTOVER_DATE>-bounded-uec-hardening-audit/bundle.yml`
- `/.octon/state/evidence/validation/audits/<CUTOVER_DATE>-bounded-uec-hardening-audit/findings.yml`
- `/.octon/state/evidence/validation/audits/<CUTOVER_DATE>-bounded-uec-hardening-audit/coverage.yml`
- `/.octon/state/evidence/validation/audits/<CUTOVER_DATE>-bounded-uec-hardening-audit/convergence.yml`
- `/.octon/state/evidence/validation/audits/<CUTOVER_DATE>-bounded-uec-hardening-audit/evidence.md`
- `/.octon/state/evidence/validation/audits/<CUTOVER_DATE>-bounded-uec-hardening-audit/commands.md`
- `/.octon/state/evidence/validation/audits/<CUTOVER_DATE>-bounded-uec-hardening-audit/validation.md`
- `/.octon/state/evidence/validation/audits/<CUTOVER_DATE>-bounded-uec-hardening-audit/inventory.md`

### New hardened closure release bundle

- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/harness-card.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/gate-status.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/closure-summary.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/closure-certificate.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/recertification-status.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/support-universe-coverage.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/support-universe-evidence-depth-report.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/evaluator-diversity-report.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/hidden-check-breadth-report.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/review-packet-freshness-report.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/non-authority-surface-report.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/contract-family-normalization-report.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/contract-version-coherence-report.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/audit-resolution-report.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/projection-shell-boundary-report.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/support-widening-blockers.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/cross-artifact-consistency.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/proof-plane-coverage.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/projection-parity-report.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/host-authority-purity-report.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/runtime-family-depth-report.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/continuity-linkage-report.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/disclosure-calibration-report.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/retirement-rationale-report.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/residual-ledger.yml`
- `/.octon/state/evidence/disclosure/releases/<CUTOVER_DATE>-uec-bounded-hardening-closure/closure/ablation-review-report.yml`

## 5.3 Files to modify

### Active governance / disclosure / closure files

- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/governance/disclosure/harness-card.yml`
- `/.octon/instance/governance/disclosure/release-lineage.yml`
- `/.octon/instance/governance/closure/unified-execution-constitution.yml`
- `/.octon/instance/governance/closure/unified-execution-constitution-status.yml`
- `/.octon/instance/governance/contracts/closeout-reviews.yml`
- `/.octon/instance/governance/retirement-register.yml`

### Constitutional kernel and family docs

- `/.octon/framework/constitution/claim-truth-conditions.yml`
- `/.octon/framework/constitution/contracts/registry.yml`
- `/.octon/framework/constitution/contracts/objective/README.md`
- `/.octon/framework/constitution/contracts/authority/README.md`
- `/.octon/framework/constitution/contracts/runtime/README.md`
- `/.octon/framework/constitution/contracts/assurance/README.md`
- `/.octon/framework/constitution/contracts/disclosure/README.md`

### Effective/generated active projections

- `/.octon/generated/effective/closure/claim-status.yml`
- `/.octon/generated/effective/closure/recertification-status.yml`
- `/.octon/generated/effective/governance/support-target-matrix.yml`

### Ingress adapter parity surfaces

- `/.octon/instance/ingress/AGENTS.md`
- `/.octon/AGENTS.md`
- `/AGENTS.md`
- `/CLAUDE.md`

### Host projection workflows

- `/.github/workflows/ai-review-gate.yml`
- `/.github/workflows/pr-autonomy-policy.yml`
- `/.github/workflows/architecture-conformance.yml`

### Support dossiers (all admitted tuples)

Modify each live admitted dossier to carry machine-readable sufficiency metadata:

- `/.octon/instance/governance/support-dossiers/repo-shell-observe-read-en/dossier.yml`
- `/.octon/instance/governance/support-dossiers/repo-shell-repo-consequential-en/dossier.yml`
- `/.octon/instance/governance/support-dossiers/repo-shell-boundary-sensitive-en/dossier.yml`
- `/.octon/instance/governance/support-dossiers/github-repo-consequential-en/dossier.yml`
- `/.octon/instance/governance/support-dossiers/ci-observe-read-en/dossier.yml`
- `/.octon/instance/governance/support-dossiers/frontier-studio-boundary-sensitive-es/dossier.yml`

## 5.4 Files to relabel / supersede rather than delete

- `/.octon/state/evidence/disclosure/releases/2026-04-09-uec-hardening-recertification/**` → remains retained historical release evidence once the new hardened bounded release is promoted.
- `/.octon/state/evidence/validation/publication/build-to-delete/2026-04-06/**` → remains retained historical review evidence, but no longer cited as the active latest review packet.

## 5.5 Files to retire or archive in this packet

**None by default.**

This packet does not require deletion to achieve bounded hardened closure. Historical mirrors, shims, and superseded release bundles remain retained evidence or retirement-tracked surfaces. Their governance is strengthened instead of forcing risky deletions.

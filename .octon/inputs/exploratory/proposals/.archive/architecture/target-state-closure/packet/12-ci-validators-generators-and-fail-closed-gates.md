# 12. CI, Validators, Generators, and Fail-Closed Gates

## 1. Goal

Define the exact machine-enforced gates that make closure true by construction.

## 2. Current workflow posture to preserve

Preserve:
- `.github/workflows/architecture-conformance.yml`
- `.github/workflows/deny-by-default-gates.yml`
- `.github/workflows/ai-review-gate.yml`

Do not discard them. Extend and re-bind them.

## 3. Introduce a dedicated closure workflow

Create:
- `.github/workflows/closure-certification.yml`

This workflow becomes the only workflow allowed to promote a release bundle to active claim status.

## 4. Validator suite

Target script path:
- `.octon/framework/assurance/runtime/_ops/scripts/`

Required validators:

### Closure truth and disclosure
- `validate-evidence-classification-schema.sh`
- `validate-evidence-classification-nonempty.sh`
- `validate-disclosure-wording-coherence.sh`
- `validate-release-bundle-freshness.sh`
- `validate-claim-surface-generated-only.sh`
- `validate-projection-byte-parity.sh`

### Cross-artifact consistency
- `validate-cross-artifact-support-tuple-consistency.sh`
- `validate-cross-artifact-capability-pack-consistency.sh`
- `validate-cross-artifact-route-consistency.sh`
- `validate-cross-artifact-support-status.sh`

### Objective and runtime normalization
- `validate-single-canonical-run-contract-family.sh`
- `validate-mission-charter-bindings.sh`
- `validate-stage-attempt-family.sh`
- `validate-run-bundle-completeness.sh`

### Authority and host-boundary enforcement
- `validate-quorum-policy-bindings.sh`
- `validate-host-projection-non-authority.sh`
- `validate-approval-grant-lease-revocation-linkage.sh`

### Proof and lab
- `validate-proof-plane-completeness.sh`
- `validate-evaluator-independence.sh`
- `validate-lab-hidden-check-coverage.sh`
- `validate-adversarial-scenario-coverage.sh`
- `validate-intervention-disclosure-completeness.sh`

### Simplification / build-to-delete
- `validate-no-legacy-active-path.sh`
- `validate-retirement-registry.sh`
- `validate-ablation-receipts.sh`
- `validate-drift-reports.sh`

## 5. Generator suite

Required generators:
- `generate-run-card.sh`
- `generate-harness-card.sh`
- `generate-proof-plane-coverage-report.sh`
- `generate-cross-artifact-consistency-report.sh`
- `generate-support-universe-coverage.sh`
- `generate-claim-drift-report.sh`
- `generate-closure-bundle.sh`
- `generate-closure-projections.sh`
- `generate-release-bundle.sh`

## 6. Workflow integration

### architecture-conformance.yml
Retain as the broad architecture gate.
Add jobs or steps for:
- run-contract family validation
- evidence-classification non-empty validation
- no-legacy-active-path validation
- build-to-delete/retirement validation

### deny-by-default-gates.yml
Retain as protected execution posture gate.
Add steps for:
- host-projection non-authority validation
- unsupported-case routing validation
- support-target pack subset validation

### ai-review-gate.yml
Re-bind as evaluator adapter:
- may emit evaluator findings
- may emit projection receipts
- must not itself define route or support status
- must not be the authoritative source of approval or support state

### closure-certification.yml
New workflow responsibilities:
1. run all closure validators
2. generate candidate release bundle
3. clean workspace / regenerate candidate bundle
4. compare bundle digests and closure outcome
5. write closure certificate only if identical
6. promote active release pointer only after success

## 7. Gate IDs

For clarity in reports:

- `G0` constitutional kernel integrity
- `G1` single canonical run-contract family
- `G2` mission/run binding validity
- `G3` authority artifact integrity
- `G4` evidence classification completeness
- `G5` cross-artifact consistency
- `G6` host projection non-authority
- `G7` proof-plane completeness
- `G8` evaluator independence / hidden checks / lab coverage
- `G9` disclosure wording coherence
- `G10` release bundle freshness and projection parity
- `G11` no legacy active path
- `G12` retirement / ablation / drift governance
- `G13` dual-pass identical closure outcome

These gate IDs should appear in closure bundle reports.

## 8. Fail-closed rule

Any failure in G0–G13:
- prevents `closure-certificate.yml`
- prevents active release promotion
- invalidates any live “complete closure” claim

## 9. Acceptance criteria

- all required validators exist and are wired into CI
- closure certification is a dedicated workflow, not an informal checklist
- live closure cannot be promoted without two identical passes
- host, proof, disclosure, and retirement defects all fail closed

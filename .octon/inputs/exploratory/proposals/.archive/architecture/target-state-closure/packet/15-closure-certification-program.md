# 15. Closure Certification Program

## 1. Purpose

Define the certification regime that proves Octon’s target-state closure claim after cutover.

## 2. Certification principle

Closure is certified by **construction and repetition**, not by narrative confidence.

## 3. Certification inputs

Certification consumes only:
- authored constitutional inputs
- support-target declarations and dossiers
- canonical run/control/evidence roots
- validator outputs
- generated release bundle artifacts

It does **not** consume hand-authored status judgments.

## 4. Mandatory certification gates

Certification requires all of the following:

1. **zero unresolved critical or high audit findings**
2. **no contradictions across truth conditions, status matrices, run bundles, disclosure artifacts, measurement artifacts, and support-target declarations**
3. **regenerated claim-bearing release artifacts from canonical sources**
4. **two consecutive full validation passes with no new issue and identical closure outcome**
5. **non-empty evidence classification for every active proof-bundle exemplar run**
6. **no superseded claim wording in any active claim-bearing artifact**
7. **one canonical run-contract family and binding regime**
8. **all active claim-bearing surfaces are machine-enforced and cross-artifact consistent**
9. **host projections are non-authoritative**
10. **proof-plane completeness and evaluator-independence policy pass**
11. **lab hidden/adversarial coverage policy pass**
12. **no active legacy persona path remains**
13. **retirement / ablation / drift governance passes**

## 5. Certification artifacts

A valid certification writes:

- `closure-certificate.yml`
- `gate-status.yml`
- `closure-summary.yml`
- `support-universe-coverage.yml`
- `proof-plane-coverage.yml`
- `cross-artifact-consistency.yml`
- `claim-drift-report.yml`
- `projection-parity-report.yml`
- final `harness-card.yml`

All under the active release bundle root.

## 6. Certification roles

### CI system
- executes validators and generators
- computes dual-pass equivalence
- fails closed on contradiction

### Governance owner
- approves release-lineage promotion only after successful certificate

### Independent evaluator / reviewer
- confirms evaluator-independence policy and intervention disclosure were met
- does not author the certificate by hand

### Runtime / architecture owners
- remediate any failed gate
- do not override failed gates manually

## 7. Recertification triggers

Re-certification is required whenever any of the following changes:
- constitutional charter or truth conditions
- support-target matrix
- active model adapter
- active host adapter
- active capability pack policy
- proof-plane policy
- hidden-check or adversarial policy
- canonical run-contract family
- evidence-retention contract
- any active proof-bundle exemplar run is replaced

## 8. Certification invalidators

Even after certification, the claim becomes invalid if:
- an active proof-bundle exemplar run later becomes contradictory
- a stable mirror drifts from its release bundle source
- support-targets widen without dossier + recertification
- superseded wording appears in active claim surfaces
- a critical or high drift report remains unresolved

## 9. Acceptance criteria

Certification is complete only when:
- a closure certificate exists for the active release
- active release mirrors are parity-valid
- all mandatory gates passed twice identically
- release-lineage points to the certified bundle
- no invalidator is present

# Hardening-Close and Recertification Checklists

## 1. Maintainer checklist — before release branch cut

- [ ] No support-target widening in this release.
- [ ] No new adapter families admitted.
- [ ] No new capability packs admitted.
- [ ] `framework/constitution/**` unchanged except documented hardening-facing clarifications.
- [ ] All claim-critical validators are present in-tree.
- [ ] Dossier / admission / proof / lab reference updates are merged.
- [ ] Host adapter contracts and workflow projections are aligned.
- [ ] RunCard generator updated for artifact-depth summaries.
- [ ] Authored HarnessCard source updated with known limits.
- [ ] Retirement register updated with retained vs retired rationale.
- [ ] Claim-adjacent transitional surfaces have explicit closeout dispositions.

## 2. Claim-critical hardening-close checklist

### CC-01 — lab reference integrity
- [ ] authored scenario registry is updated
- [ ] every required scenario in every admitted dossier resolves through the registry
- [ ] every cited proof-plane scenario resolves to retained lab evidence or `not_required`
- [ ] two consecutive green `lab-reference-integrity` runs

### CC-02 — host authority purity
- [ ] no workflow uses label/comment/check as sufficient approval
- [ ] all host status projections cite canonical authority artifacts
- [ ] two consecutive green `host-authority-purity` runs

### CC-03 — runtime family depth
- [ ] every admitted run class passes stage-attempt completeness
- [ ] every admitted run class passes checkpoint linkage
- [ ] continuity applicability is explicit for every admitted run class
- [ ] contamination / retry posture is explicit for every admitted run class
- [ ] two consecutive green runtime-family depth runs

### CC-04 — disclosure calibration
- [ ] residual ledger exists
- [ ] HarnessCard `known_limits` aligns with residual ledger
- [ ] generated/effective closure projections remain in parity
- [ ] two consecutive green disclosure-calibration runs

### CC-05 — retirement / retain-rationale discipline
- [ ] every transitional, shim, or mirror surface remaining in-tree is listed in the retirement register
- [ ] every claim-adjacent transitional surface is marked `retired`, `demoted`, or `retained_with_rationale`
- [ ] closure bundle includes a retirement-rationale report
- [ ] two consecutive green `retirement-rationale` runs

## 3. Non-critical closeout checklist

- [ ] support-universe evidence-depth report exists
- [ ] evaluator coverage summary exists
- [ ] at least one boundary-sensitive tuple has strengthened behavioral/recovery evidence this cycle
- [ ] at least one transitional surface is retired or demoted, or explicit rationale says why not
- [ ] residual ledger records all non-critical open items with target release

## 4. Release certification checklist

- [ ] zero unresolved claim-critical items
- [ ] every non-critical residual item has `closed` or `retained_with_rationale`
- [ ] all release closure reports are green
- [ ] parity report is green
- [ ] authored HarnessCard and release HarnessCard match
- [ ] new release added to release-lineage as active only after certification
- [ ] current release demoted to historical with explicit reason

## 5. Conditions that block certification immediately

- [ ] any host-only approval path detected
- [ ] any unresolved lab-reference integrity failure
- [ ] any missing required runtime-family artifact for admitted tuples
- [ ] any authored disclosure that still overstates `known_limits`
- [ ] any support-target widening merged into the same release
- [ ] any claim-adjacent transitional surface left without explicit retain-vs-retire rationale

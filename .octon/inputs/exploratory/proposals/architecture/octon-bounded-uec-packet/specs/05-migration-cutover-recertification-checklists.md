# Migration, Cutover, and Recertification Checklists

## Stage 0 — Immediate honesty patch

- [ ] Create `2026-04-11-uec-bounded-recertification-open` release bundle.
- [ ] Update `release-lineage.yml` active release.
- [ ] Supersede the 2026-04-09 complete-claim release.
- [ ] Downgrade authored HarnessCard wording.
- [ ] Update closure and generated/effective claim status surfaces.
- [ ] Publish blocker register and traceability matrix.
- [ ] Confirm there is only one active release.

## Stage 1 — Quarantine contaminated exemplar lineage

- [ ] Identify every active claim-bearing reference to `uec-bounded-repo-shell-boundary-sensitive-20260409`.
- [ ] Remove or supersede those references.
- [ ] Decide whether to preserve as historical exercise evidence or normalize in place.
- [ ] If preserving provenance, mark as non-claim-bearing historical exercise lineage.
- [ ] Open fresh clean boundary-sensitive exemplar run.

## Stage 2 — Authority normalization

- [ ] Add ledger coherence validator.
- [ ] Add no-exercise-residue validator.
- [ ] Add run-card parity validator.
- [ ] Validate all claim-bearing authority artifacts.
- [ ] Produce release-level authority reports.

## Stage 3 — Runtime/evidence hardening

- [ ] Ship `instruction-layer-manifest-v2` contract.
- [ ] Ship `run-evidence-classification-v2` contract.
- [ ] Add validators.
- [ ] Backfill all claim-bearing runs.
- [ ] Add run disclosure manifests.
- [ ] Fail CI on skeletal artifacts.

## Stage 4 — Workflow / host non-authority proof

- [ ] Audit `.github/workflows/**` listed in the packet.
- [ ] Remove label/check/env-only authority behavior.
- [ ] Add negative-path tests.
- [ ] Generate host projection purity and workflow derivation reports.

## Stage 5 — Proof-plane equalization

- [ ] Confirm structural proof closed for all admitted tuples.
- [ ] Add missing functional run evidence.
- [ ] Add behavioral lab evidence and hidden checks.
- [ ] Add maintainability drift / stale-doc / simplification evidence.
- [ ] Add recovery drills and replay-integrity evidence.
- [ ] Regenerate proof-plane coverage matrix.

## Stage 6 — Support-target closure

- [ ] Confirm each admitted tuple has admission + dossier + adapter + pack + proof + disclosure.
- [ ] Confirm every consequential or boundary-sensitive tuple has a clean exemplar run bundle.
- [ ] Regenerate support-target coverage report.
- [ ] If gaps remain, decide whether to continue full-universe hardening or narrow public claim scope.

## Stage 7 — Agency and retirement hardening

- [ ] Audit agency and ingress surfaces.
- [ ] Update non-authority register.
- [ ] Generate overlay containment report.
- [ ] Run retirement / build-to-delete scan.
- [ ] Generate build-to-delete and shim-retention reports.

## Stage 8 — Dual-pass recertification

### Pass A

- [ ] Clean environment
- [ ] Full validator suite green
- [ ] Fresh run bundles generated
- [ ] Fresh release closure bundle generated
- [ ] No closure blockers open

### Pass B

- [ ] Fresh clean environment again
- [ ] Full validator suite green again
- [ ] Fresh bundles generated again
- [ ] Dual-pass diff report produced
- [ ] No material divergence beyond allowed timestamp/digest changes

## Stage 9 — Complete-claim cutover

- [ ] Mint new recertified-complete release bundle.
- [ ] Update active release lineage.
- [ ] Update closure file to `claim_status: complete`.
- [ ] Update authored HarnessCard to permitted complete wording.
- [ ] Regenerate effective closure status projections.
- [ ] Publish final closure certificate.
- [ ] Preserve recertification-open bundle as superseded lineage.

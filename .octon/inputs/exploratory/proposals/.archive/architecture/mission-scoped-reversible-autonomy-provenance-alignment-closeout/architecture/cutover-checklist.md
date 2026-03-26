# Cutover Checklist

This checklist operationalizes the provenance closeout for one atomic branch.

## Branch readiness

- [ ] Repo baseline confirmed at `0.6.3` in `version.txt` and `/.octon/octon.yml`
- [ ] Residual gap inventory recorded from archive manifests, registry, ADRs, and migration records
- [ ] No-change zones explicitly locked
- [ ] Archived steady-state and final-closeout proposal packets identified as the normalization targets
- [ ] Final authoritative target paths for ADR, migration plan, and evidence bundle chosen

## Pre-merge implementation

- [ ] Archived steady-state proposal manifest normalized to archived lifecycle metadata
- [ ] Archived final-closeout proposal manifest normalized to archived lifecycle metadata
- [ ] One new provenance-closeout ADR drafted
- [ ] One matching provenance-closeout migration plan drafted
- [ ] Migration evidence-bundle contract prepared
- [ ] Decision index updated
- [ ] Migration index updated
- [ ] Generated proposal registry refreshed
- [ ] README, START, and architecture docs updated to point to canonical runtime/governance truth first
- [ ] Proposal-local source-of-truth and change-map artifacts updated to match the intended promotion

## Pre-merge proof

- [ ] `validate-proposal-standard.sh --all-standard-proposals` passes
- [ ] `validate-architecture-proposal.sh` passes
- [ ] `generate-proposal-registry.sh --check` passes
- [ ] `validate-version-parity.sh` passes
- [ ] `validate-architecture-conformance.sh` passes
- [ ] `alignment-check.sh --profile harness,mission-autonomy` passes
- [ ] Diff inventory proves no runtime or policy semantic surfaces changed
- [ ] Registry output includes the normalized archived MSRAOM packets
- [ ] ADR and migration indexes resolve to real records

## In-merge atomic checks

- [ ] No MSRAOM packet still reads as active implementation guidance if it is historical only
- [ ] No archived MSRAOM packet still declares `status: draft`
- [ ] No generated registry entry contradicts archive manifests
- [ ] No canonical doc requires readers to infer closeout from runtime alone
- [ ] No historical ADR was rewritten instead of superseded append-only
- [ ] No current proposal packet is archived before the final closeout transaction

## Post-merge ratification

- [ ] This implementing proposal is archived in the same transaction as the durable provenance-closeout records
- [ ] The migration evidence bundle contains `bundle.yml`, `evidence.md`, `commands.md`, `validation.md`, and `inventory.md`
- [ ] Future MSRAOM questions are answerable from runtime/governance roots plus the provenance-closeout ADR and migration record
- [ ] No follow-on provenance-remediation packet is required

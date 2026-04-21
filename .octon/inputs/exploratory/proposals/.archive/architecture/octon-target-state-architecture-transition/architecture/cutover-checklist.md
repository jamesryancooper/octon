# Cutover Checklist

## Before implementation

- [ ] Confirm proposal path equals `proposal_id`.
- [ ] Confirm `proposal.yml` and `architecture-proposal.yml` are valid.
- [ ] Confirm all promotion targets are `.octon/**` and outside this proposal tree.
- [ ] Select `change_profile` and `release_state` per ingress profile governance.
- [ ] Snapshot current validation status.

## Slice A — Hygiene

- [ ] Deduplicate fail-closed rule IDs.
- [ ] Deduplicate evidence obligation IDs.
- [ ] Add ID validators.
- [ ] Remove active-doc historical/projection conflicts.
- [ ] Retain validation evidence.

## Slice B — Registry and maps

- [ ] Extend contract registry.
- [ ] Publish generated architecture map definitions.
- [ ] Generate materialized maps as non-authoritative read models.
- [ ] Retain publication receipts and freshness artifacts.

## Slice C — Authorization coverage

- [ ] Add side-effect inventory.
- [ ] Add coverage map.
- [ ] Add coverage validator.
- [ ] Add negative-control tests.
- [ ] Retain coverage evidence.

## Slice D — Runtime refactor

- [ ] Split kernel modules.
- [ ] Add request builders.
- [ ] Split authority phases.
- [ ] Add phase-result schema.
- [ ] Run smoke tests and phase tests.

## Slice E — Proof and support

- [ ] Add evidence completeness receipts.
- [ ] Add support proof bundle requirements.
- [ ] Raise support dossier sufficiency.
- [ ] Generate SupportCard and HarnessCard projections.
- [ ] Retain support proof evidence.

## Slice F — Retirement

- [ ] Add compatibility inventory.
- [ ] Assign owners/consumers/expiry.
- [ ] Migrate consumers.
- [ ] Remove or retain shims according to validation status.

## Closeout

- [ ] Full validation plan passes.
- [ ] ADR created.
- [ ] Promotion evidence retained.
- [ ] Proposal path dependency scan passes.
- [ ] Packet can be archived.

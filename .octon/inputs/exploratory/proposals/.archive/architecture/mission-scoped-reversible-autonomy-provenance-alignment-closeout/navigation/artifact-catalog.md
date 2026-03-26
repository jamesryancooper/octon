# Artifact Catalog

This catalog lists the files currently present in this proposal package. The
current v1 proposal standard still requires this file even though this packet's
target architecture treats proposal discovery as generated projection rather
than manual inventory.

## Proposal

- `proposal_id`: `mission-scoped-reversible-autonomy-provenance-alignment-closeout`
- `proposal_kind`: `architecture`
- `proposal_path`: `.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-provenance-alignment-closeout`

## Files

| Path | Role |
| --- | --- |
| `README.md` | Entry point, purpose, reading order, and exit path |
| `proposal.yml` | Base proposal manifest |
| `architecture-proposal.yml` | Architecture subtype manifest |
| `navigation/artifact-catalog.md` | Required package inventory artifact |
| `navigation/source-of-truth-map.md` | Proposal-local authority and discovery map |
| `navigation/change-map.md` | Explicit change and no-change boundaries for the cutover |
| `architecture/target-architecture.md` | Intended post-closeout provenance state |
| `architecture/implementation-plan.md` | Ordered atomic implementation plan |
| `architecture/validation-plan.md` | Proof contract for the provenance closeout |
| `architecture/acceptance-criteria.md` | Final promotion gates |
| `architecture/cutover-checklist.md` | Operational closeout checklist |
| `resources/implementation-audit.md` | Baseline evidence that runtime closeout is already complete |
| `resources/current-state-traceability-gap.md` | Observed post-0.6.3 provenance gap summary |
| `resources/provenance-alignment-plan.md` | High-level target-state alignment rules |
| `resources/archive-and-decision-map.md` | Target lineage across archive, ADR, and migration surfaces |
| `resources/file-level-change-map.md` | Durable surface inventory for promotion |

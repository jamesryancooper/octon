# Publication Validation Receipts

`state/evidence/validation/publication/**` is the canonical retained receipt
family for runtime-facing effective publication runs.

## Families

| Family | Canonical path | Purpose |
| --- | --- | --- |
| Locality publication | `.octon/state/evidence/validation/publication/locality/` | Receipts for effective locality publication, quarantine, and fail-closed blocking |
| Extension publication | `.octon/state/evidence/validation/publication/extensions/` | Receipts for desired/actual/quarantine/compiled extension publication outcomes |
| Capability publication | `.octon/state/evidence/validation/publication/capabilities/` | Receipts for capability-routing publication and upstream-generation coherence |

## Rules

- Each publication run writes exactly one machine-readable receipt per family.
- Receipt filenames use `<timestamp>-<generation-id>.yml`.
- Receipts remain retained evidence even when the publication result is
  `blocked`, `published_with_quarantine`, or `withdrawn`.


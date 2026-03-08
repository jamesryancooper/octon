# Evidence Notes

## Target Resolution

- Target path exists:
  `.design-packages/orchestration-domain-design-package`
- Mode selected: `observed`

## Inventory Facts

- Total files under target: `52`
- Markdown files under target: `52`
- Non-Markdown files under target: `0`

## Key Evidence Points

### Decision Evidence Gap

- `.design-packages/orchestration-domain-design-package/contracts/decision-record-contract.md`
  defines `continuity/decisions/<decision-id>/decision.json` as required.
- `.design-packages/orchestration-domain-design-package/canonicalization-target-map.md`
  treats `continuity/decisions/` as a future shared continuity target.
- `.harmony/continuity/_meta/architecture/continuity-plane.md`
  currently canonizes `log.md`, `tasks.json`, `entities.json`, `next.md`, and
  append-oriented `runs/`, but not `decisions/`.
- On-disk check:
  `.harmony/continuity/decisions` is `missing`.

### Incident Governance Mismatch

- `.design-packages/orchestration-domain-design-package/normative-dependencies-and-source-of-truth-map.md`
  points incident governance to `.harmony/orchestration/governance/incidents.md`.
- `.harmony/orchestration/governance/incidents.md`
  is a production rollback runbook centered on deploy rollback and feature flags.
- `.design-packages/orchestration-domain-design-package/contracts/incident-object-contract.md`
  expects a generic incident object lifecycle, closure rules, and operator or
  policy-backed authority.

### Validation Proof Gap

- `.design-packages/orchestration-domain-design-package/assurance-and-acceptance-matrix.md`
  requires contract validation, scenario proof, and gate passage.
- `.design-packages/orchestration-domain-design-package/canonicalization-target-map.md`
  names future validation scripts for promoted surfaces.
- No machine-readable schemas, fixtures, or validators are present in the
  audited package today.

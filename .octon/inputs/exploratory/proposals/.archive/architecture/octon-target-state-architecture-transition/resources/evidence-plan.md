# Evidence Plan

## Retained evidence root

All promotion evidence for this packet lands under:

`/.octon/state/evidence/validation/architecture-target-state-transition/**`

## Required evidence bundles

| Bundle | Required contents |
|---|---|
| `proposal-validation/` | Proposal standard and architecture proposal subtype validation. |
| `identifier-hygiene/` | FCR/EVI uniqueness reports and renumbering trace. |
| `architecture-conformance/` | Registry/doc/placement validator results. |
| `authorization-coverage/` | Side-effect inventory, coverage map, uncovered-path report, negative-control results. |
| `runtime-refactor/` | Runtime command smoke tests, phase tests, behavior parity notes. |
| `generated-effective-freshness/` | Publication receipts and stale-generated negative-control results. |
| `proof-completeness/` | Evidence completeness receipts for sample consequential run. |
| `support-targets/` | Tuple proof bundles, SupportCard generation, dossier validation. |
| `compatibility-retirement/` | Shim inventory, owner/consumer/expiry, dependency scan, retirement-ready list. |
| `active-doc-hygiene/` | Active-doc hygiene report and projection-language reconciliation. |
| `closure/` | Closure certification and ADR reference. |

## Evidence quality rules

- Evidence may cite this packet as provenance but not as authority.
- RunCards, HarnessCards, and SupportCards must derive from retained evidence and durable authority only.
- CI transport artifacts are not retained evidence unless copied or summarized under `state/evidence/**` with traceability.
- Generated maps require publication receipts and freshness artifacts.

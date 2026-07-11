---
disclosure_status: externally-shareable-after-maintainer-review
authority_mode: non-authoritative
external_transmission_approved: false
---

# Authority And Information Boundaries

| Surface | Architectural role | May contain sensitive information | Public by default | Runtime authority |
| --- | --- | --- | --- | --- |
| `framework/**` | Portable authored core | Yes | No; clearance required | Yes, after normal framework governance |
| `instance/**` | Repository-specific authored authority | Yes | No | Yes for admitted project authority |
| `inputs/additive/.incoming/**` | Raw intake | Yes | No | Never |
| `inputs/additive/extensions/**` | Normalized extension source | Yes | No; separate pack review | Only after activation and publication |
| `inputs/exploratory/**` | Ideation, proposals, plans, syntheses, reports | Yes | No | Never directly |
| `state/control/**` | Mutable operational truth | Yes | No | Operational control only |
| `state/evidence/**` | Retained proof and receipts | Yes | No; classified derivatives only | Evidence, not policy |
| `state/continuity/**` | Active handoff state | Yes | No | Operational continuity |
| `generated/**` | Derived effective output and read models | Yes | No | Derived; cannot mint authority |
| Host projections | Tool-facing copies | Yes | No | Projection only |
| Public export | Cleared generated distribution | Only after review | Yes after publication | Distribution source, not project instance authority |

## Required Distinctions

- Repository-specific does not mean proprietary by definition.
- Private does not establish legal ownership or redistribution rights.
- Non-authoritative does not mean safe to disclose.
- Generated does not mean insensitive.
- Evidence classification does not change policy authority.
- Publication clearance does not make a proposal authoritative.
- Proposal acceptance does not authorize external effects.

## Promotion Model

Raw input may inform a governed change. Only a separately accepted,
implemented, validated, and promoted change can alter durable authority.
Generated publication and runtime views are rebuilt from admitted source and
remain bounded by their contracts.

Sources: `SRC-001`, `SRC-002`, `SRC-009`, and `SRC-010`.


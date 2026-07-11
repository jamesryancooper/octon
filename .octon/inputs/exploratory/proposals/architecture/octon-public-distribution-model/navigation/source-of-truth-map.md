# Source Of Truth Map

| Concern | Proposal source | Durable or operational source | Authority |
| --- | --- | --- | --- |
| Adopted baseline | `resources/conversation-decision-synthesis.md` | Later promoted contracts and maintainer decisions | Proposal resource is non-authoritative |
| Decision ownership | `resources/decision-to-packet-traceability.yml` | Child promotion targets and receipts | Coordination only |
| Child registry | `resources/child-packet-index.yml` | Child manifests and lifecycle records | Parent sequencing only |
| Blocker model | `resources/first-release-blocker-map.yml` | Fresh child validation evidence | Parent cannot override |
| External effects | `resources/external-effects-boundary.md` | Platform state and maintainer receipts | Human or platform authority |
| Runtime behavior | Child target architecture | Promoted framework or repo-local files | No runtime authority yet |
| Evidence | Proposal summaries | `.octon/state/evidence/**` or truthful local custody | Proposal copy is not retained evidence |
| Generated output | None | Rebuilt manifests, trees, candidates, and read models | Derived only |


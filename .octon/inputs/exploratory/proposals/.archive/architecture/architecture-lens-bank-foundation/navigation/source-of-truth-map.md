# Source-of-Truth Map

| Claim class | Source of truth | Note |
| --- | --- | --- |
| Conversation-derived suite intent | `.octon/inputs/additive/.incoming/architecture-review-method-suite/` | Non-authoritative raw intake; lineage only |
| Lens bank design (18 lenses, tiers, profiles, sprawl controls) | Parent `architecture/lens-bank-design.md`, preserved in `resources/source-context.md` | Direction for this child; child re-grounds against live repo |
| Per-child charter and obligations | Parent `architecture/child-packet-contract.md` | Coordination direction, non-authoritative |
| Registry facts (phase, dependencies, write scopes) | Parent `resources/child-packet-index.yml` | Proposal-local coordination authority only |
| Existing review doctrine, routing, naming | `.octon/framework/cognition/practices/methodology/architectural-review/` | Live authority; outranks every program/packet claim about it |
| Balanced required sequence and output contract | `.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md` | Live authority; expressed as lens ids without editing it |
| Existing architectural-review validators | `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-*.sh` | Convention model for the new lens-reference validator |
| Durable lens bank after promotion | `.octon/framework/cognition/practices/methodology/architectural-review/architecture-lens-bank.md`, `.../lens-bank.yml` | Authored at implementation; the durable authority |
| Durable validator after promotion | `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lens-references.sh` | Authored at implementation |
| Child lifecycle state | `proposal.yml#status` | draft until governed review/acceptance |
| Child lifecycle evidence | `.octon/state/evidence/validation/proposals/architecture-lens-bank-foundation/` | Child-owned; parent evidence never substitutes |
| Live repository facts | The repository at HEAD | Outranks all packet summaries (epistemic precedence) |

Nothing in this packet is authority. Where any statement here disagrees with the
live repository or constitutional surfaces, those win and this packet's docs need
revision. Where the parent program design disagrees with the live mechanism, the
child triggers a parent registry/design revision rather than implementing a stale
claim.

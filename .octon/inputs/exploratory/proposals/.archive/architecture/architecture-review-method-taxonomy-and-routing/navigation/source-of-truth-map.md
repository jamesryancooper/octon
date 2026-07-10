# Source-of-Truth Map

| Claim class | Source of truth | Note |
| --- | --- | --- |
| Conversation-derived suite intent | `.octon/inputs/additive/.incoming/architecture-review-method-suite/` | Non-authoritative raw intake; lineage only |
| Method taxonomy and per-method contracts | Parent `architecture/method-taxonomy.md`, preserved in `resources/source-context.md` | Direction for this child; child re-grounds against live repo |
| Naming v2 / routing v2 direction | Parent `architecture/target-architecture.md` and `child-packet-contract.md` §per-child charter | Coordination direction, non-authoritative |
| Per-child charter and obligations | Parent `architecture/child-packet-contract.md` | Coordination direction, non-authoritative |
| Registry facts (phase, dependencies, write scopes) | Parent `resources/child-packet-index.yml` | Proposal-local coordination authority only |
| Existing naming model | `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml` | Live authority; v1 today; outranks every program/packet claim about it |
| Existing routing model | `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml` | Live authority; v1 today |
| Existing mechanism README and canonical-names table | `.octon/framework/cognition/practices/methodology/architectural-review/README.md` | Live authority; table is extended, not rewritten |
| Balanced doctrine and default status | `.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md` | Live authority; cross-referenced, doctrine unchanged |
| Verified lens bank and canonical/provisional method slugs | `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml` (phase-0 output) | Live authority; its `suite_methods` slugs bind this child's canonical slugs |
| Existing architectural-review validators | `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-*.sh` | Convention model and extension targets for naming/routing validators |
| Durable naming/routing/README/Balanced after promotion | The four methodology files listed in `architecture/file-change-map.md` | Authored at implementation; the durable authority |
| Child lifecycle state | `proposal.yml#status` | draft until governed review/acceptance |
| Child lifecycle evidence | `.octon/state/evidence/validation/proposals/architecture-review-method-taxonomy-and-routing/` | Child-owned; parent evidence never substitutes |
| Live repository facts | The repository at HEAD | Outranks all packet summaries (epistemic precedence) |

Nothing in this packet is authority. Where any statement here disagrees with the
live repository or constitutional surfaces, those win and this packet's docs need
revision. Where the parent program design disagrees with the live mechanism, the
child triggers a parent registry/design revision rather than implementing a stale
claim — see `architecture/slug-reconciliation-decision.md` for the one recorded
divergence (companion method slugs).

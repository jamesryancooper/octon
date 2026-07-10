# Source-of-Truth Map

| Claim class | Source of truth | Note |
| --- | --- | --- |
| Conversation-derived suite intent | `.octon/inputs/additive/.incoming/architecture-review-method-suite/` | Non-authoritative raw intake; lineage only |
| Greenfield method contract (question, sections, non-goals, escalation) | Parent `architecture/method-taxonomy.md` §2, preserved in `resources/source-context.md` | Direction for this child; child re-grounds against live repo |
| Per-child charter and obligations | Parent `architecture/child-packet-contract.md` (greenfield charter + common obligations) | Coordination direction, non-authoritative |
| Registry facts (phase, dependencies, write scope) | Parent `resources/child-packet-index.yml` | Proposal-local coordination authority only |
| Method name/slug and catalog placement | `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml` `methods.catalog` (phase-1) | Live authority; the greenfield slug is `greenfield-reference-architecture-review-method`; this child adds only the `doc:` reference |
| Method-selection routing and escalation | `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml` `method_selection` (phase-1) | Live authority; the doc cites the escalation map, does not modify it |
| Greenfield lens profile (required/optional lens ids) | `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml` `method_profiles.greenfield-reference-architecture-review-method` (phase-0) | Live authority; the doc cites these lens ids verbatim and defines no private catalog |
| Lens doctrine (human-readable) | `.octon/framework/cognition/practices/methodology/architectural-review/architecture-lens-bank.md` (phase-0) | Live authority; consumed, not modified |
| Balanced doctrine and clean-sheet lens usage | `.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md` | Live authority; the greenfield doc contrasts with it; Balanced doctrine unchanged |
| Existing mechanism README and canonical-names table | `.octon/framework/cognition/practices/methodology/architectural-review/README.md` | Live authority; this child appends one references link, does not rewrite the table |
| Adjacent doctrine boundaries (readiness, surface audit) | `architecture-readiness/`, `audits/surface-architecture.md` | Live authority; cited as composition boundaries, never modified |
| Durable Greenfield doc after promotion | `greenfield-reference-architecture-review-method.md` (per `architecture/file-change-map.md`) | Authored at implementation; the durable authority |
| Child lifecycle state | `proposal.yml#status` | draft until governed review/acceptance |
| Child lifecycle evidence | `.octon/state/evidence/validation/proposals/greenfield-reference-architecture-review-method/` | Child-owned; parent evidence never substitutes |
| Live repository facts | The repository at HEAD | Outranks all packet summaries (epistemic precedence) |

Nothing in this packet is authority. Where any statement here disagrees with the
live repository or constitutional surfaces, those win and this packet's docs need
revision. Where the parent program design disagrees with the live mechanism, the
child triggers a parent registry/design revision rather than implementing a stale
claim. No such blocking divergence was found at HEAD — the greenfield slug,
routing entry, and lens profile all exist and agree; see
`architecture/current-state-gap-map.md`.

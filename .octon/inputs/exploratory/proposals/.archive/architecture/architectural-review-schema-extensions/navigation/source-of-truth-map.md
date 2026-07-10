# Source-of-Truth Map

| Claim class | Source of truth | Note |
| --- | --- | --- |
| Conversation-derived suite intent | `.octon/inputs/additive/.incoming/architecture-review-method-suite/` | Non-authoritative raw intake; lineage only |
| Method-report / routing-decision schema direction | Parent `architecture/method-taxonomy.md` ("every method report records the method slug and the lens profile actually applied"), preserved in `resources/source-context.md` | Direction for this child; child re-grounds against live repo |
| v2 schema-extension direction | Parent `architecture/target-architecture.md` and `child-packet-contract.md` §per-child charter | Coordination direction, non-authoritative |
| Per-child charter and obligations | Parent `architecture/child-packet-contract.md` | Coordination direction, non-authoritative |
| Registry facts (phase, dependencies, write scopes) | Parent `resources/child-packet-index.yml` | Proposal-local coordination authority only |
| Existing v1 report schema | `.octon/framework/constitution/contracts/assurance/architectural-review-report-v1.schema.json` | Live authority; retained unchanged; the v2 superset baseline |
| Existing v1 routing-decision schema | `.octon/framework/constitution/contracts/assurance/architectural-review-routing-decision-v1.schema.json` | Live authority; retained unchanged; the v2 superset baseline |
| Support-receipt schema | `.octon/framework/constitution/contracts/assurance/architectural-review-support-receipt-v1.schema.json` | Live authority; **left untouched**; validator asserts it stays v1 |
| contracts/assurance schema index | `.octon/framework/constitution/contracts/assurance/README.md` | Live authority; extended to list the two v2 schemas, not rewritten |
| Canonical method slugs | `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml` `methods` catalog (phase-1 output) | Live authority; the v2 `method` enum binds to these six slugs |
| Lens ids for `lenses_applied` | `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml` (phase-0 output) | Live authority; `lenses_applied` ids must be declared here |
| `missing_method_record` fail-closed intent | `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml` (phase-1 output) | Live authority; this child completes the schema-level `method` record it anticipated |
| Receipts validator | `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh` | Convention model and extension target for v2 awareness |
| Durable v2 schemas + validator after promotion | The files listed in `architecture/file-change-map.md` | Authored at implementation; the durable authority |
| Child lifecycle state | `proposal.yml#status` | draft until governed review/acceptance |
| Child lifecycle evidence | `.octon/state/evidence/validation/proposals/architectural-review-schema-extensions/` | Child-owned; parent evidence never substitutes |
| Live repository facts | The repository at HEAD | Outranks all packet summaries (epistemic precedence) |

Nothing in this packet is authority. Where any statement here disagrees with the
live repository or constitutional surfaces, those win and this packet's docs need
revision. Where the parent program design disagrees with the live mechanism, the
child triggers a parent registry/design revision rather than implementing a stale
claim.

# Child Packet Index (Human View)

Machine registry: `child-packet-index.yml` (schema
`octon-proposal-program-child-registry-v2`, execution mode `gated-parallel`).
All child packets are **planned sibling packets** at
`.octon/inputs/exploratory/proposals/architecture/<child-id>/` — none exist
yet; none may nest under this parent program.

| Child id | Phase | Deps | Required | What it owns |
| --- | --- | --- | --- | --- |
| `architecture-lens-bank-foundation` | phase-0 | none | yes (seed reference) | Authors `architecture-lens-bank.md` + `lens-bank.yml` (18 lenses, two tiers, per-method profiles) and the new lens-reference validator with negative controls. The foundation every method profile cites. |
| `architecture-review-method-taxonomy-and-routing` | phase-1 | `architecture-lens-bank-foundation` | yes | Refactors `naming.yml` to a methods list (schema v2), extends `review-routing.yml` with method-selection semantics and fail-closed `unknown_method` behavior (schema v2), extends the mechanism README canonical-names table, adds minimal lens/escalation cross-references to the Balanced method doc, and updates the naming/routing validators with negative controls. |
| `greenfield-reference-architecture-review-method` | phase-2 | taxonomy-and-routing | yes | Authors the Greenfield Reference Architecture Review method doc: five required output sections, initial-build sequencing, minimum viable architecture, what-not-to-build list, clean-sheet-lens relationship, escalation rules; reference-architecture-only output boundary. |
| `companion-architecture-review-methods` | phase-2 | taxonomy-and-routing | yes | Authors the four companion method docs (Tradeoff, Failure-Mode, Evolution/Fitness, Boundary/Authority) with identical contract shape: question, use cases, non-goals, required inputs, outputs, lens profile reference, escalation rules; includes the no-duplication boundary statements against readiness and surface-audit doctrine. |
| `architectural-review-schema-extensions` | phase-2 | taxonomy-and-routing | yes | Adds additive v2 report and routing-decision schemas (`method`, `lenses_applied`), keeps the support receipt schema untouched, and extends the receipts validator with negative controls. |
| `architectural-review-suite-integration` | phase-3 | greenfield method, companion methods, schema extensions | yes | Method-id recording in existing review workflow contracts, product feature note and governed-mechanism entry extensions, proposal-lifecycle advisory text (no gate changes), generated projection refresh through canonical publishers, and the full architectural-review validator sweep. |
| `architecture-review-command-facades` | phase-3 | suite-integration | **conditional** | Command/skill facades for direct method invocation, only if operator demand is demonstrated; otherwise the program records a no-action rationale at closeout. |

Excluded by design: architecture-readiness methodology and
surface-architecture audit doctrine (composed with, never modified);
Boundary/Authority generic (adopted-repo) mode (deferred with recorded owner
and trigger at closeout); any new routed workflow mode, lifecycle gate, or
review-output authority (rejected in `architecture/intake-evaluation.md`).

Intake "likely child packets" coverage: items 1–2 → the two foundation
children; item 3 → greenfield child; item 4 → companion-methods child;
item 5 → schema-extensions child; items 6–8 → suite-integration plus the
conditional command-facades child. Nothing from the intake is silently
dropped; dispositions are recorded in `architecture/intake-evaluation.md`.

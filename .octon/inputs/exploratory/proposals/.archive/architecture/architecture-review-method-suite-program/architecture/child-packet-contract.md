# Child Packet Contract

Every child of this program is an independent, manifest-governed proposal
packet at its canonical sibling path
`.octon/inputs/exploratory/proposals/architecture/<child-id>/`. Children are
never nested under this parent. The parent coordinates; it does not own.

## Obligations Every Child Must Meet

1. **Independent validity.** Each child passes
   `validate-proposal-standard.sh` and its subtype validator at its own
   path, with its own `proposal.yml`, subtype manifest, README, navigation
   docs, and required working docs.
2. **Own receipts.** Creation, review, implementation, verification, and
   closeout receipts are child-local. Parent program evidence, this
   contract, and the registry never satisfy a child receipt, promotion
   target, validation verdict, or archive metadata.
3. **Source grounding.** Each child cites the non-authoritative intake unit
   (`.octon/inputs/additive/.incoming/architecture-review-method-suite/`)
   and this program's design docs as lineage only, and re-grounds every
   claim against the live repository before proposing changes. Where a
   program design doc disagrees with the live repository, the repository
   wins and the child triggers a program registry/design revision instead
   of implementing the stale claim.
4. **Validation floor.** Before implementation planning, each child defines:
   acceptance criteria, required evidence, required validator depth, and
   rollback posture. Children touching enforcement surfaces (lens-bank
   foundation, taxonomy-and-routing, schema-extensions, suite-integration)
   must define at least one negative control (e.g., unknown method id,
   undefined lens reference, method without profile, receipt missing method
   field). Children touching only methodology docs (greenfield-method,
   companion-methods) must define a doc-consistency check against
   `naming.yml` and `lens-bank.yml`.
5. **Authority boundaries.** No child may create a lifecycle gate, a new
   review mechanism, a routed workflow mode, closeout authority, or any
   authority for review outputs; may not widen support claims; may not
   publish generated outputs outside canonical publication scripts; may not
   treat evidence, projections, or the intake unit as authority. Durable
   changes land only under `framework/**` (or, for the conditional facades
   child, the declared `.claude/**` facade surfaces) through governed
   acceptance.
6. **Suite design rules.** Methods own the question, scope, routing, and
   output contract; lenses are selected from the shared bank only; no
   private lens catalogs; Balanced remains the default method; Greenfield
   output remains reference-architecture-only; companion methods remain
   distinct and callable from Balanced Review, Greenfield Review, or
   proposal lifecycle contexts; readiness and surface-audit doctrine are
   cited, never modified or duplicated.
7. **Write-scope discipline.** Each child stays inside its
   registry-declared `write_scopes`; touching another child's scope requires
   a registry revision at the parent, not silent expansion.
8. **Terminal outcomes.** Allowed child terminal states: closed (implemented
   and verified), superseded, rejected, or — for
   `architecture-review-command-facades` only — program-recorded no-action.

## Per-Child Charters

- `architecture-lens-bank-foundation`: author `architecture-lens-bank.md`
  and `lens-bank.yml` per `architecture/lens-bank-design.md` (18 lenses,
  core/extended tiers, per-method profiles for all six methods), plus the
  lens-reference validator and fixtures. The bank must express Balanced's
  existing required sequence as lens ids without changing Balanced doctrine.
  Sprawl controls (new-lens admission rule, no private catalogs, retirement
  discipline) are part of the authored doctrine.
- `architecture-review-method-taxonomy-and-routing`: refactor `naming.yml`
  to `architectural-review-naming-v2` (methods list, Balanced default; no
  slug renames, no alias retirements), extend `review-routing.yml` to
  `architectural-review-routing-v2` (method_selection block, per-route
  allowed methods, escalation map, fail-closed `unknown_method` and
  `missing_method_record`), extend the mechanism README canonical-names
  table, add minimal cross-references to the Balanced doc, and update
  naming/routing validators with negative controls. Existing routes,
  evidence roots, and the pre-integration gate are untouched.
- `greenfield-reference-architecture-review-method`: author the method doc
  per `architecture/method-taxonomy.md` §2 — five required output sections,
  initial-build sequencing, minimum viable architecture, what-not-to-build,
  clean-sheet complementarity, escalation rules, and the
  reference-architecture-only output boundary stated fail-closed.
- `companion-architecture-review-methods`: author the four companion method
  docs per `architecture/method-taxonomy.md` §§3–6 with one shared contract
  shape (question, use cases, non-goals, required inputs, outputs, lens
  profile reference, escalation rules). Must include the explicit boundary
  statements: Failure-Mode Review vs the readiness audit's failure-mode
  assessment; Boundary/Authority Review vs the surface-architecture audit's
  single-unit classification. Boundary/Authority ships Octon-only.
- `architectural-review-schema-extensions`: add
  `architectural-review-report-v2.schema.json` and
  `architectural-review-routing-decision-v2.schema.json` with additive
  `method` and `lenses_applied` fields; leave
  `architectural-review-support-receipt-v1.schema.json` untouched; extend
  `validate-architectural-review-receipts.sh` with v2 awareness and negative
  controls; declare the v1→v2 coexistence posture explicitly.
- `architectural-review-suite-integration`: extend existing review workflow
  contracts to record the selected method id in run evidence (no new steps,
  gates, or evidence roots); extend the product feature note and governed
  cross-surface mechanism entry (navigation-only); add lifecycle advisory
  text so lifecycle prompts can recommend a method per review occasion
  (gates unchanged); enumerate and refresh affected generated projections
  through canonical publication scripts; run the full architectural-review
  validator suite plus proposal/feature-catalog validators as the closing
  sweep.
- `architecture-review-command-facades` (conditional): only if operator
  demand is demonstrated during program execution; adds command/skill
  facades that invoke existing routes/methods without creating review
  authority, plus `validate-architectural-review-skills-commands.sh`
  coverage. Default disposition is a program-recorded no-action with
  rationale at closeout.

# File Change Map

All durable changes land inside the registry-declared write scope for this child
(`.octon/framework/cognition/practices/methodology/architectural-review/`). No
file outside this scope is created or modified.

## New Files (durable, promoted at implementation)

| Path | Kind of change | Write scope |
| --- | --- | --- |
| `.octon/framework/cognition/practices/methodology/architectural-review/greenfield-reference-architecture-review-method.md` | New: the Greenfield method output contract — question, use cases, non-goals, required inputs, lens profile, five required output sections, initial-build sequencing, minimum viable architecture, what-not-to-build-yet, clean-sheet complementarity, escalation rules, fail-closed output boundary | methodology/architectural-review |

## Changed Files (durable, promoted at implementation)

| Path | Kind of change | Write scope |
| --- | --- | --- |
| `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml` | Additive: add `doc: "greenfield-reference-architecture-review-method.md"` to the existing `methods.catalog` greenfield entry (mirrors Balanced). No slug, schema-version, or other-entry change | methodology/architectural-review |
| `.octon/framework/cognition/practices/methodology/architectural-review/README.md` | Additive: add a Greenfield method-doc link to the References section. Canonical-names table unchanged (Greenfield row already added in phase-1) | methodology/architectural-review |

## Files Explicitly NOT Changed

| Path | Why untouched |
| --- | --- |
| `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml` | Phase-0 verified dependency; the doc cites its greenfield profile but does not modify it |
| `.octon/framework/cognition/practices/methodology/architectural-review/architecture-lens-bank.md` | Phase-0 lens doctrine; cited, not modified |
| `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml` | Phase-1 `method_selection` / escalation map; cited by the doc, not modified |
| `naming.yml` `methods.catalog` slugs, `canonical_modes`, aliases, facades | No slug renames, no alias retirements; only the additive `doc:` reference on the greenfield entry |
| `.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md` | Balanced doctrine unchanged; the greenfield doc contrasts with it but changes no Balanced text |
| Companion method docs (Tradeoff, Failure-Mode, Evolution/Fitness, Boundary/Authority) | Owned by `companion-architecture-review-methods` (phase-2) |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-*.sh` | This child ships no enforcement surface; validators are run for no-regression only, not modified |
| `.octon/framework/constitution/contracts/assurance/architectural-review-*.schema.json` | Report/routing-decision v2 `method`/`lenses_applied` fields are `architectural-review-schema-extensions` (phase-2) scope |
| Review workflow contracts under `orchestration/runtime/workflows/audit/**` | Method-id recording in run evidence is `architectural-review-suite-integration` (phase-3) scope |
| Architecture-readiness / surface-architecture audit doctrine | Out of scope; cited as composition boundaries only, never modified |

## Generated Surfaces

No generated/effective output is hand-edited. If a generated methodology index
references the mechanism directory, it is refreshed only through the canonical
publication script at implementation (owned by the phase-3 suite-integration
child), never by this child writing generated paths directly.

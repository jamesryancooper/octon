# Target Architecture

## Target State

After this child is implemented, the Architectural Review Mechanism directory
`.octon/framework/cognition/practices/methodology/architectural-review/` carries
an explicit method layer in its data models and docs. The directory keeps its
existing files; four are changed additively:

- `naming.yml` → `architectural-review-naming-v2`: adds a `methods` block
  (`default: balanced-architecture-review-method` + a six-entry catalog). All
  existing `mechanism`, `method`, `canonical_modes`, aliases, facades,
  `schema_names`, `validator_names`, and `legacy_aliases` are preserved verbatim.
- `review-routing.yml` → `architectural-review-routing-v2`: adds a
  `method_selection` block (default method, per-route allowed methods, escalation
  map) and appends `unknown_method` and `missing_method_record` to
  `fail_closed_conditions`. All existing routes and conditions are preserved.
- `README.md`: canonical-names table gains six method rows plus a short
  "Methods And Selection" note and reference links.
- `balanced-architecture-review-method.md`: gains minimal navigation
  cross-references (method taxonomy, lens bank, escalation map). No doctrine text
  changes.

`.octon/framework/assurance/runtime/_ops/scripts/` keeps its files; the naming
and routing validators gain method-layer checks and negative controls, with
fixtures under the assurance test tree.

## Invariants

1. **Balanced stays default.** `methods.default` and
   `method_selection.default_method` are `balanced-architecture-review-method`;
   with no selection, routing behaves exactly as today.
2. **Six methods, one catalog.** The methods list enumerates Balanced plus the
   five companions using the canonical `-method`-suffixed slugs fixed in
   `architecture/slug-reconciliation-decision.md`.
3. **Dependency binding.** Every declared method slug equals a
   `lens-bank.yml` `suite_methods[].slug` verified by
   `architecture-lens-bank-foundation`; the naming validator enforces this.
4. **Fail-closed method routing.** `unknown_method` and `missing_method_record`
   are declared fail-closed conditions; two negative-control fixtures prove both
   failure modes plus the "method without a lens profile" case.
5. **Additive only.** No slug renames, no alias retirements, no route changes, no
   new mechanism, gate, routed workflow mode, evidence root, or command facade.
6. **No authority granted to review outputs.** Method selection is routing
   semantics; review outputs remain evidence or proposal input; the
   pre-integration support receipt remains the only lifecycle-gating review
   artifact.
7. **Doc/data agreement.** The README method rows and the Balanced
   cross-references agree with `naming.yml` `methods` and `review-routing.yml`
   `method_selection`.

## Boundary With Adjacent Doctrine

Architecture-readiness evaluation and surface-architecture audit doctrine are out
of scope and unchanged; the routing `allowed_methods_by_route` lists reference
their existing route ids as occasions without modifying their doctrine.
Constitutional conflicts continue to route to Constitutional Challenge (existing
kernel gate), recorded in `method_selection.constitutional_conflict_routes_to`
as navigation, not a new gate.

## What This Child Deliberately Does Not Build

- The Greenfield and companion **method docs** (owned by
  `greenfield-reference-architecture-review-method` and
  `companion-architecture-review-methods`, phase-2). This child names the methods
  and routes them; it does not author their output contracts.
- The `architectural-review-report-v2` / `routing-decision-v2` **schema** fields
  that carry `method` and `lenses_applied` (owned by
  `architectural-review-schema-extensions`, phase-2). This child declares the
  `missing_method_record` fail-closed intent; the schema field completing it is
  phase-2.
- Review workflow **method-id recording** in run evidence and any generated
  projection refresh (owned by `architectural-review-suite-integration`,
  phase-3).
- Any modification of the phase-0 **lens bank** beyond binding to its slugs.

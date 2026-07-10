# Naming And Routing Authoring Spec

The concrete content the implementation must author. This spec is proposal-local
lineage; the durable authority is the framework artifacts once promoted. Final
field names are reconciled against the live `naming.yml`/`review-routing.yml`
conventions at implementation. All six method slugs are fixed by
`architecture/slug-reconciliation-decision.md`.

## Artifact 1 — `naming.yml` → `architectural-review-naming-v2`

Path:
`.octon/framework/cognition/practices/methodology/architectural-review/naming.yml`

Additive change: bump `schema_version` to `architectural-review-naming-v2` and
add a `methods` list. **Everything else is preserved verbatim** — the existing
`mechanism`, `method` (Balanced), `canonical_modes`, `invocation_aliases`,
`command_facades`, `schema_names`, `validator_names`, and `legacy_aliases`. No
slug is renamed; no alias is retired. The existing top-level `method` block
(Balanced) is retained for backward compatibility and is cross-listed as the
default in the new `methods` list.

New block (illustrative shape):

```yaml
schema_version: "architectural-review-naming-v2"
# ... existing mechanism / method / canonical_modes / aliases / schema_names /
#     validator_names / legacy_aliases preserved verbatim ...
methods:
  default: "balanced-architecture-review-method"
  catalog:
    - display_name: "Balanced Architecture Review Method"
      slug: "balanced-architecture-review-method"
      role: "default"
      doc: "balanced-architecture-review-method.md"
      lens_profile_ref: "lens-bank.yml#method_profiles.balanced-architecture-review-method"
    - display_name: "Greenfield Reference Architecture Review"
      slug: "greenfield-reference-architecture-review-method"
      role: "companion"
      lens_profile_ref: "lens-bank.yml#method_profiles.greenfield-reference-architecture-review-method"
    - display_name: "Architecture Tradeoff Review"
      slug: "tradeoff-review-method"
      role: "companion"
      lens_profile_ref: "lens-bank.yml#method_profiles.tradeoff-review-method"
    - display_name: "Failure-Mode Architecture Review"
      slug: "failure-mode-review-method"
      role: "companion"
      lens_profile_ref: "lens-bank.yml#method_profiles.failure-mode-review-method"
    - display_name: "Evolution/Fitness Architecture Review"
      slug: "evolution-fitness-review-method"
      role: "companion"
      lens_profile_ref: "lens-bank.yml#method_profiles.evolution-fitness-review-method"
    - display_name: "Boundary/Authority Architecture Review"
      slug: "boundary-authority-review-method"
      role: "companion"
      lens_profile_ref: "lens-bank.yml#method_profiles.boundary-authority-review-method"
```

Every `slug` in `methods.catalog` MUST equal an entry in `lens-bank.yml`
`suite_methods[].slug` (dependency binding to the verified phase-0 lens bank).

## Artifact 2 — `review-routing.yml` → `architectural-review-routing-v2`

Path:
`.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml`

Additive change: bump `schema_version` to `architectural-review-routing-v2`, add
a `method_selection` block, and append two entries to `fail_closed_conditions`.
**All existing `routes`, `default_route`, and the existing eight
`fail_closed_conditions` entries are preserved verbatim.**

New block (illustrative shape):

```yaml
schema_version: "architectural-review-routing-v2"
default_route: "pre-integration-architecture-review"   # unchanged
# ... existing routes[] preserved verbatim ...
method_selection:
  default_method: "balanced-architecture-review-method"
  # Every review run selects exactly one method; Balanced is the default when
  # no selection is made. Methods are HOW a review is conducted; routes are the
  # review OCCASION. Method selection creates no lifecycle gate.
  allowed_methods_by_route:
    pre-integration-architecture-review:
      - "balanced-architecture-review-method"       # default
      - "greenfield-reference-architecture-review-method"
      - "tradeoff-review-method"
      - "failure-mode-review-method"
      - "evolution-fitness-review-method"
      - "boundary-authority-review-method"
    post-integration-architecture-review:
      - "balanced-architecture-review-method"
      - "failure-mode-review-method"
      - "evolution-fitness-review-method"
      - "boundary-authority-review-method"
    current-state-mechanism-architecture-review:
      - "balanced-architecture-review-method"
      - "evolution-fitness-review-method"
      - "boundary-authority-review-method"
      - "failure-mode-review-method"
    domain-architecture-audit:
      - "balanced-architecture-review-method"
      - "boundary-authority-review-method"
    surface-architecture-audit:
      - "balanced-architecture-review-method"
      - "boundary-authority-review-method"
    architecture-readiness-audit:
      - "balanced-architecture-review-method"
      - "failure-mode-review-method"
  escalation_map:
    balanced-architecture-review-method:
      - trigger: "two-or-more-viable-target-designs"
        to: "tradeoff-review-method"
      - trigger: "runtime-or-governance-failure-behavior-in-doubt"
        to: "failure-mode-review-method"
      - trigger: "long-lived-mechanism-health-in-doubt"
        to: "evolution-fitness-review-method"
      - trigger: "authority-location-in-doubt"
        to: "boundary-authority-review-method"
      - trigger: "target-does-not-exist-yet"
        to: "greenfield-reference-architecture-review-method"
  constitutional_conflict_routes_to: "constitutional-challenge"   # existing kernel gate, unchanged
fail_closed_conditions:
  # ... existing eight conditions preserved verbatim ...
  - "unknown_method"                # a selected method is not in naming.yml methods.catalog
  - "missing_method_record"         # a routing decision / method-bearing report omits the selected method slug
```

`method_selection` grants no lifecycle or closeout authority. It records which
methods a route permits and how Balanced escalates. The
`missing_method_record` condition is the routing-side statement of the runtime
requirement; the schema field that carries the method record is authored by the
phase-2 `architectural-review-schema-extensions` child, so at this child's
implementation `missing_method_record` is enforced against the routing-decision
data this child controls, and the schema-level check is completed in phase-2.

Allowed-methods-by-route lists are conservative and additive: every route keeps
Balanced as the default; the extra methods are advisory options, not new gates.

## Artifact 3 — mechanism `README.md` canonical-names table

Path:
`.octon/framework/cognition/practices/methodology/architectural-review/README.md`

Append method rows to the "Canonical Names" table (existing rows unchanged) and
add a short "Methods And Selection" note stating: every review run selects
exactly one method; Balanced is the default; methods are how a review is
conducted, routes are the occasion; selecting an unknown method fails closed;
method selection creates no lifecycle gate. Add a reference link to
`architecture-lens-bank.md` and `naming.yml` `methods`.

New table rows (append after the existing Method row):

| Surface | Display Name | Slug |
| --- | --- | --- |
| Method (default) | Balanced Architecture Review Method | `balanced-architecture-review-method` |
| Method | Greenfield Reference Architecture Review | `greenfield-reference-architecture-review-method` |
| Method | Architecture Tradeoff Review | `tradeoff-review-method` |
| Method | Failure-Mode Architecture Review | `failure-mode-review-method` |
| Method | Evolution/Fitness Architecture Review | `evolution-fitness-review-method` |
| Method | Boundary/Authority Architecture Review | `boundary-authority-review-method` |

## Artifact 4 — Balanced doc minimal cross-references

Path:
`.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md`

Add **only** navigation cross-references (e.g., a short "Related" or "See also"
line) pointing to the method taxonomy in `naming.yml` `methods`, the shared lens
bank (`architecture-lens-bank.md` / `lens-bank.yml`), and the escalation map in
`review-routing.yml`. Do **not** change any Required Sequence, Octon Fit Gate,
or Output Contract text. Balanced remains the default method and its doctrine is
untouched.

## Artifact 5 — validator updates + negative controls

Paths:
`.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh`
and `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-routing.sh`

Naming validator additions (keeping the existing `[OK]`/`[ERROR]` +
`Validation summary: errors=N` + non-zero-exit convention):

1. `schema_version == architectural-review-naming-v2`.
2. `methods.default == balanced-architecture-review-method`.
3. Each of the six canonical method slugs is present in `methods.catalog`.
4. Every `methods.catalog[].slug` appears in `lens-bank.yml`
   `suite_methods[].slug` (dependency binding) — **NC-A**: a method declared in
   `naming.yml` without a matching `lens-bank.yml` profile fails closed.
5. Existing canonical-mode slugs, active aliases, command facades, and the
   retired legacy alias assertions are retained unchanged (no-regression guard).

Routing validator additions:

1. `schema_version == architectural-review-routing-v2`.
2. `method_selection.default_method == balanced-architecture-review-method`.
3. Every method in `allowed_methods_by_route` and `escalation_map` is a declared
   naming method slug — **NC-B**: an `unknown_method` (a routing method slug not
   in `naming.yml` `methods.catalog`) fails closed.
4. `fail_closed_conditions` contains both `unknown_method` and
   `missing_method_record` — **NC-C**: routing data that selects a method but
   omits the required method record fails closed.
5. Existing route declarations, `default_route`, lifecycle-authority assertions,
   and the existing fail-closed conditions are retained unchanged (no-regression
   guard).

## Fixtures (negative controls)

Retained under the assurance test tree beside the sibling architectural-review
fixtures (final path chosen at implementation, e.g.
`.../fixtures/architectural-review/method-taxonomy-routing/`):

- `pass/` — naming v2 + routing v2 with all six slugs, Balanced default, and
  both fail-closed conditions present → validators pass.
- `fail-unknown-method/` — routing selects `nonexistent-review-method` not in
  the naming catalog → routing validator fails (NC-B).
- `fail-method-without-profile/` — naming declares a method slug absent from
  `lens-bank.yml` `suite_methods` → naming validator fails (NC-A).
- `fail-missing-method-record/` — routing-decision sample selects a method but
  omits the method record while `missing_method_record` is declared → routing
  validator fails (NC-C).

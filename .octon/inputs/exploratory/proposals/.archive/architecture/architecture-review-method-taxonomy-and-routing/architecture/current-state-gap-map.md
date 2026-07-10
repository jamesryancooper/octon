# Current-State Gap Map

Verified against the live mechanism at
`.octon/framework/cognition/practices/methodology/architectural-review/` and the
validator directory `.octon/framework/assurance/runtime/_ops/scripts/`.

## Current State

| Surface | Today | Source of truth |
| --- | --- | --- |
| Naming model | `architectural-review-naming-v1`; single `method` block (Balanced); eight `canonical_modes`; active aliases; one retired legacy alias | `naming.yml` |
| Method list | None. Only Balanced is named; the five companions have no canonical slug in naming | `naming.yml` |
| Routing model | `architectural-review-routing-v1`; nine routes; `default_route: pre-integration-architecture-review`; eight `fail_closed_conditions` | `review-routing.yml` |
| Method selection | None. Routing has no method-selection semantics and no `unknown_method` / `missing_method_record` condition | `review-routing.yml` |
| Mechanism README | Canonical-names table lists mechanism, Balanced method, eight modes; no method rows | `README.md` |
| Lens bank (phase-0) | `lens-bank.yml` declares six `suite_methods` (Balanced canonical; five companions provisional) and `method_profiles` | `lens-bank.yml` |
| Naming/routing validators | Assert existing modes, aliases, facades, routes, default route, lifecycle authority; no method-layer checks | `validate-architectural-review-naming.sh`, `validate-architectural-review-routing.sh` |

## Gap → Target Traceability

| # | Source claim / gap (method-taxonomy.md, target-architecture.md, child charter) | Live gap | Target artifact / action | Acceptance ref |
| --- | --- | --- | --- | --- |
| G1 | Every review selects one method; six methods with Balanced default | Only Balanced named; no methods list | `naming.yml` v2 `methods` block (default + six-entry catalog) | AC-1 |
| G2 | Canonical companion slugs must be fixed and reconciled with lens-bank provisional slugs | Slugs provisional in lens-bank; diverge from parent prose | Adopt `-method`-suffixed slugs; record reconciliation | AC-2 |
| G3 | Naming v2 methods list must cite the verified lens bank | No binding between naming and lens-bank | Naming validator asserts every method slug ∈ `lens-bank.yml` `suite_methods` (NC-A) | AC-3, AC-5 |
| G4 | Routing gains method-selection semantics (default, per-route allowed, escalation) fail-closed on unknown method | No `method_selection` block | `review-routing.yml` v2 `method_selection` + `unknown_method` (NC-B) | AC-4, AC-5 |
| G5 | Routing must fail closed when a method record is missing | No `missing_method_record` condition | Append `missing_method_record` to `fail_closed_conditions` (NC-C) | AC-4, AC-5 |
| G6 | Mechanism README canonical-names table lists methods | No method rows | Append six method rows + selection note + links | AC-6 |
| G7 | Balanced doc gets minimal cross-references (no doctrine change) | No links to method taxonomy / lens bank | Add navigation cross-references only | AC-6 |
| G8 | Existing routes, evidence roots, aliases, and the pre-integration gate untouched; no slug renames / alias retirements | Risk of regression during v2 bump | No-regression validator assertions retained; `git diff` scoped | AC-7 |

## Re-Grounding Divergences

- **Companion method slugs (recorded, resolved).** The parent
  `method-taxonomy.md` prose uses non-suffixed slugs; the live `lens-bank.yml`
  uses `-method`-suffixed provisional slugs; the program `child-packet-index.yml`
  `child_id` for Greenfield already uses the suffixed form. This child adopts the
  suffixed slugs as canonical (live lens bank + registry outrank stale prose) and
  records a program design-revision note. See
  `architecture/slug-reconciliation-decision.md`. Not a blocker.
- **Method record schema field.** The runtime field that carries the selected
  method (`report`/`routing-decision` v2) is authored by the phase-2
  schema-extensions child. This child declares the `missing_method_record`
  fail-closed condition and enforces it against the routing-decision data it
  controls; the schema-level completion is a phase-2 dependency-output, recorded
  here, not a blocker for this child.
- No other divergence between the program design and the live mechanism was
  found; the six routes referenced by `allowed_methods_by_route` all exist in
  `review-routing.yml` at HEAD.

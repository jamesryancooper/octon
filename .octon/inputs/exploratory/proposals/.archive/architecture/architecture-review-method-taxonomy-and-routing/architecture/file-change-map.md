# File Change Map

All durable changes land inside the registry-declared write scopes for this
child (`.octon/framework/cognition/practices/methodology/architectural-review/`
and `.octon/framework/assurance/runtime/_ops/scripts/`, plus the assurance test
fixture tree for fixtures). No file outside these scopes is created or modified.

## Changed Files (durable, promoted at implementation)

| Path | Kind of change | Write scope |
| --- | --- | --- |
| `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml` | Additive: bump to `architectural-review-naming-v2`, add `methods` block; existing content preserved verbatim | methodology/architectural-review |
| `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml` | Additive: bump to `architectural-review-routing-v2`, add `method_selection` block, append two `fail_closed_conditions`; existing routes/conditions preserved | methodology/architectural-review |
| `.octon/framework/cognition/practices/methodology/architectural-review/README.md` | Additive: append six method rows + selection note + reference links; existing rows unchanged | methodology/architectural-review |
| `.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md` | Minimal: add navigation cross-references only; no doctrine change | methodology/architectural-review |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh` | Additive: method-list checks + NC-A (method without lens profile) | _ops/scripts |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-routing.sh` | Additive: method-selection checks + NC-B (unknown method) + NC-C (missing method record) | _ops/scripts |

## New Files (durable, promoted at implementation)

| Path | Kind | Write scope |
| --- | --- | --- |
| Method-taxonomy/routing validator fixtures: `pass/`, `fail-unknown-method/`, `fail-method-without-profile/`, `fail-missing-method-record/` | Test fixtures (positive + three negative controls) | assurance test fixture tree |

## Files Explicitly NOT Changed

| Path | Why untouched |
| --- | --- |
| `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml` | Phase-0 verified dependency; this child binds to its `suite_methods` slugs but does not modify it |
| `.octon/framework/cognition/practices/methodology/architectural-review/architecture-lens-bank.md` | Phase-0 lens doctrine; consumed, not modified |
| Existing `canonical_modes`, `invocation_aliases`, `command_facades`, `legacy_aliases` in `naming.yml` | No slug renames, no alias retirements (charter) |
| Existing `routes`, `default_route`, and the original eight `fail_closed_conditions` in `review-routing.yml` | Existing routes / evidence roots / pre-integration gate untouched (charter) |
| Balanced Required Sequence / Octon Fit Gates / Output Contract text | Only navigation cross-references are added; doctrine unchanged |
| `.octon/framework/constitution/contracts/assurance/architectural-review-*.schema.json` | Report/routing-decision v2 `method` field is phase-2 scope |
| Review workflow contracts under `orchestration/runtime/workflows/audit/**` | Method-id recording in run evidence is phase-3 scope |
| Architecture-readiness / surface-architecture audit doctrine | Out of scope; referenced by route id only, never modified |

## Generated Surfaces

No generated/effective output is hand-edited. If a generated methodology or
routing index references these files, it is refreshed only through the canonical
publication script at implementation, never by this child writing generated paths
directly.

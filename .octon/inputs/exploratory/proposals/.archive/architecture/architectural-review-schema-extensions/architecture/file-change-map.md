# File Change Map

All durable changes land inside the registry-declared write scopes for this child
(`.octon/framework/constitution/contracts/assurance/` and
`.octon/framework/assurance/runtime/_ops/scripts/`, plus the assurance test
fixture tree for fixtures). No file outside these scopes is created or modified.

## New Files (durable, promoted at implementation)

| Path | Kind | Write scope |
| --- | --- | --- |
| `.octon/framework/constitution/contracts/assurance/architectural-review-report-v2.schema.json` | New schema: strict additive superset of report-v1 + required `method`/`lenses_applied` | constitution/contracts/assurance |
| `.octon/framework/constitution/contracts/assurance/architectural-review-routing-decision-v2.schema.json` | New schema: strict additive superset of routing-decision-v1 + required `method`/`lenses_applied` | constitution/contracts/assurance |
| Receipts-validator fixtures: `pass/`, `fail-unknown-method/`, `fail-undefined-lens/`, `fail-receipt-schema-drift/` | Test fixtures (positive + three negative controls) | assurance test fixture tree |

## Changed Files (durable, promoted at implementation)

| Path | Kind of change | Write scope |
| --- | --- | --- |
| `.octon/framework/constitution/contracts/assurance/README.md` | Additive: list the two v2 schemas beside their v1 counterparts; existing entries unchanged | constitution/contracts/assurance |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh` | Additive: v2 awareness (v2 report/routing-decision method + lens checks; support-receipt drift guard) + NC-1/NC-2/NC-3; existing support-receipt assertions retained | _ops/scripts |

## Files Explicitly NOT Changed

| Path | Why untouched |
| --- | --- |
| `.octon/framework/constitution/contracts/assurance/architectural-review-support-receipt-v1.schema.json` | Support receipt never gains method/lens fields (charter); byte-for-byte unchanged |
| `.octon/framework/constitution/contracts/assurance/architectural-review-report-v1.schema.json` | Retained for coexistence; v2 is a superset, v1 not modified or deleted |
| `.octon/framework/constitution/contracts/assurance/architectural-review-routing-decision-v1.schema.json` | Retained for coexistence; v2 is a superset, v1 not modified or deleted |
| `.octon/framework/constitution/contracts/assurance/family.yml` | Does not reference the architectural-review schemas; no registration change needed |
| `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml` | Phase-1 verified dependency; the v2 `method` enum binds to its `methods` catalog slugs but does not modify it |
| `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml` | Phase-1 verified dependency; this child completes its `missing_method_record` intent at the schema level but does not modify it |
| `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml` | Phase-0 verified dependency; `lenses_applied` binds to its lens ids but does not modify it |
| Review workflow contracts under `orchestration/runtime/workflows/audit/**` | Method-id recording in run evidence is phase-3 scope |
| Architecture-readiness / surface-architecture audit doctrine | Out of scope; the v2 `review_mode`/`selected_mode` enums are inherited from v1 unchanged |

## Generated Surfaces

No generated/effective output is hand-edited. If a generated contract or schema
index references these files, it is refreshed only through the canonical
publication script at implementation, never by this child writing generated paths
directly.

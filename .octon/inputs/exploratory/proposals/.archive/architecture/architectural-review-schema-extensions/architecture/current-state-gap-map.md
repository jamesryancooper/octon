# Current-State Gap Map

Verified against the live contract surface at
`.octon/framework/constitution/contracts/assurance/`, the receipts validator at
`.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh`,
and the phase-0/phase-1 method surfaces at
`.octon/framework/cognition/practices/methodology/architectural-review/`.

## Current State

| Surface | Today | Source of truth |
| --- | --- | --- |
| Report schema | `architectural-review-report-v1` only; no `method` or `lenses_applied`; `additionalProperties: false` | `architectural-review-report-v1.schema.json` |
| Routing-decision schema | `architectural-review-routing-decision-v1` only; no `method` or `lenses_applied`; `additionalProperties: false` | `architectural-review-routing-decision-v1.schema.json` |
| Support-receipt schema | `architectural-review-support-receipt-v1`; no method/lens fields | `architectural-review-support-receipt-v1.schema.json` |
| contracts/assurance README | Lists the three v1 architectural-review schemas | `README.md` |
| Receipts validator | Validates the **support receipt** only; hard-asserts `schema_version == architectural-review-support-receipt-v1`; no report/routing-decision or v2 awareness | `validate-architectural-review-receipts.sh` |
| Method catalog (phase-1) | `naming.yml` `methods` catalog declares the six canonical `-method`-suffixed slugs, Balanced default | `naming.yml` |
| `missing_method_record` (phase-1) | `review-routing.yml` declares the fail-closed condition but no schema field yet carries the method record | `review-routing.yml` |
| Lens ids (phase-0) | `lens-bank.yml` declares 18 lens ids (12 core + 6 extended) | `lens-bank.yml` |

## Gap → Target Traceability

| # | Source claim / gap (method-taxonomy.md, child charter) | Live gap | Target artifact / action | Acceptance ref |
| --- | --- | --- | --- | --- |
| G1 | Every method report records the method slug | Report schema has no `method` field | `architectural-review-report-v2.schema.json` adds required `method` enum | AC-1 |
| G2 | Every method report records the lens profile actually applied | Report schema has no `lenses_applied` field | v2 report adds required `lenses_applied` array (`minItems: 1`) | AC-1 |
| G3 | Routing decisions must carry the selected method (`missing_method_record`) | Routing-decision schema has no `method` field | `architectural-review-routing-decision-v2.schema.json` adds required `method` + `lenses_applied` | AC-2 |
| G4 | Method values must be the canonical suite slugs | No schema binds method to the naming catalog | v2 `method` enum = six `naming.yml` slugs; validator cross-checks (NC — `unknown_method`) | AC-3, AC-6 |
| G5 | Lens ids must come from the shared bank | No schema binds lenses to the lens bank | validator asserts every `lenses_applied` id ∈ `lens-bank.yml` (NC — `undefined_lens`) | AC-4, AC-6 |
| G6 | Support receipt must not become method-bearing | Nothing guards the support receipt against drift | v2-aware validator asserts receipts stay v1 (NC — `receipt_schema_drift`); support-receipt schema untouched | AC-5, AC-6 |
| G7 | v1 producers must remain valid (coexistence) | No explicit posture; risk of breaking v1 artifacts | Retain v1 schemas; v1 path validates without the new fields; posture recorded | AC-7 |
| G8 | Schema index must list the new schemas | contracts/assurance README lists only v1 | Append the two v2 schema entries to the README | AC-8 |

## Re-Grounding Divergences

- **Method-record schema field is this child's job.** Phase-1
  (`architecture-review-method-taxonomy-and-routing`) declared the
  `missing_method_record` fail-closed condition and validates routing-decision
  *samples* at the config level, but no report/routing-decision **schema** field
  carries the method yet. This child adds that field. Consistent with the phase-1
  packet's own note that "the schema-extensions child completes the
  `missing_method_record` enforcement at the report/routing-decision schema
  level." Not a blocker.
- **Receipts validator scope today is support-receipt-only.** The live
  `validate-architectural-review-receipts.sh` validates only the support receipt
  and hard-asserts its v1 schema_version. The charter's "extend the receipts
  validator with v2 awareness" is therefore an additive capability: teach it to
  validate v2 report/routing-decision artifacts' new fields while keeping its
  support-receipt behavior. Recorded here so implementation does not mistake the
  extension for a rewrite of the existing support-receipt checks.
- **Canonical method slugs already reconciled.** The six `-method`-suffixed slugs
  are live in `naming.yml` (fixed by phase-1); no slug divergence remains for this
  child to resolve. The v2 `method` enum copies them verbatim.
- No other divergence between the program design and the live mechanism was
  found; all 18 lens ids referenced for `lenses_applied` exist in `lens-bank.yml`
  at HEAD.

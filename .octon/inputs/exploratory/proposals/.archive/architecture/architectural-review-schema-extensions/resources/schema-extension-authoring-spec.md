# Schema Extension Authoring Spec

Non-authoritative authoring aid for the implementation route. It records the exact
shape the durable v2 schemas and the receipts-validator extension should take, so
implementation does not re-derive them. The live repository outranks this spec; if
the naming catalog or lens bank changed, reconcile before authoring (see
`architecture/implementation-plan.md` step 1).

## Canonical Method Slugs (v2 `method` enum) — from live `naming.yml` `methods`

```
balanced-architecture-review-method        # default
greenfield-reference-architecture-review-method
tradeoff-review-method
failure-mode-review-method
evolution-fitness-review-method
boundary-authority-review-method
```

## Lens Ids (`lenses_applied` domain) — from live `lens-bank.yml`

Core (12): `system-job-framing`, `domain-model`, `current-reality-map`,
`steelman-chestertons-fence`, `complexity-separation`, `clean-sheet-reference`,
`quality-attribute-scenarios`, `tradeoff-adr`, `failure-and-recovery`,
`authority-boundary`, `validation-strategy`, `non-goals-deletion`.

Extended (6): `security-threat-model`, `data-truth-lineage`,
`contracts-compatibility`, `operability-observability-evidence`,
`evolution-fitness`, `sequencing-mvp-migration`.

The schema constrains `lenses_applied` to a non-empty, de-duplicated array of
non-empty strings; the **receipts validator** binds each id to this live lens-bank
set (fail-closed `undefined_lens`) rather than hard-coding an 18-value enum in the
schema, so a lens-bank change does not require a schema bump.

## v2 Report Schema (superset of report-v1)

Copy `architectural-review-report-v1.schema.json` verbatim, then:

- `$id` → `.../architectural-review-report-v2.schema.json`
- `title` → `Architectural Review Report v2`
- `schema_version.const` → `architectural-review-report-v2`
- add to `properties`:
  - `method`: `{ "type": "string", "enum": [ <the six slugs above> ] }`
  - `lenses_applied`: `{ "type": "array", "minItems": 1, "uniqueItems": true, "items": { "type": "string", "minLength": 1 } }`
- add `method` and `lenses_applied` to `required`
- keep `additionalProperties: false` and every other v1 field/constraint verbatim

## v2 Routing-Decision Schema (superset of routing-decision-v1)

Copy `architectural-review-routing-decision-v1.schema.json` verbatim, then apply
the identical treatment: v2 `$id`, `title` (`Architectural Review Routing Decision
v2`), `schema_version.const` (`architectural-review-routing-decision-v2`), the same
two additive required fields, and preserve the v1 `selected_mode` enum and all
other v1 fields/constraints verbatim.

## Receipts-Validator v2 Awareness

Extend `validate-architectural-review-receipts.sh` so that:

- **Support-receipt path (existing + drift guard):** keep every existing
  support-receipt assertion; additionally fail closed (`receipt_schema_drift`) if
  `schema_version` is not `architectural-review-support-receipt-v1` or the receipt
  carries a `method`/`lenses_applied` field.
- **v2 report/routing-decision path (new):** when `schema_version` ends in `-v2`,
  assert `method` is one of the live `naming.yml` `methods` catalog slugs
  (`unknown_method`) and every `lenses_applied` id is a declared `lens-bank.yml`
  lens id (`undefined_lens`).
- **v1 path (coexistence):** a v1 report/routing-decision validates without the two
  new fields.

## Fixtures (assurance test fixture tree)

- `pass/` — a valid v2 report and a valid v2 routing-decision using a real method
  slug and real lens ids.
- `fail-unknown-method/` — a v2 artifact whose `method` is not in the naming
  catalog (proves `unknown_method`).
- `fail-undefined-lens/` — a v2 artifact whose `lenses_applied` contains an id not
  in the lens bank (proves `undefined_lens`).
- `fail-receipt-schema-drift/` — a support receipt with a non-v1 `schema_version`
  or a `method` field (proves `receipt_schema_drift`).

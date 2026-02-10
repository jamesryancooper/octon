# Contract Test Fixture Naming Convention

All fixture files live in `tests/contracts/fixtures/` as plain JSON files.

## Naming Pattern

```
<contract-name>.<scenario>.json
```

Where:
- `<contract-name>` matches the schema file prefix (e.g., `scene-dsl`, `physics-ir`, `artifact-manifest`)
- `<scenario>` describes what the fixture tests

## Valid Fixture Scenarios

Use `valid-` prefix for fixtures that should pass validation:

- `entity.valid-minimal.json` — Only required fields with minimal valid values
- `entity.valid-full.json` — All fields populated with representative values
- `entity.valid-with-<feature>.json` — Tests an optional feature or field
- `entity.valid-without-<feature>.json` — Tests backward compatibility

## Invalid Fixture Scenarios

Use `invalid-` prefix for fixtures that should fail validation:

- `entity.invalid-missing-required.json` — Missing a required field
- `entity.invalid-<field-name>.json` — Invalid value for a specific field
- `entity.invalid-<constraint>.json` — Violates a specific constraint

## Examples from a Production Project

```
scene-dsl.valid-with-background-mode.json
scene-dsl.valid-without-background-mode.json
scene-dsl.invalid-background-mode.json
artifact-manifest.valid-with-output-preferences.json
artifact-manifest.valid-without-output-preferences.json
artifact-manifest.invalid-output-preferences-missing-background.json
artifact-manifest.invalid-background-mode.json
```

## Rules

1. Each fixture is a single, self-contained JSON document.
2. Valid fixtures must pass both JSON Schema and Pydantic validation.
3. Invalid fixtures must fail with a **specific, predictable** error.
4. Keep fixtures minimal — only include fields needed to test the scenario.
5. Use realistic but obviously fake data (no PII, no real secrets).

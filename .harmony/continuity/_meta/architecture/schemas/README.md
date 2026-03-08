# Continuity Schemas

Canonical schemas for continuity memory artifacts.

These schemas define field-level contracts for:

- `tasks.json`
- `entities.json`
- `continuity/decisions/<decision-id>/decision.json`

Validation is enforced by:

- `.harmony/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`

Notes:

- Schema files are the normative contract source.
- Validation script behavior must stay aligned with these schemas.

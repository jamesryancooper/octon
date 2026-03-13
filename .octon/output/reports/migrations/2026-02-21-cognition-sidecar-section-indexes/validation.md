# Validation

## Gate Results

- `validate-harness-structure.sh`: PASS
- `validate-audit-subsystem-health-alignment.sh`: PASS
- `validate-workflows.sh`: PASS
- `validate-skills.sh --strict`: PASS
- `alignment-check.sh --profile harness,skills,workflows`: PASS

## Contract Assertions Verified

- Sidecar section indexes are required and present.
- Sidecar `source` files resolve on disk.
- Sidecar indexed headings resolve in source markdown files.
- Legacy `sections/` directories are removed and blocked by validation.
- Discovery indexes resolve to sidecar index files.
- `audit-subsystem-health` alignment artifacts updated and version bumped (`1.0.10` -> `1.0.11`).

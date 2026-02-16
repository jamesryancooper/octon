# Spec Runbook

## Health Checks

- [ ] `spec/impl/spec.sh` executes `init|validate|render|diagram` without external runtime dependencies.
- [ ] Fixture gates pass via:
  - `bash .harmony/capabilities/services/planning/_ops/scripts/validate-planning-fixtures.sh`
- [ ] `validate` mode performs no file mutation.

## Rollback

- Revert `spec/impl/spec.sh` to previous revision.
- Re-run fixture validation script.

## Troubleshooting

- `InputValidationError` (`exit 5`): malformed payload or missing required fields.
- `SpecExecutionError` (`exit 4`): runtime path/permission issue.
- Ensure `jq` is available in PATH.

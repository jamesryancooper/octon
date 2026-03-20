# Validation

## Gate Results

- `sync-runtime-artifacts.sh --check`: PASS
- `validate-generated-runtime-artifacts.sh`: PASS (`errors=0 warnings=1`)
- `validate-harness-structure.sh`: PASS
- `validate-repo-instance-boundary.sh`: PASS
- `validate-continuity-memory.sh`: PASS (`errors=0 warnings=6`)
- `alignment-check.sh --profile harness`: PASS (`errors=0`; warning-only subchecks present)
- `test-validate-repo-instance-boundary.sh`: PASS
- `test-packet10-generated-tracking.sh`: PASS
- `test-sync-runtime-artifacts-fixtures.sh`: PASS

## Contract Assertions Verified

- The instance-local generated ADR summary no longer exists.
- The generated cognition decisions summary points only at canonical ADR files
  under `/.octon/instance/cognition/decisions/**`.
- Active read-oriented guidance points at the generated summary, and
  write-oriented guidance points at ADR files plus `index.yml`.
- Repo-instance and harness-structure validators fail closed if the retired
  summary path reappears in active control-plane surfaces.
- Warning-only validation output is limited to pre-existing stale evaluation
  digests and empty retained-evidence run directories; no Packet 11 gating
  failure remains.
- The Packet 11 proposal package is archived with `disposition: implemented`
  and the generated proposal registry reflects the archive move.

# Validation

## Gate Results

- `test-validate-repo-instance-boundary.sh`: PASS (`Passed: 3`, `Failed: 0`)
- `validate-repo-instance-boundary.sh`: PASS (`errors=0`)
- `validate-harness-structure.sh`: PASS (`errors=0 warnings=0`)
- `validate-raw-input-dependency-ban.sh`: PASS (`errors=0`)
- `alignment-check.sh --profile harness`: PASS (`errors=0`)
- `validate-workflows.sh`: PASS (`errors=0 warnings=0`)
- broader active-surface mixed-path grep: PASS (no matches after active-surface exclusions)
- `export-harness.sh --profile repo_snapshot`: PASS

## Contract Assertions Verified

- Packet 4 required instance structure now exists:
  - `instance/locality/{manifest.yml,registry.yml}`
  - `instance/orchestration/missions/{README.md,registry.yml,.archive,_scaffold/template}`
  - `instance/capabilities/runtime/commands/README.md`
  - enabled overlay-capable roots under `instance/governance/**`,
    `instance/agency/runtime/**`, and `instance/assurance/runtime/**`
- Active packet-4 control-plane surfaces no longer reference retired mixed
  repo-instance paths such as `cognition/runtime/context/*`,
  `cognition/runtime/decisions/*`, `continuity/*`, or legacy mission roots.
- Follow-up cleanup expanded beyond the initial packet-4 allowlist and now
  covers active framework/instance practices, cognition architecture docs,
  refactor/promote/evaluate workflow stages, and shared context guidance.
- The harness alignment profile now includes the packet-4 repo-instance
  boundary validator.
- Lightweight CI entrypoints now execute the packet-4 boundary validator.
- `repo_snapshot` export succeeds against the live repo after the packet-4
  cutover.
- The packet-4 proposal package is marked `implemented` in the proposal
  manifest and generated proposal registry.
- Extension publication state was refreshed during validation/export and
  remains current after the cutover.

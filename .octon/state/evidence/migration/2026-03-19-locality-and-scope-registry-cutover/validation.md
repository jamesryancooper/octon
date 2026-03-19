# Validation

## Gate Results

- `test-validate-locality-registry.sh`: PASS (`Passed: 6`, `Failed: 0`)
- `test-validate-locality-publication-state.sh`: PASS (`Passed: 4`, `Failed: 0`)
- `test-validate-repo-instance-boundary.sh`: PASS (`Passed: 4`, `Failed: 0`)
- `validate-locality-registry.sh`: PASS (`errors=0`)
- `validate-locality-publication-state.sh`: PASS (`errors=0`)
- `validate-repo-instance-boundary.sh`: PASS (`errors=0`)
- `validate-harness-structure.sh`: PASS (`errors=0 warnings=0`)
- `validate-agency.sh`: PASS (`errors=0 warnings=0`)
- `alignment-check.sh --profile harness`: PASS (`errors=0`)

## Contract Assertions Verified

- Locality authority resolves only through `instance/locality/**`, with one
  live scope manifest published from the authoritative registry.
- Compiled effective locality outputs match the current authoritative locality
  inputs and carry current manifest, registry, and quarantine digests.
- Active docs and contracts no longer advertise `nearest-registry-wins`;
  agency routing now uses the repo-instance scope registry token.
- Packet 6 locality validators are wired into harness alignment plus the
  direct harness/self-containment, smoke, and main-push-safety CI entrypoints.
- A standalone `scope.yml` schema contract now exists under
  `framework/cognition/_meta/architecture/instance/locality/schemas/`, and
  the live locality validator requires that contract to be present and parse as
  JSON.
- `include_globs` and `exclude_globs` are now enforced as subordinate to the
  declared `root_path`, not merely as safe relative patterns.
- The framework-core boundary validator now ignores non-canonical proposal
  workspaces so historical proposal resource references do not masquerade as
  live contract drift during harness alignment.

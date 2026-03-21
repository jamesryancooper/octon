# Validation

- `test-validate-locality-publication-state.sh`: PASS
- `test-validate-extension-publication-state.sh`: PASS
- `test-validate-capability-publication-state.sh`: PASS
- `test-validate-runtime-effective-state.sh`: PASS
- `test-export-harness.sh`: PASS
- `test-validate-extension-pack-contract.sh`: PASS
- `test-validate-host-projections.sh`: PASS
- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/.archive/architecture/validation-fail-closed-quarantine-staleness`: PASS
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/.archive/architecture/validation-fail-closed-quarantine-staleness`: PASS
- `alignment-check.sh --profile harness`: PASS after an escalated rerun to
  refresh `.codex/**` host projections in this environment

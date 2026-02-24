# Validation

## Gate Results

- `validate-workflows.sh`: PASS (`errors=0 warnings=0`)
- `validate-harness-version-contract.sh`: PASS (`errors=0`)
- `validate-ssot-precedence-drift.sh`: PASS (`errors=0`)
- `validate-audit-subsystem-health-alignment.sh`: PASS (`errors=0 warnings=0`)
- `sync-runtime-artifacts.sh`: PASS (`decisions.md` and `knowledge/graph/nodes.yml` updated)
- `validate-harness-structure.sh`: PASS (`errors=0 warnings=0`)
- `alignment-check.sh --profile harness`: PASS (`errors=0`)
- `validate-capability-engine-consistency.sh`: PASS
- `policy doctor` (`deny-by-default.v2`): PASS (`valid=true`)
- `validate-deny-by-default.sh --all --profile strict --skip-runtime-tests`: PASS
- `cargo test -p policy_engine --lib`: PASS

## Contract Assertions Verified

- Clean-break migration contract explicitly forbids dual-running old/new governance paths after cutover.
- Rollback contract is full-revert-only.
- ACP operating mode resolution is one profile -> one mode -> one ACP ceiling -> one evidence contract.
- Policy decisions emit canonical reason/remediation receipts.
- Harness unsupported schema versions are rejected fail-closed with deterministic migration steps.
- Runtime/governance/practices precedence conflicts are gated fail-closed.
- Legacy discoverable onboarding fallback is retired from workflow discovery routing.

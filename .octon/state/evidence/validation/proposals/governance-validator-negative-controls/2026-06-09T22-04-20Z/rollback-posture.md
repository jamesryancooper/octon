# Rollback Posture

proposal_id: governance-validator-negative-controls
run_id: 2026-06-09T22-04-20Z
verdict: pass

## Rollback Handle

Rollback is limited to these durable target files:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-delegated-governance-negative-controls.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-delegated-governance-negative-controls.sh`
- `.octon/framework/constitution/contracts/authority/delegated-governance-contract-v1.schema.json`

After rollback, rerun proposal standard, architecture proposal, readiness,
contract schema, authority-zone policy, authority-engine typed exception, and
git diff validation for this packet.

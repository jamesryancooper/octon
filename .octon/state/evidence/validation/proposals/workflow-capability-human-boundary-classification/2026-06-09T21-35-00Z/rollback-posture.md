# Rollback Posture

proposal_id: workflow-capability-human-boundary-classification
run_id: 2026-06-09T21-35-00Z
verdict: pass

## Rollback Handle

Rollback is limited to these durable target files:

- `.octon/framework/orchestration/governance/capability-map-v1.yml`
- `.octon/framework/orchestration/governance/capability-map-v1.schema.json`
- `.octon/framework/orchestration/governance/README.md`
- `.octon/framework/orchestration/governance/delegated-governance-inventory-v1.yml`
- `.octon/framework/capabilities/governance/policy/deny-by-default.v2.yml`
- `.octon/framework/capabilities/governance/policy/reason-codes.md`
- `.octon/framework/engine/runtime/spec/delegated-governance-contract-v1.md`

After rollback, rerun workflow authority derivation, capability map schema
validation, proposal standard, implementation conformance, and drift
validation for this packet.

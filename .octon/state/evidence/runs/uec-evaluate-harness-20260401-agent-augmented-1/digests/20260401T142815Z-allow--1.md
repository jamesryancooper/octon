# ACP Decision Digest (v2)

- Digest Format: `policy-digest-v2`
- Run ID: `uec-evaluate-harness-20260401-agent-augmented-1`
- Timestamp: `2026-04-01T14:28:15Z`
- Decision: `ALLOW`
- Effective ACP: `ACP-1`
- Operation Class: `execution.authorize`
- Phase: `stage`
- Reason Codes: `ACP_EVIDENCE_INVALID`
- Material Side Effect: `true`
- Telemetry Profile: `full`
- Intent Ref: `intent://octon/octon-governed-harness@1.1.0`
- Boundary ID: `workflow`
- Boundary Set Version: `v1`
- Workflow Mode: `agent-augmented`
- Capability Classification: `agent-augmented`
- Mission ID: ``
- Slice ID: ``
- Oversight Mode: ``
- Execution Posture: ``
- Reversibility Class: ``
- Instruction Layers: `provider:upstream:partial:0:0000000000000000000000000000000000000000000000000000000000000000,system:octon-system:partial:0:0000000000000000000000000000000000000000000000000000000000000000,developer:AGENTS.md:full:508:e3cfa0970e341b4b0b6720b126a7f78dd71da432731760147987f9486bc9fe7c,user:execution-request:full:1243:8349a404dec93973b54daf6e0981819622cf9260aa83e81b3f35222764a1e67c`
- Rollback Handle: `rollback-uec-evaluate-harness-20260401-agent-augmented-1`
- Compensation Handle: ``
- Recovery Window: `P14D`
- Autonomy Budget State: ``
- Breaker State: ``
- Support Tier: `repo-local-consequential`
- Ownership Refs: `operator://octon-maintainers`
- Approval Request Ref: ``
- Approval Grant Refs: ``
- Exception Refs: ``
- Revocation Refs: ``
- Network Egress Route: ``
- Remediation Summary: Regenerate and attach complete, hash-bound evidence artifacts for this gate.

## Reason Detail
- `ACP_EVIDENCE_INVALID`: Regenerate and attach complete, hash-bound evidence artifacts for this gate.

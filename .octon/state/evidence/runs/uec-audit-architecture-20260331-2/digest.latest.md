# ACP Decision Digest (v2)

- Digest Format: `policy-digest-v2`
- Run ID: `uec-audit-architecture-20260331-2`
- Timestamp: `2026-03-31T21:23:12Z`
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
- Workflow Mode: `human-only`
- Capability Classification: `human-only`
- Mission ID: ``
- Slice ID: ``
- Oversight Mode: ``
- Execution Posture: ``
- Reversibility Class: ``
- Instruction Layers: `provider:upstream:partial:0:0000000000000000000000000000000000000000000000000000000000000000,system:octon-system:partial:0:0000000000000000000000000000000000000000000000000000000000000000,developer:AGENTS.md:full:508:e3cfa0970e341b4b0b6720b126a7f78dd71da432731760147987f9486bc9fe7c,user:execution-request:full:1004:6f061648833826ed107b161ab3d446920d3731948933fb6df51d054e47263a7d`
- Rollback Handle: `rollback-uec-audit-architecture-20260331-2`
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

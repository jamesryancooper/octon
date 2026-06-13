# ACP Decision Digest (v2)

- Digest Format: `policy-digest-v2`
- Run ID: `archive-proposal-1781378420000-repo-hygiene-cleanup-authorization-receipts-validate-proposal`
- Timestamp: `2026-06-13T19:26:24Z`
- Decision: `ALLOW`
- Effective ACP: `ACP-1`
- Operation Class: `execution.authorize`
- Phase: `stage`
- Reason Codes: `ACP_EVIDENCE_INVALID`
- Material Side Effect: `true`
- Telemetry Profile: `full`
- Intent Ref: `workspace-charter://octon/octon-governed-harness@1.3.0`
- Boundary ID: `workflow-stage`
- Boundary Set Version: `v1`
- Workflow Mode: `role-mediated`
- Capability Classification: `role-mediated`
- Mission ID: ``
- Slice ID: ``
- Oversight Mode: ``
- Execution Posture: ``
- Reversibility Class: ``
- Instruction Layers: `provider:upstream:partial:0:0000000000000000000000000000000000000000000000000000000000000000,system:octon-system:partial:0:0000000000000000000000000000000000000000000000000000000000000000,developer:AGENTS.md:full:508:e3cfa0970e341b4b0b6720b126a7f78dd71da432731760147987f9486bc9fe7c,user:execution-request:full:5968:ebbda93b05e471c3e57213b7eed10069e3bbf9bc9d6b6bed25d12a4b9433884d`
- Rollback Handle: `rollback-archive-proposal-1781378420000-repo-hygiene-cleanup-authorization-receipts-validate-proposal`
- Compensation Handle: ``
- Recovery Window: `P14D`
- Autonomy Budget State: ``
- Breaker State: ``
- Support Tier: `repo-consequential`
- Ownership Refs: `operator://octon-maintainers`
- Approval Request Ref: ``
- Approval Grant Refs: ``
- Exception Refs: ``
- Revocation Refs: ``
- Network Egress Route: ``
- Remediation Summary: Regenerate and attach complete, hash-bound evidence artifacts for this gate.

## Reason Detail
- `ACP_EVIDENCE_INVALID`: Regenerate and attach complete, hash-bound evidence artifacts for this gate.

# Policy Digest v1

Canonical human-readable digest format for ACP decision receipts.

## Required Header

- `# ACP Decision Digest (v1)`
- `- Digest Format: policy-digest-v1`

## Required Summary Fields

- Run ID
- Timestamp
- Decision
- Effective ACP
- Operation Class
- Phase
- Reason Codes
- Material Side Effect
- Telemetry Profile
- `intent_ref` (Intent Ref)
- `boundary_id` (Boundary ID)
- `boundary_set_version` (Boundary Set Version)
- `workflow_mode` (Workflow Mode)
- `capability_classification` (Capability Classification)
- Rollback Handle
- Recovery Window
- Remediation Summary
- Instruction Layers (layer id, source, visibility, bytes, hash)

## Required Detail Section

```text
## Reason Detail
- `CODE`: human-readable remediation
```

The digest is authoritative only when sourced from a receipt that conforms to
`policy-receipt-v1.schema.json`.

When instruction-layer metadata is emitted for material runs, digest summaries
MUST align with `instruction-layer-manifest-v1.schema.json`.

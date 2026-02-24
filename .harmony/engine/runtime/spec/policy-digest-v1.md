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
- Rollback Handle
- Recovery Window
- Remediation Summary

## Required Detail Section

```text
## Reason Detail
- `CODE`: human-readable remediation
```

The digest is authoritative only when sourced from a receipt that conforms to
`policy-receipt-v1.schema.json`.

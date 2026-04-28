# Deferred Scope Ledger

| Deferred item | Reason deferred | v1 hook |
|---|---|---|
| Effectful MCP support | Requires connector conformance, egress, credentials, support proof, rollback/compensation, and authorization integration. | Stage-only connector posture schema. |
| External API autonomy | Requires network egress, credentials, evidence and rollback/compensation depth. | Connector posture maps outbound operations to `api` capability. |
| Browser-driving autonomy | Requires browser UI execution records and support proof. | Connector posture maps to `browser`, stage-only. |
| Deployment automation | High consequence, environment-specific, external irreversible risk. | Work Package may classify as blocked/mission-required. |
| Credential provisioning | Secret handling and external authority risk. | Decision Request can block on credential policy. |
| Multi-repo autonomy | Requires cross-repo authority model. | Engagement remains single-repo v1. |
| Mission runner | Requires stable compiler outputs first. | Work Package records mission-required prerequisites. |
| Autonomous governance amendments | Would risk self-widening authority. | Always human Decision Request in v1. |

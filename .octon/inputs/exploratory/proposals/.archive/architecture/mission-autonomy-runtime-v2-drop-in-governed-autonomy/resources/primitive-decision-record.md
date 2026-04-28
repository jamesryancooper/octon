# Primitive Decision Record

| Primitive | Decision | Reason |
| --- | --- | --- |
| Autonomy Window | Adopt | Required operator-visible wrapper for lease, budget, breakers, stop conditions, and review cadence. |
| Mission Runner | Adopt | Required safe continuation engine above run-first execution. |
| Mission Queue | Adopt | Canonical bounded next-work control structure. |
| Action Slice | Promote/operationalize | Existing schema becomes Mission Queue item base; it must not replace run contracts. |
| Continuation Decision | Adopt | Canonical post-run continue/pause/stage/escalate/revoke/close/fail decision. |
| Mission Run Ledger | Adopt | Mission-level run index; not a replacement for run journals. |
| Mission Evidence Profile | Adopt | Mission-level evidence depth and closeout requirements. |
| Mission-Aware Decision Request | Adopt | Extends v1 decisions to slices/runs/continuation/connectors/closeout. |
| Limited Connector Admission | Adopt narrowly | Future hook for MCP/tool/API/browser operations without broad support widening. |
| Broad MCP/API/browser autonomy | Defer | Outside v2 safety boundary. |
| Multiple simultaneous missions | Defer | Too much concurrency for MVP. |

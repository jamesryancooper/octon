# Risk Register

| Risk | Severity | Mitigation |
| --- | --- | --- |
| Connector availability mistaken for permission | High | Admission and authorization gates; generated projections non-authoritative. |
| MCP treated as trusted capability pack | High | Operation-level connector model; MCP not a pack. |
| Support-target widening through generated matrix | High | Validate no generated widening; require support admission/proof. |
| Direct CLI execution bypasses run lifecycle | High | Connector CLI is posture/admission only; execution via run contracts. |
| Credential leakage | High | Credential class, redaction, egress, evidence, and deferred credential provisioning. |
| Release automation smuggled in | High | Release Envelope deferred; connector ops cannot deploy without future release governance. |
| Campaign surface promoted prematurely | Medium | Preserve campaign no-go/deferred criteria. |
| Excessive complexity | Medium | MVP supports stage-only/read-only/reversible operations first. |

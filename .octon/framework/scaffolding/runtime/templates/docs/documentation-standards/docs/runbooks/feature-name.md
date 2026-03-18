# {{feature-name}} - Operations Runbook

## Service Objectives and Alerts

- Availability target: <e.g., 99.9%>
- Latency target: <e.g., p95 <= 300ms>
- Alert policies: <burn-rate, paging, dashboards>

## Validate

- [ ] Health endpoint or equivalent returns success
- [ ] Core feature workflow passes with a known-good payload
- [ ] Logs, metrics, and traces are present and sane

## Rollback

- Primary rollback procedure: `<rollback command or runbook link>`
- Feature toggle fallback: `flag.{{feature-name}}` (if used)

## Artifacts and State (If Applicable)

- Rebuild command: `<build command>`
- Publish command: `<publish command>`
- Verification checks: `<counts, schema_version, integrity>`

## Common Issues

- Elevated 4xx -> validate request against schema and contract
- Elevated 5xx -> check upstream dependencies and error budget
- Latency regression -> profile hot paths and verify resource saturation

## Incident Notes

- Owner:
- Timeline:
- User impact:
- What worked:
- What did not:
- Follow-up actions (link ADR if direction changes)

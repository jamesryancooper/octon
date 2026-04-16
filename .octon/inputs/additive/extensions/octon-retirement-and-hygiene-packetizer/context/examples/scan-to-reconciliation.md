# Example: Scan To Reconciliation

Intent:

- run a quick hygiene review
- include claim-gate context
- do not draft a packet yet

Example dispatcher input:

```yaml
include_claim_gate: true
protected_surface_mode: enforce
```

Expected route:

- `scan-to-reconciliation`

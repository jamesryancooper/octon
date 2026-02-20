---
external_outputs:
  outputs:
    - name: deployment_url
      type: url
      format: text
      description: "Resolved deployment URL for the inspected target"
      determinism: variable

    - name: deployment_state
      type: api-response
      format: text
      description: "Normalized deployment readiness state"
      determinism: variable

  publication:
    destination: "Vercel hosting platform"
    visibility: "Public or private based on Vercel project settings"
    retention: "Managed by Vercel deployment lifecycle"

  verification:
    method: "CLI status parsing with optional URL reachability probe"
    success_signals:
      - "Deployment URL is resolved"
      - "Deployment state is classified"
---

# External Outputs Reference

**Required when capability:** `external-output`

`deploy-status` returns deployment metadata from external systems, not only
local artifacts.

## Output Catalog

| Output | Type | Destination | Verification |
|--------|------|-------------|--------------|
| deployment_url | url | Vercel deployment endpoint | URL emitted by status source |
| deployment_state | api-response | Vercel deployment status | State classified from status evidence |

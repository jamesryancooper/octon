---
external_outputs:
  outputs:
    - name: deployment_url
      type: url
      format: text
      description: "Primary deployment URL returned by Vercel CLI"
      determinism: unique

    - name: deployment_status
      type: api-response
      format: text
      description: "Deployment status summary reported by CLI output"
      determinism: variable

  publication:
    destination: "Vercel hosting platform"
    visibility: "public or private based on Vercel project settings"
    retention: "Managed by Vercel deployment retention policies"

  verification:
    method: "Parse Vercel CLI output and confirm URL responds"
    success_signals:
      - "CLI exits successfully"
      - "Deployment URL is emitted"
---

# External Outputs Reference

**Required when capability:** `external-output`

`vercel-deploy` returns deployment artifacts through Vercel rather than local deliverable files.

## Output Catalog

| Output | Type | Destination | Verification |
|--------|------|-------------|--------------|
| deployment_url | url | Vercel deployment endpoint | URL emitted in CLI output and reachable |
| deployment_status | api-response | Vercel deployment record | Successful CLI completion and status line |

## External State Changes

- Creates a preview or production deployment in Vercel.
- Updates externally hosted runtime state for the linked project.

## Safety Notes

- Do not log authentication tokens or sensitive headers.
- Report only deployment URLs and high-level status metadata.

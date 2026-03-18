---
# External Outputs Documentation (External Output Pattern)
# Add this file when a skill's primary outputs are not local files.
#
# When to use:
# - Skill returns URLs, deployment endpoints, or API response objects
# - Skill mutates external state and reports identifiers/statuses
# - Skill emits artifacts hosted outside the local workspace
#
external_outputs:
  outputs:
    - name: "{{output_name}}"
      type: "{{url_or_identifier}}"       # url | api-response | artifact-id | endpoint
      format: "{{format}}"                # text | json | markdown
      description: "{{description}}"
      determinism: "{{determinism}}"      # stable | variable | unique

  publication:
    destination: "{{external_system}}"
    visibility: "{{visibility}}"          # public | private | internal
    retention: "{{retention_policy}}"

  verification:
    method: "{{verification_method}}"
    success_signals:
      - "{{signal_1}}"
      - "{{signal_2}}"
---

# External Outputs Reference

**Required when capability:** `external-output`

Document outputs that are returned via external systems rather than local files.

## Output Catalog

| Output | Type | Destination | Verification |
|--------|------|-------------|--------------|
| {{output_name}} | {{url_or_identifier}} | {{external_system}} | {{verification_method}} |

## External State Changes

List any external side effects (deployments, API mutations, hosted artifacts) and their rollback expectations.

## Safety Notes

Include visibility constraints and secret-safe logging guidance for external output values.

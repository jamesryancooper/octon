# Example: Proposal Packet

Input:

```text
/octon-impact-map-and-validation-selector \
  --bundle proposal-packet \
  .octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening
```

Expected route:

- `proposal-packet`

Expected result shape:

- packet kind is resolved from proposal manifests
- `validate-proposal-standard.sh` plus the subtype validator are selected
- packet refresh or supersession is the default next step

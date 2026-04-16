# Example: Mixed Inputs

Input:

```text
/octon-impact-map-and-validation-selector \
  --strictness credible-minimum \
  --explanation-mode full-trace \
  '{"touched_paths":["README.md"],"proposal_packet":".octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening"}'
```

Expected route:

- `mixed-inputs`

Expected result shape:

- touched paths remain the stronger factual source
- drift is surfaced explicitly
- packet refresh or clarification is preferred over weak validation

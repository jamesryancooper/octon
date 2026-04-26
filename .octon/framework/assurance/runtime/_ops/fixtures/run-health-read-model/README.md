# Run Health Read Model Fixtures

These fixtures exercise the generated-only run-health read model without
promoting fixture data as runtime authority.

- `fixture-set.yml` declares one positive derivation case for each supported
  run-health status.
- `generate-run-health-read-model.sh --fixtures-root ...` materializes temporary
  fixture run roots and generated health outputs.
- `validate-run-health-read-model.sh` verifies schema, non-authority posture,
  source digests, freshness metadata, status derivation, and negative controls.

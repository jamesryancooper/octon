# Contracts

Use this module for schema-backed or prose contracts that implementers must
obey without guessing.

## Included Contracts

- `schemas/architecture-readiness-target.schema.json`
  - machine-readable contract for supported evaluation targets
- `schemas/architecture-readiness-report.schema.json`
  - machine-readable contract for the structured audit summary output
- `fixtures/valid/*.json`
  - supported target examples
- `fixtures/invalid/*.json`
  - examples that the live framework must reject or classify as unsupported

## Contract Intent

The live framework should have:

- deterministic target classification
- explicit supported-scope boundaries
- stable structured output for downstream workflows and reports

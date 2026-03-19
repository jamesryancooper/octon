# Cost — Harness-Native Budget Service

Cost provides deterministic estimate/record operations for AI workflow spend tracking.

## Purpose

- Estimate operation cost from workflow + token inputs.
- Record actual usage with durable JSONL append-only storage.
- Support budget and tier-aware enforcement decisions.

## Inputs and Outputs

- Input schema: `schema/input.schema.json`
- Output schema: `schema/output.schema.json`

## Operations

- `estimate`
- `record`

## Policy

- Rules: `budget-check`, `tier-compliance`
- Enforcement: `block`
- Fail-closed: `false` (explicitly non-blocking for budget overrun visibility)

## Runtime

- Entrypoint: `impl/cost.sh`
- Durable usage path: `/.octon/state/evidence/runs/services/cost-usage.jsonl`

## Contract Artifacts

- Invariants: `contracts/invariants.md`
- Errors: `contracts/errors.yml`
- Rules: `rules/rules.yml`
- Fixtures: `fixtures/`
- Compatibility: `compatibility.yml`
- Generation provenance: `impl/generated.manifest.json`

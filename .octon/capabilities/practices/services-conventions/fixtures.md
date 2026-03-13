---
title: Service Fixtures
scope: harness
applies_to: services
---

# Service Fixtures

Fixtures anchor expected behavior for semantic evaluation and implementation validation.

Related docs:

- `.octon/cognition/_meta/architecture/agent-as-runtime.md`
- `conventions/rich-contracts.md`
- `conventions/validation-tiers.md`
- `conventions/implementation-generation.md`

## Purpose

Fixtures provide concrete examples that reduce semantic drift and make behavior assertions explicit.

Fixtures are used for:

- Tier 2 semantic calibration.
- Acceptance validation for generated implementations.
- Cross-agent conformance checks.

## Directory and Naming

Fixture location:

- `fixtures/` directory within each service.

File naming:

- `{case-name}.fixture.json`

Naming recommendations:

- `valid-*` for expected-pass fixtures.
- `invalid-*` for expected-fail fixtures.
- `edge-*` for boundary behavior fixtures.

## Fixture Schema

Each fixture file MUST include:

- `input`
- `expected_output`
- `metadata`

Illustrative fixture:

```json
{
  "input": {
    "text": "user@example.com"
  },
  "expected_output": {
    "valid": true
  },
  "metadata": {
    "id": "valid-email-basic",
    "type": "positive",
    "description": "Simple valid email should pass validation.",
    "expected_result": "pass"
  }
}
```

## Coverage Requirements

Every governed contract MUST include:

- At least one positive fixture.
- At least one negative fixture.
- At least one edge-case fixture.

Minimum coverage applies per behavior family, not per service globally.

If a service has multiple behavioral families, each family requires positive/negative/edge coverage.

## Semantic Anchoring

Tier 2 evaluation MUST calibrate against fixture expectations before applying semantic rules to repository state.

Calibration rule:

- If fixture calibration fails, semantic evaluation fails closed.

Conformance rule:

- Supported host-agent classes SHOULD run the same fixture pack to detect compatibility variance.

## Quality Guidelines

Fixtures SHOULD be:

- Minimal (include only fields needed for the case).
- Stable (avoid unrelated timestamp/random data).
- Isolated (one main behavior assertion per fixture).

Fixtures MUST:

- Use schema-valid input/output structures.
- Declare expected result intent through metadata.
- Be version-tracked with the contract that they validate.

## Drift Control

When schemas, rules, or invariants change:

- Re-evaluate impacted fixtures.
- Update or add fixtures before accepting the contract change.
- Treat missing fixture updates as contract drift.

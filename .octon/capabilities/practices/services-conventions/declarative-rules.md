---
title: Service Declarative Rules
scope: harness
applies_to: services
---

# Service Declarative Rules

Declarative rules replace imperative script logic as the authoritative expression of service governance behavior.

Related docs:

- `.octon/cognition/_meta/architecture/agent-as-runtime.md`
- `conventions/rich-contracts.md`
- `conventions/validation-tiers.md`

## Purpose

Rules define what must be true, what is checked, and what happens when checks fail.

Rules MUST be:

- Declarative (describe intent, not procedural shell flow).
- Deterministically ordered.
- Fail-closed by default.

## Canonical Rule Shape

Each rule MUST include:

- `id`
- `description`
- `category`
- `severity`
- `condition`
- `target`
- `action`

Illustrative rule:

```yaml
id: service.schema.input.required
description: Input schema file must exist and parse as valid JSON Schema.
category: structural
severity: high
condition:
  type: file_exists_and_schema_valid
  path: schema/input.schema.json
target:
  kind: file
  selector: schema/input.schema.json
action:
  mode: block
  code: INPUT_VALIDATION
  message: Missing or invalid input schema.
```

## Rule Categories

- `structural`: existence, shape, and contract wiring checks.
- `semantic`: behavior interpretation using fixtures and invariants.
- `policy`: organizational controls (fail-closed, waiver constraints, governance thresholds).

## Severity and Enforcement

Severity levels:

- `low`
- `medium`
- `high`
- `critical`

Allowed enforcement modes:

- `block`
- `warn`
- `off`

Default behavior:

- If rule parsing fails, treat as `block`.
- If enforcement mode is omitted, default to `block`.

## Evaluation Semantics

Rules MUST be evaluated with deterministic ordering:

1. `category` order: structural, semantic, policy
2. `severity` order: critical, high, medium, low
3. lexical `id` order

Execution rules:

- Structural blockers terminate evaluation early.
- Semantic rules run only when structural rules pass.
- Policy rules run last and can override pass states to block.

## Failure Semantics

Rule failures MUST map to standardized error semantics from:

- `conventions/error-codes.md`

Minimum failure payload:

- `rule_id`
- `category`
- `severity`
- `target`
- `action.mode`
- `error.code`
- `message`

## Caching and Hashing

Rule evaluations SHOULD be cached using a deterministic key derived from:

- `contract_hash`
- `rule_set_hash`
- `fixture_set_hash` (semantic rules only)
- `target_state_hash`
- `validator_version`

Cache validity:

- Invalidate on any content hash change.
- Never reuse cache across mismatched contract versions.

## Authoring Constraints

Rule authors SHOULD:

- Keep each rule single-purpose.
- Avoid cross-rule hidden dependencies.
- Use stable IDs that do not encode transient filenames.

Rule authors MUST:

- Provide actionable failure messages.
- Keep rule logic expressible without runtime-specific assumptions.

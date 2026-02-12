---
title: Contract-first
description: Define and validate interface contracts before implementation to keep systems compatible and predictable.
pillar: Direction, Trust
status: Active
---

# Contract-first

> Define contracts up front, then implement to the contract and enforce compatibility in CI.

## What This Means

APIs, events, and structured payloads must be defined in OpenAPI/JSON Schema before implementation starts. Generated types and contract tests then become the default integration path.

Contract-first keeps teams and agents aligned on expected behavior and reduces integration ambiguity.

## Why It Matters

### Pillar Alignment: Direction through Validated Discovery

Direction requires explicit intent before execution. Contract-first is the technical expression of that validation for interfaces.

### Pillar Alignment: Trust through Governed Determinism

Typed, versioned contracts reduce surprises between producers and consumers.

### Quality Attributes Promoted

- **Reliability**: fewer runtime contract mismatches.
- **Maintainability**: single change surface for interface behavior.
- **Scalability**: easier multi-client evolution through versioning.
- **Security**: explicit validation and schema-level constraints.

## In Practice

### ✅ Do

```typescript
// Good: implementation follows generated contract types
import type { paths } from '../contracts/openapi.generated';

type CreateUserReq = paths['/users']['post']['requestBody']['content']['application/json'];

export async function createUser(input: CreateUserReq) {
  // validated against schema at boundary
}
```

```python
# Good: schema-first validation on ingress
from jsonschema import validate

CREATE_USER_SCHEMA = {"type": "object", "required": ["email"], "properties": {"email": {"type": "string", "format": "email"}}}

def create_user(payload: dict) -> dict:
    validate(instance=payload, schema=CREATE_USER_SCHEMA)
    return {"id": "u_123", "email": payload["email"]}
```

### ❌ Don't

```typescript
// Bad: route ships before contract update
app.post('/users', async (req, res) => {
  // undocumented fields accepted silently
  res.json({ ok: true });
});
```

```python
# Bad: implicit payload contract, no versioning

def handle_event(evt: dict):
    # breaks when producer renames "userEmail" -> "email"
    send(evt["userEmail"])
```

## Relationship to Other Principles

- `Single Source of Truth` makes schemas authoritative.
- `Documentation is Code` keeps interface intent versioned.
- `Observability as a Contract` ensures contract breakage is detectable.

## Anti-Pattern: Code-first Drift

When implementations change before contracts, generated clients drift, compatibility breaks late, and CI loses predictive power.

## Exceptions

Skip full schema formalization only for short-lived exploratory spikes that never ship to production. Convert to contract-first before merge.

## Related Documentation

- `docs/api-design-guidelines.md`
- `docs/architecture/governance-model.md`
- `docs/methodology/README.md`
- `docs/pillars/direction.md`
- `docs/pillars/trust.md`

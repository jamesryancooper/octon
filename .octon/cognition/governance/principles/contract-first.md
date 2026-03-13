---
title: Contract-first
description: Define and validate interface contracts before implementation to keep systems compatible and predictable.
pillar: Direction, Trust
status: Active
---

# Contract-first

> Define contracts up front, then implement to the contract and enforce compatibility in CI.

## What This Means

External/shared interfaces and ACP-2/ACP-3 promotion-relevant payloads must be defined in OpenAPI/JSON Schema and validated before ACP promotion to durable state. For ACP-1 internal-only slices, lighter typed contracts are acceptable when explicit, versioned, and included in the promoted slice. Generated types and contract tests remain the default integration path for shared interfaces.

Contract-first keeps teams and agents aligned on expected behavior and reduces integration ambiguity.

## Stage vs Promote

Stage-only exploratory work may use provisional contracts while iterating on shape and constraints.
Before any durable promotion, contracts must be finalized, validated, and included in the promoted slice (receipt-linked unit).
Promotion authority remains the ACP gate: see [Autonomous Control Points](./autonomous-control-points.md).
Artifact timing and promotable-slice semantics are defined in [Documentation is Code](./documentation-is-code.md#promotable-slice-definition).
Promotion input minimums and receipt requirements are canonical in the RA/ACP
promotion inputs matrix.

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

## Canonical References

- Promotion inputs and receipt requirements: [RA/ACP Promotion Inputs Matrix](../controls/ra-acp-promotion-inputs-matrix.md)
- Shared terminology: [RA/ACP Glossary](../controls/ra-acp-glossary.md)

## Anti-Pattern: Code-first Drift

When implementations change before contracts, generated clients drift, compatibility breaks late, and CI loses predictive power.

## Exceptions

Exploratory stage-only spikes may use provisional contracts. ACP-1 internal-only changes may use lighter typed contracts; shared/external interfaces and ACP-2/ACP-3 promotion paths must use formal schemas before durable promotion.

## Related Documentation

- `.octon/scaffolding/governance/patterns/api-design-guidelines.md`
- `.octon/cognition/_meta/architecture/governance-model.md`
- `.octon/cognition/practices/methodology/README.md`
- `.octon/cognition/governance/pillars/direction.md`
- `.octon/cognition/governance/pillars/trust.md`

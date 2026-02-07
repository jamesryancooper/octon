---
title: Single Source of Truth
description: Define each type of knowledge in exactly one authoritative location. Derive, don't duplicate.
pillar: Continuity, Trust
status: Active
---

# Single Source of Truth

> Define each type of knowledge in exactly one authoritative location. Everything else derives from it.

## What This Means

Single Source of Truth (SSOT) is an information architecture principle: for any piece of knowledge, there should be exactly one place where it is defined authoritatively. All other representations should be generated, derived, or linked — never manually duplicated.

This applies to:

- **Data schemas**: Define once, generate types and validators
- **API contracts**: OpenAPI spec is the source, clients are generated
- **Configuration**: One config file, environment-specific overrides
- **Documentation**: Code comments generate API docs, not the reverse
- **Business rules**: Defined in one place, enforced everywhere

## Why It Matters

### Pillar Alignment: Continuity through Institutional Memory

The Continuity pillar captures knowledge durably. But durability without integrity creates confusion: which version is correct?

SSOT ensures that institutional memory remains coherent:

- Decisions are recorded once, referenced everywhere
- Updates propagate automatically
- Drift between representations is impossible by design

### Pillar Alignment: Trust through Governed Determinism

The Trust pillar promises predictable behavior. SSOT enables this by eliminating a common source of bugs: inconsistency between representations.

When types are generated from schemas:

- API changes automatically update client code
- Runtime validation matches compile-time types
- Documentation stays synchronized with implementation

## In Practice

### The Derivation Chain

Identify the authoritative source for each type of knowledge, then establish derivation chains:

```
OpenAPI Spec (source)
        ↓
   ┌────┴────┐
   ↓         ↓
TypeScript  Pact
  Types    Contracts
   ↓         ↓
Client    Contract
 Code      Tests
```

### ✅ Do

**Generate types from schemas:**

```typescript
// openapi.yaml (SOURCE)
components:
  schemas:
    User:
      type: object
      properties:
        id: { type: string, format: uuid }
        email: { type: string, format: email }
        createdAt: { type: string, format: date-time }

// Generated: types/user.ts (DERIVED)
// Do not edit manually — regenerate from openapi.yaml
export interface User {
  id: string;
  email: string;
  createdAt: string;
}
```

**Use schema-driven validation:**

```typescript
// Good: Validate against the same schema used for types
import { userSchema } from './generated/schemas';

function createUser(input: unknown): User {
  return userSchema.parse(input); // Runtime matches compile-time
}
```

**Link to sources instead of copying:**

```markdown
<!-- Good: Reference the source -->
For API details, see the [OpenAPI specification](../openapi.yaml).

<!-- Bad: Copy that will drift -->
## API Details
The user endpoint accepts the following fields:
- id: string (UUID)
- email: string
...
```

**Define configuration once:**

```yaml
# config/base.yaml (SOURCE)
database:
  pool_size: 10
  timeout_ms: 5000

# config/production.yaml (OVERRIDES only)
database:
  pool_size: 50  # Override for production scale
```

### ❌ Don't

**Don't maintain parallel definitions:**

```typescript
// Bad: Manual type that will drift from API
interface User {
  id: string;
  email: string;
  // Someone added 'name' to the API but forgot here
}

// Bad: Separate validation that will drift from type
const validateUser = (data: any) => {
  if (!data.id || !data.email || !data.name) {  // Different fields!
    throw new Error('Invalid user');
  }
};
```

**Don't copy documentation:**

```markdown
<!-- Bad: Same content in two places -->
# docs/api/users.md
The User object has fields: id, email, name...

# README.md
## API Reference
The User object has fields: id, email...  # Already outdated
```

**Don't hardcode derived values:**

```typescript
// Bad: Magic number that should derive from config
const POOL_SIZE = 10;

// Good: Import from configuration source
import { config } from './config';
const poolSize = config.database.pool_size;
```

## Implementation Patterns

### Schema-First Development

1. Define the schema (OpenAPI, JSON Schema, Prisma)
2. Generate types, validators, and clients
3. Implement against generated interfaces
4. Regenerate on schema changes

```bash
# Typical workflow
pnpm openapi:generate  # Updates types from spec
pnpm prisma generate   # Updates client from schema
pnpm build             # Fails if types don't match
```

### ADR as Decision Source

Architecture decisions are defined in ADRs, referenced elsewhere:

```markdown
<!-- Source: docs/adr/0001-use-postgresql.md -->
# ADR-0001: Use PostgreSQL for primary data store

## Decision
We will use PostgreSQL as our primary database.

## Rationale
- ACID compliance for financial data
- JSON support for flexible schemas
- Team familiarity
```

```markdown
<!-- Reference: docs/architecture/data-layer.md -->
We use PostgreSQL as our primary data store
(see [ADR-0001](../adr/0001-use-postgresql.md) for rationale).
```

### Configuration Hierarchy

```
config/
├── base.yaml        # Defaults (SOURCE)
├── development.yaml # Dev overrides
├── staging.yaml     # Staging overrides
└── production.yaml  # Production overrides
```

Runtime configuration merges: `base + environment`, not separate complete configs.

### Workspace Source of Truth

In Harmony workspaces, each type of knowledge has a designated home:

| Knowledge Type | Source Location | Derived Artifacts |
|---------------|-----------------|-------------------|
| Scope boundaries | `scope.md` | — |
| Conventions | `conventions.md` | Linter rules |
| Available commands | `catalog.md` | — |
| Task state | `continuity/tasks.json` | `continuity/log.md` entries |
| Decisions | `cognition/context/decisions.md` | ADR references |
| Skills | `SKILL.md` | Manifest entries |

## Enforcement Mechanisms

### Generation Scripts

```json
// package.json
{
  "scripts": {
    "generate": "pnpm openapi:generate && pnpm prisma generate",
    "prebuild": "pnpm generate",
    "lint:generated": "check-generated-files --fresh"
  }
}
```

### CI Validation

```yaml
# .github/workflows/ci.yml
- name: Check generated files are fresh
  run: |
    pnpm generate
    git diff --exit-code || (echo "Generated files are stale" && exit 1)
```

### Import Restrictions

```javascript
// eslint.config.js
rules: {
  'no-restricted-imports': ['error', {
    patterns: [{
      group: ['**/generated/**'],
      message: 'Import from the source schema, not generated files directly'
    }]
  }]
}
```

## Relationship to Other Principles

| Principle | Relationship |
|-----------|--------------|
| Contract-first | Contracts are the single source; implementations derive |
| Documentation is code | Code/schemas are source; docs derive |
| Progressive Disclosure | Different views of same source at different depths |
| Simplicity Over Complexity | SSOT reduces the complexity of keeping things in sync |

## Exceptions

Manual duplication may be acceptable when:

- **Performance requires denormalization**: Materialized views, caches (but mark as derived)
- **External systems require specific formats**: Generate/transform from source
- **Offline access requires local copies**: Sync mechanisms maintain consistency

Always document the source and the sync mechanism.

## Anti-Pattern: Drift

The primary failure mode of violating SSOT is **drift** — representations that were once consistent but diverge over time.

Signs of drift:

- "The API docs are outdated"
- "The types don't match the actual response"
- "The config file says one thing but the code does another"

Prevention:

- Generate, don't duplicate
- Validate in CI that derived artifacts are fresh
- Delete stale documentation rather than maintain parallel copies

## Related Documentation

- [Continuity Pillar](../pillars/continuity.md) — Durable knowledge capture
- [Trust Pillar](../pillars/trust.md) — Predictable behavior through consistency
- [Contract-first Principle](./core/contract-first.md) — API contracts as source
- [Documentation is Code](./core/documentation-is-code.md) — Generating docs from source

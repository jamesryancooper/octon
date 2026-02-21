---
title: Simplicity Over Complexity
description: Default to the smallest viable solution that solves the problem. Add complexity only when evidence demands it.
pillar: Focus, Velocity
status: Active
---

# Simplicity Over Complexity

> Default to the smallest viable solution. Add complexity only when evidence demands it.

## What This Means

Simplicity over complexity is a decision-making heuristic: when faced with multiple valid approaches, choose the simpler one unless you have concrete evidence that complexity is necessary.

This is not minimalism for its own sake. It's a recognition that:

- Complexity has compounding maintenance costs
- Simple systems are easier to understand, debug, and modify
- Premature abstraction often creates the wrong abstraction
- You can always add complexity later; removing it is harder

Simplicity never waives assurance controls. Deny-by-default, ACP gates,
receipts, and required safety evidence are mandatory constraints, not optional
complexity.

## Why It Matters

### Pillar Alignment: Focus through Absorbed Complexity

The Focus pillar promises developers "cognitive bandwidth freed for what matters." Every unnecessary abstraction, service boundary, or configuration option consumes attention that could go toward solving actual problems.

Harmony absorbs complexity into kits and conventions so developers don't have to manage it. But this only works if we're rigorous about what complexity we introduce in the first place.

### Pillar Alignment: Velocity through Agentic Automation

Simple systems have fewer failure modes, shorter feedback loops, and faster iteration cycles. The Velocity pillar's promise of "sustained, high-frequency delivery" depends on:

- Fewer moving parts to coordinate
- Shorter paths from change to deployment
- Less cognitive overhead per decision

### The Two-Dev Scope Principle

Harmony is designed for small teams (often one developer with AI assistance). This context shapes our defaults:

> *"Default to the smallest viable process, design, and tooling that enforces the principles without burden."*

What works for a 50-person team may be overhead for two. Start simple; scale complexity with evidence.

## In Practice

### The Simplicity Ladder

When solving a problem, prefer solutions lower on the ladder:

| Level | Pattern | Example |
|-------|---------|---------|
| 1 | Single file | One module handles the feature |
| 2 | Single service | Monolith with clear boundaries |
| 3 | Modular monolith | Feature slices with enforced boundaries |
| 4 | Service extraction | Single extracted service |
| 5 | Distributed system | Multiple coordinating services |

Move up the ladder only when you have **measured evidence** that the current level is insufficient.

### ✅ Do

**Start with a monolith:**

```typescript
// Good: Single service, clear module boundaries
// apps/api/src/features/
//   ├── users/
//   ├── billing/
//   └── notifications/
```

**Use feature flags instead of premature service extraction:**

```typescript
// Good: Same codebase, different behavior
if (await flags.isEnabled('new-billing-engine')) {
  return newBillingEngine.calculate(order);
}
return legacyBilling.calculate(order);
```

**Prefer inline code over abstraction until patterns emerge:**

```typescript
// Good: Direct implementation
async function createUser(data: UserInput) {
  const user = await db.users.create({ data });
  await sendWelcomeEmail(user.email);
  return user;
}

// Premature: Abstract factory before you need it
// const userFactory = new UserFactory(emailService, db);
// await userFactory.create(data);
```

**Choose boring technology:**

```yaml
# Good: Well-understood, battle-tested
database: PostgreSQL
cache: Redis
queue: PostgreSQL (pg-boss) or Redis (BullMQ)
```

### ❌ Don't

**Don't extract services without evidence:**

```
# Bad: Microservices from day one
user-service/
billing-service/
notification-service/
api-gateway/
service-mesh/
```

**Don't add abstraction layers "for flexibility":**

```typescript
// Bad: Repository pattern when you only have one database
interface UserRepository { ... }
class PostgresUserRepository implements UserRepository { ... }
class InMemoryUserRepository implements UserRepository { ... }  // "for testing"

// Good: Direct Prisma calls until you actually need abstraction
const user = await prisma.user.findUnique({ where: { id } });
```

**Don't configure what you can convention:**

```typescript
// Bad: Configuration for configuration's sake
const config = {
  userService: {
    maxRetries: 3,
    retryDelay: 1000,
    timeout: 5000,
    // ... 20 more options
  }
};

// Good: Sensible defaults, override only when needed
const client = createClient(); // Uses conventions
```

**Don't introduce choreography without coordination needs:**

```
# Bad: Event-driven architecture for sequential operations
UserCreated → SendWelcomeEmail → EmailSent → UpdateUserRecord

# Good: Direct calls for simple flows
createUser() → sendWelcomeEmail() → done
```

## Decision Framework

### When to Add Complexity

Add complexity when you have **specific, measurable evidence**:

| Signal | Response |
|--------|----------|
| Module exceeds 5000 lines | Consider splitting (but measure first) |
| Different scaling requirements | Consider service extraction |
| Team coordination bottleneck | Consider ownership boundaries |
| Performance data shows bottleneck | Optimize the measured hot path |
| Compliance requires isolation | Extract to separate service |

### Questions to Ask

Before adding complexity, answer:

1. **What specific problem does this solve?** (Not "might solve someday")
2. **What's the maintenance cost?** (Every abstraction has carrying cost)
3. **Can we defer this decision?** (Future-you has more information)
4. **What's the rollback plan?** (Complexity is easier to add than remove)

### The "Prove Me Wrong" Test

Propose the simplest solution. Then ask: *"What evidence would force me to complicate this?"*

If you can't articulate specific, measurable thresholds, stay simple.

## Common Simplicity Anti-Patterns

### Speculative Generality

Building for requirements you don't have:

```typescript
// Bad: "We might need multiple payment providers"
interface PaymentProvider { ... }
class StripeProvider implements PaymentProvider { ... }
class PaymentProviderFactory { ... }

// Good: Use Stripe directly. Extract the interface when you add a second provider.
const stripe = new Stripe(apiKey);
await stripe.charges.create({ ... });
```

### Premature Optimization

Optimizing before measuring:

```typescript
// Bad: "Caching will make it faster"
const cachedUser = await cache.get(`user:${id}`);
if (!cachedUser) {
  const user = await db.users.findUnique({ where: { id } });
  await cache.set(`user:${id}`, user);
  return user;
}
return cachedUser;

// Good: Direct query. Add caching when you measure a latency problem.
return db.users.findUnique({ where: { id } });
```

### Cargo Cult Architecture

Copying patterns from different contexts:

> *"Netflix uses microservices, so we should too."*

Netflix has thousands of engineers and millions of requests per second. Your context is different. Match architecture to actual needs.

## Relationship to Other Principles

| Principle | Relationship |
|-----------|--------------|
| Progressive Disclosure | Simplicity in information architecture |
| Single Source of Truth | Reduces duplication complexity |
| Monolith-first | Specific application of simplicity to architecture |
| Small diffs, trunk-based | Simplicity in workflow |

## Exceptions

Complexity is justified when:

- **Compliance requires it**: Some regulations mandate specific architectures
- **Proven scale demands it**: Measured load exceeds single-service capacity
- **Team structure requires it**: Conway's Law boundaries
- **Risk isolation requires it**: Security boundaries for sensitive data

Document the justification in an ADR.

## Related Documentation

- [Focus Pillar](../pillars/focus.md) — Absorbed complexity principle
- [Velocity Pillar](../pillars/velocity.md) — Speed through simplicity
- [Monolith-first Modulith](./monolith-first-modulith.md) — Architecture application
- [Anti-Principles](./README.md#anti-principles-explicitly-rejected) — Complexity patterns to avoid

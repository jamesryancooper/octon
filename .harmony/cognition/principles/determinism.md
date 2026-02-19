---
title: Governed Determinism
description: Deterministic-by-default behavior with bounded, policy-approved variance and full provenance for reproducibility.
pillar: Trust, Insight
status: Active
---

# Governed Determinism

> Deterministic by default. When variance is needed, keep it bounded, policy-approved, and fully recorded for reproducibility.

## What This Means

Determinism is a reliability principle: by default, the same inputs should produce the same outputs. Harmony also allows policy-approved bounded variance for long autonomous runs and recovery strategies, provided that variance mode and parameters are declared and recorded. This enables:

- **Reproducibility**: Bugs can be recreated and verified as fixed
- **Testability**: Tests are reliable, not flaky
- **Debugging**: Behavior can be traced and understood
- **Auditability**: Past decisions can be reviewed and explained

In AI-assisted development, determinism is especially critical because LLMs are inherently probabilistic. Harmony manages this through explicit configuration, pinning, bounded variance controls, and provenance tracking.

## Why It Matters

### Pillar Alignment: Trust through Governed Determinism

The Trust pillar explicitly includes "governed determinism" — predictable behavior is foundational to trust. When systems behave unpredictably:

- Developers lose confidence in deployments
- Debugging becomes guesswork
- Tests provide false confidence (pass sometimes, fail sometimes)
- Incidents are harder to diagnose and prevent

### Pillar Alignment: Insight through Structured Learning

The Insight pillar promises "every outcome teaches us something." But learning requires:

- Knowing what inputs produced what outputs
- Being able to reproduce conditions to test hypotheses
- Comparing runs with controlled variables

Non-determinism breaks the feedback loop: you can't learn from what you can't reproduce.

### The AI Determinism Challenge

LLMs introduce unique challenges:
- Same prompt can produce different outputs
- Model versions change behavior
- Temperature and sampling affect results
- Context window contents vary

Harmony addresses these through explicit controls and provenance tracking.

## In Practice

### The Determinism Stack

| Layer | Strategy | Implementation |
|-------|----------|----------------|
| Dependencies | Pin versions | Lock files, exact versions |
| Configuration | Version and hash | Config files in source control |
| AI Models | Pin provider/model/version | Explicit config, not "latest" |
| AI Parameters | Deterministic default + bounded variance mode | Documented settings + policy receipt reference |
| Randomness | Seeded generators | Explicit seed management |
| Time | Inject time | Avoid `Date.now()` in logic |
| External Services | Mock or record | Deterministic test doubles |

### ✅ Do

**Pin all dependencies:**

```json
// package.json
{
  "dependencies": {
    "lodash": "4.17.21",     // Exact version
    "express": "4.18.2"      // Not "^4.18.2"
  }
}
```

```toml
# pyproject.toml
[tool.poetry.dependencies]
requests = "2.31.0"          # Exact version
```

**Pin AI model configurations:**

```yaml
# prompts/analyze-code.yaml
model:
  provider: anthropic
  name: claude-sonnet-4-20250514
  version: "20250514"        # Explicit version, not "latest"
  
parameters:
  mode: deterministic         # Default mode
  temperature: 0.0            # Default deterministic setting
  max_tokens: 4096
  # seed: 42                 # If supported by provider
  # variance_mode: bounded_exploration  # Policy-approved only
  # variance_seed: 42                  # Required when variance_mode is set
  # acp_receipt_id: "rcpt-..."         # Required when variance_mode is set
```

**Track provenance for AI outputs:**

```typescript
// Good: Full provenance tracking
interface AIInvocation {
  // Input provenance
  prompt_hash: string;
  prompt_version: string;
  context_hash: string;
  
  // Model provenance
  provider: string;
  model: string;
  model_version: string;
  parameters: {
    mode: 'deterministic' | 'bounded_variance';
    temperature: number;
    max_tokens: number;
    seed?: number;
  };
  acp_receipt_id?: string; // Required when mode = bounded_variance
  
  // Output provenance
  output_hash: string;
  trace_id: string;
  timestamp: string;
}

const result = await llm.complete(prompt, {
  temperature: 0,
  onComplete: (response) => {
    audit.log({
      mode: 'deterministic',
      prompt_hash: hash(prompt),
      model: 'claude-sonnet-4-20250514',
      output_hash: hash(response),
      trace_id: context.traceId
    });
  }
});
```

**Use idempotency keys for mutations:**

```typescript
// Good: Idempotent mutation
async function processPayment(
  order: Order, 
  idempotencyKey: string
): Promise<PaymentResult> {
  // Check if already processed
  const existing = await payments.findByIdempotencyKey(idempotencyKey);
  if (existing) {
    return existing.result;  // Return same result
  }
  
  const result = await paymentProcessor.charge(order);
  await payments.save({ idempotencyKey, result });
  return result;
}
```

**Inject time and randomness:**

```typescript
// Good: Injected dependencies
class OrderService {
  constructor(
    private clock: Clock = new SystemClock(),
    private random: Random = new SecureRandom()
  ) {}
  
  createOrder(items: Item[]): Order {
    return {
      id: this.random.uuid(),
      createdAt: this.clock.now(),
      items
    };
  }
}

// Test with deterministic doubles
const service = new OrderService(
  new FixedClock('2024-01-15T10:00:00Z'),
  new SeededRandom(42)
);
```

### ❌ Don't

**Don't use version ranges:**

```json
// Bad: Version ranges
{
  "dependencies": {
    "lodash": "^4.17.0",    // Could be any 4.17.x
    "express": "~4.18.0"    // Could be any 4.18.x
  }
}
```

**Don't use "latest" for AI models:**

```yaml
# Bad: Implicit version
model:
  provider: anthropic
  name: claude-sonnet  # Which version? Will change!
  
parameters:
  temperature: 0.7     # Unbounded variance with no policy declaration
```

**Don't rely on implicit ordering:**

```typescript
// Bad: Non-deterministic ordering
const users = await db.users.findMany();
// Order not guaranteed!

// Good: Explicit ordering
const users = await db.users.findMany({
  orderBy: { createdAt: 'asc' }
});
```

**Don't use wall-clock time in logic:**

```typescript
// Bad: Time-dependent behavior
function isExpired(token: Token): boolean {
  return token.expiresAt < Date.now();  // Non-deterministic!
}

// Good: Injected time
function isExpired(token: Token, now: Date): boolean {
  return token.expiresAt < now.getTime();
}
```

**Don't skip idempotency for mutations:**

```typescript
// Bad: Non-idempotent
async function sendEmail(user: User, template: string) {
  await emailService.send(user.email, template);
  // Retry = duplicate email!
}

// Good: Idempotent with key
async function sendEmail(
  user: User, 
  template: string,
  idempotencyKey: string
) {
  const sent = await emailLog.exists(idempotencyKey);
  if (sent) return;
  
  await emailService.send(user.email, template);
  await emailLog.record(idempotencyKey);
}
```

## Implementation Patterns

### Lock File Discipline

```bash
# Always commit lock files
git add package-lock.json
git add pnpm-lock.yaml
git add poetry.lock
git add uv.lock

# CI should fail on lock file drift
- name: Check lock file
  run: |
    pnpm install --frozen-lockfile
```

### Prompt Versioning

```
prompts/
├── analyze-code/
│   ├── v1.0.0.md
│   ├── v1.1.0.md
│   └── current -> v1.1.0.md
└── manifest.yaml
```

```yaml
# manifest.yaml
prompts:
  analyze-code:
    current: v1.1.0
    versions:
      v1.0.0:
        hash: sha256:abc123...
        deprecated: true
      v1.1.0:
        hash: sha256:def456...
```

### Test Determinism

```typescript
// Deterministic test setup
beforeEach(() => {
  // Fixed time
  jest.useFakeTimers();
  jest.setSystemTime(new Date('2024-01-15T10:00:00Z'));
  
  // Seeded random
  jest.spyOn(Math, 'random').mockReturnValue(0.5);
  
  // Mocked external services
  mockExternalApi.reset();
});

afterEach(() => {
  jest.useRealTimers();
  jest.restoreAllMocks();
});
```

### Build Reproducibility

```dockerfile
# Dockerfile with pinned versions
FROM node:20.11.0-alpine3.19  # Exact version

# Deterministic package install
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Reproducible build
ARG BUILD_TIME
ARG GIT_SHA
ENV BUILD_TIME=${BUILD_TIME}
ENV GIT_SHA=${GIT_SHA}
```

## Relationship to Other Principles

| Principle | Relationship |
|-----------|--------------|
| Single Source of Truth | One source of version truth (lock files) |
| Reversibility | Deterministic systems have predictable rollback |
| Deny by Default | Predictable permission decisions |
| Autonomous Control Points | Policy gates evaluate deterministic diffs before promotion |

## Policy-Bounded Variance and Acceptable Non-Determinism

Harmony permits bounded variance only when policy allows it and the run is fully traceable in receipts.

For bounded variance in autonomous runs:
1. Declare mode as `bounded_variance` before execution
2. Record variance parameters (for example `temperature`, `seed`, sampling controls)
3. Attach the ACP receipt reference for the policy decision
4. Keep variance bounded to the approved range and time window

Some non-determinism is acceptable when:

- **UUIDs for identifiers**: As long as they're generated once and stored
- **Cryptographic randomness**: Security requires true randomness
- **Load balancing**: Distribution across replicas
- **Cache timing**: Performance optimization

For these cases:
1. Isolate non-determinism to specific layers
2. Ensure non-determinism doesn't affect business logic correctness
3. Log enough context to debug issues

## Anti-Pattern: Flaky Systems

The primary failure mode of ignoring determinism is **flaky systems** — behavior that varies unpredictably.

Signs of flaky systems:
- Tests that pass sometimes, fail sometimes
- "It works on my machine"
- Bugs that can't be reproduced
- AI outputs that vary dramatically between runs

Prevention:
- Pin all versions explicitly
- Inject time and randomness
- Use idempotency keys
- Track full provenance for AI calls

## Arbitration

If this principle conflicts with another, apply
[Arbitration & Precedence](./README.md#arbitration--precedence).
Determinism is default; bounded variance requires explicit policy and receipt provenance.

## Related Documentation

- [Trust Pillar](../pillars/trust.md) — Governed determinism for predictable behavior
- [Insight Pillar](../pillars/insight.md) — Learning requires reproducibility
- [Agentic Principles](./README.md#agentic-principles) — Determinism & provenance for AI
- [Autonomous Control Points](./autonomous-control-points.md) — Policy gates and receipts for bounded variance
- [EvalKit](/.harmony/capabilities/services/_meta/docs/kits-reference.md) — Deterministic AI evaluation

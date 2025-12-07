# CostKit - LLM Cost Management

CostKit provides comprehensive cost management for AI-enabled workflows, including pre-flight estimation, real-time tracking, budget management, and alerting.

## Interfaces

CostKit provides three interfaces:

| Interface | Consumers | Use For |
|-----------|-----------|---------|
| **Programmatic API** (primary) | AI agents, services | Production cost tracking, automated budgeting |
| **HTTP Runner** | Python agents, microservices | Cross-language, distributed systems |
| **CLI** | Humans, CI/CD | Debugging, cost reports, manual checks |

## Programmatic API (Primary)

The programmatic API is the **source of truth** for CostKit functionality.

### Quick Start

```typescript
import { CostKit } from '@harmony/costkit';

// Initialize with default policy
const costKit = new CostKit();

// Or with custom policy
const costKit = new CostKit({
  policyPath: './cost-policy.yaml',
  dataPath: './.harmony/cost-data.json',
});

// Get pre-flight estimate
const estimate = costKit.estimate({
  workflowType: 'code-from-plan',
  tier: 'T2',
  stage: 'final',
});

console.log(costKit.formatEstimate(estimate));

// Check budget before proceeding
const budgetCheck = costKit.checkBudget(estimate.estimatedCostUsd);
if (!budgetCheck.allowed) {
  console.warn('Budget exceeded:', budgetCheck.reason);
  return;
}

// Record actual usage after operation completes
costKit.recordUsage({
  model: 'gpt-4o',
  inputTokens: 5200,
  outputTokens: 3800,
  workflowType: 'code-from-plan',
  tier: 'T2',
  estimateId: estimate.estimateId,
  durationMs: 12500,
  success: true,
});
```

### Configuration

```typescript
interface CostKitConfig {
  /** Path to cost policy file */
  policyPath?: string;

  /** Inline policy (takes precedence over policyPath) */
  policy?: CostPolicy;

  /** Path to store usage data */
  dataPath?: string;

  /** Enable real-time tracking */
  enableTracking?: boolean;

  /** Enable alerting */
  enableAlerts?: boolean;

  /** Enable cost estimates before operations */
  enableEstimates?: boolean;

  /** Enable run record generation (default: true) */
  enableRunRecords?: boolean;

  /** Directory to write run records */
  runsDir?: string;
}
```

### Key Methods

#### `estimate(options): CostEstimate`

Get pre-flight cost estimate for an operation:

```typescript
const estimate = costKit.estimate({
  workflowType: 'spec-from-intent',
  tier: 'T2',
  inputText: 'Add user authentication with Google OAuth...',
});

console.log(`Estimated: $${estimate.estimatedCostUsd.toFixed(4)}`);
console.log(`Range: $${estimate.costRange.min.toFixed(4)} - $${estimate.costRange.max.toFixed(4)}`);
```

#### `recordUsage(params): UsageRecord`

Record actual usage after an operation:

```typescript
const record = costKit.recordUsage({
  model: 'gpt-4o',
  inputTokens: 5000,
  outputTokens: 3000,
  workflowType: 'code-from-plan',
  tier: 'T2',
  durationMs: 12500,
  success: true,
});
```

#### `getBudgetStatus(period?): BudgetStatus`

Get current budget status:

```typescript
const status = costKit.getBudgetStatus('monthly');
console.log(`Spent: $${status.spentUsd.toFixed(2)} / $${status.limitUsd.toFixed(2)}`);
console.log(`Used: ${status.usedPercent.toFixed(1)}%`);
```

#### `getCostSummary(period?): CostSummary`

Get cost summary with breakdowns:

```typescript
const summary = costKit.getCostSummary('monthly');
console.log(`Total: $${summary.totalSpentUsd.toFixed(2)}`);
console.log('By Model:', summary.byModel);
console.log('By Workflow:', summary.byWorkflow);
```

#### `checkBudget(estimatedCost): { allowed: boolean; reason?: string }`

Check if an operation is within budget:

```typescript
const check = costKit.checkBudget(0.50);
if (!check.allowed) {
  console.log('Blocked:', check.reason);
}
```

## HTTP Interface (Cross-Language)

For Python agents, microservices, or distributed systems:

```typescript
import { createHttpCostRunner } from '@harmony/costkit';

const cost = createHttpCostRunner({
  baseUrl: 'http://costkit-service:8082',
  timeoutMs: 30000,
});

// Same interface as programmatic API
const estimate = await cost.estimate({
  workflowType: 'code-from-plan',
  tier: 'T2',
  stage: 'final',
});

const record = await cost.recordUsage({
  model: 'gpt-4o',
  inputTokens: 5200,
  outputTokens: 3800,
  workflowType: 'code-from-plan',
  tier: 'T2',
  durationMs: 12500,
  success: true,
});

const status = await cost.getBudgetStatus('monthly');
const summary = await cost.getCostSummary('monthly');
const alerts = await cost.getAlerts();
```

### HTTP Protocol

The HTTP runner expects a service implementing:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/cost/estimate` | POST | Get pre-flight cost estimate |
| `/cost/record` | POST | Record actual usage |
| `/cost/status` | GET | Get budget status |
| `/cost/summary` | GET | Get cost summary |
| `/cost/alerts` | GET | Get unacknowledged alerts |
| `/cost/alerts/:id/ack` | POST | Acknowledge an alert |
| `/cost/check-budget` | POST | Check if cost is within budget |

## CLI (Debugging and CI/CD)

The CLI is a **thin wrapper** around the programmatic API for human debugging and CI/CD.

```bash
# Get cost estimate for a workflow
costkit estimate --workflow code-from-plan --tier T2 --workflow-stage final

# Check current budget status
costkit status --period monthly

# Get cost summary
costkit summary --period monthly

# Record usage (typically called by other kits)
costkit record --model gpt-4o --input-tokens 5000 --output-tokens 3000

# View unacknowledged alerts
costkit alerts

# Dry-run mode (default in local)
costkit estimate --dry-run --workflow code-from-plan

# JSON output (matches programmatic API response structure)
costkit status --format json
```

### CLI Commands

| Command | Description |
|---------|-------------|
| `estimate` | Get cost estimate for a workflow |
| `status` | Check current budget status |
| `summary` | Get cost summary for a period |
| `record` | Record actual LLM usage |
| `alerts` | Show unacknowledged alerts |

### CLI Options

| Option | Description |
|--------|-------------|
| `--workflow, -w` | Workflow type (e.g., code-from-plan) |
| `--tier` | Risk tier: T1\|T2\|T3 |
| `--workflow-stage` | Workflow stage: draft\|final |
| `--period, -p` | Budget period: daily\|weekly\|monthly |
| `--model, -m` | Model name (for record) |
| `--input-tokens` | Number of input tokens |
| `--output-tokens` | Number of output tokens |
| `--policy-path` | Path to cost policy YAML |
| `--data-path` | Path to cost data file |

Plus all [standard kit flags](../README.md#standard-cli-flags).

## Tier-Based Model Selection

CostKit automatically selects appropriate models based on risk tier:

| Tier | Stage | Default Model | Max Cost | Use Case |
|------|-------|---------------|----------|----------|
| T1 | - | gpt-4o-mini | $0.01 | Bug fixes, typos, small tasks |
| T2 | draft | gpt-4o-mini | $0.05 | First pass on features |
| T2 | final | gpt-4o | $0.20 | Merge-ready code |
| T3 | - | gpt-4o | $1.00 | Security, auth, data migrations |

```typescript
// Get the appropriate model for a tier
const model = costKit.selectModel('T2', 'final');  // Returns: 'gpt-4o'

// Get all allowed models for a tier
const models = costKit.getTierModels('T1');  // Returns: ['gpt-4o-mini', 'claude-haiku', ...]
```

## Cost Policy Configuration

Create a `cost-policy.yaml` file to customize behavior:

```yaml
version: "1.0.0"

budgets:
  monthly:
    period: monthly
    limit_usd: 500.00
    warning_threshold_percent: 70
    critical_threshold_percent: 90
    block_on_exceed: false

tier_models:
  T1:
    default_model: gpt-4o-mini
    allowed_models: [gpt-4o-mini, claude-haiku]
    max_cost_per_operation: 0.01
  T2_draft:
    default_model: gpt-4o-mini
    max_cost_per_operation: 0.05
  T2_final:
    default_model: gpt-4o
    max_cost_per_operation: 0.20
  T3:
    default_model: gpt-4o
    max_cost_per_operation: 1.00

alerts:
  enabled: true
  channels: [console]
  dedupe_window_minutes: 60
```

## Model Pricing Utilities

```typescript
import { getModelPricing, calculateCost, compareModelCosts } from '@harmony/costkit';

// Get pricing for a model
const pricing = getModelPricing('gpt-4o');
console.log(`Input: $${pricing.inputPricePer1M}/1M tokens`);

// Calculate cost for token usage
const cost = calculateCost('gpt-4o', 5000, 3000);
console.log(`Cost: $${cost.toFixed(4)}`);

// Compare two models
const comparison = compareModelCosts('gpt-4o', 'gpt-4o-mini', 5000, 3000);
console.log(`Cheaper: ${comparison.cheaperModel}`);
console.log(`Savings: ${comparison.savingsPercent.toFixed(1)}%`);
```

## Supported Models

### OpenAI
- gpt-4o, gpt-4o-mini, o1, o1-mini, o3-mini

### Anthropic
- claude-3-5-sonnet, claude-3-5-haiku, claude-3-opus

### Google
- gemini-2.0-flash, gemini-1.5-pro, gemini-1.5-flash

### Mistral
- mistral-large, mistral-small, codestral

## Best Practices

1. **Always estimate before expensive operations**: Use `estimate()` before T2 final or T3 operations.
2. **Respect tier model limits**: Let CostKit select models based on tier.
3. **Monitor weekly**: Check cost summary weekly to catch trends early.
4. **Acknowledge alerts promptly**: Review and acknowledge alerts to maintain clean state.

## Testing

```bash
# Run CostKit tests
pnpm --filter @harmony/costkit test
```

## See Also

- [@harmony/kit-base](../kit-base/README.md) - Shared infrastructure
- [COST-MANAGEMENT.md](/docs/harmony/human/COST-MANAGEMENT.md) - Human-facing cost guide

## License

Private — part of the Harmony monorepo.

# Cost — LLM Cost Management

**Package:** `@harmony/costkit`
**Purpose:** Token & spend guardrails, budget management, model selection, cost optimization
**Status:** Implemented

## Overview

Cost provides comprehensive cost management for AI-enabled workflows:

- **Pre-flight Cost Estimation**: Get accurate cost estimates before running expensive LLM operations
- **Real-time Tracking**: Track actual costs as operations complete
- **Budget Management**: Set and enforce budgets at daily, weekly, and monthly levels
- **Tier-based Model Selection**: Automatically select cost-appropriate models based on risk tier
- **Alerting**: Receive alerts when budgets are exceeded or unusual spending is detected
- **Optimization Suggestions**: Get recommendations for reducing costs

## Integration Points

| Service | Integration |
|---------|-------------|
| **Plan** | Cost estimates before planning, model selection by tier |
| **Agent** | Cost tracking per operation, budget checks before expensive operations |
| **Flow** | Workflow cost estimation, cost-aware routing |
| **Model** | Model catalog, pricing data |
| **Observe** | Cost metrics/spans, usage reporting |
| **Policy** | Budget enforcement policies |

## Responsibilities

1. **Cost Estimation**
   - Estimate tokens based on workflow type and tier
   - Calculate costs using current model pricing
   - Provide confidence intervals for estimates

2. **Model Selection**
   - Select appropriate models by risk tier
   - Enforce max cost per operation limits
   - Support fallback to cheaper models

3. **Budget Enforcement**
   - Track spending against period budgets
   - Block or warn on budget overrun
   - Support daily/weekly/monthly budgets

4. **Alerting**
   - Budget warning/critical/exceeded alerts
   - Unusual spending detection
   - Deprecated model warnings

5. **Reporting**
   - Cost summaries by model/workflow/tier
   - Trend analysis vs previous periods
   - Optimization opportunity identification

## API Reference

### Cost Class

```typescript
import { CostKit } from '@harmony/costkit';

const cost = new CostKit({
  policyPath: './cost-policy.yaml',
  dataPath: './.harmony/cost-data.json',
  enableTracking: true,
  enableAlerts: true,
});
```

### Core Methods

#### `estimate(options)` — Pre-flight Cost Estimate

```typescript
const estimate = cost.estimate({
  workflowType: 'code-from-plan',  // Workflow being run
  tier: 'T2',                       // Risk tier
  stage: 'final',                   // Stage (for T2)
  inputText: '...',                 // Optional: actual input for better accuracy
  outputSizeHint: 'medium',         // Optional: small/medium/large
});

// Returns CostEstimate
{
  estimateId: string;
  model: string;
  provider: 'openai' | 'anthropic' | ...;
  tokens: {
    inputTokens: number;
    outputTokens: number;
    totalTokens: number;
    confidence: number;
  };
  estimatedCostUsd: number;
  costRange: { min: number; max: number };
  exceedsBudget: boolean;
  budgetWarnings: string[];
}
```

#### `estimateWorkflow(options)` — Full Workflow Estimate

```typescript
const workflow = cost.estimateWorkflow({
  intent: 'Add user authentication with Google OAuth',
  tier: 'T2',
});

// Returns array of stage estimates plus totals
{
  stages: CostEstimate[];
  totalEstimatedCost: number;
  totalCostRange: { min: number; max: number };
}
```

#### `checkBudget(estimatedCost)` — Budget Check

```typescript
const check = cost.checkBudget(0.50);

// Returns
{
  allowed: boolean;      // Whether operation should proceed
  reason?: string;       // Reason if not allowed
  status: BudgetStatus;  // Current budget status
}
```

#### `recordUsage(params)` — Record Actual Usage

```typescript
const record = cost.recordUsage({
  model: 'gpt-4o',
  inputTokens: 5200,
  outputTokens: 3800,
  workflowType: 'code-from-plan',
  tier: 'T2',
  taskId: 'task-123',           // Optional
  estimateId: estimate.estimateId,  // Optional, for comparison
  durationMs: 12500,
  success: true,
  error: undefined,
});
```

#### `getBudgetStatus(period)` — Get Budget Status

```typescript
const status = cost.getBudgetStatus('monthly');

// Returns BudgetStatus
{
  period: 'monthly';
  periodStart: string;
  periodEnd: string;
  limitUsd: number;
  spentUsd: number;
  remainingUsd: number;
  usedPercent: number;
  status: 'healthy' | 'warning' | 'critical' | 'exceeded';
  projectedSpendUsd: number;
  projectedOverBudget: boolean;
  topModels: Array<{ model: string; spentUsd: number; percent: number }>;
  topWorkflows: Array<{ workflowType: string; spentUsd: number; percent: number }>;
}
```

#### `selectModel(tier, stage)` — Get Appropriate Model

```typescript
const model = cost.selectModel('T2', 'final');
// Returns: 'gpt-4o'
```

### Utility Functions

```typescript
import {
  getModelPricing,
  calculateCost,
  compareModelCosts,
  getTierModels,
  getCheapestModel,
} from '@harmony/costkit';

// Get pricing for a model
const pricing = getModelPricing('gpt-4o');

// Calculate cost for token usage
const costVal = calculateCost('gpt-4o', 5000, 3000);

// Compare two models
const comparison = compareModelCosts('gpt-4o', 'gpt-4o-mini', 5000, 3000);

// Get models for a tier
const models = getTierModels('T2', 'draft');

// Find cheapest model meeting requirements
const cheapest = getCheapestModel({
  minContextWindow: 100000,
  excludeDeprecated: true,
});
```

## Tier-Based Model Selection

| Tier | Stage | Default Model | Allowed Models | Max Cost |
|------|-------|---------------|----------------|----------|
| T1 | - | gpt-4o-mini | gpt-4o-mini, claude-haiku, gemini-2.0-flash | $0.01 |
| T2 | draft | gpt-4o-mini | gpt-4o-mini, claude-haiku | $0.05 |
| T2 | final | gpt-4o | gpt-4o, claude-sonnet | $0.20 |
| T3 | - | gpt-4o | gpt-4o, claude-opus, o1 | $1.00 |

## Workflow Token Estimates

Default token estimates by workflow type:

| Workflow | Avg Input | Avg Output | Variance |
|----------|-----------|------------|----------|
| spec-from-intent | 2,000 | 3,000 | 30% |
| plan-from-spec | 4,000 | 2,500 | 25% |
| code-from-plan | 5,000 | 4,000 | 40% |
| test-from-contract | 3,000 | 3,500 | 30% |
| threat-model-from-spec | 3,500 | 4,000 | 25% |

Tier multipliers:
- T1: 0.6x (simpler tasks)
- T2: 1.0x (normal)
- T3: 1.5x (more context/detail)

## Alert Types

| Type | Severity | Trigger |
|------|----------|---------|
| `budget_warning` | warning | Budget at warning threshold (default 70%) |
| `budget_critical` | critical | Budget at critical threshold (default 90%) |
| `budget_exceeded` | critical | Budget exceeded |
| `unusual_spend` | warning | Spending 3x+ normal rate |
| `model_deprecated` | warning | Using deprecated model |
| `estimate_exceeded` | info | Actual cost 50%+ over estimate |

## Configuration

See `packages/config/cost-policy.yaml` for the full policy schema.

Key configuration options:

```yaml
budgets:
  monthly:
    limit_usd: 500.00
    warning_threshold_percent: 70
    critical_threshold_percent: 90
    block_on_exceed: false

tier_models:
  T1:
    default_model: gpt-4o-mini
    max_cost_per_operation: 0.01
  T2_final:
    default_model: gpt-4o
    max_cost_per_operation: 0.20

alerts:
  enabled: true
  dedupe_window_minutes: 60
```

## Agent Integration Patterns

### Before Expensive Operations

```typescript
// Always estimate before T2 final or T3 operations
const estimate = cost.estimate({
  workflowType: 'code-from-plan',
  tier: task.tier,
  stage: 'final',
});

// Check budget
const budgetCheck = cost.checkBudget(estimate.estimatedCostUsd);
if (!budgetCheck.allowed) {
  // Handle budget exceeded - notify human, use cheaper model, etc.
  throw new Error(`Budget exceeded: ${budgetCheck.reason}`);
}

// Proceed with operation...
```

### Recording Usage

```typescript
// After LLM call completes
cost.recordUsage({
  model: response.model,
  inputTokens: response.usage.prompt_tokens,
  outputTokens: response.usage.completion_tokens,
  workflowType: currentWorkflow,
  tier: task.tier,
  taskId: task.id,
  estimateId: preFlightEstimate?.estimateId,
  durationMs: Date.now() - startTime,
  success: !response.error,
  error: response.error?.message,
});
```

### Model Selection

```typescript
// Let Cost select the appropriate model
const model = cost.selectModel(task.tier, stage);

// Use in LLM call
const response = await llm.chat({
  model,
  messages: [...],
});
```

## Observability

Cost integrates with Observe for metrics:

- `costkit.estimate.created` - Pre-flight estimate generated
- `costkit.usage.recorded` - Usage recorded
- `costkit.budget.check` - Budget check performed
- `costkit.alert.created` - Alert generated

Span attributes include:
- `cost.estimated_usd`
- `cost.actual_usd`
- `cost.model`
- `cost.tokens.input`
- `cost.tokens.output`
- `cost.tier`
- `cost.workflow_type`

## File Locations

- **Implementation**: `packages/kits/costkit/src/`
- **Policy**: `packages/config/cost-policy.yaml`
- **Data Storage**: `.harmony/cost-data.json` (default)

## Related Documentation

- [Model Selection Rules](../../planning-and-orchestration/README.md)
- [Budget Policy](../../../../../config/cost-policy.yaml)
- [Observe Integration](../../observability-and-ops/observakit/guide.md)

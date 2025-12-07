# CostKit - LLM Cost Management

CostKit provides comprehensive cost management for AI-enabled workflows, including pre-flight estimation, real-time tracking, budget management, and alerting.

## Features

- **Pre-flight Cost Estimation**: Get accurate cost estimates before running expensive LLM operations
- **Real-time Tracking**: Track actual costs as operations complete
- **Budget Management**: Set and enforce budgets at daily, weekly, and monthly levels
- **Tier-based Model Selection**: Automatically select cost-appropriate models based on risk tier
- **Alerting**: Receive alerts when budgets are exceeded or unusual spending is detected
- **Optimization Suggestions**: Get recommendations for reducing costs

## Quick Start

```typescript
import { CostKit } from '@harmony/kits';

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
// 📊 Cost Estimate
// ─────────────────────────────
// Workflow: code-from-plan
// Tier: T2 (final)
// Model: gpt-4o (openai)
// 
// Tokens:
//   Input:  ~5,000
//   Output: ~4,000
//   Total:  ~9,000
// 
// Estimated Cost: $0.0625
// Range: $0.0438 - $0.0813
// Confidence: 60%

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

// Check budget status
const status = costKit.getBudgetStatus();
console.log(costKit.formatBudgetStatus(status));
```

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
const model = costKit.selectModel('T2', 'final');
// Returns: 'gpt-4o'

// Get all allowed models for a tier
const models = costKit.getTierModels('T1');
// Returns: ['gpt-4o-mini', 'claude-haiku', 'gemini-2.0-flash']
```

## Pre-flight Estimation

Get cost estimates before running operations:

```typescript
// Single operation estimate
const estimate = costKit.estimate({
  workflowType: 'spec-from-intent',
  tier: 'T2',
  inputText: 'Add user authentication with Google OAuth...', // optional, improves accuracy
});

// Full workflow estimate (all stages)
const workflow = costKit.estimateWorkflow({
  intent: 'Add user authentication with Google OAuth',
  tier: 'T2',
});

console.log(costKit.formatWorkflowEstimates(workflow));
// 📊 Workflow Cost Estimate
// ══════════════════════════════════════
// 
// spec-from-intent: $0.0045 [gpt-4o-mini]
// plan-from-spec: $0.0038 [gpt-4o-mini]
// code-from-plan (draft): $0.0042 [gpt-4o-mini]
// code-from-plan (final): $0.0625 [gpt-4o]
// test-from-contract: $0.0035 [gpt-4o-mini]
// threat-model-from-spec: $0.0050 [gpt-4o-mini]
// 
// ──────────────────────────────────────
// Total Estimated: $0.0835
// Range: $0.0584 - $0.1086
```

## Budget Management

Set and track budgets:

```typescript
// Get current budget status
const status = costKit.getBudgetStatus('monthly');

console.log(`Status: ${status.status}`);        // 'healthy', 'warning', 'critical', 'exceeded'
console.log(`Spent: $${status.spentUsd.toFixed(2)}`);
console.log(`Remaining: $${status.remainingUsd.toFixed(2)}`);
console.log(`Used: ${status.usedPercent.toFixed(1)}%`);

// Check if an operation would exceed budget
const check = costKit.checkBudget(0.50);
if (!check.allowed) {
  console.log('Blocked:', check.reason);
}
```

## Cost Tracking and Reporting

Track costs and generate reports:

```typescript
// Get cost summary
const summary = costKit.getCostSummary('monthly');

console.log(costKit.formatCostSummary(summary));
// 📊 Cost Summary
// ══════════════════════════════════════
// Period: 2025-01-01 to 2025-01-31
// 
// Total Spent: $127.50
// Operations:  1,234
// Avg Cost:    $0.1033/op
// Success:     98.5%
// 
// Tokens Used:
//   Input:  2,500,000
//   Output: 1,800,000
//   Total:  4,300,000
// 
// Trend: 📈 +15.2% vs previous period
// 
// 💡 Optimization Opportunities:
//   • Using expensive model (gpt-4o) for T1 task
//     Potential savings: $12.50
//     → Use gpt-4o-mini for trivial tasks

// Get usage breakdown
console.log('By Model:', summary.byModel);
console.log('By Workflow:', summary.byWorkflow);
console.log('By Tier:', summary.byTier);
```

## Alerting

CostKit automatically generates alerts:

```typescript
// Get unacknowledged alerts
const alerts = costKit.getUnacknowledgedAlerts();

console.log(costKit.formatAlerts(alerts));
// 🔔 Alerts (2)
// ══════════════════════════════════════
// 
// ⚠️ Budget warning: 75.0% of monthly budget used
// ─────────────────────────────
// $375.00 remaining of $500.00 monthly budget.
// 
// Type: budget_warning
// Time: 1/15/2025, 10:30:00 AM
// 
// ⚠️ Deprecated model in use: gpt-4
// ─────────────────────────────
// Model "gpt-4" is deprecated. Consider migrating to "gpt-4o".

// Acknowledge an alert
costKit.acknowledgeAlert(alerts[0].alertId, 'developer@team.com');
```

## Model Pricing

Get pricing information for models:

```typescript
import { getModelPricing, calculateCost, compareModelCosts } from '@harmony/kits/costkit';

// Get pricing for a model
const pricing = getModelPricing('gpt-4o');
console.log(`Input: $${pricing.inputPricePer1M}/1M tokens`);
console.log(`Output: $${pricing.outputPricePer1M}/1M tokens`);

// Calculate cost for token usage
const cost = calculateCost('gpt-4o', 5000, 3000);
console.log(`Cost: $${cost.toFixed(4)}`);

// Compare two models
const comparison = compareModelCosts('gpt-4o', 'gpt-4o-mini', 5000, 3000);
console.log(`Cheaper: ${comparison.cheaperModel}`);
console.log(`Savings: $${comparison.savingsUsd.toFixed(4)} (${comparison.savingsPercent.toFixed(1)}%)`);
```

## Configuration

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

## API Reference

### CostKit Class

| Method | Description |
|--------|-------------|
| `estimate(options)` | Get pre-flight cost estimate |
| `estimateWorkflow(options)` | Estimate full workflow cost |
| `checkBudget(cost)` | Check if cost is within budget |
| `recordUsage(params)` | Record actual usage |
| `getBudgetStatus(period)` | Get current budget status |
| `getCostSummary(period)` | Get cost summary/report |
| `getAlerts()` | Get all alerts |
| `acknowledgeAlert(id)` | Acknowledge an alert |
| `selectModel(tier, stage)` | Get appropriate model for tier |

### Utility Functions

| Function | Description |
|----------|-------------|
| `getModelPricing(model)` | Get pricing for a model |
| `calculateCost(model, input, output)` | Calculate cost for tokens |
| `compareModelCosts(a, b, input, output)` | Compare two models |
| `getTierModels(tier, stage)` | Get models for a tier |
| `getCheapestModel(options)` | Find cheapest model meeting requirements |

## Integration with Harmony CLI

CostKit is integrated into the Harmony CLI:

```bash
# Check current budget status
harmony cost status

# Get estimate before running a workflow
harmony cost estimate feature "Add user authentication"

# Show recent spending
harmony cost summary

# List alerts
harmony cost alerts

# Acknowledge an alert
harmony cost ack <alert-id>
```

## Best Practices

1. **Always estimate before expensive operations**: Use `estimate()` or `estimateWorkflow()` before running T2 final or T3 operations.

2. **Respect tier model limits**: Let CostKit select models based on tier - don't manually override unless necessary.

3. **Monitor weekly**: Check the cost summary weekly to catch trends early.

4. **Acknowledge alerts promptly**: Review and acknowledge alerts to maintain a clean alert state.

5. **Update pricing periodically**: Model pricing changes - update `pricing.ts` when providers announce changes.

## Supported Models

### OpenAI
- gpt-4o, gpt-4o-mini, o1, o1-mini, o3-mini

### Anthropic
- claude-3-5-sonnet, claude-3-5-haiku, claude-3-opus

### Google
- gemini-2.0-flash, gemini-1.5-pro, gemini-1.5-flash

### Mistral
- mistral-large, mistral-small, codestral

See `pricing.ts` for current pricing data.


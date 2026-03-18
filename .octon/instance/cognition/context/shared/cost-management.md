# Cost Management

This guide explains how AI costs are managed in Octon. **You don't need to do much** — the system handles cost optimization automatically. This page tells you what you need to know.

## How AI Costs Work

Every time AI runs a workflow (spec, plan, code, test), it uses tokens and incurs a cost. Costs vary by:
- **Model**: GPT-4o costs more than GPT-4o-mini
- **Task complexity**: Bigger tasks use more tokens
- **Risk tier**: Higher tiers use better (more expensive) models

## What You Need to Know

### 1. Budgets Are Set

Your team has budgets (usually monthly). AI automatically:
- Tracks spending against the budget
- Uses cheaper models when appropriate
- Alerts when approaching limits

### 2. Model Selection Is Automatic

| Tier | AI Uses | Why |
|------|---------|-----|
| T1 (trivial) | Cheap models (gpt-4o-mini) | Bug fixes don't need expensive models |
| T2 draft | Cheap models | Iterate fast on first pass |
| T2 final | Quality models (gpt-4o) | Merge-ready code needs quality |
| T3 (high-risk) | Best models | Security/auth can't cut corners |

You don't choose models — the tier determines the model.

### 3. Cost Estimates Before Workflows

Before running expensive operations, you'll see an estimate:

```
📊 Workflow Cost Estimate
══════════════════════════════════════

spec-from-intent: $0.0045 [gpt-4o-mini]
plan-from-spec: $0.0038 [gpt-4o-mini]
code-from-plan: $0.0625 [gpt-4o]
test-from-contract: $0.0035 [gpt-4o-mini]

──────────────────────────────────────
Total Estimated: $0.0743
Range: $0.0520 - $0.0966
```

If the estimate seems high, you can:
- Split the task into smaller pieces
- Check if the tier is appropriate
- Proceed anyway if it's necessary

### 4. You'll See Alerts

When budget thresholds are crossed:

```
⚠️ Budget warning: 75.0% of monthly budget used
   $125.00 remaining of $500.00 monthly budget.
```

**What to do:**
- **Warning (70-90%)**: Be mindful, but continue working
- **Critical (90%+)**: Prioritize important work, defer experiments
- **Exceeded**: Contact team lead; may need budget adjustment

## Commands

```bash
# Check current budget and spending
octon cost status

# See estimate before a feature
octon cost estimate "Add user authentication"

# View spending summary
octon cost summary

# List alerts
octon cost alerts
```

## Quick Reference

### Typical Costs

| Operation | Typical Cost |
|-----------|--------------|
| T1 bug fix (full workflow) | $0.01 - $0.03 |
| T2 feature (full workflow) | $0.05 - $0.15 |
| T3 security feature | $0.20 - $0.50 |

### Budget Defaults

| Period | Default Limit | Warning | Critical |
|--------|---------------|---------|----------|
| Monthly | $500 | 70% | 90% |
| Weekly | $150 | 70% | 90% |

### When to Pay Attention

✅ **Normal - no action needed:**
- Status shows "healthy"
- Estimates are under $0.20 for standard work
- Weekly usage is steady

⚠️ **Review recommended:**
- Status shows "warning"
- Estimate is unusually high
- Seeing "unusual spending" alerts

🚨 **Action needed:**
- Status shows "critical" or "exceeded"
- Can't complete high-priority work
- Repeated budget alerts

## FAQ

### Q: What if I exceed the budget?

By default, work can continue but you'll get alerts. The budget is a guideline, not a hard stop. If you're regularly exceeding, talk to your team about adjusting the budget.

### Q: How accurate are estimates?

Estimates are usually within ±30% of actual costs. They're based on historical patterns and task complexity.

### Q: Can I use a cheaper model for T2/T3?

No — tier determines model selection for quality reasons. If you think a task is miscategorized, adjust the tier instead.

### Q: Where does cost data go?

Stored locally in `.octon/cost-data.json`. Costs are not sent anywhere external.

### Q: How often is pricing updated?

Model pricing in the system is updated when providers announce changes. Check the pricing data in the kit if you suspect it's outdated.

## Related

- [Risk Tiers](./risk-tiers.md) — How tiers affect model selection
- [AI Guardrails](../../governance/principles/guardrails.md) — How AI operations are controlled


# Cost Examples

## Estimate

```bash
echo '{"operation":"estimate","workflowType":"code-from-plan","tier":"T2","model":"gpt-4o-mini","inputTokens":5000,"outputTokens":4000}' | ./impl/cost.sh
```

## Record Usage

```bash
echo '{"operation":"record","model":"gpt-4o-mini","inputTokens":5100,"outputTokens":4200,"workflowType":"code-from-plan","tier":"T2","durationMs":12000,"success":true}' | ./impl/cost.sh
```

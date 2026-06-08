# Token Budget Policy

## Accounting Scope

Every lifecycle run must account for lifecycle-level tokens, parent-level tokens, child-level tokens, stage-level tokens, source-level tokens, model-level tokens, prompt tokens, context tokens, completion tokens, tool output tokens, repeated context, prompt boilerplate, output bloat, generated-state rereads, raw-log rereads, and high-reasoning calls.

## Initial Budgets

| Route / Stage | Target Model-Visible Budget |
|---|---:|
| parent start / child registry parse | 4k-8k |
| final parent completion | 3k-8k |
| no-dispatch completion pass | 2k-6k |
| child dispatch base context | 8k-12k |
| implementation planning child | 15k-30k |
| architecture gap map | 25k-40k |
| verification pass with no failures | 2k-8k |
| verification failure classification | 8k-15k |
| recovery with blockers | 8k-20k |
| closeout projection | 4k-10k |
| expanded audit report | on demand only |

## Regression Thresholds

CI should warn or fail when repeated-source percentage increases by more than 10% over baseline, prompt boilerplate exceeds 25% of model-visible context in minimal rollout or 15% in mature rollout, raw log model-visible bytes exceed zero without escalation receipt, generated tree model-visible bytes exceed zero without escalation receipt, full prompt asset expansion occurs without prompt-expansion-policy trigger, or high-reasoning route lacks routing receipt.

## Measurement Method

When provider usage is unavailable, estimate tokens as bytes/4 and mark estimates as approximate. When provider usage is available, retain provider counters and source-attribution estimates side by side.

## Evidence

`token-budget-ledger.json` is retained evidence. It does not authorize execution but it supports lifecycle review, token regression detection, replay analysis, and governance audit.

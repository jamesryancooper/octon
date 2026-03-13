# Cost Invariants

1. `estimate` output includes `estimateId`, token counts, and a numeric `estimatedCostUsd`.
2. `record` output includes `usageId`, token counts, and a numeric `actualCostUsd`.
3. `record` appends durable usage data to `operations/_ops/state/runs/cost-usage.jsonl`.
4. Cost calculations are deterministic for equal model + token inputs.
5. Budget policy checks remain non-fail-closed (`fail_closed=false`) by design.

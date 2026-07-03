# Acceptance Criteria

- No-op effective publication produces zero tracked diffs.
- Changed publication input updates only required generated/effective outputs.
- Lock, receipt, freshness, and resolver validation still pass for valid outputs.
- Negative controls still fail closed for stale, missing, or digest-drifted outputs.
- Runtime consumers still use freshness-checked handles only.

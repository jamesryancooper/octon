# Examples

## Default Audit

```text
/audit-ci-latency
```

Use when the weekly latency issue opens and you want a fresh local read of the same signals.

## Wider Window

```text
/audit-ci-latency window_runs="60" top_workflows="8" gate_scope="all"
```

Use when the weekly report shows unstable trends and you need a broader sample.

## Expected Recommendation Style

- Consolidate duplicated Rust setup between two workflow families.
- Tighten `paths-filter` scope for a slow validation workflow.
- Move a report-only step out of a required path when evidence shows no gate value.

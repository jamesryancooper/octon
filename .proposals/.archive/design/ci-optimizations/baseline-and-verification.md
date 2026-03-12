# Baseline and Verification Procedure

## 1) Baseline capture (before any workflow edits)

Run:

```bash
bash .proposals/ci-optimizations/scripts/collect-actions-baseline.sh --days 30
```

Outputs (timestamped directory under `.proposals/ci-optimizations/baseline/`):

- `runs.json`: raw workflow runs from GitHub API.
- `runs.ndjson`: flattened per-run records.
- `workflow-summary.csv`: workflow-level cost/performance metrics.
- `event-summary.csv`: event-level run counts and duration totals.
- `summary.md`: quick human-readable snapshot.

Primary metrics to track:

- run count per workflow
- median duration per workflow
- failure rate
- cancelled rate
- billed-minutes proxy (sum of rounded-up run minutes)
- event distribution (`pull_request`, `pull_request_target`, `push`, `schedule`, `workflow_dispatch`)

## 2) Implementation verification (immediately after merge)

- Confirm required checks still appear on PRs and report terminal status.
- Confirm no required-check context is left in perpetual pending/waiting state.
- Confirm AI Gate decision job reports on:
  - risky code changes
  - docs-only changes
  - label-only changes
- Confirm Codex review runs only when:
  - risky path changes exist, or
  - explicit `codex:review` label is present.

## 3) 1-week check

Capture 7-day post-change dataset:

```bash
bash .proposals/ci-optimizations/scripts/collect-actions-baseline.sh --days 7
```

Compare vs baseline:

```bash
bash .proposals/ci-optimizations/scripts/compare-actions-baseline.sh \
  .proposals/ci-optimizations/baseline/<before_timestamp> \
  .proposals/ci-optimizations/baseline/<after_7d_timestamp>
```

## 4) 30-day check

Capture 30-day post-change dataset and compare with original baseline:

```bash
bash .proposals/ci-optimizations/scripts/collect-actions-baseline.sh --days 30
bash .proposals/ci-optimizations/scripts/compare-actions-baseline.sh \
  .proposals/ci-optimizations/baseline/<before_timestamp> \
  .proposals/ci-optimizations/baseline/<after_30d_timestamp>
```

## 5) Acceptance thresholds

- Actions minute reduction: `>= 80%`
- Required check latency regression: `<= 10%`
- Merge-blocking flake increase: `0` material regressions
- Required governance checks: unchanged in branch protection behavior

## 6) Known measurement limitation

GitHub run metadata does not always expose PR action subtypes (`synchronize`, `labeled`, `unlabeled`) directly at run granularity. This package reports exact event-level metrics and should be complemented with PR event telemetry when subtype attribution is required.


---
name: "evaluate-ci-latency"
description: "Evaluate recent GitHub Actions latency, identify breached thresholds and step hotspots, and publish report-only tightening recommendations."
steps:
  - id: "collect-latency-evidence"
    file: "stages/01-collect-latency-evidence.md"
    description: "collect-latency-evidence"
  - id: "classify-breaches-and-hotspots"
    file: "stages/02-classify-breaches-and-hotspots.md"
    description: "classify-breaches-and-hotspots"
  - id: "publish-tightening-report"
    file: "stages/03-publish-tightening-report.md"
    description: "publish-tightening-report"
---

# Evaluate Ci Latency

_Generated README from canonical workflow `evaluate-ci-latency`._

## Usage

```text
/evaluate-ci-latency
```

## Purpose

Evaluate recent GitHub Actions latency, identify breached thresholds and step hotspots, and publish report-only tightening recommendations.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/meta/evaluate-ci-latency`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/meta/evaluate-ci-latency/workflow.yml`.
- External runtime dependencies required by the target project are available.

## Parameters

- `window_runs` (text, required=false), default=`40`: Number of recent successful PR runs used for latency analysis.
- `top_workflows` (text, required=false), default=`5`: Number of slow or regressed workflows to inspect for hotspot detail.
- `gate_scope` (text, required=false), default=`required`: Latency scope emphasized in the report: required or all.
- `policy_path` (file, required=false), default=`.octon/framework/execution-roles/practices/standards/ci-latency-policy.json`: Policy contract defining thresholds, window sizes, and issue semantics.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [collect-latency-evidence](./stages/01-collect-latency-evidence.md)
2. [classify-breaches-and-hotspots](./stages/02-classify-breaches-and-hotspots.md)
3. [publish-tightening-report](./stages/03-publish-tightening-report.md)

## Verification Gate

- [ ] verification stage passes

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/meta/evaluate-ci-latency/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/meta/evaluate-ci-latency/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 0.1.0 | Generated from canonical workflow `evaluate-ci-latency` |

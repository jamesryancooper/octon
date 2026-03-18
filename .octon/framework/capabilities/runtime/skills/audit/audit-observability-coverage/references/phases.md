---
behavior:
  phases:
    - name: "Configure"
      steps:
        - "Parse scope, observability contract reference, artifact globs, and convergence controls"
        - "Normalize severity threshold and finding taxonomy"
        - "Enumerate service manifests, SLO artifacts, alert artifacts, and runbook/dashboard artifacts"
        - "Build deterministic scope inventory for coverage accounting"
    - name: "Signal Contract Coverage"
      isolation: true
      steps:
        - "Inspect in-scope service manifests and contract docs for telemetry declarations"
        - "Verify expected signal intent is defined (traces/logs/metrics expectations)"
        - "Verify ownership or escalation metadata is present where required"
        - "Record signal coverage findings and clean coverage proof"
    - name: "SLO and Alert Coverage"
      isolation: true
      steps:
        - "Inspect SLO artifacts for measurable objectives and budget semantics"
        - "Inspect alert artifacts for actionable policy mappings"
        - "Check whether critical objectives have matching alerting evidence"
        - "Record coverage gaps with explicit acceptance criteria"
    - name: "Runbook and Dashboard Coverage"
      isolation: true
      steps:
        - "Inspect runbook artifacts for operational response guidance"
        - "Inspect dashboard references for visibility linkage"
        - "Check alertable surfaces for runbook/dashboard references"
        - "Record operational readiness findings and clean coverage proof"
    - name: "Self-Challenge"
      steps:
        - "Re-check evidence sufficiency for each non-trivial finding"
        - "Attempt to disprove high-severity findings and downgrade if unsupported"
        - "Search for blind spots in scope selection and artifact discovery"
        - "Record unknowns where compliance cannot be evidenced"
    - name: "Report"
      steps:
        - "Generate findings report with layer breakdown and severity distribution"
        - "Emit stable finding IDs and acceptance criteria in bounded bundle mode"
        - "Emit coverage ledger, convergence receipt, and done-gate metadata"
        - "Write report and run log to designated output paths"
  goals:
    - "Evidence-backed observability coverage map for in-scope surfaces"
    - "Deterministic detection of telemetry, SLO, alert, runbook, and dashboard gaps"
    - "Actionable remediation guidance with stable finding identity"
    - "Convergence-ready outputs for pre-release and post-remediation gates"
---

# Behavior Phases

This skill runs a six-phase observability coverage loop. Each mandatory layer
must complete before the next to keep findings attributable and reproducible.

## Layer Intent

- `Signal Contract Coverage` verifies telemetry contract intent exists for each service surface.
- `SLO and Alert Coverage` verifies measurable objectives and alerting readiness.
- `Runbook and Dashboard Coverage` verifies operator actionability and diagnostic visibility.

## Severity Heuristic

- `CRITICAL` -- Missing observability controls on critical paths likely to hide active failures
- `HIGH` -- Significant coverage gap that materially degrades incident response
- `MEDIUM` -- Partial/inconsistent coverage reducing diagnosability or ownership clarity
- `LOW` -- Minor clarity or consistency issues with limited operational impact

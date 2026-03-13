---
behavior:
  phases:
    - name: "Configure"
      steps:
        - "Parse scope, baseline references, artifact globs, and convergence controls"
        - "Normalize severity threshold and finding taxonomy"
        - "Enumerate release policy, deployment/rollback, operations, and evidence artifacts"
        - "Build deterministic scope inventory for coverage accounting"
    - name: "Release Criteria and Change-Control Coverage"
      isolation: true
      steps:
        - "Inspect release baseline and quality-gate policy artifacts"
        - "Inspect change-control, approval, and launch-criteria artifacts"
        - "Check alignment between declared criteria and in-scope release surfaces"
        - "Record coverage findings and clean coverage proof"
    - name: "Deployment and Rollback Safeguards"
      isolation: true
      steps:
        - "Inspect deployment automation and compatibility safeguards"
        - "Inspect rollback and contingency artifacts"
        - "Check whether critical paths have executable rollback posture"
        - "Record safeguard gaps with explicit acceptance criteria"
    - name: "Operational Response and Gate Evidence"
      isolation: true
      steps:
        - "Inspect operations baseline, incident, and runbook artifacts"
        - "Inspect release evidence and gate receipts"
        - "Check traceability from release decision points to evidence"
        - "Record readiness findings and clean coverage proof"
    - name: "Self-Challenge"
      steps:
        - "Re-check evidence sufficiency for each non-trivial finding"
        - "Attempt to disprove high-severity findings and downgrade if unsupported"
        - "Search for blind spots in scope selection and artifact discovery"
        - "Record unknowns where readiness claims cannot be evidenced"
    - name: "Report"
      steps:
        - "Generate findings report with layer breakdown and severity distribution"
        - "Emit stable finding IDs and acceptance criteria in bounded bundle mode"
        - "Emit coverage ledger, convergence receipt, and done-gate metadata"
        - "Write report and run log to designated output paths"
  goals:
    - "Evidence-backed release-readiness coverage map for in-scope surfaces"
    - "Deterministic detection of policy, safeguard, and operational readiness gaps"
    - "Actionable remediation guidance with stable finding identity"
    - "Convergence-ready outputs for pre-release and post-remediation gates"
---

# Behavior Phases

This skill runs a six-phase release-readiness coverage loop. Each mandatory layer
must complete before the next to keep findings attributable and reproducible.

## Layer Intent

- `Release Criteria and Change-Control Coverage` verifies declared release criteria match in-scope launch surfaces.
- `Deployment and Rollback Safeguards` verifies deployment controls and rollback posture for critical paths.
- `Operational Response and Gate Evidence` verifies incident readiness and evidence traceability for release decisions.

## Severity Heuristic

- `CRITICAL` -- Missing release controls likely to cause severe production impact without recovery confidence
- `HIGH` -- Significant readiness gap that materially weakens launch confidence
- `MEDIUM` -- Partial/inconsistent readiness artifacts that reduce traceability and assurance
- `LOW` -- Minor clarity or consistency issues with limited risk impact

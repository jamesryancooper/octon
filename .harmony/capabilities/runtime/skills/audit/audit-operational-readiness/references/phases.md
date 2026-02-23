---
behavior:
  phases:
    - name: "Configure"
      steps:
        - "Parse scope, baseline references, artifact globs, and convergence controls"
        - "Normalize severity threshold and finding taxonomy"
        - "Enumerate ownership/objective, runbook/incident, resilience/capacity, and evidence artifacts"
        - "Build deterministic scope inventory for coverage accounting"
    - name: "Operational Ownership and Reliability Objectives"
      isolation: true
      steps:
        - "Inspect operations baseline and service ownership artifacts"
        - "Inspect reliability objective artifacts such as SLO or service-level commitments"
        - "Check whether critical surfaces have clear ownership and objective coverage"
        - "Record coverage findings and clean coverage proof"
    - name: "Runbook and Incident Response Preparedness"
      isolation: true
      steps:
        - "Inspect runbook and escalation artifacts for critical workflows"
        - "Inspect incident-response and on-call readiness artifacts"
        - "Check operational response completeness, currency, and actionability"
        - "Record preparedness gaps with explicit acceptance criteria"
    - name: "Resilience, Capacity, and Evidence Readiness"
      isolation: true
      steps:
        - "Inspect resilience and capacity planning artifacts"
        - "Inspect operational evidence and run receipts"
        - "Check whether critical paths have evidence-backed resilience readiness"
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
    - "Evidence-backed operational-readiness coverage map for in-scope services"
    - "Deterministic detection of ownership, response, and resilience gaps"
    - "Actionable remediation guidance with stable finding identity"
    - "Convergence-ready outputs for pre-release and post-remediation gates"
---

# Behavior Phases

This skill runs a six-phase operational-readiness coverage loop. Each mandatory layer
must complete before the next to keep findings attributable and reproducible.

## Layer Intent

- `Operational Ownership and Reliability Objectives` verifies ownership, accountability, and reliability-target coverage.
- `Runbook and Incident Response Preparedness` verifies operators can detect, escalate, and respond with actionable procedures.
- `Resilience, Capacity, and Evidence Readiness` verifies sustained operation posture and auditable readiness evidence.

## Severity Heuristic

- `CRITICAL` -- Missing operational controls likely to cause severe outage impact on critical paths
- `HIGH` -- Significant readiness gap that materially weakens service operability confidence
- `MEDIUM` -- Partial/inconsistent operational artifacts that reduce traceability and assurance
- `LOW` -- Minor clarity or consistency issues with limited risk impact

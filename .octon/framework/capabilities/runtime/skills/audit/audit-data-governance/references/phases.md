---
behavior:
  phases:
    - name: "Configure"
      steps:
        - "Parse scope, baseline references, artifact globs, and convergence controls"
        - "Normalize severity threshold and finding taxonomy"
        - "Enumerate classification/retention, lineage/contract, privacy, and evidence artifacts"
        - "Build deterministic scope inventory for coverage accounting"
    - name: "Classification and Retention Coverage"
      isolation: true
      steps:
        - "Inspect classification baseline and handling policy artifacts"
        - "Inspect retention and deletion policy artifacts"
        - "Check alignment between classification tiers and retention controls"
        - "Record coverage findings and clean coverage proof"
    - name: "Lineage and Contract Traceability"
      isolation: true
      steps:
        - "Inspect lineage and provenance artifacts"
        - "Inspect data-contract and interface metadata artifacts"
        - "Check traceability links between data surfaces and contracts"
        - "Record traceability gaps with explicit acceptance criteria"
    - name: "Privacy Safeguards and Evidence Readiness"
      isolation: true
      steps:
        - "Inspect privacy safeguard artifacts and sensitive-data controls"
        - "Inspect governance evidence and run-receipt artifacts"
        - "Check whether in-scope critical paths have sufficient governance evidence"
        - "Record readiness findings and clean coverage proof"
    - name: "Self-Challenge"
      steps:
        - "Re-check evidence sufficiency for each non-trivial finding"
        - "Attempt to disprove high-severity findings and downgrade if unsupported"
        - "Search for blind spots in scope selection and artifact discovery"
        - "Record unknowns where governance claims cannot be evidenced"
    - name: "Report"
      steps:
        - "Generate findings report with layer breakdown and severity distribution"
        - "Emit stable finding IDs and acceptance criteria in bounded bundle mode"
        - "Emit coverage ledger, convergence receipt, and done-gate metadata"
        - "Write report and run log to designated output paths"
  goals:
    - "Evidence-backed data-governance coverage map for in-scope surfaces"
    - "Deterministic detection of classification, retention, lineage, privacy, and evidence gaps"
    - "Actionable remediation guidance with stable finding identity"
    - "Convergence-ready outputs for pre-release and post-remediation gates"
---

# Behavior Phases

This skill runs a six-phase data-governance coverage loop. Each mandatory layer
must complete before the next to keep findings attributable and reproducible.

## Layer Intent

- `Classification and Retention Coverage` verifies policy tiers align with retention and deletion controls.
- `Lineage and Contract Traceability` verifies provenance and contract linkage.
- `Privacy Safeguards and Evidence Readiness` verifies sensitive-data safeguards and governance receipts.

## Severity Heuristic

- `CRITICAL` -- Missing governance controls likely to breach sensitive-data policy or retention obligations
- `HIGH` -- Significant governance coverage gap that materially weakens compliance readiness
- `MEDIUM` -- Partial/inconsistent governance artifacts that reduce traceability and assurance
- `LOW` -- Minor clarity or consistency issues with limited risk impact

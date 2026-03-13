---
behavior:
  phases:
    - name: "Configure"
      steps:
        - "Parse scope, baseline references, artifact globs, and convergence controls"
        - "Normalize severity threshold and finding taxonomy"
        - "Enumerate contract/spec, implementation, compatibility/versioning, and evidence artifacts"
        - "Build deterministic scope inventory for coverage accounting"
    - name: "Contract Definition and Specification Coverage"
      isolation: true
      steps:
        - "Inspect contract baselines and API-design policy artifacts"
        - "Inspect OpenAPI/schema/contract artifacts"
        - "Check alignment between interface surfaces and contract specifications"
        - "Record coverage findings and clean coverage proof"
    - name: "Implementation and Compatibility Conformance"
      isolation: true
      steps:
        - "Inspect implementation artifacts mapped to declared contracts"
        - "Inspect compatibility and invariants artifacts"
        - "Check conformance and backward/forward compatibility posture"
        - "Record conformance gaps with explicit acceptance criteria"
    - name: "Versioning, Deprecation, and Evidence Readiness"
      isolation: true
      steps:
        - "Inspect versioning and deprecation strategy artifacts"
        - "Inspect run evidence and interface gate receipts"
        - "Check whether critical interfaces have sufficient evidence-backed readiness"
        - "Record readiness findings and clean coverage proof"
    - name: "Self-Challenge"
      steps:
        - "Re-check evidence sufficiency for each non-trivial finding"
        - "Attempt to disprove high-severity findings and downgrade if unsupported"
        - "Search for blind spots in scope selection and artifact discovery"
        - "Record unknowns where contract claims cannot be evidenced"
    - name: "Report"
      steps:
        - "Generate findings report with layer breakdown and severity distribution"
        - "Emit stable finding IDs and acceptance criteria in bounded bundle mode"
        - "Emit coverage ledger, convergence receipt, and done-gate metadata"
        - "Write report and run log to designated output paths"
  goals:
    - "Evidence-backed API-contract coverage map for in-scope interfaces"
    - "Deterministic detection of spec, conformance, and compatibility gaps"
    - "Actionable remediation guidance with stable finding identity"
    - "Convergence-ready outputs for pre-release and post-remediation gates"
---

# Behavior Phases

This skill runs a six-phase API-contract coverage loop. Each mandatory layer
must complete before the next to keep findings attributable and reproducible.

## Layer Intent

- `Contract Definition and Specification Coverage` verifies declared API contracts are complete and traceable.
- `Implementation and Compatibility Conformance` verifies runtime surfaces conform to contracts and compatibility posture.
- `Versioning, Deprecation, and Evidence Readiness` verifies interface lifecycle governance and release evidence.

## Severity Heuristic

- `CRITICAL` -- Missing contract controls likely to cause severe interface breakage on critical paths
- `HIGH` -- Significant contract/conformance gap that materially weakens readiness
- `MEDIUM` -- Partial/inconsistent contract artifacts that reduce traceability and assurance
- `LOW` -- Minor clarity or consistency issues with limited risk impact

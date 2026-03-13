---
behavior:
  phases:
    - name: "Configure"
      steps:
        - "Parse scope, baseline references, artifact globs, and convergence controls"
        - "Normalize severity threshold and finding taxonomy"
        - "Enumerate policy/control, secrets/access, dependency, and evidence artifacts"
        - "Build deterministic scope inventory for coverage accounting"
    - name: "Policy and Control Coverage"
      isolation: true
      steps:
        - "Inspect policy baseline and principle artifacts for required control intent"
        - "Inspect control artifacts for enforceable security gate definitions"
        - "Check alignment between policy declarations and control implementations"
        - "Record policy/control coverage findings and clean coverage proof"
    - name: "Secrets and Access Safeguards"
      isolation: true
      steps:
        - "Inspect secrets-handling safeguards and redaction control artifacts"
        - "Inspect authorization and policy-enforcement artifacts"
        - "Check critical paths for secrets and access-control coverage evidence"
        - "Record safeguard gaps with explicit acceptance criteria"
    - name: "Dependency and Evidence Readiness"
      isolation: true
      steps:
        - "Inspect dependency and supply-chain evidence artifacts (for example SBOM references)"
        - "Inspect compliance evidence artifacts and run receipts"
        - "Check whether in-scope critical surfaces have traceable evidence chains"
        - "Record readiness findings and clean coverage proof"
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
    - "Evidence-backed security and compliance coverage map for in-scope surfaces"
    - "Deterministic detection of policy, control, secrets, access, dependency, and evidence gaps"
    - "Actionable remediation guidance with stable finding identity"
    - "Convergence-ready outputs for pre-release and post-remediation gates"
---

# Behavior Phases

This skill runs a six-phase security and compliance coverage loop. Each
mandatory layer must complete before the next to keep findings attributable and
reproducible.

## Layer Intent

- `Policy and Control Coverage` verifies that policy baselines and controls are present and aligned.
- `Secrets and Access Safeguards` verifies secrets protection and authorization coverage.
- `Dependency and Evidence Readiness` verifies dependency assurance artifacts and compliance receipts.

## Severity Heuristic

- `CRITICAL` -- Missing safeguards or controls on critical paths likely to enable unauthorized access or non-compliant release
- `HIGH` -- Significant security/compliance coverage gap that materially degrades release assurance
- `MEDIUM` -- Partial/inconsistent controls or evidence that reduce traceability and confidence
- `LOW` -- Minor clarity or consistency issues with limited risk impact

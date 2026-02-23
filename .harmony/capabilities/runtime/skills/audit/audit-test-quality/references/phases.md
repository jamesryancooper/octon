---
behavior:
  phases:
    - name: "Configure"
      steps:
        - "Parse scope, baseline references, artifact globs, and convergence controls"
        - "Normalize severity threshold and finding taxonomy"
        - "Enumerate strategy, contract/integration, determinism, and evidence artifacts"
        - "Build deterministic scope inventory for coverage accounting"
    - name: "Test Strategy and Coverage Topology"
      isolation: true
      steps:
        - "Inspect testing strategy baseline and policy artifacts"
        - "Inspect unit, integration, contract, and regression test surface artifacts"
        - "Check alignment between declared strategy and discovered coverage topology"
        - "Record coverage findings and clean coverage proof"
    - name: "Contract and Integration Assurance"
      isolation: true
      steps:
        - "Inspect contract and integration test artifacts"
        - "Inspect service/interface compatibility and dependency evidence"
        - "Check traceability links between critical paths and executable tests"
        - "Record assurance gaps with explicit acceptance criteria"
    - name: "Determinism, Flake Control, and Gate Evidence"
      isolation: true
      steps:
        - "Inspect determinism and flake-management artifacts"
        - "Inspect quality-gate policy and run-evidence artifacts"
        - "Check whether critical-path test results are reproducible and gateable"
        - "Record readiness findings and clean coverage proof"
    - name: "Self-Challenge"
      steps:
        - "Re-check evidence sufficiency for each non-trivial finding"
        - "Attempt to disprove high-severity findings and downgrade if unsupported"
        - "Search for blind spots in scope selection and artifact discovery"
        - "Record unknowns where quality claims cannot be evidenced"
    - name: "Report"
      steps:
        - "Generate findings report with layer breakdown and severity distribution"
        - "Emit stable finding IDs and acceptance criteria in bounded bundle mode"
        - "Emit coverage ledger, convergence receipt, and done-gate metadata"
        - "Write report and run log to designated output paths"
  goals:
    - "Evidence-backed test-quality coverage map for in-scope surfaces"
    - "Deterministic detection of strategy, assurance, and gate-readiness gaps"
    - "Actionable remediation guidance with stable finding identity"
    - "Convergence-ready outputs for pre-release and post-remediation gates"
---

# Behavior Phases

This skill runs a six-phase test-quality coverage loop. Each mandatory layer
must complete before the next to keep findings attributable and reproducible.

## Layer Intent

- `Test Strategy and Coverage Topology` verifies declared strategy aligns with discovered test surface coverage.
- `Contract and Integration Assurance` verifies critical paths are protected by traceable contract and integration tests.
- `Determinism, Flake Control, and Gate Evidence` verifies reproducibility and quality-gate readiness.

## Severity Heuristic

- `CRITICAL` -- Missing quality controls likely to permit severe regressions on critical paths
- `HIGH` -- Significant test-quality gap that materially weakens release confidence
- `MEDIUM` -- Partial/inconsistent test artifacts that reduce reliability and traceability
- `LOW` -- Minor clarity or consistency issues with limited risk impact

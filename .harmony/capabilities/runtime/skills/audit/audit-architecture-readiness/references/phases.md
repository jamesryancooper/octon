---
behavior:
  phases:
    - name: "Configure"
      steps:
        - "Parse target path, threshold, evidence depth, and convergence controls"
        - "Normalize severity threshold and finding taxonomy"
        - "Inventory candidate evidence roots for the target"
        - "Build deterministic scope inventory for coverage accounting"
    - name: "Target Classification and Applicability Gate"
      isolation: true
      steps:
        - "Classify the target using domain profiles and bounded-surface rules"
        - "Resolve whole-harness, bounded-domain, or not-applicable outcome"
        - "Stop early with explicit not-applicable result for unsupported targets"
    - name: "Dimension Scoring"
      isolation: true
      steps:
        - "Score all 13 framework dimensions for supported targets"
        - "Track hard-gate failures explicitly"
        - "Record evidence-backed gaps with stable IDs and acceptance criteria"
        - "Record clean coverage proof for scored surfaces"
    - name: "Failure-Mode and Boundary Analysis"
      isolation: true
      steps:
        - "Assess mandatory failure modes"
        - "Assess control-plane vs execution-plane integrity"
        - "Identify design smells that indicate structural weakness"
        - "Map material gaps to exact remediation artifacts"
    - name: "Self-Challenge"
      steps:
        - "Re-check evidence sufficiency for each high-severity finding"
        - "Attempt to disprove unsupported claims and downgrade if necessary"
        - "Search for blind spots in classification and scope selection"
        - "Record unknowns where readiness claims cannot be evidenced"
    - name: "Report"
      steps:
        - "Generate markdown report with section-complete findings"
        - "Write structured summary JSON and validate it against the report schema"
        - "Emit coverage ledger, convergence receipt, and done-gate metadata"
        - "Write report and run log to designated output paths"
  goals:
    - "Deterministic architecture-readiness verdict for supported Harmony targets"
    - "Evidence-backed hard-gate failures and remediation plan"
    - "Stable structured output suitable for workflow orchestration"
    - "Explicit not-applicable results for unsupported target classes"
---

# Behavior Phases

This skill runs a six-phase architecture-readiness evaluation loop. Mandatory
layers must complete before the next to keep findings attributable and
reproducible.

## Layer Intent

- `Target Classification and Applicability Gate` prevents forced scoring of unsupported targets.
- `Dimension Scoring` produces the core readiness verdict and hard-gate analysis.
- `Failure-Mode and Boundary Analysis` explains how the architecture resists or fails under operational pressure.

## Severity Heuristic

- `CRITICAL` -- Hard-gate or structural defect that blocks implementation-ready verdict
- `HIGH` -- Material readiness gap that substantially weakens governability or recovery posture
- `MEDIUM` -- Partial or inconsistent readiness coverage
- `LOW` -- Minor clarity, naming, or consistency issue

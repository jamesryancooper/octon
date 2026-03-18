---
decisions:
  - id: target-classification
    point: "Phase 2: Target Classification and Applicability Gate"
    question: "How should the target be classified before scoring?"
    branches:
      - condition: "target_path == '.octon'"
        label: whole_octon
        next_phase: "Run whole-harness evaluation"
      - condition: "target_path is one top-level bounded-surface domain"
        label: bounded_surface_domain
        next_phase: "Run bounded-domain evaluation"
      - condition: "target_path resolves to unsupported profile or surface-only path"
        label: not_applicable
        next_phase: "Emit not-applicable verdict, recommend audit-surface-architecture for single-surface follow-up, and stop scoring"

  - id: evidence-sufficiency
    point: "Phase 5: Self-Challenge"
    question: "Is there enough evidence to defend the verdict?"
    branches:
      - condition: "all blocking claims are path-backed"
        label: sufficient
        next_phase: "Preserve findings and verdict"
      - condition: "one or more blocking claims lack support"
        label: insufficient
        next_phase: "Downgrade unsupported claims and record unknowns"

  - id: done-gate-mode
    point: "Phase 6: Report"
    question: "Should this run enforce strict done-gate pass criteria?"
    branches:
      - condition: "post_remediation == true"
        label: strict_done_gate
        next_phase: "Require convergence stability and zero open findings at/above threshold"
      - condition: "post_remediation == false"
        label: discovery_done_gate
        next_phase: "Record done-gate result for planning only"

default_path:
  [
    "Configure",
    "Target Classification and Applicability Gate",
    "Dimension Scoring",
    "Failure-Mode and Boundary Analysis",
    "Self-Challenge",
    "Report",
  ]
---

# Decision Reference

Branching is controlled by target classification, evidence sufficiency, and
done-gate mode.

Decision guardrails:

- Classification happens before any scoring.
- Unsupported targets never receive forced scores.
- Strict remediation pass criteria apply only when `post_remediation=true`.

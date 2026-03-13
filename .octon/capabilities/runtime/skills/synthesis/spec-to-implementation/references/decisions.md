---
decisions:
  - id: ambiguity-gate
    point: "Phase 1: Parse"
    question: "Is the specification sufficiently clear for decomposition?"
    branches:
      - condition: "Requirements and constraints are clear"
        label: proceed
        next_phase: "Phase 2: Map"
      - condition: "Contradictory or underspecified requirements"
        label: clarify
        next_phase: "Request clarifications before finalizing plan"

  - id: plan-size-gate
    point: "Phase 4: Sequence"
    question: "Does the generated plan exceed bounded task volume?"
    branches:
      - condition: "Task count <= 30"
        label: single_plan
        next_phase: "Phase 5: Plan"
      - condition: "Task count > 30"
        label: phased_plan
        next_phase: "Split output into milestones/phases"

default_path: ["Parse", "Map", "Decompose", "Sequence", "Plan", "Review"]
---

# Decision Reference

Two decisions control output quality:

- Ambiguity gate ensures assumptions are surfaced instead of guessed.
- Plan-size gate keeps decomposition reviewable by splitting oversized plans.

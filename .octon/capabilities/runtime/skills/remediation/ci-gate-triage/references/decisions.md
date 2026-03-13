---
decisions:
  - id: context-sufficient
    point: "Phase 1: Pre-flight"
    question: "Is context sufficient to proceed deterministically?"
    branches:
      - condition: "Yes"
        label: proceed
        next_phase: "Run analysis and mapping"
      - condition: "No"
        label: escalate
        next_phase: "Return missing-context escalation"

  - id: evidence-quality
    point: "Phase 3: Output and Escalation"
    question: "Is evidence quality sufficient for a reliable result?"
    branches:
      - condition: "Yes"
        label: sufficient
        next_phase: "Return outcome"
      - condition: "No"
        label: insufficient
        next_phase: "Return bounded guidance with explicit uncertainty"

default_path: ["Pre-flight", "Analysis and Mapping", "Output and Escalation"]
---

# Decision Reference

Decision points keep this skill deterministic, bounded, and auditable.

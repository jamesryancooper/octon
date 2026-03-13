---
decisions:
  - id: severity-confidence
    point: "Phase 1: Scope and Severity"
    question: "Is severity classification reliable enough to proceed?"
    branches:
      - condition: "Yes"
        label: classified
        next_phase: "Mitigation decisioning"
      - condition: "No"
        label: uncertain
        next_phase: "Escalate for authority confirmation"

  - id: mitigation-choice
    point: "Phase 2: Mitigation Decisioning"
    question: "Is rollback/containment decision supported by evidence?"
    branches:
      - condition: "Yes"
        label: supported
        next_phase: "Capture evidence and follow-up"
      - condition: "No"
        label: unsupported
        next_phase: "Escalate with ambiguity receipt"

default_path: ["Scope and Severity", "Mitigation Decisioning", "Evidence and Follow-up"]
---

# Decision Reference

Incident decisions must remain explicit, reversible when possible, and traceable.

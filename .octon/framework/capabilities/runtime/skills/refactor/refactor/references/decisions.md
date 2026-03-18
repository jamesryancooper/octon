---
decisions:
  - id: verification-loop-gate
    point: "Phase 5: Verify"
    question: "Did all search patterns return zero remaining references?"
    branches:
      - condition: "Any old-pattern reference still exists"
        label: loop_back
        next_phase: "Phase 4: Execute"
      - condition: "All searches are clean"
        label: proceed
        next_phase: "Phase 6: Document"

  - id: scope-escalation
    point: "Phase 1: Define Scope"
    question: "Does the run exceed bounded limits (files/modules)?"
    branches:
      - condition: "Within limits"
        label: continue
        next_phase: "Phase 2: Audit"
      - condition: "Exceeds limits"
        label: escalate
        next_phase: "Request mission-level split"

default_path: ["Define Scope", "Audit", "Plan", "Execute", "Verify", "Document"]
---

# Decision Reference

The key branch is the mandatory verification loop. Refactor completion is blocked until all audit searches are clean.

A secondary branch escalates oversized runs to preserve safety and reviewability.

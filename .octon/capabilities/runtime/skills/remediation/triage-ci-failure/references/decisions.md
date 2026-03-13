---
decisions:
  - id: failure-category-route
    point: "Phase 2: Diagnose"
    question: "Which failure category best matches the CI evidence?"
    branches:
      - condition: "TEST_FAILURE"
        label: test_route
        next_phase: "Phase 3 with test-focused repair"
      - condition: "BUILD_ERROR or LINT_VIOLATION"
        label: build_route
        next_phase: "Phase 3 with compile/lint repair"
      - condition: "DEPENDENCY"
        label: dependency_route
        next_phase: "Phase 3 with dependency repair"
      - condition: "INFRA"
        label: infra_escalate
        next_phase: "Report and escalate (no local code fix)"

  - id: scope-cap
    point: "Phase 1: Fetch"
    question: "Are there more than 3 independent failing jobs?"
    branches:
      - condition: "<= 3 jobs"
        label: proceed
        next_phase: "Phase 2: Diagnose"
      - condition: "> 3 jobs"
        label: split
        next_phase: "Recommend batched triage passes"

default_path: ["Fetch", "Diagnose", "Fix", "Verify", "Report"]
---

# Decision Reference

Diagnosis determines the remediation route. Infrastructure failures are explicitly escalated instead of patched in code.

The workflow remains linear once category routing is selected.

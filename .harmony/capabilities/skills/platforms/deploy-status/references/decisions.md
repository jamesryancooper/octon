---
decisions:
  - id: target-resolution
    point: "Phase 1: Pre-flight"
    question: "Which deployment target should be inspected?"
    branches:
      - condition: "`deployment` parameter is provided"
        label: explicit_deployment
        next_phase: "Inspect specified deployment"
      - condition: "`project` (or linked project) with environment is available"
        label: project_environment
        next_phase: "Inspect latest deployment in environment"
      - condition: "Neither target is resolvable"
        label: unresolved
        next_phase: "Escalate for missing context"

  - id: readiness-classification
    point: "Phase 3: Verification"
    question: "How should readiness be classified?"
    branches:
      - condition: "CLI state is ready and URL check passes"
        label: ready
        next_phase: "Report READY"
      - condition: "CLI indicates building/queued"
        label: in_progress
        next_phase: "Report IN_PROGRESS"
      - condition: "CLI error or failed URL check"
        label: degraded
        next_phase: "Report DEGRADED with remediation steps"

default_path: ["Pre-flight", "Status Collection", "Verification", "Report"]
---

# Decision Reference

Decisions are intentionally limited to target resolution and readiness
classification to keep behavior deterministic across runs.

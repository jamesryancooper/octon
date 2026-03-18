---
decisions:
  - id: provider-context-resolution
    point: "Phase 1: Pre-flight"
    question: "Is provider context resolvable from the request and repository state?"
    branches:
      - condition: "Yes"
        label: resolved
        next_phase: "Proceed with provider mapping"
      - condition: "No"
        label: unresolved
        next_phase: "Escalate with required context"

  - id: evidence-quality
    point: "Phase 3: Evidence and Output"
    question: "Is evidence sufficient for a deterministic decision?"
    branches:
      - condition: "Yes"
        label: sufficient
        next_phase: "Return output"
      - condition: "No"
        label: insufficient
        next_phase: "Return escalation guidance"

default_path: ["Pre-flight", "Provider Mapping", "Evidence and Output"]
---

# Decision Reference

This skill uses bounded decision points to keep provider-specific behavior deterministic and auditable.

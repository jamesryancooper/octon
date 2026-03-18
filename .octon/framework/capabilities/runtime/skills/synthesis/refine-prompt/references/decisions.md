---
decisions:
  - id: context-depth-selection
    point: "Phase 1: Context Analysis"
    question: "How deep should repository analysis go for this prompt?"
    branches:
      - condition: "Prompt is narrow and file targets are explicit"
        label: minimal
        next_phase: "Phase 2: Intent Extraction"
      - condition: "Prompt is broad or ambiguous"
        label: deep
        next_phase: "Phase 2 with expanded context sweep"

  - id: confirmation-gate
    point: "Phase 9: Intent Confirmation"
    question: "Should the final prompt be confirmed with the user?"
    branches:
      - condition: "skip_confirmation is false"
        label: confirm
        next_phase: "Wait for user confirmation"
      - condition: "skip_confirmation is true"
        label: bypass
        next_phase: "Phase 10: Output"

default_path: ["Context Analysis", "Intent Extraction", "Persona Assignment", "Reference Injection", "Negative Constraints", "Decomposition", "Validation", "Self-Critique", "Intent Confirmation", "Output"]
---

# Decision Reference

This skill branches on analysis depth and user confirmation behavior.

- Depth branch controls how much repository context is injected.
- Confirmation branch controls whether output is paused for user approval.

All other phases execute in order.

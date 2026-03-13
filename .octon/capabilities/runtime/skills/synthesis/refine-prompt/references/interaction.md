---
interaction:
  pattern: approval

  interaction_points:
    - id: clarify_intent
      phase: 2
      type: input
      question: "The prompt has unresolved ambiguity. Which goal should be prioritized?"
      options: dynamic
      required: true

    - id: final_confirmation
      phase: 9
      type: approval
      question: "Does this refined prompt match your intent?"
      options: ["Approve", "Revise", "Cancel"]
      required: true

  state_persistence:
    strategy: checkpoint
    location: ".octon/capabilities/runtime/skills/_ops/state/runs/refine-prompt/{{run-id}}/"

  fallback:
    on_timeout: abort
    default_option: null
---

# Interaction Reference

Human decision points:

1. Clarification input when intent remains ambiguous after extraction.
2. Final approval before writing the refined prompt (unless `skip_confirmation=true`).

Expected user input:

- Preferred interpretation when multiple intents are plausible.
- Final approve/revise/cancel decision on the refined output.

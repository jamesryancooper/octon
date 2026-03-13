---
decisions:
  - id: comment-resolution-route
    point: "Phase 2: Classify"
    question: "Does each comment require code change, explanation, or deferral?"
    branches:
      - condition: "BUG/DESIGN/STYLE/NIT with actionable code change"
        label: implement_fix
        next_phase: "Phase 4: Resolve"
      - condition: "QUESTION requiring clarification only"
        label: respond_only
        next_phase: "Phase 6: Report"
      - condition: "OUT_OF_SCOPE for current PR"
        label: defer
        next_phase: "Report as deferred follow-up"

  - id: scope-guard
    point: "Phase 1: Fetch"
    question: "Is unresolved comment volume within bounded run scope?"
    branches:
      - condition: "Comment count <= 50"
        label: proceed
        next_phase: "Phase 2: Classify"
      - condition: "Comment count > 50"
        label: escalate
        next_phase: "Request batched execution"

default_path: ["Fetch", "Classify", "Plan", "Resolve", "Verify", "Report"]
---

# Decision Reference

Branching is driven by comment type and bounded scope.

- Actionable comments route to code changes.
- Clarification-only comments route directly to reporting.
- Out-of-scope comments are deferred explicitly, not silently ignored.

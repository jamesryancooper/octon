---
decisions:
  - id: input-mode
    point: "Phase 1: Analyze"
    question: "Was the request given as explicit tool list or service description?"
    branches:
      - condition: "tools parameter provided"
        label: explicit_tools
        next_phase: "Phase 2 with direct tool schema design"
      - condition: "service description provided"
        label: infer_tools
        next_phase: "Phase 2 with inferred tool set"

  - id: implementation-language
    point: "Phase 3: Scaffold"
    question: "Should scaffold target TypeScript or Python?"
    branches:
      - condition: "language is typescript"
        label: ts
        next_phase: "Generate TS project layout"
      - condition: "language is python"
        label: py
        next_phase: "Generate Python project layout"

default_path: ["Analyze", "Design", "Scaffold", "Implement", "Validate", "Document"]
---

# Decision Reference

Branching is controlled by request shape and language target.

After those decisions, execution is linear through implementation, validation, and documentation.

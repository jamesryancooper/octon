---
decisions:
  - id: input-readiness
    point: "Phase 1: Gather Materials"
    question: "Do we have enough source material to produce a defensible synthesis?"
    branches:
      - condition: "Input folder contains relevant markdown notes"
        label: proceed
        next_phase: "Phase 2: Extract Findings"
      - condition: "Folder is empty, unreadable, or out of scope"
        label: escalate
        next_phase: "Escalate to user"

  - id: contradiction-handling
    point: "Phase 4: Synthesize"
    question: "Are contradictions resolvable from available evidence?"
    branches:
      - condition: "Evidence is sufficient to reconcile conflicting findings"
        label: resolve
        next_phase: "Phase 5: Output"
      - condition: "Contradictions remain unresolved"
        label: flag
        next_phase: "Output with explicit unresolved section"

default_path: ["Gather Materials", "Extract Findings", "Identify Themes", "Synthesize", "Output"]
---

# Decision Reference

The workflow is mostly linear, with two explicit gates:

- Input readiness before extraction starts.
- Contradiction handling before final output is published.

If either gate fails, the run is still reported, but the output must clearly mark the issue for human follow-up.

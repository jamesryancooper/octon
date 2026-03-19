---
checkpoints:
  strategy: phase
  storage: ".octon/state/control/skills/checkpoints/spec-to-implementation/{{run-id}}/"
  retention: session

  schema:
    - name: parse_complete
      trigger: "After Phase 1 completes"
      contains:
        - extracted_requirements
        - extracted_constraints
        - ambiguity_log

    - name: decompose_complete
      trigger: "After Phase 3 completes"
      contains:
        - task_backlog_draft
        - dependency_edges
        - risk_annotations

recovery:
  on_resume: "Resume from next incomplete phase and keep prior assumptions visible."
  on_input_change: "If spec content changes, restart parse and remap dependencies."
  on_corruption: "Preserve artifact snapshot and rebuild decomposition state."
---

# Checkpoint Reference

Checkpoints retain requirement extraction and task graph context across interruptions.

Resume contract:

- State is stored in `.octon/state/control/skills/checkpoints/spec-to-implementation/{{run-id}}/`.
- Resume preserves assumption logs so review context is not lost.
- Any material spec update invalidates prior decomposition checkpoints.

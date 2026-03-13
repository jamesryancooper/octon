---
checkpoints:
  strategy: phase
  storage: ".octon/capabilities/runtime/skills/_ops/state/runs/refine-prompt/{{run-id}}/"
  retention: session

  schema:
    - name: context_analysis_complete
      trigger: "After Phase 1 completes"
      contains:
        - relevant_files
        - inferred_constraints
        - context_depth

    - name: draft_prompt_complete
      trigger: "After Phase 8 completes"
      contains:
        - refined_prompt_draft
        - critique_findings
        - unresolved_questions

recovery:
  on_resume: "Resume from the latest completed phase and preserve prompt draft continuity."
  on_input_change: "Re-run intent extraction if raw prompt changes."
  on_corruption: "Restart from context analysis and log recovery event."
---

# Checkpoint Reference

State is preserved to avoid redoing expensive context analysis and self-critique.

Resume contract:

- Checkpoints live in `.octon/capabilities/runtime/skills/_ops/state/runs/refine-prompt/{{run-id}}/`.
- If the raw prompt text changes mid-run, earlier checkpoints are invalidated.
- Confirmation responses are appended as resume metadata.

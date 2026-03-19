---
checkpoints:
  strategy: phase
  storage: ".octon/state/control/skills/checkpoints/create-skill/{{run_id}}/"
  retention: session

  schema:
    - name: validation_complete
      trigger: "After Phase 1 completes"
      contains:
        - requested_skill_id
        - alignment_decision
        - uniqueness_result

    - name: scaffold_complete
      trigger: "After Phase 3 completes"
      contains:
        - created_paths
        - placeholder_replacements
        - pending_registry_updates

recovery:
  on_resume: "Resume from latest phase and re-check id uniqueness before writes."
  on_input_change: "If skill_name changes, restart from validation."
  on_corruption: "Preserve corrupted run state and restart with fresh scaffold."
---

# Checkpoint Reference

Checkpointing keeps creation safe across interruptions and avoids partial registry updates.

Resume contract:

- State lives in `.octon/state/control/skills/checkpoints/create-skill/{{run_id}}/`.
- Registry updates are replayed only after validation and scaffold checkpoints are present.
- Resume re-runs uniqueness checks before any destructive operation.

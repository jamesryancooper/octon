---
checkpoints:
  strategy: phase
  storage: ".octon/capabilities/runtime/skills/_ops/state/runs/build-mcp-server/{{run-id}}/"
  retention: session

  schema:
    - name: design_complete
      trigger: "After Phase 2 completes"
      contains:
        - tool_schema_catalog
        - security_constraints
        - language_target

    - name: implementation_complete
      trigger: "After Phase 4 completes"
      contains:
        - generated_project_paths
        - handler_status
        - validation_plan

recovery:
  on_resume: "Resume from next incomplete phase using saved tool schema catalog."
  on_input_change: "If tool list or service changes, restart from analysis/design."
  on_corruption: "Preserve failed snapshot and regenerate scaffold before continuing."
---

# Checkpoint Reference

Checkpoint state keeps tool contract decisions and scaffold progress synchronized.

Resume contract:

- State is persisted in `.octon/capabilities/runtime/skills/_ops/state/runs/build-mcp-server/{{run-id}}/`.
- Resume revalidates chosen language and tool list before code generation.
- Validation results are appended to checkpoint state for final reporting.

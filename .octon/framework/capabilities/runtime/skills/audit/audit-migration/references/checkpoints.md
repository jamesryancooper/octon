---
checkpoints:
  strategy: phase
  storage: ".octon/state/control/skills/checkpoints/audit-migration/{{run-id}}/"
  retention: session

  schema:
    - name: configure_complete
      trigger: "After Phase 1 completes"
      contains:
        - normalized_manifest
        - active_scope_manifest
        - enabled_optional_layers

    - name: core_layers_complete
      trigger: "After Phase 4 completes"
      contains:
        - grep_findings
        - cross_reference_findings
        - semantic_findings

recovery:
  on_resume: "Resume from the next incomplete layer using saved scope manifest."
  on_input_change: "If mappings change, restart from configuration."
  on_corruption: "Preserve checkpoint snapshot and rerun affected layers."
---

# Checkpoint Reference

Checkpointing preserves layer isolation and reproducibility across interruptions.

Resume contract:

- Checkpoints are written under `.octon/state/control/skills/checkpoints/audit-migration/{{run-id}}/`.
- Resume never skips mandatory layers; it continues from the first incomplete layer.
- Partition mode resumes with the same partition filter to keep coverage proofs valid.

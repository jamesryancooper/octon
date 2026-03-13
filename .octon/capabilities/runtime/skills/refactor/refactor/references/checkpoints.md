---
checkpoints:
  strategy: phase
  storage: ".octon/capabilities/runtime/skills/_ops/state/runs/refactor/{{run-id}}/"
  retention: session

  schema:
    - name: audit_complete
      trigger: "After Phase 2 completes"
      contains:
        - search_manifest
        - match_inventory
        - exclusion_set

    - name: execute_pass_complete
      trigger: "After each Phase 4 pass"
      contains:
        - applied_changes
        - pending_items
        - verification_attempt

recovery:
  on_resume: "Load latest manifest and continue from pending items."
  on_input_change: "Restart from audit to rebuild match inventory."
  on_corruption: "Preserve artifacts and regenerate manifest from source."
---

# Checkpoint Reference

This skill is explicitly resumable. Checkpoints preserve audit manifests and execution progress for looped verification passes.

Resume contract:

- State is stored in `.octon/capabilities/runtime/skills/_ops/state/runs/refactor/{{run-id}}/`.
- Resume starts at the first incomplete phase with full audit context.
- Verification attempt count is retained for escalation logic.

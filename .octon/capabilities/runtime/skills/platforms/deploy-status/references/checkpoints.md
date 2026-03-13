---
checkpoints:
  strategy: phase
  storage: ".octon/capabilities/runtime/skills/_ops/state/runs/deploy-status/{{run_id}}/"
  retention: session

  schema:
    - name: preflight_complete
      trigger: "After Phase 1"
      contains:
        - target
        - project
        - environment
        - prerequisites

    - name: status_collected
      trigger: "After Phase 2"
      contains:
        - deployment_url
        - deployment_state
        - source_evidence

recovery:
  on_resume: "Re-run lightweight status collection before reusing prior results."
  on_input_change: "If project/deployment/environment changes, restart from pre-flight."
  on_corruption: "Discard partial state and restart full workflow."
---

# Checkpoint Reference

Checkpoints make repeated status checks deterministic during a single session
while still forcing a fresh read of volatile deployment state on resume.

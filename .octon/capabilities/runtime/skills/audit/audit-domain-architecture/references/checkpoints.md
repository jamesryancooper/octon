---
checkpoints:
  strategy: phase
  storage: ".octon/capabilities/runtime/skills/_ops/state/logs/audit-domain-architecture/{{run_id}}.md"
  retention: session

  schema:
    - name: configure_complete
      trigger: "After Phase 1 completes"
      contains:
        - normalized_parameters
        - target_mode
        - target_resolution_evidence
        - domain_profile_baseline
        - criteria_set

    - name: mapping_complete
      trigger: "After Phase 2 completes"
      contains:
        - surface_map
        - responsibilities_matrix
        - evidence_index

    - name: evaluation_complete
      trigger: "After Phase 4 completes"
      contains:
        - criteria_findings
        - critical_gaps
        - recommendation_candidates

recovery:
  on_resume: "Resume from the next incomplete phase using latest checkpoint section in the run log."
  on_input_change: "If domain_path, criteria, or domain_profiles_ref changes, restart from configuration."
  on_corruption: "Preserve prior log artifact and rerun all phases for determinism."
---

# Checkpoint Reference

This skill uses phase checkpoints embedded in the run log to support recoverable
analysis without source modification.

Resume contract:

- Checkpoint sections are appended in order to the run log.
- Resume never skips mandatory phases.
- If inputs change materially, prior checkpoints are invalidated.

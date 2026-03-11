---
checkpoints:
  strategy: phase
  storage: ".harmony/capabilities/runtime/skills/_ops/state/logs/audit-architecture-readiness/{{run_id}}.md"
  retention: session

  schema:
    - name: configure_complete
      trigger: "After Phase 1 completes"
      contains:
        - normalized_parameters
        - scope_inventory
        - severity_bar
        - determinism_controls

    - name: classification_complete
      trigger: "After Phase 2 completes"
      contains:
        - target_profile
        - evaluation_mode
        - applicability_result

    - name: scoring_complete
      trigger: "After Phase 4 completes"
      contains:
        - dimension_scores
        - hard_gate_failures
        - failure_mode_findings
        - coverage_ledger

    - name: self_challenge_complete
      trigger: "After Phase 5 completes"
      contains:
        - confirmed_findings
        - downgraded_findings
        - unresolved_unknowns
        - determinism_receipt_inputs

recovery:
  on_resume: "Resume from the next incomplete phase using latest checkpoint section in the run log."
  on_input_change: "If target path or classification references change, restart from configuration."
  on_corruption: "Preserve prior log artifact and rerun all mandatory phases for determinism."
---

# Checkpoint Reference

This skill uses phase checkpoints embedded in the run log to support recoverable
execution without source modification.

Resume contract:

- Checkpoint sections are appended in order to the run log.
- Resume never skips mandatory layers.
- Material parameter changes invalidate prior checkpoints.

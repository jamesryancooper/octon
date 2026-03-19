---
checkpoints:
  strategy: phase
  storage: ".octon/state/control/skills/checkpoints/triage-ci-failure/{{run-id}}/"
  retention: session

  schema:
    - name: fetch_complete
      trigger: "After Phase 1 completes"
      contains:
        - failing_run_metadata
        - job_step_targets
        - log_snippets

    - name: diagnosis_complete
      trigger: "After Phase 2 completes"
      contains:
        - failure_category
        - suspected_root_cause
        - affected_files

recovery:
  on_resume: "Resume from fix phase using saved diagnosis and target job metadata."
  on_input_change: "If CI run id changes, refresh logs before fixing."
  on_corruption: "Restart from fetch and preserve corrupted checkpoint for debugging."
---

# Checkpoint Reference

Checkpointing prevents re-triaging large CI logs after interruption.

Resume contract:

- State is saved in `.octon/state/control/skills/checkpoints/triage-ci-failure/{{run-id}}/`.
- Resume re-verifies CI job identity to avoid applying stale fixes.
- Verification results are appended to checkpoint state before final report.

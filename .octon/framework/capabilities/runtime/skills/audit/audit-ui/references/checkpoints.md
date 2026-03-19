---
checkpoints:
  strategy: phase
  storage: ".octon/state/control/skills/checkpoints/audit-ui/{{run-id}}/"
  retention: session

  schema:
    - name: ruleset_ready
      trigger: "After Phase 1 completes"
      contains:
        - ruleset_source_url
        - parsed_rule_catalog
        - fetch_timestamp

    - name: scan_complete
      trigger: "After Phase 3 completes"
      contains:
        - scanned_file_manifest
        - categorized_violations
        - clean_file_list

recovery:
  on_resume: "Resume from the next incomplete phase with cached ruleset metadata."
  on_input_change: "If target or file_types change, restart from discovery."
  on_corruption: "Re-fetch ruleset and rebuild scan state."
---

# Checkpoint Reference

State is preserved for deterministic reporting and restart safety.

Resume contract:

- Checkpoints are stored in `.octon/state/control/skills/checkpoints/audit-ui/{{run-id}}/`.
- Resume validates that the same ruleset URL and target scope are still in effect.
- If not, the run restarts from discovery to avoid mixed baselines.

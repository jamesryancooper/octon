---
checkpoints:
  strategy: phase
  storage: ".octon/capabilities/runtime/skills/_ops/state/runs/synthesize-research/{{run-id}}/"
  retention: session

  schema:
    - name: gather_materials_complete
      trigger: "After Phase 1 completes"
      contains:
        - source_file_manifest
        - source_count
        - topic_hint

    - name: identify_themes_complete
      trigger: "After Phase 3 completes"
      contains:
        - extracted_findings
        - provisional_themes
        - contradiction_candidates

recovery:
  on_resume: "Load the latest checkpoint and continue from the next unfinished phase."
  on_input_change: "Warn about source drift and restart unless user confirms reuse."
  on_corruption: "Preserve corrupted state for audit and restart from Phase 1."
---

# Checkpoint Reference

The run preserves source inventory, extracted findings, and theme drafts so synthesis can resume without re-reading every note.

Resume contract:

- Checkpoint files are stored under `.octon/capabilities/runtime/skills/_ops/state/runs/synthesize-research/{{run-id}}/`.
- Resume always revalidates source file count before continuing.
- If files changed materially, the run restarts to avoid stale conclusions.

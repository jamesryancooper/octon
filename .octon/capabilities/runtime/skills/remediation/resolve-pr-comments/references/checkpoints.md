---
checkpoints:
  strategy: phase
  storage: ".octon/capabilities/runtime/skills/_ops/state/runs/resolve-pr-comments/{{run-id}}/"
  retention: session

  schema:
    - name: fetch_complete
      trigger: "After Phase 1 completes"
      contains:
        - unresolved_comment_manifest
        - reviewer_filters
        - classification_seed

    - name: resolve_complete
      trigger: "After Phase 4 completes"
      contains:
        - applied_changes_by_comment
        - deferred_comments
        - verification_notes

recovery:
  on_resume: "Resume from first unresolved comment group with prior classifications intact."
  on_input_change: "If PR head changes significantly, rerun fetch/classify."
  on_corruption: "Preserve checkpoint for traceability and rebuild comment manifest."
---

# Checkpoint Reference

State is preserved to keep comment-to-fix traceability stable across interruptions.

Resume contract:

- Checkpoints are stored in `.octon/capabilities/runtime/skills/_ops/state/runs/resolve-pr-comments/{{run-id}}/`.
- Resume revalidates PR head SHA before applying additional fixes.
- Deferred comments remain explicitly tracked in checkpoint state.

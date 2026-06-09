# Aggregate Program Closeout Evidence Template

## Non-Authority Banner

This template is architecture guidance for parent proposal-program closeout
summaries. Parent aggregate evidence may summarize child outcomes, but it must
not satisfy child-owned manifests, subtype manifests, review receipts,
implementation prompts, validation verdicts, promotion targets, acceptance
criteria, conformance receipts, drift/churn receipts, closeout receipts, archive
metadata, or terminal outcomes.

Generated projections, raw inputs, host state, chat history, model memory, tool
availability, feature catalog entries, lifecycle events, and lifecycle
interaction receipts are not authority for child closeout.

## Required Parent Summary Fields

```yaml
schema_version: governed-cross-surface-mechanisms-program-closeout-v1
program_id: <parent-program-id>
recorded_at: <iso8601>
child_authority_preserved: true
mechanism_coverage_complete: true
selected_optional_children:
  - child_id: mechanism-detail-pages-and-operator-map
    outcome: implemented
    child_receipt_ref: <child-owned-closeout-or-archive-ref>
children:
  - child_id: <child-id>
    terminal_outcome: <implemented|closed|archived|blocked|accepted-deferral>
    child_manifest_ref: <child-owned-proposal-yml-or-archive-manifest>
    child_review_ref: <child-owned-review-receipt>
    child_implementation_ref: <child-owned-implementation-run-receipt>
    child_conformance_ref: <child-owned-conformance-receipt>
    child_drift_churn_ref: <child-owned-drift-churn-receipt>
    child_validation_ref: <child-owned-validation-receipt>
    child_closeout_ref: <child-owned-closeout-receipt>
    child_archive_ref: <child-owned-archive-metadata>
authority_systems:
  proposal_lifecycle: separate
  change_closeout: separate
  worktree_closeout: separate
  repo_hygiene_cleanup: separate
negative_controls:
  parent_evidence_satisfies_child_receipts: false
  generated_projection_used_as_authority: false
  raw_input_used_as_authority: false
  host_state_used_as_authority: false
  feature_catalog_used_as_authority: false
  lifecycle_interaction_receipt_used_as_authorization: false
```

## Mechanism Coverage

The parent closeout summary must cover every required mechanism listed in
`index.yml`. If a mechanism is covered by a child packet, the parent summary
must cite the child-owned terminal evidence rather than copying or replacing
the child receipt.

## Optional Child Handling

For `mechanism-detail-pages-and-operator-map`, record one of:

- `implemented`, with child-owned implementation, validation, closeout, and
  archive evidence.
- `accepted-deferral`, with explicit child-owned deferral evidence.

Because this program run selected the child, parent closeout is incomplete
until one of those child-owned outcomes exists.

## Separation Rule

Proposal lifecycle, Change closeout, worktree closeout, and repo hygiene cleanup
are separate authority systems. A receipt from one system can be advisory
context for another only when the target system independently accepts it under
its own contract.

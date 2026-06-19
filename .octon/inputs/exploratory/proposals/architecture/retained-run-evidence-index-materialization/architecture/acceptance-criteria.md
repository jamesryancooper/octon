# Acceptance Criteria

- A valid implemented proposal packet can produce a
  `retained-run-evidence-index-v1` artifact that passes
  `validate-retained-run-evidence-index.sh`.
- Missing required child receipt verdicts fail before any valid index claim.
- Source tampering after index creation makes retained-run index validation fail
  closed through digest mismatch.
- Materialized indexes and receipts are retained evidence only and do not claim
  control authority, execution authority, child receipt satisfaction,
  lifecycle transition authority, generated-output authority, parent promotion,
  parent closeout, archive, cleanup, publication, landing, deletion, or
  `cleaned`.
- No generated output is hand-edited.

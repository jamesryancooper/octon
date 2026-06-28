# Acceptance Criteria

- Proposal packet delivery cannot emit completed delivery when unresolved
  feature-catalog drift exists.
- Proposal program delivery cannot emit completed delivery when unresolved
  child or parent feature-catalog drift exists.
- Proposal packet terminal closeout cannot emit archive-ready when unresolved
  feature-catalog drift exists.
- Receipts cite catalog validation result, drift result, affected feature ids,
  required documentation action, and authority notes.
- Workflow validators enforce the new stage and receipt refs.

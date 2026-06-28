# Acceptance Criteria

- The product feature catalog has accurate entries for all 24 identified
  feature gaps, with matching feature notes where boundary explanation is
  required.
- Each catalog entry records implementation status, entrypoints, authoritative
  refs, runtime surfaces, relevant extension surfaces, generated/evidence refs,
  validation refs, related docs, and authority/non-authority notes.
- `validate-product-feature-catalog.sh` passes after catalog documentation
  implementation.
- The closeout gate detects new features, material feature changes, removals,
  retirements, renames, splits, merges, downgrades, implementation-status
  changes, stale refs, stale generated/evidence refs, stale validation refs,
  missing authority notes, and incorrect feature grouping.
- The gate distinguishes authored runtime/spec/validator evidence from raw
  inputs, generated outputs, host UI state, chat/model memory, and tool
  availability.
- Proposal packet delivery, proposal program delivery, and proposal packet
  terminal closeout cannot claim archive-ready or completed delivery when
  unresolved feature-catalog drift exists.
- Retained receipts cite catalog validation result, drift result, affected
  feature ids, required documentation actions, and explicit authority notes.

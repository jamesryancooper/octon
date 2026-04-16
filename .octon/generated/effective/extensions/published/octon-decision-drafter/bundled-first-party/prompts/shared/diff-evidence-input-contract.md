# Diff And Evidence Input Contract

This family derives drafts from a diff plus retained evidence.

## Required Inputs

- Exactly one of:
  - `diff_range`
  - `diff_source`
- Optional `changed_paths`
- Grounding through either:
  - non-empty `evidence_refs` under `/.octon/state/evidence/**`, or
  - contextual refs that can be expanded into retained evidence, such as
    `adr_ref`, `migration_plan_ref`, `proposal_packet_ref`,
    `run_contract_ref`, or `rollback_posture_ref`

## Input Discipline

- If both diff inputs are present, fail closed.
- If neither diff input is present, fail closed.
- If grounding cannot be established from retained evidence or target context,
  fail closed.
- Treat explicit contextual refs as scoping aids, not as authority
  replacements.

## Normalization

- Derive `changed_paths` from the diff when they are not supplied.
- Collapse repeated evidence refs into one deduplicated list.
- Record unknowns explicitly instead of inferring unsupported facts.

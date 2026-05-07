# Bundle Matrix

## `adr-update`

- Primary refs: `adr_ref`, `evidence_refs`
- Draft focus: ADR addendum or ADR patch suggestion
- Eligible explicit patch targets: ADR markdown files only

## `migration-rationale`

- Primary refs: `migration_plan_ref`, `proposal_packet_ref`, `evidence_refs`
- Draft focus: standalone `Migration Rationale` section
- Eligible explicit patch targets: migration plan markdown files or other
  human-authored draft docs

## `rollback-notes`

- Primary refs: `rollback_posture_ref`, `run_contract_ref`, `evidence_refs`
- Draft focus: `Rollback Notes` section
- Eligible explicit patch targets: human-authored narrative docs only

## `change-receipt`

- Primary refs: `evidence_refs`
- Draft focus: concise markdown receipt that cites existing retained receipts
- Eligible explicit patch targets: low-authority draft docs only; never a
  retained receipt file

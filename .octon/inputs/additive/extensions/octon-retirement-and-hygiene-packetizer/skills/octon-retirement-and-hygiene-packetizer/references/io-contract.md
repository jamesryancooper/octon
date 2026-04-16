# I/O Contract

## Inputs

- `flow` - optional route selector
- `audit_id` - optional repo-hygiene audit id
- `audit_dir` - optional repo-hygiene audit directory
- `proposal_id` - optional migration proposal id
- `include_claim_gate` - optional boolean, default `true`
- `protected_surface_mode` - optional `enforce` or `report-only`
- `dry_run_route` - optional boolean
- `run_audit` - optional boolean
- `gap_scope` - optional `missing`, `stale`, or `all`
- `packet_attachment` - optional repo-hygiene packet attachment path
- `target_ids` - optional comma-separated target ids

## Outputs

- retained run evidence under
  `/.octon/state/evidence/runs/skills/octon-retirement-and-hygiene-packetizer/`
- optional checkpoints under
  `/.octon/state/control/skills/checkpoints/octon-retirement-and-hygiene-packetizer/`
- optional migration proposal draft under
  `/.octon/inputs/exploratory/proposals/migration/<proposal_id>/`

## Flow Notes

- `scan-to-reconciliation` is summary-grade because `repo-hygiene scan` emits
  console output only.
- `audit-to-packet-draft` and `ablation-plan-draft` depend on existing
  structured audit or packet evidence.
- Draft outputs stay non-authoritative even when they cite authoritative
  evidence paths.

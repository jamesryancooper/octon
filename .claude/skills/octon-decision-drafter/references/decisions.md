# Decisions

- The composite entrypoint defaults to `change-receipt`.
- Explicit `bundle` selection outranks inferred target refs when the diff
  input is well-formed.
- Inferred routing precedence is:
  `adr_ref` -> `migration_plan_ref` or `proposal_packet_ref` ->
  `rollback_posture_ref` or `run_contract_ref` -> `change-receipt`.
- `change-receipt` may cite retained receipts, but it must never mint a new
  canonical receipt surface.
- `patch-suggestion` requires an explicit target path and must never target:
  - ADR or migration discovery indexes
  - retained receipt files under `state/evidence/**`
  - rollback posture or other control files under `state/control/**`
  - generated publication or summary outputs under `generated/**`

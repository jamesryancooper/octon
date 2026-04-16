# Routing Guide

The `octon-decision-drafter` dispatcher resolves routes in this order:

1. explicit valid `bundle`
2. explicit unsupported `bundle` -> deny
3. conflicting target refs -> escalate
4. conflicting diff inputs -> escalate
5. inferred target refs
6. default `change-receipt`
7. missing required diff or grounding inputs -> escalate

Inference order:

- `adr_ref` -> `adr-update`
- `migration_plan_ref` or `proposal_packet_ref` -> `migration-rationale`
- `rollback_posture_ref` or `run_contract_ref` -> `rollback-notes`
- otherwise `change-receipt`

`dry_run_route=true` returns the route receipt without dispatching to a leaf
bundle.

# Bundle Matrix

| Bundle | Route Id | Prompt Set Id | Primary Inputs | Default Output |
| --- | --- | --- | --- | --- |
| ADR update | `adr-update` | `octon-decision-drafter-adr-update` | `diff_range` or `diff_source`, `adr_ref`, retained evidence | ADR addendum or ADR patch suggestion |
| Migration rationale | `migration-rationale` | `octon-decision-drafter-migration-rationale` | `diff_range` or `diff_source`, `migration_plan_ref` or `proposal_packet_ref`, retained evidence | `Migration Rationale` section |
| Rollback notes | `rollback-notes` | `octon-decision-drafter-rollback-notes` | `diff_range` or `diff_source`, `rollback_posture_ref` or `run_contract_ref`, retained evidence | `Rollback Notes` section |
| Change receipt | `change-receipt` | `octon-decision-drafter-change-receipt` | `diff_range` or `diff_source`, retained evidence | inline or scratch markdown receipt |

## Shared Guardrails

- Every bundle returns `Draft / Non-Authoritative`.
- `patch-suggestion` requires `draft_target_path`.
- No bundle may auto-write discovery indexes, retained receipts, rollback
  truth, or generated publication surfaces.

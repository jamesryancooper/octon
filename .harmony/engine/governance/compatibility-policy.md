# Compatibility Policy

## Governance Context

Engine compatibility decisions must align with migration governance profile keys:

- `change_profile`: `atomic` or `transitional`
- `release_state`: `pre-1.0` or `stable`
- `transitional_exception_note`: required in `pre-1.0` when `change_profile=transitional`

## Policy

1. `atomic` profile:
   - Prefer one-step cutover with no long-lived compatibility shims.
   - Remove obsolete paths/contracts in the same promotion window.
2. `transitional` profile:
   - Allowed only when hard gates require coexistence/staged exposure.
   - Must define coexistence phases, exit criteria, and decommission date.
3. Pre-1.0 (`release_state=pre-1.0`):
   - `atomic` is default.
   - `transitional` requires complete `transitional_exception_note`.
4. Stable (`release_state=stable`):
   - Either profile may be selected based on hard-gate evidence.

## Constraints

- No undocumented compatibility mode is allowed.
- Profile tie-break ambiguity (both profiles appearing required) must escalate.
- Rollback strategy must be explicit and compatible with chosen profile.

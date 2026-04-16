# Draft Output Contract

The selected `output_mode` controls presentation only. It does not change the
non-authoritative posture of the draft.

## `inline`

- Return markdown directly in the response.
- Include `Draft / Non-Authoritative`, diff basis, evidence basis, and any
  unresolved unknowns.

## `patch-suggestion`

- Allowed only when `draft_target_path` is explicit.
- Return a suggested edit only. Do not apply it.
- Use this only for eligible human-authored narrative docs such as ADRs or
  migration plans.
- Never target discovery indexes, retained receipts, rollback-control files, or generated outputs.

## `scratch-md`

- Materialize scratch output only under the generic skill checkpoint and
  run-evidence roots.
- Keep scratch output subordinate to the current diff and evidence set.
- Scratch markdown is disposable support material, not canonical policy,
  control, or evidence truth.

# Acceptance Criteria

- Repeated unchanged no-dispatch attempts update one bounded ledger.
- `max-steps-exhausted` without route dispatch does not duplicate full compact
  evidence when the blocker fingerprint is unchanged.
- Changed input digest, changed blocker fingerprint, or route dispatch emits
  fresh evidence.
- The attempt ledger records enough data to audit why no new artifacts were
  written.

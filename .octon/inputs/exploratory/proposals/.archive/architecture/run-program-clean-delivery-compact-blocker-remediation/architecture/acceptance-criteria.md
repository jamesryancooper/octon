# Acceptance Criteria

- Repeated identical blocker fingerprints produce a compact delta receipt, not
  a duplicate full workflow tree.
- Repeated full workflow directory emission fails closed after a configurable
  threshold and switches to compact remediation when continuation is safe.
- File-count and byte-budget breaches throttle artifact production and continue
  when required evidence remains preserved.
- Compact receipts identify blocker class, current fingerprint, prior matching
  fingerprint, budget state, retained evidence refs, and next route.
- Negative controls block compact continuation when required receipts or full
  evidence would be lost.

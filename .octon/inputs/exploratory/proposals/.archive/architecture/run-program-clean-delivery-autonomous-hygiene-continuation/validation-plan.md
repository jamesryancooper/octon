# Validation Plan

- `validate-proposal-standard.sh --package <this-child> --skip-registry-check`
- `validate-architecture-proposal.sh --package <this-child>`
- `validate-proposal-implementation-readiness.sh --package <this-child>`
- Stale fingerprint preserve/exclude fixture.
- Cleanup-safe-count-zero non-mutating preserve/exclude fixture.
- Foreign residue preserve-only fixture.
- Destructive cleanup without authority negative control.
- Rerun-gate continuation fixture.

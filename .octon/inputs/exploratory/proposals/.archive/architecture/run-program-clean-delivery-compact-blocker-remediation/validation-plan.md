# Validation Plan

- `validate-proposal-standard.sh --package <this-child> --skip-registry-check`
- `validate-architecture-proposal.sh --package <this-child>`
- `validate-proposal-implementation-readiness.sh --package <this-child>`
- Repeated blocker fingerprint fixture.
- Repeated full workflow directory threshold fixture.
- File-count budget fixture.
- Byte-budget fixture.
- Negative control where required evidence would be lost and compact mode must
  block.

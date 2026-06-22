# Validation Plan

## Parent Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening`
- `validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-lifecycle-delivery-autonomy-hardening`
- `generate-proposal-registry.sh --check`
- `validate-lifecycle-postmortem.sh --structured-output <evaluation.yml> --report <report.md> --review-findings <review-findings.ndjson>` for postmortem profile fixtures after implementation

## Child Validators

Each child must pass:

- `validate-proposal-standard.sh --package <child> --skip-registry-check`
- `validate-architecture-proposal.sh --package <child>`
- `validate-proposal-implementation-readiness.sh --package <child>`

Later implementation routes must add child-specific tests listed in each child packet.

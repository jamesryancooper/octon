# Validation Plan

## Packet Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-postmortem-evaluation-profile --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-postmortem-evaluation-profile`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-postmortem-evaluation-profile`

## Future Implementation Validators

- `octon lifecycle postmortem --run-id <completed-proposal-program-run-id>`
- `validate-lifecycle-postmortem.sh --run-id <completed-proposal-program-run-id>`
- `validate-lifecycle-postmortem.sh --structured-output <evaluation.yml> --report <report.md> --review-findings <review-findings.ndjson>`
- `test-lifecycle-postmortem.sh`
- Regression tests for completed proposal-program postmortems with and without delivery evidence.

## Negative Controls

- A postmortem report cannot authorize lifecycle transitions.
- A postmortem recommendation backlog cannot satisfy proposal review, child implementation, closeout, archive, delivery, or cleaned-claim gates.
- Delivery proof-chain fields cannot require PR fallback.

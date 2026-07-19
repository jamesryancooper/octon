# Validation Plan

## Evidence Posture

Planned proof is not executed proof. Each future result must record command,
working directory, exact commit, start/end time, exit code, retained log or
digest, evidence classification, and evidence reference.

## Structural Proposal Validation

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-containment`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-containment`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-containment`
- `validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-containment` after formal review
- `validate-architectural-review-receipts.sh` after a real independent review

The proposal, readiness, review, and strict architecture gates must all pass at
the accepted-state digest before implementation prompt generation. Future
implementation, provider, conformance, drift, and rollback gates remain
independently unsatisfied until their direct evidence exists.

## Future Implementation Validators

| Claim | Validator or test | Required evidence class |
| --- | --- | --- |
| Complete physical writer inventory | `validate-material-side-effect-inventory.sh` plus unknown-writer fixture | `STATICALLY_INSPECTED`, then `ADVERSARIALLY_TESTED` for the negative fixture |
| Complete launcher/authority coverage | `validate-authorization-boundary-coverage.sh` plus unknown-launcher fixture | `STATICALLY_INSPECTED`, then `ADVERSARIALLY_TESTED` |
| No Octon-owned human or agent direct-main route | `validate-execution-governance.sh`, route matrix, human/agent route negative fixtures | `DYNAMICALLY_EXECUTED` |
| GitHub projection remains non-authoritative | `validate-github-projection-alignment.sh` and provider observation | `STATICALLY_INSPECTED` and `PROVIDER_OBSERVED` |
| Claims match proof | `validate-support-target-proofing.sh`, `validate-support-target-live-claims.sh` | `STATICALLY_INSPECTED` with direct retained proof references |
| Referenced tests are not executed tests | dedicated referenced-only negative fixture | `ADVERSARIALLY_TESTED` |
| Burden baseline is reproducible | deterministic file/workflow/command/time measurements | `CONFIGURATION_DERIVED` and `DYNAMICALLY_EXECUTED` where timed |
| Rollback preserves containment | rollback drill against disposable projection/provider fixtures | `DYNAMICALLY_EXECUTED` |

## Adversarial Cases

- reintroduce a candidate-head write step;
- inject an unregistered shell or Rust writer;
- inject a raw agent spawn path;
- set a human or agent Octon route to direct-main;
- directly invoke current local landing, hosted no-PR, or destructive cleanup;
- close a PR unmerged and attempt candidate/source-branch deletion;
- present invalid, stale, revoked, wrong-SHA, or raced authority and attempt to
  convert the denial into PR;
- classify eligible Class B no-PR and prove it remains blocked and preserved;
- cite a test without executing it and attempt an executed classification;
- claim a stage-only or stale tuple as live;
- treat protected PR as a universal or presumptively safe bridge while
  containment is active;
- treat GitHub status, generated inventory, or proposal prose as authority.

Every case must fail closed without secret values or production effect targets.

## Retained Evidence

Future evidence belongs under
`.octon/state/evidence/validation/proposals/octon-architecture-migration-containment/`
and includes baseline, provider-observation, containment, inventory coverage,
claim-correction, burden, rollback, validation, conformance, and drift/churn
receipts. Evidence never replaces proposal status, operator decisions, or
canonical authority.

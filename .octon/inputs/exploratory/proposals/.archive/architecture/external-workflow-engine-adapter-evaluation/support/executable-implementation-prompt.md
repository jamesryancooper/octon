# Executable Implementation Prompt

Implement `external-workflow-engine-adapter-evaluation` as a child-owned lab
evaluation packet.

## Promotion Targets

- `.octon/framework/lab/adapter-evaluations/`
- `.octon/instance/governance/connector-admissions/external-workflow-engine-adapter/evaluate-adapter/admission.yml`
- `.octon/state/evidence/lab/adapter-evaluations/external-workflow-engine-adapter-evaluation/`
- `.octon/framework/constitution/contracts/adapters/deferred-adapter-evaluation-boundaries-v1.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-deferred-adapter-evaluation-boundaries.sh`

## Workstreams

1. Promote external workflow engine adapter lab evaluation records and retained lab proof.
2. Promote a non-live connector admission boundary record for stage-only adapter evaluation.
3. Promote the shared deferred adapter evaluation boundary contract.
4. Promote validator coverage proving external engine state cannot own Octon
   workflow, run, authorization, support, evidence, or closeout truth.

## Evidence And Receipts

Retain child validation evidence under
`.octon/state/evidence/validation/proposals/external-workflow-engine-adapter-evaluation/`.
Write `support/implementation-run.md`, `support/validation.md`,
`support/implementation-conformance-review.md`, and
`support/post-implementation-drift-churn-review.md`.

## Validation

Run:

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/external-workflow-engine-adapter-evaluation`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/external-workflow-engine-adapter-evaluation`
- `validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/external-workflow-engine-adapter-evaluation --require-implementation-authorization`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/external-workflow-engine-adapter-evaluation`
- `validate-deferred-adapter-evaluation-boundaries.sh`
- `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/external-workflow-engine-adapter-evaluation`
- `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/external-workflow-engine-adapter-evaluation`

## Rollback

Remove external workflow engine adapter lab, admission, and retained proof
records; remove shared boundary artifacts only if no sibling child still owns
them; then rerun validators and registry checks.

## Closeout Refusal Criteria

Refuse closeout or archive if external engine state is claimed as Octon
workflow truth, run truth, authorization, support, evidence, or closeout truth;
if conformance/drift receipts are missing; or if validators fail.

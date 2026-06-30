# Validation Plan

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture`
- `validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture --mode pre-integration-architecture-review --require-pass`
- `validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture --print-digest`

## Future Implementation Validators

Later child packet implementation must select the applicable subset below and
retain compact logs under the relevant run or validation evidence root:

- `validate-proposal-program-delivery-workflow.sh`
- `validate-proposal-program-delivery-profile.sh --profile <profile>`
- `validate-proposal-program-delivery-receipt.sh --receipt <receipt>`
- `generate-proposal-program-delivery-evidence-index.sh --receipt <receipt> --out <index>`
- `validate-proposal-program-delivery-evidence-index.sh --index <index>`
- `validate-proposal-program-readiness-projection.sh --projection <projection>`
- `validate-proposal-lifecycle-terminal-freshness.sh --targeted <target>`
- `validate-feature-catalog-drift-closeout.sh --receipt <receipt>`
- `validate-change-closeout-state-machine.sh --receipt <receipt>`
- `validate-hosted-no-pr-landing.sh --receipt <receipt>`
- `validate-closeout-worktree-wrapper.sh --report <report>`
- `classify-proposal-worktree-hygiene.sh --target <proposal-program>`
- `validate-terminal-closeout-local-evidence.sh --proof <proof> --require-cleaned`
- `validate-evidence-disclosure-tiers.sh`
- `validate-extension-publication-state.sh`
- `validate-runtime-effective-state.sh`
- `validate-runtime-effective-route-bundle.sh`
- `validate-no-raw-generated-effective-runtime-reads.sh`
- `validate-generated-non-authority.sh`
- `validate-input-non-authority.sh`

## Negative Controls

- Parent summary, readiness projection, delivery receipt, or delivery evidence
  index used as child-owned receipt evidence must fail.
- Aggregate delivery receipt used as archive, Change, cleanup, generated
  publication, or terminal proof authorization must fail.
- Raw additive extension input used as runtime route authority without
  generated effective publication and freshness evidence must fail.
- Generated effective output hand edits must fail publication freshness checks.
- Local/private terminal evidence used as hosted/shared closeout proof must
  fail evidence disclosure validation.

## Retained Evidence Expectations

- Route and workflow receipts:
  `.octon/state/evidence/runs/workflows/<run-id>/**`.
- Skill receipts:
  `.octon/state/evidence/runs/skills/**`.
- Validator logs:
  `.octon/state/evidence/validation/**`.
- Publication receipts:
  `.octon/state/evidence/validation/publication/**`.
- Proposal-local support receipts remain under this packet and are
  non-authoritative.

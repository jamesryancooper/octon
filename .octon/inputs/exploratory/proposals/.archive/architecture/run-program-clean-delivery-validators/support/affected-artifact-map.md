# Affected Artifact Map

proposal_id: run-program-clean-delivery-validators
reviewed_at: 2026-06-29T14:32:31Z
verdict: pass

## Promotion Targets

### `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`

- owner: Octon assurance runtime
- priority: required
- current assumption: clean-delivery proof is distributed across existing
  delivery, closeout, hosted-landing, lifecycle-alignment, and disclosure-tier
  validators.
- required change: add a read-only aggregate validator that confirms the
  validator chain is present and statically healthy, and optionally validates a
  proposal-program delivery receipt for a proven `cleaned` outcome.
- retained evidence expectation: packet `support/implementation-run.md`,
  packet `support/validation.md`, and lifecycle run evidence cite the command
  and result.
- generated-output boundary: no generated output is edited or trusted as
  authority by this validator.
- rollback expectation: remove this script with the paired regression test.
- closeout boundary: the validator cannot authorize archive, cleanup, branch
  cleanup, generated publication, Git mutation, terminal proof, or a cleaned
  claim.
- downstream references: `validation-plan.md`,
  `support/executable-implementation-prompt.md`,
  `support/implementation-run.md`, and the regression test.

### `.octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh`

- owner: Octon assurance runtime
- priority: required
- current assumption: no single regression test proves the aggregate validator
  fails closed on clean-delivery overclaims.
- required change: add one shell regression test with a valid cleaned receipt
  fixture plus negative controls for non-cleaned outcome, stale terminal proof,
  and aggregate evidence substitution.
- retained evidence expectation: packet `support/implementation-run.md` and
  `support/validation.md` cite the test result.
- generated-output boundary: test fixtures are temporary local files and never
  become generated authority.
- rollback expectation: remove this test with the aggregate validator.
- closeout boundary: the test performs no network, hosted, Git, archive,
  cleanup, generated publication, terminal proof, or branch cleanup mutation.
- downstream references: `validation-plan.md`,
  `support/executable-implementation-prompt.md`, and
  `support/implementation-run.md`.

## Existing Validator Dependencies

The aggregate validator composes these existing validators without taking over
their authority:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh`

## Exclusions

- No Rust regression target is included in this packet.
- No directory-level promotion target is approved.
- No generated projection, proposal input, host surface, chat, model memory, or
  local/private evidence is promoted as authority.

# Run Program Clean Delivery Validators

This child packet promotes a narrow aggregate validator for autonomous clean
delivery completion.

The promoted validator is
`.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`.
It composes existing proposal-program delivery, closeout, hosted landing, and
evidence validators, and can additionally validate a delivery receipt whose
actual outcome is `cleaned`.

The promoted regression test is
`.octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh`.
It proves a valid cleaned receipt passes and negative controls fail for
non-cleaned delivery, stale terminal proof, and aggregate evidence
substitution.

The validator is read-only. It does not authorize mutation, delivery, archive,
cleanup, branch cleanup, generated publication, or a cleaned claim.

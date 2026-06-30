# Validation

validation_id: run-program-clean-delivery-validators-validation-20260629T143231Z
validated_at: 2026-06-29T14:32:31Z
verdict: pass
errors: 0

## Commands

- `bash -n .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
  - result: pass
- `bash -n .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh`
  - result: pass
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
  - result: pass
- `bash .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh`
  - result: pass

## Coverage

- Static aggregate validator chain.
- Valid cleaned proposal-program delivery receipt.
- Non-cleaned delivery outcome rejection.
- Stale terminal proof rejection.
- Aggregate evidence substitution rejection.

## Exclusions

- No network access.
- No hosted mutation.
- No Git mutation.
- No archive, cleanup, branch cleanup, generated publication, terminal proof
  synthesis, or `cleaned` claim.

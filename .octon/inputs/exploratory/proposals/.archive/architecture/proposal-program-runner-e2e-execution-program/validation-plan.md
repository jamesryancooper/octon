# Validation Plan

## Creation-Time Validators

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child>` for every child.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package <child>` for every child.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <child> --require-implementation-authorization` for every child.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <parent> --require-implementation-authorization`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package <parent>`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package <parent>`.
- `.octon/framework/engine/runtime/run lifecycle run --lifecycle proposal-program --target <parent>` without `--execute-routes`.

## Source Coverage Checks

Run source-coverage checks after decomposition, after creation, and before final
readiness. Missing or ambiguous requirements block readiness.

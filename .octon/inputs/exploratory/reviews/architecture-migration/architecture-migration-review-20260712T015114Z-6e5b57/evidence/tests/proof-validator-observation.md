# Proof Validator Dynamic Observation

Command:

OCTON_EMIT_VALIDATOR_RESULT=1 bash
.octon/framework/assurance/runtime/_ops/scripts/validate-proof-bundle-executability.sh

Result: exit 0; validation errors=0.

The emitted validator-result manifest declared:

- claimed_depth: proof
- achieved_depth: proof
- runtime_tests_executed:
  .octon/framework/assurance/runtime/_ops/tests/test-proof-bundle-execution.sh
- negative_controls_executed:
  missing-proof-execution-or-replay-evidence-denies

Static inspection of validate-proof-bundle-executability.sh and
validator-result-common.sh shows the validator checks fields and references
and appends the test path/control name to result arrays. It does not invoke the
referenced test script.

Classification: DYNAMICALLY_EXECUTED for the emitted result and
STATICALLY_INSPECTED for the call graph. The observation proves misleading
execution metadata, not that every underlying proof artifact is false.


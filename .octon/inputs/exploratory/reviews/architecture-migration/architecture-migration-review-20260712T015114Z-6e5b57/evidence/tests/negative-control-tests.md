# Negative-Control and Publication Test Results

## Hosted no-PR

Command:

CARGO_TARGET_DIR=/tmp/octon-amr-shell-target bash
.octon/framework/assurance/runtime/_ops/tests/test-hosted-no-pr-landing.sh

Result: exit 0; 29 passed, 0 failed.

Cases included source/check SHA binding, missing/denied/stale authorization,
execution signal, force-push refspec, missing evidence, route/ruleset
expectations, and pushed-only claims.

## Authorized-effect bypass controls

Command:

CARGO_TARGET_DIR=/tmp/octon-amr-authority-target bash
.octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-negative-bypass.sh

Result: exit 0. Missing token, wrong scope, reuse, expiry, forged digest, wrong
class, and related selected authority tests passed.

## Material side-effect controls

Command:

CARGO_TARGET_DIR=/tmp/octon-amr-authority-target bash
.octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-token-bypass-denials.sh

Result: exit 0; 3 passed, 0 failed.

## Boundary coverage controls

The authorization boundary coverage and negative-control scripts exited 0.
Their validators establish declared file/pattern/fixture coverage. They do not
enumerate and prove structural dominance over lifecycle/pipeline/workflow
spawn or candidate-controlled provider paths.

Classification: ADVERSARIALLY_TESTED for the actual negative fixtures;
DYNAMICALLY_EXECUTED for structural validators. Scope limitations remain
STATICALLY_INSPECTED.


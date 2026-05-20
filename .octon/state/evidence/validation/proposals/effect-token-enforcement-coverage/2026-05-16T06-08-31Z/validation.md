# Validation Evidence

validated_at: 2026-05-16T06:09:24Z

## validate-proposal-standard

Command:

## bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage

Command:


Exit code: 0
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/validate-proposal-standard.log
Log:

## validate-architecture-proposal

Command:

## bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage

Command:


Exit code: 0
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/validate-architecture-proposal.log
Log:

## validate-proposal-implementation-readiness

Command:

## bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage

Command:


Exit code: 0
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/validate-proposal-implementation-readiness.log
Log:

## validate-proposal-review-gate

Command:

## bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage --require-implementation-authorization

Command:


Exit code: 0
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/validate-proposal-review-gate.log
Log:

## checksum-before

Command:

## cd .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage && shasum -a 256 -c SHA256SUMS.txt

Command:


Exit code: 0
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/checksum-before.log
Log:

## validate-material-side-effect-inventory

Command:

## bash .octon/framework/assurance/runtime/_ops/scripts/validate-material-side-effect-inventory.sh

Command:


Exit code: 0
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/validate-material-side-effect-inventory.log
Log:

## validate-authorization-boundary-coverage

Command:

## bash .octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh

Command:


Exit code: 0
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/validate-authorization-boundary-coverage.log
Log:

## validate-authorized-effect-token-enforcement

Command:

## bash .octon/framework/assurance/runtime/_ops/scripts/validate-authorized-effect-token-enforcement.sh

Command:


Exit code: 0
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/validate-authorized-effect-token-enforcement.log
Log:

## validate-architecture-conformance

Command:

## bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh

Command:


Exit code: 1
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/validate-architecture-conformance.log
Log:

## test-material-side-effect-token-bypass-denials

Command:

## bash .octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-token-bypass-denials.sh

Command:


Exit code: 1
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/test-material-side-effect-token-bypass-denials.log
Log:

## test-authorized-effect-token-negative-bypass

Command:

## bash .octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-negative-bypass.sh

Command:


Exit code: 0
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/test-authorized-effect-token-negative-bypass.log
Log:

## test-authorized-effect-token-consumption

Command:

## bash .octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-consumption.sh

Command:


Exit code: 0
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/test-authorized-effect-token-consumption.log
Log:

## test-material-side-effect-coverage-fixtures

Command:

## bash .octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-coverage-fixtures.sh

Command:


Exit code: 1
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/test-material-side-effect-coverage-fixtures.log
Log:

## cargo-authorized-effects

Command:

## cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_authorized_effects

Command:


Exit code: 0
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/cargo-authorized-effects.log
Log:

## cargo-authority-engine-lib

Command:

## cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_authority_engine --lib

Command:


Exit code: 0
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/cargo-authority-engine-lib.log
Log:

## cargo-kernel-bin

Command:

## cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel --bin octon

Command:


Exit code: 0
Log:


Exit code: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T06-08-31Z/cargo-kernel-bin.log
Log:


Failures: 3

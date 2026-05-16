# Effect Token Enforcement Coverage Validation Evidence

validated_at: 2026-05-16T07:19:47Z
run_id: lifecycle-proposal-program-1778904192406-8da93d7a-effect-token-enforcement-coverage
proposal_path: .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage

## Commands

### validate-proposal-standard

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage
```

exit_code: 0
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/validate-proposal-standard.log

    Validation summary: errors=0 warnings=0
    [OK] proposal review gate passes
    [OK] promotion targets are present
    [OK] promotion target scope is coherent
    Validation summary: errors=0 warnings=1
    Validation summary: errors=0
    [OK] subtype validator passes for .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
    [OK] generated proposal registry parses as YAML
    [OK] proposal registry matches generated projection
    Registry generation summary: errors=0
    [OK] proposal registry synchronized with manifest projection
    Validation summary: errors=0 warnings=1


### validate-architecture-proposal

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage
```

exit_code: 0
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/validate-architecture-proposal.log

    [OK] review covers promotion target: .octon/framework/assurance/runtime/_ops/scripts/
    [OK] review covers promotion target: .octon/framework/assurance/runtime/_ops/tests/
    Validation summary: errors=0 warnings=0
    [OK] proposal review authorizes executable implementation prompt
    [OK] promotion targets are present
    [OK] promotion target scope is coherent
    [OK] target architecture exists
    [OK] architecture implementation plan exists
    [OK] architecture acceptance criteria exist
    [OK] implementation-grade proposal contains no scaffold placeholders
    Validation summary: errors=0 warnings=0
    Validation summary: errors=0


### validate-proposal-implementation-readiness

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage
```

exit_code: 0
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/validate-proposal-implementation-readiness.log

    [OK] review covers promotion target: .octon/framework/engine/runtime/crates/
    [OK] review covers promotion target: .octon/framework/assurance/runtime/_ops/scripts/
    [OK] review covers promotion target: .octon/framework/assurance/runtime/_ops/tests/
    Validation summary: errors=0 warnings=0
    [OK] proposal review authorizes executable implementation prompt
    [OK] promotion targets are present
    [OK] promotion target scope is coherent
    [OK] target architecture exists
    [OK] architecture implementation plan exists
    [OK] architecture acceptance criteria exist
    [OK] implementation-grade proposal contains no scaffold placeholders
    Validation summary: errors=0 warnings=0


### validate-proposal-review-gate

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage --require-implementation-authorization
```

exit_code: 0
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/validate-proposal-review-gate.log

    [OK] review covers promotion target: .octon/framework/assurance/runtime/_ops/scripts/
    [OK] review covers promotion target: .octon/framework/assurance/runtime/_ops/tests/
    [OK] proposal status is accepted for implementation authorization
    [OK] proposal review authorizes implementation
    [OK] proposal review permits implementation prompt generation
    [OK] proposal review has no open blockers for implementation
    [OK] reviewed packet digest is fresh
    [OK] review covers promotion target: .octon/framework/engine/runtime/spec/
    [OK] review covers promotion target: .octon/framework/engine/runtime/crates/
    [OK] review covers promotion target: .octon/framework/assurance/runtime/_ops/scripts/
    [OK] review covers promotion target: .octon/framework/assurance/runtime/_ops/tests/
    Validation summary: errors=0 warnings=0


### validate-material-side-effect-inventory

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-material-side-effect-inventory.sh
```

exit_code: 0
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/validate-material-side-effect-inventory.log

    [OK] extension-activation owner present
    [OK] extension-activation risk tier present
    [OK] extension-activation material flag present
    [OK] extension-activation token type present
    [OK] capability-pack-activation roots present
    [OK] capability-pack-activation boundary present
    [OK] capability-pack-activation owner present
    [OK] capability-pack-activation risk tier present
    [OK] capability-pack-activation material flag present
    [OK] capability-pack-activation token type present
    [OK] coverage receipt binds inventory
    Validation summary: errors=0


### validate-authorization-boundary-coverage

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh
```

exit_code: 0
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/validate-authorization-boundary-coverage.log

    [OK] authority-phases contains pattern: execution-receipt-v3
    [OK] authority-phases declares denial reason code
    [OK] authority-phases declares negative controls
    [OK] authority-phases declares test coverage
    [OK] authority-phases declares authorized-effect token mediation
    [OK] authority-phases declares token bypass negative control
    [OK] workflow gate present: .github/workflows/architecture-conformance.yml
    [OK] .github/workflows/architecture-conformance.yml contains gate text: validate-authorization-boundary-coverage.sh
    [OK] .github/workflows/architecture-conformance.yml contains gate text: validate-material-side-effect-inventory.sh
    [OK] workflow gate present: .github/workflows/deny-by-default-gates.yml
    [OK] .github/workflows/deny-by-default-gates.yml contains gate text: validate-authorization-boundary-coverage.sh
    Validation summary: errors=0


### validate-authorized-effect-token-enforcement

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-authorized-effect-token-enforcement.sh
```

exit_code: 0
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/validate-authorized-effect-token-enforcement.log

    [OK] connector-admission-runtime-admin negative bypass ref present
    [OK] connector-admission-runtime-admin token_required present
    [OK] connector-admission-runtime-admin coverage_state present
    [OK] connector-admission-runtime-admin is explicitly non-live: stage_only
    [OK] connector-operation-live-effect class binding present
    [OK] connector-operation-live-effect owner ref present
    [OK] connector-operation-live-effect consumer api ref present
    [OK] connector-operation-live-effect negative bypass ref present
    [OK] connector-operation-live-effect token_required present
    [OK] connector-operation-live-effect coverage_state present
    [OK] connector-operation-live-effect is explicitly non-live: denied_until_connector_admission_runtime_authorization
    Validation summary: errors=0


### test-material-side-effect-token-bypass-denials

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-token-bypass-denials.sh
```

exit_code: 0
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/test-material-side-effect-token-bypass-denials.log

    PASS: token enforcement fails without token types
    PASS: token enforcement passes with declared token mediation
    PASS: token enforcement fails without token bypass negative controls
    
    test-material-side-effect-token-bypass-denials.sh: passed=3 failed=0


### test-authorized-effect-token-negative-bypass

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-negative-bypass.sh
```

exit_code: 0
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/test-authorized-effect-token-negative-bypass.log

    test implementation::tests::budget_denial_rejects_effect_consumption ... ok
    
    test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 69 filtered out; finished in 2.36s
    
        Finished `test` profile [unoptimized + debuginfo] target(s) in 0.14s
         Running unittests src/lib.rs (.octon/generated/.tmp/engine/build/runtime-crates-target/debug/deps/octon_authority_engine-95e8650e86b57203)
    
    running 1 test
    test implementation::tests::egress_denial_rejects_effect_consumption ... ok
    
    test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 69 filtered out; finished in 2.35s
    


### test-authorized-effect-token-consumption

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-consumption.sh
```

exit_code: 0
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/test-authorized-effect-token-consumption.log

    test implementation::tests::issued_effect_verifies_and_records_consumption_receipt ... ok
    
    test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 69 filtered out; finished in 2.40s
    
        Finished `test` profile [unoptimized + debuginfo] target(s) in 0.14s
         Running unittests src/lib.rs (.octon/generated/.tmp/engine/build/runtime-crates-target/debug/deps/octon_authority_engine-95e8650e86b57203)
    
    running 1 test
    test implementation::tests::failed_run_measurement_artifacts_remain_workflow_agnostic ... ok
    
    test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 69 filtered out; finished in 2.80s
    


### test-material-side-effect-coverage-fixtures

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-coverage-fixtures.sh
```

exit_code: 0
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/test-material-side-effect-coverage-fixtures.log

    test workflow::tests::create_design_package_writes_execution_artifacts ... ok
    
    test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 199 filtered out; finished in 12.47s
    
        Finished `test` profile [unoptimized + debuginfo] target(s) in 0.16s
         Running unittests src/main.rs (.octon/generated/.tmp/engine/build/runtime-crates-target/debug/deps/octon-7bbbb56590a67520)
    
    running 1 test
    test pipeline::tests::mock_generic_workflow_writes_execution_artifacts ... ok
    
    test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 199 filtered out; finished in 10.38s
    


### cargo-test-authorized-effects

```sh
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_authorized_effects
```

exit_code: 0
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/cargo-test-authorized-effects.log

         Running unittests src/lib.rs (.octon/generated/.tmp/engine/build/runtime-crates-target/debug/deps/octon_authorized_effects-403310fef91a8294)
    
    running 0 tests
    
    test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
    
       Doc-tests octon_authorized_effects
    
    running 0 tests
    
    test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
    


### cargo-test-authority-engine-lib

```sh
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_authority_engine --lib
```

exit_code: 0
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/cargo-test-authority-engine-lib.log

    test implementation::tests::tampered_verification_bundle_fails_closed ... ok
    test implementation::tests::unsupported_support_envelope_tuple_is_rejected ... ok
    test implementation::tests::verification_bundle_scope_mismatch_fails_closed ... ok
    test implementation::tests::wrong_capability_pack_is_rejected ... ok
    test implementation::tests::wrong_effect_class_is_rejected ... ok
    test implementation::tests::wrong_route_binding_is_rejected ... ok
    test implementation::tests::wrong_run_binding_is_rejected ... ok
    test implementation::tests::wrong_scope_effect_fails_closed ... ok
    test implementation::tests::wrong_support_tuple_is_rejected ... ok
    
    test result: ok. 70 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 61.65s
    


### cargo-test-kernel-bin

```sh
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel --bin octon
```

exit_code: 0
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/cargo-test-kernel-bin.log

    test workflow::tests::create_static_proposal_failure_writes_execution_artifacts ... ok
    test workflow::tests::failing_executor_writes_failure_receipts ... ok
    test workflow::tests::mock_executor_run_materializes_reports_and_package_delta ... ok
    test workflow::tests::prepare_only_run_materializes_bundle_and_prompt_packets ... ok
    test workflow::tests::proposal_registry_preserves_same_id_across_kinds ... ok
    test workflow::tests::render_stage_prompt_injects_prior_reports ... ok
    test workflow::tests::rigorous_mock_executor_run_materializes_rigorous_reports ... ok
    test workflow::tests::validate_proposal_rejects_invalid_explicit_run_id ... ok
    test workflow::tests::validate_proposal_rejects_reused_explicit_run_id ... ok
    
    test result: ok. 200 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 273.44s
    


### validate-support-envelope-reconciliation

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-support-envelope-reconciliation.sh
```

exit_code: 1
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/validate-support-envelope-reconciliation.log

    [OK] generated result status is valid
    [OK] generated result remains non-authority
    [OK] generated result uses digest-bound freshness
    [OK] generated result declares invalidation conditions
    [OK] generated result forbids support widening
    [ERROR] published support-envelope reconciliation is stale; regenerate it
    [OK] all declared live tuples reconcile to live
    [OK] generated outputs do not widen support
    [OK] live tuples are proof-backed and freshness-valid
    [OK] live tuples are not excluded or revoked
    [OK] support envelope status reconciled
    Validation summary: errors=1


### validate-run-health-read-model

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh
```

exit_code: 1
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/validate-run-health-read-model.log

    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-safe-stage-approval-exercise-20260402/health.yml: digest drift for runtime_route_bundle: expected sha256:ab0ce11465025a09173e268b98884038dc91a3153b2bbba00e4450999d63f395, got sha256:27971f3631b0ac22cc738dccbda5b0c72b5656bd454dd0b4f496585b1bd9d5c1
    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-safe-stage-approval-exercise-20260402/health.yml: digest drift for pack_routes: expected sha256:dcc8c5a6cbcfc6ea5b3844b6771117adc1cb1fcaa05ff243419b951a958535f1, got sha256:8239696b818b859f8119999dad8b45ba6c3a3859de8b02a79f753566542388dd
    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-safe-stage-lease-revocation-exercise-20260402/health.yml: digest drift for runtime_route_bundle: expected sha256:ab0ce11465025a09173e268b98884038dc91a3153b2bbba00e4450999d63f395, got sha256:27971f3631b0ac22cc738dccbda5b0c72b5656bd454dd0b4f496585b1bd9d5c1
    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-safe-stage-lease-revocation-exercise-20260402/health.yml: digest drift for pack_routes: expected sha256:dcc8c5a6cbcfc6ea5b3844b6771117adc1cb1fcaa05ff243419b951a958535f1, got sha256:8239696b818b859f8119999dad8b45ba6c3a3859de8b02a79f753566542388dd
    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-validate-proposal-20260331-b/health.yml: digest drift for runtime_route_bundle: expected sha256:ab0ce11465025a09173e268b98884038dc91a3153b2bbba00e4450999d63f395, got sha256:27971f3631b0ac22cc738dccbda5b0c72b5656bd454dd0b4f496585b1bd9d5c1
    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-validate-proposal-20260331-b/health.yml: digest drift for pack_routes: expected sha256:dcc8c5a6cbcfc6ea5b3844b6771117adc1cb1fcaa05ff243419b951a958535f1, got sha256:8239696b818b859f8119999dad8b45ba6c3a3859de8b02a79f753566542388dd
    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-validate-proposal-20260331-success-3/health.yml: digest drift for runtime_route_bundle: expected sha256:ab0ce11465025a09173e268b98884038dc91a3153b2bbba00e4450999d63f395, got sha256:27971f3631b0ac22cc738dccbda5b0c72b5656bd454dd0b4f496585b1bd9d5c1
    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-validate-proposal-20260331-success-3/health.yml: digest drift for pack_routes: expected sha256:dcc8c5a6cbcfc6ea5b3844b6771117adc1cb1fcaa05ff243419b951a958535f1, got sha256:8239696b818b859f8119999dad8b45ba6c3a3859de8b02a79f753566542388dd
    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-validate-proposal-20260401-agent-augmented-3/health.yml: digest drift for runtime_route_bundle: expected sha256:ab0ce11465025a09173e268b98884038dc91a3153b2bbba00e4450999d63f395, got sha256:27971f3631b0ac22cc738dccbda5b0c72b5656bd454dd0b4f496585b1bd9d5c1
    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-validate-proposal-20260401-agent-augmented-3/health.yml: digest drift for pack_routes: expected sha256:dcc8c5a6cbcfc6ea5b3844b6771117adc1cb1fcaa05ff243419b951a958535f1, got sha256:8239696b818b859f8119999dad8b45ba6c3a3859de8b02a79f753566542388dd
    [ERROR] negative controls skipped because no valid health file exists
    Validation summary: errors=195


### validate-architecture-conformance

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh
```

exit_code: 1
log: .octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T07-19-47Z/logs/validate-architecture-conformance.log

    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-safe-stage-lease-revocation-exercise-20260402/health.yml: digest drift for pack_routes: expected sha256:dcc8c5a6cbcfc6ea5b3844b6771117adc1cb1fcaa05ff243419b951a958535f1, got sha256:8239696b818b859f8119999dad8b45ba6c3a3859de8b02a79f753566542388dd
    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-validate-proposal-20260331-b/health.yml: digest drift for runtime_route_bundle: expected sha256:ab0ce11465025a09173e268b98884038dc91a3153b2bbba00e4450999d63f395, got sha256:27971f3631b0ac22cc738dccbda5b0c72b5656bd454dd0b4f496585b1bd9d5c1
    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-validate-proposal-20260331-b/health.yml: digest drift for pack_routes: expected sha256:dcc8c5a6cbcfc6ea5b3844b6771117adc1cb1fcaa05ff243419b951a958535f1, got sha256:8239696b818b859f8119999dad8b45ba6c3a3859de8b02a79f753566542388dd
    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-validate-proposal-20260331-success-3/health.yml: digest drift for runtime_route_bundle: expected sha256:ab0ce11465025a09173e268b98884038dc91a3153b2bbba00e4450999d63f395, got sha256:27971f3631b0ac22cc738dccbda5b0c72b5656bd454dd0b4f496585b1bd9d5c1
    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-validate-proposal-20260331-success-3/health.yml: digest drift for pack_routes: expected sha256:dcc8c5a6cbcfc6ea5b3844b6771117adc1cb1fcaa05ff243419b951a958535f1, got sha256:8239696b818b859f8119999dad8b45ba6c3a3859de8b02a79f753566542388dd
    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-validate-proposal-20260401-agent-augmented-3/health.yml: digest drift for runtime_route_bundle: expected sha256:ab0ce11465025a09173e268b98884038dc91a3153b2bbba00e4450999d63f395, got sha256:27971f3631b0ac22cc738dccbda5b0c72b5656bd454dd0b4f496585b1bd9d5c1
    [ERROR] /Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/materialized/runs/uec-validate-proposal-20260401-agent-augmented-3/health.yml: digest drift for pack_routes: expected sha256:dcc8c5a6cbcfc6ea5b3844b6771117adc1cb1fcaa05ff243419b951a958535f1, got sha256:8239696b818b859f8119999dad8b45ba6c3a3859de8b02a79f753566542388dd
    [ERROR] negative controls skipped because no valid health file exists
    Validation summary: errors=195
    [ERROR] run-health read-model validation failed
    [OK] Context Pack Builder validation passed
    Validation summary: errors=2



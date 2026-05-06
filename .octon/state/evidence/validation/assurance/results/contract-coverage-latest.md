# Contract Coverage and Boundary Report

- generated_utc: 2026-05-06T02:41:13Z
- status: FAIL
- contracts_indexed: 8
- missing_metadata: 0
- missing_contract_paths: 0
- missing_enforcement_bindings: 0
- ops_boundary_violations: 12

## Coverage Table

| Contract ID | Owner | Version | Contract Path | Enforcement Paths | Status | Notes |
|---|---|---|---|---:|---|---|
| OCTON-SPEC-014 | cognition | 1.1.0 | ../../../framework/cognition/_meta/architecture/runtime-vs-ops-contract.md | 2 | PASS | ok |
| OCTON-SPEC-015 | cognition | 1.1.0 | ../../../framework/cognition/_meta/architecture/specification.md | 1 | PASS | ok |
| OCTON-SPEC-016 | cognition | 1.1.0 | ../../../framework/cognition/_meta/architecture/specification.md | 1 | PASS | ok |
| OCTON-SPEC-017 | cognition | 1.1.0 | ../../../framework/cognition/_meta/architecture/specification.md | 1 | PASS | ok |
| ASSURANCE-PRECEDENCE-001 | assurance | 1.1.0 | ../../../framework/assurance/governance/precedence.md | 2 | PASS | ok |
| ENGINE-GOV-001 | engine | 1.1.0 | ../../../framework/engine/governance/README.md | 1 | PASS | ok |
| ENGINE-GOV-002 | engine | 1.0.0 | ../../../framework/engine/governance/instruction-layer-precedence.md | 1 | PASS | ok |
| OPS-MUTATION-001 | cognition | 1.1.0 | ../../../framework/cognition/_meta/architecture/runtime-vs-ops-contract.md | 1 | PASS | ok |

##  Boundary Violations
- `.octon/framework/assurance/runtime/_ops/fixtures/authorized-effect-token-enforcement/README.md`: canonical artifact under _ops/
- `.octon/framework/assurance/runtime/_ops/fixtures/run-lifecycle-v1/README.md`: canonical artifact under _ops/
- `.octon/framework/assurance/runtime/_ops/fixtures/run-health-read-model/README.md`: canonical artifact under _ops/
- `.octon/framework/assurance/runtime/_ops/fixtures/support-envelope-reconciliation/README.md`: canonical artifact under _ops/
- `.octon/framework/assurance/runtime/_ops/fixtures/engagement-change-package-compiler-v1/valid/.octon/framework/constitution/contracts/registry.yml`: canonical artifact under _ops/
- `.octon/framework/assurance/runtime/_ops/fixtures/engagement-change-package-compiler-v1/valid/.octon/instance/governance/connectors/README.md`: canonical artifact under _ops/
- `.octon/framework/assurance/runtime/_ops/fixtures/engagement-change-package-compiler-v1/valid/.octon/instance/governance/connectors/README.md`: governance artifact nested under _ops/
- `.octon/framework/assurance/runtime/_ops/fixtures/engagement-change-package-compiler-v1/valid/.octon/instance/governance/connectors/posture.yml`: governance artifact nested under _ops/
- `.octon/framework/assurance/runtime/_ops/fixtures/engagement-change-package-compiler-v1/valid/.octon/instance/governance/policies/evidence-profiles.yml`: governance artifact nested under _ops/
- `.octon/framework/assurance/runtime/_ops/fixtures/engagement-change-package-compiler-v1/valid/.octon/instance/governance/policies/engagement-change-package-compiler.yml`: governance artifact nested under _ops/
- `.octon/framework/assurance/runtime/_ops/fixtures/engagement-change-package-compiler-v1/valid/.octon/instance/governance/policies/preflight-evidence-lane.yml`: governance artifact nested under _ops/
- `.octon/framework/assurance/runtime/_ops/fixtures/engagement-change-package-compiler-v1/README.md`: canonical artifact under _ops/

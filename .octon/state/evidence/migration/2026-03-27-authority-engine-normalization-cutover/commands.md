# Wave 2 Command Log

- `cargo check --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-mission-runtime-contracts.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-repo-instance-boundary.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-authoritative-doc-triggers.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-authority-control-tooling.sh`
- `rg -n "state/control/execution/exception-leases\\.yml|OCTON_EXECUTION_HUMAN_APPROVED|accept:human|ai-gate:waive|approval_request_ref|approval_grant_refs|materialize-pr-authority\\.sh" .github .octon/framework .octon/instance -g '!**/inputs/exploratory/**'`
- `rg -n "state/control/execution/(approvals|exceptions|revocations)|framework/constitution/contracts/authority|support-targets\\.yml|support_status|requires_mission" .octon -g '!**/inputs/exploratory/**'`

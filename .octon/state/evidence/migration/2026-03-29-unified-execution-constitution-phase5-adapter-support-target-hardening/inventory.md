# Phase 5 Change Inventory

## Summary

- Hardened constitutional adapter schemas and runtime adapter manifests.
- Added canonical host adapters for CI and Studio.
- Added governed capability-pack contracts and repo-local pack admission.
- Published an explicit support-target matrix with allowed capability packs.
- Extended runtime authorization, validators, and CI to fail closed on
  unsupported tuples, broken adapter manifests, and unadmitted packs.

## Adapter Contract Hardening

- Updated:
  - `/.octon/framework/constitution/contracts/adapters/{README.md,family.yml,host-adapter-v1.schema.json,model-adapter-v1.schema.json}`
  - `/.octon/framework/engine/runtime/adapters/host/{README.md,repo-shell.yml,github-control-plane.yml}`
  - `/.octon/framework/engine/runtime/adapters/model/{README.md,repo-local-governed.yml,experimental-external.yml}`
- Added:
  - `/.octon/framework/constitution/contracts/adapters/capability-pack-v1.schema.json`
  - `/.octon/framework/engine/runtime/adapters/host/ci-control-plane.yml`
  - `/.octon/framework/engine/runtime/adapters/host/studio-control-plane.yml`

## Support-Target Matrix And Pack Admission

- Updated:
  - `/.octon/instance/governance/support-targets.yml`
  - `/.octon/framework/constitution/contracts/registry.yml`
  - `/.octon/framework/constitution/precedence/normative.yml`
  - `/.octon/framework/engine/runtime/{config/policy-interface.yml,spec/policy-interface-v1.md,spec/execution-authorization-v1.md}`
  - `/.octon/octon.yml`
- Added:
  - `/.octon/framework/capabilities/packs/**`
  - `/.octon/instance/capabilities/runtime/packs/**`
  - `support-target-admission.md`
  - `adapter-conformance-model.md`

## Runtime And Validation Enforcement

- Updated:
  - `/.octon/framework/engine/runtime/crates/kernel/src/{authorization.rs,pipeline.rs,workflow.rs}`
  - `/.octon/framework/assurance/runtime/_ops/scripts/{validate-wave5-agency-adapter-hardening.sh,validate-harness-structure.sh,validate-execution-governance.sh}`
  - `/.github/workflows/architecture-conformance.yml`
- Added:
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-phase5-adapter-support-target-hardening.sh`

## Phase 5 Exit Status

- Support-target matrix published and enforced: satisfied by the updated
  support-target declaration, runtime authorization, and Phase 5 validator.
- New support tiers require adapter conformance evidence: satisfied by the
  richer adapter manifests plus runtime cross-checking of conformance suites
  and criteria refs.
- Unsupported tuples fail closed: satisfied by kernel tests covering undeclared
  hosts, invalid model manifests, and unadmitted API packs.

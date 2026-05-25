# Implementation Run Receipt

verdict: pass
implemented_at: 2026-05-15T21:20:54Z
promotion_evidence_count: 11

## Profile Selection Receipt

release_state: pre-1.0
change_profile: atomic
transitional_exception_note: not authorized

## Durable Changes

- Added `agent-node-v1` runtime narrative and schema under `.octon/framework/engine/runtime/spec/`.
- Added `model-call-receipt-v1` runtime narrative and schema under `.octon/framework/engine/runtime/spec/`.
- Added constitutional runtime schema mirrors for agent nodes and model-call receipts.
- Registered the new runtime contract family entries in `.octon/framework/constitution/contracts/runtime/family.yml` and documented the final authority boundary in `.octon/framework/constitution/contracts/runtime/README.md`.
- Added `.octon/instance/governance/policies/model-call-routing.yml` and documented it in the instance policy index.
- Added `validate-agent-node-model-call-contract.sh` with positive fixtures, negative controls, context-pack fixture validation, proposal-path non-authority checks, generated non-authority checks, and model-call routing, budget, fallback, retry, cost/usage, output-validation, and replay-envelope checks.

## Retained Evidence

- `.octon/state/evidence/validation/proposals/agent-node-model-call-contract/20260515T211056Z/implementation-evidence.md`
- `.octon/state/evidence/validation/proposals/agent-node-model-call-contract/20260515T211056Z/fixtures/agent-node-model-call/agent-node-positive.json`
- `.octon/state/evidence/validation/proposals/agent-node-model-call-contract/20260515T211056Z/fixtures/agent-node-model-call/model-call-receipt-positive.json`
- `.octon/state/evidence/validation/proposals/agent-node-model-call-contract/20260515T211056Z/fixtures/context-pack-positive/context-pack.json`
- `.octon/state/evidence/validation/proposals/agent-node-model-call-contract/20260515T211056Z/fixtures/context-pack-positive/context-pack-receipt.json`

## Validators Run

- `jq empty .octon/framework/engine/runtime/spec/agent-node-v1.schema.json .octon/framework/engine/runtime/spec/model-call-receipt-v1.schema.json .octon/framework/constitution/contracts/runtime/agent-node-v1.schema.json .octon/framework/constitution/contracts/runtime/model-call-receipt-v1.schema.json` - pass.
- `bash -n .octon/framework/assurance/runtime/_ops/scripts/validate-agent-node-model-call-contract.sh` - pass.
- `yq -e '.' .octon/framework/constitution/contracts/runtime/family.yml .octon/instance/governance/policies/model-call-routing.yml` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-agent-node-model-call-contract.sh --evidence-root .octon/state/evidence/validation/proposals/agent-node-model-call-contract/20260515T211056Z` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-context-pack-builder.sh --pack .octon/state/evidence/validation/proposals/agent-node-model-call-contract/20260515T211056Z/fixtures/context-pack-positive/context-pack.json --receipt .octon/state/evidence/validation/proposals/agent-node-model-call-contract/20260515T211056Z/fixtures/context-pack-positive/context-pack-receipt.json --root .` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract --require-implementation-authorization` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-transition-coverage.sh` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-workflow-statechart-harness.sh` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-authorized-effect-token-enforcement.sh` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-contract-family-version-coherence.sh` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-docs-consistency.sh` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-no-raw-generated-effective-runtime-reads.sh` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-v1.sh` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract` - pass with one non-blocking inventory warning for newly written support receipts.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract` - pass with one non-blocking excluded assurance-script terminology scan warning.
- `(cd .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract && shasum -a 256 -c SHA256SUMS.txt)` - pass.

## Rollback Posture

Rollback is bounded to removing the new agent-node and model-call runtime specs, constitutional schema mirrors, model-call routing policy, and child-specific validator, and reverting the runtime contract family and policy README updates. Existing Run Lifecycle v1, Workflow Statechart v1, Task-Specific Execution Harness v1, Execution Authorization v1, Context Pack Builder v1, Authorized Effect Token v1, Evidence Store v1, support-target, model-adapter, connector admission, and fail-closed contracts remain canonical.

## Blockers

None.

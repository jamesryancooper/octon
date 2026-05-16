# Agent Node Model Call Contract Implementation Evidence

implemented_at: 2026-05-15T21:20:54Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract
route_id: run-packet-implementation
release_state: pre-1.0
change_profile: atomic
transitional_exception_note: not authorized

## Files Changed

- `.octon/framework/engine/runtime/spec/agent-node-v1.md`
- `.octon/framework/engine/runtime/spec/agent-node-v1.schema.json`
- `.octon/framework/engine/runtime/spec/model-call-receipt-v1.md`
- `.octon/framework/engine/runtime/spec/model-call-receipt-v1.schema.json`
- `.octon/framework/constitution/contracts/runtime/agent-node-v1.schema.json`
- `.octon/framework/constitution/contracts/runtime/model-call-receipt-v1.schema.json`
- `.octon/framework/constitution/contracts/runtime/family.yml`
- `.octon/framework/constitution/contracts/runtime/README.md`
- `.octon/instance/governance/policies/model-call-routing.yml`
- `.octon/instance/governance/policies/README.md`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-agent-node-model-call-contract.sh`

## Validation Commands

- `jq empty .octon/framework/engine/runtime/spec/agent-node-v1.schema.json .octon/framework/engine/runtime/spec/model-call-receipt-v1.schema.json .octon/framework/constitution/contracts/runtime/agent-node-v1.schema.json .octon/framework/constitution/contracts/runtime/model-call-receipt-v1.schema.json` - pass.
- `bash -n .octon/framework/assurance/runtime/_ops/scripts/validate-agent-node-model-call-contract.sh` - pass.
- `yq -e '.' .octon/framework/constitution/contracts/runtime/family.yml .octon/instance/governance/policies/model-call-routing.yml` - pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-agent-node-model-call-contract.sh --evidence-root .octon/state/evidence/validation/proposals/agent-node-model-call-contract/20260515T211056Z` - pass.
- `CONTEXT_FIXTURE_DIR='.octon/state/evidence/validation/proposals/agent-node-model-call-contract/20260515T211056Z/fixtures/context-pack-positive' bash .octon/framework/assurance/runtime/_ops/scripts/validate-context-pack-builder.sh --pack "$CONTEXT_FIXTURE_DIR/context-pack.json" --receipt "$CONTEXT_FIXTURE_DIR/context-pack-receipt.json" --root .` - pass.
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

## Search Evidence

- Exact scan for `agent-node-model-call-contract` and proposal input roots across approved durable targets found no active runtime, policy, support, control, or closeout dependency on the proposal path. Hits are limited to contract naming, validator command naming, and existing generic proposal-validation scripts.
- Boundary scan for agent-owned authority, generated authority, proposal authority, live Durable Object, live MCP, external workflow, and universal replay terms found expected negative-control language only. The new policy explicitly denies generated projection authority and excludes universal replay guarantees.
- The post-implementation drift validator's assurance-script terminology warning is limited to existing generic validation logic under `.octon/framework/assurance/runtime/_ops/scripts/`; the promoted agent-node and model-call contract terminology does not introduce `Work Package` language.

## Fixture Evidence

- Positive agent-node fixture: `fixtures/agent-node-model-call/agent-node-positive.json`
- Positive model-call receipt fixture: `fixtures/agent-node-model-call/model-call-receipt-positive.json`
- Positive context-pack fixture: `fixtures/context-pack-positive/context-pack.json`
- Positive context-pack receipt fixture: `fixtures/context-pack-positive/context-pack-receipt.json`

The child-specific validator also exercises negative controls for missing harness binding, generated workflow authority, transition authority claims, forbidden authority claims, missing context receipt, wrong routing policy, missing cost/usage receipt, raw-input context authority, model output closeout authority, and universal replay claims.

## Publication Posture

No generated/effective outputs were changed or published. This packet authorizes durable runtime specs, constitutional runtime contracts, instance governance policy, and assurance validation only.

## Rollback Posture

Rollback is bounded to removing the eight new durable files and reverting the three modified durable files listed above. Retained evidence should remain as the audit trail for the rollback decision.

## Blockers

None.

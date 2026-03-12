# PATCHPLAN: Context Governance Clean-Break Migration

## Scope

Execute a clean-break migration for:

1. Instruction-layer precedence as an enforceable engine contract.
2. Default-deny developer-layer context artifacts with minimal, bounded requirements.
3. Receipt-driven context-acquisition overhead telemetry and policy enforcement.

## Clean-Break Contract (Non-Negotiable)

1. One cutover event: after cutover, only the new governance path may execute.
2. No compatibility shims/adapters/translators.
3. No dual-mode old/new runtime branching.
4. No transitional flags preserving legacy behavior.
5. Legacy behavior and references removed in the same migration (code, docs, contracts, tests, call-sites).
6. Rollback strategy is full-revert-only for the cutover range.

## Explicit Legacy Removal Targets

1. Material-run paths that do not emit instruction-layer manifest metadata.
2. Material-run paths that do not emit context-acquisition counters.
3. Developer-layer context acceptance outside the new allowlist/shape constraints.
4. Receipt/provenance logic that tolerates missing instruction-layer or acquisition fields.
5. Any schema/contract aliases retained only for backward compatibility.

## New SSOT Targets

1. `/.harmony/engine/governance/instruction-layer-precedence.md`
2. `/.harmony/engine/runtime/spec/instruction-layer-manifest-v1.schema.json`
3. `/.harmony/capabilities/governance/policy/deny-by-default.v2.yml`
4. `/.harmony/engine/runtime/spec/policy-receipt-v1.schema.json`
5. `/.harmony/capabilities/governance/policy/acp-provenance-fields.schema.json`
6. Assurance validators and workflow verification gates that fail closed on missing required fields.

## Phased Delivery (No Reordering)

### Phase 0: Migration Bootstrap

1. Create canonical runtime migration record (`plan.md`) from clean-break template.
2. Register migration in runtime migration index.
3. Create evidence-bundle skeleton (`bundle.yml`, `evidence.md`, `commands.md`, `validation.md`, `inventory.md`).

### Phase 1: Pre-Cutover Hardening

1. Add contracts/schemas/specs for instruction-layer manifests and context-acquisition telemetry.
2. Add policy gates and assurance validators.
3. Update scaffolding/services/workflows/continuity surfaces to consume the new model.

### Phase 2: Atomic Cutover

1. Remove remaining compatibility keys and legacy execution branches in policy/runtime/receipt paths.
2. Enforce one authoritative execution path for instruction manifests and acquisition counters.
3. Confirm no material-run path can bypass required telemetry.

### Phase 3: Anti-Regression and Closure

1. Add context-governance legacy identifiers to `legacy-banlist.md`.
2. Update CI gate contract coverage so reintroduction fails closed.
3. Execute integrated validators and record receipts in evidence bundle.
4. Mark migration plan definition-of-done items complete with evidence links.

## Required Artifacts

1. Runtime migration plan:
   - `/.harmony/cognition/runtime/migrations/2026-02-25-context-governance-clean-break/plan.md`
2. Task breakdown:
   - `/.harmony/output/reports/analysis/2026-02-25-context-governance-integration-task-breakdown.md`
3. Evidence bundle:
   - `/.harmony/output/reports/migrations/2026-02-25-context-governance-clean-break/`
   - required files: `bundle.yml`, `evidence.md`, `commands.md`, `validation.md`, `inventory.md`

## Verification Matrix

1. Static: contract/schema lint + no legacy aliases in migrated surfaces.
2. Runtime: mandatory instruction-layer manifest emission + mandatory context-acquisition counters.
3. Policy: deny-by-default strict validation passes.
4. Orchestration/assurance: workflow and alignment gates fail closed on missing evidence.
5. Migration governance: plan/index/evidence-bundle integrity is complete.

## Exit Criteria

1. Exactly one execution path remains for instruction-layer manifests and context-overhead telemetry.
2. Legacy paths/tokens are removed and banlisted.
3. Contracts/docs/workflows reference only the new model.
4. Integrated validators pass in strict mode.
5. Migration evidence bundle contains command receipts proving cutover and anti-regression.

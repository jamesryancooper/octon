# Task Breakdown: Context Governance Integration (Clean-Break Migration)

Date: 2026-02-25  
Migration ID: `2026-02-25-context-governance-clean-break`  
Scope: Integrate the three approved initiatives:
1. Instruction-layer precedence as a contract (observable/local layers only)
2. Default-deny developer-layer context artifacts (minimal requirements only)
3. Receipt-driven context exploration and overhead telemetry

## Clean-Break Mode (Mandatory)

1. Single cutover event only: post-cutover execution must use only the new context-governance path.
2. No compatibility shims/adapters, no dual-mode branching, no transitional flags.
3. Legacy surfaces (code, contracts, docs, tests, and call-sites) are removed in the same migration.
4. Rollback strategy is full-revert-only for the cutover change set.
5. Migration must update banlist and CI enforcement to prevent reintroduction.

## Execution Constraints

1. Do not modify `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/cognition/governance/principles/principles.md` (immutable charter).
2. Run the verification command immediately after each step before continuing.
3. If a verification command fails, fix that step before moving forward.
4. Do not reorder steps; this sequence is cutover-dependent.

## Step 00: Bootstrap Clean-Break Migration Record and Evidence Bundle

Owner: `continuity-governance`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/cognition/runtime/migrations/2026-02-25-context-governance-clean-break/plan.md` (new)
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/cognition/runtime/migrations/index.yml`
3. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/output/reports/migrations/2026-02-25-context-governance-clean-break/bundle.yml` (new)
4. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/output/reports/migrations/2026-02-25-context-governance-clean-break/evidence.md` (new)
5. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/output/reports/migrations/2026-02-25-context-governance-clean-break/commands.md` (new)
6. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/output/reports/migrations/2026-02-25-context-governance-clean-break/validation.md` (new)
7. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/output/reports/migrations/2026-02-25-context-governance-clean-break/inventory.md` (new)

Exact edit order:
1. Create runtime migration `plan.md` from clean-break template with explicit removed/new SSOT lists.
2. Register migration record in runtime migrations index.
3. Create the five required evidence-bundle files with placeholder headings.

Verification command:

```bash
test -f .octon/cognition/runtime/migrations/2026-02-25-context-governance-clean-break/plan.md && \
rg -n '2026-02-25-context-governance-clean-break' .octon/cognition/runtime/migrations/index.yml && \
for f in bundle.yml evidence.md commands.md validation.md inventory.md; do test -f ".octon/output/reports/migrations/2026-02-25-context-governance-clean-break/$f"; done
```

## Step 01: Define Instruction-Layer Contract Surface

Owner: `engine-governance`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/engine/governance/instruction-layer-precedence.md` (new)
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/engine/governance/README.md`
3. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/cognition/_meta/architecture/specification.md`
4. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/cognition/runtime/context/index.yml`

Exact edit order:
1. Create the engine governance contract for observable instruction layers and precedence.
2. Add the new contract to engine governance README contract list.
3. Add/adjust architecture references to the new contract.
4. Register the contract in cognition context contract registry metadata.

Verification command:

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-contract-governance.sh
```

## Step 02: Add Instruction-Layer Manifest Schema and Interface Hooks

Owner: `engine-runtime`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/engine/runtime/spec/instruction-layer-manifest-v1.schema.json` (new)
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/engine/runtime/spec/policy-interface-v1.md`
3. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/engine/runtime/spec/policy-digest-v1.md`

Exact edit order:
1. Create manifest schema with required fields (`layer_id`, `source`, `sha256`, `bytes`, `visibility`).
2. Update policy interface spec to require manifest emission behavior for material runs.
3. Update digest spec to document instruction-layer summary fields.

Verification command:

```bash
jq -e . .octon/engine/runtime/spec/instruction-layer-manifest-v1.schema.json >/dev/null && \
bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh
```

## Step 03: Extend Receipt/Provenance Schemas and Receipt Writer (No Compatibility Keys)

Owner: `engine-runtime`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/engine/runtime/spec/policy-receipt-v1.schema.json`
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/governance/policy/acp-provenance-fields.schema.json`
3. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/_ops/scripts/policy-receipt-write.sh`

Exact edit order:
1. Add required `instruction_layers` and context-acquisition fields to policy receipt schema.
2. Add matching required fields to ACP provenance schema.
3. Update receipt writer to emit only new required fields and fail closed on missing required telemetry.

Verification command:

```bash
bash -n .octon/capabilities/_ops/scripts/policy-receipt-write.sh && \
bash .octon/assurance/runtime/_ops/scripts/validate-capability-engine-consistency.sh
```

## Step 04: Add Policy Contract Controls for Context Gating and Overhead

Owner: `capabilities-policy`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/governance/policy/deny-by-default.v2.yml`
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/governance/policy/deny-by-default.v2.schema.json`

Exact edit order:
1. Add `developer_context_gate` block (allowlist, minimal sections, size limits, default hard enforcement).
2. Add `context_overhead_gate` block (thresholds, hard-fail contract for missing required counters).
3. Update schema definitions and required keys for both gate blocks.

Verification command:

```bash
bash .octon/capabilities/_ops/scripts/validate-deny-by-default.sh --all --profile strict
```

## Step 05: Emit Instruction-Layer Manifest from Runtime Policy Wrapper (Single Path)

Owner: `engine-runtime`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/engine/runtime/policy`
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/engine/runtime/config/policy-interface.yml`
3. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/engine/runtime/spec/policy-interface-v1.md`

Exact edit order:
1. Add runtime assembly/emission of observable instruction-layer manifest data for material runs.
2. Remove legacy/optional routing that allows material runs without manifest output.
3. Update interface spec semantics and examples to reflect mandatory behavior.

Verification command:

```bash
bash -n .octon/engine/runtime/policy && \
bash .octon/assurance/runtime/_ops/scripts/validate-engine-capability-boundary.sh
```

## Step 06: Add Assurance Validator for Developer Context Policy

Owner: `assurance-runtime`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/assurance/runtime/_ops/scripts/validate-developer-context-policy.sh` (new)
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/assurance/runtime/_ops/scripts/alignment-check.sh`
3. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/assurance/practices/complete.md`

Exact edit order:
1. Create validator script for allowlisted context artifacts, section limits, and size checks.
2. Add validator invocation to `alignment-check --profile harness`.
3. Add completion checklist requirement for this validator when relevant files change.

Verification command:

```bash
bash -n .octon/assurance/runtime/_ops/scripts/validate-developer-context-policy.sh && \
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness --dry-run
```

## Step 07: Align Scaffolding and Init Output with Minimal Context Rules

Owner: `scaffolding`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/scaffolding/runtime/templates/AGENTS.md`
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/scaffolding/runtime/_ops/scripts/init-project.sh`
3. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/runtime/commands/init.md`

Exact edit order:
1. Trim template structure to minimal required sections aligned to new policy.
2. Ensure init script generates only compliant developer-layer artifacts by default.
3. Update command docs to match generated output contract.

Verification command:

```bash
bash -n .octon/scaffolding/runtime/_ops/scripts/init-project.sh && \
bash .octon/assurance/runtime/_ops/scripts/validate-framing-alignment.sh
```

## Step 08: Define Context-Acquisition Telemetry Contract

Owner: `services-governance`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/practices/services-conventions/run-records.md`
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/runtime/services/execution/agent/guide.md`
3. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/runtime/services/execution/flow/guide.md`
4. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/runtime/services/interfaces/filesystem-snapshot/contract.md`
5. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/runtime/services/interfaces/filesystem-discovery/contract.md`

Exact edit order:
1. Extend run-record conventions with required `context_acquisition` and `context_overhead_ratio`.
2. Update agent execution guide with required acquisition counters.
3. Update flow execution guide with required acquisition counters.
4. Update snapshot contract observability fields.
5. Update discovery contract observability fields.

Verification command:

```bash
bash .octon/capabilities/runtime/services/_ops/scripts/validate-services.sh && \
bash .octon/capabilities/runtime/services/_ops/scripts/validate-filesystem-interfaces.sh
```

## Step 09: Implement Context-Acquisition Counter Emission in Runtime Services

Owner: `services-runtime`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/runtime/services/execution/agent/impl/agent.sh`
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/runtime/services/execution/flow/impl/flow-client.sh`
3. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/runtime/services/execution/agent/schema/output.schema.json`
4. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/runtime/services/execution/flow/schema/output.schema.json`

Exact edit order:
1. Add deterministic acquisition counters in agent runtime output.
2. Add deterministic acquisition counters in flow runtime output.
3. Extend agent output schema to include new required fields.
4. Extend flow output schema to include new required fields.

Verification command:

```bash
bash -n .octon/capabilities/runtime/services/execution/agent/impl/agent.sh && \
bash -n .octon/capabilities/runtime/services/execution/flow/impl/flow-client.sh && \
bash .octon/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh --mode services-core
```

## Step 10: Add Assurance Validator for Context Overhead Budgets

Owner: `assurance-runtime`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/assurance/runtime/_ops/scripts/validate-context-overhead-budget.sh` (new)
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/assurance/runtime/_ops/scripts/alignment-check.sh`
3. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/assurance/practices/session-exit.md`

Exact edit order:
1. Create validator for overhead thresholds and missing telemetry fields.
2. Add validator invocation to `alignment-check --profile harness`.
3. Add session-exit requirement to run the validator when runtime telemetry surfaces change.

Verification command:

```bash
bash -n .octon/assurance/runtime/_ops/scripts/validate-context-overhead-budget.sh && \
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness --dry-run
```

## Step 11: Atomic Cutover - Remove Legacy Paths and Dual-Mode Branching

Owner: `cutover-driver`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/engine/runtime/policy`
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/engine/runtime/config/policy-interface.yml`
3. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/_ops/scripts/policy-receipt-write.sh`
4. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/engine/runtime/spec/policy-receipt-v1.schema.json`
5. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/governance/policy/acp-provenance-fields.schema.json`
6. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/governance/policy/deny-by-default.v2.yml`

Exact edit order:
1. Remove remaining legacy aliases/optional keys that preserve non-manifest or non-counter execution.
2. Remove runtime branching that allows material runs without instruction-layer manifests.
3. Remove runtime branching that allows missing context-acquisition telemetry fields.
4. Set policy/interface defaults so only the new path is valid.

Verification command:

```bash
bash .octon/capabilities/_ops/scripts/validate-deny-by-default.sh --all --profile strict && \
bash .octon/assurance/runtime/_ops/scripts/validate-capability-engine-consistency.sh && \
bash .octon/assurance/runtime/_ops/scripts/validate-engine-capability-boundary.sh
```

## Step 12: Add Legacy Banlist Entries and CI Regression Controls

Owner: `governance-assurance`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/cognition/practices/methodology/migrations/legacy-banlist.md`
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/cognition/practices/methodology/migrations/ci-gates.md`
3. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/assurance/runtime/_ops/scripts/alignment-check.sh`

Exact edit order:
1. Add banlist entries for removed context-governance legacy identifiers/paths.
2. Update CI gate doctrine notes for these new banned identifiers.
3. Ensure alignment profile includes enforcement checks needed for this migration.

Verification command:

```bash
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness && \
rg -n 'context-governance-clean-break|instruction-layer|context-acquisition' .octon/cognition/practices/methodology/migrations/legacy-banlist.md
```

## Step 13: Bind New Gates into Audit/Release Workflows

Owner: `orchestration`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/orchestration/runtime/workflows/audit/audit-pre-release-workflow/WORKFLOW.md`
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/orchestration/runtime/workflows/audit/audit-pre-release-workflow/08-verify.md`
3. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/orchestration/runtime/workflows/registry.yml`

Exact edit order:
1. Add explicit verification criteria for instruction-layer manifests and context gates.
2. Update pre-release verify step to fail on missing required evidence.
3. Sync workflow registry metadata and outputs.

Verification command:

```bash
bash .octon/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
```

## Step 14: Update Continuity/Assurance Surfaces and Fixtures

Owner: `continuity-assurance-test`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/continuity/_meta/architecture/continuity-plane.md`
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/continuity/_meta/architecture/runs-retention.md`
3. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/assurance/practices/complete.md`
4. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/assurance/practices/session-exit.md`
5. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/engine/_meta/evidence/verification-scenarios.md`
6. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/runtime/services/execution/agent/fixtures/edge.json`
7. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/runtime/services/execution/flow/fixtures/edge.json`
8. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/capabilities/runtime/services/interfaces/agent-platform/fixtures/edge.json`

Exact edit order:
1. Add run-evidence expectations for instruction-layer manifests and context-overhead metadata.
2. Update retention and checklists for new validators/evidence.
3. Add verification scenarios for manifest completeness and gate outcomes.
4. Add fixture coverage for context-acquisition counters and threshold classification.

Verification command:

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-continuity-memory.sh && \
bash .octon/capabilities/runtime/services/_ops/scripts/validate-services.sh && \
bash .octon/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh --mode all
```

## Step 15: Final Integrated Gate Pass and Evidence Closure

Owner: `release-driver`  
File list:
1. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/output/reports/migrations/2026-02-25-context-governance-clean-break/commands.md`
2. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/output/reports/migrations/2026-02-25-context-governance-clean-break/validation.md`
3. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/output/reports/migrations/2026-02-25-context-governance-clean-break/evidence.md`
4. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/output/reports/migrations/2026-02-25-context-governance-clean-break/inventory.md`
5. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/output/reports/migrations/2026-02-25-context-governance-clean-break/bundle.yml`
6. `/Users/jamesryancooper/.codex/worktrees/531f/octon/.octon/cognition/runtime/migrations/2026-02-25-context-governance-clean-break/plan.md`

Exact edit order:
1. Execute full integrated validations after all previous steps are complete.
2. Record command receipts and outcomes in bundle files.
3. Update migration `plan.md` verification and definition-of-done sections with links to evidence.

Verification command:

```bash
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,services,workflows,skills && \
bash .octon/capabilities/_ops/scripts/validate-deny-by-default.sh --all --profile strict
```

## Suggested Execution Sequence (No Reordering)

`Step 00 -> Step 01 -> Step 02 -> Step 03 -> Step 04 -> Step 05 -> Step 06 -> Step 07 -> Step 08 -> Step 09 -> Step 10 -> Step 11 -> Step 12 -> Step 13 -> Step 14 -> Step 15`

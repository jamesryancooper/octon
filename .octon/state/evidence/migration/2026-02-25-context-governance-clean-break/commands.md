# Commands

All verification commands executed from:
`/Users/jamesryancooper/.codex/worktrees/531f/octon`

## Step 00 Bootstrap

```bash
test -f .octon/instance/cognition/context/shared/migrations/2026-02-25-context-governance-clean-break/plan.md && \
rg -n '2026-02-25-context-governance-clean-break' .octon/instance/cognition/context/shared/migrations/index.yml && \
for f in bundle.yml evidence.md commands.md validation.md inventory.md; do test -f ".octon/state/evidence/migration/2026-02-25-context-governance-clean-break/$f"; done
```

Result: PASS

## Step 01 Contract Surface

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-contract-governance.sh
```

Result: PASS

## Step 02 Schema and Interface

```bash
jq -e . .octon/framework/engine/runtime/spec/instruction-layer-manifest-v1.schema.json >/dev/null && \
bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh
```

```bash
bash .octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh
```

Result: PASS (post-sync)

## Step 03 Receipt/Provenance

```bash
bash -n .octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh && \
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-engine-consistency.sh
```

Result: PASS

## Step 04 Context Gate Policy

```bash
bash .octon/framework/capabilities/_ops/scripts/validate-deny-by-default.sh --all --profile strict
```

Result: PASS

## Step 05 Runtime Manifest Emission

```bash
bash -n .octon/framework/engine/runtime/policy && \
bash .octon/framework/assurance/runtime/_ops/scripts/validate-engine-capability-boundary.sh
```

Result: PASS

## Step 06 Developer Context Validator

```bash
bash -n .octon/framework/assurance/runtime/_ops/scripts/validate-developer-context-policy.sh && \
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness --dry-run
```

Result: PASS

## Step 07 Scaffolding Alignment

```bash
bash -n .octon/framework/scaffolding/runtime/_ops/scripts/init-project.sh && \
bash .octon/framework/assurance/runtime/_ops/scripts/validate-framing-alignment.sh
```

Result: PASS

## Step 08 Telemetry Contract

```bash
bash .octon/framework/capabilities/runtime/services/_ops/scripts/validate-services.sh && \
bash .octon/framework/capabilities/runtime/services/_ops/scripts/validate-filesystem-interfaces.sh
```

Result: PASS

## Step 09 Telemetry Runtime Emission

```bash
bash -n .octon/framework/capabilities/runtime/services/execution/agent/impl/agent.sh && \
bash -n .octon/framework/capabilities/runtime/services/execution/flow/impl/flow-client.sh && \
bash .octon/framework/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh --mode services-core
```

Result: PASS

## Step 10 Overhead Budget Validator

```bash
bash -n .octon/framework/assurance/runtime/_ops/scripts/validate-context-overhead-budget.sh && \
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness --dry-run
```

Result: PASS

## Step 11 Atomic Cutover Hardening

```bash
bash .octon/framework/capabilities/_ops/scripts/validate-deny-by-default.sh --all --profile strict && \
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-engine-consistency.sh && \
bash .octon/framework/assurance/runtime/_ops/scripts/validate-engine-capability-boundary.sh
```

Result: PASS

## Step 12 Banlist and CI Controls

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness && \
rg -n 'context-governance-clean-break|instruction-layer|context-acquisition' .octon/framework/cognition/practices/methodology/migrations/legacy-banlist.md
```

Result: PASS

## Step 13 Workflow Binding

```bash
bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
```

Result: PASS

## Step 14 Continuity/Assurance/Fixtures

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-continuity-memory.sh && \
bash .octon/framework/capabilities/runtime/services/_ops/scripts/validate-services.sh && \
bash .octon/framework/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh --mode all
```

Result: PASS

## Step 15 Final Integrated Gate

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,services,workflows,skills && \
bash .octon/framework/capabilities/_ops/scripts/validate-deny-by-default.sh --all --profile strict
```

Result: PASS (`exit=0`)

Key receipt lines:

- `Alignment check summary: errors=0`
- `All checks passed!`
- `Runtime deny-by-default tests complete: 44 passed, 0 failed`

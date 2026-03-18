# Commands

## Step 5 / Workflow Cutover Validation

```bash
bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
```

## Step 6 / Versioning Contract Validation

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-version-contract.sh
```

## Step 7 / SSOT Drift Validation

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-ssot-precedence-drift.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
```

## Runtime Artifact Synchronization

```bash
bash .octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh
```

## Core Governance / Assurance Gates

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-engine-consistency.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness
```

## Deny-by-Default Contract Validation

```bash
.octon/framework/engine/runtime/policy doctor \
  --policy .octon/framework/capabilities/governance/policy/deny-by-default.v2.yml \
  --schema .octon/framework/capabilities/governance/policy/deny-by-default.v2.schema.json \
  --reason-codes .octon/framework/capabilities/governance/policy/reason-codes.md

bash .octon/framework/capabilities/_ops/scripts/validate-deny-by-default.sh \
  --all --profile strict --skip-runtime-tests
```

## Policy Engine Test Sweep (Targeted)

```bash
cargo test -q --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p policy_engine --lib
```

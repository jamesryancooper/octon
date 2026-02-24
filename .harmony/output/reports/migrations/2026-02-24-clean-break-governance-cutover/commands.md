# Commands

## Step 5 / Workflow Cutover Validation

```bash
bash .harmony/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
```

## Step 6 / Versioning Contract Validation

```bash
bash .harmony/assurance/runtime/_ops/scripts/validate-harness-version-contract.sh
```

## Step 7 / SSOT Drift Validation

```bash
bash .harmony/assurance/runtime/_ops/scripts/validate-ssot-precedence-drift.sh
bash .harmony/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
```

## Runtime Artifact Synchronization

```bash
bash .harmony/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh
```

## Core Governance / Assurance Gates

```bash
bash .harmony/assurance/runtime/_ops/scripts/validate-capability-engine-consistency.sh
bash .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .harmony/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness
```

## Deny-by-Default Contract Validation

```bash
.harmony/engine/runtime/policy doctor \
  --policy .harmony/capabilities/governance/policy/deny-by-default.v2.yml \
  --schema .harmony/capabilities/governance/policy/deny-by-default.v2.schema.json \
  --reason-codes .harmony/capabilities/governance/policy/reason-codes.md

bash .harmony/capabilities/_ops/scripts/validate-deny-by-default.sh \
  --all --profile strict --skip-runtime-tests
```

## Policy Engine Test Sweep (Targeted)

```bash
cargo test -q --manifest-path .harmony/engine/runtime/crates/Cargo.toml -p policy_engine --lib
```

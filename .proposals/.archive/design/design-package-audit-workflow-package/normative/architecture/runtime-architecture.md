# Runtime Architecture

## Goal

Describe the durable Octon surfaces that implement this package.

## Layers

### 1. Package Layer

The package provides prompt assets, stage contracts, artifact rules, and
implementation guidance.

### 2. Workflow Contract Layer

`/.octon/orchestration/runtime/workflows/audit/audit-design-package/workflow.yml`
defines inputs, stages, artifacts, and done-gate checks.

### 3. Execution Layer

`/.octon/engine/runtime/crates/kernel/src/workflow.rs` resolves selected
stages, renders prompt packets, invokes the executor, and persists bundle
artifacts.

### 4. Lifecycle And Recovery Layer

The hardened package adds explicit lifecycle and recovery rules in:

- `normative/execution/run-lifecycle.md`
- `normative/execution/executor-interface.md`

These documents define run/stage states, mutation ownership, rerun semantics,
prompt packet structure, response parsing, and error classification.

### 5. Assurance Layer

The validator and runner tests assert:

- required workflow files exist
- workflow registration stays aligned
- mutation-stage receipts are present
- mock execution produces the expected bundle contract
- bundle/report schemas remain aligned to the package contract

## Data Flow

1. operator selects a target package and mode
2. workflow resolves stage sequence and bundle paths
3. the runner renders one prompt packet per selected stage
4. stage outputs feed later stages only after the required report is persisted
5. file-writing stages mutate the target package or emit exact no-op receipts
6. bundle validation computes the final verdict

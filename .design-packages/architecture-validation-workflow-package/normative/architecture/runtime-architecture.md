# Runtime Architecture

## Goal

Describe the durable Harmony surfaces that implement this package.

## Layers

### 1. Package Layer

The package provides prompt assets, stage contracts, artifact rules, and
implementation guidance.

### 2. Workflow Contract Layer

`/.harmony/orchestration/runtime/workflows/audit/audit-design-package/workflow.yml`
defines inputs, stages, artifacts, and done-gate checks.

### 3. Execution Layer

`/.harmony/engine/runtime/crates/kernel/src/workflow.rs` resolves selected
stages, renders prompt packets, invokes the executor, and persists bundle
artifacts.

### 4. Assurance Layer

The validator and runner tests assert:

- required workflow files exist
- workflow registration stays aligned
- mutation-stage receipts are present
- mock execution produces the expected bundle contract

## Data Flow

1. operator selects a target package and mode
2. workflow resolves stage sequence and bundle paths
3. stage outputs feed later stages
4. file-writing stages mutate the target package or emit exact no-op receipts
5. bundle validation computes the final verdict

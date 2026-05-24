# Target Architecture

_Status: Draft child target architecture_

## Target State

A workflow-statechart contract overlays and then converges with Run Lifecycle v1 without creating a new control root; task-specific harness compilation records bind objective, run contract, support target, capability envelope, context pack, authorization route, effect-token classes, evidence obligations, rollback or compensation posture, human-intervention posture, model/cost policy, and closeout criteria.

## Current Canonical Baseline

This child starts from the current canonical runtime and governance surfaces: Run Lifecycle v1, Execution Authorization v1, Authorized Effect Token v1, Context Pack Builder v1, Evidence Store v1, support-target governance, and fail-closed obligations. Those surfaces remain canonical unless this child or a dependent child is accepted, implemented, validated, promoted, and cut over through durable evidence.

## Authority Model Fit

The child must strengthen the existing authored-authority, state-control, retained-evidence, generated-derived, and inputs-non-authority model. It must not create a second control plane or route around current authorization and evidence obligations.

## In Scope

Statechart semantics, harness compilation records with complete required envelope bindings, binding to Run Lifecycle v1, generated diagram non-authority, validator shape, and migration-neutral compatibility with existing run contracts.

## Out Of Scope

- No external workflow engine adoption.
- No Durable Object coordination adapter.
- No agent-node/model-call contract beyond the harness slots needed by a later child.
- No runtime cutover or compatibility retirement by itself.

## Promotion Surface

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/runtime/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/generated/cognition/projections/materialized/`

## Evidence Before Claim

- Statechart schema fixtures and validator receipts.
- Harness compilation examples and negative fixtures covering every required envelope binding.
- Run Lifecycle v1 parity review evidence.

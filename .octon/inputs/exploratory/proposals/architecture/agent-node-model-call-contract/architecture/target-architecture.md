# Target Architecture

_Status: Draft child target architecture_

## Target State

Model calls can participate only as typed, finite, evidenced activity nodes inside a task-specific harness and workflow statechart; agents never own workflow state, policy, support claims, or closeout truth.

## Current Canonical Baseline

This child starts from the current canonical runtime and governance surfaces: Run Lifecycle v1, Execution Authorization v1, Authorized Effect Token v1, Context Pack Builder v1, Evidence Store v1, support-target governance, and fail-closed obligations. Those surfaces remain canonical unless this child or a dependent child is accepted, implemented, validated, promoted, and cut over through durable evidence.

## Authority Model Fit

The child must strengthen the existing authored-authority, state-control, retained-evidence, generated-derived, and inputs-non-authority model. It must not create a second control plane or route around current authorization and evidence obligations.

## In Scope

Agent-node schema, model-call receipt contract, context digest binding, allowed tools/connectors by reference, output schema validation, cost/budget posture, terminal states, and forbidden authority claims.

## Out Of Scope

- No agent-owned queues, schedules, closeout, or workflow transition authority.
- No connector/MCP permission model beyond references to later connector admission.
- No universal replay guarantee for probabilistic outputs.
- No runtime implementation claim before durable schemas and validators land.

## Promotion Surface

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/runtime/`
- `.octon/instance/governance/policies/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Evidence Before Claim

- Agent-node and model-call schema fixtures.
- Validator receipts for output validation and budget enforcement.
- Review evidence tying agent nodes to harness/statechart contracts.

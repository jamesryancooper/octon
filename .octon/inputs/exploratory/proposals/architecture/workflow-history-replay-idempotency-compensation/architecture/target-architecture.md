# Target Architecture

_Status: Draft child target architecture_

## Target State

Octon can reconstruct supported workflow histories from control journals and retained evidence, classify retry and compensation posture, and fail closed when replay or rollback evidence is insufficient.

## Current Canonical Baseline

This child starts from the current canonical runtime and governance surfaces: Run Lifecycle v1, Execution Authorization v1, Authorized Effect Token v1, Context Pack Builder v1, Evidence Store v1, support-target governance, and fail-closed obligations. Those surfaces remain canonical unless this child or a dependent child is accepted, implemented, validated, promoted, and cut over through durable evidence.

## Authority Model Fit

The child must strengthen the existing authored-authority, state-control, retained-evidence, generated-derived, and inputs-non-authority model. It must not create a second control plane or route around current authorization and evidence obligations.

## In Scope

Workflow history records, replay reconstruction reports, idempotency keys, retry classes, compensation plans, failure receipts, evidence mirrors, and validator coverage for supported workflows.

## Out Of Scope

- No universal replay of arbitrary external systems.
- No guarantee of full rollback or global transactionality.
- No external workflow-engine authority.
- No Durable Object persistence as canonical control or evidence.

## Promotion Surface

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/runtime/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/state/evidence/`

## Evidence Before Claim

- Replay reconstruction reports over sample histories.
- Idempotency/retry/compensation fixtures and validator receipts.
- Evidence-store placement receipts.

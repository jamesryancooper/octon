# Target Architecture

_Status: Draft child target architecture_

## Target State

Claims about workflow execution, agent-node participation, authorization, replay, and compensation are backed by durable evidence that is role-separated from live control truth and generated projections.

## Current Canonical Baseline

This child starts from the current canonical runtime and governance surfaces: Run Lifecycle v1, Execution Authorization v1, Authorized Effect Token v1, Context Pack Builder v1, Evidence Store v1, support-target governance, and fail-closed obligations. Those surfaces remain canonical unless this child or a dependent child is accepted, implemented, validated, promoted, and cut over through durable evidence.

## Authority Model Fit

The child must strengthen the existing authored-authority, state-control, retained-evidence, generated-derived, and inputs-non-authority model. It must not create a second control plane or route around current authorization and evidence obligations.

## In Scope

Evidence obligation deltas, provenance fields, retained evidence roots, disclosure contracts, receipt chaining, external index references, and validators.

## Out Of Scope

- No use of proposal-local artifacts as durable evidence.
- No use of generated summaries as control or evidence truth.
- No full cryptographic attestation requirement unless separately scoped.

## Promotion Surface

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/contracts/retention/`
- `.octon/framework/constitution/contracts/disclosure/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Evidence Before Claim

- Evidence obligation and retention contract diffs.
- Provenance validator receipts.
- Closeout bundle sample and negative fixtures.

# Target Architecture

_Status: Draft child target architecture_

## Target State

Every supported material side effect path either requires a verified typed effect token before mutation or is explicitly unsupported and denied with retained evidence.

## Current Canonical Baseline

This child starts from the current canonical runtime and governance surfaces: Run Lifecycle v1, Execution Authorization v1, Authorized Effect Token v1, Context Pack Builder v1, Evidence Store v1, support-target governance, and fail-closed obligations. Those surfaces remain canonical unless this child or a dependent child is accepted, implemented, validated, promoted, and cut over through durable evidence.

## Authority Model Fit

The child must strengthen the existing authored-authority, state-control, retained-evidence, generated-derived, and inputs-non-authority model. It must not create a second control plane or route around current authorization and evidence obligations.

## In Scope

Material side-effect inventory, coverage matrix, bypass-negative tests, token verification receipts, runtime crate enforcement targets, and validator scripts.

## Out Of Scope

- No widening of support targets or connector permissions.
- No replacement of Execution Authorization v1 or Authorized Effect Token v1 without validated promotion.
- No claim that all repo code paths are covered before coverage receipts prove it.

## Promotion Surface

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/engine/runtime/crates/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Evidence Before Claim

- Material side-effect inventory and coverage matrix.
- Token consumption validation reports.
- Runtime test receipts for bypass denial and valid path acceptance.

# Target Architecture

_Status: Draft child target architecture_

## Target State

Connector operations can execute only when support posture, operation admission, effect token verification, evidence retention, and trust posture agree; protocol/tool discovery remains input only.

## Current Canonical Baseline

This child starts from the current canonical runtime and governance surfaces: Run Lifecycle v1, Execution Authorization v1, Authorized Effect Token v1, Context Pack Builder v1, Evidence Store v1, support-target governance, and fail-closed obligations. Those surfaces remain canonical unless this child or a dependent child is accepted, implemented, validated, promoted, and cut over through durable evidence.

## Authority Model Fit

The child must strengthen the existing authored-authority, state-control, retained-evidence, generated-derived, and inputs-non-authority model. It must not create a second control plane or route around current authorization and evidence obligations.

## In Scope

Operation-level connector admission records, trust dossiers, support-target binding, effect-token binding, invocation receipts, denial reasons, and validators.

## Out Of Scope

- No MCP integration approval by implication.
- No Durable Object adapter implementation.
- No external workflow-engine adapter implementation.
- No support-target widening from connector availability.

## Promotion Surface

- `.octon/instance/governance/connector-admissions/`
- `.octon/instance/governance/connectors/`
- `.octon/framework/constitution/contracts/adapters/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Evidence Before Claim

- Connector admission fixtures and validator reports.
- Operation invocation receipts for accepted and denied cases.
- Support-target binding and effect-token verification receipts.

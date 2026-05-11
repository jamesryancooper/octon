# Target Architecture

_Status: Draft child target architecture_

## Target State

Octon may claim Governed Workflow Runtime canonically only after required runtime contracts, validators, receipts, implementation conformance, post-implementation drift review, and promotion evidence exist outside proposal paths.

## Current Canonical Baseline

This child starts from the current canonical runtime and governance surfaces: Run Lifecycle v1, Execution Authorization v1, Authorized Effect Token v1, Context Pack Builder v1, Evidence Store v1, support-target governance, and fail-closed obligations. Those surfaces remain canonical unless this child or a dependent child is accepted, implemented, validated, promoted, and cut over through durable evidence.

## Authority Model Fit

The child must strengthen the existing authored-authority, state-control, retained-evidence, generated-derived, and inputs-non-authority model. It must not create a second control plane or route around current authorization and evidence obligations.

## In Scope

Cutover criteria, compatibility language, retirement register entries, migration receipts, rollback posture, disclosure updates, and final claim boundaries.

## Out Of Scope

- No implementation of missing workflow, agent-node, replay, token, evidence, or connector primitives inside this cutover packet.
- No cutover while predecessor child receipts are missing, stale, failed, or child-owned only in proposal-local form.
- No retirement of compatibility language without rollback and support evidence.

## Promotion Surface

- `.octon/framework/cognition/_meta/terminology/naming-constitution.md`
- `.octon/framework/cognition/_meta/terminology/glossary.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/README.md`
- `.octon/AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/instance/bootstrap/START.md`

## Evidence Before Claim

- Child terminal receipt index and freshness report.
- Cutover checklist and compatibility retirement receipt.
- Post-cutover drift/churn review.

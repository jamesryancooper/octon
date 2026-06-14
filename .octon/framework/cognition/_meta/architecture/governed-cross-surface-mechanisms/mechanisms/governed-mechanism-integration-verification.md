# Governed Mechanism Integration Verification

## Role

Governed mechanism integration verification is the lifecycle gate that checks whether a mechanism implementation has complete cross-surface evidence before proposal closeout or archive readiness.

The mechanism composes existing gates. It does not own implementation conformance, post-implementation drift/churn, publication generation, terminal closeout, current-state architecture review, lifecycle postmortem, or archive relocation.

## Authority Boundaries

- Durable semantics live in product contracts, workflow contracts, validators, lifecycle extension inputs, and the governed mechanism index.
- Proposal-local support receipts are evidence only.
- Generated outputs are derived-only and must be refreshed by canonical generators or publishers.
- Current-state mechanism architecture review remains evidence-only.
- Lifecycle postmortem remains evidence-only.
- Host state, dashboards, chat, tool state, and model memory are non-authority.

## Required Evidence

A passing receipt cites:

- a validated mechanism integration profile,
- implementation conformance receipt evidence,
- post-implementation drift/churn receipt evidence,
- generated publication freshness evidence,
- terminal freshness evidence for closeout or archive modes,
- current-state architecture review evidence only when available,
- explicit non-authority classifications.

## Validation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-profile.sh --profile <profile>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-receipt.sh --receipt <proposal-path>/support/governed-mechanism-integration-evaluation.yml --package <proposal-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-cross-surface-mechanisms.sh
```

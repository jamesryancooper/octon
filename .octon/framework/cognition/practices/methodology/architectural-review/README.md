---
title: Architectural Review Mechanism
description: Native Octon doctrine, routing, naming, and evidence boundaries for architectural review.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-06-11
---

# Architectural Review Mechanism

The Architectural Review Mechanism is Octon's native architecture-review
family. It owns doctrine, review mode taxonomy, routing rules, schema-backed
receipts, workflow contracts, validators, evidence roots, and lifecycle
integration points.

Extension packs may prepare source material and proposal packets, but they do
not own native review doctrine, lifecycle gates, workflow authority, or closeout
authority.

## Canonical Names

| Surface | Display Name | Slug |
| --- | --- | --- |
| Mechanism | Architectural Review Mechanism | `architectural-review` |
| Method | Balanced Architecture Review Method | `balanced-architecture-review-method` |
| Pre-integration review | Pre-Integration Architecture Review | `pre-integration-architecture-review` |
| Post-integration review | Post-Integration Architecture Review | `post-integration-architecture-review` |
| Mechanism review | Current-State Mechanism Architecture Review | `current-state-mechanism-architecture-review` |
| Readiness audit | Architecture Readiness Audit | `architecture-readiness-audit` |
| Domain audit | Domain Architecture Audit | `domain-architecture-audit` |
| Surface audit | Surface Architecture Audit | `surface-architecture-audit` |
| Extension packet helper | Architecture Revision Packet | `architecture-revision-packet` |
| Evaluator | Lifecycle Postmortem Evaluator | `lifecycle-postmortem-evaluator` |

The canonical readiness-audit slug is `architecture-readiness-audit`.
`audit-architecture-readiness` is retired from authored runtime, workflow,
skill, command, and lifecycle routing surfaces.

## Native Ownership

Native Octon owns:

- architectural review doctrine and naming;
- review mode routing;
- report, routing, and support receipt schemas;
- validator and negative-control behavior;
- workflow contracts and evidence roots;
- proposal lifecycle gates;
- governed mechanism index integration.

`octon-concept-integration` owns:

- source and concept intake;
- source extraction and verification;
- multi-source synthesis;
- source-to-packet generation;
- Architecture Revision Packet packetization helpers;
- convenience prompt bundles.

## Authority Boundaries

- Raw inputs are not authority.
- Proposal packets are temporary and non-authoritative.
- Generated outputs are derived-only.
- Review reports are retained evidence only unless a lifecycle contract gates
  on a schema-backed support receipt.
- Skills and commands are invocation surfaces only; workflows are canonical
  execution contracts.
- Parent program summaries cannot satisfy child packet receipts.
- Lifecycle postmortems cannot authorize closeout, promotion, redesign,
  support widening, generated publication, or constitutional amendment.

## References

- [Balanced Architecture Review Method](./balanced-architecture-review-method.md)
- [Review Routing](./review-routing.yml)
- [Naming Model](./naming.yml)

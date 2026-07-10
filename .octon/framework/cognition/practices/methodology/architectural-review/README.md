---
title: Architectural Review Mechanism
description: Native Octon doctrine, routing, naming, and evidence boundaries for architectural review.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-06-15
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
| Method (default) | Balanced Architecture Review Method | `balanced-architecture-review-method` |
| Method | Greenfield Reference Architecture Review | `greenfield-reference-architecture-review-method` |
| Method | Architecture Tradeoff Review | `tradeoff-review-method` |
| Method | Failure-Mode Architecture Review | `failure-mode-review-method` |
| Method | Evolution/Fitness Architecture Review | `evolution-fitness-review-method` |
| Method | Boundary/Authority Architecture Review | `boundary-authority-review-method` |
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

## Methods And Selection

Every architecture review run selects exactly one **method** — the way the
review is conducted. Balanced Architecture Review is the declared default; the
five companion methods above are advisory options. Methods are distinct from
routes: a method is *how* a review is conducted, a route is the *occasion* for
it. The per-route allowed methods and the Balanced escalation map live in
[`review-routing.yml`](./review-routing.yml) `method_selection`; the canonical
method catalog and lens bindings live in [`naming.yml`](./naming.yml) `methods`.

Selecting a method not declared in `naming.yml` `methods.catalog` fails closed
(`unknown_method`), and a routing decision that selects a method but omits the
required method record fails closed (`missing_method_record`). Method selection
creates no lifecycle gate and grants no review output any authority — the
pre-integration support receipt remains the sole lifecycle-gating review
artifact. Each method draws its lenses from the shared
[Architecture Lens Bank](./architecture-lens-bank.md) (`lens-bank.yml`); every
`methods.catalog` slug binds to a `lens-bank.yml` `suite_methods` profile.

## Invocation Aliases And Command Facades

`domain-architecture-audit` and `surface-architecture-audit` are the canonical
methodology and report-schema mode names. The operator invocation surfaces keep
the established `audit-domain-architecture` and `audit-surface-architecture`
names as active aliases, with validators enforcing the mapping.

`architecture-readiness-audit`, `audit-domain-architecture`, and
`audit-surface-architecture` have command facades for operator discovery. These
commands invoke the existing audit skills or workflow routes only; they do not
create lifecycle gates or review authority.

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
- [Greenfield Reference Architecture Review Method](./greenfield-reference-architecture-review-method.md)
- [Architecture Tradeoff Review Method](./tradeoff-review-method.md)
- [Failure-Mode Architecture Review Method](./failure-mode-review-method.md)
- [Evolution/Fitness Architecture Review Method](./evolution-fitness-review-method.md)
- [Boundary/Authority Architecture Review Method](./boundary-authority-review-method.md)
- [Review Routing](./review-routing.yml)
- [Naming Model](./naming.yml)
- [Architecture Lens Bank](./architecture-lens-bank.md)

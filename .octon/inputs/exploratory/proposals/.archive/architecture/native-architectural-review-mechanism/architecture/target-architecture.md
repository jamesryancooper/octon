# Target Architecture

## Mechanism Shape

Octon gains a native Architectural Review Mechanism with one family slug:
`architectural-review`.

The mechanism owns:

- native doctrine for the Balanced Architecture Review Method;
- a deterministic review mode taxonomy and routing contract;
- strict report, routing, and support receipt schemas;
- validators and negative controls;
- canonical workflows for pre-integration, post-integration, current-state
  mechanism, and architecture-readiness review;
- thin skill and command invocation surfaces;
- proposal lifecycle gates that require Pre-Integration Architecture Review for
  architecture proposals;
- mode-specific retained evidence roots;
- governed cross-surface mechanism index integration;
- migration cleanup for old `architecture-readiness-audit` naming.

## Native And Extension Split

Native Octon owns architectural review authority. The extension owns intake and
packetization helpers:

- source and concept intake;
- concept extraction and verification;
- multi-source synthesis;
- source-to-packet generation;
- Architecture Revision Packet packetization helper;
- prompt bundles and publication alignment.

The extension may call or reference native doctrine and workflows, but it cannot
replace lifecycle gates or become a second review control plane.

## Review Modes

The target taxonomy uses these canonical names and slugs:

| Display Name | Slug | Primary Purpose |
| --- | --- | --- |
| Pre-Integration Architecture Review | `pre-integration-architecture-review` | Required native gate before architecture proposal acceptance or implementation authorization. |
| Architecture Revision Packet | `architecture-revision-packet` | Extension-owned helper that packages revised architecture proposals from sources and review pressure. |
| Post-Integration Architecture Review | `post-integration-architecture-review` | Evidence-only review after implementation unless later policy explicitly selects it as a gate. |
| Current-State Mechanism Architecture Review | `current-state-mechanism-architecture-review` | Native review of a durable mechanism's current architecture independent of an integration proposal. |
| Architecture Readiness Audit | `architecture-readiness-audit` | Native readiness audit for whole-harness or bounded architecture readiness. |
| Domain Architecture Audit | `domain-architecture-audit` | Domain-focused architecture critique. |
| Surface Architecture Audit | `surface-architecture-audit` | Durable surface unit architecture critique. |
| Lifecycle Postmortem Evaluator | `lifecycle-postmortem-evaluator` | Retained evidence-only lifecycle evaluation after a lifecycle run. |
| Constitutional Challenge | `constitutional-challenge` | Escalation path for constitution, precedence, fail-closed, authority, or normative conflict. |

## Authority Boundaries

- Raw inputs are not authority.
- Proposal packets are temporary and non-authoritative.
- Generated outputs are derived-only.
- Review reports are retained evidence unless a lifecycle contract explicitly
  gates on their schema-backed receipt.
- Lifecycle postmortems cannot authorize closeout, promotion, redesign, support
  widening, generated publication, or constitutional amendment.
- Extension packetization cannot replace native proposal lifecycle gates.
- Skills and commands cannot duplicate workflow authority.
- Parent program summaries cannot satisfy child packet receipts.
- Host state, chat, tool availability, dashboards, and model memory are never
  authority.

## Lifecycle Gate Target

Every architecture proposal must have a fresh passing
`pre-integration-architecture-review` support receipt before the proposal can
move to `accepted` or authorize implementation. The receipt must be
schema-backed, digest-bound to the reviewed packet, validator-bound, and
non-authority-classified.

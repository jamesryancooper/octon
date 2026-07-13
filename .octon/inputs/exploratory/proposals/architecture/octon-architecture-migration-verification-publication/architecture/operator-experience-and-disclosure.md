# Operator Experience And Disclosure

## Normal Solo-Builder Experience

RP-06 adds no normal command concept and no routine prompt. After later
program enablement, an eligible Class B change receives an authenticated
exact-SHA verdict and lands through RP-05. Valid review-required work opens or
updates protected PR. Invalid authority denies with the shortest safe next
action. The operator does not select among technical verifier, publisher, or
workflow mechanisms.

## One-Screen Status

The normal route view should show:

- candidate/source SHA and destination ref;
- selected outcome: local Class A, brokered Class B, protected PR, stronger
  Class C control, or denied;
- verifier identity/version and verdict status without exposing secrets;
- route policy version/digest;
- provider-binding freshness when relevant;
- status: waiting, verified, publishing, PR-ready, succeeded, denied,
  blocked, or reconciling;
- concise reason and shortest safe next action;
- retained receipt reference.

Raw provider payloads, credentials, verbose traces, and large evidence bodies
remain outside the normal view.

## Route Experience

- Eligible Class B: zero prompts; verify, publish, and report completion.
- Valid review-required work: zero routine prompts; preserve the candidate and
  report the deterministic protected-PR route.
- Invalid, stale, forged, revoked, raced, wrong-SHA, or wrong-scope authority:
  deny with a concise fresh-authorization action, never PR laundering.
- Verifier/provider outage or drift: preserve work and report the affected
  route as blocked; safe Class A remains usable.
- Irreducible effect ambiguity is owned by RP-08 and must not be guessed here.

## Setup And Maintenance

The verifier/publication specialization integrates with existing setup,
status, doctor, repair, upgrade, and uninstall surfaces. It must not add a
custom verifier daemon under ED-004, a second store, another broker, a normal
profile, or a separate credential-enrollment ceremony.

Doctor checks verifier identity/version, permission separation, policy and
schema digest, required-check producer binding, provider drift, projection
freshness, and route enablement. Routine refresh is automatic and receipted;
provider drift disables the affected route instead of prompting the operator
to weaken it.

## Disclosure Boundaries

The packet and later receipts may claim only immutable verification,
deterministic route selection, and the primary-provider specialization
directly proven. They must disclose that:

- production Class B requires RP-07 signed evidence and RP-08 recovery;
- trust-root activation belongs to RP-09;
- generic adapter semantics belong to RP-11;
- final provider and support claims belong to RP-14;
- provider observations are point-in-time and drift-sensitive;
- optional worker and secondary-provider claims require their own proof;
- .github workflows are derived projections, never authority or RP-06
  promotion targets.

## Product Budgets Contributed

RP-06 contributes zero routine prompts, zero false A/B-to-PR escalations in
the reference matrix, preserved blocked work, at most seven normal command
concepts program-wide, and concise one-screen status. RP-14 owns final measured
speed, completion, setup, and maintenance claims.

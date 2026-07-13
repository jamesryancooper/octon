# Operator Experience And Disclosure

## Normal Solo-Builder Experience

RP-05 adds no normal command concept and no routine prompt. When RP-06 later
selects an eligible Class B route, the broker imports the exact candidate
object, performs the exact ref update, and reports completion. The operator
does not manage Git configuration, credentials, object stores, or retry logic.

## One-Screen Status

The normal completion or blocker view should show:

- candidate/source SHA;
- destination repository and ref;
- route selected by RP-06;
- status: pending, attempting, reconciling, succeeded, denied, blocked, or
  manual intervention;
- expected-old and observed target identities;
- whether the claim is state satisfied or attempt performed;
- shortest safe next action;
- retained receipt reference.

No credential value, raw Git trace, or large evidence payload appears in the
normal view.

## Failure Experience

- Wrong target, stale expected-old, non-ancestor, or invalid authority: deny
  without mutation.
- Valid work that does not meet no-PR predicates: preserve and route to
  protected PR through RP-06.
- Provider or adapter outage: preserve work and retry only after safe
  reconciliation.
- Irreducibly unknown outcome: present one concise actionable intervention,
  never repeated prompts.

## Setup And Maintenance

The Git adapter shares RP-04 setup, status, doctor, repair, upgrade, and
uninstall. It must not add a separate daemon, store, credential enrollment, or
control plane. Doctor checks only adapter version, broker Git isolation,
credential handle availability, provider reachability, policy digest, and
pending unknown attempts.

Routine maintenance is automatic and bounded: prune disposable broker Git
objects only after active operation and evidence pins clear; rotate provider
credentials through RP-04; and rerun provider CAS conformance when provider
configuration drifts.

## Disclosure Boundaries

The packet and its later receipts may claim only a sanitized Git primitive.
They must disclose that:

- production autonomous publication is not proven by RP-05;
- RP-06 supplies verifier and route policy;
- RP-07 supplies signed bounded evidence;
- RP-08 supplies recovery and Class B proof;
- provider observations are point-in-time;
- no .github host projection is an RP-05 authority or promotion target.

## Product Budgets Contributed

RP-05 should add no routine prompts, preserve blocked candidate work, avoid a
new visible profile, and keep mediation overhead inside the later program's
60-second p50 budget excluding provider queue time. RP-14 owns final measured
product claims.

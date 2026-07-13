# Validation Plan

## Evidence Posture

All runtime, adversarial, provider, and projection proof is planned. This draft
claims none as executed.

| Proof family | Method | Required classification |
| --- | --- | --- |
| Contract, permission, and ownership map | Static inspection | STATICALLY_INSPECTED |
| Verdict and route fixtures | Dynamic execution | DYNAMICALLY_EXECUTED |
| Candidate mutation and duplicate-context attacks | Adversarial test | ADVERSARIALLY_TESTED |
| Provider worker loss/duplication and route races | Fault injection | ADVERSARIALLY_TESTED |
| Ruleset, App, check, environment, and secret posture | Provider observation | PROVIDER_OBSERVED |
| Projection generation and drift | Dynamic execution | DYNAMICALLY_EXECUTED |

## PO-FD-011 / Immutable Verdict

Vary candidate verifier code, workflow source, producer identity, event,
repository, source SHA, target ref, target pre-SHA, policy digest, harness
digest, evidence head, time, expiry, and revocation. Create duplicate and
conflicting contexts. Only the complete tuple from the accepted verifier
identity/version may pass.

## PO-FD-010 / Adaptive Publication

Exercise:

- eligible Class B to exact RP-05 no-PR effect;
- valid protected scope or valid uncertainty to protected PR;
- invalid, stale, forged, revoked, raced, wrong-SHA, and wrong-scope authority
  to denial;
- Class C downgrade attempt to denial or stronger control;
- agent direct-main reachability to denial;
- blocked publication with candidate work preserved;
- zero routine prompts and concise explanation.

## PO-FD-007 / Optional Provider Worker

If admitted, prove narrow App permissions, exact operation binding,
duplicate/lost/delayed workflow reconciliation, inability to mint authority,
and no canonical state. Absence of the optional worker does not block the core
local path.

## FD-023 Specialization

Run the verifier/publication specialization through the generic conformance
vocabulary without claiming RP-11 generic adapter ownership. RP-14 independently
reproduces the integrated provider claim. A live secondary is tested only for
a separately proposed secondary-provider claim.

## UE-015 Provider Refresh

At implementation and promotion, capture redacted:

- rulesets and branch protection;
- required-check producer identities;
- Apps and permissions;
- Actions defaults;
- environments and protection;
- secret consumers;
- relevant audit and run evidence.

Drift blocks or demotes the affected route.

## Projection Tests

- .octon source deterministically produces the expected host projection.
- Source mutation invalidates the projection digest.
- Direct .github edits fail drift validation.
- Projection receipt binds source, output, publisher, generation, and time.
- Projection cannot mint authority or substitute for the verdict.

## Evidence To Retain

- verifier identity/version and permission receipt;
- exact verdict fixtures and negative matrix;
- immutable policy source/digest and route matrix;
- provider configuration observations;
- optional-worker conformance when present;
- workflow disposition and projection source/output digests;
- zero-prompt UX report;
- rollback rehearsal;
- implementation conformance and drift/churn receipts.

## Acceptance Rule

No context-name, summary-only, self-reported, candidate-generated, or stale
provider result passes. Failure keeps autonomous publication disabled.

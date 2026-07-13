# Validation Plan

## Evidence Posture

All tests below are planned. None is represented as executed evidence by this
draft. Results must use the reconciliation evidence classifications and retain
proof method separately.

| Proof family | Method | Required classification |
| --- | --- | --- |
| Contract and ownership checks | Static inspection | STATICALLY_INSPECTED |
| Positive object import and exact fast-forward | Dynamic execution | DYNAMICALLY_EXECUTED |
| Hostile Git extension matrix | Adversarial test | ADVERSARIALLY_TESTED |
| Crash, outage, and target races | Fault injection | ADVERSARIALLY_TESTED |
| Live scratch provider behavior | Provider observation | PROVIDER_OBSERVED |
| Operator flow and fallback | Scenario execution | DYNAMICALLY_EXECUTED |

## PO-FD-009 / PG-05-SANITIZED-GIT

The decisive proof runs sentinels through:

- hooks and hook paths;
- system, global, local, worktree, include, and includeIf config;
- aliases and command substitution;
- credential and remote helpers;
- clean/smudge process filters and textconv;
- external diff and merge drivers;
- fsmonitor;
- submodules and recursive update behavior;
- alternates and replacement objects;
- SSH, upload-pack, receive-pack, proxy, and protocol helpers;
- signing programs, editors, pagers, and askpass;
- attributes and candidate-controlled environment variables.

Every sentinel must remain unexecuted while the one exact positive
fast-forward succeeds.

## UE-005 / Provider Race Matrix

Against a disposable provider repository:

1. Hold expected-old constant while another actor advances the target to an
   ancestor of proposed-new; the adapter must deny.
2. Advance the target to a non-ancestor; the adapter must deny.
3. Change repository identity or target ref; the adapter must deny.
4. Supply wrong or incomplete objects; import or update must deny.
5. Lose the response after provider acceptance; the adapter must report an
   unknown causal outcome and must not retry.
6. Have another actor install the same proposed-new object; observation may
   report state satisfied but not attempt performed.
7. Revoke or expire authorization immediately before the call; the effect must
   not run.

## Fault Matrix

Inject failure before and after object import, ancestry proof, RP-03 attempt
commit, credential projection, provider send, response receipt, observation,
and result persistence. The target either remains expected-old or reaches
proposed-new through at most one authorized attempt; uncertainty is preserved
for RP-08 reconciliation.

## Structural Checks

- No candidate checkout under broker identity.
- No direct writer outside the broker adapter.
- No Git credential in candidate environment or evidence output.
- No .github promotion target.
- No dependency from durable source to the active proposal path.
- RP-05-owned files do not encode verifier or route-policy authority.

## Packet Validators

- validate-proposal-standard.sh with the registry check skipped during isolated
  child authoring.
- validate-architecture-proposal.sh.
- validate-proposal-implementation-readiness.sh.
- validate-proposal-review-gate.sh.
- validate-architectural-review-receipts.sh when review is requested.

## Evidence To Retain

- adapter and allowlist source digests;
- object-transfer input/output digests;
- hostile fixture manifest and results;
- scratch repository and ref identities;
- expected-old race observations;
- provider receipt and lost-response records;
- state-satisfied versus attempt-performed classifications;
- writer inventory and direct-path scan;
- rollback rehearsal;
- implementation conformance and drift/churn receipts.

## Acceptance Rule

No summary-only result passes. The proof bundle must identify evaluator,
inputs, outputs, criteria, negative controls, trace or replay references,
receipt references, and final result. Failure leaves production publication
disabled.

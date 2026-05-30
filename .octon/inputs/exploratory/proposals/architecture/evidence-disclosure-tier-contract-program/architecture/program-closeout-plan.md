# Program Closeout Plan

_Status: In-review parent-program closeout plan_

Program closeout is not satisfied by the existence of this parent packet.
Closeout requires child-owned terminal outcomes and aggregate evidence.

## Required Closeout Conditions

1. Every required child in `resources/child-packet-index.yml` has a terminal
   outcome allowed by the active proposal-program lifecycle contract.
2. Every implemented required child has child-owned implementation-grade,
   implementation-conformance, and post-implementation drift/churn receipts.
3. Every rejected, superseded, replaced, or deferred child has explicit
   resolving evidence.
4. Required child receipts are fresh and digest-checked against live child
   state.
5. Parent aggregate evidence summarizes child outcomes without satisfying child
   receipts.
6. No parent file claims child promotion target truth, child validation truth,
   child archive truth, or child implementation truth.
7. No generated projection, raw input, local raw evidence file, host surface,
   chat history, or proposal path is used as authority.
8. Hosted/shared closeout can complete from publishable evidence and
   disclosure artifacts without requiring local-only evidence.

## Aggregate Evidence

The parent closeout evidence should include:

- child registry digest;
- child terminal outcome table;
- required child receipt freshness table;
- deferred/rejected/superseded child resolution table;
- aggregate validator report;
- authority-boundary review;
- generated/input/local-evidence non-authority review;
- hosted closeout local-evidence independence review;
- migration and rollback summary.

## Closeout Blockers

Closeout is blocked when:

- any required child is non-terminal;
- any required child has stale or missing receipts;
- any required child promotion target is parent-owned;
- raw local evidence is required for hosted/shared closeout;
- publishable receipts are too vague to prove the claim;
- generated read models are treated as authority or retained evidence;
- tracked files appear under the local-only evidence root;
- current retained evidence contracts are weakened without accepted child
  evidence.

## Archive Posture

After required children reach allowed terminal outcomes and aggregate evidence
is retained, this parent packet may be archived as implemented, rejected,
superseded, or historical according to the active proposal lifecycle rules.

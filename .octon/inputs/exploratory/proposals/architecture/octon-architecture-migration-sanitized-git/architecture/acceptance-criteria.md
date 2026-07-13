# Acceptance Criteria

These criteria authorize no implementation. They define the evidence required
after accepted implementation.

| ID | Criterion | Required proof |
| --- | --- | --- |
| AC-RP05-001 | The Git effect executes only inside the one RP-04 broker and consumes a frozen RP-03 operation/attempt contract. | Static ownership map and broker integration tests |
| AC-RP05-002 | Broker Git state is independent from the candidate and canonical repository, with no checkout under broker identity. | Filesystem/object-database identity fixtures |
| AC-RP05-003 | Candidate-object import transfers the exact reachable object closure without executing candidate code or loading candidate configuration. | Non-execution fixtures and object digest comparison |
| AC-RP05-004 | Hooks, includes, aliases, helpers, filters, drivers, fsmonitor, submodules, alternates, transports, signing programs, editors, pagers, attributes, and local config cannot execute or redirect the effect. | UE-005 hostile extension matrix with sentinels |
| AC-RP05-005 | Every RP-03 canonical T1 tuple/digest field, including consequence scope and evidence head, plus the selected source/target/delete/mirror precondition is exact and immutable for one attempt. | Per-field omission/mutation and wrong-identity negatives |
| AC-RP05-006 | The proposed object is independently proved to descend from expected-old before the provider operation. | Ancestor and non-ancestor tests |
| AC-RP05-007 | The provider atomically rejects an expected-old mismatch even when the intervening target remains an ancestor of the proposed object. | Concurrent ancestor target-race test against a scratch provider |
| AC-RP05-008 | Non-fast-forward, wrong repository, wrong ref, wrong SHA, stale authorization, missing credential, and unsupported transport all deny without changing the target. | Negative route matrix and remote observation |
| AC-RP05-009 | The adapter records current observed state separately from any claim that this attempt performed the transition. | Lost-response and concurrent-actor attribution tests |
| AC-RP05-010 | Adapter, broker, credential, or provider unavailability preserves candidate work and exposes no ambient fallback. | Fault and outage matrix |
| AC-RP05-011 | Existing ambient mutation paths are removed, disabled, or reduced to broker-only facades after proof; no second writer remains. | Writer inventory and direct-path negative scan |
| AC-RP05-012 | PO-FD-009 passes and RP-06 can consume the proven FD-010 Git primitive without RP-05 owning verifier or route policy. | PG-05 proof bundle and RP-06 interface conformance |
| AC-RP05-013 | No .github path or generated projection becomes an octon-internal promotion target. | Target-family and drift/churn review |
| AC-RP05-014 | Normal operation adds no new routine operator prompt or command concept. | Operator-flow fixture and disclosure review |
| AC-RP05-015 | Expected-absent/expected-tip source-ref create/update and expected-tip deletion are sealed, separately T1-bound operations. | Source-ref race and lost-response suite |
| AC-RP05-016 | Conditional deletion cannot remove a closed-unmerged or otherwise unlanded candidate and rejects a moved tip atomically. | Closed-unmerged and compare/delete-race fixtures |
| AC-RP05-017 | True target CAS works under mandatory protections with no bypass; if unavailable, production publication remains disabled. | Scratch provider/ruleset conformance and bypass-negative proof |
| AC-RP05-018 | Candidate environments contain no provider credential, and collision, outage, denial, or `UNKNOWN` never switches the frozen attempt to PR. | Credential scan and route-freeze negatives |
| AC-RP05-019 | The adapter remains a closed operation family and cannot expose arbitrary Git commands, transports, repositories, refs, or credentials. | API surface and hostile request negatives |

## Exit Criteria

RP-05 exits only when all criteria pass with direct retained evidence, the
strict pre-integration architecture review and implementation authorization
exist, RP-04 has exited, ED-003 is shown feasible, implementation conformance
passes, and post-implementation drift/churn review reports no second effect
path or target-family violation.

## Claim Limit

Passing RP-05 proves a sanitized Git primitive. It does not prove immutable
verification, production Class B publication, complete recovery, or a support
claim.

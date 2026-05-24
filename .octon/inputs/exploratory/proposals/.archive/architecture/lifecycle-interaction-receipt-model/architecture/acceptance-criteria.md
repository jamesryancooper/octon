# Acceptance Criteria

Implementation is complete only when all criteria pass:

1. Valid lifecycle interaction request receipts pass schema and validator
   checks.
2. Valid lifecycle interaction return receipts pass schema and validator
   checks.
3. Dangling evidence refs fail.
4. Stale evidence refs fail.
5. Scope widening fails through boundary digest mismatch or unsafe paths.
6. Forbidden authority transfer fails when a request omits required forbidden
   transfers or includes authority-bearing evidence.
7. A request cannot satisfy promotion, archive, landing, cleanup, or closeout
   gates.
8. Target lifecycles independently evaluate gates before acting.
9. Return evidence is required before a source lifecycle marks the dependency
   resolved.
10. The runner can discover and plan from a request without self-authorizing
    dispatch.
11. Executor adapters cannot reinterpret request policy or use it to satisfy
    missing target route proof.
12. Generated effective projections are refreshed only as derived publication.
13. Existing proposal statuses remain unchanged.
14. Proposal-local receipts do not authorize Git or ref mutation.
15. Phase names remain checkpoint/event context, not runtime statuses.
16. All implementation changes stay within declared promotion targets.
17. Implementation conformance and post-implementation drift receipts pass with
    zero unresolved items.
18. Closeout uses `closeout-change` and claims only the highest proven outcome.

# Mission Runner Sequence

The Mission Runner must be deterministic at the control-plane level.

## Algorithm

1. Resolve active Engagement.
2. Resolve active Work Package.
3. Resolve active Mission Charter.
4. Resolve Autonomy Window.
5. Reconstruct mission state from control roots.
6. Verify mission-control lease.
7. Verify budget.
8. Verify circuit breakers.
9. Refresh Project Profile if stale.
10. Refresh Work Package if stale or invalidated.
11. Refresh support-target posture.
12. Refresh capability/connector posture.
13. Refresh context baseline and identify run context needs.
14. Load Mission Queue.
15. Filter Action Slices blocked by dependencies.
16. Filter Action Slices requiring unresolved Decision Requests.
17. Filter slices outside lease, risk ceiling, action class, support, or capability envelope.
18. Select next bounded Action Slice.
19. Compile next run-contract candidate.
20. Build/validate run-bound context pack.
21. Evaluate policy and approvals.
22. Authorize through engine-owned boundary.
23. Execute through existing governed run path.
24. Validate result.
25. Update Mission Queue.
26. Update Mission Run Ledger.
27. Update continuity.
28. Emit Continuation Decision.
29. Continue only if gates still pass; otherwise pause/stage/escalate/revoke/close/fail.

The model may help prepare implementation content inside a governed run. It must not become the canonical source for continuation decisions, support posture, capability admission, lease state, budget state, breaker state, or closeout.

# Acceptance Criteria

The cutover is acceptable only if **every** criterion below is true.

## A. Release, Manifest, And Ratification

1. `version.txt` equals `0.6.1`.
2. `.octon/octon.yml` `release_version` equals `0.6.1`, and validation fails
   on any `version.txt` / root-manifest divergence.
3. `.octon/README.md`, the umbrella architecture spec, and the root manifest
   all describe the same mission-control, summary, projection, and effective-
   route roots.
4. A migration plan and decision record for this cutover exist under canonical
   instance cognition roots.
5. The prior `mission-scoped-reversible-autonomy-completion-cutover` package
   is archived after promotion.

## B. Mission Authority And Scaffolding

6. The mission scaffold creates the complete mission-control file family or an
   automatic seed path makes that family exist before the mission is active.
7. The mission scaffold or seed path also creates the continuity stubs
   required by MSRAOM.
8. Every in-tree active mission uses `octon-mission-v2`.
9. `owner_ref` is canonical everywhere.
10. No runtime path depends on legacy `owner` after migration completes.

## C. Mission-Control Contracts

11. Each runtime-required control file has one durable schema and one
    canonical location.
12. `authorize-update-v1` exists and is registered.
13. `mission-view-v1` exists and is registered.
14. `mode-state.breaker_state` and `circuit-breaker.state` use one normalized
    vocabulary.
15. `mode-state.effective_scenario_resolution_ref` is required for active or
    paused autonomous missions.
16. `intent-register` entries reference action slices.
17. Action slices carry the fields needed for boundary, ACP, reversibility,
    preview, and recovery derivation.

## D. Forward Intent And Action Slices

18. Material autonomous work cannot proceed from an empty or stale intent
    register.
19. Material autonomous work cannot proceed without a referenced action slice.
20. Preview generation, feedback windows, proceed-on-silence eligibility, and
    promote eligibility all consume the same slice-linked intent state.
21. Observe-only missions may remain empty-intent until they fork bounded
    operate work.
22. At least one in-tree validation mission or fixture demonstrates non-empty
    intent publication and slice-derived recovery.

## E. Mode, Route, And Runtime Integration

23. A fresh scenario-resolution artifact exists for every active autonomous
    mission.
24. The route is linked from `mode-state.yml`.
25. The route contains `mission_class`, `effective_scenario_family`, and
    `effective_action_class`.
26. The evaluator, scheduler, and summary generator consume the same route.
27. The route is recomputed whenever relevant control truth changes.
28. Generic `service.execute` recovery fallback is not used for material
    autonomous work.
29. If recovery cannot be derived, the runtime tightens to `STAGE_ONLY`,
    `SAFE`, or `DENY`.

## F. Interaction Grammar

30. `Inspect / Signal / Authorize-Update` is operationally complete.
31. Directives are persisted in canonical mission control truth.
32. Authorize-updates are persisted in canonical mission control truth.
33. Runtime handlers exist for the directive and authorize-update types named
    in this packet.
34. Ownership precedence is applied consistently to control mutations.

## G. Scheduling And Safe Interruption

35. `suspend_future_runs` and `pause_active_run` are distinct and enforced.
36. Overlap policy is enforced.
37. Backfill policy is enforced.
38. Pause-on-failure is enforced.
39. Safe-boundary classes use the normalized taxonomy.
40. No route falls back to a generic safe-boundary class because of taxonomy
    mismatch.

## H. Recovery, Finalize, And Evidence

41. Run receipts continue to carry recovery and finalize semantics.
42. Control receipts are emitted for all control mutations listed in this
    packet.
43. Run evidence and control evidence remain separate.
44. Finalize gates consume route, directives, authorize-updates, and recovery
    state.
45. Late feedback can block finalize or invoke recovery while the recovery
    window is open.
46. Break-glass and safing transitions emit control receipts.

## I. Autonomy Burn And Circuit Breakers

47. Autonomy-budget state is recomputed from actual runtime/control evidence.
48. Breaker state is recomputed from actual runtime/control evidence.
49. Breaker actions affect route, scheduler, and summaries.
50. Burn/breaker transitions are retained in control evidence.

## J. Operator And Machine Read Models

51. Every active mission has generated `now.md`, `next.md`, `recent.md`, and
    `recover.md`.
52. Ownership-routed operator digests are generated from subscriptions and
    ownership policy.
53. Every active mission has a materialized machine-readable mission view
    under the mission projection root.
54. Generated views remain non-authoritative and cite their source roots.

## K. Scenario Resolution And Conformance

55. Scenario resolution remains generated, not authored.
56. It distinguishes mission class from effective scenario family.
57. It routes at least these cases differently:
    - routine housekeeping
    - long-running campaign/refactor
    - dependency/security patching
    - release-sensitive work
    - infrastructure drift correction
    - migration/backfill
    - external sync
    - observe-only monitoring
    - incident containment
    - destructive work
    - absent human
    - late feedback
    - conflicting human input
    - reversible vs compensable vs irreversible work
58. The scenario suite validates those cases.
59. Scenario conformance is blocking in CI.

## L. CI And Validation

60. The architecture-conformance workflow (or an explicitly required companion
    workflow) runs all required mission-runtime and scenario validators.
61. The validators fail on:
    - missing control files
    - stale or unlinked route
    - empty intent for material work
    - generic recovery fallback
    - vocabulary mismatch
    - missing mission projection
    - missing summaries/digests
    - missing control receipts where required
62. CI branch protection treats the MSRAOM conformance checks as required.
63. No canonical doc claims a surface that does not exist, generate, and
    validate in the repo.

## Final Acceptance Rule

The cutover is complete only when all sixty-three criteria are true at once.
If any criterion is false, MSRAOM is still not in a true steady completed
state.

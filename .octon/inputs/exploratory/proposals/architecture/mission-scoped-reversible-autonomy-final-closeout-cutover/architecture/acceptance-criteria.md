# Acceptance Criteria

The closeout is acceptable only if **every** criterion below is true.
Together these criteria are the done gate for the [implementation audit](../resources/implementation-audit.md).

## A. Release, manifest, and ratification

1. `version.txt` equals `0.6.3`.
2. `.octon/octon.yml` `release_version` equals `0.6.3`.
3. Validation fails on any `version.txt` / root-manifest divergence.
4. `.octon/README.md`, the umbrella architecture spec, the runtime-vs-ops contract, and the root manifest all describe the same mission-control, effective-route, summary, digest, and mission-projection roots.
5. A migration record and a completion decision exist under canonical instance cognition roots.
6. The prior `mission-scoped-reversible-autonomy-steady-state-cutover` packet is archived after promotion.

## B. Mission lifecycle and scaffolding

7. The generic mission scaffold remains authority-only and does not directly author mutable control truth.
8. A canonical seed-before-active path exists and is the only allowed route to an active autonomous mission.
9. Validation fails if any active or paused autonomous mission lacks a full seeded mission-control family.
10. Validation fails if any active or paused autonomous mission lacks continuity stubs required by MSRAOM.
11. Every in-tree active mission uses `octon-mission-v2`.
12. `owner_ref` is canonical everywhere.
13. No runtime path depends on legacy `owner`.

## C. Mission-control contracts

14. Each runtime-required control file has one durable schema and one canonical location.
15. `authorize-update-v1` exists and is registered.
16. `mission-view-v1` exists and is registered.
17. `intent-register-v1`, `action-slice-v1`, `mode-state-v1`, `schedule-control-v1`, `mission-control-lease-v1`, `autonomy-budget-v1`, and `circuit-breaker-v1` are all registered.
18. `mode-state.breaker_state` and `circuit-breaker.state` use one normalized vocabulary.
19. `mode-state.effective_scenario_resolution_ref` is required for active or paused autonomous missions.
20. Active autonomous missions have a non-null current slice reference or are explicitly observe-only and route-bounded as such.

## D. Forward intent and action slices

21. Material autonomous work cannot proceed from an empty intent register.
22. Material autonomous work cannot proceed without a current intent entry.
23. Material autonomous work cannot proceed without a referenced action slice.
24. Intent entries reference action slices.
25. Action slices carry the fields needed for boundary, ACP, reversibility, preview, and recovery derivation.
26. Preview generation, feedback windows, proceed-on-silence eligibility, and promote eligibility all consume the same slice-linked intent state.
27. Observe-only missions may remain empty-intent only until they fork bounded operate work.
28. At least one in-tree validation mission or fixture demonstrates non-empty intent publication and slice-derived recovery.
29. No material autonomous route degrades to generic `service.execute` recovery fallback.

## E. Mode, route, and runtime integration

30. A fresh scenario-resolution artifact exists for every active autonomous mission.
31. The route is linked from `mode-state.yml`.
32. The route contains `mission_class`, `effective_scenario_family`, and `effective_action_class`.
33. The route records which layer supplied the effective scenario family.
34. The route records whether boundary and recovery semantics come from mission policy or a more-specific action slice.
35. The evaluator, scheduler, and summary generator consume the same effective route.
36. The route is recomputed whenever relevant control truth changes.
37. If route freshness is violated, runtime tightens to `STAGE_ONLY`, `SAFE`, or `DENY`.
38. If recovery cannot be derived from route plus slice, runtime tightens to `STAGE_ONLY`, `SAFE`, or `DENY`.

## F. Interaction grammar

39. `Inspect / Signal / Authorize-Update` is operationally complete.
40. Directives are persisted in canonical mission control truth.
41. Authorize-updates are persisted in canonical mission control truth.
42. Runtime handlers exist for all directive and authorize-update types named in this packet.
43. Ownership precedence is applied consistently to control mutations.
44. Directive and authorize-update application leaves control-plane receipts.

## G. Scheduling and safe interruption

45. `suspend_future_runs` and `pause_active_run` are distinct and enforced.
46. Overlap policy is enforced.
47. Backfill policy is enforced.
48. Pause-on-failure is enforced.
49. Safe-boundary classes use one normalized taxonomy.
50. No material route falls back to a generic safe-boundary class because of taxonomy mismatch.
51. Finalize blocking and unblocking consume directives, authorize-updates, route state, and recovery-window state.

## H. Recovery, finalize, and evidence

52. Run receipts continue to carry recovery and finalize semantics.
53. Control receipts are emitted for all control mutations listed in this packet.
54. Run evidence and control evidence remain separate.
55. Late feedback can block finalize or invoke recovery while the recovery window is open.
56. Break-glass and safing transitions emit control receipts.
57. Lease changes, schedule mutations, breaker transitions, and autonomy-budget transitions emit control receipts.

## I. Autonomy burn and circuit breakers

58. Autonomy-budget state is recomputed from actual runtime/control evidence.
59. Breaker state is recomputed from actual runtime/control evidence.
60. Breaker actions affect route, scheduler, evaluator, and summaries.
61. Burn/breaker transitions are retained in control evidence.
62. Safing activation and deactivation are retained in control evidence.

## J. Operator and machine read models

63. Every active autonomous mission has generated `now.md`, `next.md`, `recent.md`, and `recover.md`.
64. Ownership-routed operator digests are generated from subscriptions and ownership policy.
65. Every active autonomous mission has a materialized machine-readable mission view under the mission projection root.
66. Generated views remain non-authoritative and cite their source roots.
67. No generated summary claims a control or evidence fact that is absent from canonical inputs.

## K. Scenario resolution and conformance

68. Scenario resolution remains generated, not authored.
69. It distinguishes mission class from effective scenario family.
70. It routes at least these cases differently:
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
71. The scenario suite validates those cases.
72. Scenario conformance is blocking in CI.

## L. Validation and CI

73. Blocking CI runs:
    - version parity validation
    - architecture conformance
    - mission lifecycle cutover validation
    - mission runtime contract validation
    - mission source-of-truth validation
    - mission intent invariants validation
    - route normalization validation
    - runtime effective-state validation
    - scenario conformance
    - generated summaries validation
    - mission view generation validation
    - control-evidence validation
74. Any failure in the above jobs blocks merge.

## M. Steady-state truthfulness

75. No canonical doc overclaims behavior that runtime, evidence, generated views, and CI do not prove.
76. No known gap from the [implementation audit](../resources/implementation-audit.md) remains open after merge.
77. No further “completion” packet is needed after this one.

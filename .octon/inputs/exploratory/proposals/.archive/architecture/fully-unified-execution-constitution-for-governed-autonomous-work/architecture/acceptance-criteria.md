# Acceptance Criteria

The fully unified execution constitution proposal is ready for promotion when
all of the following are true.

## Constitutional Kernel And Preserved Invariants

1. The proposal explicitly preserves the five-class super-root:
   `framework / instance / inputs / state / generated`.
2. The proposal explicitly preserves `framework/**` and `instance/**` as the
   only authored authority classes.
3. The proposal explicitly preserves raw `inputs/**` as non-authoritative and
   excluded from runtime and policy resolution.
4. The proposal explicitly preserves `generated/**` as derived-only.
5. The proposal explicitly preserves fail-closed posture for missing or stale
   required control surfaces.
6. The proposal explicitly defines one constitutional kernel under
   `framework/constitution/**`.
7. The proposal explicitly defines a human-readable constitutional charter
   artifact.
8. The proposal explicitly defines a machine-readable constitutional charter
   artifact.
9. The proposal explicitly defines separate normative and epistemic precedence
   surfaces.
10. The proposal explicitly defines non-waivable fail-closed obligations.
11. The proposal explicitly defines evidence obligations.
12. The proposal explicitly defines ownership-role classes for humans, harness,
    and models.
13. The proposal explicitly defines a constitutional contract registry.
14. The proposal explicitly defines a support-target declaration surface.
15. The proposal explicitly forbids prompts, ingress adapters, host glue, or
    generated projections from redefining the constitutional kernel.
16. The proposal explicitly requires every compensating mechanism to carry
    retirement metadata.

## Objective Binding And Execution Model

17. The proposal explicitly defines a four-layer objective stack consisting of
    workspace charter pair, mission charter pair, run contract, and stage
    attempt contract.
18. The proposal explicitly preserves `instance/bootstrap/OBJECTIVE.md` as part
    of the workspace-charter layer unless and until a durable replacement is
    promoted.
19. The proposal explicitly preserves
    `instance/cognition/context/shared/intent.contract.yml` as part of the
    workspace-charter layer unless and until a durable replacement is promoted.
20. The proposal explicitly preserves mission authority under
    `instance/orchestration/missions/**`.
21. The proposal explicitly defines a new per-run contract under
    `state/control/execution/runs/<run_id>/**`.
22. The proposal explicitly makes the run contract the atomic execution unit.
23. The proposal explicitly keeps mission as the continuity, ownership, and
    long-horizon autonomy container.
24. The proposal explicitly states that long-horizon or recurring autonomy
    requires mission authority.
25. The proposal explicitly states that bounded run-only autonomy is legal only
    for declared support tiers.
26. The proposal explicitly forbids silent fallback into mission-less
    execution.
27. The proposal explicitly requires every consequential run to bind exactly
    one workspace charter pair and exactly one run contract.
28. The proposal explicitly requires stage attempts or retry artifacts to live
    under the run root.
29. The proposal explicitly requires assurance and disclosure to consume the
    run contract as execution-time authority.
30. The proposal explicitly forbids widening scope beyond the bound run
    contract during execution.

## Authority Routing And Approval Model

31. The proposal explicitly defines one authority engine between objective
    binding and material capability use.
32. The proposal explicitly requires all consequential side effects to pass
    through authority routing before execution.
33. The proposal explicitly preserves or extends the existing grant-oriented
    execution boundary rather than bypassing it.
34. The proposal explicitly defines normalized ApprovalRequest artifacts.
35. The proposal explicitly defines normalized ApprovalGrant artifacts.
36. The proposal explicitly defines normalized ExceptionLease artifacts.
37. The proposal explicitly defines normalized Revocation artifacts.
38. The proposal explicitly defines normalized DecisionArtifact artifacts.
39. The proposal explicitly defines normalized GrantBundle artifacts.
40. The proposal explicitly limits route outcomes to `ALLOW`, `STAGE_ONLY`,
    `ESCALATE`, or `DENY`.
41. The proposal explicitly requires humans to own policy content and
    irreversible approvals.
42. The proposal explicitly requires the harness to own evaluation and
    enforcement.
43. The proposal explicitly limits the model to requesting or proposing
    authority rather than minting it.
44. The proposal explicitly requires unresolved ownership or policy ambiguity
    to fail closed or downgrade only where policy allows.
45. The proposal explicitly requires support-tier checks to participate in
    authority routing.
46. The proposal explicitly requires approval and exception state to live under
    `state/control/execution/**` or an equivalent control family.
47. The proposal explicitly requires retained authority evidence under
    `state/evidence/control/execution/**` or an equivalent retained evidence
    family.
48. The proposal explicitly forbids labels, comments, UI state, or chat
    transcripts from acting as steady-state authority.

## Runtime Lifecycle, Evidence, And Replay

49. The proposal explicitly defines a canonical run-control root under
    `state/control/execution/runs/<run_id>/**`.
50. The proposal explicitly defines a canonical retained evidence root under
    `state/evidence/runs/<run_id>/**`.
51. The proposal explicitly requires runtime to bind the run root before any
    consequential stage begins.
52. The proposal explicitly requires checkpoints to be durable artifacts rather
    than chat-local memory.
53. The proposal explicitly requires resumability from durable state rather
    than from thread continuity alone.
54. The proposal explicitly requires retry or stage-attempt classification.
55. The proposal explicitly requires rollback or compensation posture to be
    recorded per run.
56. The proposal explicitly requires contamination handling or hard-reset
    posture.
57. The proposal explicitly requires incremental receipts or retained evidence
    for consequential stages rather than only final closeout artifacts.
58. The proposal explicitly requires replay pointers or replay manifests for
    consequential runs.
59. The proposal explicitly allows high-volume telemetry to externalize only if
    retained pointers stay inside the canonical evidence model.
60. The proposal explicitly requires mission summaries or mission projections
    to remain derived consumers of run evidence rather than replacements for
    the run root.
61. The proposal explicitly preserves `generated/**` as non-authoritative even
    when runtime consumes generated effective views.

## Verification, Lab, And Disclosure

62. The proposal explicitly defines structural verification as one proof plane,
    not the only proof plane.
63. The proposal explicitly defines functional verification as a first-class
    proof plane.
64. The proposal explicitly defines behavioral verification as a first-class
    proof plane.
65. The proposal explicitly defines governance verification as a first-class
    proof plane.
66. The proposal explicitly defines recovery verification as a first-class
    proof plane.
67. The proposal explicitly defines maintainability or architecture-health
    verification as a first-class proof plane.
68. The proposal explicitly defines independent evaluator paths where
    deterministic proof is insufficient.
69. The proposal explicitly defines a top-level `framework/lab/**` domain or an
    equivalent lab family.
70. The proposal explicitly distinguishes the lab from ordinary assurance.
71. The proposal explicitly requires behavioral claims to be backed by lab,
    replay, scenario, or shadow-run evidence.
72. The proposal explicitly requires every consequential run to emit a RunCard.
73. The proposal explicitly requires system-level support, benchmark, or
    release claims to emit a HarnessCard.
74. The proposal explicitly requires disclosure artifacts to record support
    tier, proof class, intervention, and known limits.
75. The proposal explicitly requires intervention accounting rather than hidden
    human repair.
76. The proposal explicitly requires measurement records for consequential run
    reporting.

## Agency, Adapters, And Support Targets

77. The proposal explicitly preserves one accountable orchestrator as the
    default execution role.
78. The proposal explicitly limits additional roles to real separation-of-duties
    value.
79. The proposal explicitly forbids persona-only role proliferation in the
    kernel path.
80. The proposal explicitly requires memory discipline to be runtime-enforced
    rather than prose-only.
81. The proposal explicitly defines model adapters as replaceable,
    non-authoritative boundaries.
82. The proposal explicitly defines host adapters as replaceable,
    non-authoritative boundaries.
83. The proposal explicitly requires support-target declarations for workload,
    model, language/resource, or locale tiers.
84. The proposal explicitly constrains Octon's claims to supported tiers rather
    than aspirational universality.

## Restructuring, Rollout, And Closeout

85. The proposal explicitly keeps the top-level class-root shape unchanged and
    scopes restructuring to the interior of those classes.
86. The proposal explicitly defines promotion targets inside durable
    `/.octon/**` surfaces rather than proposal-local paths.
87. The proposal explicitly keeps proposals non-authoritative and temporary.
88. The proposal explicitly defines the implementation as a staged transitional
    program rather than as an underspecified future direction.
89. The proposal explicitly justifies why a transitional profile is required.
90. The proposal explicitly defines phase exits or wave exits that prevent
    indefinite coexistence between mission-first and run-first models.
91. The proposal explicitly requires no new consequential execution path to
    bypass the authorization boundary during rollout.
92. The proposal explicitly requires no new support claim without explicit
    support-target declaration.
93. The proposal explicitly requires no new consequential run path to skip
    retained evidence and disclosure once run bundles are introduced.
94. The proposal explicitly requires durable promotion outputs to stand on
    their own without proposal-path dependencies.
95. The proposal explicitly defines completion in terms of aligned authority,
    runtime, evidence, proof, and disclosure rather than directory shape alone.

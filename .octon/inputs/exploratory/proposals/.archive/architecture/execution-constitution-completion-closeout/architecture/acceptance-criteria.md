# Acceptance Criteria

- proposal: `execution-constitution-completion-closeout`

The closeout is complete only when all of the following are true.

## Atomic Completion

1. The landing branch is a clean-break cutover with no required coexistence
   window between the old and final models.
2. No live consequential path still depends on transitional helper synthesis,
   legacy authority evidence, or placeholder governance overlays after the same
   branch lands.
3. No current authoritative doc claims a mixed or compatibility steady state for
   the final model.

## Canonical Authority

4. Every consequential acceptance run is created through the engine
   `authorize_execution(...) -> GrantBundle` path rather than by direct helper
   scripting.
5. `state/evidence/control/execution/**` contains canonical authority-decision
   artifacts for the acceptance runs.
6. `state/evidence/control/execution/**` contains canonical authority-grant-
   bundle artifacts for the acceptance runs.
7. When a run requires approval, `state/control/execution/approvals/**`
   contains matching `ApprovalRequest` and `ApprovalGrant` artifacts.
8. When a run uses an exception or revocation, those artifacts are retained
   under the canonical control roots rather than only in compatibility sets.
9. Sample acceptance evidence does not rely on legacy
   `state/evidence/decisions/repo/**` records as the sole authority evidence.

## Run-First Execution

10. Every consequential acceptance run binds
   `state/control/execution/runs/<run-id>/run-contract.yml` before side effects.
11. Every consequential acceptance run retains canonical `runtime-state.yml`,
   `rollback-posture.yml`, stage-attempts, control checkpoints, evidence
   checkpoints, replay pointers, and retained run evidence.
12. `state/continuity/runs/**` exists and contains run continuity for acceptance
   runs.
13. At least one supported mission-backed run completes end to end under the
    canonical authority path.
14. At least one supported run-only run completes end to end under the same
    canonical authority path.
15. No acceptance run contradicts the support-target route computed for its
    compatibility tuple.

## Proof And Disclosure

16. Acceptance evidence includes structural, governance, functional,
    behavioral, maintainability, recovery, and evaluator proof handling.
17. Structural and governance proof are retained as durable run-local or
    release-local artifacts rather than only as script references in RunCards.
18. Every consequential acceptance run emits a RunCard that references canonical
    authority, proof, measurement, intervention, and replay artifacts.
19. A current-release HarnessCard exists for the live supported posture.
20. Behavioral claims cite retained replay, lab, scenario, or shadow evidence.
21. Intervention-free claims cite a canonical intervention log stating that no
    hidden intervention occurred.

## Retention And Replay

22. `framework/constitution/contracts/retention/**` exists and is active.
23. `state/evidence/external-index/**` exists and is used when replay-heavy
    artifacts externalize.
24. Replay retention classes are explicit about Git-inline vs pointered vs
    external immutable evidence.
25. Acceptance runs can be reconstructed from their canonical run control and
    evidence roots alone.

## Lab, Observability, And Governance

26. `framework/lab/**` contains authored scenario, replay, shadow, fault, and
    adversarial surfaces rather than only minimal scaffolding.
27. `framework/observability/**` contains authored measurement, intervention,
    and failure-taxonomy surfaces beyond a README-plus-schema shell.
28. `instance/governance/contracts/**` is populated with the repo-owned overlay
    contracts needed for the final model, including retirement governance.
29. The atomic cutover retains drift review, support-target review, adapter
    review, and deletion review evidence.

## Overclaim Prevention

30. No current authoritative doc may declare the unified execution constitution
    complete while any criterion above is false.
31. Acceptance validators must fail closed if a helper-script backfill bundle is
    presented as final acceptance evidence.
32. The archived predecessor proposal remains archived lineage only; the final
    completion claim is made only from durable repo-local authority and retained
    evidence.

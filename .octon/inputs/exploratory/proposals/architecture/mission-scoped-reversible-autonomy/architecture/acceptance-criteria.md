# Acceptance Criteria

The Mission-Scoped Reversible Autonomy cutover is ready for promotion when all
of the following are true.

## Naming And Scope

1. The proposal explicitly keeps **Mission-Scoped Reversible Autonomy** as the
   canonical public-facing model name.
2. The proposal explicitly defines that model as Octon's implementation of
   policy-governed reversible supervisory control.
3. The proposal explicitly states that the cutover is atomic and pre-1.0.
4. The proposal explicitly forbids a long-lived dual live operating model.
5. The proposal explicitly states that historical receipts are retained without
   rewrite.
6. The proposal explicitly states that live autonomous runtime behavior changes
   in one cutover.

## Root Manifest And Architecture Contracts

1. `.octon/octon.yml` is updated to publish the cutover release identifier.
2. `.octon/octon.yml` is updated with runtime-input bindings for missions
   registry, mission control root, ownership registry, and mission-autonomy
   policy.
3. The umbrella architecture specification is updated to declare mission-
   scoped execution control under `state/control/execution/missions/**`.
4. The umbrella architecture specification is updated to declare retained
    control evidence under `state/evidence/control/**`.
5. The umbrella architecture specification is updated to declare generated
    mission/operator summaries under `generated/cognition/summaries/**`.
6. The runtime-vs-ops contract is updated to keep mission-control automation
    inside canonical `state/**` or `generated/**` roots.
7. The contract registry is updated with every new schema/spec introduced by
    this cutover.
8. A canonical governance principle file for Mission-Scoped Reversible
    Autonomy is added.
9. ACP, reversibility, and ownership/boundary principle files are updated to
    align with the new model.

## Mission Authority Upgrade

1. `instance/orchestration/missions/registry.yml` upgrades to
    `octon-mission-registry-v2`.
2. `instance/orchestration/missions/_scaffold/template/mission.yml` upgrades
    to `octon-mission-v2`.
3. `mission.yml` v2 requires mission class.
4. `mission.yml` v2 requires owner reference.
5. `mission.yml` v2 requires risk ceiling.
6. `mission.yml` v2 requires allowed action classes.
7. `mission.yml` v2 requires safe-subset declaration.
8. `mission.yml` v2 requires scope IDs.
9. `mission.yml` v2 requires success criteria.
10. `mission.yml` v2 requires failure conditions.
11. `mission.md` scaffold is updated to explain mode, scope, and safing.
12. Existing active missions are upgraded in the cutover branch.
13. Archived missions may remain historical until reactivated.

## Repo-Owned Policy And Ownership

1. `instance/governance/policies/mission-autonomy.yml` is added.
2. The mission-autonomy policy defines mission-class default modes.
3. The mission-autonomy policy defines execution postures.
4. The mission-autonomy policy defines preview timing defaults.
5. The mission-autonomy policy defines digest cadence defaults.
6. The mission-autonomy policy defines overlap defaults.
7. The mission-autonomy policy defines backfill defaults.
8. The mission-autonomy policy defines pause-on-failure defaults.
9. The mission-autonomy policy defines recovery-window defaults.
10. The mission-autonomy policy defines proceed-on-silence constraints.
11. The mission-autonomy policy defines autonomy burn thresholds.
12. The mission-autonomy policy defines breaker actions.
13. The mission-autonomy policy defines quorum independence rules.
14. `instance/governance/ownership/registry.yml` is added.
15. The ownership registry defines authoritative owners for non-path assets.
16. Directive precedence is explicitly defined across break-glass, mission
    owner, ownership registry, `CODEOWNERS`, and subscribers.

## Runtime And Policy Contracts

1. `execution-request-v2.schema.json` is added.
2. `execution-receipt-v2.schema.json` is added.
3. `policy-receipt-v2.schema.json` is added.
4. `policy-digest-v2.md` is added.
5. `control-receipt-v1.schema.json` is added.
6. `action-slice-v1.schema.json` is added.
7. `intent-register-v1.schema.json` is added.
8. `mode-state-v1.schema.json` is added.
9. `control-directive-v1.schema.json` is added.
10. `schedule-control-v1.schema.json` is added.
11. `autonomy-budget-v1.schema.json` is added.
12. `circuit-breaker-v1.schema.json` is added.
13. `mission-control-lease-v1.schema.json` is added.
14. `mission-autonomy-policy-v1.schema.json` is added.
15. `ownership-registry-v1.schema.json` is added.
16. Autonomous execution requests require mission reference.
17. Autonomous execution requests require slice reference.
18. Autonomous execution requests require intent reference.
19. Autonomous execution requests require oversight mode.
20. Autonomous execution requests require execution posture.
21. Autonomous execution requests require reversibility class.
22. Autonomous execution requests require boundary ID.
23. Autonomous runtime launches deny when autonomy context is missing.
24. New execution receipts include rollback or compensation handle.
25. New execution receipts include recovery window.
26. New execution receipts include autonomy-budget state.
27. New execution receipts include breaker state.
28. Policy digests surface mission ID, slice ID, mode, reversibility,
    rollback handle, and recovery window.

## Mutable Control Truth

1. `state/control/execution/missions/<mission-id>/lease.yml` exists.
2. `.../mode-state.yml` exists.
3. `.../intent-register.yml` exists.
4. `.../directives.yml` exists.
5. `.../schedule.yml` exists.
6. `.../autonomy-budget.yml` exists.
7. `.../circuit-breakers.yml` exists.
8. `.../subscriptions.yml` exists.
9. Existing `budget-state.yml` remains authoritative for spend/data budgets.
10. Existing `exception-leases.yml` remains authoritative for execution waivers.
11. No second mutable control plane is added outside canonical repo surfaces.

## Retained Evidence And Continuity

1. `state/evidence/control/execution/**` is added as a retained evidence
    family.
2. Directives that affect active execution or durable outcome emit control
    receipts.
3. Authorize-updates emit control receipts.
4. Lease changes emit control receipts.
5. Breaker trips and resets emit control receipts.
6. Safing and break-glass changes emit control receipts.
7. Mission continuity lives under `state/continuity/repo/missions/**`.
8. Mission continuity is not stored in generated views.
9. `Recent` summaries are projections over receipts and continuity, not a new
    authoritative journal.

## Mode Semantics

1. The model retains `silent`, `notify`, `feedback_window`,
    `proceed_on_silence`, and `approval_required`.
2. The model retains `interruptible_scheduled` as an execution posture rather
    than collapsing it into a flat mode list.
3. Silence is explicitly defined as continued delegation, not consent.
4. Proceed-on-silence is allowed only for reversible or tightly bounded
    compensable work with published feedback windows and healthy trust state.
5. Approval-required covers irreversible, public, financial, legal,
    credential, or no-credible-rollback actions.
6. `STAGE_ONLY` is explicitly defined as the humane fail-closed fallback.
7. Hard deny is explicitly defined for policy-violating or missing-context
    paths.
8. Safing is explicitly defined as authority contraction, not mere pause.

## Interaction Model

1. The proposal explicitly adopts `Inspect / Signal / Authorize-Update`.
2. `Inspect` is read-only and non-authoritative.
3. `Signal` is asynchronous steering, not approval.
4. `Authorize-Update` is authority mutation, not casual feedback.
5. External comments or UI interactions are not binding until translated into
     canonical control truth.
6. Humans can intervene before execution.
7. Humans can intervene during execution at safe boundaries.
8. Humans can intervene after execution through rollback/compensation and
     finalize blocking.

## Scheduling, Digests, And Notifications

1. The proposal explicitly distinguishes future-run suspension from active-run
     pause.
2. The proposal explicitly defines overlap policy.
3. The proposal explicitly defines backfill policy.
4. The proposal explicitly defines pause-on-failure.
5. The proposal explicitly defines preview timing defaults.
6. The proposal explicitly defines digest cadence defaults by mission class.
7. The proposal explicitly routes awareness by owners first and subscribers
     second.
8. Continuous heartbeat chatter is explicitly rejected as a default awareness
     mechanism.

## Reversibility And Recovery

1. The proposal explicitly defines `reversible`, `compensable`, and
     `irreversible`.
2. The proposal explicitly states that compensation is weaker than rollback.
3. Promote and finalize remain separate steps.
4. Default recovery windows are defined in repo policy.
5. Late feedback semantics are defined before stage, after stage, after
     promote, after recovery expiry, and after finalize.
6. The proposal explicitly states that reversible design can reduce the need
     for blanket pre-execution approval.
7. The proposal explicitly states that some actions must not rely on
     "recover later".

## Escalation And Trust Tightening

1. Autonomy burn budgets are separate from spend/data budgets.
2. The proposal defines `healthy`, `warning`, and `exhausted` burn states.
3. The proposal defines breaker trip conditions.
4. The proposal defines breaker actions.
5. The proposal defines safing behavior.
6. The proposal defines break-glass requirements.
7. The proposal requires postmortem follow-up for break-glass.

## Generated Operator Views

1. Generated mission `now.md` exists.
2. Generated mission `next.md` exists.
3. Generated mission `recent.md` exists.
4. Generated mission `recover.md` exists.
5. Generated operator digests exist under `generated/cognition/summaries/operators/**`.
6. Generated views are explicitly non-authoritative.
7. Generated views are refreshed from canonical control/evidence/continuity
     surfaces only.

## Scenario Conformance

1. There is conformance coverage for routine repo housekeeping.
2. There is conformance coverage for long-running refactor.
3. There is conformance coverage for scheduled dependency patching.
4. There is conformance coverage for release maintenance.
5. There is conformance coverage for infra drift correction.
6. There is conformance coverage for cost cleanup or soft delete.
7. There is conformance coverage for data migration or backfill.
8. There is conformance coverage for external API sync.
9. There is conformance coverage for monitoring or guard missions.
10. There is conformance coverage for production incident response.
11. There is conformance coverage for high-volume low-risk repetitive work.
12. There is conformance coverage for destructive high-impact work.
13. There is conformance coverage for absent operator behavior.
14. There is conformance coverage for late feedback.
15. There is conformance coverage for conflicting human input.
16. There is conformance coverage for rollback-path failure.
17. There is conformance coverage for breaker trip and safing entry.
18. There is conformance coverage for break-glass activation.

## Documentation And Bootstrap

1. `.octon/README.md` is updated to explain Mission-Scoped Reversible
     Autonomy.
2. `.octon/instance/bootstrap/START.md` is updated to explain the mission
     authority/control/evidence/read-model split.
3. The proposal registry is updated with this proposal entry.
4. A canonical decision record or ADR is added when the cutover lands.
5. No implementation or docs path continues to describe the old ad hoc
     autonomy posture as current after cutover.

## Proposal Package Completeness

1. `navigation/artifact-catalog.md` exists and inventories the proposal-local
   artifacts plus the required registry companion artifact.
2. `resources/current-state-gap-analysis.md` exists and names the current
   live repo gaps this cutover must close.
3. `architecture/validation-plan.md` exists and defines blocking validators,
   scenario suites, and promotion gates.
4. `architecture/cutover-checklist.md` exists and defines the branch-level
   atomic sequence, merge gate, immediate post-merge checks, and rollback
   triggers.
5. `architecture/implementation-plan.md` names the durable migration-plan
   path and retained evidence-bundle path for the cutover.
6. `proposal.yml` and `README.md` include the durable migration, decision,
   and cutover-evidence closeout surfaces in their promotion targets or exit
   path.
7. The active proposals registry contains this proposal entry while it
   remains active.

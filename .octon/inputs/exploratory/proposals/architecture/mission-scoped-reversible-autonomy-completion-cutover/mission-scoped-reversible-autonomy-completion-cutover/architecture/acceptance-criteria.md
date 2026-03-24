# Acceptance Criteria

The MSRAOM completeness cutover is ready for promotion only when all of the
following are true.

## Naming And Scope

1. The proposal explicitly keeps **Mission-Scoped Reversible Autonomy** as the
   canonical public-facing model name.
2. The proposal explicitly defines that model as Octon’s implementation of
   policy-governed reversible supervisory control.
3. The proposal explicitly states that the cutover is atomic and pre-1.0.
4. The proposal explicitly forbids a long-lived dual live operating model.
5. The proposal explicitly states that historical receipts are retained without
   rewrite.
6. The proposal explicitly states that live autonomous runtime behavior changes
   in one cutover.

## Root Manifest And Architecture Contracts

1. `version.txt` is bumped to `0.6.0`.
2. `.octon/octon.yml` is updated to publish the completion cutover release.
3. `.octon/octon.yml` is updated with runtime-input bindings for:
   - mission registry
   - mission control root
   - ownership registry
   - mission-autonomy policy
   - generated effective route root
   - generated mission/operator summary roots
4. The umbrella architecture specification is updated to declare mission-scoped
   execution control under `state/control/execution/missions/**`.
5. The umbrella architecture specification is updated to declare retained
   control evidence under `state/evidence/control/**`.
6. The umbrella architecture specification is updated to declare generated
   mission/operator summaries under `generated/cognition/summaries/**`.
7. The umbrella architecture specification is updated to declare generated
   effective scenario resolution under `generated/effective/**`.
8. The runtime-vs-ops contract is updated to keep mission-control automation
   inside canonical `state/**` or `generated/**` roots.
9. The contract registry is updated with every new schema introduced by the
   cutover.
10. A canonical governance principle file for Mission-Scoped Reversible
    Autonomy exists and is aligned with the final model.
11. ACP, reversibility, ownership/boundary, and progressive-disclosure
    principle files are updated to align with the completed model.

## Mission Authority Upgrade

1. `instance/orchestration/missions/registry.yml` remains v2 and is aligned with
   the final mission charter.
2. `instance/orchestration/missions/_scaffold/template/mission.yml` remains
   `octon-mission-v2`.
3. `mission.yml` v2 requires mission class.
4. `mission.yml` v2 requires owner reference (`owner_ref`).
5. `mission.yml` v2 requires risk ceiling.
6. `mission.yml` v2 requires allowed action classes.
7. `mission.yml` v2 requires safe-subset declaration.
8. `mission.yml` v2 requires scope IDs.
9. `mission.yml` v2 requires success criteria.
10. `mission.yml` v2 requires failure conditions.
11. `mission.md` scaffold explains mode, scope, safe subset, and safing.
12. Active missions are upgraded in the cutover branch.
13. Runtime readers consume `owner_ref` rather than legacy `owner`.
14. Any temporary legacy reader shim is covered by regression tests and removed
    once no active mission depends on it.

## Repo-Owned Policy And Ownership

1. `instance/governance/policies/mission-autonomy.yml` remains canonical.
2. The mission-autonomy policy defines mission-class default oversight modes.
3. The mission-autonomy policy defines execution postures.
4. The mission-autonomy policy defines preview timing defaults.
5. The mission-autonomy policy defines digest cadence defaults.
6. The mission-autonomy policy defines overlap defaults.
7. The mission-autonomy policy defines backfill defaults.
8. The mission-autonomy policy defines pause-on-failure defaults.
9. The mission-autonomy policy defines recovery-window defaults.
10. The mission-autonomy policy defines proceed-on-silence constraints.
11. The mission-autonomy policy defines autonomy-burn thresholds.
12. The mission-autonomy policy defines breaker actions.
13. The mission-autonomy policy defines safe interrupt boundary defaults.
14. The mission-autonomy policy defines quorum independence rules.
15. `instance/governance/ownership/registry.yml` remains canonical.
16. The ownership registry defines authoritative owners for non-path assets.
17. Directive precedence is explicitly defined across break-glass, kill switch,
    mission owner, ownership registry, `CODEOWNERS`, and subscribers.

## Runtime And Policy Contracts

1. `execution-request-v2.schema.json` remains canonical and aligned.
2. `execution-receipt-v2.schema.json` remains canonical and aligned.
3. `policy-receipt-v2.schema.json` remains canonical and aligned.
4. `policy-digest-v2.md` remains canonical and aligned.
5. `control-receipt-v1.schema.json` is added.
6. `action-slice-v1.schema.json` is added.
7. `intent-register-v1.schema.json` is added.
8. `mode-state-v1.schema.json` is added.
9. `control-directive-v1.schema.json` is added.
10. `schedule-control-v1.schema.json` is added.
11. `autonomy-budget-v1.schema.json` is added.
12. `circuit-breaker-v1.schema.json` is added.
13. `mission-control-lease-v1.schema.json` is added.
14. `subscriptions-v1.schema.json` is added.
15. `scenario-resolution-v1.schema.json` is added.
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
28. Policy digests surface mission ID, slice ID, mode, reversibility, rollback
    handle, and recovery window.
29. Runtime does not use undocumented hardcoded recovery defaults for material
    execution.
30. Runtime consumes mission-autonomy policy rather than merely asserting that
    the file exists.

## Mutable Control Truth

1. `state/control/execution/missions/<mission-id>/lease.yml` exists and validates.
2. `.../mode-state.yml` exists and validates.
3. `.../intent-register.yml` exists and validates.
4. `.../directives.yml` exists and validates.
5. `.../schedule.yml` exists and validates.
6. `.../autonomy-budget.yml` exists and validates.
7. `.../circuit-breakers.yml` exists and validates.
8. `.../subscriptions.yml` exists and validates.
9. Existing `budget-state.yml` remains authoritative for spend/data budgets.
10. Existing `exception-leases.yml` remains authoritative for execution waivers.
11. No second mutable control plane is added outside canonical repo surfaces.
12. Mission scaffolding creates the full control-file family for autonomous
    missions.
13. Validators reject autonomous missions missing required control files.

## Retained Evidence And Continuity

1. `state/evidence/control/execution/**` exists as a retained evidence family.
2. Directives that affect active or future execution emit control receipts.
3. Authorize-updates emit control receipts.
4. Lease changes emit control receipts.
5. Schedule mutations emit control receipts.
6. Breaker trips and resets emit control receipts.
7. Safing changes emit control receipts.
8. Break-glass activations and clearings emit control receipts.
9. Mission continuity lives under `state/continuity/repo/missions/**`.
10. Mission continuity is not stored in generated views.
11. `Recent` summaries are projections over receipts and continuity, not a new
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

1. The completed model explicitly adopts `Inspect / Signal / Authorize-Update`.
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

1. The completed model explicitly distinguishes future-run suspension from
   active-run pause.
2. Overlap policy is explicit and machine-consumable.
3. Backfill policy is explicit and machine-consumable.
4. Pause-on-failure is explicit and machine-consumable.
5. Preview timing defaults are explicit and machine-consumable.
6. Digest cadence defaults by mission class are explicit and machine-consumable.
7. Awareness routing is owners-first and subscribers-second.
8. Continuous heartbeat chatter is explicitly rejected as a default awareness
   mechanism.
9. Scheduler runtime consumes the canonical schedule control record.
10. Scheduler runtime consumes the effective scenario-resolution output.

## Reversibility And Recovery

1. The completed model explicitly defines `reversible`, `compensable`, and
   `irreversible`.
2. The completed model explicitly states that compensation is weaker than
   rollback.
3. Promote and finalize remain separate steps.
4. Default recovery windows are defined in repo policy.
5. Late feedback semantics are defined before stage, after stage, after
   promote, after recovery expiry, and after finalize.
6. The completed model explicitly states that reversible design can reduce the
   need for blanket pre-execution approval.
7. The completed model explicitly states that some actions must not rely on
   “recover later”.
8. Rollback or compensation handles are surfaced in receipts and `recover.md`.

## Escalation And Trust Tightening

1. Autonomy burn budgets are separate from spend/data budgets.
2. The completed model defines `healthy`, `warning`, and `exhausted` burn states.
3. The completed model defines breaker trip conditions.
4. The completed model defines breaker actions.
5. The completed model defines safing behavior.
6. The completed model defines break-glass requirements.
7. The completed model requires postmortem follow-up for break-glass.
8. Runtime automatically updates autonomy burn from evidence.
9. Runtime automatically trips and resets breaker state based on evidence and
   authorized resets.

## Scenario Resolution

1. A derived scenario-resolution artifact exists under
   `generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`.
2. The scenario-resolution artifact has a durable schema.
3. The scenario-resolution artifact is freshness-bounded.
4. Scheduler behavior consumes it.
5. Generated mission summaries consume it.
6. The route is derived from canonical mission, policy, and control surfaces.
7. No second authoritative scenario registry is introduced.
8. Scenario routing covers at least:
   - routine housekeeping
   - long-running refactor
   - dependency/security patching
   - release maintenance
   - infrastructure drift correction
   - cost cleanup
   - migration/backfill
   - external API sync
   - monitoring / observe-only
   - incident response
   - high-volume repetitive work
   - destructive high-impact work
   - absent human
   - late human feedback
   - conflicting human input

## Generated Operator Views

1. Generated mission `now.md` exists.
2. Generated mission `next.md` exists.
3. Generated mission `recent.md` exists.
4. Generated mission `recover.md` exists.
5. Generated operator digests exist under `generated/cognition/summaries/operators/**`.
6. Generated views are explicitly non-authoritative.
7. Generated views are refreshed from canonical control/evidence/continuity
   surfaces only.
8. Generated views are not placeholder-only after merge.

## Scenario Conformance

1. There is conformance coverage for routine repo housekeeping.
2. There is conformance coverage for long-running refactor.
3. There is conformance coverage for dependency patching.
4. There is conformance coverage for release maintenance.
5. There is conformance coverage for infrastructure drift correction.
6. There is conformance coverage for cost cleanup.
7. There is conformance coverage for migration/backfill.
8. There is conformance coverage for external sync.
9. There is conformance coverage for observe-only monitoring.
10. There is conformance coverage for incident containment.
11. There is conformance coverage for high-volume repetitive work.
12. There is conformance coverage for destructive irreversible work.
13. There is conformance coverage for absent-human behavior.
14. There is conformance coverage for late-feedback behavior.
15. There is conformance coverage for conflicting-human-input behavior.
16. There is conformance coverage for breaker and safing behavior.
17. There is conformance coverage for finalize-block behavior.

## Contradiction Cleanup

1. Repo docs no longer claim canonical surfaces that do not exist.
2. No runtime-required mission control file lacks a durable contract.
3. No orchestration reader uses legacy `owner` as canonical after the cutover.
4. No hidden fallback recovery semantics remain for material work.
5. No generated summary or effective route is used while stale.

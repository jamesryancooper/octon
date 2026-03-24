# Target Architecture

## Decision

Ratify one atomic, clean-break operating-model cutover where all long-running
or always-running autonomous Octon agents run under **Mission-Scoped
Reversible Autonomy**.

Under this cutover:

- the public-facing model name remains **Mission-Scoped Reversible Autonomy**
- supervisory control is integrated into the model definition instead of
  replacing the name
- every autonomous agent run is mission-scoped and bound to durable mission
  authority under `instance/orchestration/missions/**`
- every material autonomous action is decomposed into a governed action slice
  with forward intent, explicit mode, reversibility class, and safe interrupt
  boundary
- every material execution attempt still passes the engine-owned
  `authorize_execution(...)` boundary and ACP promote/finalize gates
- routine work remains non-blocking by default, but no material autonomous path
  may proceed without intent binding, grants, receipts, and recovery metadata
- human oversight is supervisory and mostly asynchronous:
  inspect, signal, and authorize-update are separate control paths
- `STAGE_ONLY` remains the humane fail-closed fallback when promote/finalize
  prerequisites are missing but staging is still safe and useful
- no second authoritative run journal, external control plane, or ad hoc
  approval queue is introduced
- the implementation ships as one pre-1.0 cutover with no dual live operating
  model and no legacy compatibility mode for new autonomous runs

This proposal is the implementation contract for that cutover.

## Status

- status: accepted
- cutover style: atomic, repo-wide, pre-1.0 clean break
- release intent: ship as the next harness minor release after `0.5.5`
  (`0.6.0` is the recommended cutover release identifier)
- proposal area:
  mission authority, supervisory control semantics, runtime/policy contracts,
  control truth, retained control evidence, generated operator views, and
  assurance/conformance
- dependencies:
  - `migration-rollout`
  - `runtime-execution-governance-hardening`
  - `harness-integrity-tightening`
  - `framework-core-architecture`
  - `repo-instance-architecture`
  - `state-evidence-continuity`

## Why This Proposal Exists

Octon already has the right backbone:

- `framework/**` and `instance/**` are authored authority
- `state/**` carries operational truth and retained evidence
- `generated/**` is never authoritative
- material execution already passes the engine authorization boundary
- ACP already governs promote/finalize
- receipts, budgets, and fail-closed policy contracts already exist

What Octon does not yet have as one integrated operating model is:

- a durable mission charter rich enough to serve as standing delegation for
  always-running agents
- an explicit live mode beacon
- a forward intent register
- a formal interaction grammar separating awareness, intervention, and approval
- mission-scoped schedule semantics
- autonomy burn budgets and oversight circuit breakers
- a canonical safing posture
- mission-scoped generated Now / Next / Recent / Recover views
- one repo-native source-of-truth arrangement for all of the above

This proposal lands those pieces in one cutover instead of layering them
piecemeal or asking operators to reason across undocumented conventions.

## Canonical Name And Public Posture

**Canonical name:** Mission-Scoped Reversible Autonomy

**Explanatory definition:** Octon's Mission-Scoped Reversible Autonomy model is
its implementation of policy-governed reversible supervisory control:
a mission-scoped controller operates under standing delegation, publishes
forward intent and explicit live oversight/safety mode, and commits durable
state only through reversible ACP-governed slices with grants, receipts,
recovery windows, and asynchronous human steering.

Why this naming is final:

- it preserves continuity with Octon's existing research and terminology
- it keeps the emphasis on governed autonomy rather than operator gatekeeping
- it avoids confusion with approval-heavy control models
- it still incorporates the independent research's supervisory-control framing
  in the model definition and implementation details

## Clean-Break Cutover Rules

This proposal requires a **big bang, clean break, atomic update**.

### What "atomic" means

1. The mission charter upgrade, runtime contract upgrade, mutable control-state
   surfaces, retained control evidence, and generated operator views land in
   one cutover branch and merge together.
2. After the cutover, autonomous runtime paths MUST require the new mission
   autonomy context; legacy autonomous launch conventions are rejected.
3. There is no long-lived parallel operating model and no soft migration where
   some autonomous runs use mission control and others do not.
4. Historical retained evidence is not rewritten. Old receipts remain valid as
   historical evidence; only new runtime emissions switch to the new contracts.
5. If required mission-control surfaces are missing after cutover, the runtime
   fails closed or falls back to `STAGE_ONLY` as declared by policy. It does
   not silently drop back to ad hoc autonomy.

### What "clean break" forbids

- no hidden in-memory control state
- no external UI-owned control store
- no second activity log distinct from receipts plus continuity
- no "temporary" autonomous path that skips mission authority or mode state
- no compatibility path that omits mission/slice/reversibility fields for
  autonomous runs
- no chat comment or external issue comment treated as binding until it is
  translated into canonical control truth

## Governing Philosophy

The operating model is defined by five rules:

1. **Autonomy is continuous by default.**
   Missions may keep moving without re-asking for permission on every slice.
2. **Authority is never ambient.**
   Continuation leases, grants, ACP gates, budgets, and breakers still govern
   material side effects.
3. **Oversight is supervisory, not approval-heavy.**
   Humans stay on the loop through visibility, asynchronous directives, and
   recovery—not through constant runtime blocking.
4. **Reversibility is a control primitive.**
   Strong rollback and compensation design reduce the need for blanket
   pre-execution approval, but never replace policy.
5. **Evidence extends control across time.**
   Intent publication, receipts, rollback handles, recovery windows, and
   finalize blockers keep governance meaningful before, during, and after
   execution.

## Final Control Dimensions

These dimensions stay distinct everywhere in the cutover:

- **Awareness:** what a human can see without stopping the mission
- **Intervention:** what a human can change asynchronously while the mission
  continues or pauses at a boundary
- **Approval:** which actions must wait for explicit authority mutation
- **Reversibility:** what can still be rolled back or compensated after
  execution

Notifications are not oversight.
Silence is not consent.
Reversibility is not permission.

## Final Layered Architecture

### 1. Mission Authority Layer

**Purpose:** durable desired outcome and standing delegation envelope.

**Canonical surfaces:**

- `instance/orchestration/missions/registry.yml`
- `instance/orchestration/missions/<mission-id>/mission.yml`
- `instance/orchestration/missions/<mission-id>/mission.md`

**Contract:**

- mission authority lives only under `instance/**`
- mission authority defines outcome, scope, owner, success/failure conditions,
  allowed action classes, mission class, risk ceiling, default schedule hints,
  and safe-subset declaration for safing mode
- mission authority does not grant per-action execution permission

### 2. Forward Intent And Planning Layer

**Purpose:** publish upcoming material work before execution.

**Canonical surface:**

- `state/control/execution/missions/<mission-id>/intent-register.yml`

**Contract:**

- the register is mutable operational truth, not authored mission authority
- it contains versioned action slices with earliest start, feedback deadline,
  reversibility class, blast radius, boundary class, and default-on-silence
  semantics
- operator notices and `Next` views are derived from it

### 3. Live Mode And Control-State Layer

**Purpose:** expose the current authority and execution state explicitly.

**Canonical surfaces:**

- `state/control/execution/missions/<mission-id>/lease.yml`
- `state/control/execution/missions/<mission-id>/mode-state.yml`
- `state/control/execution/missions/<mission-id>/schedule.yml`
- `state/control/execution/missions/<mission-id>/directives.yml`
- `state/control/execution/missions/<mission-id>/autonomy-budget.yml`
- `state/control/execution/missions/<mission-id>/circuit-breakers.yml`
- `state/control/execution/missions/<mission-id>/subscriptions.yml`

### 4. Human Interaction Layer

**Purpose:** formalize how humans observe and steer the mission.

**Interaction grammar:**

- **Inspect**
- **Signal**
- **Authorize-Update**

These are separate control categories and must never be collapsed into one
generic "approval" action.

### 5. Governance Gate Layer

**Purpose:** preserve machine-enforced policy and fail-closed behavior.

**Canonical surfaces:**

- engine authorization boundary
- ACP policy and receipts
- repo-owned network egress policy
- repo-owned execution-budget policy
- executor profile controls

### 6. Recovery And Finalize Layer

**Purpose:** keep post-start governance meaningful.

**Canonical semantics:**

- stage
- promote
- recovery window
- finalize
- rollback or compensation handle
- block finalize

### 7. Evidence And Continuity Layer

**Purpose:** retain what happened, why it was allowed, and what remains open.

**Canonical surfaces:**

- `state/evidence/runs/**`
- `state/evidence/control/execution/**`
- `state/continuity/repo/missions/**`

### 8. Escalation Layer

**Purpose:** tighten autonomy automatically when evidence says trust is being
burned.

**Canonical surfaces:**

- `state/control/execution/missions/<mission-id>/autonomy-budget.yml`
- `state/control/execution/missions/<mission-id>/circuit-breakers.yml`
- mode-state safing / break-glass fields
- mission-autonomy repo policy defaults

### 9. Derived Read-Model Layer

**Purpose:** give humans useful, low-friction visibility without creating
another authority surface.

**Canonical generated outputs:**

- `generated/cognition/summaries/missions/<mission-id>/now.md`
- `generated/cognition/summaries/missions/<mission-id>/next.md`
- `generated/cognition/summaries/missions/<mission-id>/recent.md`
- `generated/cognition/summaries/missions/<mission-id>/recover.md`
- `generated/cognition/summaries/operators/<operator-id>/**`

## Required Surface Layout

```text
.octon/
  octon.yml
  framework/
    cognition/
      governance/
        principles/
          mission-scoped-reversible-autonomy.md
          autonomous-control-points.md         # updated
          reversibility.md                     # updated
          ownership-and-boundaries.md          # updated
      _meta/
        architecture/
          specification.md                     # updated
          runtime-vs-ops-contract.md           # updated
          contract-registry.yml                # updated
    engine/
      runtime/
        spec/
          mission-charter-v2.schema.json
          mission-autonomy-policy-v1.schema.json
          ownership-registry-v1.schema.json
          mission-control-lease-v1.schema.json
          action-slice-v1.schema.json
          intent-register-v1.schema.json
          mode-state-v1.schema.json
          control-directive-v1.schema.json
          schedule-control-v1.schema.json
          autonomy-budget-v1.schema.json
          circuit-breaker-v1.schema.json
          execution-request-v2.schema.json
          execution-receipt-v2.schema.json
          policy-receipt-v2.schema.json
          policy-digest-v2.md
          control-receipt-v1.schema.json
        config/
          policy-interface.yml                 # updated
        crates/
          kernel/                              # updated
          policy_engine/                       # updated
    orchestration/
      runtime/
        workflows/                             # updated
    assurance/
      runtime/                                 # updated
  instance/
    orchestration/
      missions/
        README.md                              # updated
        registry.yml                           # octon-mission-registry-v2
        _scaffold/
          template/
            mission.yml                        # octon-mission-v2
            mission.md                         # updated
            tasks.json
            log.md
        <mission-id>/
          mission.yml
          mission.md
          tasks.json
          log.md
          context/
    governance/
      policies/
        mission-autonomy.yml                   # new
        execution-budgets.yml                  # existing, still authoritative
        network-egress.yml                     # existing, still authoritative
      ownership/
        registry.yml                           # new
  state/
    control/
      execution/
        budget-state.yml                       # existing spend/token state
        exception-leases.yml                   # existing waiver state
        missions/
          <mission-id>/
            lease.yml
            mode-state.yml
            intent-register.yml
            directives.yml
            schedule.yml
            autonomy-budget.yml
            circuit-breakers.yml
            subscriptions.yml
    continuity/
      repo/
        missions/
          <mission-id>/
            next-actions.yml
            handoff.md
    evidence/
      runs/
        <run-id>/
          ...
      control/
        execution/
          <timestamp>-<event-id>.yml
  generated/
    cognition/
      summaries/
        missions/
          <mission-id>/
            now.md
            next.md
            recent.md
            recover.md
        operators/
          <operator-id>/
            ...
      projections/
        materialized/
          missions/
            <mission-id>.json
```

## Final Primitive Catalog

| Primitive | Canonical surface | Kind | Required semantics |
| --- | --- | --- | --- |
| Mission charter | `instance/orchestration/missions/<mission-id>/mission.yml` | authored authority | Durable goal, owner, scope, mission class, risk ceiling, allowed action classes, safe subset, success criteria. |
| Mission registry | `instance/orchestration/missions/registry.yml` | authored authority | Canonical mission discovery; upgrade to v2 and keep archive semantics. |
| Continuation lease | `state/control/execution/missions/<mission-id>/lease.yml` | mutable control truth | Separate mission continuity from per-action grants; carries status, expiry, concurrency cap, and allowed continuation envelope. |
| Action slice | `intent-register.yml` entries | operational truth | Smallest independently governable material unit; includes ACP prediction, reversibility class, boundary class, expected impact, and evidence plan. |
| Forward intent register | `intent-register.yml` | mutable control truth / operational truth | Versioned queue of upcoming material slices, earliest start, feedback deadline, operator options, and default-on-silence semantics. |
| Mode beacon | `mode-state.yml` | mutable control truth | Explicit `oversight_mode`, `execution_posture`, `safety_state`, phase, current slice, active run, and next boundary. |
| Feedback window | `intent-register.yml` + `schedule.yml` | mutable control truth | Non-blocking pre-start or pre-promote interval where humans may steer without forced approval. |
| Control directive | `directives.yml` | mutable control truth | Binding asynchronous steering: pause, suspend future runs, reprioritize, narrow scope, exclude target, veto next promote, block finalize. |
| Authorize-update | control receipt + affected control file | mutable control truth + evidence | Explicit authority mutation: approval, budget raise, owner attestation, breaker reset, break-glass, lease changes, exception issuance. |
| Safe interrupt boundary | action-slice boundary metadata + `mode-state.yml` | workflow authority + operational truth | Declares where an active run may pause safely and deterministically. |
| Schedule control record | `schedule.yml` | mutable control truth | Future-run suspension, active-run pause, overlap, backfill, preview lead, pause-on-failure, quiet-hours behavior. |
| Exception / waiver lease | `exception-leases.yml` and related mission refs | mutable control truth | Time-boxed relaxation of a control; never equivalent to mission continuity or irreversible permission. |
| Execution grant bundle | engine-issued grant | authoritative execution control | Mandatory before any material side effect. |
| Execution receipt | `state/evidence/runs/<run-id>/**` | retained evidence | What happened, why it was allowed or denied, which policies applied, and what recovery exists. |
| Control receipt | `state/evidence/control/execution/**` | retained evidence | Retained proof for directives, authorize-updates, breaker trips, safing, and break-glass. |
| Rollback / compensation handle | run receipt + `recover` view | retained evidence | Explicit recovery reference, expiry, and owner. |
| Recovery window | receipt + `mode-state.yml` / `recover` view | mutable control truth + evidence binding | Period after promote when rollback/compensation is guaranteed and finalize may still be blocked. |
| Operator subscription | `subscriptions.yml` | mutable control truth | Mission watch, digest, and alert routing. |
| Autonomy burn budget | `autonomy-budget.yml` | mutable control truth | Measures trust burn and drives automatic tightening. |
| Oversight circuit breaker | `circuit-breakers.yml` | mutable control truth | Deterministic, machine-enforced tightening, pausing, or safing. |
| Safing declaration | `mode-state.yml` + control receipt | mutable control truth + evidence | Restricted safe subset: observe-only, stage-only, or bounded containment. |
| Break-glass activation | control truth + control receipt | mutable control truth + evidence | Exceptional, time-boxed override with explicit accountability and postmortem requirement. |

## Final Mission Charter Upgrade

`mission.yml` upgrades from `octon-mission-v1` to `octon-mission-v2`.

### Required v2 additions

At minimum, `octon-mission-v2` must add:

- `mission_class`
- `risk_ceiling`
- `allowed_action_classes`
- `default_safing_subset`
- `default_schedule_hint`
- `default_overlap_policy`
- `owner_ref`
- `scope_ids`
- `success_criteria`
- `failure_conditions`
- `notes_ref` or inline notes field

### Recommended mission classes

To minimize additive complexity while covering all required agent classes, use:

- `observe`
- `campaign`
- `reconcile`
- `maintenance`
- `migration`
- `incident`
- `destructive`

Domain-specific tags such as `coding`, `infra`, `security`, `repo`,
`external-sync`, or `ops` MAY be added as non-authoritative descriptors, but
mission class drives the default control posture.

## Final Mode Model

The cutover keeps Octon's richer mode model.

### Oversight mode

- `silent`
- `notify`
- `feedback_window`
- `proceed_on_silence`
- `approval_required`

### Execution posture

- `one_shot`
- `continuous`
- `interruptible_scheduled`

### Safety state

- `active`
- `paused`
- `degraded`
- `safe`
- `break_glass`

### Phase

- `planning`
- `staging`
- `promoting`
- `running`
- `recovering`
- `finalizing`
- `closed`

`interruptible_scheduled` remains a posture overlay for long-running or
recurring work. It does not replace the oversight mode.

## Final Execution Mode Rules

### Silent

Use for local, routine, high-confidence, truly reversible or discardable work.
Silence means the standing delegation still applies. It never means consent.

### Notify

Use when work is still reversible but materially interesting to an owner or
shared surface. Notice does not block.

### Feedback window

Use when human preference or coordination matters but policy does not require
approval. Silence means continue after the declared deadline.

### Proceed on silence

Allowed only when all of the following are true:

- reversibility class is `reversible` or tightly bounded `compensable`
- rollback or compensation path is declared before start
- blast radius is bounded and visible
- the slice is already inside mission scope and allowed action classes
- feedback deadline and operator options were published
- no required attestation, review, or approval is missing
- no public, financial, legal, identity, credential, or safety commitment is
  involved
- autonomy burn budget is not in `warning` or `exhausted`
- no breaker is currently tightening the mission

### Approval required

Mandatory when any of the following apply:

- reversibility class is `irreversible`
- ACP-4 or equivalent point-of-no-return step
- public release or publication boundary requiring human review
- money movement, legal commitment, credential or identity change without a
  proven reversible path
- unresolved authoritative owner conflict
- no credible rollback or compensation path
- active safing policy elevates the step

### STAGE_ONLY

`STAGE_ONLY` is the correct fallback when:

- staging is safe and useful
- promote or finalize prerequisites are missing
- required attestation/review is absent
- cost evidence is missing but staging is allowed
- autonomy burn or breaker state allows work preparation but not durable
  promotion

### Hard deny

Hard deny is correct when:

- the autonomous request violates policy
- mission or intent binding is missing or invalid
- scope is outside the mission or denied by ownership/boundary policy
- egress or spend policy denies
- a kill switch is active
- the action is irreversible and no explicit approval or break-glass exists

### Safing

Safing is correct when:

- trust is degraded enough that normal autonomy is no longer acceptable
- observability is missing for risky work
- the breaker has tripped or autonomy burn is exhausted
- operators are absent during ambiguous high-risk conditions
- rollback guarantees are missing on a class that normally depends on them

Safing contracts authority down to the mission's declared safe subset.

## Final Interaction Grammar

### Inspect

Read-only mission visibility:

- mode beacon
- intent register
- recent receipts
- recovery state
- continuity
- budget and breaker status

Implemented through derived views over canonical surfaces.

### Signal

Asynchronous steering that changes mutable control truth without itself widening
authority:

- `pause_at_boundary`
- `suspend_future_runs`
- `stop_after_slice`
- `reprioritize`
- `narrow_scope`
- `exclude_target`
- `veto_next_promote`
- `block_finalize`
- `enter_safe_mode`

Signals must materialize into canonical control truth and emit control receipts
when they affect active execution or durable decisions.

### Authorize-Update

Synchronous authority mutation:

- explicit approval
- continuation lease grant/extension/revocation
- spend cap raise
- owner attestation
- exception/waiver lease
- breaker reset
- enter or exit break-glass

Authorize-updates always emit control receipts.

## Final Scheduling And Notification Model

### Preview timing defaults

Preview timing is policy-driven by mission class and schedule interval.

Recommended default rules in `mission-autonomy.yml`:

- interval `>= 24h`: preview `24h` before start, feedback deadline `1h` before start
- interval `>= 1h` and `< 24h`: preview at `10%` of interval before start,
  with `15m` floor and `2h` cap; feedback deadline at `25%` of preview lead
- interval `< 1h`: no push preview by default unless the mission is
  operator-interesting or policy elevates it

### Digest cadence defaults by mission class

These defaults resolve the open digest-cadence question:

| Mission class | Default awareness route | Default cadence |
| --- | --- | --- |
| `observe` | digest + threshold alert only | daily digest, immediate anomaly alert |
| `campaign` | start/finish notice + progress digest | every 12h while active |
| `reconcile` | watch for owners + digest | every 6h while active; immediate on breaker or feedback window |
| `maintenance` | preview notice + closure digest | one preview per run, one closure digest per run |
| `migration` | preview + watch + closure digest | at phase open, every checkpoint batch if active > 6h, final closure digest |
| `incident` | immediate alert | immediate on open, containment, safing, breaker, closeout |
| `destructive` | explicit approval request | no batching for approval or finalize-expiry notices |

Continuous heartbeats are forbidden as a default human-awareness mechanism.

### Ownership routing

Default routing order:

1. mission owner from `mission.yml`
2. authoritative ownership registry for affected asset or service
3. repo-path owners from `CODEOWNERS`
4. optional subscribers in `subscriptions.yml`

Subscribers may widen awareness but do not outrank owners.

### Future-run suspension vs active-run pause

The cutover resolves this distinction explicitly:

- **future-run suspension** changes only `schedule.yml` and prevents new runs
- **active-run pause** affects the current run and takes effect only
  immediately when safe or at the next declared interrupt boundary

### Overlap and backfill defaults

Default overlap policies in `mission-autonomy.yml`:

- `observe`: `allow_concurrent`
- `campaign`: `skip`
- `reconcile`: `queue_latest`
- `maintenance`: `skip`
- `migration`: `skip`
- `incident`: `cancel_older_at_boundary`
- `destructive`: `skip`

Default backfill policies:

- `observe`: `none`
- `campaign`: `latest_only`
- `reconcile`: `bounded_catchup`
- `maintenance`: `latest_only`
- `migration`: `none`
- `incident`: `none`
- `destructive`: `none`

### Pause-on-failure defaults

Pause-on-failure is a schedule property, not an ad hoc human habit.

Default pause-on-failure should trigger for:

- rollback-path failure
- any breaker trip
- missing observability on risky work
- repeated promote denials on the same slice class
- out-of-blast-radius side effect
- control-surface corruption or missing mission mode state

## Final Reversibility Model

### Reversibility classes

- `reversible`: prior state can be restored inside a declared recovery window
- `compensable`: exact rollback is not guaranteed, but a predeclared bounded
  compensation path exists
- `irreversible`: no credible rollback or bounded compensation exists

Compensation is weaker than rollback and must not be represented as true
reversibility.

### Stage / promote / finalize

The cutover keeps and sharpens Octon's existing split:

- **stage**: prepare a reversible candidate
- **promote**: make the candidate durable after ACP and policy checks
- **finalize**: remove fallback or cross the true point of no return

Promote and finalize must never collapse into one step for ACP-1 through ACP-3
work.

### Default recovery-window durations

This proposal resolves the default recovery-window question with practical
starting defaults published in `mission-autonomy.yml`:

| Work class | Default recovery window |
| --- | --- |
| local reversible repo/code change | `72h` |
| stateful reversible infra / rollout / canary | `24h` |
| soft-destructive detach / archive / tombstone | `14d` before finalize |
| migration chunk or expand phase | `72h` minimum |
| migration contract or finalize gate | `7d` or explicit approval, whichever is stricter |
| compensable external sync write | `24h` compensation window |
| public sample batch before broader publish | `2h` before expansion |

Repo policy MAY tighten or lengthen these defaults, but any override must be
explicit and receipted when applied.

### Late feedback

- before stage: edit or replace the slice
- after stage but before promote: discard stage or replan
- after promote inside recovery window: rollback or compensate, and optionally
  block finalize
- after recovery window: open a compensating mission or escalate
- after finalize or irreversible boundary: no rollback promise remains

## Final Escalation Model

### Autonomy burn budgets

Autonomy burn budgets are separate from spend and token budgets.

They measure trust burn using evidence such as:

- rollback count or rollback rate
- compensation count
- repeated retries
- operator veto-after-notice
- exception/waiver frequency
- breaker trips
- promote denials due to missing evidence
- confidence misses
- near-misses and incidents
- any out-of-scope or out-of-blast-radius attempt

Recommended base states:

- `healthy`
- `warning`
- `exhausted`

Recommended starting thresholds:

- `warning`: one breaker trip, two rollbacks, or three veto-after-notice /
  denied-promote events for the same mission within a 24h window
- `exhausted`: two breaker trips, any rollback-path failure, one out-of-blast-
  radius side effect, or one high-severity incident on the same mission class
  within a 24h window

These thresholds are deliberately conservative for the first cutover and may be
adjusted by repo policy later.

### Oversight circuit breakers

Breakers automatically tighten behavior when:

- autonomy burn becomes `exhausted`
- rollback is declared but cannot be performed
- observability or required evidence is missing on risky work
- repeated boundary violations occur
- a kill switch or safe-mode directive is active
- a mission class crosses incident thresholds

Breaker actions may include:

- downgrade `silent` to `notify`
- downgrade `proceed_on_silence` to `feedback_window`
- force `STAGE_ONLY`
- suspend future runs
- pause active run at the next safe boundary
- enter safing
- require explicit operator reset

### Safing mode

Safing is not total shutdown.
It is predeclared authority contraction.

Default safing subset for most missions:

- `observe_only`
- `stage_only`

Missions in `incident` class MAY additionally declare `bounded_containment`
actions in the mission charter.

### Break-glass

Break-glass remains exceptional and must be:

- strongly authenticated
- explicitly time-boxed
- reason-coded
- control-receipted
- visible in the mode beacon
- followed by a postmortem task in mission continuity

## Open Question Resolutions

This proposal closes the previously open questions as follows.

### 1. Continuation lease design

A continuation lease is a mission-scoped mutable control artifact at
`state/control/execution/missions/<mission-id>/lease.yml`.

It is **not** a grant and **not** a policy exception.

Required states:

- `active`
- `paused`
- `revoked`
- `expired`

Required fields:

- `mission_id`
- `lease_id`
- `status`
- `granted_by`
- `granted_at`
- `expires_at`
- `max_concurrent_runs`
- `allowed_action_classes`
- `default_safing_subset`

### 2. Directive authority mapping

Binding directive precedence is:

1. break-glass / kill-switch authorities
2. mission owner from `mission.yml`
3. authoritative ownership registry entry for the affected asset/service
4. `CODEOWNERS` for affected repo paths
5. optional subscribers and watchers (advisory only)

External comments, chat messages, or UI actions are never binding until they
write canonical control truth and emit a control receipt.

### 3. Default digest cadence by agent class

Resolved by the mission-class defaults in `mission-autonomy.yml`, with the
table above as the initial standard.

### 4. Safe interrupt boundary taxonomy

Define these boundary classes and require every material slice to declare one:

- `immediate` — observe-only or pre-side-effect phase
- `task_boundary` — before next discrete internal task
- `batch_boundary` — before next file/resource/API batch
- `checkpoint_boundary` — after a durable checkpoint or migration chunk
- `rollout_boundary` — between canary waves, environments, or public batches
- `stage_boundary` — before promote or finalize

Default mappings:

- coding / repo housekeeping: `task_boundary` or `batch_boundary`
- reconcile / infra drift: `batch_boundary` or `rollout_boundary`
- migration / backfill: `checkpoint_boundary`
- monitoring observe-only: `immediate`
- external sync: `batch_boundary`
- destructive/high-impact: `stage_boundary` before irreversible step

### 5. Quorum independence

ACP-2 and ACP-3 independence is resolved by policy, not by intuition.

Two machine attestations count as independent only if at least **two** of the
following differ:

- provider or model family
- prompt/template family
- runtime binary or execution path
- evidence derivation path
- validator class (deterministic vs model-based)

Default quorum rules:

- ACP-2: execution agent + one independent verifier or deterministic validator
- ACP-3: execution agent + one independent verifier + one deterministic
  validator; add owner attestation when public externality, boundary
  exception, or weak compensation is involved
- ACP-4: human approval or break-glass is mandatory; machine quorum can advise
  but not replace approval

### 6. Recovery-window defaults

Resolved by the recovery-default table above and encoded in
`mission-autonomy.yml`.

### 7. Repo-native vs external UX

Repo-native artifacts remain the only authority surfaces.
External UIs are derived clients only.
Any binding action must resolve back into repo control truth and retained
control evidence.

## Non-Goals

This proposal does **not**:

- replace ACP, deny-by-default, or the engine authorization boundary
- create a generic external orchestration database
- turn every human preference into a required approval
- treat generated views as authority
- support dual live autonomous operating models after cutover
- promise rollback for actions that are only compensable or irreversible
- collapse mission planning into receipts or receipts into generated summaries

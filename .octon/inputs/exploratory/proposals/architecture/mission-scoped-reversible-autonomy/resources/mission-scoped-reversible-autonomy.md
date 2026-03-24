# Mission-Scoped Reversible Autonomy

## 1. Final executive framing

Octon’s problem is not how to insert more approvals into autonomous work. It is how to let long-running agents continue under standing delegation while keeping every material side effect inside explicit policy, grant, evidence, and recovery boundaries. Octon already has the right backbone for that: `/.octon/` is the authoritative super-root; `framework/**` and `instance/**` are authored authority; `state/**` holds operational truth and retained evidence; `generated/**` is never source of truth; all material execution must pass the engine-owned `authorize_execution(...)` boundary; ACP is the normative gate for promote/finalize; and autonomous policy requests must bind to an `intent_ref` or fail closed. ([GitHub][1])

The governing philosophy for long-running Octon agents is therefore:

**Autonomy is continuous by default; authority is never ambient; oversight is supervisory rather than approval-heavy; reversibility is a control primitive; receipts and recovery extend governance beyond the moment of execution.**

That philosophy implies five non-negotiable consequences.

First, a long-running agent should continue inside a durable mission envelope without re-asking for permission on every slice. Second, humans should see mode, current state, next durable move, and recovery path without being spammed. Third, intervention should be mostly asynchronous and non-blocking. Fourth, routine ACP-1 through ACP-3 work should be designed to stage, promote, recover, and only later finalize; ACP-4 stays blocked by default absent break-glass. Fifth, when policy prerequisites for promote are missing, the humane fail-closed outcome is usually `STAGE_ONLY`, not indefinite waiting and not silent promotion. ([GitHub][2])

This operating model is meant to be the canonical Octon framing for any agent that may run for hours, days, or indefinitely: coding agents, infra agents, repo maintenance agents, migration agents, security agents, monitoring agents, reconciliation agents, and non-coding operational agents.

---

## 2. Final named operating model

**Canonical name:** **Mission-Scoped Reversible Autonomy**

**One-sentence definition:**
A long-running Octon agent operates inside a mission charter and continuation lease, publishes forward intent and live oversight/safety mode, and can change durable state only through reversible ACP-governed action slices with grants, receipts, recovery windows, and asynchronous human steering.

**Naming justification:**
This should remain the canonical name because it preserves continuity with Octon’s existing research and keeps the emphasis where Octon wants it: **autonomy by default inside governed boundaries**, not operator gatekeeping. The phrase **supervisory control** should remain part of the definition and explanatory framing, because it sharpens the control philosophy, but it should not replace the public-facing name. “Mission-Scoped Reversible Autonomy” is more Octon-native, less likely to be mistaken for approval-heavy control, and easier to map onto missions, grants, ACP, receipts, and recovery.

**Explanatory framing:**
Mission-Scoped Reversible Autonomy is **Octon’s implementation of policy-governed reversible supervisory control**.

---

## 3. Final conceptual architecture

The finalized Octon model has nine interacting layers.

**1. Mission authority layer**
Defines the durable goal, owner, scope, success criteria, acceptable action classes, schedule defaults, and policy posture. This is the standing delegation envelope. It answers, “What is this agent allowed to keep trying to accomplish?”

**2. Forward intent and planning layer**
Breaks the mission into versioned action slices and publishes the next material slices in a forward intent register. This answers, “What is the agent likely to do next, when, why, and with what recovery path?”

**3. Live mode and control-state layer**
Publishes the explicit oversight mode, execution posture, safety state, current phase, current slice, active directives, schedule state, active exceptions, and next safe interrupt boundary. This answers, “What authority state is the agent in right now?”

**4. Human interaction layer**
Provides three formal interaction classes:

* **Inspect** for read-only visibility
* **Signal** for asynchronous steering directives
* **Authorize-Update** for changes to authority, approval, budgets, exceptions, or break-glass state

This keeps awareness, intervention, and approval distinct.

**5. Governance gate layer**
Applies the engine-owned execution boundary, capability grants, repo-owned execution budget and egress policy, and ACP promote/finalize control points. This answers, “May this slice attempt execution, and may its staged output become durable?”

**6. Recovery and finalize layer**
Attaches rollback handles, compensation plans, recovery windows, and separate finalize boundaries to promoted work. This answers, “What can still be undone, for how long, and what remains blocked until finalization?”

**7. Evidence and continuity layer**
Retains grants, receipts, policy digests, attestation artifacts, instruction-layer manifests, telemetry links, and handoff/continuity state. This answers, “What happened, why, under which authority, and what remains open?”

**8. Escalation layer**
Tracks autonomy burn budgets, circuit breakers, pause-on-failure state, safing posture, and break-glass activations. This answers, “Should this mission tighten, pause, downgrade, or enter emergency override?”

**9. Derived read-model layer**
Renders operator-facing summaries such as **Now / Next / Recent / Recover**, mission cards, digests, watch views, and calendars. These are derived from canonical surfaces and are never source of truth. Octon’s architecture already requires exactly that separation between authored authority, operational truth, retained evidence, and generated outputs. ([GitHub][1])

The canonical flow is:

**Mission charter → continuation lease → action slice → forward intent register → preview/feedback window → execution request + grant → stage → ACP promote → receipt + rollback handle + recovery window → optional finalize later → continuity update + derived summaries**

That flow preserves non-blocking progress while keeping the operator continuously on the loop rather than on the critical path for every step.

---

## 4. Final primitive catalog

The primitives below are the core vocabulary of the operating model. Path names are recommended surface families, not a mandatory schema freeze.

### 4.1 Mission charter

What it is: the durable definition of mission purpose, owner, scopes, success/failure conditions, allowed action classes, default schedule, default oversight posture, and risk ceiling.

Why it exists: to create standing delegation without ambient authority. The agent can keep working because the mission answers the stable “why” and “within what bounds.”

Who writes / reads: written by an authorized human owner or repo bootstrap; read by planners, policy, runtimes, operators, and summaries.

Where it belongs: `instance/orchestration/missions/**` plus supporting context in `instance/cognition/context/**`.

Kind: **authored authority**.

How it preserves flow: avoids repeated restatement of goals and scope.

How it supports awareness/intervention/recovery: gives humans a stable reference for whether the agent is still doing the right mission at all.

Failure modes: vague scope, mixed-risk missions, stale owners, missing success criteria.

### 4.2 Continuation lease

What it is: a time-bounded control artifact that says the mission may keep attempting authorized slices until revoked, expired, or tightened.

Why it exists: to separate mission continuity from per-slice authority.

Who writes / reads: written by authorized operators or governance automation; read by scheduler, runtime, policy, operators.

Where it belongs: `state/control/execution/**`.

Kind: **mutable control truth**.

How it preserves flow: long runs continue without task-by-task approval.

How it supports awareness/intervention/recovery: humans can extend, pause, shorten, or revoke the lease without rewriting the mission.

Failure modes: mistaken as blanket permission, forgotten expiry, unclear revocation semantics.

### 4.3 Action slice

What it is: the smallest independently governable and receiptable material unit of work, with predicted ACP, reversibility class, blast radius, evidence plan, budget impact, and safe interrupt boundary.

Why it exists: to keep long missions decomposed into reversible increments.

Who writes / reads: written by the agent planner; read by policy, runtime, operators, summaries.

Where it belongs: `state/control/execution/intents/**` or an equivalent mutable execution-planning surface, with continuity references.

Kind: **operational truth**.

How it preserves flow: makes progress continuous but bounded.

How it supports awareness/intervention/recovery: every material next step is inspectable and locally steerable.

Failure modes: slices too large, crossing multiple risk classes, no boundary between stage and finalize.

### 4.4 Forward intent register and intent notice

What it is: the versioned queue of upcoming material action slices, each with `intent_ref`, rationale, reversibility class, earliest start, feedback deadline, default-on-silence semantics, required approvals/attestations, and rollback/compensation references. Operator-facing notices are derived from it.

Why it exists: to publish future material action before execution instead of only logging history afterward.

Who writes / reads: written by planner/scheduler/runtime; read by policy, operators, watch subscribers, digests.

Where it belongs: canonical register in `state/control/execution/intents/**`; notices in `generated/cognition/**`.

Kind: register is **mutable control truth / operational truth**; notices are **derived read models**.

How it preserves flow: preview happens ahead of consequential work without converting every preview into a blocking gate.

How it supports awareness/intervention/recovery: operators can react before start, not only after receipts.

Failure modes: stale entries, noisy micro-intents, no versioning, notices detached from canonical register.

### 4.5 Mode beacon

What it is: the explicit live statement of the mission’s current:

* `oversight_mode`
* `execution_posture`
* `safety_state`
* `execution_phase`

Recommended values:

* `oversight_mode`: `silent`, `notify`, `feedback_window`, `proceed_on_silence`, `approval_required`
* `execution_posture`: `one_shot`, `continuous`, `interruptible_scheduled`
* `safety_state`: `active`, `paused`, `degraded`, `safe`, `break_glass`
* `execution_phase`: `planning`, `staging`, `promoting`, `recovering`, `finalizing`, `closed`

Why it exists: mode must never be implicit.

Who writes / reads: written by runtime/control plane; read by operators, digests, policies, automation.

Where it belongs: `state/control/execution/mode-state/**`.

Kind: **mutable control truth**.

How it preserves flow: operators do not need to interrupt simply to discover current authority state.

How it supports awareness/intervention/recovery: tells humans instantly whether silence, veto, approval, pause, or rollback semantics currently apply.

Failure modes: stale mode, ambiguous semantics, phase shown without oversight/safety state.

### 4.6 Feedback window

What it is: a bounded pre-start or pre-promote interval during which asynchronous human input can alter the upcoming slice without converting it into mandatory approval.

Why it exists: to give humans a real chance to shape work while preserving default continuity.

Who writes / reads: written by scheduler/control plane; read by operators and runtime.

Where it belongs: in schedule control truth and in derived notices.

Kind: **mutable control truth**, surfaced through **derived read models**.

How it preserves flow: the run waits only for the declared window, not indefinitely.

How it supports awareness/intervention/recovery: makes pre-execution objections meaningful.

Failure modes: windows too short to matter, too frequent to be tolerable, or unclear about what happens on silence.

### 4.7 Control directive

What it is: an authoritative asynchronous steering instruction such as `pause_at_boundary`, `suspend_future_runs`, `stop_after_slice`, `reprioritize`, `narrow_scope`, `exclude_target`, `veto_next_promote`, or `block_finalize`.

Why it exists: to separate steering from approval and from casual commentary.

Who writes / reads: written by authorized humans; read by runtime/control plane and reflected in summaries.

Where it belongs: `state/control/execution/directives/**`.

Kind: **mutable control truth**.

How it preserves flow: lets humans shape future behavior without reopening mission authority.

How it supports awareness/intervention/recovery: provides real intervention power before, during, or after execution.

Failure modes: mixed with chat, no precedence rules, no acknowledgement or consumption semantics.

### 4.8 Authorize-Update request

What it is: a synchronous authoritative mutation request that changes permission or policy state, such as explicit approval, lease extension, budget increase, owner attestation, exception grant, breaker reset, or break-glass activation.

Why it exists: to keep approval and authority mutation distinct from steering.

Who writes / reads: written by authorized humans or governance automation; read by policy/runtime.

Where it belongs: `state/control/execution/**` and related policy control surfaces, with receipt linkage.

Kind: **mutable control truth**, usually receipt-linked.

How it preserves flow: only actions that truly need authority change use it.

How it supports awareness/intervention/recovery: makes “approval required” explicit and bounded.

Failure modes: used for routine steering, missing receipts, approvals that widen authority silently.

### 4.9 Safe interrupt boundary

What it is: the declared boundary where an active run can pause safely and deterministically.

Why it exists: because “stop now” is often unsafe, while “wait for approval forever” is operationally wasteful.

Who writes / reads: authored in workflow contracts and refined by action slices/runtime state; read by operators and control plane.

Where it belongs: workflow authority under `framework/**` or `instance/**`, with current boundary state under `state/control/execution/**`.

Kind: mixed: **authored authority** for boundary definition, **operational truth** for current boundary position.

How it preserves flow: work runs uninterrupted between safe boundaries.

How it supports awareness/intervention/recovery: humans know when pause takes effect.

Failure modes: boundaries undefined, too infrequent, or not truly safe.

### 4.10 Schedule control record

What it is: the authoritative schedule and pause model for a mission or recurring slice class.

It should include:

* cadence or trigger source
* earliest start
* preview lead time
* feedback deadline
* future-run suspension state
* active-run pause state
* overlap policy
* backfill policy
* pause-on-failure behavior
* quiet-hours / batching preferences
* escalation recipients

Why it exists: schedule semantics are governance, not mere UX.

Who writes / reads: mission author sets defaults; scheduler/runtime maintain current state; operators inspect and mutate.

Where it belongs: `state/control/execution/schedules/**`, with defaults in the mission charter.

Kind: **mutable control truth**.

How it preserves flow: recurring work proceeds predictably without ad hoc operator coordination.

How it supports awareness/intervention/recovery: distinguishes “stop future runs” from “pause the active run.”

Failure modes: accidental overlap, catch-up storms after pause, confusion between suspension and interruption.

### 4.11 Exception / waiver lease

What it is: a time-boxed, receipted relaxation of a normal policy or scope constraint.

Why it exists: to preserve continuity without making exceptional authority permanent.

Who writes / reads: written by authorized owners; read by policy/runtime/operators.

Where it belongs: `state/control/execution/**` and capability-governance exception surfaces already used by Octon. The current harness already provides exception-lease surfaces for execution control and capability governance. ([GitHub][1])

Kind: **mutable control truth**, receipt-linked.

How it preserves flow: lets a mission keep moving under explicit, expiring exceptions.

How it supports awareness/intervention/recovery: exceptions are inspectable, attributable, and reversible in time.

Failure modes: silent persistence, vague scope, using waivers to bypass irreversible actions.

### 4.12 Execution grant bundle

What it is: the engine-issued authorization for a material execution attempt.

Why it exists: because autonomy never bypasses material execution control.

Who writes / reads: written by `authorize_execution(...)`; read by workflows, executors, services, and policy wrappers.

Where it belongs: `state/control/capabilities/grants/**` plus the engine-bound run root.

Kind: **authoritative execution control artifact**.

How it preserves flow: allows machine-issued permission under policy rather than manual approval loops.

How it supports awareness/intervention/recovery: ties each material attempt to scope, risk, and reason-coded outcomes.

Failure modes: grant boundary bypassed, scope drift between request and execution, missing provenance.

### 4.13 Execution / change receipt

What it is: append-only retained evidence of what was attempted or done, what decision resulted, which reason codes applied, what evidence existed, and which instruction layers and policies were in force.

Why it exists: post-run accountability should not depend on human memory or chat logs.

Who writes / reads: written by runtime/policy engine; read by operators, auditors, recovery agents, summaries.

Where it belongs: `state/evidence/runs/**`.

Kind: **retained evidence**.

How it preserves flow: routine work can proceed because accountability is strong after the fact.

How it supports awareness/intervention/recovery: receipts tell humans what changed and why.

Failure modes: unreadable receipts, missing required fields, receipts that do not bind to the actual run. Octon already requires receipt emission for every material execution attempt, and the canonical human-readable ACP digest is defined as a projection of a receipt rather than a separate authority source. ([GitHub][3])

### 4.14 Rollback handle and rollback receipt

What it is: the explicit recovery reference attached to a promoted slice, including how to restore or compensate, who may do it, what evidence it depends on, and when the guarantee expires.

Why it exists: rollback is what makes notify-mode and proceed-on-silence tolerable for reversible work.

Who writes / reads: written by runtime/policy and optionally updated by recovery automation; read by operators, policy, recovery agents.

Where it belongs: retained evidence in `state/evidence/runs/**`, surfaced in policy digests and `Recover` views.

Kind: **retained evidence** plus a **derived read-model projection**.

How it preserves flow: lets work move first and recover quickly if needed.

How it supports awareness/intervention/recovery: late human input can still be operational.

Failure modes: untested rollback, hidden handle, expired path masquerading as still available.

### 4.15 Recovery window

What it is: the bounded period after promote during which rollback or compensation is guaranteed and finalize remains blockable.

Why it exists: because governance should remain meaningful after execution has started.

Who writes / reads: written by policy/runtime at promote time; read by operators, schedulers, recovery tools.

Where it belongs: control truth referenced from receipts and reflected in read models.

Kind: **mutable control truth** with evidentiary binding.

How it preserves flow: late feedback becomes action, not regret.

How it supports awareness/intervention/recovery: humans know exactly how long they retain recovery leverage.

Failure modes: absent or too-short windows, hidden deadlines, finalize happening before the window can serve its purpose.

### 4.16 Operator digest and watch subscription

What it is: the routing and rendering layer for human awareness.

Subscription preferences define:

* who watches which missions/assets/scopes/action classes
* desired cadence
* desired severity
* preferred channel class

Digests and watch views render:

* state transitions
* operator-actionable notices
* exceptions
* receipts
* recoverability

Why it exists: awareness must be designed, not assumed.

Who writes / reads: subscription preferences are written by humans or governance automation; digests are generated by read-model builders.

Where it belongs: subscription state under `state/control/execution/**`; generated summaries in `generated/cognition/**`.

Kind: subscriptions are **mutable control truth**; digests/views are **derived read models**.

How it preserves flow: the agent keeps running without narrating itself.

How it supports awareness/intervention/recovery: operators get the right information at the right cadence.

Failure modes: everyone subscribed to everything, no ownership routing, digests drifting from receipts.

### 4.17 Autonomy burn budget

What it is: the per mission/action-class trust budget that measures how much autonomous latitude is still justified by recent evidence.

It should consume on events such as:

* rollback rate spikes
* unexpected compensations
* repeated retries
* exception/waiver usage
* breaker trips
* operator veto-after-notice
* policy-denied promotes due to missing evidence
* confidence misses
* near-misses and incidents

Why it exists: autonomy should tighten because evidence says trust is being burned, not because humans feel nervous.

Who writes / reads: written by runtime/governance analytics; read by policy, scheduler, operators, summaries.

Where it belongs: `state/control/execution/autonomy-budgets/**`.

Kind: **mutable control truth**.

How it preserves flow: autonomy remains broad while healthy.

How it supports awareness/intervention/recovery: operators can see when the system is tightening itself.

Failure modes: arbitrary thresholds, one global budget for all action classes, gaming the metric.

### 4.18 Oversight circuit breaker

What it is: the machine-enforced switch that automatically tightens, pauses, or safes missions when autonomy burn or critical conditions exceed threshold.

Why it exists: because some conditions should change mode automatically.

Who writes / reads: written by policy/runtime; read by scheduler, executors, operators.

Where it belongs: `state/control/execution/circuit-breakers/**`.

Kind: **mutable control truth**.

How it preserves flow: prevents improvised operator intervention under stress by making escalation deterministic.

How it supports awareness/intervention/recovery: humans see exactly why the system tightened.

Failure modes: hair-trigger chatter, no reset semantics, breaker hidden behind generic errors.

### 4.19 Safing mode declaration

What it is: the explicit degraded safety posture in which the mission is restricted to:

* observe-only,
* stage-only,
* or predeclared bounded containment actions.

Why it exists: “degraded” and “safe” are not the same. A degraded system may still do some work; a safed system must not improvise beyond its safe subset.

Who writes / reads: written by runtime/policy or an authorized operator; read by all controllers and operators.

Where it belongs: `state/control/execution/mode-state/**`.

Kind: **mutable control truth**.

How it preserves flow: keeps some useful autonomous behavior available instead of full shutdown.

How it supports awareness/intervention/recovery: operators know the mission has tightened and why.

Failure modes: vague allowed-action set, safing without clear exit criteria, silent re-expansion of authority.

### 4.20 Break-glass activation

What it is: the exceptional, time-boxed override that allows otherwise blocked high-impact work under explicit owner accountability.

Why it exists: emergencies must not depend on the normal happy path.

Who writes / reads: written by an explicitly authorized human or emergency automation under policy; read by policy, runtime, auditors, summaries.

Where it belongs: `state/control/execution/**` and related exception/waiver surfaces, with mandatory retained receipt evidence.

Kind: **mutable control truth** plus **retained evidence**.

How it preserves flow: lets truly urgent work happen when delay is worse than risk.

How it supports awareness/intervention/recovery: creates maximum visibility and accountability around exceptional authority.

Failure modes: normalized use, weak authentication, no TTL, no after-action review.

---

## 5. Final execution mode and decision model

Octon should keep its richer execution model, but sharpen it into two distinct dimensions.

**Dimension A: oversight mode**

* `silent`
* `notify`
* `feedback_window`
* `proceed_on_silence`
* `approval_required`

**Dimension B: execution posture**

* `one_shot`
* `continuous`
* `interruptible_scheduled`

`interruptible_scheduled` is not a replacement for the other modes. It is a posture overlay for long-running or recurring work with explicit safe-boundary pause semantics.

### 5.1 Decision procedure

**Step 1: determine ACP floor and reversibility class**
Use the worst of:

* reversibility class
* blast radius
* externality/public visibility
* policy sensitivity
* expected point of no return

Octon’s current ACP ladder already distinguishes:

* ACP-0 observe
* ACP-1 reversible local
* ACP-2 stateful reversible
* ACP-3 destructive-adjacent
* ACP-4 irreversible, blocked by default. ([GitHub][4])

**Step 2: determine whether pre-execution human input is**

* unnecessary,
* useful but optional,
* or required by policy.

**Step 3: apply upward modifiers**
Upgrade oversight one level when any of these are true:

* low confidence or high novelty
* rollback/compensation untested
* high public visibility
* external commitments
* ownership conflict
* autonomy burn budget warning/exhaustion
* repeated recent incidents in the same action class
* observability degradation

**Step 4: allow downward pressure only when**

* recovery is fast, tested, and bounded,
* blast radius is small,
* no policy-required approval/attestation/review is missing,
* no public/financial/legal/safety commitment is involved.

### 5.2 Final meanings of the modes

**Silent**
Use when work is routine, local, low-risk, high-confidence, and truly reversible or discardable. Humans see it in dashboards and digests, not as a push notice. Silence means the standing delegation remains in force. An objection applies to future slices or triggers boundary pause if still in flight.

**Notify**
Use when work is still reversible but materially interesting to an owner or shared surface. Push a concise notice, but do not wait. Silence means continue. Objection narrows scope, reschedules, or blocks the next promote.

**Notify with feedback window**
Use when human preference or coordination is valuable but not policy-required. The intent notice publishes earliest start and deadline. Silence means continue after the window closes. Objection changes the plan without turning the mission into approval toil.

**Proceed-on-silence**
Use only when:

* the action is reversible or tightly compensable,
* blast radius is bounded,
* rollback or compensation is already defined,
* a feedback window has been published,
* no required attestation/review/approval is missing,
* no public, financial, legal, identity, credential, or safety commitment is being made,
* autonomy burn and circuit breakers are healthy.

Silence here means: **delegation stands inside the already-declared mission and recovery envelope.** It never means consent, endorsement, or widened authority.

**Interruptible scheduled execution**
Use for long-running or recurring missions with known safe boundaries, especially ACP-2 and ACP-3 work. This posture can combine with `notify`, `feedback_window`, or `proceed_on_silence`. It means the active run continues slice-by-slice, but humans can pause at declared boundaries and can separately suspend future scheduled runs.

**Explicit approval required**
Use when any of these apply:

* ACP-4 / irreversible action
* human-review-required executor profile
* release/publication step requiring human review
* high-impact compensable action whose harm cannot be acceptably governed by notice + recovery
* missing credible rollback/compensation
* unresolved authoritative owner conflict
* non-waivable legal, financial, safety, identity, or policy constraint

Current Octon policy already treats some executor profiles, such as `release_candidate_preparation` and `human_review_required`, as requiring hard-enforce, human review, and rollback metadata. This operating model preserves those as explicit exceptions, not the default posture for all agent work. ([GitHub][5])

### 5.3 Fallback outcomes

**`STAGE_ONLY`** is correct when:

* staging is still safe and useful,
* promote/finalize prerequisites are missing,
* required owner attestation is absent,
* cost evidence is missing but staging is allowed,
* autonomy burn or breaker state says “no promote” rather than “no work at all.”

Octon already uses `STAGE_ONLY` as deterministic bounded behavior when owner attestation is required but missing, and the repo-owned execution budget policy already supports stage-only on missing cost evidence. ([GitHub][6])

**Hard deny** is correct when:

* the request violates policy,
* `intent_ref` is missing or invalid,
* a kill switch is active,
* scope is impermissibly broad,
* egress or budget policy denies,
* the action is autonomous but not allowed for autonomy,
* the action is irreversible without break-glass.

The policy interface and execution boundary already require fail-closed denial for missing/invalid intent binding, and material paths cannot proceed without satisfying budget and egress policy. ([GitHub][7])

**Safing mode** is correct when:

* the mission is degraded enough that normal autonomy is no longer trustworthy,
* observability is missing,
* recovery assurances are unavailable,
* autonomy burn is exhausted,
* repeated failures indicate the current mode is unsafe,
* operators are absent during ambiguous high-risk conditions.

In safing mode, new material promotes stop. Allowed behavior contracts down to observe-only, stage-only, or predeclared bounded containment.

---

## 6. Final human awareness and interaction model

The model depends on keeping four control dimensions separate.

**Awareness**
What the human can inspect without stopping the mission.

**Intervention**
What the human can change asynchronously while the mission continues or pauses at a boundary.

**Approval**
Which actions must wait for explicit authorization or policy mutation.

**Reversibility**
What can be undone or compensated after execution. Reversibility does not grant permission; it changes how much pre-execution blocking is justified.

### 6.1 Final interaction grammar

Octon should formally adopt:

**Inspect / Signal / Authorize-Update**

**Inspect**
Read-only visibility into the mission, current mode, next intents, recent receipts, recovery state, budget burn, and schedule. Implemented through derived read models and linked receipts/evidence.

**Signal**
Asynchronous human steering that changes control truth without automatically blocking the mission:

* pause at boundary
* suspend future runs
* narrow scope
* reprioritize
* exclude target
* veto next promote
* block finalize
* change watch routing
* downgrade from proceed-on-silence to feedback window

**Authorize-Update**
An authoritative change to permission or policy state:

* approve
* extend/revoke continuation lease
* raise spend cap
* grant owner attestation
* add exception/waiver lease
* reset breaker
* enter or exit break-glass

This grammar prevents awareness from becoming approval, and prevents human intervention from being expressed only as chat text.

### 6.2 Final operator read model

Every mission should render a concise operator view with four panes.

**Now**
Current mission purpose, owner, current slice, current `oversight_mode`, `execution_posture`, `safety_state`, current phase, active directives, budget/breaker status, and next safe interrupt boundary.

**Next**
Upcoming material slices from the forward intent register: target, rationale, reversibility class, blast radius, earliest start, feedback deadline, default-on-silence behavior, and whether approval/attestation is still pending.

**Recent**
Completed slices, deviations, exceptions, retries, receipts, ACP decisions, and policy digests.

**Recover**
Current rollback handle or compensation path, recovery window, finalize deadline, and whether finalize is currently blocked.

This read model should be progressive-disclosure-first: summary first, evidence on demand. Octon’s existing progressive disclosure principle already supports that architecture, and the canonical ACP digest already requires fields like decision, effective ACP, reason codes, rollback handle, recovery window, and remediation summary. ([GitHub][8])

### 6.3 What humans see and can do

**Before execution**
Humans see:

* the mission purpose
* the next material action
* mode beacon
* earliest start
* feedback deadline
* reversibility class
* expected impact
* operator options

Humans can:

* inspect details
* signal scope or schedule changes
* veto next promote
* block finalize
* approve if required
* attach attestation
* suspend future runs

**During execution**
Humans see:

* live phase and mode
* completed slices
* current slice
* next safe interrupt boundary
* budget/breaker health
* active exceptions and directives

Humans can:

* pause at boundary
* pause active run if already at a safe point
* suspend future scheduled runs
* reprioritize remaining slices
* narrow or exclude scope
* enter safing
* trigger break-glass if authorized

**After execution**
Humans see:

* closure digest
* receipts
* policy decision summary
* rollback handle
* recovery window
* finalize deadline
* continuity tasks

Humans can:

* invoke rollback/compensation inside the recovery window
* block finalize
* open a compensating mission
* change future policy or schedule
* consume operator digest without wading through full evidence

### 6.4 No response, disagreement, and late response

**If humans say nothing**

* `silent`, `notify`: continue.
* `feedback_window`: continue after deadline.
* `proceed_on_silence`: continue only if still inside declared reversible envelope and no required control artifact is missing.
* `approval_required`: do not start or do not finalize.
* missing prerequisite: `STAGE_ONLY` or bounded `ESCALATE`, never indefinite waiting by default.

**If humans disagree**
Binding directives follow authoritative precedence:

1. Octon ownership registry under `.octon/`
2. repo-native metadata such as `CODEOWNERS`
3. external systems as hints only

If authoritative conflict remains unresolved, the mission pauses at a safe boundary or goes `STAGE_ONLY`; the agent does not socially arbitrate. Octon’s ownership contract already states that precedence and already specifies deterministic `STAGE_ONLY` behavior when required attestation is missing. ([GitHub][6])

**If feedback arrives late**

* before promote: it changes future slices
* after promote but inside recovery window: rollback/compensate or block finalize
* after recovery window: open a compensating mission or escalate; do not pretend the original run should have waited forever

---

## 7. Final scheduling, digest, and notification model

Operator attention is a primary systems problem. Notifications are for actionability, not for awareness.

### 7.1 Scheduling semantics

Every recurring or scheduled mission must have an authoritative schedule control record that distinguishes:

* **suspend future runs**: stop creating new executions
* **pause active run**: interrupt the current run at a safe boundary
* **overlap policy**: `skip`, `queue_latest`, `queue_all_bounded`, `cancel_older_at_boundary`, or `allow_concurrent`
* **backfill policy** after suspension: `none`, `latest_only`, `bounded_catchup`
* **pause-on-failure**: which failure classes suspend future work automatically
* **notice lead time** and **feedback deadline**
* **quiet-hours / batching behavior**

These are governance semantics, not scheduler implementation trivia.

### 7.2 Preview timing

Preview timing should be policy-scoped, but the model is fixed:

* **Silent**: no pre-execution push. Visibility exists in dashboard and digest.
* **Notify**: push only when the work becomes operator-interesting, usually at mission open, material schedule change, or first material slice of a batch.
* **Feedback window / proceed-on-silence**: publish a preview with explicit `earliest_start` and `default_on_silence_deadline`.
* **Interruptible scheduled execution**: publish at mission start and when a future boundary materially changes the likely next durable move.
* **Approval required**: publish an explicit approval request with point-of-no-return language.

### 7.3 Digests and watch modes

Octon should use three default human awareness routes:

**Digest mode**
Default. Time-bucketed or state-transition summaries. Suitable for routine low-risk work.

**Watch mode**
Focused state-transition visibility for specific missions, assets, or action classes. Suitable for owners who care about a mission’s ongoing behavior.

**Alert mode**
Reserved for operator-actionable moments:

* feedback window opens
* approval required
* breaker trip
* safing entered
* recovery window near expiry
* promote denied / staged-only unexpectedly
* break-glass activated

Continuous agents must not emit heartbeat chatter. Awareness lives primarily in **Now / Next / Recent / Recover** views and periodic digests, not in raw event spam. Octon’s progressive disclosure principle already supports layered summary-first presentation, and ownership routing should follow authoritative owner metadata first. ([GitHub][8])

### 7.4 Ownership-based routing

Alert and watch routing should follow:

1. authoritative Octon ownership metadata
2. repo-native projections like `CODEOWNERS`
3. optional subscribers
4. external hints only after those

This minimizes notification blast radius and keeps responsibility legible.

### 7.5 Quiet hours and batching

Non-actionable notices should batch into the next digest window. Action-required notices bypass batching. Quiet hours may delay notify-mode push, but must not delay:

* approval-required requests that block public/high-risk work,
* breaker/safing alerts,
* bounded incident containment alerts,
* recovery-window expiry alerts.

---

## 8. Final reversibility, recovery, and finalize model

Reversibility is not cleanup. It is one of the primary reasons routine autonomy can remain non-blocking.

### 8.1 Final reversibility taxonomy

**Reversible**
The prior state can be restored with a tested rollback path inside a declared recovery window, with bounded risk and acceptable cost. Typical examples: repo changes, canary deploys, feature flags, soft-detached resources, reversible config changes.

**Compensable**
The prior state cannot be perfectly restored, but harm can be bounded and counteracted through a predeclared compensation path. Examples: external API writes, some user-visible notifications, soft commitments, replicated syncs.

**Irreversible**
No credible rollback or equivalent compensation exists. Examples: permanent destructive deletion, money movement, public publication at full blast radius, legal commitments, some credential or identity changes, physical actuation, hard-cutover destructive migrations.

Compensation is weaker than rollback. Compensable work should not be casually treated as safe enough for silent autonomy.

### 8.2 Stage, promote, finalize

Octon should keep the current ACP/reversibility semantics:

* **Stage**: apply in reversible form that can still be discarded
* **Promote**: make the staged change durable after policy/evidence/rollback checks
* **Finalize**: remove the old fallback or cross the true point of no return

Octon’s reversibility contract already states that routine ACP-1 through ACP-3 work must carry a rollback path and rollback handle, and that finalize/contraction is separate and ACP-4 blocked by default in normal runs. ([GitHub][9])

### 8.3 Recovery window and rollback receipt

Every promoted ACP-1 through ACP-3 slice must emit:

* a rollback handle or compensation handle
* recovery window start and expiry
* recovery preconditions
* finalize blocker status
* remediation summary

The human-readable policy digest should surface those fields directly from the receipt. ([GitHub][10])

### 8.4 Late feedback semantics

Late feedback is normal and must still have meaning.

* **Before stage**: edit or delete the upcoming slice.
* **After stage but before promote**: discard stage or replan.
* **After promote within recovery window**: rollback or compensate; optionally block finalize.
* **After recovery window**: guaranteed recovery has ended; continue only via explicit compensating mission or escalation.
* **After finalize / irreversible point**: no rollback promise exists; only break-glass, compensating operations, or out-of-band recovery remain.

### 8.5 How recovery changes pre-execution governance

Strong reversible design can legitimately reduce the need for blocking approval because risk is managed across time:

* before execution with intent publication,
* during execution with safe-boundary pause,
* after promote with rollback or compensation,
* before finalization with a recovery window.

That is why routine ACP-1 and ACP-2 work should prefer notify, feedback-window, or proceed-on-silence over blanket approval.

### 8.6 What cannot be trusted to “recover later”

The model must not overclaim recovery. These categories default upward:

* irreversible deletion
* large-blast public communication
* money movement
* legal/public commitments
* identity/credential changes without proven reverse path
* destructive migrations past point of no return
* safety-critical or physical side effects

These are approval-required or break-glass by default.

---

## 9. Final escalation and trust-tightening model

Autonomy should tighten because evidence says it should, not because humans feel vaguely uneasy.

### 9.1 Autonomy burn budgets

Every mission or action class should track a separate autonomy burn budget from its spend/data budgets.

**Burn events should include**

* rollback count and rollback rate
* compensation count
* unexpected operator veto-after-notice
* breaker trips
* repeated retries
* exception/waiver usage
* promote denials due to missing evidence
* confidence miss incidents
* near-misses and postmortem-class failures
* scope drift or deviation from the forward intent register

**Burn states**

* `healthy`
* `warning`
* `exhausted`

**Default effects**

* healthy: normal oversight mode
* warning: smaller slices, more visibility, upgrade one mode level
* exhausted: stage-only or pause-on-failure; possibly enter safing until reset

### 9.2 Oversight circuit breakers

Circuit breakers should trip automatically on:

* exhausted autonomy burn budget
* rollback path failure
* observability loss on risky work
* repeated boundary violations
* active kill switch
* mission-class incident threshold breach
* missing critical evidence on repeated promotes
* unexpected external effect outside declared blast radius

Breaker effects may include:

* suspend future runs
* pause active run at next safe boundary
* downgrade `proceed_on_silence` to `feedback_window`
* downgrade `silent` to `notify`
* force `STAGE_ONLY`
* enter safing
* require explicit operator reset

ACP already treats budgets and circuit breakers as normative control-point inputs; this model makes them an explicit standing escalation layer rather than an afterthought. ([GitHub][2])

### 9.3 Pause-on-failure

Pause-on-failure belongs in schedule control, not in ad hoc operator reaction. Certain failure classes should:

* stop future runs immediately,
* keep the active run recoverable,
* route an alert to owners,
* optionally enter safing.

### 9.4 Degraded mode and safing mode

**Degraded** means some telemetry or certainty is missing; low-risk work may continue under tightened mode.
**Safe** means new material promotes are not allowed except the mission’s predeclared safe subset:

* observe-only
* stage-only
* bounded containment playbook

Safing is not total shutdown. It is controlled contraction of authority.

### 9.5 Break-glass

Break-glass must be:

* explicit
* strongly authenticated
* time-boxed
* reason-coded
* receipt-linked
* postmortemed

It does not erase governance. It is a different governance posture.

### 9.6 Relation to spend/data budgets

Repo-owned execution budget policy and network egress policy remain mandatory inputs to material execution, and the runtime already requires them before material paths proceed. The existing execution budget policy can already stage-only on missing cost evidence. Autonomy burn budgets do not replace those; they govern **trust and oversight**, not dollars or tokens. A mission can be within spend budget but out of autonomy budget, or vice versa. ([GitHub][3])

---

## 10. Final Octon surface mapping

The mapping below keeps one source of truth per concern and avoids duplicate ledgers.

| Concept                                                                                             | Canonical surface                                                                            | Truth class                               | Notes                                                          |
| --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- | ----------------------------------------- | -------------------------------------------------------------- |
| Mission charter, owner, success criteria, default schedule, risk ceiling                            | `instance/orchestration/missions/**`, `instance/cognition/context/**`                        | Authored authority                        | Durable desired outcome and boundary envelope                  |
| Repo-wide governance defaults, ACP rules, executor profile constraints, protected refs, policy mode | `framework/**`, `instance/governance/policies/**`, `.octon/octon.yml`                        | Authored authority                        | Runtime and governance contracts; not per-run state            |
| Continuation lease                                                                                  | `state/control/execution/mission-leases/**`                                                  | Mutable control truth                     | Time-bounded continuity                                        |
| Action slices and forward intent register                                                           | `state/control/execution/intents/**`                                                         | Operational truth / mutable control truth | Versioned upcoming material work                               |
| Mode beacon                                                                                         | `state/control/execution/mode-state/**`                                                      | Mutable control truth                     | `oversight_mode`, `execution_posture`, `safety_state`, `phase` |
| Control directives                                                                                  | `state/control/execution/directives/**`                                                      | Mutable control truth                     | Pause, reprioritize, block finalize, etc.                      |
| Schedule control record                                                                             | `state/control/execution/schedules/**`                                                       | Mutable control truth                     | Future-run suspension, active-run pause, overlap, backfill     |
| Exception / waiver leases                                                                           | `state/control/execution/**` and capability-governance exception surfaces                    | Mutable control truth                     | Time-boxed policy relaxation                                   |
| Execution grants                                                                                    | `state/control/capabilities/grants/**` plus engine grant bundle                              | Authoritative execution control           | Per-attempt authorization                                      |
| Receipts, ACP decisions, rollback metadata, instruction-layer manifests                             | `state/evidence/runs/**`                                                                     | Retained evidence                         | Canonical audit and recovery evidence                          |
| Continuity, handoff, remaining work, follow-up tasks                                                | `state/continuity/repo/**`, `state/continuity/scopes/**`                                     | Operational truth                         | Mission progress and handoff, not policy                       |
| Autonomy burn budgets, breaker state                                                                | `state/control/execution/autonomy-budgets/**`, `state/control/execution/circuit-breakers/**` | Mutable control truth                     | Trust-tightening state                                         |
| Operator subscriptions                                                                              | `state/control/execution/watchers/**`                                                        | Mutable control truth                     | Who sees what, when                                            |
| Policy digests, Now/Next/Recent/Recover, mission calendar, watch views                              | `generated/cognition/**`                                                                     | Derived read models                       | Never authoritative; projections over canonical artifacts      |

This matches the current Octon root contract: authored authority under `framework/**` and `instance/**`, operational truth and retained evidence under `state/**`, and non-authoritative projections under `generated/**`. Material execution must still flow through the engine authorization boundary, and human-readable digests remain derived from receipts, not competing truth sources. ([GitHub][1])

**Important source-of-truth rule:**
Do **not** create a second authoritative run journal. The human-facing “Recent” stream should be a derived projection over receipts plus continuity state.

---

## 11. Scenario validation

### 11.1 Routine repo housekeeping

* **Intended work:** link fixes, doc normalization, generated-summary refresh, stale local cleanup.
* **Human sees:** digest entries and the `Recent` stream; no real-time push unless a threshold trips.
* **Mode:** `silent`, posture `continuous` or `one_shot`.
* **Silence:** work continues.
* **Objection:** changes only future slices or pauses at next file-batch boundary.
* **Mid-flight:** boundary pause only.
* **Evidence:** per-batch receipts and diffs.
* **Recovery:** simple revert.
* **Why correct:** pre-execution attention adds little value; rollback is cheap.

### 11.2 Long-running code refactor

* **Intended work:** multi-day subsystem rewrite in ACP-1 slices.
* **Human sees:** mission charter at start, `Next` slice queue, risk map, periodic digests, current boundary.
* **Mode:** `notify` at mission open, then mostly `silent`/`notify` per slice; posture `interruptible_scheduled`.
* **Silence:** slice-by-slice progress continues.
* **Objection:** `pause_at_boundary`, `reprioritize`, or `narrow_scope`.
* **Mid-flight:** current slice finishes to safe boundary, future slices replan.
* **Evidence:** slice receipts with test results and rollback references.
* **Recovery:** revert or rollback by promoted slice.
* **Why correct:** long work should flow, but each durable increment remains locally steerable and reversible.

### 11.3 Scheduled dependency patching

* **Intended work:** maintenance-window dependency or security patches with canary constraints.
* **Human sees:** package set, rationale, canary plan, recovery handle, feedback deadline.
* **Mode:** `feedback_window` or `proceed_on_silence`; posture `interruptible_scheduled`.
* **Silence:** patch proceeds at scheduled window only if prerequisites are complete.
* **Objection:** defer, narrow package set, or force `STAGE_ONLY`.
* **Mid-flight:** pause only at environment or canary boundary.
* **Evidence:** preflight, test/canary receipts, ACP decision digest, rollback handle.
* **Recovery:** rollback to prior dependency set or canary restore.
* **Why correct:** preserves patch velocity without treating silence as approval.

### 11.4 Release maintenance

* **Intended work:** release preparation, protected workflow changes, public publish readiness.
* **Human sees:** richer preview plus explicit approval state for publish-sensitive boundaries.
* **Mode:** analysis/staging may be `notify`; promote/finalize is `approval_required`.
* **Silence:** staging may continue; publish does not.
* **Objection:** keep staged, remediate, or cancel.
* **Mid-flight:** pause before publish or protected mutation.
* **Evidence:** release prep receipts, rollback metadata, review linkage.
* **Recovery:** discard stage or revert pre-release artifacts.
* **Why correct:** current Octon manifest already marks release-sensitive executor profiles as requiring hard-enforce and human review. ([GitHub][5])

### 11.5 Infrastructure drift correction

* **Intended work:** reconcile declared and actual infrastructure state.
* **Human sees:** affected resources, reversibility class, owner-attestation status if boundary exception exists.
* **Mode:** usually `feedback_window`; posture `interruptible_scheduled`.
* **Silence:** continue only when attestation/policy requirements are already satisfied.
* **Objection:** narrow resources, reschedule, or hold promote.
* **Mid-flight:** pause at resource-batch boundary.
* **Evidence:** plan receipt, validation evidence, owner attestation if required.
* **Recovery:** rollback or restore resource state.
* **Why correct:** autonomy is useful here, but silent re-architecture of production boundaries is not. Missing required attestation should deterministically become `STAGE_ONLY`. ([GitHub][6])

### 11.6 Cost optimization and cleanup

* **Intended work:** stop idle resources, archive unused artifacts, soft-delete stale assets.
* **Human sees:** savings estimate, affected assets, recovery window, finalize date.
* **Mode:** `proceed_on_silence` only for soft-destructive reversible steps; posture `interruptible_scheduled`.
* **Silence:** detach/archive proceeds; hard delete does not.
* **Objection:** exclude resource, restore asset, or block finalize.
* **Mid-flight:** pause at next resource boundary.
* **Evidence:** receipts for detach, savings estimate, recovery metadata.
* **Recovery:** restore within recovery window.
* **Why correct:** soft destruction plus recovery window reduces need for blanket preapproval; finalize remains separate.

### 11.7 Data migration or backfill

* **Intended work:** expand/migrate/contract campaign over chunks.
* **Human sees:** chunk plan, cutover boundaries, rollback proof, telemetry profile, point of no return.
* **Mode:** `feedback_window` or `proceed_on_silence` for expand/migrate; contract/finalize may require stronger control.
* **Silence:** chunked work continues while rollback proof remains valid.
* **Objection:** pause before next chunk or before contract phase.
* **Mid-flight:** current chunk finishes atomically, then pause.
* **Evidence:** chunk receipts, telemetry, rollback validation.
* **Recovery:** per-chunk rollback before finalize; after contract, only compensating recovery if declared.
* **Why correct:** migrations are stateful, so boundary semantics matter more than manual babysitting.

### 11.8 External API sync

* **Intended work:** push Octon-managed state into an external system.
* **Human sees:** target system, egress scope, write volume, compensability class, schedule.
* **Mode:** minimum `notify`; often `feedback_window` for broad syncs.
* **Silence:** proceed only when compensability is declared and external blast radius is bounded.
* **Objection:** narrow target accounts, downgrade to dry-run, or suspend future runs.
* **Mid-flight:** pause at next batch or API-page boundary.
* **Evidence:** egress authorization, request/response receipts, compensation playbook.
* **Recovery:** compensating writes or replay from last good snapshot.
* **Why correct:** external effects are often compensable rather than truly reversible, so silent mode is too weak.

### 11.9 Monitoring / guard agent

* **Intended work:** continuous observation, anomaly detection, policy guard checks.
* **Human sees:** trend digest, anomaly summaries, current mode beacon; no heartbeat spam.
* **Mode:** `silent`, posture `continuous`.
* **Silence:** observe mission continues.
* **Objection:** narrow watch scope, disable auto-remediation, or require human confirmation for operate sub-missions.
* **Mid-flight:** usually immediate because observe-only; operate sub-missions use safe boundaries.
* **Evidence:** telemetry links, anomaly receipts, any triggered sub-mission receipts.
* **Recovery:** not usually needed for observe-only; any operate sub-mission carries its own handle.
* **Why correct:** continuous monitors should be quiet until they have something meaningful to say or do.

### 11.10 Production incident response

* **Intended work:** minimal reversible containment during a live incident.
* **Human sees:** critical notice with evidence, containment scope, mode change, rollback path.
* **Mode:** bounded `proceed_on_silence` only inside emergency playbooks; otherwise `feedback_window` or `approval_required` depending action.
* **Silence:** smallest reversible containment may proceed if delay cost is high and policy preauthorizes it.
* **Objection:** narrow or stop at safe point; break-glass may widen only with explicit authority.
* **Mid-flight:** kill-switch or safe-boundary pause.
* **Evidence:** incident-linked receipts, containment rationale, later postmortem linkage.
* **Recovery:** unquarantine, restore previous config, or compensate.
* **Why correct:** cost of delay changes timing, not the need for receipts, explicit mode, and recovery.

### 11.11 High-volume low-risk repetitive work

* **Intended work:** hundreds of tiny ACP-1 fixes, branch cleanup, repetitive rewrites.
* **Human sees:** campaign-level preview, batch digest, burn-budget state.
* **Mode:** `silent` at item level, `notify` at campaign level; posture `continuous`.
* **Silence:** campaign continues until budget/breaker or exclusion rules trip.
* **Objection:** remove subsets from future queue or pause at batch boundary.
* **Mid-flight:** finish current batch, then pause.
* **Evidence:** batch receipt plus item manifests.
* **Recovery:** selective revert or batch revert.
* **Why correct:** this is exactly where notification fatigue is most dangerous.

### 11.12 Destructive high-impact work

* **Intended work:** permanent deletion, irreversible deprovision, hard data drop.
* **Human sees:** explicit approval request with point-of-no-return language and no-recovery warning.
* **Mode:** `approval_required`; ACP-4 or equivalent.
* **Silence:** no start or no finalize.
* **Objection:** cancel or require redesigned reversible path.
* **Mid-flight:** no autonomous crossing of point of no return.
* **Evidence:** approval record, break-glass if applicable, full receipt.
* **Recovery:** generally none beyond out-of-band remediation.
* **Why correct:** Octon already treats ACP-4 as blocked by default and routine autonomy as ACP-1 through ACP-3. ([GitHub][4])

### 11.13 Human absent during scheduled canary deploy

* **Intended work:** ACP-2 canary release with rollback proof.
* **Human sees:** preview with deadline and default-on-silence semantics.
* **Mode:** `proceed_on_silence`.
* **Silence:** canary proceeds only if no required review/attestation is missing.
* **Objection:** if nobody responds, but policy prerequisites are missing, fallback is `STAGE_ONLY`, not indefinite wait.
* **Mid-flight:** pause at canary boundary if later signaled.
* **Evidence:** no-response path logged in receipt.
* **Recovery:** immediate rollback to prior canary or hold promote.
* **Why correct:** absence should not stall low-risk reversible flow, but it must not fabricate missing authority.

### 11.14 Late human feedback on soft-delete cleanup

* **Intended work:** tombstone old resources, finalize later.
* **Human sees:** soft-delete receipt, recovery window, finalize date.
* **Mode:** `proceed_on_silence` for the soft step; finalize later may require stronger control.
* **Silence:** tombstone proceeds.
* **Objection:** if late but inside the window, restore and block finalize.
* **Mid-flight:** next boundary or immediate restore if already promoted.
* **Evidence:** original receipt plus recovery receipt.
* **Recovery:** restore from tombstone.
* **Why correct:** recovery windows are specifically designed so late feedback still matters.

### 11.15 Conflicting human input

* **Intended work:** ACP-2 infra or repo change with two humans giving incompatible instructions.
* **Human sees:** conflict surfaced in `Now` and `Next`, with authoritative owner shown.
* **Mode:** current oversight mode remains, but promote may shift to `STAGE_ONLY`.
* **Silence:** not relevant; conflict resolution governs.
* **Objection:** authoritative directive wins; otherwise pause at boundary or stage-only.
* **Mid-flight:** current safe boundary is the resolution point.
* **Evidence:** both directives, precedence source, and final decision appear in receipts.
* **Recovery:** already-promoted slices remain recoverable as normal.
* **Why correct:** governance conflict is not planning ambiguity; the agent should not improvise a social hierarchy.

---

## 12. Final design principles

1. **Separate continuity from authority.**
   Missions may continue by default, but every material side effect still needs the engine boundary, grants, and ACP control.

2. **Make mode explicit.**
   Humans should never have to guess the current oversight mode, execution posture, or safety state.

3. **Publish forward intent before consequential work.**
   Past-only logs are not enough for real oversight.

4. **Prefer reversible slices over approval toil.**
   For routine work, veto, rollback, recovery windows, and finalize blockers are stronger than universal preapproval.

5. **Treat `STAGE_ONLY` as the humane fail-closed default.**
   Preserve useful staged progress when promote prerequisites are missing.

6. **Interrupt at safe boundaries, not by panic.**
   Safe pause is the default human intervention model for in-flight material work.

7. **Route attention by actionability and ownership.**
   Awareness should be summary-first and owner-scoped; alerts are for moments that actually need a human.

8. **Tighten autonomy with evidence, not anxiety.**
   Burn budgets and breakers should respond to measured trust loss.

9. **Keep evidence canonical and read models derived.**
   Do not let chat, dashboards, or digests become hidden control planes.

10. **Never fuse promote with point-of-no-return finalize.**
    Late recovery and meaningful post-execution governance depend on that separation.

---

## 13. Final mistakes to avoid

1. **Using approvals as the universal safety mechanism.**
   That collapses autonomy into queue management and weakens real attention.

2. **Treating silence as consent.**
   Silence only means the declared delegation envelope still stands.

3. **Equating more notifications with better oversight.**
   That produces fatigue, not awareness.

4. **Equating reversibility with permission.**
   Recovery lowers the need for blocking approval; it does not override policy.

5. **Logging only what happened, not what is about to happen.**
   Without forward intent, operators are always late.

6. **Letting stage and finalize collapse into one action.**
   That destroys the recovery window.

7. **Creating duplicate authoritative ledgers.**
   Receipts, continuity, and control truth already exist; “Recent” is a view, not a new source of truth.

8. **Failing to distinguish future-run suspension from active-run interruption.**
   Scheduled systems become unpredictable without that separation.

9. **Treating compensation as if it were rollback.**
   Compensable actions often deserve stronger pre-execution control than truly reversible ones.

10. **Leaving degraded and emergency states implicit.**
    No explicit safing or break-glass model means improvisation under stress.

---

## 14. Remaining open questions

1. **Exact schema design for continuation leases and the forward intent register.**
   The operating model is clear; the canonical artifact schemas and versioning rules still need formalization.

2. **Calibration of autonomy burn budgets by action class.**
   The model should be consistent, but thresholds must differ across coding, infra, migrations, monitoring, and security operations.

3. **Executor-class-specific safe interrupt taxonomies.**
   “Safe boundary” exists conceptually now, but exact boundary classes should be formalized differently for repo mutation, infra reconciliation, migrations, and external sync.

4. **Default recovery-window TTLs by resource type.**
   Repo edits, soft-deleted resources, migration checkpoints, and user-visible external effects should likely have different defaults.

5. **Quorum independence and anti-correlation rules for ACP-2/ACP-3.**
   If multiple agents or attestations are used, Octon needs stronger rules to ensure they are not just repeating the same blind spot.

---

## 15. Final concise recommendation

**Final recommended operating model name:** **Mission-Scoped Reversible Autonomy**

**One-sentence definition:**
A long-running Octon agent runs under standing mission delegation, publishes forward intent and explicit live mode, and commits durable change only through reversible ACP-governed slices with grants, receipts, recovery windows, and asynchronous human steering.

**Why it best satisfies the three goals:**
It **never interrupts work by default** because mission continuity and machine-issued grants let routine slices keep moving; it **keeps humans updated** because mode, next intent, recent receipts, and recovery state are always available through summary-first read models; and it **allows human feedback or interruption when needed** because humans can signal changes before execution, pause safely during execution, and roll back or block finalize after execution without forcing routine work into approval-heavy loops.

[1]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/_meta/architecture/specification.md "raw.githubusercontent.com"
[2]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/governance/principles/autonomous-control-points.md "raw.githubusercontent.com"
[3]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/execution-authorization-v1.md "raw.githubusercontent.com"
[4]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/capabilities/governance/policy/deny-by-default.v2.yml "raw.githubusercontent.com"
[5]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/octon.yml "raw.githubusercontent.com"
[6]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/governance/principles/ownership-and-boundaries.md "raw.githubusercontent.com"
[7]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/policy-interface-v1.md "raw.githubusercontent.com"
[8]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/governance/principles/progressive-disclosure.md "raw.githubusercontent.com"
[9]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/governance/principles/reversibility.md "raw.githubusercontent.com"
[10]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/engine/runtime/spec/policy-digest-v1.md "raw.githubusercontent.com"

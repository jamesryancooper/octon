# Target Architecture

## Decision

Octon should perform one final **atomic closeout cutover** that makes the Mission-Scoped Reversible Autonomy Operating Model fully complete, fully integrated, and architecturally clean.

The target release is **0.6.3**.

This packet is not a redesign packet.
It is a **closeout** packet.
It lands one final repo-wide, pre-1.0, clean-break update that removes the last lifecycle, intent, evidence, and proof gaps that still prevent an unqualified “done” verdict.
Its scope is bounded by the [implementation audit](../resources/implementation-audit.md), and it proposes only the changes required to close that audit cleanly.

## Canonical model statement

**Mission-Scoped Reversible Autonomy** remains the canonical public-facing name.

It remains defined as:

> A long-running Octon agent runs under standing mission delegation, publishes forward intent and explicit live mode, and commits durable change only through reversible ACP-governed slices with grants, receipts, recovery windows, and asynchronous human steering.

It remains Octon’s implementation of **policy-governed reversible supervisory control**.

## What this packet changes

This packet **does not**:

- rename the operating model
- replace ACP, grants, receipts, reversibility, or `STAGE_ONLY`
- add a second control plane
- turn routine work into an approval-heavy model
- create a new authored “scenario registry”
- move generated summaries or routes into authoritative surfaces

This packet **does**:

- choose one final **mission lifecycle rule** and enforce it everywhere
- require a fully seeded mission-control family before a mission may become active
- require slice-linked **forward intent** for material autonomous work
- make **scenario resolution** the single generated effective route consumed by runtime, scheduling, summaries, and finalize logic
- broaden retained **control-plane evidence** to all meaningful control mutations
- make **autonomy-burn** and **breaker** transitions retained-evidence-driven runtime behavior
- make summaries, operator digests, and machine mission views standard generated outputs for active autonomous missions
- make the conformance suite block merges when any of those invariants fail
- remove the last remaining lifecycle and normalization ambiguities

## Final architecture rule for mission lifecycle

The closeout packet chooses the following rule and makes it canonical:

### Rule 1: authored mission scaffolds remain authority-only

The generic mission scaffold continues to create only mission-authority artifacts under:

- `instance/orchestration/missions/<mission-id>/mission.yml`
- `instance/orchestration/missions/<mission-id>/mission.md`
- `instance/orchestration/missions/<mission-id>/tasks.json`
- `instance/orchestration/missions/<mission-id>/log.md`

This avoids misplacing mutable control truth under authored authority.

### Rule 2: seed-before-active is mandatory

Before a mission may enter an autonomous active or paused runtime state, the activation path **must** seed:

- `lease.yml`
- `mode-state.yml`
- `intent-register.yml`
- `action-slices/`
- `directives.yml`
- `authorize-updates.yml`
- `schedule.yml`
- `autonomy-budget.yml`
- `circuit-breakers.yml`
- `subscriptions.yml`
- mission continuity stubs
- a fresh generated `scenario-resolution.yml`
- generated summaries
- a machine-readable `mission-view.yml`
- a control receipt proving the seeding event

This seed-before-active path becomes the canonical lifecycle rule.
The scaffold does not need to own mutable state; the lifecycle does.

### Rule 3: validation makes the lifecycle fail-closed

A mission may not be treated as active autonomous runtime state unless validation proves the seed-before-active invariant.

This closes the last ambiguity identified in the [implementation audit](../resources/implementation-audit.md) without violating source-of-truth separation.

## Final architecture layers

### 1. Mission authority layer
Canonical surfaces:
- `instance/orchestration/missions/**`
- mission registry
- mission scaffolds

Role:
- mission charter
- owner reference
- mission class
- safe subset
- success/failure conditions
- allowed action classes
- risk ceiling

### 2. Mission control layer
Canonical surfaces:
- `state/control/execution/missions/<mission-id>/`

Role:
- continuation lease
- mode state
- intent register
- action slices
- directives
- authorize-updates
- schedule control
- autonomy budget
- breaker state
- subscriptions

### 3. Effective routing layer
Canonical surfaces:
- `generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`

Role:
- generated route that resolves mission class, effective scenario family, effective action class, oversight mode, schedule semantics, safe boundary class, recovery profile, finalize policy, digests, and alert routing from authoritative inputs

### 4. Execution-governance layer
Canonical surfaces:
- execution request/grant/receipt/policy receipt schemas
- ACP principle and deny-by-default policy
- root manifest execution-governance configuration

Role:
- grant boundary
- ACP stage/promote/finalize
- `STAGE_ONLY`
- recoverability
- approval gating
- release-sensitive exceptions

### 5. Continuity and retained evidence layer
Canonical surfaces:
- `state/continuity/repo/missions/**`
- `state/evidence/control/execution/**`
- `state/evidence/runs/**`

Role:
- handoff
- next actions
- control receipts
- run receipts
- recovery and finalize evidence
- burn/breaker transition evidence

### 6. Generated awareness layer
Canonical surfaces:
- `generated/cognition/summaries/missions/**`
- `generated/cognition/summaries/operators/**`
- `generated/cognition/projections/materialized/missions/**`

Role:
- `Now / Next / Recent / Recover`
- operator digests
- machine-readable mission view

## Final architecture invariants

1. **No active mission without seeded control truth.**
2. **No material autonomous work without a current intent entry and referenced action slice.**
3. **No effective route without freshness and linkage.**
4. **No material recovery semantics from generic fallback.**
5. **No unreceipted control mutation.**
6. **No generated view substituting for missing control or evidence.**
7. **No lifecycle ambiguity between create, seed, activate, pause, recover, finalize, and archive.**
8. **No non-blocking autonomy outside policy, route, and recovery invariants.**
9. **No CI blind spot around lifecycle, route, summaries, evidence, or scenarios.**

## The final correction set

This packet closes the remaining gaps by implementing exactly eight repo-wide corrections:

1. **Lifecycle closeout**
   - mission creation stays authority-only
   - activation auto-seeds mission control and continuity
   - active missions fail validation if seed is absent

2. **Forward-intent closeout**
   - material autonomous work requires non-empty, fresh, slice-linked intent
   - observe-only missions remain the only empty-intent carveout until they fork operate work

3. **Route normalization closeout**
   - mission class provides defaults
   - effective scenario family refines schedule/awareness behavior
   - action slice overrides route only for more-specific boundary/recovery/externality semantics
   - breaker/safing/directives only tighten

4. **Interaction closeout**
   - `Inspect / Signal / Authorize-Update` becomes fully operational, receipted, and precedence-governed

5. **Evidence closeout**
   - all control mutations emit receipts
   - run and control evidence remain separate

6. **Burn/breaker closeout**
   - runtime recomputes autonomy burn and breaker state from retained evidence and current control truth
   - those transitions feed route, scheduler, and summaries

7. **Read-model closeout**
   - every active autonomous mission gets generated summaries and a mission view
   - operator digests are ownership-routed and subscription-aware

8. **Conformance closeout**
   - lifecycle, intent, route, evidence, burn/breaker, summaries, and scenarios all become blocking CI invariants

## Release posture

This packet should promote with a single `0.6.3` closeout release.

After promotion:

- archive `mission-scoped-reversible-autonomy-steady-state-cutover`
- archive this packet
- write the completion decision and migration evidence
- treat MSRAOM as fully complete unless a later ADR explicitly supersedes it

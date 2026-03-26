# Target Architecture

## Decision

Octon should perform one final **atomic steady-state cutover** that makes the
Mission-Scoped Reversible Autonomy Operating Model truly complete, fully
integrated, and architecturally clean.

The target release is **0.6.1**. It should land as one repo-wide, pre-1.0,
clean-break update. There should be no follow-on correctness packet after it.

## What This Packet Does And Does Not Change

This packet **does not**:
- rename the operating model
- replace ACP, grants, receipts, reversibility, or `STAGE_ONLY`
- add a second control plane
- turn routine work into an approval-heavy model
- rewrite historical mission or run evidence

This packet **does**:
- finish the control-plane and operator-plane integration layers
- make mission creation and mission runtime agree on one complete control-file
  family
- make scenario resolution the actual effective routing layer used by runtime,
  scheduling, summaries, and recovery/finalize logic
- remove generic fallback autonomy semantics
- make runtime, docs, generated views, and CI all match

## Canonical Model Statement

**Mission-Scoped Reversible Autonomy** remains the canonical public-facing
name.

It remains defined as:

> A long-running Octon agent runs under standing mission delegation,
> publishes forward intent and explicit live mode, and commits durable change
> only through reversible ACP-governed slices with grants, receipts, recovery
> windows, and asynchronous human steering.

This remains Octon’s implementation of
**policy-governed reversible supervisory control**.

## Why Another Atomic Cutover Is Still Needed

Octon already has a substantial MSRAOM implementation:
- mission charters and mission-autonomy policy exist
- mission control files and schemas exist
- generated scenario resolution exists
- generated `Now / Next / Recent / Recover` summaries exist
- an operator digest exists
- evaluator logic exists
- control evidence roots exist

But “substantially implemented” is not the same thing as “done.” The remaining
issues are specifically the ones that create chronic trust and correctness
problems if left unresolved:

- mission scaffolds still lag behind runtime expectations
- route linkage is still weaker than it should be
- intent publication is present but not yet mandatory for material autonomous
  work
- safe-boundary taxonomy is still partly inconsistent
- some autonomy semantics still degrade to generic route behavior instead of
  explicit slice-driven behavior
- control-plane evidence is not yet broad enough to prove every control
  mutation
- mission projections are still not a standard generated surface
- runtime, CI, and summaries do not yet prove the same invariants

The implementation audit in `resources/implementation-audit.md` therefore
judges the current state as **partially complete with moderate gaps** and
treats this packet as a closeout exercise, not a redesign exercise.

Because Octon is still pre-1.0, the right correction is one clean break, not a
prolonged period of partial fixes.

## Atomic Rules

1. **No dual live model.** Once merged, all live autonomous mission paths use
   the completed MSRAOM control family, routing layer, evidence model, and
   conformance suite.
2. **No post-cutover remediation backlog.** This packet closes every currently
   known gap. If a gap is known now, it is fixed now.
3. **No hidden fallback path.** If effective route, action slice, or recovery
   semantics cannot be derived, the runtime tightens to `STAGE_ONLY`, `SAFE`,
   or `DENY`.
4. **No authoritative ambiguity.** Authored authority, mutable control truth,
   retained evidence, and derived read models remain distinct.
5. **No summary-only implementation.** A generated summary never substitutes
   for missing canonical control or evidence surfaces.
6. **No empty-intent material work.** A material autonomous run cannot proceed
   from an empty or stale intent register.
7. **No untested scenario routing.** Scenario-resolution is only complete when
   validated in blocking CI.

## Final Architecture Layers

### 1. Mission authority layer
Canonical surfaces:
- `instance/orchestration/missions/**`
- mission registry
- mission scaffolds

Role:
- mission charter
- owner reference
- risk ceiling
- allowed action classes
- safe subset
- mission class
- success/failure conditions

### 2. Governance and policy layer
Canonical surfaces:
- `instance/governance/policies/mission-autonomy.yml`
- deny-by-default policy
- `.octon/octon.yml`
- ownership registry

Role:
- mission-class defaults
- oversight-mode defaults
- scenario-family upgrades
- ACP / reversibility rules
- executor-profile constraints
- ownership precedence
- digest, alert, and route defaults

### 3. Mutable mission control layer
Canonical surfaces:
- `state/control/execution/missions/<mission-id>/**`

Required file family:
- `lease.yml`
- `mode-state.yml`
- `intent-register.yml`
- `action-slices/<slice-id>.yml`
- `directives.yml`
- `authorize-updates.yml`
- `schedule.yml`
- `autonomy-budget.yml`
- `circuit-breakers.yml`
- `subscriptions.yml`

Role:
- standing delegation continuity
- explicit live mode
- forward intent publication
- action-slice authority context
- intervention and approval request handling
- scheduling behavior
- trust-tightening state
- ownership-aware routing state

### 4. Execution governance layer
Canonical surfaces:
- engine runtime request / grant / receipt / policy receipt contracts
- ACP enforcement
- spend and egress policy
- executor-profile constraints

Role:
- authorize each material attempt
- enforce mission-bound autonomy context
- preserve `STAGE_ONLY` and `DENY`
- bind execution to intent and slice identity

### 5. Recovery and finalize layer
Canonical surfaces:
- run receipts
- control receipts
- recovery windows
- finalize gating logic

Role:
- rollback or compensation handles
- finalize separation
- late-feedback handling
- finalize blocking and authorization

### 6. Continuity and handoff layer
Canonical surfaces:
- `state/continuity/repo/missions/**`

Role:
- progress
- handoff
- next actions
- unresolved blockers
- mission closeout state

### 7. Derived effective routing layer
Canonical surfaces:
- `generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`

Role:
- compile mission class, effective scenario family, current slice, policy,
  mode, schedule, directives, budgets, breakers, and safing into one runtime-
  consumable behavior contract

### 8. Derived operator and machine views
Canonical surfaces:
- `generated/cognition/summaries/missions/<mission-id>/{now,next,recent,recover}.md`
- `generated/cognition/summaries/operators/**`
- `generated/cognition/projections/materialized/missions/<mission-id>/mission-view.yml`

Role:
- summary-first human awareness
- ownership-routed digests
- machine-readable mission state for tools and higher-level orchestration
- no authority

## Final Steady-State Invariants

After this cutover, the following must be true for every active autonomous
mission:

1. the mission charter is `octon-mission-v2` and `owner_ref` is canonical
2. the complete mission-control file family exists
3. `mode-state.yml` points to a fresh scenario-resolution artifact
4. material autonomous work has at least one current intent entry and one
   referenced action-slice artifact
5. route recovery and boundary semantics are derived from slice + policy, not
   generic fallback
6. summaries and digests are refreshed from canonical mission control,
   evidence, continuity, and effective route
7. a machine-readable mission projection exists
8. directives and authorize-updates are reflected in control receipts
9. autonomy-budget and breaker transitions are recomputed and receipted
10. required validators and scenario tests are blocking in CI

## Resolved Design Choices

### Release target
The completion target is **0.6.1**. The repo already advertises `0.6.0`, so
the correct interpretation of this packet is “finish and stabilize 0.6.0” not
“invent a new conceptual generation.” The audit also confirms one of the
remaining closure defects is version drift between `version.txt` and
`.octon/octon.yml`, so this packet must make version parity a validated
invariant instead of an assumed convention.

### Scenario routing
Scenario routing remains **derived**, not authored. The canonical result is
the generated scenario-resolution artifact. There is no separate scenario
registry.

### Mission projections
The manifest and contract registry already name a mission projection root.
This packet keeps that root and makes it real by materializing one machine-
readable mission view per active mission. It does not remove the root.

### Mission creation
The complete mission-control family must exist immediately after mission
creation. This packet therefore requires either:
- scaffold generation of the full control-file family, or
- an automatic seed step invoked by the create-mission workflow.

In steady state, the user experience is atomic either way: no active mission
exists without its full control family.

### Route strictness
The runtime may not derive recovery from a generic placeholder action class
for material work. If an active or pending material slice does not resolve to
a policy-backed action class and reversibility profile, the run tightens.

### Interaction grammar completeness
`Inspect / Signal / Authorize-Update` becomes operationally complete by adding
a dedicated `authorize-updates.yml` queue and corresponding control receipts.
This is the minimal additive change that finishes the grammar cleanly.

## Final Outcome

After this cutover, Octon should have:

- one complete MSRAOM implementation path
- one complete mission-control file family
- one route-aware runtime and scheduler path
- one operator view family
- one machine-readable mission projection family
- one control-plane evidence model
- one blocking scenario and runtime-contract conformance baseline

Anything less leaves the operating model not yet truly done.

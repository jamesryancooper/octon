# Target Architecture

## Decision

Octon should perform an **atomic completion cutover** that finishes the
implementation of Mission-Scoped Reversible Autonomy without changing its
canonical name or replacing its governance spine.

The cutover release target is **0.6.0** and it must land as one repo-wide,
pre-1.0, clean-break update.

## Why This Is Needed

The repo currently contains a partially integrated MSRAOM implementation:

- the policy and contract backbone is real,
- but key control-plane and operator-plane pieces remain missing, weakly
  integrated, or contradictory.

The completion cutover resolves that state by making the repo match the model it
already claims to implement.

## Canonical Model Statement

**Mission-Scoped Reversible Autonomy** remains the canonical public-facing name.

It is defined as:

> A long-running Octon agent runs under standing mission delegation, publishes
> forward intent and explicit live mode, and commits durable change only through
> reversible ACP-governed slices with grants, receipts, recovery windows, and
> asynchronous human steering.

This continues to be Octon’s implementation of
**policy-governed reversible supervisory control**.

## Atomic Cutover Rules

1. **No dual live model.** Once merged, all live autonomous paths use the
   completed MSRAOM surfaces and contracts.
2. **Historical evidence remains.** Historical receipts and mission artifacts
   are not rewritten.
3. **Live contracts upgrade together.** Root manifest, mission scaffolds, runtime
   specs, runtime consumers, generated views, and tests land in the same cutover.
4. **Docs must match implementation.** Placeholder-only canonical surfaces are
   not acceptable after merge.
5. **No hidden fallback path.** If effective route or recovery data cannot be
   derived, the runtime must `STAGE_ONLY`, `SAFE`, or `DENY`, not improvise.

## Final Architecture Layers

### 1. Mission authority layer
Canonical surfaces:
- `instance/orchestration/missions/**`
- mission registry
- mission scaffolds

Role:
- durable mission charter
- owner reference
- scope IDs
- safe subset
- risk ceiling
- allowed action classes
- success/failure conditions

### 2. Policy layer
Canonical surfaces:
- `instance/governance/policies/mission-autonomy.yml`
- deny-by-default policy
- `.octon/octon.yml`
- ownership registry

Role:
- mission-class defaults
- ACP and reversibility rules
- executor-profile constraints
- ownership precedence
- digest and routing defaults

### 3. Mutable mission control layer
Canonical surfaces:
- `state/control/execution/missions/<mission-id>/**`

Role:
- continuity lease
- mode beacon
- forward intent register
- directives
- schedule control
- autonomy burn budgets
- circuit breakers
- subscriptions

### 4. Execution governance layer
Canonical surfaces:
- engine runtime request / grant / receipt / policy receipt contracts
- ACP enforcement
- egress and spend budget gates

Role:
- authorize each material attempt
- enforce mission-bound autonomy context
- preserve `STAGE_ONLY` and `DENY`

### 5. Recovery and finalize layer
Canonical surfaces:
- run receipts
- control receipts
- recovery windows
- finalize gating logic

Role:
- rollback or compensation handles
- finalize separation
- late-feedback semantics

### 6. Continuity and handoff layer
Canonical surfaces:
- `state/continuity/repo/missions/**`

Role:
- progress
- next handoff
- follow-up tasks
- unresolved blockers

### 7. Derived effective routing layer
Canonical surfaces:
- `generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`

Role:
- materialize the effective scenario route used by runtime and operator views

### 8. Derived operator views
Canonical surfaces:
- `generated/cognition/summaries/missions/<mission-id>/{now,next,recent,recover}.md`
- `generated/cognition/summaries/operators/**`

Role:
- summary-first awareness
- mission/operator legibility
- no authority

## New Durable Contracts Required

The cutover must add and register:

- `mission-control-lease-v1.schema.json`
- `mode-state-v1.schema.json`
- `action-slice-v1.schema.json`
- `intent-register-v1.schema.json`
- `control-directive-v1.schema.json`
- `schedule-control-v1.schema.json`
- `autonomy-budget-v1.schema.json`
- `circuit-breaker-v1.schema.json`
- `subscriptions-v1.schema.json`
- `control-receipt-v1.schema.json`
- `scenario-resolution-v1.schema.json`

## Runtime Corrections Required

### 1. Mission-charter reader correction
- `owner_ref` becomes canonical
- legacy `owner` may be read only during migration
- post-cutover generated views and runtime behavior must be sourced from
  `owner_ref`

### 2. Policy consumption correction
The runtime must consume the mission-autonomy policy for:
- mission-class defaults
- preview timing
- overlap/backfill
- pause-on-failure
- default recovery windows
- autonomy-burn thresholds
- breaker actions
- safe interrupt boundary defaults
- ownership routing defaults

### 3. Recovery correction
The runtime may not invent default recovery semantics for material work. If
rollback/compensation or recovery window cannot be derived from effective route
and policy, the runtime must tighten to `STAGE_ONLY`, `SAFE`, or `DENY`.

### 4. Read-model correction
Mission and operator summaries must actually exist and be refreshable from
canonical mission control, evidence, and continuity surfaces.

## Scenario Resolution

The cutover explicitly adds **derived scenario resolution** as the missing
integration layer.

It is not a new authority registry. It is a materialized effective route that
compiles mission class, action class, reversibility, executor profile, mode
state, schedule control, autonomy budget, breaker state, and safing/incident
state into one coherent behavior contract.

This output must be consumed by:
- scheduler behavior
- preview publication
- digest routing
- operator read models
- recovery/finalize gating

## Contradictions Resolved

| Contradiction | Resolution |
| --- | --- |
| Repo declares generated mission/operator summaries but they are placeholder-only | Materialize them in the cutover |
| Runtime expects mission control files without durable contracts | Add the missing spec family and scaffolds |
| Mission charter v2 uses `owner_ref` but some readers still expect `owner` | Make `owner_ref` canonical and update readers |
| Mission-autonomy policy is richer than runtime behavior | Add explicit scenario resolver and policy-consuming runtime integration |
| Recovery data can fall back to hidden behavior | Require policy-derived recovery or tighten the path |

## Final Outcome

After this cutover, Octon should have:

- one complete MSRAOM implementation path,
- one mission control family with durable contracts,
- one scenario-resolution layer,
- one operator read-model family,
- one conformance suite that proves behavior across the required scenarios.

Anything less leaves the operating model incomplete.

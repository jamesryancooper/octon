# Scenario Routing Design

## Decision

Octon should implement **scenario routing** as a **derived effective resolver**,
not as a new authoritative registry.

The repo already has the right authoritative inputs:

- mission class in the mission charter
- repo-owned defaults in `mission-autonomy.yml`
- ACP/action-class and reversibility policy in deny-by-default policy
- executor-profile constraints in `.octon/octon.yml`
- live mission mode, schedule, budget, breaker, and subscription state

What is missing is a single runtime- and operator-consumable output that turns
those inputs into one coherent effective route.

## Why It Is Needed

Without a materialized resolver, scenario handling remains scattered across:

- mission class defaults
- ACP rules
- executor profiles
- ad hoc runtime checks
- schedule state
- breaker state
- operator digests

That makes it too easy for scheduler behavior, preview behavior, recovery
behavior, and operator views to disagree.

## Non-Goals

- no new authored scenario registry
- no duplicate source of truth
- no special-case hardcoded routing in UI-only layers
- no naming inflation that displaces mission class, action class, or ACP

## Resolver Inputs

The scenario resolver must consume:

1. **Mission authority**
   - `mission.yml`
   - mission registry entry
2. **Repo-owned mission policy**
   - `instance/governance/policies/mission-autonomy.yml`
3. **ACP/action-class policy**
   - deny-by-default policy
4. **Runtime profile constraints**
   - `.octon/octon.yml`
5. **Mission live state**
   - lease
   - mode state
   - intent register
   - schedule control
   - autonomy budget
   - circuit breakers
   - subscriptions
   - directives
6. **Optional contextual escalation inputs**
   - incident state
   - recovery-window state
   - break-glass activation
   - active safing subset

## Resolver Outputs

The effective scenario-resolution artifact must compute:

- `scenario_family`
- `effective_oversight_mode`
- `effective_execution_posture`
- `preview_lead`
- `feedback_window`
- `proceed_on_silence_allowed`
- `approval_required`
- `safe_interrupt_boundary_class`
- `overlap_policy`
- `backfill_policy`
- `pause_on_failure`
- `digest_cadence`
- `watch_route`
- `alert_route`
- `required_quorum`
- `recovery_profile`
- `finalize_policy`
- `safing_subset`
- `route_reason_codes`

## Recommended Surface

**Canonical derived surface**
`.octon/generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`

**Human-facing projections**
- render summary excerpts into:
  - `generated/cognition/summaries/missions/<mission-id>/now.md`
  - `generated/cognition/summaries/missions/<mission-id>/next.md`

## Resolver Algorithm

1. Start with mission charter and mission class.
2. Load mission-class defaults from `mission-autonomy.yml`.
3. Load action-class / ACP / reversibility constraints for the current or next
   slice from deny-by-default policy.
4. Apply executor-profile constraints from `.octon/octon.yml`.
5. Apply live control truth:
   - directives
   - schedule state
   - lease state
   - mode state
   - autonomy burn state
   - breaker state
   - safing state
6. Apply higher-priority emergency or kill-switch precedence.
7. Emit one effective route with explicit rationale and freshness TTL.

## Scenario Families

The resolver should classify the effective route into one of these policy-defined
families:

- `observe`
- `campaign`
- `maintenance`
- `reconcile`
- `migration`
- `external_sync`
- `incident`
- `destructive`
- `release_sensitive`

The family may begin from `mission_class`, but may be **upgraded** by:
- executor profile
- action class
- reversibility class
- public/external effect
- breaker/safing state
- incident state

## Example Upgrades

- `maintenance` + external write + compensable-only recovery -> effective family
  `external_sync`
- `campaign` + public publish step -> effective family `release_sensitive`
- `observe` + bounded containment sub-mission -> effective family `incident`
- any family + irreversible finalize -> effective family `destructive`

## Required Behavioral Outcomes

### Routine housekeeping
- `silent`
- no preview push
- digest-only
- revert-based recovery

### Long-running refactor
- `notify` at mission open, then mostly `silent`/`notify`
- interruptible scheduled posture
- slice-level rollback and continuity

### Dependency patching
- `feedback_window` or `proceed_on_silence`
- environment/canary safe boundary
- rollback handle required

### Release maintenance
- analysis/stage may continue
- publish/finalize becomes `approval_required`

### Drift correction
- mission-class defaults plus ownership/attestation overlays
- route to `STAGE_ONLY` when required authorizations are missing

### Observe-only monitoring
- `silent`, `continuous`
- anomaly may fork an operate sub-mission with upgraded route

### Incident response
- minimal bounded containment allowed under emergency route
- breaker/safing/break-glass precedence explicitly visible

### Destructive work
- `approval_required`
- no autonomous point-of-no-return crossing

## Why This Is Better Than A New Registry

A separate scenario registry would duplicate:
- mission class
- ACP policy
- reversibility rules
- executor profiles
- live breaker/safing state

A derived resolver keeps authority where it already belongs and makes the
effective result explicit for both runtime and operators.

## Acceptance Rule

The cutover is not complete until:

- the resolver exists,
- the output is materialized,
- runtime uses it,
- operator views use it,
- scenario conformance tests validate it.

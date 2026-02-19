# AE Gates Patch

## Goal

Update AE gate behavior so the umbrella chain (`assurance > productivity > integration`) drives:

- backlog prioritization
- regression reporting
- high-priority acceptance-criteria requirements

while preserving existing hard-fail vs soft-warn semantics unless explicitly stated.

## Current Gate Baseline (From Runtime)

Current behavior in `.harmony/runtime/crates/assurance_tools/src/main.rs`:

- backlog priority: `weight * gap`, tie-break by chain rank
- regressions: thresholded by weight/delta
- criteria/evidence requirements: mostly weight/mode/maturity based
- severity model: hard fail and soft warn

## Patch Rules

## 1) Backlog Prioritization (Umbrella-Driven Tie-Break)

Keep canonical priority formula:

`priority = effective_weight * max(0, target - measured)`

Ordering:

1. higher `priority`
2. lower `umbrella_rank` (`assurance=1`, `productivity=2`, `integration=3`)
3. higher `weight`
4. deterministic lexical tie-break (`subsystem`, then `attribute`)

Expected output field changes:

```diff
-charter_outcome
-charter_rank
+umbrella
+umbrella_rank
```

## 2) Regression Detection (Umbrella-Aware Reporting)

Preserve existing severity triggers:

- hard: `weight >= 5 && delta <= -0.5`
- hard: `weight >= 4 && delta <= -1.0`
- warn: `weight >= 4 && -1.0 < delta <= -0.5`
- warn: `umbrella_rank == 1 && weight == 3 && delta <= -0.5`

Add umbrella-aware reporting without changing primary hard/warn thresholds:

- include `umbrella` and `umbrella_rank` in regression records
- include umbrella rank as deterministic secondary sort key for top regressions
- keep gate decision derived from hard/warn findings

## 3) High-Priority Acceptance Criteria Requirements

Define high-priority attribute deterministically:

`is_high_priority = (umbrella_rank == 1 && weight == 3) || (weight >= 4)`

Enforcement:

- For `umbrella_rank == 1 && weight == 3`:
  - missing acceptance criteria -> warn in local/ci, hard in release/prod-runtime
  - missing evidence -> warn in local/ci, hard in release/prod-runtime
- For `weight >= 4`:
  - existing criteria/evidence rules remain unchanged
- For non-high-priority:
  - existing behavior unchanged

This keeps existing `weight>=4/5` semantics stable while adding an Assurance-first guardrail for rank-1 `weight=3` attributes.

## 4) Policy-Deviation Governance Rule

Current top-priority deviation check is rank-based. Keep same structure with umbrella naming:

```diff
-charter_priority_deviation
+umbrella_priority_deviation
```

Rule remains:
- lowering an Assurance-rank attribute in repo override without declaration + ADR -> warning or phase-classified violation as currently enforced.

## 5) Example: Backlog Before/After

Before:

```yaml
attribute: deployability
charter_outcome: speed_of_development
charter_rank: 2
priority: 10.0
```

After:

```yaml
attribute: deployability
umbrella: productivity
umbrella_rank: 2
priority: 10.0
```

## 6) Example: Gate Summary Header Before/After

Before:

```text
# Weighted Quality Gate Summary
```

After:

```text
# Assurance Engine Gate Summary
```

## 7) Acceptance Criteria for This Patch

- [ ] Backlog ordering uses umbrella ranks in tie cases.
- [ ] Regression hard/warn counts unchanged for identical inputs.
- [ ] High-priority detection is umbrella-rank-aware.
- [ ] No old-chain IDs appear in gate output fields.
- [ ] Existing fail/warn status outcomes remain stable for unchanged fixtures.

# AE Test Plan: Umbrella Chain Migration

## Goals

Prove that:

1. AE uses the umbrella chain everywhere.
2. Rollup computation is deterministic/stable.
3. Gates behave per umbrella-chain rules, preserving existing `weight>=4/5` semantics while adding rank-1 `weight=3` assurance guardrails.

## Test Strategy

Use three layers:

1. Unit tests for parsing/mapping/ranking logic.
2. Fixture-driven integration tests for score/gate outputs.
3. Repo sweep tests for residual old-chain/QGE references.

## Proposed Test Surfaces

### A) Runtime crate tests

Target:

- `.harmony/runtime/crates/assurance_tools/src/main.rs`
- add test module or integration tests under:
  `.harmony/runtime/crates/assurance_tools/tests/`

New tests:

1. `parse_charter_spec_requires_umbrella_chain`
2. `attribute_map_must_cover_all_attributes`
3. `top_driver_tie_break_prefers_assurance_then_productivity_then_integration`
4. `assurance_rollup_hybrid_formula_is_stable`
5. `gate_high_priority_detection_uses_umbrella_rank`
6. `regression_severity_thresholds_unchanged`

### B) Golden fixtures

Add fixtures under:

- `.harmony/runtime/crates/assurance_tools/tests/fixtures/umbrella/`

Files:

1. `weights.umbrella.yml`
2. `scores.baseline.yml`
3. `context.ci.yml`
4. `scorecard.expected.yml`
5. `results.expected.md`
6. `gate-summary.expected.md`

Representative contexts:

- `ci-reliability + beta + harmony`
- `ci-reliability + prod + my-repo`
- `regulated + critical + payments-repo`

### C) Sweep checks (no residual old-chain logic)

Add CI checks:

```bash
rg -n "trust|speed_of_development|ease_of_use" .harmony/runtime/crates/assurance_tools/src/main.rs .harmony/assurance/standards/weights/weights.yml
rg -n "QGE|legacy QGE label" .harmony .github
```

Rules:

- No old chain IDs in active AE policy/runtime/output templates.
- No QGE naming in active docs/code/commands.

## Determinism and Stability Assertions

For identical fixture inputs:

- `scorecard.yml` hash must be stable.
- `top_backlog` ordering must be stable.
- `gate-summary.md` status and finding counts must be stable.

Example check:

```bash
sha256sum out/run1/scorecard.yml out/run2/scorecard.yml
```

## Gate Behavior Assertions

Use baseline fixture pairs with known deltas:

1. `weight=5`, `delta=-0.5` -> hard fail outside local mode.
2. `weight=4`, `delta=-0.5` -> soft warn.
3. `assurance umbrella + weight=3 + missing criteria` -> warn in local/ci, hard in release/prod-runtime.
4. `assurance umbrella + weight=3 + delta<=-0.5` -> umbrella-priority regression warning.

## Example Golden Output Delta

Before expected key:

```yaml
charter_outcome: trust
charter_rank: 1
```

After expected key:

```yaml
umbrella: assurance
umbrella_rank: 1
```

## CI Wiring

Update `.github/workflows/assurance-weight-gates.yml` (or companion workflow) to run:

1. `cargo test -p harmony_assurance_tools`
2. fixture comparison script for score/gate markdown + yaml outputs
3. residual-reference sweeps

## Exit Criteria

- [ ] All new unit tests pass.
- [ ] Golden fixture outputs match exactly.
- [ ] No old-chain IDs remain in active AE logic/policy.
- [ ] No active QGE references remain.
- [ ] Existing gate severity behavior is preserved for unchanged scenarios.

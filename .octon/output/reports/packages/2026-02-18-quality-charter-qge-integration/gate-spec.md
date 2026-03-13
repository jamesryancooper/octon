# gate-spec

Assurance Engine charter-driven enforcement implemented in:
`/Users/jamesryancooper/Projects/octon/.octon/engine/runtime/crates/assurance_tools/src/main.rs` (`gate` command).

## Hard Fail Checks

1. Charter presence and parseability
- `CHARTER.md` missing or unreadable.
- Charter section parsing fails (priority chain or trade-off rules missing).

2. Charter contract completeness in `weights.yml`
- Missing/invalid `charter` block.
- Missing `priority_chain`, `tradeoff_rules`, `tie_break_rule`, `required_references`, or `attribute_outcome_map`.

3. Charter/weights contradiction
- `weights.yml` charter reference path mismatches active charter path.
- `weights.yml` priority chain differs from `CHARTER.md` section 1.
- `weights.yml` trade-off rules differ from `CHARTER.md` section 4.
- Any required reference path in `weights.yml` does not exist.

4. Governance for policy/charter intent changes
- Policy/charter changed without `meta.version` bump.
- Missing changelog entry for current version.
- Missing changelog rationale.
- Missing/invalid ADR reference.
- Missing/mismatched `charter_ref` in changelog entry.

5. Existing Assurance Engine hard gates retained
- Missing criteria/evidence for high-weight attributes per mode/maturity.
- Regressions beyond configured thresholds.
- Missing ADR for unresolved `5 vs 5` conflicts.
- Control-plane override strictness violations.

## Soft Warn Checks

1. Baseline availability
- Missing baseline weights/scores/charter for drift checks.

2. Charter-priority override risk
- Repo override reduces a top-priority charter outcome without explicit declaration + ADR.

3. Top-driver tie-break drift
- Equal-priority driver ordering does not honor charter priority chain.

4. Existing override warnings retained
- Productivity override missing declaration.
- Missing expiry for declared overrides without permanent justification.

## Why These Severities

- Hard fail: violations that directly break traceability, charter correctness, or trust controls.
- Soft warn: advisory drift/risk signals where immediate breakage is too disruptive, but governance visibility is required.

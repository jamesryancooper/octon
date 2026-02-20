# Assurance Precedence Contract

## Purpose

Define the canonical policy precedence order used by Assurance when resolving
effective weights and override decisions.

## Canonical Order

Assurance resolves policy inputs in this order (later wins):

1. `global`
2. `run-mode`
3. `subsystem`
4. `maturity`
5. `repo`

The same order applies to scorecard computation and gate enforcement.

## Resolution Rules

- Missing keys are ignored; only declared keys participate in merge.
- At equal specificity, the last applied source wins deterministically.
- Repo-level overrides are allowed only under governance controls in
  `SUBSYSTEM_OVERRIDE_POLICY.md` and `overrides.yml`.
- Control-plane deviations without required governance artifacts are
  fail-closed policy violations.

## Sources of Truth

- Policy weights: `.harmony/assurance/governance/weights/weights.yml`
- Override declarations: `.harmony/assurance/governance/overrides.yml`
- Override governance: `.harmony/assurance/governance/SUBSYSTEM_OVERRIDE_POLICY.md`
- Subsystem classes: `.harmony/assurance/governance/subsystem-classes.yml`

## Enforcement Surfaces

- Local/CI computation: `.harmony/assurance/runtime/_ops/scripts/compute-assurance-score.sh`
- Local/CI gating: `.harmony/assurance/runtime/_ops/scripts/assurance-gate.sh`
- Runtime tool: `.harmony/engine/runtime/crates/assurance_tools/src/main.rs`

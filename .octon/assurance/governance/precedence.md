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

## Runtime Authority Tie-Breaker

When runtime authority is shared between capabilities and engine contracts,
Assurance resolves execution authority in this order:

1. Engine runtime safety and lifecycle enforcement (`engine/runtime/**`)
2. Capabilities runtime behavioral semantics (`capabilities/runtime/**`)
3. Domain-local practices and helper guidance

If engine enforcement and capability semantics conflict and no explicit contract
override exists, Assurance MUST fail closed, emit a policy violation, and
require ADR-backed contract reconciliation before promotion.

Practices guidance is advisory and MUST NOT override runtime or governance contracts.

## Resolution Rules

- Missing keys are ignored; only declared keys participate in merge.
- At equal specificity, the last applied source wins deterministically.
- Repo-level overrides are allowed only under governance controls in
  `SUBSYSTEM_OVERRIDE_POLICY.md` and `overrides.yml`.
- Control-plane deviations without required governance artifacts are
  fail-closed policy violations.

## Sources of Truth

- Policy weights: `.octon/assurance/governance/weights/weights.yml`
- Override declarations: `.octon/assurance/governance/overrides.yml`
- Override governance: `.octon/assurance/governance/SUBSYSTEM_OVERRIDE_POLICY.md`
- Subsystem classes: `.octon/assurance/governance/subsystem-classes.yml`
- Runtime tie-breaker contract: `.octon/cognition/_meta/architecture/specification.md` (`OCTON-SPEC-016`)

## Enforcement Surfaces

- Local/CI computation: `.octon/assurance/runtime/_ops/scripts/compute-assurance-score.sh`
- Local/CI gating: `.octon/assurance/runtime/_ops/scripts/assurance-gate.sh`
- Runtime tool: `.octon/engine/runtime/crates/assurance_tools/src/main.rs`

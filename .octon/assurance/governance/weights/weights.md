# Octon Policy Weights

Policy-only weights for assurance trade-offs. Measurement scores live in `/Users/jamesryancooper/Projects/octon/.octon/assurance/governance/scores/scores.yml`.

This policy is resolved and enforced by the **Assurance Engine**,
Octon's authoritative local engine for assurance governance.

## Charter Contract

- Canonical charter: `/Users/jamesryancooper/Projects/octon/.octon/assurance/governance/CHARTER.md`
- Machine contract: `/Users/jamesryancooper/Projects/octon/.octon/assurance/governance/weights/weights.yml` -> `charter`
- Active umbrella chain: `Assurance > Productivity > Integration`
- The resolver and gate validate:
  - charter priority chain alignment,
  - trade-off rule alignment,
  - required charter references,
  - `attribute_umbrella_map` coverage for all canonical attributes,
  - charter-driven tie-break behavior in top-driver output.

Attribute-level scores remain source of truth. Umbrellas are derived rollups for
ordering and reporting.

## Core Rule

Effective weights are resolved by applying layers in this order:

`global -> run-mode -> subsystem -> maturity -> repo`

Later layers override earlier layers for the same attribute.

## Attribute Guidance: `autonomy`

- Definition: ability for Octon to execute useful work independently within explicit policy boundaries.
- Boundary rule: autonomy never overrides safety/security or no-silent-apply/ACP promotion requirements.
- Primary tensions: `safety`, `security`, `auditability`, `complexity_calibration`, `usability`.
- Scoring cues:
  - `1`: mostly manual or autonomy is effectively disallowed for the subsystem.
  - `3`: bounded autonomy for low-risk/read-only tasks; material effects remain ACP-gated.
  - `5`: autonomous low/medium-risk execution is reliable, deterministic, and policy-bounded with clear ACP gates.
- Evidence examples:
  - `/Users/jamesryancooper/Projects/octon/.octon/cognition/governance/principles/no-silent-apply.md`
  - `/Users/jamesryancooper/Projects/octon/.octon/cognition/governance/principles/autonomous-control-points.md`
  - `/Users/jamesryancooper/Projects/octon/.octon/cognition/governance/principles/deny-by-default.md`
  - `/Users/jamesryancooper/Projects/octon/.octon/cognition/_meta/architecture/runtime-policy.md`

## Governance

- Weight changes require a version bump in `/Users/jamesryancooper/Projects/octon/.octon/assurance/governance/weights/weights.yml`.
- Weight changes require a changelog entry with rationale and ADR reference.
- Score changes do not require ADR/version by default and should be tracked in `/Users/jamesryancooper/Projects/octon/.octon/assurance/governance/scores/scores.yml`.
- Profile sprawl is constrained via guardrails (`max_active_profiles_per_repo`, naming regex, and deprecation rules).

## Source Files

- Policy weights: `/Users/jamesryancooper/Projects/octon/.octon/assurance/governance/weights/weights.yml`
- Measurement scores: `/Users/jamesryancooper/Projects/octon/.octon/assurance/governance/scores/scores.yml`
- Resolver entrypoint: `/Users/jamesryancooper/Projects/octon/.octon/assurance/runtime/_ops/scripts/compute-assurance-score.sh`
- Gate entrypoint: `/Users/jamesryancooper/Projects/octon/.octon/assurance/runtime/_ops/scripts/assurance-gate.sh`
- Rust implementation: `/Users/jamesryancooper/Projects/octon/.octon/engine/runtime/crates/assurance_tools/src/main.rs`

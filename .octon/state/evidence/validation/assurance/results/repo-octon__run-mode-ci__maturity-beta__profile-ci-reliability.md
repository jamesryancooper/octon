# Assurance Engine Results

- Profile: `ci-reliability`
- Repo: `octon`
- Run mode: `ci`
- Maturity: `beta`
- System score: `76.20%`

## Charter Metadata

- Charter: `.octon/framework/assurance/governance/CHARTER.md`
- Version: `2.2.3`
- Umbrella chain: `Assurance (assurance) > Productivity (productivity) > Integration (integration)`
- Tie-break rule: When weighted priority ties, prioritize items mapped to higher umbrellas in chain order.

## Trade-off Rules

- Assurance is non-negotiable.
- Productivity is optimized inside assurance constraints.
- Integration requires explicit contracts, security controls, and tests.
- Attribute-level scoring remains the source of truth.
- Umbrella rollups must not hide critical assurance weaknesses.

## Conflict Resolution

Equal-priority conflicts were resolved by umbrella chain order.

| Priority | Winner | Loser | Winner Umbrella | Loser Umbrella |
|---:|---|---|---|---|
| 10 | `scaffolding:observability` | `assurance:operability` | `assurance` | `productivity` |

## Umbrella Rollups

| Umbrella | Rank | Score | Weighted Mean | Critical Floor | Samples | Formula |
|---|---:|---:|---:|---:|---:|---|
| `Assurance` | 1 | `82.63%` | 4.1875 | 4.000 | 100 | `0.7*weighted_mean + 0.3*critical_floor` |
| `Productivity` | 2 | `67.67%` | 3.383333 | n/a | 140 | `weighted_mean` |
| `Integration` | 3 | `84.50%` | 4.225 | n/a | 30 | `weighted_mean` |

## Subsystem Totals

| Subsystem | Weighted Score |
|---|---:|
| `agency` | `76.87%` |
| `assurance` | `76.49%` |
| `capabilities` | `76.49%` |
| `cognition` | `77.02%` |
| `continuity` | `76.49%` |
| `ideation` | `72.61%` |
| `orchestration` | `75.30%` |
| `output` | `75.44%` |
| `runtime` | `79.30%` |
| `scaffolding` | `76.00%` |

## Top Drivers

Prioritization formula: `effective_weight × max(0, target_score - current_score)`

| Subsystem | Attribute | Umbrella | Rank | Weight | Current | Target | Gap | Priority | Evidence | Suggested Action |
|---|---|---|---:|---:|---:|---:|---:|---:|---|---|
| `agency` | `availability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/practices/methodology/reliability-and-ops.md, .octon/framework/cognition/practices/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `agency` | `observability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/governance/principles/observability-as-a-contract.md, .octon/framework/cognition/_meta/architecture/observability-requirements.md, .octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh | Raise 'observability' from 3 to target 5. |
| `assurance` | `availability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/practices/methodology/reliability-and-ops.md, .octon/framework/cognition/practices/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `assurance` | `observability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/governance/principles/observability-as-a-contract.md, .octon/framework/cognition/_meta/architecture/observability-requirements.md, .octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh | Raise 'observability' from 3 to target 5. |
| `capabilities` | `availability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/practices/methodology/reliability-and-ops.md, .octon/framework/cognition/practices/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `capabilities` | `observability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/governance/principles/observability-as-a-contract.md, .octon/framework/cognition/_meta/architecture/observability-requirements.md, .octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh | Raise 'observability' from 3 to target 5. |
| `cognition` | `availability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/practices/methodology/reliability-and-ops.md, .octon/framework/cognition/practices/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `cognition` | `observability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/governance/principles/observability-as-a-contract.md, .octon/framework/cognition/_meta/architecture/observability-requirements.md, .octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh | Raise 'observability' from 3 to target 5. |
| `continuity` | `availability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/practices/methodology/reliability-and-ops.md, .octon/framework/cognition/practices/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `ideation` | `availability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/practices/methodology/reliability-and-ops.md, .octon/framework/cognition/practices/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `ideation` | `observability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/governance/principles/observability-as-a-contract.md, .octon/framework/cognition/_meta/architecture/observability-requirements.md, .octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh | Raise 'observability' from 3 to target 5. |
| `orchestration` | `availability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/practices/methodology/reliability-and-ops.md, .octon/framework/cognition/practices/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `orchestration` | `observability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/governance/principles/observability-as-a-contract.md, .octon/framework/cognition/_meta/architecture/observability-requirements.md, .octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh | Raise 'observability' from 3 to target 5. |
| `output` | `availability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/practices/methodology/reliability-and-ops.md, .octon/framework/cognition/practices/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `output` | `observability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/governance/principles/observability-as-a-contract.md, .octon/framework/cognition/_meta/architecture/observability-requirements.md, .octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh | Raise 'observability' from 3 to target 5. |
| `scaffolding` | `availability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/practices/methodology/reliability-and-ops.md, .octon/framework/cognition/practices/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `scaffolding` | `observability` | `assurance` | 1 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/governance/principles/observability-as-a-contract.md, .octon/framework/cognition/_meta/architecture/observability-requirements.md, .octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh | Raise 'observability' from 3 to target 5. |
| `assurance` | `operability` | `productivity` | 2 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/practices/methodology/reliability-and-ops.md, .octon/framework/cognition/_meta/architecture/runtime-policy.md | Raise 'operability' from 3 to target 5. |
| `capabilities` | `operability` | `productivity` | 2 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/practices/methodology/reliability-and-ops.md, .octon/framework/cognition/_meta/architecture/runtime-policy.md | Raise 'operability' from 3 to target 5. |
| `cognition` | `operability` | `productivity` | 2 | 5 | 3 | 5 | 2 | 10 | .octon/framework/cognition/practices/methodology/reliability-and-ops.md, .octon/framework/cognition/_meta/architecture/runtime-policy.md | Raise 'operability' from 3 to target 5. |

## Regressions

- Hard: `0`
- Soft: `0`

# Weighted Quality Results

- Profile: `ci-reliability`
- Repo: `harmony`
- Run mode: `ci`
- Maturity: `beta`
- System score: `76.20%`

## Charter Metadata

- Charter: `.harmony/assurance/CHARTER.md`
- Version: `1.0.0`
- Priority chain: `Trust (trust) > Speed of development (speed_of_development) > Ease of use (ease_of_use) > Portability (portability) > Interoperability (interoperability)`
- Tie-break rule: When weighted priority ties, prioritize items mapped to higher charter outcomes in chain order.

## Trade-off Rules

- Trust is non-negotiable.
- Speed is optimized inside trust constraints.
- Ease of use is protected by progressive disclosure.
- Portability is preserved by contracts and isolation.
- Interoperability is allowed only with versioning + security + tests.

## Conflict Resolution

Equal-priority conflicts were resolved by charter chain order.

| Priority | Winner | Loser | Winner Outcome | Loser Outcome |
|---:|---|---|---|---|
| 10 | `scaffolding:observability` | `ideation:maintainability` | `trust` | `speed_of_development` |
| 10 | `ideation:maintainability` | `assurance:operability` | `speed_of_development` | `ease_of_use` |

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

| Subsystem | Attribute | Outcome | Rank | Weight | Current | Target | Gap | Priority | Evidence | Suggested Action |
|---|---|---|---:|---:|---:|---:|---:|---:|---|---|
| `agency` | `availability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/methodology/reliability-and-ops.md, .harmony/cognition/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `agency` | `observability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/principles/observability-as-a-contract.md, .harmony/cognition/_meta/architecture/observability-requirements.md | Raise 'observability' from 3 to target 5. |
| `assurance` | `availability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/methodology/reliability-and-ops.md, .harmony/cognition/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `assurance` | `observability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/principles/observability-as-a-contract.md, .harmony/cognition/_meta/architecture/observability-requirements.md | Raise 'observability' from 3 to target 5. |
| `capabilities` | `availability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/methodology/reliability-and-ops.md, .harmony/cognition/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `capabilities` | `observability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/principles/observability-as-a-contract.md, .harmony/cognition/_meta/architecture/observability-requirements.md | Raise 'observability' from 3 to target 5. |
| `cognition` | `availability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/methodology/reliability-and-ops.md, .harmony/cognition/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `cognition` | `observability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/principles/observability-as-a-contract.md, .harmony/cognition/_meta/architecture/observability-requirements.md | Raise 'observability' from 3 to target 5. |
| `continuity` | `availability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/methodology/reliability-and-ops.md, .harmony/cognition/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `ideation` | `availability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/methodology/reliability-and-ops.md, .harmony/cognition/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `ideation` | `observability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/principles/observability-as-a-contract.md, .harmony/cognition/_meta/architecture/observability-requirements.md | Raise 'observability' from 3 to target 5. |
| `orchestration` | `availability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/methodology/reliability-and-ops.md, .harmony/cognition/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `orchestration` | `observability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/principles/observability-as-a-contract.md, .harmony/cognition/_meta/architecture/observability-requirements.md | Raise 'observability' from 3 to target 5. |
| `output` | `availability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/methodology/reliability-and-ops.md, .harmony/cognition/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `output` | `observability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/principles/observability-as-a-contract.md, .harmony/cognition/_meta/architecture/observability-requirements.md | Raise 'observability' from 3 to target 5. |
| `scaffolding` | `availability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/methodology/reliability-and-ops.md, .harmony/cognition/methodology/risk-tiers.md | Raise 'availability' from 3 to target 5. |
| `scaffolding` | `observability` | `trust` | 1 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/principles/observability-as-a-contract.md, .harmony/cognition/_meta/architecture/observability-requirements.md | Raise 'observability' from 3 to target 5. |
| `ideation` | `maintainability` | `speed_of_development` | 2 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/principles/documentation-is-code.md, .harmony/cognition/principles/ownership-and-boundaries.md | Raise 'maintainability' from 3 to target 5. |
| `assurance` | `operability` | `ease_of_use` | 3 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/methodology/reliability-and-ops.md, .harmony/cognition/_meta/architecture/runtime-policy.md | Raise 'operability' from 3 to target 5. |
| `capabilities` | `operability` | `ease_of_use` | 3 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/methodology/reliability-and-ops.md, .harmony/cognition/_meta/architecture/runtime-policy.md | Raise 'operability' from 3 to target 5. |

## Regressions

- Hard: `0`
- Soft: `0`

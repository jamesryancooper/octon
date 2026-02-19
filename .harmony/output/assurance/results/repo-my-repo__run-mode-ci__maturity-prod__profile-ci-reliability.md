# Weighted Quality Results

- Profile: `ci-reliability`
- Repo: `my-repo`
- Run mode: `ci`
- Maturity: `prod`
- System score: `76.08%`

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
| 10 | `scaffolding:observability` | `agency:deployability` | `trust` | `speed_of_development` |

## Subsystem Totals

| Subsystem | Weighted Score |
|---|---:|
| `agency` | `76.72%` |
| `assurance` | `76.35%` |
| `capabilities` | `76.35%` |
| `cognition` | `76.87%` |
| `continuity` | `76.35%` |
| `ideation` | `72.50%` |
| `orchestration` | `75.34%` |
| `output` | `75.30%` |
| `runtime` | `79.13%` |
| `scaffolding` | `75.86%` |

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
| `agency` | `deployability` | `speed_of_development` | 2 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/_meta/architecture/runtime-policy.md, .github/workflows/runtime-binaries.yml | Raise 'deployability' from 3 to target 5. |
| `assurance` | `deployability` | `speed_of_development` | 2 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/_meta/architecture/runtime-policy.md, .github/workflows/runtime-binaries.yml | Raise 'deployability' from 3 to target 5. |
| `capabilities` | `deployability` | `speed_of_development` | 2 | 5 | 3 | 5 | 2 | 10 | .harmony/cognition/_meta/architecture/runtime-policy.md, .github/workflows/runtime-binaries.yml | Raise 'deployability' from 3 to target 5. |

## Regressions

- Hard: `0`
- Soft: `0`

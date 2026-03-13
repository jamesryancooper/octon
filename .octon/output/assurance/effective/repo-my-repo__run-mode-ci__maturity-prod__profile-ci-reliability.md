# Effective Weights

- Profile: `ci-reliability`
- Repo: `my-repo`
- Run mode: `ci`
- Maturity: `prod`

## Charter Metadata

- Charter: `.octon/assurance/CHARTER.md`
- Umbrella chain: `Assurance > Productivity > Integration`
- Tie-break rule: When weighted priority ties, prioritize items mapped to higher umbrellas in chain order.

## Trade-off Rules

- Assurance is non-negotiable.
- Productivity is optimized inside assurance constraints.
- Integration requires explicit contracts, security controls, and tests.
- Attribute-level scoring remains the source of truth.
- Umbrella rollups must not hide critical assurance weaknesses.

## Conflict Resolution

Priority ties were resolved using the umbrella chain (higher-ranked umbrellas win).

| Priority | Winner | Loser | Winner Umbrella | Loser Umbrella |
|---:|---|---|---|---|
| 10 | `scaffolding:observability` | `agency:deployability` | `assurance` | `productivity` |

## Matrix

| Attribute | `agency` | `assurance` | `capabilities` | `cognition` | `continuity` | `ideation` | `orchestration` | `output` | `runtime` | `scaffolding` |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `Performance` (`performance`) | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 |
| `Scalability` (`scalability`) | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 |
| `Reliability` (`reliability`) | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 |
| `Availability` (`availability`) | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 |
| `Robustness` (`robustness`) | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 |
| `Recoverability` (`recoverability`) | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 |
| `Dependability` (`dependability`) | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 |
| `Safety` (`safety`) | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 |
| `Autonomy` (`autonomy`) | 5 | 4 | 4 | 4 | 4 | 1 | 5 | 4 | 4 | 4 |
| `Security` (`security`) | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 |
| `Simplicity` (`simplicity`) | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 |
| `Evolvability` (`evolvability`) | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 |
| `Long-term Maintainability` (`maintainability`) | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 |
| `Portability` (`portability`) | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 |
| `Functional Suitability` (`functional_suitability`) | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 |
| `Completeness` (`completeness`) | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 |
| `Operability` (`operability`) | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 |
| `Observability` (`observability`) | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 |
| `Testability` (`testability`) | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 |
| `Auditability` (`auditability`) | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 |
| `Deployability` (`deployability`) | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 |
| `Usability` (`usability`) | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 4 |
| `Accessibility` (`accessibility`) | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 |
| `Interoperability` (`interoperability`) | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 |
| `Compatibility` (`compatibility`) | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 |
| `Configurability` (`configurability`) | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 |
| `Sustainability` (`sustainability`) | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 |

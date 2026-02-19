# AE Mapping: Old Chain to Umbrella Chain

## 1) Old Priority Elements -> New Umbrellas

| Old element | New umbrella | Rationale |
|---|---|---|
| Trust | Assurance | Same governance intent: confidence, safety, correctness, explainability. |
| Speed of development | Productivity | Throughput and cycle-time optimization. |
| Ease of use | Productivity | Friction reduction and operator/developer leverage. |
| Portability | Integration | Cross-environment operation. |
| Interoperability | Integration | Cross-tool/repo/system compatibility. |

## 2) Attribute -> Primary Umbrella (Authoritative)

| Attribute | Primary umbrella |
|---|---|
| dependability | assurance |
| security | assurance |
| safety | assurance |
| reliability | assurance |
| availability | assurance |
| robustness | assurance |
| recoverability | assurance |
| auditability | assurance |
| observability | assurance |
| functional_suitability | assurance |
| autonomy | productivity |
| performance | productivity |
| scalability | productivity |
| simplicity | productivity |
| evolvability | productivity |
| maintainability | productivity |
| completeness | productivity |
| operability | productivity |
| testability | productivity |
| deployability | productivity |
| usability | productivity |
| accessibility | productivity |
| configurability | productivity |
| sustainability | productivity |
| portability | integration |
| interoperability | integration |
| compatibility | integration |

## 3) Umbrella Rollup Rule Choice

Chosen rule: **hybrid**

Reason:
Weighted average alone can hide severe Assurance weakness in one critical attribute.
Min-only is too pessimistic for planning.
Hybrid preserves assurance-first governance and still reflects broad posture.

### Deterministic Formula

For umbrella `U`:

`weighted_mean(U) = sum(weight[a] * score[a]) / sum(weight[a])`

If `U != assurance`:

`umbrella_score(U) = weighted_mean(U)`

If `U == assurance`:

- `critical_set = {security, safety, reliability, recoverability, dependability, functional_suitability}`
- `critical_floor = min(score[a] for a in critical_set)`
- `umbrella_score(assurance) = 0.7 * weighted_mean(assurance) + 0.3 * critical_floor`

Rounding:
- internal math at float precision
- persisted score/mean values rounded to 6 decimals
- percent views rounded to 2 decimals

## 4) How Umbrellas Influence Weighting Without Hiding Attributes

1. Attribute priority remains canonical:
   `priority[a] = effective_weight[a] * max(0, target[a] - measured[a])`
2. Umbrella only affects ordering when priorities tie:
   lower `umbrella_rank` wins (`assurance=1`, `productivity=2`, `integration=3`)
3. Gate checks still evaluate per-attribute criteria/evidence/regression thresholds.
4. Umbrella rollups are additive reporting views, not replacements for attribute rows.

## 5) Optional Secondary Tagging Rule

Secondary tags may be stored for reporting:

```yaml
attribute_tags:
  observability:
    primary: assurance
    secondary: [integration]
```

Constraint:
`primary` is the only value used for precedence unless an explicit future rule is added.

## 6) Before/After Example Driver Row

Before:

```yaml
attribute: observability
charter_outcome: trust
charter_rank: 1
priority: 10.0
```

After:

```yaml
attribute: observability
umbrella: assurance
umbrella_rank: 1
priority: 10.0
```

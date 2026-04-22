# Architecture Health Contract v3

This contract defines Octon's achieved-depth aggregate architecture health
gate.

## Depth classes

- `existence`
- `schema`
- `semantic`
- `runtime`
- `proof`
- `closure-grade`

## Validator result contract

Every validator that contributes to the aggregate architecture-health result
must emit a structured record with:

```yaml
validator_id:
dimension:
claimed_depth:
achieved_depth:
evidence_refs:
runtime_tests_executed:
negative_controls_executed:
limitations:
```

`claimed_depth` expresses the validator's intended ceiling.
`achieved_depth` records what the current run or retained evidence actually
proved.

## Required closure-grade dimensions

| Dimension | Minimum achieved depth |
| --- | --- |
| structural contract | `semantic` |
| recursive runtime-effective handles | `runtime` |
| publication freshness | `runtime` |
| authorization coverage | `runtime` |
| capability-pack cutover | `semantic` |
| extension lifecycle | `runtime` |
| support proof executability | `proof` |
| operator read models | `semantic` |
| compatibility retirement cutover | `semantic` |
| publication receipts | `proof` |
| architecture-health aggregation | `closure-grade` |

## Rules

1. A dimension passes only at the depth actually proven by its validator or
   retained evidence.
2. A required closure-grade dimension fails when it only proves existence or
   schema.
3. Closure-grade status requires the minimum achieved depth listed above for
   every required dimension.
4. The aggregate gate may orchestrate narrower validators, but it may not mint
   a second authority surface.
5. The final certificate lives under
   `/.octon/state/evidence/validation/architecture/10of10-target-transition/closure/**`.

## Canonical validator

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-health.sh`

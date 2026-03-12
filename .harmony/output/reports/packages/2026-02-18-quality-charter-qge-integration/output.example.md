# output.example

Context:
`repo=harmony`, `run-mode=ci`, `maturity=beta`, `profile=ci-reliability`

Generated files:

- Effective matrix: `/Users/jamesryancooper/Projects/harmony/.harmony/output/assurance/effective/repo-harmony__run-mode-ci__maturity-beta__profile-ci-reliability.md`
- Weighted results: `/Users/jamesryancooper/Projects/harmony/.harmony/output/assurance/results/repo-harmony__run-mode-ci__maturity-beta__profile-ci-reliability.md`

## Effective Output (excerpt)

```md
# Effective Weights

- Profile: `ci-reliability`
- Repo: `harmony`
- Run mode: `ci`
- Maturity: `beta`

## Charter Metadata

- Charter: `.harmony/assurance/governance/CHARTER.md`
- Priority chain: `Assurance > Productivity > Integration`
- Tie-break rule: When weighted priority ties, prioritize items mapped to higher charter outcomes in chain order.

## Trade-off Rules

- Assurance is non-negotiable.
- Productivity is optimized inside assurance constraints.
- Integration is preserved by explicit versioned contracts and controls.
```

## Results Output (excerpt)

```md
# Weighted Assurance Results

- Profile: `ci-reliability`
- Repo: `harmony`
- Run mode: `ci`
- Maturity: `beta`
- System score: `76.20%`

## Conflict Resolution

Equal-priority conflicts were resolved by charter chain order.

| Priority | Winner | Loser | Winner Outcome | Loser Outcome |
|---:|---|---|---|---|
| 10 | `scaffolding:auditability` | `ideation:maintainability` | `assurance` | `productivity` |
```

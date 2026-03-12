# Harmony Weights (Human-Readable Example)
Version: `1.0.0`
Status: `active`
Owner: `harmony-platform`
Updated: `2026-02-18`

## Canonical Attribute IDs
`performance`, `scalability`, `reliability`, `availability`, `robustness`, `recoverability`, `dependability`, `safety`, `security`, `simplicity`, `evolvability`, `maintainability`, `portability`, `functional_suitability`, `completeness`, `operability`, `observability`, `testability`, `auditability`, `deployability`, `usability`, `accessibility`, `interoperability`, `compatibility`, `configurability`, `sustainability`

## Profile: `global-default`
Baseline for all contexts before overrides.

| Attribute | Weight |
|---|---:|
| performance | 3 |
| scalability | 3 |
| reliability | 5 |
| availability | 4 |
| robustness | 4 |
| recoverability | 5 |
| dependability | 4 |
| safety | 5 |
| security | 5 |
| simplicity | 5 |
| evolvability | 4 |
| maintainability | 5 |
| portability | 5 |
| functional_suitability | 5 |
| completeness | 4 |
| operability | 4 |
| observability | 4 |
| testability | 4 |
| auditability | 4 |
| deployability | 4 |
| usability | 3 |
| accessibility | 3 |
| interoperability | 4 |
| compatibility | 3 |
| configurability | 3 |
| sustainability | 2 |

## Profile: `ci-reliability`
Delivery-control profile for CI and release validation.

Overrides from global:
- `scalability: 4`
- `availability: 5`
- `operability: 5`
- `observability: 5`
- `testability: 5`
- `auditability: 5`
- `deployability: 5`

## Profile: `local-devex`
Developer ergonomics profile for local iteration.

Overrides from global:
- `performance: 4`
- `simplicity: 5`
- `usability: 5`
- `portability: 5`
- `auditability: 3`
- `availability: 3`

## Profile: `regulated`
High-assurance regulated profile.

Overrides from global:
- `dependability: 5`
- `auditability: 5`
- `observability: 5`
- `testability: 5`
- `availability: 5`
- `recoverability: 5`
- `safety: 5`
- `security: 5`

## Run-Mode Overrides
- `local`: prefer `local-devex`
- `ci`: prefer `ci-reliability`
- `release`: prefer `ci-reliability`
- `prod-runtime`: prefer `regulated` if repo is regulated, else `ci-reliability`

## Subsystem Overrides (Examples)
- `runtime`: raise reliability, recoverability, safety, security, observability, operability.
- `scaffolding`: raise simplicity, portability, usability.
- `continuity`: raise auditability, observability, recoverability.
- `quality`: raise testability, functional_suitability, auditability.

## Maturity Defaults
- `prototype` -> `local-devex`
- `alpha` -> `global-default`
- `beta` -> `ci-reliability`
- `prod` -> `ci-reliability`
- `critical` -> `regulated`

## Repo Override Example
Repo `harmony` can pin:
- `portability: 5`
- `simplicity: 5`
- `auditability: 5`

## Deprecation Rules
1. Profiles must have status: `active | deprecated`.
2. Deprecated profiles need:
   - replacement profile,
   - sunset date,
   - migration note.
3. Removal is allowed only after:
   - at least 2 release cycles,
   - zero repos referencing profile.

## Changelog (Append-Only)
- `2026-02-18`: `v1.0.0` initialized with `global-default`, `ci-reliability`, `local-devex`, `regulated`.
- `2026-02-18`: added precedence contract (`global -> run-mode -> subsystem -> maturity -> repo`).

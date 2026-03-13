# Scoring Workflow, Regression Detection, and Enforcement

## 1. Engineer Workflow (Update + Score)
1. Update subsystem measured scores in `.octon/assurance/governance/scores/scores.yml`.
2. Include acceptance criteria and evidence refs per updated attribute.
3. Select context (`run_mode`, `subsystem`, `maturity`, `repo`) in context input.
4. Run score computation locally:
   - `compute-assurance-score.sh --profile <id> --context <context.yml> --scores <scores.yml>`
5. Review generated scorecard and top drivers.
6. If any `5 vs 5` conflict was intentionally accepted, add ADR link.
7. Commit score artifacts (or attach in CI output) for review.

## 2. Score Computation Outputs
For each run, publish:
- `scorecard.md` (human summary)
- `scorecard.yml` (machine data)
- `effective-weights.yml` (resolved weights after precedence)
- `regressions.md` (threshold breaches and driver list)

Suggested output path:
- `.octon/output/assurance/scorecards/<YYYY-MM-DD>/<run-id>/`

## 3. Regression Detection Rules

### 3.1 Definitions
- `delta_attr = measured_now - measured_prev`
- `weighted_impact = effective_weight * delta_attr`

### 3.2 Thresholds
- Hard regression threshold:
  - if effective weight `>=5` and `delta_attr <= -0.5`
  - if effective weight `>=4` and `delta_attr <= -1.0`
- Soft warning threshold:
  - if effective weight `>=4` and `-1.0 < delta_attr <= -0.5`
  - if effective weight `==3` and `delta_attr <= -1.0`

### 3.3 Baseline Selection
- Default baseline = previous successful run with same profile + same subsystem + same maturity.
- If missing baseline, compare against configured profile target (no fail, warn only).

## 4. Hard Fail vs Soft Warn Policy
| Rule | Local | CI | Release/Prod-runtime |
|---|---|---|---|
| Missing criteria for weight 5 | Fail | Fail | Fail |
| Missing evidence for weight 5 | Warn | Fail | Fail |
| Missing criteria/evidence for weight 4 | Warn | Warn | Fail (maturity >= prod) |
| High-weight regression beyond threshold | Warn | Fail | Fail |
| Missing ADR for `5 vs 5` conflict | Warn | Fail | Fail |
| Profile deprecated and past sunset | Warn | Fail | Fail |

Rationale:
- Local mode prioritizes fast iteration with high-signal warnings.
- CI enforces quality drift control.
- Release/prod-runtime enforces strict confidence and auditability.

## 5. Required Attribute Acceptance Checks
Before pass:
1. For each effective weight `5` attribute in current context:
   - acceptance criteria must exist,
   - at least one evidence reference must exist,
   - measured score must be present.
2. For each effective weight `4` attribute:
   - criteria + measured score required,
   - evidence required in CI when maturity `>= beta`.

## 6. Maturity Integration

### Stage Defaults
- `prototype`: `local-devex`
- `alpha`: `global-default`
- `beta`: `ci-reliability`
- `prod`: `ci-reliability`
- `critical`: `regulated`

### Evidence Requirements by Maturity
| Maturity | Required evidence minimum |
|---|---|
| prototype | lint/type/unit + basic acceptance criteria for weight 5 |
| alpha | + contract tests on changed boundaries + rollback notes |
| beta | + observability evidence (`trace_id`) + risk-tier review |
| prod | + runbooks + SLO definitions + rollback rehearsal evidence |
| critical | + DR drills + full threat model + compliance audit trail |

## 7. Publishing and Consumption
1. CI publishes scorecard artifacts as build artifacts and (optionally) commits summary markdown under `.octon/output/assurance/scorecards/`.
2. PR template includes “Quality Weight Delta” section linking current scorecard.
3. Backlog automation consumes `top_drivers` from scorecard and opens/updates prioritized tasks.

## 8. Profile Sprawl Controls
1. Maximum active profiles per repo: `<= 6`.
2. New profile requires proof that existing profiles cannot express the requirement.
3. Near-duplicate profile detection (`>=80% identical weights`) must fail profile creation.
4. Quarterly pruning: inactive profiles auto-marked deprecated with sunset.

# resolver.md

## Resolver Inputs

- Policy: `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/governance/weights/weights.yml`
- Measurement: `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/governance/scores/scores.yml`
- Context: `repo`, `run-mode`, `maturity`, optional explicit `profile`, optional subsystem filter.
- Optional baseline scorecard for deltas.

## Active Context Selection

Resolution order:

1. Explicit CLI/context profile (if provided)
2. `selection_defaults.run_mode[run-mode]`
3. `selection_defaults.maturity[maturity]`
4. `selection_defaults.fallback_profile`
5. `global-default`

## Effective Weight Resolution

For each subsystem, start from active profile policy and apply layers in order:

`global -> run-mode -> subsystem -> maturity -> repo`

Later layer wins for the same attribute.

Tie behavior:
- No averaging, no blending.
- Deterministic replacement on collision.

## Scoring

Per subsystem:

- `weighted_score = sum(weight[a] * score[a]) / sum(weight[a] * 5)`
- all attributes included; missing measurement defaults are normalized by resolver input model.

System score:
- arithmetic mean of subsystem weighted scores.

## Deltas

If baseline scorecard is present:
- `delta[a] = current_score[a] - baseline_score[a]`
- `regression_impact[a] = effective_weight[a] * delta[a]`

## Backlog Driver Priority

Primary backlog driver formula:

- `priority[a] = effective_weight[a] * max(0, target_score[a] - current_score[a])`

Driver payload includes:
- subsystem
- attribute
- current score
- target score
- gap
- effective weight
- priority
- evidence pointers
- suggested action

## Output Artifacts

Resolver writes:

- `/Users/jamesryancooper/Projects/harmony/.harmony/output/assurance/effective/<context>.md`
- `/Users/jamesryancooper/Projects/harmony/.harmony/output/assurance/results/<context>.md`

Gate artifacts written by resolver:

- `/Users/jamesryancooper/Projects/harmony/.harmony/output/assurance/scorecards/<date>/<run-id>/scorecard.yml`
- `/Users/jamesryancooper/Projects/harmony/.harmony/output/assurance/scorecards/<date>/<run-id>/scorecard.md`

## Example Context

`repo=my-repo`, `run-mode=ci`, `maturity=prod`, `profile=ci-reliability`

Effective precedence application for subsystem `runtime`:

1. load `global` map
2. apply `run_mode/ci`
3. apply `subsystem/runtime`
4. apply `maturity/prod`
5. apply `repo/my-repo` (if exists)

Final map is the effective weight vector used for scoring and gate decisions.

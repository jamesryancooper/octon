# pseudocode.md

## Profile + Policy Resolution

```text
INPUT:
  weights.yml, context={repo, run_mode, maturity, profile?}

FUNCTION select_profile(context, weights):
  if context.profile is set:
    return context.profile
  if weights.selection_defaults.run_mode has context.run_mode:
    return mapped profile
  if weights.selection_defaults.maturity has context.maturity:
    return mapped profile
  if weights.selection_defaults.fallback_profile exists:
    return fallback
  return "global-default"

FUNCTION resolve_profile_policy(profile_id):
  profile = weights.profiles[profile_id]
  if profile.base exists:
    parent_policy = resolve_profile_policy(profile.base)
  else:
    parent_policy = empty policy

  own_policy = normalize(profile.weights)
  merged_policy = deep_merge(parent_policy, own_policy)
  return merged_policy
```

## Effective Weights (Required Precedence)

```text
FUNCTION effective_weights(policy, context, subsystem):
  out = copy(policy.global)

  # Required application order
  if policy.run_mode[context.run_mode] exists:
    out = merge(out, policy.run_mode[context.run_mode])

  if policy.subsystem[subsystem] exists:
    out = merge(out, policy.subsystem[subsystem])

  if policy.maturity[context.maturity] exists:
    out = merge(out, policy.maturity[context.maturity])

  if policy.repo[context.repo] exists:
    out = merge(out, policy.repo[context.repo])

  validate all canonical attributes present
  validate each value is integer 1..5
  return out
```

## Weighted Scores + Deltas

```text
FUNCTION score_subsystem(effective_weights, measured_scores):
  numerator = 0
  denominator = 0
  FOR each attribute a:
    w = effective_weights[a]
    s = measured_scores[a]
    numerator += w * s
    denominator += w * 5
  return numerator / denominator

FUNCTION delta(current_scores, baseline_scores):
  FOR each subsystem, attribute:
    d = current - baseline
    impact = effective_weight * d
```

## Backlog Drivers

```text
FUNCTION backlog_drivers(effective_weights, scores):
  drivers = []
  FOR each subsystem, attribute a:
    current = scores[subsystem][a].score
    target = scores[subsystem][a].target_score default 5
    gap = max(0, target - current)
    priority = effective_weights[a] * gap
    drivers.push({subsystem, a, current, target, gap, weight, priority})

  sort drivers by priority desc, weight desc
  return top N
```

## Gate Rules

```text
IF weights policy changed vs baseline:
  require meta.version bump
  require changelog entry for current version
  require non-empty rationale
  require ADR reference

FOR each score record:
  IF score <= 2 and evidence missing -> fail in ci/release/prod-runtime, warn in local
  IF high-weight regression and evidence missing -> fail in ci/release/prod-runtime, warn in local

FOR each 5v5 conflict:
  require ADR reference
```

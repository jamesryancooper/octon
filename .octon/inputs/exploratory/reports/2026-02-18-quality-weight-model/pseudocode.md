# Deterministic Algorithms (Profile Selection + Scoring)

## 1. Resolve Active Profile and Effective Weights
```text
INPUTS:
  weights_registry
  context = { run_mode, subsystem, maturity, repo, explicit_profile? }

FUNCTION resolve_profile(weights_registry, context):
  if context.explicit_profile exists:
    return context.explicit_profile

  if weights_registry.selection_defaults.run_mode contains context.run_mode:
    return weights_registry.selection_defaults.run_mode[context.run_mode]

  if weights_registry.maturity_defaults contains context.maturity:
    return weights_registry.maturity_defaults[context.maturity]

  return "global-default"

FUNCTION merge_weights(base_map, override_map):
  result = copy(base_map)
  for each attribute_id in override_map:
    result[attribute_id] = override_map[attribute_id]
  return result

FUNCTION effective_weights(weights_registry, context):
  profile_id = resolve_profile(weights_registry, context)
  profile = weights_registry.profiles[profile_id]

  if profile has base:
    base = weights_registry.profiles[profile.base].weights
    current = merge_weights(base, profile.weights)
  else:
    current = copy(profile.weights)

  # precedence: global -> run-mode -> subsystem -> maturity -> repo
  if overrides.run_mode contains context.run_mode:
    current = merge_weights(current, overrides.run_mode[context.run_mode].weights)

  if overrides.subsystem contains context.subsystem:
    current = merge_weights(current, overrides.subsystem[context.subsystem].weights)

  if overrides.maturity contains context.maturity:
    current = merge_weights(current, overrides.maturity[context.maturity].weights)

  if overrides.repo contains context.repo:
    current = merge_weights(current, overrides.repo[context.repo].weights)

  validate_all_attributes_present(current)
  validate_weight_range(current, min=1, max=5)

  return { profile_id, weights: current }
```

## 2. Compute Weighted Scores
```text
INPUTS:
  effective_weights_map  # attribute -> 1..5
  subsystem_scores       # subsystem -> attribute -> measured_score (0..5)

FUNCTION weighted_score_for_subsystem(weights, measured):
  numerator = 0
  denominator = 0
  for each attribute in weights:
    w = weights[attribute]
    m = measured.get(attribute, 0)
    numerator += w * m
    denominator += w * 5

  if denominator == 0:
    return 0

  return numerator / denominator  # 0..1

FUNCTION compute_scores(weights, subsystem_scores):
  results = {}
  for each subsystem in subsystem_scores:
    score = weighted_score_for_subsystem(weights, subsystem_scores[subsystem])
    results[subsystem] = score

  system_score = average(results.values)
  return { subsystem_scores: results, system_score: system_score }
```

## 3. Compute Deltas and Top Drivers
```text
INPUTS:
  current_scores
  baseline_scores
  effective_weights

FUNCTION compute_deltas(current, baseline, weights):
  deltas = []
  for each subsystem in current:
    for each attribute in weights:
      now = current[subsystem].attributes.get(attribute, 0)
      prev = baseline[subsystem].attributes.get(attribute, 0)
      delta = now - prev
      impact = weights[attribute] * delta
      deltas.append({
        subsystem: subsystem,
        attribute: attribute,
        delta: delta,
        weight: weights[attribute],
        impact: impact,
        abs_impact: abs(impact)
      })

  sort deltas by abs_impact desc
  top_drivers = first N where abs_impact > 0
  return { deltas, top_drivers }
```

## 4. Gate Evaluation
```text
INPUTS:
  context
  effective_weights
  score_input  # includes criteria/evidence/conflicts
  deltas

FUNCTION check_required_acceptance(score_input, weights, context):
  findings = []
  for each subsystem in score_input:
    for each attribute in weights:
      w = weights[attribute]
      rec = score_input[subsystem][attribute]

      if w >= 5:
        if rec.criteria missing:
          findings.add(HARD_FAIL, "missing criteria", subsystem, attribute)
        if context.run_mode in ["ci", "release", "prod-runtime"] and rec.evidence empty:
          findings.add(HARD_FAIL, "missing evidence", subsystem, attribute)

      if w == 4 and rec.criteria missing:
        if context.run_mode == "local":
          findings.add(SOFT_WARN, "missing criteria", subsystem, attribute)
        else:
          findings.add(SOFT_WARN, "missing criteria", subsystem, attribute)

  return findings

FUNCTION check_regressions(deltas, context):
  findings = []
  for each d in deltas:
    if d.weight >= 5 and d.delta <= -0.5:
      findings.add(context.run_mode == "local" ? SOFT_WARN : HARD_FAIL, "high-weight regression", d)
    else if d.weight >= 4 and d.delta <= -1.0:
      findings.add(context.run_mode == "local" ? SOFT_WARN : HARD_FAIL, "regression", d)
    else if d.weight >= 4 and d.delta <= -0.5:
      findings.add(SOFT_WARN, "warning regression", d)

  return findings

FUNCTION check_5v5_conflicts(score_input, weights, context):
  findings = []
  for each conflict in score_input.conflicts:
    a = conflict.attribute_a
    b = conflict.attribute_b
    if weights[a] == 5 and weights[b] == 5 and conflict.adr_ref missing:
      findings.add(context.run_mode == "local" ? SOFT_WARN : HARD_FAIL, "missing ADR for 5v5 conflict", conflict)

  return findings

FUNCTION evaluate_gate(context, weights, score_input, deltas):
  findings = []
  findings += check_required_acceptance(score_input, weights, context)
  findings += check_regressions(deltas, context)
  findings += check_5v5_conflicts(score_input, weights, context)

  has_hard_fail = any(findings.level == HARD_FAIL)
  has_warn = any(findings.level == SOFT_WARN)

  if has_hard_fail:
    return { status: "FAIL", findings }
  if has_warn:
    return { status: "WARN", findings }
  return { status: "PASS", findings }
```

## 5. Determinism Notes
1. All maps must be iterated in stable sorted-key order.
2. Baseline run selection must be deterministic (`latest successful` by timestamp + same context key).
3. Numeric rounding in score output must be fixed (`round(4)` for percentages).
4. Generated scorecard files must include run metadata hash for reproducibility.

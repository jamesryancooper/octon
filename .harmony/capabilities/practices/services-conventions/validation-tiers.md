---
title: Service Validation Tiers
scope: harness
applies_to: services
---

# Service Validation Tiers

Services use a two-tier validation model: deterministic structural validation (Tier 1) and fixture-calibrated semantic evaluation (Tier 2).

Related docs:

- `.harmony/cognition/_meta/architecture/agent-as-runtime.md`
- `.harmony/cognition/_meta/architecture/agent-runtime-caveats.md`
- `conventions/declarative-rules.md`
- `conventions/fixtures.md`
- `conventions/run-records.md`

## Tier Overview

- Tier 1: deterministic structural validation with no model dependency.
- Tier 2: semantic evaluation interpreted by agent host and calibrated by fixtures.

Tier gating rule:

- Tier 2 MUST NOT run if Tier 1 fails.

## Tier 1 Validator Contract (Deterministic)

Tier 1 validator input contract:

- `repo_root`
- `service_path`
- `contract_version`

Tier 1 validator output contract:

- `status`
- `validator_version`
- `contract_hash`
- `check_results[]`
- `errors[]`

Tier 1 exit codes:

- `0`: pass
- `1`: validation-fail
- `2`: invalid-contract
- `3`: tool-error

Tier 1 constraints:

- No network calls.
- No model calls.
- Deterministic file-order traversal.

## Tier 2 Semantic Evaluation Contract

Tier 2 inputs:

- Tier 1 pass result.
- Rule set.
- Fixture set.
- Compatibility profile.

Tier 2 outputs:

- `status`
- `semantic_results[]`
- `fixture_calibration`
- `violations[]`
- `waiver_required` (boolean)

Tier 2 constraints:

- Must load fixtures before semantic rule interpretation.
- Must fail closed on calibration ambiguity or incompatible host capabilities.

## Execution Policy

Tier 1 execution:

- Required on every PR.
- Required on local pre-commit when configured.

Tier 2 execution:

- Required on protected branches.
- Required on release gates.
- Optional on feature branches and local runs.

Merge/release policy:

- Tier 2 failure blocks merge/release unless explicitly waived with governance evidence.

## Caching

Validation caching SHOULD use content-hash keys.

Tier 1 cache key SHOULD include:

- `contract_hash`
- `validator_version`
- `service_path_hash`

Tier 2 cache key SHOULD include:

- `contract_hash`
- `rule_set_hash`
- `fixture_set_hash`
- `compatibility_profile_hash`
- `agent_host_class`
- `evaluator_version`

Cache invalidation:

- Any relevant content change invalidates cache.
- Cache entries MUST NOT cross contract version boundaries.

## Run Record Integration

Tier outputs MUST be captured in run records aligned to:

- `conventions/run-records.md`

Minimum recorded fields:

- tier identifier
- status
- contract hash/version
- cache hit/miss
- trace correlation ID
- key violations and suggested actions

## Offline Behavior

Offline or model-unavailable mode:

- Tier 1 remains available and required.
- Tier 2 becomes deferred/pending.

Degraded-mode controls:

- Mark semantic status explicitly as pending.
- Block release promotion unless Tier 2 later passes or a waiver is approved.

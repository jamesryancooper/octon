---
title: Profile Taxonomy
description: Canonical disambiguation of profile terms used across governance, runtime policy, workflows, and validators.
status: Active
---

# Profile Taxonomy

Use this page to avoid collisions between similarly named profile concepts.

## Canonical Rule

`profile` terms are not interchangeable. Always choose the profile key for the layer you are operating in.

## Profile Families

| Profile key / field | Allowed values | Scope | Answers this question | Canonical references |
|---|---|---|---|---|
| `change_profile` | `atomic`, `transitional` | Governance change planning and migration doctrine | How should this change be implemented/rolled out? | `AGENTS.md`, `.octon/framework/cognition/practices/methodology/migrations/doctrine.md` |
| `release_state` | `pre-1.0`, `stable` | Governance release-maturity gate | Which semver maturity rules apply to profile selection? | `version.txt`, `.release-please-manifest.json`, `AGENTS.md` |
| `transitional_exception_note` | object: `rationale`, `risks`, `owner`, `target_removal_date` | Governance exception contract | If pre-1.0 uses transitional, what exception evidence justifies it? | `AGENTS.md`, migration doctrine/template/instructions |
| `execution_profile` | `core`, `external-dependent` | Workflow runtime dependency declaration | Does this workflow require external dependencies/project-root I/O? | `.octon/framework/orchestration/runtime/workflows/manifest.yml`, `.octon/framework/orchestration/runtime/workflows/README.md` |
| Domain profile (registry value) | `bounded-surfaces`, `state-tracking`, `human-led`, `artifact-sink` | Top-level harness domain architecture | What structural surface shape must this top-level domain follow? | `.octon/framework/cognition/governance/domain-profiles.yml` |
| `classification` (capability map) | `execution-role-ready`, `role-mediated`, `human-only` | Workflow autonomy classification | What autonomy class is this workflow approved for? | `.octon/framework/orchestration/governance/capability-map-v1.yml` |
| `workflow_mode` (receipt/runtime) | `autonomous`, `role-mediated`, `human-only` | Runtime execution mode | How is this run actually being executed? | `.octon/framework/engine/runtime/spec/policy-receipt-v1.schema.json` |
| Policy profile id (`--profile` for resolver/ACP request context) | `refactor`, `scaffold`, `tests`, `docs`, `release-readiness` | Deny-by-default tool/write/service bundles | What least-privilege grant bundle should apply to this run? | `.octon/framework/capabilities/governance/policy/profiles/*.yml`, `.octon/framework/capabilities/_ops/scripts/policy-profile-resolve.sh` |
| ACP operating mode | `observe`, `iterate`, `operate`, `emergency` | ACP control plane | What ACP ceiling/evidence/escalation path applies? | `.octon/framework/capabilities/governance/policy/deny-by-default.v2.yml#acp.operating_modes` |
| `telemetry_profile` | `minimal`, `sampled`, `full` | Observability contract + ACP telemetry gate | What telemetry level is required/used for promotion evidence? | `.octon/framework/cognition/governance/principles/observability-as-a-contract.md`, `.octon/framework/cognition/governance/controls/ra-acp-promotion-inputs-matrix.md` |
| Validation profile (skills/services/deny-by-default validators) | `strict`, `dev-fast` | Validator runtime behavior | How deep should validation run for this invocation? | `validate-skills.sh`, `validate-services.sh`, `validate-deny-by-default.sh` |
| Alignment-check profile | `commit-pr`, `harness`, `framing`, `intent-layer`, `agency`, `workflows`, `skills`, `services`, `weights`, `all` | Assurance check bundles | Which alignment bundle(s) should run? | `.octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh` |
| Benchmark/perf test profile | `ci`, `standard` | Filesystem-interface performance fixtures/tests | Which benchmark fixture size and test budget should run? | `build-filesystem-interfaces-benchmark-fixture.sh`, `test-filesystem-interfaces-*.sh` |

## Disambiguation Checklist

1. If you are choosing rollout strategy, use `change_profile` and `release_state` (never `execution_profile`).
2. If you are declaring workflow dependency assumptions, use `execution_profile`.
3. If you are selecting least-privilege tool/write bundles, use policy profile ids (`refactor`, `scaffold`, `tests`, `docs`, `release-readiness`).
4. If you are describing autonomy approval posture, use capability `classification` and runtime `workflow_mode`.
5. If you are tuning validator breadth, use validator `--profile` values (`strict` or `dev-fast`) or alignment-check profiles.

## Fast Examples

```bash
# Governance planning receipt
change_profile=atomic
release_state=pre-1.0
```

```yaml
# Workflow manifest dependency declaration
execution_profile: external-dependent
```

```bash
# Deny-by-default policy bundle resolution
bash .octon/framework/capabilities/_ops/scripts/policy-profile-resolve.sh refactor
```

```bash
# Assurance alignment bundles
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,workflows
```

## Non-Goals

- This document does not redefine profile semantics; it only maps canonical sources.
- This document does not replace policy or schema SSOTs.

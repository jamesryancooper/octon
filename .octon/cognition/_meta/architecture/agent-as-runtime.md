---
title: Agent-as-Runtime Model
description: Portable harness architecture where declarative contracts are interpreted by host agents using deterministic structural validation and governed semantic evaluation.
---

# Agent-as-Runtime Model

Related docs: [agent architecture](./agent-architecture.md), [runtime architecture](./runtime-architecture.md), [runtime policy](./runtime-policy.md), [governance model](./governance-model.md), [agent runtime caveats](./agent-runtime-caveats.md)

## Purpose and Scope

This document defines the architecture for running the Octon harness (`.octon/`) as pure declarative content interpreted by an AI agent. The goal is portability across repositories, stacks, and environments without shipping project-local executables or runtime binaries in the harness itself.

This model applies to:

- Harness interpretation and governance checks.
- Service contract evaluation and fixture-calibrated rule interpretation.
- Optional generation of native deterministic implementations from declarative contracts.

This model does not replace product/application runtime architecture. Product runtime concerns remain governed by [runtime architecture](./runtime-architecture.md) and [runtime policy](./runtime-policy.md).

## Decision Statement

Octon adopts an agent-as-runtime architecture for harness interpretation:

- The harness ships as content: manifests, schemas, rules, fixtures, and conventions.
- The host agent interprets that content and performs validation/evaluation.
- Deterministic structural checks remain available without agent/model access.
- Semantic checks, policy interpretation, and richer reasoning run through the host agent.

## Goals and Non-Goals

### Goals

- Maximize portability of harness assets across repositories.
- Keep source-of-truth logic in declarative contracts, not ad hoc scripts.
- Preserve deterministic quality gates where determinism is mandatory.
- Support multiple agent hosts through a lowest-common-denominator tool surface.
- Maintain auditability, provenance, and reproducibility of validation/evaluation runs.

### Non-Goals

- Eliminating host prerequisites entirely (an agent host is still required).
- Replacing application runtime services or deployment runtimes.
- Guaranteeing byte-identical outputs across all agent vendors/models.

## Dependency Boundary

The model distinguishes project-local dependencies from host-provided prerequisites.

### In Scope (Must Ship in the Repo)

- Declarative contracts (YAML/JSON Schema/Markdown).
- Rule definitions and fixture sets.
- Conventions defining validation semantics and evidence requirements.
- Templates and metadata needed to reproduce contract interpretation.

### Out of Scope (Host-Provided Prerequisites)

- Agent runtime and model access.
- Tool adapter implementing `read`, `glob`, `grep`, and `bash`.
- Environment-level execution substrate used by the host agent.

Normative rule:

- Harness portability means no project-local runtime dependency, not zero host prerequisites.

## What Ships: Content Standard

The harness runtime surface is content-first and contract-first.

Required content families:

- Discovery and registry metadata.
- Contract schemas and rule definitions.
- Fixture packs for behavior anchoring and acceptance.
- Conventions for run records, error semantics, observability, and idempotency.
- Templates that encode source-of-truth structure for services.

Explicit exclusions for the portable harness surface:

- Required compiled binaries.
- Required per-platform runtime bundles.
- Required shell-specific operational scripts for semantic enforcement.

Optional helper scripts are allowed only when they are non-authoritative convenience tooling and do not become required for semantic correctness.

## Interpretation Loop

The harness interpretation lifecycle is standardized as:

1. Discover contract and compatibility profile.
2. Run Tier 1 deterministic structural validation.
3. Load fixtures and calibrate semantic expectations.
4. Interpret declarative rules against current repository state.
5. Emit structured outcomes and run record evidence.
6. Apply governance decision (pass, fail, waive-with-accountability).

Key properties:

- Tier 1 never depends on model access.
- Tier 2 is fixture-calibrated and policy-governed.
- Every non-trivial evaluation produces traceable evidence.

## Contract Anatomy

A rich contract must be complete enough for both:

- Semantic interpretation by an agent.
- Optional deterministic implementation generation.

Minimum components:

- `schema`: declarative structure and type constraints.
- `rules`: structural/semantic/policy rule set.
- `fixtures`: positive, negative, and edge-case examples.
- `invariants`: behavioral guarantees that must hold.
- `error_semantics`: stable failure categories and expected operator action.
- `compatibility_profile`: required and optional capability declarations.

Illustrative shape:

```yaml
contract:
  id: example-service
  version: "1.0.0"
  schema: contracts/example.schema.json
  rules: rules/
  fixtures: fixtures/
  invariants: contracts/invariants.md
  error_semantics: contracts/errors.yml
  compatibility_profile: compatibility.yml
```

Normative rules:

- Contract is the source of truth.
- Implementations are derived artifacts.
- Contract versioning is mandatory for any semantic-breaking change.

## Validation Tiers

Octon uses a two-tier validation model.

### Tier 1 (Deterministic Structural Validation)

Tier 1 validates structure and contract integrity without agent/model calls.

Required validator contract:

- Inputs: `repo_root`, `service_path`, `contract_version`
- Outputs: `status`, `validator_version`, `contract_hash`, `check_results[]`, `errors[]`
- Exit codes:
  - `0` pass
  - `1` validation-fail
  - `2` invalid-contract
  - `3` tool-error
- Constraints:
  - No network access
  - No model calls
  - Deterministic file-order traversal

Execution policy:

- Must run on every PR.
- Should run locally pre-commit when possible.

### Tier 2 (Semantic Evaluation)

Tier 2 interprets declarative rules with fixture calibration using an agent host.

Execution policy:

- Required on protected branches and release gates.
- Optional on feature branches and local runs.
- Can degrade gracefully when model access is unavailable.

Tier interaction:

- Tier 1 failure blocks Tier 2.
- Tier 2 failure blocks merge/release unless explicitly waived.

## Compatibility Profile and Conformance

To support multiple host agents, contracts declare a compatibility profile.

Minimum required capability surface:

- `read`
- `glob`
- `grep`
- `bash`

Optional capabilities can be declared for richer behavior, but required checks must remain satisfiable by the minimum surface unless explicitly marked host-specific.

Illustrative profile:

```yaml
compatibility:
  required_tools: [read, glob, grep, bash]
  optional_tools: [mcp, structured_diff]
  minimum_behavior:
    deterministic_tier1: true
    fixture_execution: true
```

Conformance requirement:

- Each service includes a conformance fixture pack that verifies expected behavior against the declared compatibility profile.

## Implementation Generation (Derived, Not Authoritative)

When deterministic native execution is needed, teams may generate implementations from contracts.

Workflow:

1. Validate contract completeness.
2. Generate implementation candidate.
3. Execute fixture suite against generated implementation.
4. Iterate until all mandatory fixtures pass.
5. Accept and version generated output with provenance metadata.

Generation acceptance rules:

- Passing fixtures are required but not sufficient; governance and policy checks still apply.
- Generated code must not become a shadow source of truth.

Required generation provenance manifest (`impl/generated.manifest.json`):

- `contract_version`
- `contract_hash`
- `fixture_set_hash`
- `rule_set_hash`
- `agent_id`
- `agent_version`
- `model_id`
- `prompt_hash`
- `tool_surface_version`
- `generated_at` (UTC)

## Evidence, Auditability, and Reproducibility

All semantic runs should emit run records aligned with the harness run-record conventions in:

- `.octon/capabilities/practices/services-conventions/run-records.md`

Minimum evidence expectations:

- Inputs and contract version/hash.
- Outcome status and error semantics.
- Determinism metadata (prompt hash, model metadata where applicable).
- Trace correlation identifiers.

Reproducibility is scoped:

- Structural reproducibility is deterministic via Tier 1.
- Semantic reproducibility is bounded via fixture calibration, versioned rules, and captured model/runtime metadata.

## Relationship to Platform Runtime

This architecture concerns harness interpretation. It is separate from product runtime services.

| Aspect | Harness Runtime (Agent-as-Runtime) | Product Runtime (Platform Runtime) |
|---|---|---|
| Primary responsibility | Interpret contracts/rules/fixtures for governance | Execute application/platform flows in runtime plane |
| Artifact form | Declarative content in repo | Deployable runtime services |
| Determinism strategy | Deterministic Tier 1 + calibrated Tier 2 | Runtime policy, contracts, observability, rollback |
| Failure handling | Validation/evaluation fail-closed + waivers | SLO-based operational controls and incident response |
| Source of truth | Contracts and conventions | Runtime service contracts and operational policy |

See [runtime architecture](./runtime-architecture.md) and [runtime policy](./runtime-policy.md) for runtime-plane behavior.

## Governance Integration

The model integrates with governance as follows:

- Tier 1 is a mandatory deterministic gate.
- Tier 2 is a semantic gate with risk-tiered enforcement.
- Waivers must be explicit, time-bounded, and auditable.
- Run evidence is required for consequential decisions.

This aligns with [governance model](./governance-model.md) and Octon principles on determinism, guardrails, and ACP gates.

## Adoption Guidance

Recommended rollout sequence:

1. Encode existing service behavior as explicit contracts and fixtures.
2. Enforce Tier 1 deterministically for all services.
3. Introduce Tier 2 semantic checks on protected branches.
4. Add compatibility profiles and conformance fixtures.
5. Enable implementation generation for services needing deterministic executables.

## Summary

The agent-as-runtime model makes harness logic portable by moving authority to declarative contracts while preserving deterministic structural checks and governed semantic evaluation. It keeps portability practical, not absolute: no project-local runtime dependency, clear host prerequisites, and auditable evidence for every meaningful decision.

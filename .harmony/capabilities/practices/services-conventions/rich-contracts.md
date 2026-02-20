---
title: Service Rich Contracts
scope: harness
applies_to: services
---

# Service Rich Contracts

Rich contracts are the minimum declarative surface required for reliable agent interpretation and optional native implementation generation.

Related docs:

- `.harmony/cognition/_meta/architecture/agent-as-runtime.md`
- `.harmony/cognition/_meta/architecture/agent-runtime-caveats.md`
- `conventions/declarative-rules.md`
- `conventions/fixtures.md`
- `conventions/implementation-generation.md`

## Purpose

A contract is "rich" when it fully specifies structure, behavior, failure semantics, and compatibility constraints without depending on implementation-specific source code.

Rich contracts support two outcomes:

- Deterministic structural validation (Tier 1).
- Fixture-calibrated semantic evaluation (Tier 2).

## Contract Completeness Criteria

A service contract MUST include:

1. `schema`
2. `rules`
3. `fixtures`
4. `invariants`
5. `error_semantics`
6. `compatibility_profile`

Illustrative shape:

```yaml
contract:
  id: guard
  version: "1.2.0"
  schema:
    input: schema/input.schema.json
    output: schema/output.schema.json
  rules: rules/
  fixtures: fixtures/
  invariants: contracts/invariants.md
  error_semantics: contracts/errors.yml
  compatibility_profile: compatibility.yml
```

## Required and Optional Components

Required components:

- `schema`: JSON Schema for input and output contracts.
- `rules`: declarative structural/semantic/policy rules.
- `fixtures`: positive, negative, and edge cases.
- `invariants`: behavioral guarantees that rules and fixtures enforce.
- `error_semantics`: stable failure categories and operator actions.
- `compatibility_profile`: required tool surface and optional capability declarations.

Optional components:

- `examples`: human-oriented usage examples.
- `non_functional`: latency, cost, and throughput guidance.
- `implementation_hints`: generation hints that do not override contract truth.

Optional components MUST NOT redefine or conflict with required contract behavior.

## Versioning

Contract versions MUST use semver and be updated as follows:

- Major: breaking change to schema, rules, fixture expectations, or error semantics.
- Minor: backward-compatible behavior expansion.
- Patch: clarifications or non-behavioral fixes.

Breaking changes require:

- Contract version bump.
- Updated fixtures proving changed behavior.
- Updated run evidence for impacted services.

## Compatibility Profile

Every rich contract MUST declare a compatibility profile.

Minimum required tool surface:

- `read`
- `glob`
- `grep`
- `bash`

Any required capability beyond this surface MUST be explicitly declared and justified.

Illustrative profile:

```yaml
compatibility:
  required_tools: [read, glob, grep, bash]
  optional_tools: [mcp, structured_diff]
  minimum_behavior:
    deterministic_tier1: true
    fixture_calibration: true
```

## Relationship to Implementation

Source of truth rule:

- Contract is authoritative.
- Implementations are derived and replaceable.

Normative constraints:

- Generated or handwritten implementation code MUST conform to contract + fixtures.
- Implementation details MUST NOT weaken contract guarantees.
- Contract and implementation drift is a policy failure until reconciled.

## Quality Gate for Richness

A contract is accepted as rich only if:

1. All required components exist and are parseable.
2. Schemas validate the declared fixture inputs/outputs.
3. Rules reference real targets and valid severities/actions.
4. Fixtures cover positive, negative, and edge behavior.
5. Compatibility profile is present and internally consistent.

If any condition fails, the contract is incomplete and cannot pass semantic governance.

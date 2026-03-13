---
title: Service Implementation Generation
scope: harness
applies_to: services
---

# Service Implementation Generation

Native implementations can be generated from rich contracts when deterministic runtime behavior is needed. Contracts remain authoritative.

Related docs:

- `.octon/cognition/_meta/architecture/agent-as-runtime.md`
- `.octon/cognition/_meta/architecture/agent-runtime-caveats.md`
- `conventions/rich-contracts.md`
- `conventions/fixtures.md`
- `conventions/validation-tiers.md`

## Source of Truth Invariant

The service contract is the source of truth.

Normative rules:

- Generated implementation is derived artifact.
- Generated implementation MUST conform to contract + fixtures.
- Generated implementation MUST NOT redefine contract semantics.

## Generation Workflow (Five Steps)

1. Completeness check

- Confirm rich contract components are present and valid.
- Require Tier 1 pass before generation.

2. Generate candidate

- Produce native implementation under `impl/`.
- Apply deterministic templates or generation strategy where available.

3. Fixture validation

- Run fixture suite against generated implementation.
- Treat any mandatory fixture failure as generation failure.

4. Iterate

- Update generation inputs/templates and regenerate until fixtures pass.

5. Accept

- Record provenance metadata.
- Commit generated output with contract/version alignment.

## Regeneration Triggers

Regeneration is required when any of the following changes:

- Input or output schema.
- Declarative rules.
- Fixture set.
- Behavioral invariants.
- Compatibility profile requirements affecting implementation behavior.

## Placement and Markers

Generated artifacts MUST live in:

- `impl/` directory.

Recommended marker at top of generated files:

```text
Generated from service contract. Do not edit manually unless regeneration workflow documents an exception.
```

If manual edits are required, they MUST be explicitly documented with rationale and reconciliation plan.

## Required Provenance Manifest

Every accepted generated implementation MUST include:

- `impl/generated.manifest.json`

Required fields:

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

Illustrative manifest:

```json
{
  "contract_version": "1.2.0",
  "contract_hash": "sha256:...",
  "fixture_set_hash": "sha256:...",
  "rule_set_hash": "sha256:...",
  "agent_id": "architect",
  "agent_version": "2026-02-12",
  "model_id": "example-model",
  "prompt_hash": "sha256:...",
  "tool_surface_version": "1",
  "generated_at": "2026-02-12T10:30:00Z"
}
```

## Acceptance Criteria

Generated implementation can be accepted only when:

1. Tier 1 passes.
2. Mandatory fixtures pass.
3. Provenance manifest is complete.
4. Governance/policy checks pass (or are explicitly waived).

Any missing provenance field or fixture mismatch is a block condition.

## Drift Control

Drift signals:

- Contract changed but implementation was not regenerated.
- Implementation changed without corresponding contract/version update.
- Fixture expectations no longer match implementation behavior.

Drift handling:

- Treat as contract-governance failure.
- Regenerate or reconcile contract/fixtures immediately.

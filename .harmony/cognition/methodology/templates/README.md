---
title: Spec Templates
description: Risk-tiered spec templates for AI agents to use when generating specifications for changes.
---

# Spec Templates

This directory contains spec templates for each risk tier. AI agents should select the appropriate template based on the auto-tier-assignment algorithm.

## Template Selection

| Tier | Template | When to Use |
|------|----------|-------------|
| T1 | `spec-tier1.yaml` | Trivial changes: typos, docs, tiny fixes |
| T2 | `spec-tier2.yaml` | Standard changes: features, endpoints, refactoring |
| T3 | `spec-tier3.yaml` | Elevated risk: auth, billing, data, security |

## Usage

### 1. Determine Tier

Use the [auto-tier-assignment](../auto-tier-assignment.md) algorithm to classify the change.

### 2. Load Template

```typescript
import { loadSpecTemplate } from '@harmony/speckit';

const tier = await classifyChange(intent, files);
const template = await loadSpecTemplate(`spec-tier${tier}.yaml`);
```

### 3. Fill Template

AI agents should fill ALL required fields in the template. Optional fields should be included when relevant.

### 4. Validate

```typescript
import { validateSpec } from '@harmony/speckit';

const validation = await validateSpec(spec, tier);
if (!validation.valid) {
  // Handle validation errors
}
```

## Template Structure

### Common Fields (All Tiers)

- `tier`: Risk tier (1, 2, or 3)
- `title`: Descriptive title
- `scope`: Files and surfaces affected
- `_metadata`: AI generation metadata
- `_review`: Human review tracking

### Tier-Specific Fields

| Field | T1 | T2 | T3 |
|-------|-----|-----|-----|
| `intent` | ✅ | - | - |
| `problem/solution` | - | ✅ | ✅ |
| `contracts` | - | ✅ | ✅ |
| `threat_analysis` | - | Lite | Full |
| `data_classification` | - | - | ✅ |
| `migration` | - | - | ✅ |
| `rollout` | - | ✅ | ✅ |
| `observability` | - | ✅ | ✅ |
| `approval_checkpoints` | - | - | ✅ |
| `adr` | - | - | ✅ |

## Validation Rules

### T1 Validation

- `tier` must be `1`
- `scope.surfaces` must be empty
- `scope.lines_changed_estimate` must be < 50
- `risk_assessment.security_impact` must be `none`
- `risk_assessment.data_impact` must be `none`

### T2 Validation

- `tier` must be `2`
- `threat_analysis.stride_lite` must be present
- `rollout.flag.name` must be provided
- `testing.e2e_smoke.required` must be `true`

### T3 Validation

- `tier` must be `3`
- `navigator` must be specified
- `threat_model.stride` must have all categories
- `approval_checkpoints` must be present
- `adr.required` must be `true`
- Spec must be approved before build proceeds

## Human Review Requirements

| Tier | Review Type | Time Budget |
|------|-------------|-------------|
| T1 | Skim summary | 2-3 min |
| T2 | Review summary + PR | 15-20 min |
| T3 | Full spec review (staged) | 30-60 min |

## Related Documentation

- [Risk Tiers Overview](../risk-tiers.md)
- [Auto-Tier Assignment](../auto-tier-assignment.md)
- [Spec-First Planning](../spec-first-planning.md)
- [Human-Facing Risk Tiers](../../RISK-TIERS.md)

---
title: Spec Templates
description: Risk-tiered spec templates for AI agents to use when generating specifications for changes.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.harmony/agency/governance/CONSTITUTION.md"
  - "/.harmony/agency/governance/DELEGATION.md"
  - "/.harmony/agency/governance/MEMORY.md"
  - "/.harmony/cognition/practices/methodology/authority-crosswalk.md"
---

# Spec Templates

This directory contains spec templates for each risk tier. AI agents should select the appropriate template based on the auto-tier-assignment algorithm.

## Machine Discovery

- `index.yml` - canonical machine-readable spec template index.

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
// Illustrative pseudocode (adapt to your runtime and package layout)
import { loadSpecTemplate } from '@harmony/speckit';

const tier = await classifyChange(intent, files);
const template = await loadSpecTemplate(`spec-tier${tier}.yaml`);
```

### 3. Fill Template

AI agents should fill ALL required fields in the template. Optional fields should be included when relevant.

### 4. Validate

```typescript
// Illustrative pseudocode (adapt to your runtime and package layout)
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
- `governance.profile_selection.*`: required profile governance fields (`change_profile`, `release_state`, fact set, receipt reference, conditional `transitional_exception_note`)
- `governance.acp.*`: required ACP target/outcome and receipt reference
- `scope`: Files and surfaces affected
- `_metadata`: AI generation metadata
- review tracking surface: `_review` for T1/T2 and `oversight_touchpoints` for T3

### Tier-Specific Fields

| Field | T1 | T2 | T3 |
|-------|-----|-----|-----|
| `intent` | ✅ | - | - |
| `problem/solution` | - | ✅ | ✅ |
| `convivial_impact` | - | ✅ | ✅ |
| `contracts` | - | ✅ | ✅ |
| `threat_analysis` | - | Lite | - |
| `threat_model` | - | - | Full |
| `data_classification` | - | - | ✅ |
| `migration` | - | - | ✅ |
| `rollout` | - | ✅ | ✅ |
| `observability` | - | ✅ | ✅ |
| `_review` | ✅ | ✅ | - |
| `oversight_touchpoints` | - | - | ✅ |
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
- `convivial_impact.capability_expansion` must be present
- `convivial_impact.attention_class` must be present
- `convivial_impact.extraction_risk` must be present
- `threat_analysis.stride_lite` must be present
- `rollout.flag.name` must be provided
- `testing.e2e_smoke.required` must be `true`

### T3 Validation

- `tier` must be `3`
- `navigator` must be specified
- `convivial_impact.capability_expansion` must be present
- `convivial_impact.attention_class` must be present
- `convivial_impact.extraction_risk` must be present
- `threat_model.stride` must have all categories
- `oversight_touchpoints` must be present
- `oversight_touchpoints.spec_review.required` must be `true`
- `oversight_touchpoints.pr_review.required` must be `true`
- `oversight_touchpoints.promotion_readiness_review.required` must be `true`
- `_metadata.human_review_required_before_build` must be `true`
- `adr.required` must be `true`
- Promotion/readiness decisions flow through ACP evidence + quorum

## Human Review Requirements

| Tier | Review Type | Time Budget |
|------|-------------|-------------|
| T1 | Skim summary | 2-3 min |
| T2 | Review summary + PR | 15-20 min |
| T3 | Full staged review (spec + PR + promotion readiness) | 30-60 min |

## Related Documentation

- [Risk Tiers Overview](../risk-tiers.md)
- [Auto-Tier Assignment](../auto-tier-assignment.md)
- [Spec-First Planning](../spec-first-planning.md)
- [Human-Facing Risk Tiers](../../../runtime/context/risk-tiers.md)

---
title: Risk Tier Classification System
description: Comprehensive AI-facing documentation for Harmony's three-tier risk classification system, including criteria, gates, responsibilities, and automation logic.
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

# Risk Tier Classification System

This document provides the complete specification for Harmony's risk tier system. It is designed for AI agents to use when classifying changes, generating specs, and applying appropriate rigor.

For the human-facing summary, see [../../runtime/context/risk-tiers.md](../../runtime/context/risk-tiers.md).

---

## Overview

Every change in Harmony is classified into one of three risk tiers:

| Tier | Name | Human Time | AI Rigor | Governance Flow |
|------|------|------------|----------|-----------------|
| **T1** | Trivial | 2-3 min | Standard gates | Stage -> evidence -> ACP-1 gate -> promote/stage-only -> receipt |
| **T2** | Standard | 15-20 min | Standard + threat analysis + preview | Stage -> evidence -> ACP-2 gate (+ quorum) -> promote/stage-only -> receipt |
| **T3** | Elevated | 30-60 min | Full analysis + staged safety checks | Stage -> evidence -> ACP-3 gate (+ quorum) -> promote/stage-only -> receipt |

**Key Principle:** Agents apply appropriate rigor at every tier under system-governed ACP controls. The difference is ACP strength (evidence, quorum, budgets, reversibility), while humans retain policy authorship, exceptions handling, and escalation authority.

Governance references: [Autonomous Control Points](../../governance/principles/autonomous-control-points.md), [Deny by Default](../../governance/principles/deny-by-default.md), [Arbitration & Precedence](../../governance/principles/README.md#arbitration--precedence).

---

## Risk Tier and Profile Governance Crosswalk

Risk tier and change profile are complementary and both are mandatory for governance-impacting work:

- Tier (`T1/T2/T3`) controls evidence depth, CI strictness, and ACP gate strength.
- Profile (`atomic/transitional`) controls rollout/migration shape and release-state rules.

Before implementation, plans must include:

1. `change_profile`
2. `release_state`
3. `Profile Selection Receipt`

For pre-1.0 `transitional` selection, include `transitional_exception_note` with `rationale`, `risks`, `owner`, and `target_removal_date`.

Promotion authority sentence:

`ACP receipt outcomes determine runtime promotion authority; humans retain policy authorship, exceptions, and escalation authority.`

---

## Pillar Alignment by Tier

The risk tier system operationalizes Harmony's [Six Pillars](../../governance/pillars/README.md), with each tier emphasizing different pillars based on the nature and risk of the change.

| Tier | Primary Pillars | Rationale |
|------|-----------------|-----------|
| **T1** | [Velocity](../../governance/pillars/velocity.md) | Fast delivery with basic gates. Trivial changes benefit from speed; minimal ceremony serves throughput. |
| **T2** | [Direction](../../governance/pillars/direction.md), [Velocity](../../governance/pillars/velocity.md), [Trust](../../governance/pillars/trust.md) | Validated spec ensures we build the right thing. Threat analysis and feature flags balance speed with safety. |
| **T3** | [Direction](../../governance/pillars/direction.md), [Trust](../../governance/pillars/trust.md), [Continuity](../../governance/pillars/continuity.md) | Full spec validation, security review, and ADRs. Elevated risk demands governed determinism and institutional memory. |

### How Each Pillar Manifests Across Tiers

| Pillar | T1 | T2 | T3 |
|--------|-----|-----|-----|
| **Direction** | Intent identified | Validated spec with scope | Full spec with alternatives |
| **Focus** | Minimal process overhead | AI absorbs complexity | AI handles full analysis |
| **Velocity** | Fast path: 2-3 min | Balanced: 15-20 min | Thorough: 30-60 min |
| **Trust** | Basic gates | Threat-lite + flags | Full STRIDE + security review |
| **Continuity** | — | Observability required | ADRs + traces required |
| **Insight** | — | — | Postmortem potential |

The tier system ensures that the pillar emphasis scales with risk: T1 optimizes for Velocity, T2 balances Velocity with Trust and Direction, and T3 prioritizes Trust, Direction, and Continuity.

---

## Tier 1: Trivial Changes

### Classification Criteria

A change qualifies as T1 if ALL of the following are true:

```yaml
tier1_criteria:
  scope:
    max_lines_changed: 49      # < 50 (exclusive); 50+ triggers T2
    max_files_changed: 4       # < 5 (exclusive); 5+ triggers T2
    
  surfaces_touched:
    allowed:
      - documentation
      - comments
      - tests (non-security)
      - styling (CSS/SCSS)
      - configuration (non-security)
      - logging (non-sensitive)
    forbidden:
      - authentication
      - authorization
      - billing
      - payments
      - user_data
      - pii
      - secrets
      - security_headers
      - database_schema
      - api_mutations
      
  patterns:
    allowed:
      - typo_fix
      - documentation_update
      - log_statement_add
      - comment_update
      - dependency_patch_bump
      - test_addition
      - a11y_improvement
    forbidden:
      - business_logic_change
      - api_contract_change
      - data_model_change
      - auth_flow_change
```

### File Path Signals

```yaml
tier1_paths:
  strong_indicators:  # These suggest T1 if only these changed
    - "*.md"
    - "docs/**"
    - "**/*.test.ts"
    - "**/*.spec.ts"
    - "**/*.css"
    - "**/*.scss"
    - "**/README*"
    - "CHANGELOG*"
    - ".gitignore"
    
  weak_indicators:  # Need additional analysis
    - "**/*.json"  # Could be config or data
    - "**/*.yaml"  # Could be config or CI
```

### T1 Spec Template

Use the canonical T1 template in [templates/spec-tier1.yaml](./templates/spec-tier1.yaml).

Required focus for T1 specs:
- concise intent and bounded file scope
- explicit trivial risk posture (`security_impact: none`, `data_impact: none`)
- verification posture and rollback handle

### T1 Gates (AI Enforces)

| Gate | Required | Notes |
|------|----------|-------|
| Lint & format | ✅ | ESLint, Prettier |
| Type check | ✅ | `tsc --noEmit` |
| Unit tests | ✅ | Existing must pass |
| Secret scan | ✅ | CI secret scanning |
| Dependency scan | ✅ | Dependabot alerts |
| SBOM generation | ✅ | Syft |
| Preview deploy | ❌ | Optional |
| E2E smoke | ❌ | Not required |
| Threat analysis | ❌ | Skip for T1 |
| Feature flag | ❌ | Optional |

### T1 Human Touchpoints

1. **Review AI summary** (30 seconds)
   - Verify change matches intent
   - Check no unexpected files
   
2. **Verify CI green** (10 seconds)
   - All gates pass

3. **On-the-loop check** (required when escalation thresholds are crossed)
   - Verify run receipts and ACP outcome
   - Confirm no unresolved escalation before promotion

**Total: 2-3 minutes**

### T1 AI Summary Format

```markdown
## T1 Summary: <Title>

**What**: <1 sentence describing the change>
**Risk**: None (no logic/security impact)
**Tests**: <Existing tests pass | N new tests added>
**Files**: <N files, M lines changed>

**Action needed**: Verify ACP/CI outcome and evidence bundle
```

---

## Tier 2: Standard Changes

### Classification Criteria

A change qualifies as T2 if:
- It does NOT meet T3 criteria (below), AND
- Any of the following are true:

```yaml
tier2_criteria:
  scope:
    lines_changed: 50-300
    files_changed: 5-20
    
  surfaces_touched:
    triggers_t2:
      - new_api_endpoint
      - new_ui_component
      - business_logic_change
      - refactoring
      - query_optimization
      - new_feature (non-sensitive)
      - integration (non-sensitive)
      
  patterns:
    triggers_t2:
      - add_endpoint
      - add_component
      - add_service
      - refactor_module
      - add_feature
      - performance_optimization
```

### File Path Signals

```yaml
tier2_paths:
  triggers:
    - "apps/*/src/**"  # App code changes
    - "packages/*/src/**"  # Package code changes
    - "**/*.tsx"  # UI components
    - "**/api/**"  # API routes (if not auth)
    - "**/services/**"  # Services (if not auth/billing)
    
  requires_analysis:  # Might be T2 or T3
    - "**/models/**"
    - "**/adapters/**"
    - "**/domain/**"
```

### T2 Spec Template

Use the canonical T2 template in [templates/spec-tier2.yaml](./templates/spec-tier2.yaml).

Required focus for T2 specs:
- problem/solution, scope, and impacted surfaces
- STRIDE-lite threat analysis and test/rollout/observability contracts
- governance/ACP receipt fields and conditional governance-impacting section refs when applicable

### T2 Gates (AI Enforces)

| Gate | Required | Notes |
|------|----------|-------|
| Lint & format | ✅ | ESLint, Prettier |
| Type check | ✅ | `tsc --noEmit` |
| Unit tests | ✅ | New + existing |
| Contract tests | ✅ | If API changes |
| OpenAPI diff | ✅ | oasdiff |
| Secret scan | ✅ | CI secret scanning |
| Dependency scan | ✅ | Dependabot |
| CodeQL | ✅ | Security analysis |
| Semgrep | ✅ | Security patterns |
| SBOM generation | ✅ | Syft |
| Preview deploy | ✅ | Required |
| E2E smoke | ✅ | Core flows |
| STRIDE-lite | ✅ | Automated analysis |
| Feature flag | ✅ | Required |
| Observability check | ✅ | Spans/logs present |

### T2 Human Touchpoints

1. **Review spec summary** (2-5 minutes)
   - Does it capture the intent?
   - Any scope concerns?
   - Threat summary reasonable?
   
2. **Scan PR changes** (5-10 minutes)
   - Implementation matches spec?
   - Code quality acceptable?
   - Tests cover key paths?
   
3. **Check preview** (required for elevated-impact or uncertain T2 changes, 2-3 minutes)
   - Feature works as expected?
   
4. **Approve PR** (click)

**Total: 15-20 minutes**

### T2 AI Summary Format

```markdown
## T2 Summary: <Title>

**What**: <2-3 sentence description>
**Spec summary**: <Core behavior and constraints>

**Threat check**: 
- <STRIDE category>: ✅ <mitigation> or ⚠️ <concern>
- ...

**Tests**: <N unit, N contract, preview smoke passing>
**Flag**: `<flag.name>` (default OFF)
**Rollback**: <method>

**Action needed**: Review spec summary, approve PR

[View full spec →] [View threat analysis →]
```

---

## Tier 3: Elevated Changes

### Classification Criteria

A change qualifies as T3 if ANY of the following are true:

```yaml
tier3_criteria:
  surfaces_touched:
    any_triggers_t3:
      - authentication
      - authorization
      - access_control
      - session_management
      - billing
      - payment_processing
      - pii_handling
      - phi_handling
      - secrets_management
      - security_headers
      - csp_cors
      - database_migrations
      - user_data_export
      - user_data_deletion
      - third_party_oauth
      - third_party_data_sharing
      - encryption
      - signing
      
  patterns:
    any_triggers_t3:
      - auth_flow
      - payment_integration
      - data_migration
      - schema_migration
      - rbac_change
      - security_config
      - compliance_feature
      - gdpr_feature
```

### File Path Signals

```yaml
tier3_paths:
  auto_triggers:  # Always T3
    - "**/auth/**"
    - "**/authentication/**"
    - "**/authorization/**"
    - "**/billing/**"
    - "**/payment/**"
    - "**/security/**"
    - "**/migrations/**"
    - "**/rbac/**"
    - "**/access-control/**"
    - "**/*session*"
    - "**/*oauth*"
    - "**/*csp*"
    - "**/*cors*"
    
  requires_analysis:  # Analyze content
    - "**/middleware/**"  # Could be auth middleware
    - "**/hooks/**"  # Could be auth hooks
    - "**/config/**"  # Could be security config
```

### T3 Spec Template

Use the canonical T3 template in [templates/spec-tier3.yaml](./templates/spec-tier3.yaml).

Required focus for T3 specs:
- full problem/solution framing with alternatives and sensitive-surface scope
- data classification, full STRIDE model, security tests, migration/rollout/rollback design
- oversight touchpoints, ADR linkage, and conditional governance-impacting section refs when applicable

### T3 Gates (AI Enforces)

| Gate | Required | Notes |
|------|----------|-------|
| Lint & format | ✅ | ESLint, Prettier |
| Type check | ✅ | `tsc --noEmit` |
| Unit tests | ✅ | Including security tests |
| Contract tests | ✅ | Required |
| Integration tests | ✅ | If applicable |
| OpenAPI diff | ✅ | Breaking change review |
| Secret scan | ✅ | CI secret scanning |
| Dependency scan | ✅ | Dependabot + license |
| CodeQL | ✅ | Full analysis |
| Semgrep | ✅ | Security patterns |
| SBOM generation | ✅ | Syft |
| Provenance attestation | ✅ | For releases |
| Preview deploy | ✅ | Required |
| E2E smoke | ✅ | Extended flows |
| Full STRIDE | ✅ | Human-reviewed |
| Feature flag | ✅ | Required |
| Observability check | ✅ | Full coverage |
| Golden tests | ✅ | Critical paths |
| Verifier/recovery attestations | ✅ | Independent attestation quorum (agent/service roles) |
| Security evidence review | ✅ | STRIDE + control evidence attached to ACP artifacts |

### T3 Oversight Touchpoints (Human-on-the-Loop)

**Stage 1: Stage + Evidence**

1. **AI stages and assembles evidence** (plan, diff, tests, rollback proof).
2. **Verifier + recovery attestations are collected** for ACP-3 quorum.
3. **ACP gate evaluates promotion** and returns `ALLOW` or `STAGE_ONLY`.

**Stage 2: Promote or Stage-Only**

1. **Promote only on ACP `ALLOW`**.
2. **On missing quorum/disagreement**, remain stage-only and emit escalation artifact.

**Stage 3: Required Oversight + Watch**

1. **Review receipt/digest** (required for T3).
2. **Monitor watch window** and execute rollback if circuit breakers trip.

**Total on-loop time: 30-60 minutes** (primarily post-gate oversight).

### T3 AI Summary Format

```markdown
## T3 Summary: <Title>

**What**: <Detailed description>
**Classification**: Elevated risk - <reason>

### Spec Summary
<3-5 sentence summary of the spec>

### Threat Model Summary
| Category | Status | Key Mitigation |
|----------|--------|----------------|
| Spoofing | ✅ Mitigated | <mitigation> |
| Tampering | ✅ Mitigated | <mitigation> |
| ... | ... | ... |

**Residual risks**: <any accepted risks>

### Testing Coverage
- Unit: <N> tests (<coverage>%)
- Contract: <N> tests
- Security: <N> tests
- Golden: <N> critical paths
- E2E: <N> flows

### Rollout Plan
1. Internal (100%) - <duration>
2. Canary (5%) - <duration>
3. General (100%)

**Flag**: `<flag.name>` (default OFF)
**Rollback**: <immediate + full method>
**Watch window**: 30 minutes

### ACP gates
- [ ] Spec evidence assembled (plan/diff/tests/rollback)
- [ ] Verifier/recovery quorum evidence captured
- [ ] ACP gate decision and receipt recorded
- [ ] Rollback handle and recovery window documented
- [ ] Promotion watch scheduled if ACP policy requests it

**Action needed**: Review full spec/evidence as needed; promote only if ACP gate allows and team policy allows on-loop escalation.

[View full spec →] [View threat model →] [View migration plan →]
```

---

## Tier Comparison Reference

### Scope Limits

| Metric | T1 | T2 | T3 |
|--------|-----|-----|-----|
| Lines changed | < 50 | 50-300 | Any |
| Files changed | < 5 | 5-20 | Any |
| New endpoints | 0 | Any | Any |
| Auth/security surfaces | 0 | 0 | Any |
| Data migrations | 0 | 0 | Any |

### Gate Comparison

| Gate | T1 | T2 | T3 |
|------|-----|-----|-----|
| Lint/type/test | ✅ | ✅ | ✅ |
| Secret scan | ✅ | ✅ | ✅ |
| SBOM | ✅ | ✅ | ✅ |
| CodeQL/Semgrep | ❌ | ✅ | ✅ |
| Contract tests | ❌ | ✅ | ✅ |
| Preview deploy | ❌ | ✅ | ✅ |
| E2E smoke | ❌ | ✅ | ✅ |
| Threat analysis | ❌ | Lite | Full |
| Feature flag | ❌ | ✅ | ✅ |
| Observability | ❌ | ✅ | ✅ |
| Golden tests | ❌ | ❌ | ✅ |
| Verifier/recovery attestations | ❌ | ❌ | ✅ |
| Security evidence review | ❌ | ❌ | ✅ |
| Watch window | ❌ | ❌ | ✅ |

### Human Time Comparison

| Activity | T1 | T2 | T3 |
|----------|-----|-----|-----|
| Review summary | 30s | 2-5 min | N/A |
| Review spec | N/A | N/A | 10-15 min |
| Review threat model | N/A | 1 min | 5-10 min |
| Review PR | 1 min | 5-10 min | 10-15 min |
| Test preview | N/A | Optional | Required |
| Promotion decision | ACP-1 outcome | ACP-2 outcome | ACP-3 outcome (+ quorum) |
| Watch window | N/A | N/A | 30 min |
| **Total** | **2-3 min** | **15-20 min** | **30-60 min** |

---

## Tier Assignment Algorithm

See [auto-tier-assignment.md](./auto-tier-assignment.md) for the complete algorithm AI agents use to classify changes.

---

## Overriding Tiers

### Bumping Up

Always allowed. AI should suggest bumping up when:
- Change is borderline between tiers
- Unusual patterns detected
- Cross-cutting concerns identified

```yaml
tier_bump_up:
  command: "harmony tier-up <id> --reason '<reason>'"
  requires_justification: false
  requires_approval: false
```

### Bumping Down

Requires justification. AI should resist bumping down except:
- Clear misclassification based on file path
- Human explicitly requests with valid reason

```yaml
tier_bump_down:
  command: "harmony tier-down <id> --reason '<reason>'"
  requires_justification: true
  requires_escalation_review:
    from_t2_to_t1: false
    from_t3_to_t2: true  # Escalation artifact + verifier review + override evidence reference
    from_t3_to_t1: true  # Escalation artifact + security evidence review + override evidence reference
  required_fields_for_t3_downgrade:
    - override_artifact_ref
    - approver
    - timestamp
    - rationale
```

---

## Integration with Workflows

### Spec Generation

1. AI determines tier based on intent/files
2. AI selects appropriate spec template
3. AI fills spec completely
4. Optional on-loop oversight review of receipt/digest artifacts

### CI/CD Pipeline

1. PR receives tier label automatically
2. CI runs tier-appropriate gates
3. Gate failures block merge
4. Tier-specific ACP/quorum/escalation requirements enforced

### Documentation

1. Each change gets tier-appropriate documentation
2. ADRs required for T3
3. Observability requirements scale with tier

See also:
- [spec-first-planning.md](./spec-first-planning.md)
- [ci-cd-quality-gates.md](./ci-cd-quality-gates.md)
- [flow-and-wip-policy.md](./flow-and-wip-policy.md)

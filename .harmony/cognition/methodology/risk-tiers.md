---
title: Risk Tier Classification System
description: Comprehensive AI-facing documentation for Harmony's three-tier risk classification system, including criteria, gates, responsibilities, and automation logic.
---

# Risk Tier Classification System

This document provides the complete specification for Harmony's risk tier system. It is designed for AI agents to use when classifying changes, generating specs, and applying appropriate rigor.

For the human-facing summary, see [../context/risk-tiers.md](../context/risk-tiers.md).

---

## Overview

Every change in Harmony is classified into one of three risk tiers:

| Tier | Name | Human Time | AI Rigor | Governance Flow |
|------|------|------------|----------|-----------------|
| **T1** | Trivial | 2-3 min | Standard gates | Stage -> evidence -> ACP-1 gate -> promote/stage-only -> receipt |
| **T2** | Standard | 15-20 min | Standard + threat analysis + preview | Stage -> evidence -> ACP-2 gate (+ quorum) -> promote/stage-only -> receipt |
| **T3** | Elevated | 30-60 min | Full analysis + staged safety checks | Stage -> evidence -> ACP-3 gate (+ quorum) -> promote/stage-only -> receipt |

**Key Principle:** AI applies appropriate rigor at every tier. The difference is ACP strength (evidence, quorum, budgets, reversibility), while humans remain on-the-loop for escalation and optional post-run oversight.

Governance references: [Autonomous Control Points](../principles/autonomous-control-points.md), [Deny by Default](../principles/deny-by-default.md), [Arbitration & Precedence](../principles/README.md#arbitration--precedence).

---

## Pillar Alignment by Tier

The risk tier system operationalizes Harmony's [Six Pillars](../pillars/README.md), with each tier emphasizing different pillars based on the nature and risk of the change.

| Tier | Primary Pillars | Rationale |
|------|-----------------|-----------|
| **T1** | [Velocity](../pillars/velocity.md) | Fast delivery with basic gates. Trivial changes benefit from speed; minimal ceremony serves throughput. |
| **T2** | [Direction](../pillars/direction.md), [Velocity](../pillars/velocity.md), [Trust](../pillars/trust.md) | Validated spec ensures we build the right thing. Threat analysis and feature flags balance speed with safety. |
| **T3** | [Direction](../pillars/direction.md), [Trust](../pillars/trust.md), [Continuity](../pillars/continuity.md) | Full spec validation, security review, and ADRs. Elevated risk demands governed determinism and institutional memory. |

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

Use the BMAD-lite format:

```yaml
# T1 Spec: BMAD-Lite
tier: 1
title: "<Short descriptive title>"
intent: "<1-2 sentences describing what and why>"

scope:
  files:
    - "<file1.ts>"
    - "<file2.md>"
  surfaces: []  # Empty for T1
  
risk_assessment:
  classification: trivial
  security_impact: none
  data_impact: none
  rollback: "revert commit"

verification:
  tests_affected: existing_pass | new_added
  manual_check: not_required
```

### T1 Gates (AI Enforces)

| Gate | Required | Notes |
|------|----------|-------|
| Lint & format | ✅ | ESLint, Prettier |
| Type check | ✅ | `tsc --noEmit` |
| Unit tests | ✅ | Existing must pass |
| Secret scan | ✅ | GitHub + TruffleHog |
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

3. **Optional on-the-loop check** (if required by team policy)
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

Use the Standard format:

```yaml
# T2 Spec: Standard
tier: 2
title: "<Descriptive title>"
created: "<ISO date>"
owner: "<developer>"

# Problem & Solution
problem:
  statement: "<What problem does this solve>"
  context: "<Why now, what's the impact>"
  
solution:
  summary: "<How we're solving it>"
  approach: "<Technical approach in 2-3 sentences>"

# Scope
scope:
  in_scope:
    - "<Behavior 1>"
    - "<Behavior 2>"
  out_of_scope:
    - "<Explicitly not doing X>"
  
  surfaces:
    - type: api | ui | worker | adapter
      path: "<path or component>"
      
  files_estimate:
    new: <N>
    modified: <N>
    total_lines: <N>

# Contracts (if API)
contracts:
  - path: "/api/<path>"
    method: GET | POST | PUT | DELETE
    request_schema: "<ref or inline>"
    response_schema: "<ref or inline>"
    auth_required: true | false

# Threat Analysis (STRIDE-lite)
threat_analysis:
  classification: standard
  stride_lite:
    spoofing: "<N/A or risk + mitigation>"
    tampering: "<N/A or risk + mitigation>"
    repudiation: "<N/A or risk + mitigation>"
    information_disclosure: "<N/A or risk + mitigation>"
    denial_of_service: "<N/A or risk + mitigation>"
    elevation_of_privilege: "<N/A or risk + mitigation>"
  summary: "<1-2 sentence threat summary>"

# Testing
testing:
  unit_tests:
    count: <N>
    coverage_target: "<percentage>"
  contract_tests:
    count: <N>
    paths: ["<path>"]
  e2e_smoke:
    required: true
    flows: ["<flow description>"]

# Rollout
rollout:
  flag_name: "feature.<name>"
  flag_default: false
  rollout_plan:
    - stage: internal
      percentage: 100
    - stage: canary
      percentage: 5
    - stage: general
      percentage: 100
  rollback:
    method: "disable flag"
    fallback: "promote prior preview"

# Observability
observability:
  spans:
    - "<span.name>"
  metrics:
    - "<metric.name>"
  logs:
    - level: info | warn | error
      event: "<event description>"
```

### T2 Gates (AI Enforces)

| Gate | Required | Notes |
|------|----------|-------|
| Lint & format | ✅ | ESLint, Prettier |
| Type check | ✅ | `tsc --noEmit` |
| Unit tests | ✅ | New + existing |
| Contract tests | ✅ | If API changes |
| OpenAPI diff | ✅ | oasdiff |
| Secret scan | ✅ | GitHub + TruffleHog |
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
   
3. **Check preview** (optional, 2-3 minutes)
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

Use the Full format:

```yaml
# T3 Spec: Full
tier: 3
title: "<Descriptive title>"
created: "<ISO date>"
owner: "<developer>"
navigator: "<second developer>"

# Problem & Solution
problem:
  statement: "<Detailed problem description>"
  context: "<Business context and urgency>"
  impact:
    users_affected: "<scope>"
    systems_affected: ["<system>"]
    
solution:
  summary: "<Solution overview>"
  approach: "<Detailed technical approach>"
  alternatives_considered:
    - option: "<Alternative 1>"
      rejected_because: "<Reason>"
    - option: "<Alternative 2>"
      rejected_because: "<Reason>"

# Scope
scope:
  in_scope:
    - "<Behavior 1>"
    - "<Behavior 2>"
  out_of_scope:
    - "<Explicitly not doing X>"
  dependencies:
    - "<External dependency>"
    
  surfaces:
    - type: api | ui | worker | adapter
      path: "<path or component>"
      sensitivity: high | critical
      
  files_estimate:
    new: <N>
    modified: <N>
    total_lines: <N>

# Data Classification
data_classification:
  categories_touched:
    - category: pii | phi | secret | auth | financial
      fields: ["<field>"]
      handling: "<how it's handled>"
  data_flows:
    - from: "<source>"
      to: "<destination>"
      encrypted: true | false
      logged: true | false
      sensitive_fields_redacted: true | false

# Contracts
contracts:
  - path: "/api/<path>"
    method: GET | POST | PUT | DELETE
    request_schema:
      type: object
      properties: {}
    response_schema:
      type: object
      properties: {}
    auth:
      required: true
      type: "<auth type>"
      scopes: ["<scope>"]
    rate_limiting:
      enabled: true
      limit: "<limit>"

# Full STRIDE Threat Model
threat_model:
  classification: elevated
  assets:
    - name: "<asset>"
      sensitivity: high | critical
      
  stride:
    spoofing:
      applicable: true | false
      threats:
        - description: "<threat>"
          likelihood: low | medium | high
          impact: low | medium | high | critical
          mitigation: "<mitigation>"
          tests: ["<test description>"]
          
    tampering:
      applicable: true | false
      threats:
        - description: "<threat>"
          likelihood: low | medium | high
          impact: low | medium | high | critical
          mitigation: "<mitigation>"
          tests: ["<test description>"]
          
    repudiation:
      applicable: true | false
      threats:
        - description: "<threat>"
          likelihood: low | medium | high
          impact: low | medium | high | critical
          mitigation: "<mitigation>"
          tests: ["<test description>"]
          
    information_disclosure:
      applicable: true | false
      threats:
        - description: "<threat>"
          likelihood: low | medium | high
          impact: low | medium | high | critical
          mitigation: "<mitigation>"
          tests: ["<test description>"]
          
    denial_of_service:
      applicable: true | false
      threats:
        - description: "<threat>"
          likelihood: low | medium | high
          impact: low | medium | high | critical
          mitigation: "<mitigation>"
          tests: ["<test description>"]
          
    elevation_of_privilege:
      applicable: true | false
      threats:
        - description: "<threat>"
          likelihood: low | medium | high
          impact: low | medium | high | critical
          mitigation: "<mitigation>"
          tests: ["<test description>"]
          
  asvs_controls:
    - id: "<ASVS-X.Y.Z>"
      description: "<control>"
      implementation: "<how implemented>"
      
  residual_risks:
    - risk: "<remaining risk>"
      acceptance: "<why acceptable>"
      owner: "<who accepts>"

# Testing
testing:
  unit_tests:
    count: <N>
    coverage_target: "<percentage>"
    security_focused:
      - "<test description>"
      
  contract_tests:
    count: <N>
    paths: ["<path>"]
    
  integration_tests:
    count: <N>
    scenarios: ["<scenario>"]
    
  security_tests:
    count: <N>
    categories:
      - auth_bypass
      - injection
      - idor
      - "<other>"
      
  golden_tests:
    count: <N>
    critical_paths:
      - "<path description>"
      
  e2e_smoke:
    required: true
    flows:
      - "<flow 1>"
      - "<flow 2>"

# Migration (if applicable)
migration:
  required: true | false
  type: schema | data | both
  strategy: forward_only | dual_write | blue_green
  
  steps:
    - step: 1
      description: "<step>"
      reversible: true | false
      
  rollback:
    possible: true | false
    method: "<rollback method>"
    data_loss: none | acceptable | requires_backup
    
  validation:
    pre_migration: ["<check>"]
    post_migration: ["<check>"]

# Rollout
rollout:
  flag_name: "feature.<name>"
  flag_default: false
  
  stages:
    - name: internal
      percentage: 100
      duration: "1 day"
      success_criteria:
        - "<criteria>"
        
    - name: canary
      percentage: 5
      duration: "1 hour minimum"
      success_criteria:
        - error_rate: "<= 0.5%"
        - latency_p95: "<= budget"
        
    - name: general
      percentage: 100
      success_criteria:
        - "<criteria>"
        
  rollback:
    immediate: "disable flag"
    full: "promote prior preview + disable flag"
    data_rollback: "<if applicable>"
    
  watch_window:
    duration: "30 minutes"
    metrics_to_watch:
      - "<metric>"
    alert_thresholds:
      - metric: "<metric>"
        threshold: "<value>"

# Observability
observability:
  spans:
    - name: "<span.name>"
      attributes:
        - "<attr>"
  metrics:
    - name: "<metric.name>"
      type: counter | histogram | gauge
  logs:
    - level: info | warn | error
      event: "<event>"
      fields:
        - "<field>"
  dashboards:
    - "<dashboard link or name>"
  alerts:
    - name: "<alert>"
      condition: "<condition>"
      severity: warning | critical

# SLO Implications
slo_implications:
  affected_slos:
    - slo: "<SLO name>"
      current: "<current target>"
      expected_impact: "<impact>"
  new_slis:
    - name: "<SLI>"
      definition: "<definition>"

# ACP Promotion Contract
acp_flow:
  sequence:
    - stage
    - gather_evidence
    - acp_gate
    - promote_or_stage_only
    - receipt_and_digest
  escalation:
    when:
      - quorum_unresolved
      - risk_threshold_crossed
      - policy_requires_human_input
  human_oversight:
    mode: on_the_loop
    required_for_routine_promotion: false

t3_requirements:
  acp: ACP-3
  evidence_required: [plan, diff, tests, ci, rollback_proof]
  quorum_required: quorum.acp3
  enforce_budgets: true
  require_receipt: true
```

### T3 Gates (AI Enforces)

| Gate | Required | Notes |
|------|----------|-------|
| Lint & format | ✅ | ESLint, Prettier |
| Type check | ✅ | `tsc --noEmit` |
| Unit tests | ✅ | Including security tests |
| Contract tests | ✅ | Required |
| Integration tests | ✅ | If applicable |
| OpenAPI diff | ✅ | Breaking change review |
| Secret scan | ✅ | GitHub + TruffleHog |
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
| Navigator review | ✅ | Independent review pass (time-separated if solo) |
| Security review | ✅ | Explicit sign-off |

### T3 Oversight Touchpoints (Human-on-the-Loop)

**Stage 1: Stage + Evidence**

1. **AI stages and assembles evidence** (plan, diff, tests, rollback proof).
2. **Verifier + recovery attestations are collected** for ACP-3 quorum.
3. **ACP gate evaluates promotion** and returns `ALLOW` or `STAGE_ONLY`.

**Stage 2: Promote or Stage-Only**

1. **Promote only on ACP `ALLOW`**.
2. **On missing quorum/disagreement**, remain stage-only and emit escalation artifact.

**Stage 3: Optional Oversight + Watch**

1. **Review receipt/digest** (optional, recommended for T3).
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
| Navigator review | ❌ | ❌ | ✅ |
| Security review | ❌ | ❌ | ✅ |
| Watch window | ❌ | ❌ | ✅ |

### Human Time Comparison

| Activity | T1 | T2 | T3 |
|----------|-----|-----|-----|
| Review summary | 30s | 2-5 min | N/A |
| Review spec | N/A | N/A | 10-15 min |
| Review threat model | N/A | 1 min | 5-10 min |
| Review PR | 1 min | 5-10 min | 10-15 min |
| Test preview | N/A | Optional | Required |
| Approve | Click | Click | Multi-stage |
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
  requires_approval:
    from_t2_to_t1: false
    from_t3_to_t2: true  # Navigator approval (review pass)
    from_t3_to_t1: true  # Navigator approval (security checklist)
```

---

## Integration with Workflows

### Spec Generation

1. AI determines tier based on intent/files
2. AI selects appropriate spec template
3. AI fills spec completely
4. Human reviews per tier requirements

### CI/CD Pipeline

1. PR receives tier label automatically
2. CI runs tier-appropriate gates
3. Gate failures block merge
4. Tier-specific approval requirements enforced

### Documentation

1. Each change gets tier-appropriate documentation
2. ADRs required for T3
3. Observability requirements scale with tier

See also:
- [spec-first-planning.md](./spec-first-planning.md)
- [ci-cd-quality-gates.md](./ci-cd-quality-gates.md)
- [flow-and-wip-policy.md](./flow-and-wip-policy.md)

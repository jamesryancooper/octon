---
title: Auto-Tier Assignment Algorithm
description: Algorithm and rules for AI agents to automatically classify changes into risk tiers.
---

# Auto-Tier Assignment Algorithm

This document specifies the algorithm AI agents use to automatically classify changes into risk tiers (T1, T2, T3).

## Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    TIER ASSIGNMENT FLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Extract Signals (files, intent, patterns)                   │
│                    ↓                                            │
│  2. Check T3 Triggers (any match → T3)                         │
│                    ↓                                            │
│  3. Check T2 Triggers (any match → T2)                         │
│                    ↓                                            │
│  4. Verify T1 Criteria (all must match → T1)                   │
│                    ↓                                            │
│  5. Default to T2 (when uncertain)                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Key Principle:** When in doubt, assign a higher tier. It's always safe to over-classify.

---

## Signal Extraction

### Input Sources

```yaml
signal_sources:
  primary:
    - intent: "Natural language description of the change"
    - files_changed: "List of file paths being modified"
    - diff_preview: "Estimated diff content"
    
  secondary:
    - related_issues: "Linked issues or tickets"
    - recent_changes: "Recent commits in affected areas"
    - codeowner_areas: "CODEOWNERS patterns matched"
```

### Signal Categories

```yaml
signals:
  file_signals:
    - paths_matched: []
    - directories_touched: []
    - file_types: []
    - total_files: 0
    
  scope_signals:
    - lines_added_estimate: 0
    - lines_removed_estimate: 0
    - total_lines_changed: 0
    
  content_signals:
    - keywords_detected: []
    - patterns_matched: []
    - imports_added: []
    
  surface_signals:
    - api_changes: false
    - ui_changes: false
    - database_changes: false
    - auth_changes: false
    - security_changes: false
```

---

## T3 Triggers (Elevated Risk)

**Rule:** If ANY T3 trigger matches, assign T3.

### Path-Based Triggers

```yaml
t3_path_triggers:
  # Authentication & Authorization
  auth_patterns:
    - "**/auth/**"
    - "**/authentication/**"
    - "**/authorization/**"
    - "**/login/**"
    - "**/logout/**"
    - "**/signin/**"
    - "**/signup/**"
    - "**/register/**"
    - "**/*oauth*"
    - "**/*saml*"
    - "**/*sso*"
    - "**/*session*"
    - "**/*token*"
    - "**/rbac/**"
    - "**/permissions/**"
    - "**/access-control/**"
    
  # Billing & Payments
  billing_patterns:
    - "**/billing/**"
    - "**/payment/**"
    - "**/payments/**"
    - "**/checkout/**"
    - "**/subscription/**"
    - "**/invoice/**"
    - "**/*stripe*"
    - "**/*paypal*"
    - "**/*braintree*"
    
  # Security
  security_patterns:
    - "**/security/**"
    - "**/crypto/**"
    - "**/encryption/**"
    - "**/*csp*"
    - "**/*cors*"
    - "**/*csrf*"
    - "**/middleware/auth*"
    - "**/middleware/security*"
    - "**/*.pem"
    - "**/*.key"
    
  # Data & Migrations
  data_patterns:
    - "**/migrations/**"
    - "**/migrate/**"
    - "**/seeds/**"
    - "**/fixtures/**"
    - "**/*schema*"
    - "**/prisma/schema.prisma"
    - "**/drizzle/**"
    
  # Infrastructure
  infra_patterns:
    - "**/infra/**"
    - "**/.github/workflows/**"
    - "**/ci/**"
    - "**/cd/**"
    - "**/deploy/**"
    - "vercel.json"
    - "docker-compose*.yml"
    - "Dockerfile*"
```

### Keyword Triggers

```yaml
t3_keyword_triggers:
  # In file content or intent
  auth_keywords:
    - "password"
    - "credential"
    - "authenticate"
    - "authorize"
    - "permission"
    - "role"
    - "admin"
    - "sudo"
    - "superuser"
    - "oauth"
    - "jwt"
    - "session"
    - "token"
    
  security_keywords:
    - "encrypt"
    - "decrypt"
    - "hash"
    - "salt"
    - "secret"
    - "private key"
    - "certificate"
    - "vulnerability"
    - "cve"
    - "security"
    - "xss"
    - "csrf"
    - "injection"
    - "sanitize"
    
  data_keywords:
    - "migration"
    - "schema change"
    - "add column"
    - "drop column"
    - "alter table"
    - "delete user"
    - "pii"
    - "gdpr"
    - "personal data"
    - "export data"
    
  billing_keywords:
    - "payment"
    - "charge"
    - "refund"
    - "subscription"
    - "billing"
    - "invoice"
    - "credit card"
    - "stripe"
```

### Pattern Triggers

```yaml
t3_pattern_triggers:
  # Code patterns that trigger T3
  dangerous_operations:
    - pattern: "DELETE FROM.*WHERE"
      description: "Bulk delete operations"
    - pattern: "DROP TABLE"
      description: "Schema destructive operations"
    - pattern: "TRUNCATE"
      description: "Data truncation"
    - pattern: "rm -rf"
      description: "Recursive file deletion"
      
  auth_operations:
    - pattern: "bcrypt|argon2|pbkdf2"
      description: "Password hashing"
    - pattern: "createSession|destroySession"
      description: "Session management"
    - pattern: "signJwt|verifyJwt"
      description: "JWT operations"
      
  sensitive_access:
    - pattern: "process\\.env\\."
      description: "Environment variable access"
      context: "Check if accessing secrets"
    - pattern: "getSecret|fetchSecret"
      description: "Secret retrieval"
```

---

## T2 Triggers (Standard)

**Rule:** If no T3 triggers match, check T2 triggers. If any match, assign T2.

### Path-Based Triggers

```yaml
t2_path_triggers:
  api_patterns:
    - "**/api/**"
    - "**/routes/**"
    - "**/controllers/**"
    - "**/handlers/**"
    - "**/endpoints/**"
    
  service_patterns:
    - "**/services/**"
    - "**/domain/**"
    - "**/core/**"
    - "**/business/**"
    
  ui_patterns:
    - "**/components/**"
    - "**/pages/**"
    - "**/views/**"
    - "**/app/**"
    - "**/*.tsx"
    - "**/*.jsx"
    
  adapter_patterns:
    - "**/adapters/**"
    - "**/repositories/**"
    - "**/clients/**"
    - "**/integrations/**"
```

### Scope Triggers

```yaml
t2_scope_triggers:
  lines_threshold:
    min: 50
    # Changes >= 50 lines trigger T2 (T1 allows < 50)
    
  files_threshold:
    min: 5
    # Changes to >= 5 files trigger T2 (T1 allows < 5)
    
  complexity_indicators:
    - "Multiple files modified"
    - "New exports added"
    - "Interface changes"
    - "Type changes affecting multiple files"
```

### Content Triggers

```yaml
t2_content_triggers:
  api_changes:
    - "app.get|app.post|app.put|app.delete"
    - "router.get|router.post"
    - "export.*handler"
    - "NextResponse|NextRequest"
    
  component_changes:
    - "export.*function.*Component"
    - "export default function"
    - "React.FC"
    - "useState|useEffect|useContext"
    
  service_changes:
    - "class.*Service"
    - "export.*service"
    - "implements.*Port"
    - "implements.*Repository"
```

---

## T1 Criteria (Trivial)

**Rule:** T1 is assigned ONLY if ALL criteria are met AND no T2/T3 triggers fired.

### All Must Be True

```yaml
t1_all_required:
  scope_limits:
    max_lines_changed: 49      # < 50 (exclusive); 50+ triggers T2
    max_files_changed: 4       # < 5 (exclusive); 5+ triggers T2
    
  file_restrictions:
    allowed_extensions:
      - ".md"
      - ".mdx"
      - ".txt"
      - ".css"
      - ".scss"
      - ".json"  # Only if non-security config
      - ".yaml"  # Only if non-security config
      
    allowed_directories:
      - "docs/**"
      - "**/__tests__/**"
      - "**/*.test.*"
      - "**/*.spec.*"
      - "**/README*"
      - ".github/ISSUE_TEMPLATE/**"
      - ".github/PULL_REQUEST_TEMPLATE/**"
      
  content_restrictions:
    no_logic_changes: true
    no_api_changes: true
    no_database_changes: true
    no_auth_changes: true
    no_security_changes: true
```

### T1 Positive Indicators

```yaml
t1_positive_indicators:
  # Strong indicators that support T1 classification
  patterns:
    - type: typo_fix
      indicators:
        - "Single word change"
        - "Spelling correction"
        - "Grammar fix"
      confidence_boost: 0.2
      
    - type: doc_update
      indicators:
        - "Only .md files changed"
        - "README update"
        - "Comment update"
      confidence_boost: 0.2
      
    - type: test_addition
      indicators:
        - "Only test files changed"
        - "New test cases added"
        - "No production code changes"
      confidence_boost: 0.1
      
    - type: style_change
      indicators:
        - "Only CSS/SCSS changed"
        - "No JavaScript/TypeScript logic"
      confidence_boost: 0.1
```

---

## Classification Algorithm

### Pseudocode

```typescript
async function classifyChange(intent: string, files: string[]): Promise<Tier> {
  // Step 1: Extract signals
  const signals = await extractSignals(intent, files);
  
  // Step 2: Check T3 triggers (highest priority)
  const t3Match = checkT3Triggers(signals);
  if (t3Match.triggered) {
    return {
      tier: 3,
      confidence: t3Match.confidence,
      reason: t3Match.reason,
      triggers: t3Match.triggers
    };
  }
  
  // Step 3: Check T2 triggers
  const t2Match = checkT2Triggers(signals);
  if (t2Match.triggered) {
    return {
      tier: 2,
      confidence: t2Match.confidence,
      reason: t2Match.reason,
      triggers: t2Match.triggers
    };
  }
  
  // Step 4: Verify T1 criteria
  const t1Valid = verifyT1Criteria(signals);
  if (t1Valid.allMet) {
    return {
      tier: 1,
      confidence: t1Valid.confidence,
      reason: "All T1 criteria met",
      criteria: t1Valid.criteria
    };
  }
  
  // Step 5: Default to T2 when uncertain
  return {
    tier: 2,
    confidence: 0.6,
    reason: "Defaulting to T2 (uncertain classification)",
    note: "Consider manual review"
  };
}
```

### Confidence Calculation

```yaml
confidence_factors:
  high_confidence: ">= 0.9"
  # Clear trigger match with strong signals
  
  medium_confidence: "0.7 - 0.89"
  # Trigger match with some ambiguity
  
  low_confidence: "< 0.7"
  # Uncertain classification, consider bumping up
  
calculation:
  base_confidence: 0.5
  
  boosters:
    - clear_path_match: +0.2
    - multiple_triggers: +0.1
    - keyword_match: +0.1
    - pattern_match: +0.1
    
  reducers:
    - ambiguous_scope: -0.1
    - mixed_signals: -0.15
    - borderline_size: -0.1
```

---

## Edge Cases

### Ambiguous Paths

```yaml
ambiguous_paths:
  # These paths need content analysis
  
  middleware:
    path: "**/middleware/**"
    analysis: "Check if auth/security middleware"
    if_auth: T3
    if_other: T2
    
  config:
    path: "**/config/**"
    analysis: "Check if security config"
    if_security: T3
    if_other: T1 or T2
    
  utils:
    path: "**/utils/**"
    analysis: "Check for crypto/auth utilities"
    if_sensitive: T3
    if_other: T1 or T2
```

### Size Overrides

```yaml
size_overrides:
  # Size alone doesn't determine tier
  
  large_doc_update:
    condition: "> 300 lines but only .md files"
    classification: T1
    reason: "Documentation doesn't carry risk"
    
  small_auth_change:
    condition: "< 10 lines but in auth/**"
    classification: T3
    reason: "Auth changes are always elevated"
    
  refactor_across_files:
    condition: "> 20 files but purely mechanical"
    classification: T2
    note: "May need manual verification"
```

### Intent Overrides

```yaml
intent_overrides:
  # User intent can influence classification
  
  security_fix:
    keywords: ["security fix", "vulnerability", "cve"]
    override: T3
    reason: "Security fixes need elevated review"
    
  hotfix:
    keywords: ["hotfix", "urgent fix", "production issue"]
    override: "Maintain current tier but flag for expedited review"
    
  experiment:
    keywords: ["experiment", "poc", "prototype"]
    note: "Consider if should be behind flag (T2+)"
```

---

## Tier Override Rules

### Bump Up (Always Allowed)

```yaml
bump_up:
  allowed: always
  requires_justification: false
  
  common_reasons:
    - "Gut feeling says riskier"
    - "Non-obvious dependencies"
    - "First change in this area"
    - "Customer-facing impact"
    
  command: "harmony tier-up <id> --reason '<reason>'"
```

### Bump Down (Restricted)

```yaml
bump_down:
  t2_to_t1:
    allowed: true
    requires_justification: true
    approval_required: false
    
    valid_reasons:
      - "File path triggered T2 but content is trivial"
      - "Test-only change in non-test directory"
      - "Config change with no runtime impact"
      
  t3_to_t2:
    allowed: true
    requires_justification: true
    approval_required: true  # Navigator must approve
    
    valid_reasons:
      - "File in auth/ but not auth logic"
      - "Migration is additive-only with no data changes"
      - "Security config update is defensive improvement"
      
	  t3_to_t1:
	    allowed: true
	    requires_justification: true
	    approval_required: true  # Navigator approval (security checklist)
    
    valid_reasons:
      - "Documentation in security directory"
      - "Test file in auth directory"
    
  command: "harmony tier-down <id> --reason '<reason>'"
```

---

## Integration Points

### SpecKit Integration

```typescript
// SpecKit uses this algorithm when generating specs
import { classifyChange } from '@harmony/tier-classifier';

async function generateSpec(intent: string, files: string[]) {
  const classification = await classifyChange(intent, files);
  const template = loadTemplate(`spec-tier${classification.tier}.yaml`);
  
  return {
    spec: await fillTemplate(template, intent, files),
    classification
  };
}
```

### CI/CD Integration

```yaml
# In CI pipeline
- name: Verify Tier Classification
  run: |
    TIER=$(harmony get-tier $PR_NUMBER)
    GATES=$(harmony get-gates --tier $TIER)
    echo "Running gates for T$TIER: $GATES"
```

### PR Labels

```yaml
pr_labels:
  tier1:
    label: "tier:1"
    color: "green"
    description: "Trivial change - minimal review"
    
  tier2:
    label: "tier:2"
    color: "yellow"
    description: "Standard change - normal review"
    
  tier3:
    label: "tier:3"
    color: "red"
    description: "Elevated risk - thorough review required"
```

---

## Monitoring & Improvement

### Classification Metrics

```yaml
metrics_to_track:
  accuracy:
    - "Tier upgrades after initial classification"
    - "Tier downgrades after initial classification"
    - "Human overrides by reason"
    
  efficiency:
    - "Classification time"
    - "Confidence distribution"
    - "Edge case frequency"
    
  quality:
    - "Post-merge issues by tier"
    - "Security issues missed"
    - "Over-classification rate"
```

### Feedback Loop

```yaml
feedback_loop:
  when_human_overrides:
    - Log original classification and signals
    - Log override reason
    - Queue for algorithm improvement review
    
  weekly_review:
    - Review all overrides
    - Identify pattern gaps
    - Update triggers/criteria as needed
    
  quarterly_calibration:
    - Analyze post-merge issues by tier
    - Adjust thresholds
    - Add new patterns from incidents
```

---

## See Also

- [Risk Tiers Overview](./risk-tiers.md)
- [Spec Templates](./templates/README.md)
- [CI/CD Quality Gates](./ci-cd-quality-gates.md)
- [Human-Facing Risk Tiers](../RISK-TIERS.md)

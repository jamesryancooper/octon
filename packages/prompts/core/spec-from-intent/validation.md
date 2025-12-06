# Validation Checklist for Spec-from-Intent Output

This document defines the validation rules applied to all spec-from-intent outputs.

## Automated Checks (AI Self-Validates)

### Schema Validation
- [ ] Output parses as valid YAML
- [ ] Conforms to tier-appropriate schema (T1, T2, or T3)
- [ ] All required fields present
- [ ] Field values within defined constraints (lengths, patterns, enums)

### Consistency Checks
- [ ] Tier matches scope indicators:
  - T1: < 50 LOC estimate, no auth/data surfaces
  - T2: < 300 LOC estimate, standard surfaces only
  - T3: auth, billing, data, or security surfaces present
- [ ] File paths use valid format (relative to workspace root)
- [ ] API paths follow REST conventions (`/api/resource/:param`)
- [ ] Feature flag follows naming pattern: `feature.<domain>.<name>`

### Completeness Checks
- [ ] Description explains both WHAT and WHY
- [ ] For T2/T3: Contracts cover all API surfaces mentioned
- [ ] For T3: Data classification covers all sensitive fields
- [ ] For T3: All STRIDE categories have at least one entry
- [ ] Test counts are non-zero for relevant categories

### Rollback Validation
- [ ] Rollback strategy is specific (not "revert if needed")
- [ ] For T2/T3: Mentions feature flag disable
- [ ] For T3: Both immediate and full rollback defined

## Red Flags (Triggers Human Review)

### Scope Mismatch
- [ ] T1 spec mentions auth, session, or security → Should be T2/T3
- [ ] T1 spec mentions database or schema changes → Should be T3
- [ ] T2 spec has > 300 LOC estimate → Consider splitting or T3
- [ ] T3 spec seems small and low-risk → Verify tier is appropriate

### Missing Critical Information
- [ ] Auth endpoint without CSRF protection mentioned
- [ ] Data storage without classification
- [ ] External API calls without timeout/retry strategy
- [ ] User input handling without validation mentioned

### Hallucination Indicators
- [ ] References files that don't exist in context
- [ ] References APIs or libraries not in the codebase
- [ ] Mentions features or patterns not in provided context
- [ ] Unusually specific implementation details without context

## Human Spot-Check Guide

For T1 specs:
- Does the description match my intent?
- Are there any hidden risks I see that AI missed?

For T2 specs:
- Does the scope feel right?
- Is the threat summary reasonable?
- Would I know how to roll this back?

For T3 specs (require full review):
- [ ] Read full description - does it capture my intent?
- [ ] Check data classification - any sensitive fields missed?
- [ ] Review STRIDE - are the obvious threats covered?
- [ ] Verify SLOs match our standards
- [ ] Confirm rollback plan is executable

## Golden Test Coverage

Golden tests for this prompt verify:

1. **T1 generation**: Given trivial intent, produces minimal valid T1 spec
2. **T2 generation**: Given standard feature, produces complete T2 spec with threat summary
3. **T3 generation**: Given security-sensitive intent, produces full STRIDE analysis
4. **Tier recommendation**: Given ambiguous intent, recommends appropriate tier
5. **Clarification request**: Given insufficient intent, asks for clarification


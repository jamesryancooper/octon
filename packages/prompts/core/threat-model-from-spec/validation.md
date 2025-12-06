# Validation Checklist for Threat-Model-from-Spec Output

## Automated Checks

### Schema Validation
- [ ] Output matches T2 or T3 schema based on input tier
- [ ] All required fields present
- [ ] Threat IDs are unique and follow pattern (S1, T1, R1, I1, D1, E1)

### Coverage Validation
- [ ] All STRIDE categories addressed (or explicitly marked N/A with reason)
- [ ] Each threat has at least one mitigation
- [ ] Each mitigation has at least one test
- [ ] For T3: likelihood and impact ratings present

### Specificity Checks
- [ ] Threats reference specific aspects of the feature
- [ ] Mitigations are implementable (not just "use encryption")
- [ ] Tests are verifiable (not just "ensure security")
- [ ] Attack scenarios describe realistic exploitation (T3)

## Red Flags

### Too Generic
- [ ] Threats could apply to any web application
- [ ] No mention of specific endpoints or data
- [ ] Mitigations don't reference feature specifics

### Missing Critical Analysis
- [ ] Auth feature without spoofing analysis
- [ ] Data storage without information disclosure analysis
- [ ] API endpoint without tampering analysis
- [ ] Admin feature without elevation of privilege analysis

### Incomplete Mitigations
- [ ] Threats identified but no mitigations proposed
- [ ] Mitigations don't address the actual threat
- [ ] No way to test that mitigation works

## Human Spot-Check Guide

### For T2
- Does the summary capture the main security concerns?
- Are the top 3-5 risks actually the most important?
- Are the recommended controls appropriate?

### For T3
- [ ] Review each STRIDE category
- [ ] Verify attack scenarios are realistic
- [ ] Confirm mitigations are feasible to implement
- [ ] Check that tests would actually catch the threat
- [ ] Review residual risks - are they acceptable?

## Surface-Specific Checks

### API Surfaces
- [ ] Authentication bypass considered
- [ ] Authorization (IDOR) considered
- [ ] Input validation considered
- [ ] Rate limiting considered

### Auth Surfaces
- [ ] Session management threats considered
- [ ] Credential storage threats considered
- [ ] Account enumeration considered
- [ ] Brute force protection considered

### Data Surfaces
- [ ] Data at rest encryption considered
- [ ] Data classification respected
- [ ] Access logging considered
- [ ] Data retention considered

### Billing Surfaces
- [ ] Payment data handling considered
- [ ] Fraud prevention considered
- [ ] Audit trail considered
- [ ] PCI DSS relevance noted


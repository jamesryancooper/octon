---
title: "Task: Handle a Security Issue"
description: Step-by-step guide to addressing security vulnerabilities and concerns.
access: human
---

# Task: Handle a Security Issue

This guide covers how to address security issues, from dependency vulnerabilities to code-level security fixes. Most security work is **T3 (elevated risk)**.

---

## Quick Reference

| Situation | Command |
|-----------|---------|
| Check security status | `harmony security status` |
| Investigate an alert | `harmony security investigate <alert-id>` |
| Fix a vulnerability | `harmony security fix <vuln-id>` |
| Run security audit | `harmony security audit` |
| Tighten a feature | `harmony security harden <feature>` |

---

## Types of Security Issues

### 1. Dependency Vulnerabilities

Alert example: "High severity CVE in lodash"

```bash
# Check current vulnerabilities
harmony security status

# See details
harmony security investigate CVE-2021-23337

# AI proposes fix
harmony security fix CVE-2021-23337
```

### 2. Code Vulnerabilities

Alert example: "Potential SQL injection in OrderService"

```bash
# Investigate
harmony security investigate SAST-001

# AI analyzes and proposes fix
harmony security fix SAST-001
```

### 3. Configuration Issues

Alert example: "CSP header missing on /api routes"

```bash
# Check headers
harmony security check headers

# Fix configuration
harmony security fix headers-csp
```

### 4. Proactive Hardening

No alert—you want to strengthen security.

```bash
# Audit a feature
harmony security audit auth

# Harden a feature
harmony security harden user-data
```

---

## Handling a Dependency Alert

### Step 1: Understand the Alert

```bash
harmony security investigate CVE-2021-23337
```

AI shows:
```
┌─ Security Alert: CVE-2021-23337 ─────────────────────────────────┐
│                                                                  │
│ Package: lodash 4.17.20                                          │
│ Severity: HIGH (CVSS 7.5)                                        │
│ Type: Prototype Pollution                                        │
│                                                                  │
│ Your exposure:                                                   │
│   - Used in: 3 files                                             │
│   - User input passed: NO ✓                                      │
│   - Exploitable in your context: UNLIKELY                        │
│                                                                  │
│ Fix available: Upgrade to 4.17.21                                │
│ Breaking changes: None                                           │
│                                                                  │
│ Recommendation: Fix (routine, T1)                                │
│                                                                  │
│ [Fix Now] [More Details] [Snooze 7 days] [Ignore with reason]    │
└──────────────────────────────────────────────────────────────────┘
```

### Step 2: Apply the Fix

```bash
# Auto-fix (for simple upgrades)
harmony security fix CVE-2021-23337

# AI updates package, runs tests, creates PR
```

### Step 3: Review and Merge

For T1 security fixes (simple upgrades), review is quick:
- Verify it's just a version bump
- Check tests pass
- Approve

---

## Handling a Code Vulnerability

### Step 1: Understand the Finding

```bash
harmony security investigate SAST-001
```

AI shows:
```
┌─ Security Finding: SAST-001 ─────────────────────────────────────┐
│                                                                  │
│ Type: SQL Injection                                              │
│ Severity: CRITICAL                                               │
│ Location: src/services/OrderService.ts:142                       │
│                                                                  │
│ Finding:                                                         │
│   User input is concatenated into SQL query without              │
│   parameterization.                                              │
│                                                                  │
│ Code:                                                            │
│   const query = `SELECT * FROM orders WHERE id = ${orderId}`;    │
│                                 ^^^^^^^^^^^                      │
│                                 Unsanitized input                │
│                                                                  │
│ Exploitability: HIGH                                             │
│   - orderId comes from URL parameter                             │
│   - No validation present                                        │
│                                                                  │
│ Recommendation: Fix immediately (T3)                             │
│                                                                  │
│ [Fix Now] [More Details] [False Positive]                        │
└──────────────────────────────────────────────────────────────────┘
```

### Step 2: Apply the Fix

```bash
harmony security fix SAST-001
```

AI generates:
- Parameterized query fix
- Input validation
- Updated tests
- T3 PR requiring Navigator review

### Step 3: T3 Review Process

For critical security fixes:

1. **Review the fix thoroughly**
   - Does it actually fix the vulnerability?
   - Any new attack vectors introduced?

2. **Both devs approve** (Navigator required for T3)

3. **Ship with monitoring**
   ```bash
   harmony ship security-fix-sast-001
   ```

4. **No gradual rollout** — security fixes go to 100% immediately

---

## Proactive Security Audit

### Audit a Feature

```bash
harmony security audit auth
```

AI analyzes:
- Code patterns
- Known vulnerability patterns (OWASP Top 10)
- Configuration
- Dependencies used

```
┌─ Security Audit: auth ───────────────────────────────────────────┐
│                                                                  │
│ STRIDE Analysis:                                                 │
│   Spoofing:           ✓ Session tokens are secure                │
│   Tampering:          ✓ CSRF protection present                  │
│   Repudiation:        ⚠ Missing audit log for password changes   │
│   Info Disclosure:    ✓ No sensitive data in responses           │
│   DoS:                ⚠ No rate limiting on login                 │
│   Elevation:          ✓ Role checks present                      │
│                                                                  │
│ Findings:                                                        │
│   HIGH   - No rate limiting on login endpoint                    │
│   MEDIUM - Password change not logged                            │
│   LOW    - Session timeout could be shorter (24h → 4h)           │
│                                                                  │
│ [Fix All] [Fix High Only] [View Details] [Export Report]         │
└──────────────────────────────────────────────────────────────────┘
```

### Fix Audit Findings

```bash
# Fix all findings
harmony security fix audit-auth

# Fix only high severity
harmony security fix audit-auth --severity high
```

---

## Hardening a Feature

Make an existing feature more secure:

```bash
harmony security harden user-data
```

AI suggests improvements:
```
┌─ Hardening Suggestions: user-data ───────────────────────────────┐
│                                                                  │
│ Current state: Good baseline security                            │
│                                                                  │
│ Suggested improvements:                                          │
│                                                                  │
│ 1. Add field-level encryption for sensitive fields               │
│    Impact: Protects data at rest                                 │
│    Effort: Medium                                                │
│                                                                  │
│ 2. Add audit logging for all data access                         │
│    Impact: Compliance, forensics                                 │
│    Effort: Low                                                   │
│                                                                  │
│ 3. Implement data retention policy                               │
│    Impact: Compliance, reduced exposure                          │
│    Effort: Medium                                                │
│                                                                  │
│ 4. Add anomaly detection for access patterns                     │
│    Impact: Early breach detection                                │
│    Effort: High                                                  │
│                                                                  │
│ [Apply All] [Select Specific] [View Details]                     │
└──────────────────────────────────────────────────────────────────┘
```

---

## Security Configurations

### Check Headers

```bash
harmony security check headers
```

Verifies:
- Content-Security-Policy
- X-Frame-Options
- X-Content-Type-Options
- Strict-Transport-Security
- Referrer-Policy

### Fix Header Issues

```bash
harmony security fix headers
```

AI updates middleware/configuration to add missing headers.

### Check Secrets

```bash
harmony security check secrets
```

Scans for:
- Hardcoded secrets
- Exposed API keys
- Credentials in logs

---

## Emergency Security Response

### Critical Vulnerability Discovered

```bash
# Immediate assessment
harmony security emergency "SQL injection in production"

# AI prioritizes:
# 1. Scope of exposure
# 2. Active exploitation check
# 3. Immediate mitigation
# 4. Fix plan
```

### If Actively Being Exploited

```bash
# Block the attack vector immediately
harmony security block <endpoint>

# This disables the endpoint while you fix
```

### Post-Incident

```bash
# Generate security incident report
harmony security report <incident-id>

# Includes: timeline, exposure, fix, prevention
```

---

## What AI Does (Behind the Scenes)

1. **Scans**: Runs SAST (CodeQL, Semgrep), dependency checks, config analysis
2. **Analyzes**: Determines exploitability in your specific context
3. **Prioritizes**: Ranks by actual risk, not just CVSS score
4. **Fixes**: Generates secure code following OWASP guidelines
5. **Tests**: Creates security-specific tests
6. **Documents**: Updates security documentation and threat models

---

## Security Best Practices

### Do

- ✅ Address HIGH/CRITICAL findings immediately
- ✅ Run `harmony security status` daily
- ✅ Audit new features before shipping
- ✅ Keep dependencies updated
- ✅ Review security PRs thoroughly (even AI-generated)

### Don't

- ❌ Ignore security alerts (even low severity)
- ❌ Snooze alerts indefinitely
- ❌ Ship security fixes without testing
- ❌ Assume AI fixes are perfect—review them

---

## Common Scenarios

### "Dependabot says we have 10 vulnerabilities"

```bash
# See the full picture
harmony security status

# Fix all auto-fixable
harmony security fix --auto

# For the rest, investigate one by one
harmony security investigate <id>
```

### "Security researcher reported a vulnerability"

```bash
# Start investigation
harmony security investigate --external "researcher report"

# AI helps assess and fix
# Follow responsible disclosure timeline
```

### "Compliance audit coming up"

```bash
# Generate compliance report
harmony security compliance --framework soc2

# Fix any gaps
harmony security fix compliance-gaps
```

### "Penetration test findings"

```bash
# Import findings
harmony security import pentest-results.json

# Prioritize and fix
harmony security fix pentest --severity high
```

---

## Time Estimates

| Issue Type | Investigation | Fix | Total |
|------------|---------------|-----|-------|
| Simple dep upgrade | 2 min | 5 min | 7 min |
| Complex dep upgrade | 10 min | 30 min | 40 min |
| Code vulnerability | 15 min | 30-60 min | 45-75 min |
| Configuration issue | 5 min | 15 min | 20 min |
| Full feature audit | 30 min | varies | varies |

---

## Next Steps

- [Run a data migration](./run-data-migration.md)
- [Fix a bug](./fix-a-bug.md)
- Back to [DAILY-FLOW.md](/.harmony/agency/practices/daily-flow.md)
- [Security Baseline](/.harmony/cognition/methodology/security-baseline.md) (full details)

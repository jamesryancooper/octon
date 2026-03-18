---
title: Risk Tiers
description: How Octon classifies changes by risk, and what level of review you need to provide for each tier.
---

# Risk Tiers

Octon classifies every change into one of three risk tiers. Agent workflows and ACP checks run by default; this determines how much human governance attention is required.

**The key insight:** Agents do the same rigorous work for all tiers under system-governed controls. The difference is how much *you* need to review and whether policy escalation is required.

---

## Tier Overview

| Tier | Risk Level | Your Time | What You Do |
|------|------------|-----------|-------------|
| **T1** | Trivial | 2-3 min | Skim summary, approve |
| **T2** | Standard | 15-20 min | Review spec summary and PR |
| **T3** | Elevated | 30-60 min | Full spec review, staged approval |

---

## Tier 1: Trivial

### What Triggers T1

- Changes < 50 lines of code
- Docs, tests, or comments only
- No business logic changes
- No auth, data, or security surfaces touched

**Examples:**
- Typo fixes
- Adding a log statement
- Updating documentation
- Minor CSS adjustments
- Dependency version bumps (patch level)

### What AI Does (T1)

- Generates a minimal spec (BMAD-lite)
- Writes the code and tests
- Runs all standard CI gates
- Creates a PR with a 1-paragraph summary

### What You Do (T1)

1. **Read the AI summary** (30 seconds)
   ```
   ## T1 Summary: Fix typo in ErrorBoundary
   
   **What**: Changed "recieved" → "received" in ErrorBoundary.tsx
   **Risk**: None (no logic change)
   **Tests**: Existing tests pass
   **Action needed**: Approve PR
   ```

2. **Check CI is green** (10 seconds)

3. **Approve** (click button)

**Total time: 2-3 minutes**

### When to Bump to T2

- If you're unsure about the change scope
- If it touches more files than expected
- If your gut says "this feels bigger"

```bash
octon tier-up <pr-number>
```

---

## Tier 2: Standard

### What Triggers T2

- Changes 50-300 lines of code
- New endpoints or UI components
- Business logic changes (non-security)
- Refactoring across multiple files

**Examples:**
- Adding a new API endpoint
- Creating a new UI component
- Implementing a new feature
- Refactoring a service
- Database query optimizations

### What AI Does (T2)

- Generates a full spec with:
  - Problem/solution description
  - API contracts or UI wireframe
  - Test plan
  - STRIDE-lite threat check (automated)
- Writes code, tests, and documentation
- Creates a PR with:
  - Spec summary
  - Threat analysis summary
  - Test coverage report
- Runs all CI gates plus preview smoke tests
- Deploys to preview environment

### What You Do (T2)

1. **Review the spec summary** (2-5 minutes)
   ```
   ## T2 Summary: Add /api/users/:id endpoint
   
   **What**: New GET endpoint returning user profile
   **Spec summary**: Returns public profile fields only 
   (name, avatar, bio). Auth required. No PII in response.
   
   **Threat check**: ✅ IDOR mitigated (auth required)
   **Tests**: 4 unit, 1 contract, preview smoke passing
   **Flag**: feature.user-profile (default OFF)
   
   **Action needed**: Review spec summary, approve PR
   ```

2. **Scan the PR changes** (5-10 minutes)
   - Do the changes match the spec?
   - Any obvious code smells?
   - Tests cover the key paths?

3. **Optionally check the preview** (2-3 minutes)
   - Click the preview URL
   - Try the feature manually

4. **Approve**

**Total time: 15-20 minutes**

### When to Bump to T3

- If it touches auth, billing, or user data
- If the threat analysis flags something
- If you're introducing a new pattern or architecture

```bash
octon tier-up <pr-number> --reason "touches user sessions"
```

---

## Tier 3: Elevated

### What Triggers T3

- Auth, session, or access control changes
- Billing or payment handling
- PII or sensitive data access
- Database schema migrations
- Security configurations
- Infrastructure changes
- Any change AI flags as high-risk

**Examples:**
- OAuth integration
- Payment processing
- User data export/deletion
- Database migrations
- CSP or security header changes
- New third-party integrations with sensitive scopes

### What AI Does (T3)

- Generates a complete spec with:
  - Detailed problem/solution
  - Full API contracts
  - Data classification
  - Complete STRIDE threat model
  - SLO implications
  - Migration plan (if applicable)
  - Detailed rollback procedure
- Writes extensive tests including:
  - Unit tests
  - Contract tests
  - Security-focused tests
  - Golden tests for critical paths
- Creates staged PR with:
  - Full spec (you review before build)
  - Complete threat analysis
  - Test coverage report
  - Observability verification

### What You Do (T3)

**Stage 1: Approve Spec (before AI builds)**

1. **Read the full spec** (10-15 minutes)
   - Does it capture the requirement correctly?
   - Are the contracts well-defined?
   - Is anything missing?

2. **Review the threat analysis** (5-10 minutes)
   - Does STRIDE cover the obvious risks?
   - Are mitigations appropriate?
   - Any concerns not addressed?

3. **Approve spec to proceed**
   ```bash
   octon approve-spec oauth-integration
   ```

**Stage 2: Review PR (after AI builds)**

1. **Review code changes** (10-15 minutes)
   - Does implementation match spec?
   - Are security mitigations implemented?
   - Any code patterns that concern you?

2. **Review test coverage** (5 minutes)
   - Are critical paths covered?
   - Do security tests make sense?

3. **Check preview thoroughly** (5-10 minutes)
   - Test the feature manually
   - Try edge cases
   - Check for obvious security issues

4. **Second reviewer (Navigator)** required for T3
   - ACP-3 quorum requires proposer/verifier/recovery attestations
   - Security-focused review

**Stage 3: Post-Deploy Watch**

After promoting to production:
- 30-minute watch window
- Monitor error rates and SLOs
- Be ready to rollback

**Total time: 30-60 minutes** (but spread across stages)

---

## Tier Comparison Matrix

| Aspect | T1 | T2 | T3 |
|--------|----|----|-----|
| **Spec** | BMAD-lite (AI fills) | Standard (AI fills, you skim) | Full (you review before build) |
| **Threat Analysis** | Skip | STRIDE-lite (auto) | Full STRIDE (you review) |
| **Code Review** | Skim summary | Spot-check | Thorough review |
| **Preview Check** | Optional | Recommended | Required |
| **Reviewers** | 1 (auto-approve OK) | 1 | 2 (Navigator required) |
| **Feature Flag** | Optional | Required | Required |
| **Watch Window** | None | None | 30 minutes |
| **Rollback Plan** | Revert commit | Disable flag | Documented, rehearsed |

---

## How AI Assigns Tiers

AI auto-assigns tiers based on:

| Signal | Tier Impact |
|--------|-------------|
| Files in `auth/`, `billing/`, `security/` | → T3 |
| Database migrations | → T3 |
| Changes to CSP, CORS, or security headers | → T3 |
| API endpoints with write operations | → T2 minimum |
| Changes > 300 LOC | → T2 minimum |
| Changes < 50 LOC, no logic | → T1 |
| Docs/tests only | → T1 |

**You can always override:**

```bash
# Bump up (always allowed)
octon tier-up <id> --reason "touches sessions"

# Bump down (requires justification)
octon tier-down <id> --reason "actually just a config change"
```

---

## What Each Tier Guarantees

### All Tiers (AI handles automatically)

- ✅ Code passes linting and type checks
- ✅ All tests pass
- ✅ CI gates are green
- ✅ No secrets in code
- ✅ Dependencies scanned
- ✅ SBOM generated

### T2 and T3 (additional)

- ✅ Threat analysis completed
- ✅ Feature flag in place
- ✅ Preview deployed and tested
- ✅ Rollback procedure documented

### T3 Only (additional)

- ✅ Full STRIDE threat model
- ✅ Two-person review
- ✅ Security-specific tests
- ✅ Post-deploy watch window
- ✅ Rollback rehearsed

---

## Quick Decision Guide

```
Is it auth, billing, data, or security?
  └─ YES → T3
  └─ NO → Continue

Is it a new feature or significant change?
  └─ YES → T2
  └─ NO → Continue

Is it just docs, tests, or tiny fixes?
  └─ YES → T1
  └─ NO → T2 (default to caution)
```

---

## Examples by Tier

### T1 Examples

| Change | Why T1 |
|--------|--------|
| Fix "recieved" → "received" typo | Docs/copy only |
| Add console.log for debugging | No logic change |
| Update README with new instructions | Docs only |
| Bump lodash 4.17.20 → 4.17.21 | Patch version, no breaking changes |
| Add alt text to image | Accessibility, no logic |

### T2 Examples

| Change | Why T2 |
|--------|--------|
| Add `GET /api/users/:id` | New endpoint |
| Create UserProfileCard component | New UI component |
| Refactor OrderService to use repository pattern | Architecture change |
| Add pagination to list endpoints | Logic change across files |
| Integrate Stripe for payments | ⚠️ Actually T3 (billing) |

### T3 Examples

| Change | Why T3 |
|--------|--------|
| Add Google OAuth login | Auth system |
| Implement "delete my data" feature | User data, GDPR |
| Add role-based access control | Access control |
| Migrate users table schema | Database migration |
| Update CSP headers | Security configuration |
| Integrate third-party with user data scope | Data sharing |

---

## Overriding Tiers

### Bumping Up

Always allowed. Use when:
- Your gut says it's riskier than AI thinks
- You want more thorough review
- The change has non-obvious implications

```bash
octon tier-up <id> --reason "affects caching behavior"
```

### Bumping Down

Requires justification. Use when:
- AI over-classified based on file path
- It's genuinely simpler than it looks

```bash
octon tier-down <id> --reason "config change only, no auth logic"
```

**Note:** Bumping down from T3 requires Navigator approval.

---

## Full Documentation

For the complete risk classification system, gate matrices, and policy details:

- **Flow & WIP Policy**: [methodology/flow-and-wip-policy.md](../../practices/methodology/flow-and-wip-policy.md)
- **CI/CD Gates**: [methodology/ci-cd-quality-gates.md](../../practices/methodology/ci-cd-quality-gates.md)
- **Security Baseline**: [methodology/security-baseline.md](../../practices/methodology/security-baseline.md)

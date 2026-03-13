# AI Guardrails: What Humans Need to Know

This guide explains how Octon protects against AI failures and what you should watch for when reviewing AI-generated content.

## How It Works

```
┌──────────────────────────────────────────────────────────────┐
│  You (Human Developer)                                        │
│  └─ octon check output.ts                                  │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│  GuardKit                                                     │
│  ├─ Prompt Injection Detection (8 patterns)                  │
│  ├─ Secret Scanning (8 types: AWS, GitHub, JWT...)           │
│  ├─ Hallucination Detection (imports, APIs, helpers)         │
│  ├─ PII Detection (email, phone, SSN...)                     │
│  └─ Code Safety (eval, SQL injection, XSS...)                │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│  Result: ✅ Safe  |  ⚠️ Warnings  |  ❌ Blocked               │
└──────────────────────────────────────────────────────────────┘
```

## What's Protected Against

| Risk | Protection | Severity |
|------|------------|----------|
| Prompt Injection | "Ignore instructions" patterns | 🔴 Critical |
| Secret Exposure | AWS keys, GitHub tokens, JWTs | 🔴 Critical |
| SQL Injection | Query concatenation | 🔴 Critical |
| `eval()` Usage | Arbitrary code execution | 🔴 Critical |
| Hallucinated Imports | Unknown packages | 🔴 High |
| Fake APIs | Non-existent methods | 🔴 High |
| XSS Patterns | innerHTML, dangerouslySet... | 🟡 High |
| PII Exposure | Emails, phones, SSNs | 🟡 Medium |
| Empty Catch Blocks | Swallowed errors | 🟡 Medium |
| TODO Placeholders | Incomplete code | 🟢 Low |

## Quick Reference: Red Flags

When reviewing AI output, watch for these warning signs:

| Red Flag | What It Looks Like | What to Do |
|----------|-------------------|------------|
| 🔴 **Unknown imports** | `import { helper } from '@unknown/package'` | Run `npm info <package>` to verify it exists |
| 🔴 **Generic helpers** | `import { processData } from '../utils/helpers'` | Check if the file/function actually exists |
| 🔴 **Fake APIs** | `localStorage.getAsync()` | These don't exist—verify against MDN/docs |
| 🟡 **TODO placeholders** | `// TODO: implement this` | Code is incomplete—needs finishing |
| 🟡 **Empty error handling** | `catch (e) { }` | Silently swallowing errors is dangerous |
| 🟡 **Overly generic names** | `const data = await fetch...` | May indicate placeholder code |
| 🟢 **Too-perfect code** | No edge cases, no error handling | Probably incomplete or oversimplified |

## How Octon Protects You

### Automatic Checks

Every AI output goes through automatic guardrail checks:

1. **Prompt Injection Detection**: Blocks attempts to manipulate AI behavior
2. **Secret Scanning**: Catches leaked API keys, passwords, tokens
3. **PII Detection**: Flags email addresses, phone numbers, SSNs
4. **Hallucination Detection**: Identifies fake imports, functions, APIs
5. **Code Safety**: Catches dangerous patterns (eval, SQL injection, XSS)

### What Gets Blocked

These issues will **block** the AI output from proceeding:

- ❌ Leaked secrets (API keys, passwords, tokens)
- ❌ Critical prompt injection attempts
- ❌ Use of `eval()` or similar dangerous patterns
- ❌ SQL injection vulnerabilities
- ❌ Disabled SSL verification

### What Gets Flagged (But Can Proceed)

These issues generate **warnings** that you should review:

- ⚠️ Unknown package imports
- ⚠️ Generic helper/util imports
- ⚠️ Empty catch blocks
- ⚠️ TODO/placeholder comments
- ⚠️ Hardcoded localhost URLs
- ⚠️ Potential PII in output

## Your Responsibilities

### For T1 (Trivial) Changes

- Skim the AI summary
- Check that the change looks reasonable
- Approve if no red flags

**Time: ~2 minutes**

### For T2 (Standard) Changes

- Review the spec summary
- Check imports are valid (run `octon verify-imports` if unsure)
- Look for red flags listed above
- Run the preview and spot-check key functionality

**Time: ~10-15 minutes**

### For T3 (High-Risk) Changes

- Review full spec before AI builds
- Verify all imports and dependencies
- Review security analysis carefully
- Test edge cases in preview
- Watch deployment for 30 minutes

**Time: ~30-45 minutes**

## Commands for Verification

```bash
# Verify AI output hasn't hallucinated imports
octon verify-imports

# Run full guardrail checks on output
octon check --guardrails

# Explain why AI made certain decisions
octon explain "why did you use package X?"

# Retry with stricter constraints
octon retry --constraint "only use packages already in package.json"
```

## Common Hallucination Patterns

### 1. Fake Package Imports

AI sometimes invents packages that sound plausible but don't exist:

```typescript
// ❌ Suspicious - "helper" packages are often hallucinated
import { validateUser } from '@auth/helper-utils';

// ✅ Better - use known packages
import { z } from 'zod';
```

**How to verify:** Run `npm info <package-name>`

### 2. Non-Existent APIs

AI sometimes uses APIs that don't exist or work differently:

```typescript
// ❌ Wrong - this async method doesn't exist
const data = localStorage.getAsync('key');

// ✅ Correct - localStorage is synchronous
const data = localStorage.getItem('key');
```

**How to verify:** Check MDN Web Docs or official documentation

### 3. Invented Configuration Options

AI sometimes creates configuration options that look reasonable but don't exist:

```typescript
// ❌ Suspicious - "autoSanitize" may not be a real option
const client = new ApiClient({
  autoSanitize: true,
  smartMode: 'enhanced'
});

// ✅ Verify against actual documentation
const client = new ApiClient({
  baseURL: process.env.API_URL
});
```

**How to verify:** Check the package's official documentation

### 4. Scope Creep

AI sometimes generates much more code than requested:

```
You asked: "Add a login button"
AI generated: Login, registration, password reset, 2FA, admin panel...
```

**What to do:** 
- Use `octon retry --constraint "only implement login, nothing else"`
- Or break into smaller tasks

## When to Override AI

You should **reject** AI output when:

1. It imports packages not in package.json (and you didn't ask for new deps)
2. It references files that don't exist
3. It uses APIs you can't verify
4. It generates code for things you didn't ask for
5. Security checks fail

You should **request regeneration** when:

1. Code has TODO placeholders
2. Error handling is missing or generic
3. Tests are missing for critical paths
4. The approach seems overcomplicated

## Golden Tests and Quality Monitoring

### What Are Golden Tests?

Golden tests are saved examples of expected AI output. They help us detect when AI behavior changes (intentionally or not).

### How They're Used

1. **Weekly runs**: Golden tests run automatically every week
2. **Before model updates**: Run before switching AI models
3. **After prompt changes**: Verify changes don't break things

### Monitoring Dashboard

Check AI quality metrics:

- **Pass rate**: Should be > 90%
- **Drift**: Large changes from baseline may indicate problems
- **Consistency**: Highly variable outputs suggest temperature too high

### When You'll Be Alerted

You'll get notifications when:

- Pass rate drops below 90%
- Significant drift is detected
- Multiple consecutive test failures
- A prompt starts producing inconsistent results

## Quick Troubleshooting

### "AI keeps generating the same wrong thing"

```bash
octon retry --model claude-sonnet  # Try different model
octon retry --context "do not use X, instead use Y"
```

### "AI output looks suspicious"

```bash
octon verify-imports  # Check all imports are real
octon check --guardrails  # Run full check
octon explain "explain your reasoning"
```

### "Tests are failing on AI output"

```bash
octon status  # Check what's failing
octon retry --constraint "ensure all tests pass"
```

### "AI refuses to generate something"

This is usually a safety feature. If it's legitimate:

```bash
octon retry --context "this is for internal testing purposes, not malicious"
```

## Summary Checklist

Before approving any AI output:

- [ ] No unknown package imports?
- [ ] No suspicious helper/util imports?
- [ ] No TODO/placeholder comments?
- [ ] Proper error handling present?
- [ ] No hardcoded secrets or URLs?
- [ ] Scope matches what you asked for?
- [ ] Tests are included and passing?

When in doubt: **Ask the AI to explain**, or **regenerate with stricter constraints**.

---

## Technical Reference

For developers who want to understand the implementation:

| Component | Location | Description |
|-----------|----------|-------------|
| Guard Service Contract | `.octon/capabilities/runtime/services/governance/guard/SERVICE.md` | Canonical service metadata and policy |
| Guard Runtime | `.octon/capabilities/runtime/services/governance/guard/impl/guard.sh` | Shell implementation for check/sanitize |
| Guard Rules | `.octon/capabilities/runtime/services/governance/guard/rules/rules.yml` | Declarative enforcement rules |
| Guard Fixtures | `.octon/capabilities/runtime/services/governance/guard/fixtures/` | Positive/negative/edge behavior anchors |

See also:
- `.octon/capabilities/runtime/services/governance/guard/guide.md`
- `.octon/capabilities/runtime/services/governance/guard/references/patterns.md`

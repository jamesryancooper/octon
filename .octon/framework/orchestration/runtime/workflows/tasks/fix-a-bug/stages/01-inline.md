
# Task: Fix a Bug

This guide walks you through fixing a bug using Octon's AI-assisted workflow.

---

## Quick Version

```bash
octon fix "#423"              # Start from issue number
# or
octon fix "login button broken on mobile"  # Start from description

# AI generates spec, writes fix, creates PR
# You review the summary and approve
```

**Your time: 5-10 minutes for a typical bug**

Before broad verification or repo-consequential test execution, run
`/repo-consequential-preflight` and stop if branch freshness or repo-shell
policy posture routes to warn, block, or escalate.

---

## Step-by-Step

### 1. Start the Fix

**Option A: From an issue**
```bash
octon fix "#423"
```

**Option B: From a description**
```bash
octon fix "error message shows wrong text when payment fails"
```

**Option C: From an error you're seeing**
```bash
octon fix "TypeError: Cannot read property 'email' of undefined in UserService"
```

### 2. AI Generates a Spec

AI analyzes the bug and creates a minimal spec:

```
Analyzing bug...

Bug Analysis:
- Location: src/components/PaymentForm.tsx:142
- Root cause: Missing null check on user object
- Impact: Users see crash instead of error message

Proposed fix:
- Add null check before accessing user.email
- Show friendly error message if user is null

Tier: T1 (trivial fix, no logic change)

Proceed with fix? [Y/n]
```

Press Enter to continue (or `n` to modify).

### 3. AI Writes the Fix

AI generates:
- The code fix
- Updates to any affected tests
- A PR with summary

```
Writing fix...

Changes:
- Modified: src/components/PaymentForm.tsx (+3 lines)
- Modified: src/components/__tests__/PaymentForm.test.tsx (+8 lines)

Creating PR...
PR #425 created: "fix: handle null user in PaymentForm"

Tests running...
✓ All tests passing

Ready for review.
```

### 4. Review the PR

Open the PR link. You'll see:

```markdown
## T1 Summary: Fix null user crash in PaymentForm

**What**: Added null check before accessing user.email
**Root cause**: User object can be null during logout race condition
**Fix**: Return early with error message if user is null

**Tests**: Added test for null user case, all passing
**Risk**: None (defensive fix only)

**Action needed**: Approve PR
```

**Your review checklist:**
- [ ] Does the summary make sense?
- [ ] Does the fix match the bug description?
- [ ] Are tests green?

### 5. Approve and Merge

If it looks good, approve the PR. AI will:
- Merge when CI passes
- Deploy to preview automatically

For T1 bugs, that's it! No flag needed, no staged rollout.

---

## Variations

### Bug Needs More Investigation

```bash
octon fix "users reporting slow load times"
```

If AI can't pinpoint the cause:

```
I need more information to fix this.

Questions:
1. Which page is slow?
2. Is it slow for all users or specific ones?
3. When did this start?

Provide more context: 
> 
```

Answer the questions, and AI will continue.

### Bug is Bigger Than Expected

AI might determine the bug is actually T2 or T3:

```
This bug is more complex than expected.

Analysis:
- Affects authentication flow (security surface)
- Requires database query changes
- Multiple components involved

Recommended tier: T2

This will require:
- Spec review before proceeding
- Feature flag for the fix
- Preview testing

Continue as T2? [Y/n]
```

See [RISK-TIERS.md](/.octon/instance/cognition/context/shared/risk-tiers.md) for what T2 involves.

### You Disagree with AI's Fix

```bash
# See AI's reasoning
octon explain "why did you use this approach?"

# Try a different approach
octon retry --constraint "use try-catch instead of null check"

# Take over manually
octon manual "#425"
```

### Bug Can't Wait (Critical)

```bash
octon fix "critical: all API calls returning 500" --priority critical
```

This tells AI to:
- Skip normal queue
- Generate minimal fix
- Create PR immediately

---

## Tips

### Be Specific

**Less useful:**
```bash
octon fix "app is broken"
```

**More useful:**
```bash
octon fix "clicking submit on /settings crashes with TypeError"
```

### Include Error Messages

```bash
octon fix "Error: ECONNREFUSED when calling payment API"
```

AI can search logs and identify the issue faster.

### Reference the Right Issue

```bash
# If there's an existing issue
octon fix "#423"

# AI will use all context from the issue
```

---

## What AI Does (Behind the Scenes)

1. **Analyze**: Searches codebase for related code, checks recent changes, looks at error patterns
2. **Diagnose**: Identifies root cause and affected files
3. **Plan**: Generates minimal spec for the fix
4. **Implement**: Writes the fix code
5. **Test**: Updates or adds tests, runs test suite
6. **Document**: Creates PR with summary, links to issue
7. **Gate**: Runs all CI checks

---

## Time Estimates

| Bug Type | Your Time |
|----------|-----------|
| Typo/copy fix | 2 minutes |
| Simple logic fix | 5-10 minutes |
| Fix requiring investigation | 15-20 minutes |
| Complex fix (T2) | 20-30 minutes |

---

## Troubleshooting

### AI Can't Find the Bug

```bash
# Give more context
octon fix "bug description" --context "it's in the checkout flow"

# Point to specific file
octon fix "bug description" --file src/checkout/OrderSummary.tsx
```

### Fix Doesn't Work

```bash
# See what AI tried
octon explain "#425"

# Provide feedback and retry
octon retry "#425" --feedback "fix didn't handle the edge case where quantity is 0"
```

### Tests Are Failing

```bash
# See what's failing
octon diagnose "#425"

# AI will fix the tests or the code
```

---

## Next Steps

- [Add an API endpoint](./add-api-endpoint.md)
- [Run a data migration](./run-data-migration.md)
- Back to [DAILY-FLOW.md](/.octon/framework/execution-roles/practices/daily-flow.md)

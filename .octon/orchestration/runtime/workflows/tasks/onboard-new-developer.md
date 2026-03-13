---
title: "Task: Onboard a New Developer"
description: Retired onboarding workflow artifact preserved only for historical reference.
access: human
---

# Task: Onboard a New Developer

> Retired workflow artifact. This path is not discoverable or supported for new runs.
> Use `agent-led-happy-path.md` as the only canonical onboarding execution path.

## Overview

Octon includes an AI-assisted onboarding flow that guides new developers through their first tasks. This reduces onboarding from weeks to **about 15-30 minutes** of hands-on work.

---

## Quick Start

For a new developer joining the team:

```bash
# Start the guided onboarding
octon onboard start

# Or with personalization
octon onboard start --name "Alice"
```

The AI will guide them through each step.

---

## How It Works

The onboarding flow guides developers through 8 structured steps:

```
┌──────────────────────────────────────────────────────────────┐
│  ONBOARDING FLOW (~15-20 minutes total)                      │
├──────────────────────────────────────────────────────────────┤
│  1. Welcome (2m)           - Mental model overview           │
│  2. Environment Check (1m) - Verify setup                    │
│  3. First Status (1m)      - Learn `octon status`          │
│  4. Guided Bug Fix (5m)    - Complete a T1 fix               │
│  5. Guided Feature (8m)    - Add a small T1/T2 feature       │
│  6. PR Review (3m)         - How to review AI work           │
│  7. Ship (2m)              - Deploy with flags/rollback      │
│  8. Complete! (1m)         - Summary and quick reference     │
└──────────────────────────────────────────────────────────────┘
```

---

## What Each Step Teaches

| Step | What They Learn | Time |
|------|-----------------|------|
| Welcome | Mental model: you orchestrate, AI executes | 2 min |
| Environment Check | Verify setup is correct | 1 min |
| First Status | Using `octon status` to check progress | 1 min |
| Guided Bug Fix | Complete a T1 fix with AI assistance | 5 min |
| Guided Feature | Add a small feature (T1 or T2) | 8 min |
| PR Review | How to review AI-generated PRs | 3 min |
| Ship | Deploy with flags and rollback | 2 min |

**Total: ~20-30 minutes**

---

## Onboarding Commands

| Command | Description |
|---------|-------------|
| `octon onboard` | Show status or start onboarding |
| `octon onboard start` | Begin (or resume) onboarding |
| `octon onboard status` | Show current progress |
| `octon onboard next` | Advance to the next step |
| `octon onboard fix "desc"` | Start a guided bug fix |
| `octon onboard feature "desc"` | Start a guided feature |
| `octon onboard build` | Build the current task |
| `octon onboard approve` | Approve and continue |
| `octon onboard skip` | Skip the current step |
| `octon onboard reset` | Start fresh |

---

## For the Existing Team

When onboarding a new developer:

1. **Ensure their environment is set up:**
   - Node.js 20+
   - Git access to the repo
   - Vercel CLI (if doing deployments)

2. **Point them to the onboarding command:**
   ```bash
   octon onboard start --name "New Dev Name"
   ```

3. **Be available for questions**, but let AI guide them through mechanics

4. **After onboarding:**
   - Review their first few T1/T2 PRs together
   - Pair on their first T3 task
   - Answer any conceptual questions

---

## Recommended First Week Schedule

| Day | Focus | Commands to Know |
|-----|-------|------------------|
| 1 | Complete onboarding flow | `octon onboard`, `status`, `build` |
| 2 | Do 2-3 T1 fixes solo | `octon fix`, `build`, `ship` |
| 3 | Do 1 T2 feature with pair | `octon feature`, `explain` |
| 4 | Shadow a T3 review | `octon explain` |
| 5 | Solo T2, retro | `octon retry`, `rollback` |

---

## If Onboarding Gets Stuck

If someone gets stuck during onboarding:

```bash
# See what step they're on
octon onboard status

# Skip a problematic step
octon onboard skip

# Start completely fresh
octon onboard reset
```

Common issues:
- **Environment check fails**: Ensure package.json exists and git is initialized
- **Build fails**: Try `octon retry --constraint "keep it simple"`
- **Confused about a step**: `octon explain "what should I do here?"`

---

## Customizing Onboarding

The onboarding flow can be customized by modifying:

- **Candidates**: `findOnboardingCandidates()` in `orchestrator/onboarding.ts`
- **Steps**: `DEFAULT_STEPS` array in the same file
- **Guidance text**: Update the `guidance` field in each step

For project-specific onboarding tasks, consider:
- Creating issues labeled `good-first-issue` or `onboarding`
- Adding project-specific candidates to the candidate finder
- Customizing guidance text to reference your specific codebase

---

## Success Metrics

After onboarding, a developer should:

- [ ] Know how to start fixes and features
- [ ] Understand the T1/T2/T3 tier system
- [ ] Be able to review AI summaries effectively
- [ ] Know how to ship with feature flags
- [ ] Know how to rollback if needed
- [ ] Feel confident working independently on T1/T2 tasks

---

## Related Documentation

- [START-HERE.md](/.octon/agency/practices/start-here.md) - The reference doc developers use daily
- [DAILY-FLOW.md](/.octon/agency/practices/daily-flow.md) - How a typical day looks
- [RISK-TIERS.md](/.octon/cognition/runtime/context/risk-tiers.md) - Understanding T1/T2/T3
- [fix-a-bug.md](./fix-a-bug.md) - Detailed bug fix workflow

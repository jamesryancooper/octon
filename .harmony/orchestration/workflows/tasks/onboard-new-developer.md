---
title: "Task: Onboard a New Developer"
description: Step-by-step guide to onboarding a new developer with Harmony's guided workflow.
access: human
---

# Task: Onboard a New Developer

## Overview

Harmony includes an AI-assisted onboarding flow that guides new developers through their first tasks. This reduces onboarding from weeks to **about 15-30 minutes** of hands-on work.

---

## Quick Start

For a new developer joining the team:

```bash
# Start the guided onboarding
harmony onboard start

# Or with personalization
harmony onboard start --name "Alice"
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
│  3. First Status (1m)      - Learn `harmony status`          │
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
| First Status | Using `harmony status` to check progress | 1 min |
| Guided Bug Fix | Complete a T1 fix with AI assistance | 5 min |
| Guided Feature | Add a small feature (T1 or T2) | 8 min |
| PR Review | How to review AI-generated PRs | 3 min |
| Ship | Deploy with flags and rollback | 2 min |

**Total: ~20-30 minutes**

---

## Onboarding Commands

| Command | Description |
|---------|-------------|
| `harmony onboard` | Show status or start onboarding |
| `harmony onboard start` | Begin (or resume) onboarding |
| `harmony onboard status` | Show current progress |
| `harmony onboard next` | Advance to the next step |
| `harmony onboard fix "desc"` | Start a guided bug fix |
| `harmony onboard feature "desc"` | Start a guided feature |
| `harmony onboard build` | Build the current task |
| `harmony onboard approve` | Approve and continue |
| `harmony onboard skip` | Skip the current step |
| `harmony onboard reset` | Start fresh |

---

## For the Existing Team

When onboarding a new developer:

1. **Ensure their environment is set up:**
   - Node.js 20+
   - Git access to the repo
   - Vercel CLI (if doing deployments)

2. **Point them to the onboarding command:**
   ```bash
   harmony onboard start --name "New Dev Name"
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
| 1 | Complete onboarding flow | `harmony onboard`, `status`, `build` |
| 2 | Do 2-3 T1 fixes solo | `harmony fix`, `build`, `ship` |
| 3 | Do 1 T2 feature with pair | `harmony feature`, `explain` |
| 4 | Shadow a T3 review | `harmony explain` |
| 5 | Solo T2, retro | `harmony retry`, `rollback` |

---

## If Onboarding Gets Stuck

If someone gets stuck during onboarding:

```bash
# See what step they're on
harmony onboard status

# Skip a problematic step
harmony onboard skip

# Start completely fresh
harmony onboard reset
```

Common issues:
- **Environment check fails**: Ensure package.json exists and git is initialized
- **Build fails**: Try `harmony retry --constraint "keep it simple"`
- **Confused about a step**: `harmony explain "what should I do here?"`

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

- [START-HERE.md](/.harmony/agency/practices/start-here.md) - The reference doc developers use daily
- [DAILY-FLOW.md](/.harmony/agency/practices/daily-flow.md) - How a typical day looks
- [RISK-TIERS.md](/.harmony/cognition/context/risk-tiers.md) - Understanding T1/T2/T3
- [fix-a-bug.md](./fix-a-bug.md) - Detailed bug fix workflow

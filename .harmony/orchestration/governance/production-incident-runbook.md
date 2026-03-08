---
title: Production Incident Runbook
description: Product-specific operational response guide for production outages and regressions. Rollback first, investigate second.
---

# Production Incident Runbook

When something goes wrong in production, follow this runbook. The golden rule:
**Rollback first, investigate second.**

Use `incidents.md` for generic Harmony incident governance. Use this file for
product-specific operational response steps.

## Incident Response Flowchart

```text
┌─────────────────────────────────────────────────────────────────┐
│  SOMETHING IS WRONG IN PRODUCTION                               │
│                                                                 │
│  1. Is it caused by a recent deploy?                            │
│     └─ YES → Rollback immediately (30 sec fix)                  │
│     └─ MAYBE → Rollback anyway, investigate after               │
│     └─ NO → Continue to step 2                                  │
│                                                                 │
│  2. Is it caused by a feature flag?                             │
│     └─ YES → Disable the flag (instant fix)                     │
│     └─ NO → Continue to step 3                                  │
│                                                                 │
│  3. Is it an external service issue?                            │
│     └─ YES → Enable fallback/degraded mode if available         │
│     └─ NO → Investigate and hotfix                              │
│                                                                 │
│  4. After stabilization                                         │
│     └─ Write postmortem (AI helps)                              │
│     └─ Fix the root cause                                       │
│     └─ Re-deploy with fix                                       │
└─────────────────────────────────────────────────────────────────┘
```

## Quick Commands

| Situation | Command |
|-----------|---------|
| Start incident tracking | `harmony incident start` |
| Rollback deployment | `vercel promote <previous-url>` |
| Disable a feature | `harmony flag disable <flag>` |
| Check what changed recently | `harmony changes --recent` |
| Get AI analysis | `harmony investigate "description"` |
| End incident | `harmony incident resolve` |

## Step 1: Rollback (If Recent Deploy)

**Time target: Under 2 minutes**

### Check if recent deploy caused it

```bash
# When was the last deploy?
vercel ls --limit 3

# What changed in that deploy?
harmony changes --since <timestamp>
```

### Perform rollback

```bash
# Get the previous deployment URL
vercel ls

# Promote the previous deployment (instant rollback)
vercel promote <previous-deployment-url>

# Verify rollback succeeded
harmony status --production
```

If there is any chance the recent deploy caused the issue, rollback first. You
can always re-deploy later after the root cause is understood.

## Step 2: Disable Feature Flag (If Flag-Related)

**Time target: Under 1 minute**

```bash
# Disable the flag
harmony flag disable <flag-name>

# Verify it's disabled
harmony flag status <flag-name>
```

## Step 3: Investigate

Only investigate deeply after production is stable.

### Let AI help

```bash
harmony investigate "users getting 500 errors on checkout"
```

### Manual investigation

```bash
# Check recent errors
harmony logs --production --errors --since "30 min ago"

# Check specific service
harmony logs --production --service checkout

# Check external services
harmony health --external
```

## Step 4: Communicate

If users are affected:

1. acknowledge the issue
2. provide regular updates
3. announce resolution when stable

Team communication examples:

```bash
harmony incident notify "Checkout 500s - investigating"
harmony incident update "Rolled back, monitoring"
harmony incident resolve "Root cause: null pointer in UserService"
```

## Step 5: Fix And Re-Deploy

```bash
# Start a hotfix
harmony fix "checkout 500 error" --priority critical

# Ship the fix
harmony ship checkout-fix

# Enable gradually
harmony flag enable checkout-fix --scope internal
harmony flag enable checkout-fix
```

## Step 6: Postmortem

Required for incidents that materially affect users.

```bash
harmony postmortem create
```

AI can draft:

- timeline
- suspected root cause
- contributing factors
- remediation actions
- follow-up work

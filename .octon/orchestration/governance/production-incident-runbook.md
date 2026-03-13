---
title: Production Incident Runbook
description: Product-specific operational response guide for production outages and regressions. Rollback first, investigate second.
---

# Production Incident Runbook

When something goes wrong in production, follow this runbook. The golden rule:
**Rollback first, investigate second.**

Use `incidents.md` for generic Octon incident governance. Use this file for
product-specific operational response steps.

For orchestration-specific lookup, closure readiness, and failure handling,
also use:

- `/.octon/orchestration/practices/operator-lookup-and-triage.md`
- `/.octon/orchestration/practices/orchestration-failure-playbooks.md`

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
| Start incident tracking | `octon incident start` |
| Rollback deployment | `vercel promote <previous-url>` |
| Disable a feature | `octon flag disable <flag>` |
| Check what changed recently | `octon changes --recent` |
| Get AI analysis | `octon investigate "description"` |
| End incident | `octon incident resolve` |
| Orchestration lookup | `octon orchestration lookup --incident-id <id>` |
| Closure readiness | `octon orchestration incident closure-readiness --incident-id <id>` |
| Ops snapshot | `octon orchestration summary --surface all` |

## Step 1: Rollback (If Recent Deploy)

**Time target: Under 2 minutes**

### Check if recent deploy caused it

```bash
# When was the last deploy?
vercel ls --limit 3

# What changed in that deploy?
octon changes --since <timestamp>
```

### Perform rollback

```bash
# Get the previous deployment URL
vercel ls

# Promote the previous deployment (instant rollback)
vercel promote <previous-deployment-url>

# Verify rollback succeeded
octon status --production
```

If there is any chance the recent deploy caused the issue, rollback first. You
can always re-deploy later after the root cause is understood.

## Step 2: Disable Feature Flag (If Flag-Related)

**Time target: Under 1 minute**

```bash
# Disable the flag
octon flag disable <flag-name>

# Verify it's disabled
octon flag status <flag-name>
```

## Step 3: Investigate

Only investigate deeply after production is stable.

### Let AI help

```bash
octon investigate "users getting 500 errors on checkout"
```

### Manual investigation

```bash
# Check recent errors
octon logs --production --errors --since "30 min ago"

# Check specific service
octon logs --production --service checkout

# Check external services
octon health --external
```

### Orchestration-specific investigation

If the issue touches watcher, queue, automation, run, or incident lineage:

```bash
# Get an orchestration-wide snapshot
octon orchestration summary --surface all

# Follow the incident or run lineage
octon orchestration lookup --incident-id <incident-id>
octon orchestration lookup --run-id <run-id>
```

Use the scenario-specific response playbooks in
`/.octon/orchestration/practices/orchestration-failure-playbooks.md` once the
failure class is known.

## Step 4: Communicate

If users are affected:

1. acknowledge the issue
2. provide regular updates
3. announce resolution when stable

Team communication examples:

```bash
octon incident notify "Checkout 500s - investigating"
octon incident update "Rolled back, monitoring"
octon incident resolve "Root cause: null pointer in UserService"
```

## Step 5: Fix And Re-Deploy

```bash
# Start a hotfix
octon fix "checkout 500 error" --priority critical

# Ship the fix
octon ship checkout-fix

# Enable gradually
octon flag enable checkout-fix --scope internal
octon flag enable checkout-fix
```

## Step 6: Postmortem

Required for incidents that materially affect users.

```bash
octon postmortem create
```

AI can draft:

- timeline
- suspected root cause
- contributing factors
- remediation actions
- follow-up work

## Step 7: Closure Readiness

Before a human closes an orchestration-linked incident, run:

```bash
octon orchestration incident closure-readiness --incident-id <incident-id>
```

If the readiness check reports blockers, do not close the incident until the
missing evidence is linked or explicitly waived under policy.

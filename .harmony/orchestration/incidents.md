---
title: Incidents
description: What to do when production breaks. Rollback first, investigate second.
---

# Incidents

When something goes wrong in production, follow this guide. The golden rule: **Rollback first, investigate second.**

---

## Incident Response Flowchart

```
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

---

## Quick Commands

| Situation | Command |
|-----------|---------|
| Start incident tracking | `harmony incident start` |
| Rollback deployment | `vercel promote <previous-url>` |
| Disable a feature | `harmony flag disable <flag>` |
| Check what changed recently | `harmony changes --recent` |
| Get AI analysis | `harmony investigate "description"` |
| End incident | `harmony incident resolve` |

---

## Step 1: Rollback (If Recent Deploy)

**Time target: Under 2 minutes**

### Check if Recent Deploy Caused It

```bash
# When was the last deploy?
vercel ls --limit 3

# What changed in that deploy?
harmony changes --since <timestamp>
```

### Perform Rollback

```bash
# Get the previous deployment URL
vercel ls

# Promote the previous deployment (instant rollback)
vercel promote <previous-deployment-url>

# Verify rollback succeeded
harmony status --production
```

**Don't wait to be sure.** If there's any chance the recent deploy caused it, rollback. You can always re-deploy later.

---

## Step 2: Disable Feature Flag (If Flag-Related)

**Time target: Under 1 minute**

If the issue is related to a specific feature:

```bash
# Disable the flag
harmony flag disable <flag-name>

# Verify it's disabled
harmony flag status <flag-name>
```

This is faster than rollback if you know which feature is causing the problem.

---

## Step 3: Investigate

**Only after you've stabilized production**

### Let AI Help

```bash
harmony investigate "users getting 500 errors on checkout"
```

AI will:
- Check recent deployments and changes
- Analyze error logs
- Check external service status
- Look for patterns

**Example output:**
```
┌─ Investigation: 500 errors on checkout ─────────────────────┐
│                                                              │
│ Timeline:                                                    │
│   15:32 - Deploy #142 (user-profiles feature)                │
│   15:35 - Error rate started increasing                      │
│   15:38 - First user report                                  │
│                                                              │
│ Likely cause: Deploy #142                                    │
│ Confidence: 85%                                              │
│                                                              │
│ Evidence:                                                    │
│   - Error spike correlates with deploy time                  │
│   - Errors are in UserService (touched in #142)              │
│   - No external service issues detected                      │
│                                                              │
│ Recommended action: Rollback to #141                         │
│                                                              │
│ [Rollback Now] [More Details] [Ignore]                       │
└──────────────────────────────────────────────────────────────┘
```

### Manual Investigation

If AI can't find the cause:

```bash
# Check recent errors
harmony logs --production --errors --since "30 min ago"

# Check specific service
harmony logs --production --service checkout

# Check external services
harmony health --external
```

---

## Step 4: Communicate

### If It's Affecting Users

1. **Acknowledge** — Let users know you're aware (if you have a status page)
2. **Update** — Post updates every 15-30 minutes
3. **Resolve** — Announce when fixed

### Between Team Members

```bash
# Start incident channel (if using Slack/Discord integration)
harmony incident notify "Checkout 500s - investigating"

# Update
harmony incident update "Rolled back, monitoring"

# Resolve
harmony incident resolve "Root cause: null pointer in UserService"
```

---

## Step 5: Fix and Re-Deploy

After stabilizing:

### Create the Fix

```bash
# Start a hotfix
harmony fix "checkout 500 error" --priority critical

# AI will generate a fix based on investigation
# Review and approve the fix PR
```

### Re-Deploy Carefully

```bash
# Ship the fix
harmony ship checkout-fix

# Enable gradually (even for fixes)
harmony flag enable checkout-fix --scope internal

# Verify fix works
# Then full enable
harmony flag enable checkout-fix
```

---

## Step 6: Postmortem

**Required for any incident affecting users. AI helps write it.**

```bash
harmony postmortem create
```

AI generates a draft postmortem with:
- Timeline (from logs and events)
- Root cause analysis
- Impact assessment
- Action items

### Postmortem Template

```markdown
# Incident: [Brief Description]

## Summary
One paragraph describing what happened.

## Timeline
- HH:MM - First symptom detected
- HH:MM - Alert triggered / User reported
- HH:MM - Investigation started
- HH:MM - Root cause identified
- HH:MM - Mitigation applied (rollback/flag disable)
- HH:MM - Issue resolved
- HH:MM - Post-incident verification

## Impact
- Duration: X minutes
- Users affected: ~N
- Revenue impact: $X (if applicable)

## Root Cause
What actually caused the issue.

## What Went Well
- Quick detection
- Fast rollback
- etc.

## What Could Be Improved
- Missing test coverage for this case
- Alert could have triggered sooner
- etc.

## Action Items
- [ ] Add test for null case (@owner, due date)
- [ ] Improve alert threshold (@owner, due date)
- [ ] Update runbook (@owner, due date)
```

---

## Severity Levels

| Level | Definition | Response |
|-------|------------|----------|
| **Sev-1** | Production down, all users affected | Both devs engage, rollback immediately, postmortem required |
| **Sev-2** | Significant degradation, many users affected | Primary on-call responds, rollback or hotfix, postmortem if > 15 min |
| **Sev-3** | Minor issue, workaround available | Fix in normal flow, no postmortem needed |

### Sev-1 Response

```bash
# Immediately
vercel promote <previous-url>

# Start tracking
harmony incident start --severity 1

# Notify
harmony incident notify "SEV-1: Production down, rolling back"

# Both devs engage
# One focuses on mitigation
# One focuses on investigation
```

### Sev-2 Response

```bash
# Quick assessment
harmony investigate "brief description"

# Mitigate
harmony flag disable <flag-name>  # or rollback

# Fix when stable
harmony fix "description" --priority high
```

### Sev-3 Response

```bash
# Log the issue
harmony fix "description"

# Fix in normal flow
# No emergency response needed
```

---

## Common Incidents and Responses

### 500 Errors Spiking

```bash
# Quick check
harmony investigate "500 error spike"

# If recent deploy
vercel promote <previous-url>

# If specific feature
harmony flag disable <flag-name>
```

### Slow Response Times

```bash
# Check what's slow
harmony investigate "slow responses"

# If it's a specific endpoint
harmony flag disable <flag-name>  # if behind flag

# If it's database
# Check query logs, consider read replica, add caching
```

### External Service Down

```bash
# Check external services
harmony health --external

# Enable fallback mode if available
harmony flag enable ops.fallback-mode

# Wait for external service to recover
```

### Memory/CPU Issues

```bash
# Check resources
harmony health --resources

# If caused by recent deploy, rollback
vercel promote <previous-url>

# If gradual, investigate and scale
```

---

## Incident Checklist

### During Incident

```
□ Acknowledge the incident
□ Assess severity (Sev-1/2/3)
□ Mitigate (rollback or disable flag)
□ Communicate status
□ Investigate root cause
□ Apply fix
□ Verify fix works
□ Update communication
□ Close incident
```

### After Incident

```
□ Write postmortem (within 48 hours)
□ Create action items
□ Share learnings with team
□ Update runbooks if needed
□ Close action items (within 2 weeks)
```

---

## On-Call Rotation

For a 2-dev team:

| Week | Primary | Backup |
|------|---------|--------|
| Odd weeks | Dev A | Dev B |
| Even weeks | Dev B | Dev A |

**On-call expectations:**
- Respond to Sev-1/2 alerts within 15 minutes during work hours
- After hours: Sev-1 only, within 30 minutes
- No expectation to fix complex issues alone — escalate to backup

**Sustainable on-call:**
- No heroics. Rollback and hand off if needed.
- Postmortem is about learning, not blame.
- After an incident, next focus block is protected for recovery.

---

## Alert Configuration

AI monitors these automatically:

| Metric | Alert Threshold | Severity |
|--------|-----------------|----------|
| Error rate (5xx) | > 1% | Sev-2 |
| Error rate (5xx) | > 5% | Sev-1 |
| p95 latency | > 500ms | Sev-2 |
| p95 latency | > 2000ms | Sev-1 |
| Error budget burn | > 2x normal | Sev-2 |
| Error budget burn | > 5x normal | Sev-1 |
| External service | Down | Sev-2 |

---

## Full Documentation

For detailed incident response procedures and SRE practices:

- **Reliability & Ops**: [methodology/reliability-and-ops.md](methodology/reliability-and-ops.md)
- **Security Baseline**: [methodology/security-baseline.md](methodology/security-baseline.md)
- **Postmortem Template**: [methodology/reliability-and-ops.md#blameless-postmortem-template](methodology/reliability-and-ops.md#blameless-postmortem-template)


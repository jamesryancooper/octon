---
title: Shipping
description: How to ship features to production, manage feature flags, and rollback when needed.
---

# Shipping

This guide covers how to ship features to production safely. Harmony uses **preview deployments**, **feature flags**, and **instant rollback** to make shipping fast and safe.

---

## The Shipping Model

```
┌─────────────────────────────────────────────────────────────────┐
│  PR Created                                                     │
│    ↓                                                            │
│  Preview Deployed (automatic)                                   │
│    ↓                                                            │
│  PR Approved & Merged                                           │
│    ↓                                                            │
│  Trunk Preview Updated (automatic)                              │
│    ↓                                                            │
│  Manual Promote to Production   ← You control this              │
│    ↓                                                            │
│  Feature Flag Controls Access   ← Gradual rollout               │
└─────────────────────────────────────────────────────────────────┘
```

**Key principle:** Features ship to production behind flags (OFF by default). You enable them when ready.

---

## Quick Reference

| I want to... | Command |
|--------------|---------|
| See what's ready to ship | `harmony ship --list` |
| Ship a specific feature | `harmony ship <feature-name>` |
| Promote preview to prod | `vercel promote <preview-url>` |
| Rollback immediately | `vercel promote <previous-url>` |
| Check production status | `harmony status --production` |
| Enable a feature flag | `harmony flag enable <flag-name>` |
| Disable a feature flag | `harmony flag disable <flag-name>` |

---

## Shipping a Feature

### Step 1: Confirm PR is Merged

The PR must be:
- ✅ Approved by required reviewers
- ✅ All CI gates passing
- ✅ Merged to trunk (main)

```bash
# Check what's ready
harmony ship --list
```

### Step 2: Verify Trunk Preview

After merge, your code deploys to the trunk preview automatically.

```bash
# Get the trunk preview URL
harmony preview trunk

# Or check Vercel dashboard
```

**Quick verification:**
- Does the feature work as expected?
- No console errors?
- Key flows still working?

### Step 3: Promote to Production

```bash
# Via Harmony
harmony ship <feature-name>

# Or directly via Vercel
vercel promote <trunk-preview-url>
```

**What happens:**
1. The preview becomes the new production deployment
2. Your feature is now in production (but behind a flag)
3. Previous deployment becomes the rollback target

### Step 4: Enable the Feature Flag

New features ship with flags OFF by default.

```bash
# Enable for yourself first
harmony flag enable <flag-name> --scope internal

# Enable for a percentage
harmony flag enable <flag-name> --percent 10

# Enable for everyone
harmony flag enable <flag-name>
```

**Recommended rollout:**
1. Internal users only (you and team)
2. 10% of users
3. 50% of users
4. 100% of users

Wait at least 15-30 minutes between stages. Watch for errors.

---

## Rollback

### Instant Rollback

If something goes wrong after promotion:

```bash
# Immediate rollback
vercel promote <previous-deployment-url>
```

This takes ~30 seconds. The previous deployment becomes active.

### Where to Find the Previous URL

```bash
# List recent deployments
vercel ls

# Or via Harmony
harmony deployments --recent 5
```

### Rollback via Feature Flag

If the problem is isolated to a specific feature:

```bash
# Disable the feature flag (faster than redeploying)
harmony flag disable <flag-name>
```

This takes effect immediately without redeployment.

### When to Rollback

Rollback immediately if you see:
- 🚨 Error rate spike (> 1% 5xx errors)
- 🚨 SLO burn rate alert
- 🚨 User reports of broken functionality
- 🚨 Security alert

**Don't wait to investigate.** Rollback first, then figure out what went wrong.

---

## Feature Flags

### How Flags Work

Every T2/T3 feature ships with a flag. The flag determines who sees the feature.

```typescript
// In code (AI handles this)
if (await isEnabled('feature.user-profiles')) {
  // New feature code
} else {
  // Old behavior or nothing
}
```

### Flag Naming Convention

```
feature.<feature-name>    # For features
experiment.<name>         # For A/B tests
rollout.<name>            # For gradual migrations
ops.<name>                # For operational toggles
```

### Managing Flags

```bash
# List all flags
harmony flags list

# Check flag status
harmony flag status feature.user-profiles

# Enable/disable
harmony flag enable feature.user-profiles
harmony flag disable feature.user-profiles

# Enable for percentage
harmony flag enable feature.user-profiles --percent 25

# Enable for specific users/orgs
harmony flag enable feature.user-profiles --users user1,user2
```

### Flag Cleanup

Flags should be short-lived. AI reminds you to clean up old flags.

```bash
# See stale flags (> 2 weeks since enabled for all)
harmony flags stale

# Remove a flag (after verifying feature is stable)
harmony flag remove feature.user-profiles
```

---

## The Promote/Rollback Workflow

### Normal Ship

```
1. PR merged → Trunk preview updated
2. harmony ship feature-name (or vercel promote)
3. Feature in production, flag OFF
4. harmony flag enable feature-name --scope internal
5. Test manually
6. harmony flag enable feature-name --percent 10
7. Monitor for 30 min
8. harmony flag enable feature-name
9. Done! Clean up flag in 1-2 weeks
```

### Ship with Issues

```
1. PR merged → Trunk preview updated
2. vercel promote <preview-url>
3. Feature in production, flag OFF
4. harmony flag enable feature-name --scope internal
5. Find a bug during internal testing
6. harmony flag disable feature-name  ← Stop here
7. Fix the bug with a new PR
8. Re-promote, re-enable flag
```

### Emergency Rollback

```
1. Feature in production, flag ON
2. Error spike detected
3. Option A: harmony flag disable feature-name  ← If feature-specific
4. Option B: vercel promote <previous-url>  ← If broader issue
5. Investigate
6. Fix and re-ship
```

---

## Shipping Tiers

Different tiers have different shipping requirements:

| Tier | Flag Required | Rollout Steps | Watch Window |
|------|---------------|---------------|--------------|
| T1 | Optional | Ship directly | None |
| T2 | Yes | Internal → % → All | None required |
| T3 | Yes | Internal → 10% → 50% → All | 30 min per stage |

### T1 Shipping

Simple changes can go directly to production:

```bash
# T1 doesn't require a flag
harmony ship typo-fix
```

### T2 Shipping

Standard features go through flag rollout:

```bash
harmony ship user-profiles
harmony flag enable feature.user-profiles --scope internal
# Test...
harmony flag enable feature.user-profiles --percent 25
# Wait 15 min, check metrics...
harmony flag enable feature.user-profiles
```

### T3 Shipping

High-risk changes require staged rollout with watch windows:

```bash
harmony ship oauth-integration

# Stage 1: Internal only
harmony flag enable auth.google-oauth --scope internal
# Wait 30 min, verify manually

# Stage 2: Small percentage
harmony flag enable auth.google-oauth --percent 10
# Wait 30 min, monitor dashboards

# Stage 3: Half
harmony flag enable auth.google-oauth --percent 50
# Wait 30 min, monitor dashboards

# Stage 4: Everyone
harmony flag enable auth.google-oauth
```

---

## Monitoring After Ship

### What to Watch

After promoting to production, monitor:

| Metric | Where to Check | Alert Threshold |
|--------|----------------|-----------------|
| Error rate | Dashboard / `harmony status` | > 0.5% |
| Latency (p95) | Dashboard | > 300ms |
| Error budget | `harmony slo status` | Burn rate > 2x |

### Automated Alerts

AI monitors these metrics and will alert you:

```
⚠️ Error rate increased from 0.1% to 0.8% after deploy
   Recommendation: Rollback or disable feature.user-profiles
   
   [Rollback] [Disable Flag] [Investigate]
```

### Post-Deploy Checklist

```
□ Promotion successful
□ Feature flag enabled for internal
□ Manual test passed
□ No error spike in first 5 min
□ Gradual rollout to percentage
□ No errors during rollout
□ Full enable
□ Stable for 1 hour
□ Flag cleanup scheduled
```

---

## Troubleshooting

### Promotion Failed

```bash
# Check Vercel status
vercel ls --failed

# Check what went wrong
harmony investigate "promotion failed"
```

Common causes:
- Build error in trunk
- Environment variable missing
- Dependency issue

### Feature Not Working After Ship

1. **Check the flag is enabled**
   ```bash
   harmony flag status feature.user-profiles
   ```

2. **Check you're in the rollout**
   ```bash
   harmony flag check feature.user-profiles --user <your-id>
   ```

3. **Check for errors**
   ```bash
   harmony logs --production --errors
   ```

### Rollback Not Working

```bash
# Get the exact previous URL
vercel ls

# Force promote with confirmation
vercel promote <url> --yes
```

If Vercel is having issues, disable feature flags as a faster alternative.

---

## Best Practices

### Do

- ✅ Always test in preview before promoting
- ✅ Start with internal/small % rollouts
- ✅ Monitor metrics after each rollout stage
- ✅ Have the rollback URL ready before promoting
- ✅ Clean up flags within 2 weeks of full rollout

### Don't

- ❌ Skip the preview verification
- ❌ Go straight to 100% on T3 features
- ❌ Leave flags enabled indefinitely
- ❌ Investigate before rolling back (rollback first!)
- ❌ Ship on Friday afternoon

---

## Full Documentation

For detailed deployment configuration and advanced topics:

- **Architecture**: [../ai/methodology/architecture-and-repo-structure.md](../ai/methodology/architecture-and-repo-structure.md)
- **CI/CD Gates**: [../ai/methodology/ci-cd-quality-gates.md](../ai/methodology/ci-cd-quality-gates.md)
- **Sandbox Flow**: [../ai/methodology/sandbox-flow.md](../ai/methodology/sandbox-flow.md)


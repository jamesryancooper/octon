---
title: Shipping
description: How to ship features to production, manage feature flags, and rollback when needed.
---

# Shipping

This guide covers how to ship features to production safely. Octon uses **preview deployments**, **feature flags**, and **instant rollback** to make shipping fast and safe.

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
| See what's ready to ship | `octon ship --list` |
| Ship a specific feature | `octon ship <feature-name>` |
| Promote preview to prod | `octon ship <feature-name>` or `<deploy-cli> promote <preview-url>` |
| Rollback immediately | `octon rollback` or `<deploy-cli> rollback <deployment-id>` |
| Check production status | `octon status --production` |
| Enable a feature flag | `octon flag enable <flag-name>` |
| Disable a feature flag | `octon flag disable <flag-name>` |

---

## Shipping a Feature

### Step 1: Confirm PR is Merged

The PR must be:
- ✅ Approved by required reviewers
- ✅ All CI gates passing
- ✅ Merged to trunk (main)

```bash
# Check what's ready
octon ship --list
```

### Step 2: Verify Trunk Preview

After merge, your code deploys to the trunk preview automatically.

```bash
# Get the trunk preview URL
octon preview trunk

# Or check your deployment platform dashboard
```

**Quick verification:**
- Does the feature work as expected?
- No console errors?
- Key flows still working?

### Step 3: Promote to Production

```bash
# Via Octon
octon ship <feature-name>

# Or directly via your deployment platform
<deploy-cli> promote <trunk-preview-url>
```

**What happens:**
1. The preview becomes the new production deployment
2. Your feature is now in production (but behind a flag)
3. Previous deployment becomes the rollback target

### Step 4: Enable the Feature Flag

New features ship with flags OFF by default.

```bash
# Enable for yourself first
octon flag enable <flag-name> --scope internal

# Enable for a percentage
octon flag enable <flag-name> --percent 10

# Enable for everyone
octon flag enable <flag-name>
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
<deploy-cli> rollback <previous-deployment-id>
```

Treat rollback as urgent. Execute it first, then investigate root cause.

### Where to Find the Previous URL

```bash
# List recent deployments
<deploy-cli> list-deployments

# Or via Octon
octon deployments --recent 5
```

### Rollback via Feature Flag

If the problem is isolated to a specific feature:

```bash
# Disable the feature flag (faster than redeploying)
octon flag disable <flag-name>
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

```text
# Pseudocode (AI handles language-specific implementation)
if feature_flag_enabled("feature.user-profiles"):
  run new behavior
else:
  run existing behavior
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
octon flags list

# Check flag status
octon flag status feature.user-profiles

# Enable/disable
octon flag enable feature.user-profiles
octon flag disable feature.user-profiles

# Enable for percentage
octon flag enable feature.user-profiles --percent 25

# Enable for specific users/orgs
octon flag enable feature.user-profiles --users user1,user2
```

### Flag Cleanup

Flags should be short-lived. AI reminds you to clean up old flags.

```bash
# See stale flags (> 2 weeks since enabled for all)
octon flags stale

# Remove a flag (after verifying feature is stable)
octon flag remove feature.user-profiles
```

---

## The Promote/Rollback Workflow

### Normal Ship

```
1. PR merged → Trunk preview updated
2. octon ship feature-name (or your platform promote command)
3. Feature in production, flag OFF
4. octon flag enable feature-name --scope internal
5. Test manually
6. octon flag enable feature-name --percent 10
7. Monitor for 30 min
8. octon flag enable feature-name
9. Done! Clean up flag in 1-2 weeks
```

### Ship with Issues

```
1. PR merged → Trunk preview updated
2. <deploy-cli> promote <preview-url>
3. Feature in production, flag OFF
4. octon flag enable feature-name --scope internal
5. Find a bug during internal testing
6. octon flag disable feature-name  ← Stop here
7. Fix the bug with a new PR
8. Re-promote, re-enable flag
```

### Emergency Rollback

```
1. Feature in production, flag ON
2. Error spike detected
3. Option A: octon flag disable feature-name  ← If feature-specific
4. Option B: <deploy-cli> rollback <previous-deployment-id>  ← If broader issue
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
octon ship typo-fix
```

### T2 Shipping

Standard features go through flag rollout:

```bash
octon ship user-profiles
octon flag enable feature.user-profiles --scope internal
# Test...
octon flag enable feature.user-profiles --percent 25
# Wait 15 min, check metrics...
octon flag enable feature.user-profiles
```

### T3 Shipping

High-risk changes require staged rollout with watch windows:

```bash
octon ship oauth-integration

# Stage 1: Internal only
octon flag enable auth.google-oauth --scope internal
# Wait 30 min, verify manually

# Stage 2: Small percentage
octon flag enable auth.google-oauth --percent 10
# Wait 30 min, monitor dashboards

# Stage 3: Half
octon flag enable auth.google-oauth --percent 50
# Wait 30 min, monitor dashboards

# Stage 4: Everyone
octon flag enable auth.google-oauth
```

---

## Monitoring After Ship

### What to Watch

After promoting to production, monitor:

| Metric | Where to Check | Alert Threshold |
|--------|----------------|-----------------|
| Error rate | Dashboard / `octon status` | > 0.5% |
| Latency (p95) | Dashboard | > 300ms |
| Error budget | `octon slo status` | Burn rate > 2x |

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
# Check deployment platform status
<deploy-cli> list-deployments --failed

# Check what went wrong
octon investigate "promotion failed"
```

Common causes:
- Build error in trunk
- Environment variable missing
- Dependency issue

### Feature Not Working After Ship

1. **Check the flag is enabled**
   ```bash
   octon flag status feature.user-profiles
   ```

2. **Check you're in the rollout**
   ```bash
   octon flag check feature.user-profiles --user <your-id>
   ```

3. **Check for errors**
   ```bash
   octon logs --production --errors
   ```

### Rollback Not Working

```bash
# Get recent deployments
<deploy-cli> list-deployments

# Execute rollback directly if needed
<deploy-cli> rollback <previous-deployment-id>
```

If your deployment platform is having issues, disable feature flags first.

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

- **Architecture**: [Architecture Overview](../../cognition/_meta/architecture/overview.md)
- **CI/CD Gates**: [CI/CD Quality Gates](../../cognition/practices/methodology/ci-cd-quality-gates.md)
- **Sandbox Flow**: [Sandbox Flow](../../cognition/practices/methodology/sandbox-flow.md)

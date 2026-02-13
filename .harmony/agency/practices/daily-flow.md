---
title: Daily Flow
description: How your day looks as a human developer orchestrating AI agents in Harmony.
---

# Daily Flow

This document describes the daily rhythm of working with Harmony. As a human developer, you orchestrate AI agents who do the bulk of the work. Your job is to direct, review, and approve.

---

## The Shape of Your Day

```
┌─────────────────────────────────────────────────────────────────┐
│  MORNING                                                        │
│  • Check status: What did AI do overnight?                      │
│  • Review and approve ready PRs                                 │
│  • Kick off new work for the day                                │
├─────────────────────────────────────────────────────────────────┤
│  MIDDAY                                                         │
│  • Review AI-generated specs and PRs as they come in            │
│  • Handle any interrupts (alerts, urgent bugs)                  │
│  • Deep work: Planning, architecture decisions, stakeholder     │
├─────────────────────────────────────────────────────────────────┤
│  AFTERNOON                                                      │
│  • Final reviews and approvals                                  │
│  • Ship completed features (promote to production)              │
│  • Queue up work for AI to continue overnight                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Morning Routine (15-30 min)

### 1. Check Status

```bash
harmony status
```

This shows you:
- PRs waiting for your review
- AI work in progress
- Any blocked items
- Alerts or issues that need attention

**Example output:**
```
┌─ Harmony Status ─────────────────────────────────────────────┐
│ PRs Ready for Review:                                        │
│   • #142 [T1] Fix typo in error message                      │
│   • #141 [T2] Add user profile endpoint                      │
│                                                              │
│ AI In Progress:                                              │
│   • oauth-integration [T3] - Building (60% complete)         │
│                                                              │
│ Alerts:                                                      │
│   • ⚠️  Error budget: 92% remaining (healthy)                │
│                                                              │
│ Blocked:                                                     │
│   • None                                                     │
└──────────────────────────────────────────────────────────────┘
```

### 2. Review and Approve PRs

For each PR waiting for review:

**T1 (Trivial):** Skim the AI summary (30 seconds), check tests are green, approve.

**T2 (Standard):** Read the spec summary (2-3 min), scan the PR changes, check preview if needed, approve.

**T3 (Elevated):** Carefully review spec and threat analysis. Check the preview thoroughly. May need discussion with other dev.

### 3. Start New Work

```bash
# Start a new feature
harmony feature "add webhook notifications for order updates"

# Fix a bug
harmony fix "#423"

# Build the current task
harmony build

# Continue paused work
harmony retry
```

AI will generate specs and start building. You'll be notified when things are ready for review.

> **CLI Reference**: Run `harmony help` to see all available commands and options.

---

## During the Day

### Reviewing AI Work

When AI notifies you that work is ready:

1. **Read the summary first** — AI provides a 1-paragraph summary at the top of every PR
2. **Check the tier** — This tells you how much scrutiny is needed
3. **For T2/T3** — Review the spec summary and threat analysis
4. **Spot-check code** — AI handles most review; you look for obvious issues
5. **Check tests are green** — CI should pass before you approve
6. **Approve or request changes** — If something's off, ask AI to retry

### Handling Interrupts

**Security Alert:**
```bash
harmony security check
```
AI analyzes the alert, proposes a fix, and shows you the risk level. Approve the fix PR.

**Production Issue:**
```bash
harmony incident start
```
See [INCIDENTS.md](./INCIDENTS.md) for full process. Rollback first, investigate second.

**Urgent Bug:**
```bash
harmony fix "critical: users can't login" --priority high
```
AI prioritizes this and generates an expedited fix.

### Asking AI for Help

```bash
# Understand a decision
harmony explain "why did we use Redis for sessions?"

# Get context on a file
harmony explain "what does OrderService do?"

# Understand an error
harmony explain "what does this error mean: ECONNREFUSED"
```

---

## Afternoon / End of Day

### Ship Completed Features

For features that are approved and ready:

```bash
# Check what's ready to ship
harmony status

# Ship a specific feature (behind a flag)
harmony ship

# Ship a specific task by ID
harmony ship <task-id>

# Or use Vercel directly
vercel promote <preview-url>
```

**Remember:** Features ship behind flags by default. After shipping:
1. Verify the preview works
2. Enable the flag for internal users first
3. Gradually roll out to all users

→ See [SHIPPING.md](./SHIPPING.md) for details.

### Queue Work for Overnight

AI can continue working while you're away:

```bash
# Start a larger feature that AI can work on overnight
harmony feature "refactor authentication to use OAuth2"
harmony build

# Start another task
harmony feature "add pagination to /api/orders"
harmony build
```

You'll have PRs waiting for review in the morning.

---

## Weekly Rhythm

### Monday: Planning

```bash
harmony plan-week
```

AI suggests priorities based on:
- Backlog items
- SLO health
- Technical debt

You adjust and approve the week's focus.

### Friday: Retro and Cleanup

**15-minute retro** (can be async):

1. `harmony retro` — AI generates summary of the week
2. Review: What went well? What was painful?
3. Adjust: Tighten or loosen any guardrails?

**Cleanup:**
```bash
# Clean up stale flags
harmony flags cleanup

# Review AI quality metrics
harmony quality report
```

---

## Working with Your Partner

In a 2-dev team, you rotate roles weekly:

| Role | Responsibilities |
|------|------------------|
| **Driver** | Initiates work, owns implementation, makes risk calls |
| **Navigator** | Reviews work, handles security checks, approves T3 changes |

### Async Communication

- **PRs and issues** — Primary communication channel
- **Daily standup** — 2 bullets each, async in Slack/Discord:
  - Yesterday: What got shipped
  - Today: What's in progress

### Sync Communication

- **T3 reviews** — May require brief sync discussion
- **Incidents** — Coordinate via incident channel
- **Weekly retro** — 15 min, can be async or sync

---

## Example Day: Monday

### Dev A (Driver this week)

| Time | Activity |
|------|----------|
| 9:00 | `harmony status` — 2 T1 PRs waiting |
| 9:15 | Approve both T1 PRs (5 min total) |
| 9:20 | Review T2 spec for "user profiles" — looks good |
| 9:25 | `harmony build user-profiles` |
| 9:30 | **Deep work** — Planning next quarter's features |
| 11:00 | AI pings: "user-profiles PR ready" |
| 11:15 | Review and approve PR |
| 11:30 | AI merges, deploys to preview |
| 14:00 | `harmony plan-week` — Adjust priorities with Dev B |
| 14:30 | Start T3 OAuth spec: `harmony feature "google oauth" --tier T3` |
| 15:00 | Review generated spec with Dev B |
| 15:30 | Approve spec, `harmony build oauth-integration` |
| 17:00 | Check AI progress, queue questions for tomorrow |

### Dev B (Navigator this week)

| Time | Activity |
|------|----------|
| 9:00 | Check alerts — one error budget warning overnight |
| 9:10 | `harmony investigate "error spike at 3am"` |
| 9:20 | AI proposes fix — approve |
| 9:45 | Review and approve fix PR |
| 10:00 | `harmony triage` — Categorize incoming issues |
| 11:00 | Review Dev A's user-profiles work (Navigator approval) |
| 14:00 | Weekly planning with Dev A |
| 15:00 | Security review of OAuth spec (T3 requires Navigator) |
| 15:15 | Approve OAuth spec |
| 16:00 | Review any pending security alerts |

---

## Common Patterns

### "I need to change direction mid-task"

```bash
harmony pause
# Adjust the task
harmony retry --context "actually, we need pagination too"
```

### "AI's approach isn't what I wanted"

```bash
harmony retry --constraint "use cursor-based pagination, not offset"
```

### "I need to understand what AI did"

```bash
harmony explain <task-id> "why did you use this approach?"
```

### "Something went wrong, need to redo"

```bash
harmony pause
harmony retry --model claude-opus
```

---

## Time Estimates

| Activity | T1 | T2 | T3 |
|----------|----|----|-----|
| Review spec summary | 30 sec | 2-3 min | 10-15 min |
| Review PR | 1 min | 5-10 min | 15-30 min |
| Spot-check code | Skip | 2-3 min | 5-10 min |
| **Total human time** | **2-3 min** | **15-20 min** | **30-60 min** |

Compare to pre-AI approach where each of these would be 2-4 hours of work.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| AI seems stuck | `harmony status --verbose` to see what's happening |
| PR has been pending too long | `harmony nudge <pr-number>` |
| Tests keep failing | `harmony diagnose <pr-number>` |
| Not sure what tier something should be | AI auto-assigns; you can override with `--tier` |
| Need to stop everything | `harmony pause --all` |

---

## Next Steps

- **Need to ship something?** → [SHIPPING.md](./SHIPPING.md)
- **Production issue?** → [INCIDENTS.md](./INCIDENTS.md)
- **Want to understand risk tiers?** → [RISK-TIERS.md](./RISK-TIERS.md)
- **Specific task?** → Check [TASKS/](./TASKS/) directory

---

## Full Documentation

For deep dives into the methodology, see the AI-facing docs:

- **CLI Reference**: `packages/harmony-cli/README.md` — Full command reference, options, and integration points
- **CI/CD Details**: [methodology/ci-cd-quality-gates.md](methodology/ci-cd-quality-gates.md)
- **Flow & WIP Policy**: [methodology/flow-and-wip-policy.md](methodology/flow-and-wip-policy.md)
- **Reliability & Ops**: [methodology/reliability-and-ops.md](methodology/reliability-and-ops.md)


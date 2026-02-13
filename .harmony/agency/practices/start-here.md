---
title: Start Here
description: Your entry point to Harmony—a methodology where you orchestrate AI agents to build enterprise-quality software.
---

# Harmony: Start Here

Welcome to Harmony. This is a methodology where **you orchestrate AI agents** to build enterprise-quality software. You make decisions. AI does the work. You approve. AI executes.

---

## Your Mental Model

```
┌─────────────────────────────────────────────────────────────────┐
│  YOU THINK IN          │  AI HANDLES                           │
├─────────────────────────────────────────────────────────────────┤
│  Spec → Plan → Build   │  Templates, code, tests, docs,        │
│  → Verify → Ship       │  gates, security analysis,            │
│                        │  observability, migrations            │
└─────────────────────────────────────────────────────────────────┘

Kits: The tools AI uses under the hood. You don't call them directly.
```

**The simple version:**
- You describe what you want
- AI does the heavy lifting
- You review and approve
- AI ships it safely

---

## Your Daily Commands

| I want to...                | Command / Action                              |
|-----------------------------|-----------------------------------------------|
| **Get started (new dev)**   | `harmony onboard start`                       |
| Start a new feature         | `harmony feature "description"`               |
| Fix a bug                   | `harmony fix "#123"` or `harmony fix "desc"`  |
| Check on AI progress        | `harmony status`                              |
| Build current task          | `harmony build`                               |
| Review AI's work            | Review PR + AI summary                        |
| Ship to production          | `harmony ship` or `vercel promote <url>`      |
| Rollback a problem          | `harmony rollback` or `vercel promote <prev>` |
| Handle an incident          | See [INCIDENTS.md](./INCIDENTS.md)            |
| Understand something        | `harmony explain "why did we..."`             |
| Retry with guidance         | `harmony retry --constraint "try X instead"`  |
| Pause AI work               | `harmony pause`                               |

→ **CLI Documentation**: See `packages/harmony-cli/README.md` for full command reference.

---

## Risk Tiers: When You Intervene

AI auto-assigns a risk tier to every change. Higher tiers require more human attention.

| Tier | What it is | Your Role | AI's Role |
|------|------------|-----------|-----------|
| **T1** | Bug fix, tiny change | Skim AI summary (1-2 min), approve | Full spec, code, tests, risk check |
| **T2** | Small feature | Review spec summary (5 min), approve PR | Full work + threat analysis |
| **T3** | Auth/data/security | Review full spec, approve each stage | Full work + deep security analysis |

**Rule of thumb:** If AI says T1, you can trust the summary. T2 deserves a quick read. T3 needs your full attention.

→ See [RISK-TIERS.md](./RISK-TIERS.md) for details.

---

## First Day Checklist

**Option A: Guided Onboarding (Recommended)**

```bash
harmony onboard start
```

The AI will guide you through everything step-by-step. Takes about 15-20 minutes.

**Option B: Self-Guided**

- [ ] **Read this doc** (5 min) ✅ You're doing it now
- [ ] **Read [DAILY-FLOW.md](./DAILY-FLOW.md)** (5 min) — How your day looks
- [ ] **Run `harmony status`** — See what's happening in your project
- [ ] **Try a small fix**: `harmony fix "update readme typo"` — Watch AI work
- [ ] **Build it**: `harmony build` — AI implements the fix
- [ ] **Review the PR** — See AI's summary, approve if it looks good
- [ ] **Ship it**: `harmony ship` — Deploy to production

**That's it for Day 1.** You're now productive in Harmony.

> **Note**: Run `harmony help` to see all available commands and options.

---

## First Week Reading Path

| Day | Document | Time | What You Learn |
|-----|----------|------|----------------|
| 1 | This doc (START-HERE) | 5 min | Mental model, first commands |
| 1 | [DAILY-FLOW.md](./DAILY-FLOW.md) | 5 min | Daily rhythm |
| 2 | [RISK-TIERS.md](./RISK-TIERS.md) | 5 min | When to pay close attention |
| 3 | [SHIPPING.md](./SHIPPING.md) | 5 min | How to release and rollback |
| 5 | [TASKS/fix-a-bug.md](./TASKS/fix-a-bug.md) | 5 min | Do your first guided task |
| 7 | [INCIDENTS.md](./INCIDENTS.md) | 5 min | What to do if production breaks |

**Total reading for Week 1: ~30 minutes**

---

## When Things Go Wrong

| Situation | What to Do |
|-----------|------------|
| AI output looks wrong | `harmony explain "why did you..."` — AI explains reasoning |
| Want a different approach | `harmony retry --constraint "try X instead"` |
| Need to pause AI work | `harmony pause` — Stops without discarding progress |
| CI gates fail | AI auto-fixes most; you approve the fix PR |
| Production incident | `harmony rollback` then [INCIDENTS.md](./INCIDENTS.md) |
| Not sure what's happening | `harmony status` — Shows current state |
| Need command help | `harmony help <command>` — Shows options and examples |

---

## Key Concepts (Glossary)

| Term | What It Means |
|------|---------------|
| **Spec** | A structured description of what you want to build. AI writes it; you review. |
| **Tier** | Risk level (T1 = tiny, T3 = high-risk). Determines how much you review. |
| **Preview** | A deployed version of your PR for testing before production. |
| **Promote** | Move a preview to production. |
| **Rollback** | Revert to a previous deployment. Instant with `vercel promote`. |
| **Flag** | Feature flag. New features ship OFF by default, then get enabled gradually. |
| **Kit** | Tools AI uses under the hood. You can use kit CLIs directly for debugging. |

→ See [../shared/GLOSSARY.md](../shared/GLOSSARY.md) for complete glossary.
→ See [KITS.md](./KITS.md) for kit CLI quick reference.

---

## Quick Reference Card

```
┌──────────────────────────────────────────────────────────────┐
│  HARMONY QUICK REFERENCE                                     │
├──────────────────────────────────────────────────────────────┤
│  Start feature:   harmony feature "what I want"              │
│  Fix a bug:       harmony fix "description"                  │
│  Check status:    harmony status                             │
│  Build:           harmony build                              │
│  Ship:            harmony ship                               │
│  Rollback:        harmony rollback                           │
│  Get help:        harmony explain "question"                 │
│  Retry:           harmony retry --constraint "..."           │
├──────────────────────────────────────────────────────────────┤
│  T1: Approve quickly     T2: Review summary                  │
│  T3: Review everything   Incidents: Rollback first           │
├──────────────────────────────────────────────────────────────┤
│  Aliases: f=feature, b=build, s=status, r=retry, d=deploy    │
└──────────────────────────────────────────────────────────────┘
```

---

## Where to Go Next

1. **Ready to start?** → [DAILY-FLOW.md](./DAILY-FLOW.md)
2. **Want to understand risk?** → [RISK-TIERS.md](./RISK-TIERS.md)
3. **Need to ship something?** → [SHIPPING.md](./SHIPPING.md)
4. **Production is down?** → [INCIDENTS.md](./INCIDENTS.md)
5. **Want the full details?** → [methodology/README.md](methodology/README.md) (AI-facing docs)

---

## Full Documentation (For AI and Deep Dives)

The simple docs you're reading are the human-facing layer. For full details on methodology, architecture, kits, and policies, see:

- **CLI Reference**: `packages/harmony-cli/README.md` — Full command docs, options, integration points
- **Kit CLIs**: [KITS.md](./KITS.md) — Quick reference for using kit CLIs directly
- **Kit Technical Docs**: `/packages/kits/README.md` — Full kit documentation
- **Prompt Library**: `packages/prompts/README.md` — Canonical prompts with schemas and validation
- **Full Methodology**: [methodology/README.md](methodology/README.md)
- **Architecture**: [architecture/overview.md](architecture/overview.md)
- **Kit Documentation**: [kits/README.md](kits/README.md)
- **Security Policies**: [methodology/security-baseline.md](methodology/security-baseline.md)

These docs are detailed and comprehensive—designed for AI agents to consume. You don't need to read them unless you want to understand how things work under the hood.


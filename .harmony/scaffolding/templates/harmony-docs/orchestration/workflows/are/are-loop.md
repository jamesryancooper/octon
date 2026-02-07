---
title: ARE Loop - Documentation Improvement Methodology
description: Analyze → Refine → Evaluate Loop for systematic documentation improvement
scope: shared
owner: engineering
version: 2.7.0
status: active
lastReviewed: 2025-12-11
related:
  - ./00-are-overview.md
  - ./agent-harness.md
tags:
  - documentation
  - methodology
  - quality
  - evaluation
---

# ARE Loop - Documentation Improvement Methodology

The **Analyze → Refine → Evaluate (ARE) Loop** is a systematic methodology for improving documentation quality. This methodology has been split into modular prompt files for easier AI agent management.

---

## Quick Start

### For AI Agents (Recommended)

Use the **Agent Harness** for reliable multi-session execution:

1. **Initialize**: Run `./are-init.sh <target-directory>` or use the initializer prompt in [agent-harness.md](./agent-harness.md)
2. **Each Session**: Follow the Session Protocol in [agent-harness.md](./agent-harness.md)
3. **Track Progress**: Update `<target-directory>/.harmony/.are/are-progress.json` after each phase

This ensures progress is tracked across context windows and each session knows where to resume.

**Directory Structure**:
- Central ARE prompts: `.harmony/orchestration/workflows/are/` (this directory)
- Runtime artifacts: `<target-directory>/.harmony/.are/` (created per doc set)

### For Human Users

1. **Start here**: [00-are-overview.md](./00-are-overview.md) - Select your tier and understand the methodology
2. **Run the loop**: Analyze → Refine → Evaluate using the phase prompts below
3. **Reference as needed**: Templates, tooling, and best practices

### For Document Sets

If improving a **collection of related documents** around a specific concept:

→ Use the [Document Set Improvement Workflow](./workflow-document-set-improvement.md)

This orchestrates the full process:
1. Generate a concept-aligned ARE prompt using [concept-aligned-are-loop.meta.md](./concept-aligned-are-loop.meta.md)
2. Run document set analysis
3. Process each document through the ARE loop

---

## Prompt File Index

### Agent Infrastructure

| File | Purpose |
|------|---------|
| [agent-harness.md](./agent-harness.md) | **Session protocol for AI agents** - progress tracking, verification, clean handoffs |
| [are-init.sh](./are-init.sh) | Initialization script to bootstrap tracking files |

### Core Workflow (Sequential)

| # | File | Purpose |
|---|------|---------|
| 00 | [are-overview.md](./00-are-overview.md) | Entry point, tier selection, Harmony alignment |
| 01 | [are-analyze-single-doc.md](./01-are-analyze-single-doc.md) | Analyze phase for individual documents |
| 02 | [are-analyze-audits.md](./02-are-analyze-audits.md) | Optional deep-dive audits (claims, processes, anti-patterns) |
| 03 | [are-refine.md](./03-are-refine.md) | Refine phase (prioritize → ideate → implement → validate) |
| 04 | [are-evaluate.md](./04-are-evaluate.md) | Evaluate phase (measure → decide) |
| 05 | [are-stress-tests.md](./05-are-stress-tests.md) | Scenario-based validation |
| 06 | [are-quality-gates.md](./06-are-quality-gates.md) | Stop-the-line triggers, re-evaluation triggers |

### Specialized

| # | File | Purpose |
|---|------|---------|
| - | [are-document-sets.md](./are-document-sets.md) | Multi-document analysis (terminology, duplication, navigation) |
| - | [workflow-document-set-improvement.md](./workflow-document-set-improvement.md) | **End-to-end workflow** for improving a doc set with concept alignment |
| - | [concept-aligned-are-loop.meta.md](./concept-aligned-are-loop.meta.md) | Meta-prompt to generate concept-focused ARE prompts |

### Reference & Support

| # | File | Purpose |
|---|------|---------|
| 07 | [are-templates.md](./07-are-templates.md) | All blank templates consolidated |
| 08 | [are-tooling.md](./08-are-tooling.md) | Tool recommendations, AI prompts, CI/CD |
| 09 | [are-best-practices.md](./09-are-best-practices.md) | Anti-patterns, failure modes, scaling |
| 10 | [are-quick-reference.md](./10-are-quick-reference.md) | Condensed reference card |
| 11 | [are-worked-example.md](./11-are-worked-example.md) | Complete API auth guide example |

---

## Agent Session Flow

Based on [Anthropic's research on long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents):

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        EVERY SESSION FLOW                                │
│  (Runtime artifacts in <target-dir>/.harmony/.are/)                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  START OF SESSION (Required)                                            │
│  1. pwd                                     → Confirm directory         │
│  2. cat .harmony/.are/are-progress.json   → Understand state          │
│  3. cat .harmony/.are/are-session-log.md  → Read last session notes   │
│  4. git log --oneline -5                    → Verify clean state        │
│  5. Identify current task                   → What to work on           │
│                                                                         │
│  DURING SESSION                                                         │
│  6. Execute ONE task              → One phase of one document           │
│  7. Create artifacts              → Save to .harmony/.are/artifacts/  │
│  8. Verify completion             → Use verification checklist          │
│                                                                         │
│  END OF SESSION (Required)                                              │
│  9. Update are-progress.json      → Record new status                   │
│  10. Update are-session-log.md    → Document what happened              │
│  11. git add && git commit        → Clean state for next session        │
│  12. Note next task               → Clear instruction for next session  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**Key Principles**:
- Work on **ONE document, ONE phase** per session
- **ALWAYS** read progress files before starting
- **ALWAYS** update progress files before ending
- **NEVER** mark complete without verification
- **ALWAYS** commit to establish clean state

---

## Workflow Navigation

```
Start → Initialize with agent-harness.md or are-init.sh
           │
           ▼
    ┌──────────────────────────────────────────┐
    │           Individual Document?            │
    │                                          │
    │  Yes → 01-are-analyze-single-doc.md      │
    │         └─(optional)→ 02-are-analyze-audits.md
    │        03-are-refine.md                  │
    │        04-are-evaluate.md                │
    │         └─(optional)→ 05-are-stress-tests.md
    │         └─(optional)→ 06-are-quality-gates.md
    │                                          │
    │  No (Doc Set) → are-document-sets.md     │
    │                 + above phases           │
    └──────────────────────────────────────────┘

Supporting (as needed):
  - 07-are-templates.md (blank templates)
  - 08-are-tooling.md (tool selection, AI prompts)
  - 09-are-best-practices.md (anti-patterns, scaling)
  - 10-are-quick-reference.md (quick lookup)
  - 11-are-worked-example.md (learn by example)
```

---

## Tiers at a Glance

| Tier | Time Budget | Cycle Duration | Use For |
|------|-------------|----------------|---------|
| **ARE-Lite** | 15-30 min | 1-2 days | Minor updates, low-risk docs |
| **ARE-Standard** | 1-2 hours | 3-5 days | New docs, significant changes |
| **ARE-Full** | 2-4 hours | 5-7 days | Critical docs, major refactors |

---

## Why This Structure?

### Modular Prompts
The original monolithic ARE Loop document was 1,774 lines. Breaking it into focused modules provides:
- **Reduced cognitive load**: Each file is 100-300 lines
- **Task-focused execution**: AI agents load only relevant prompts
- **Clear sequencing**: Numbered prefixes indicate workflow order

### Agent Harness
Based on Anthropic's research, long-running agents fail when they:
- Try to do everything at once (one-shotting)
- Declare victory too early
- Lose state between sessions

The agent harness solves this with:
- **Structured progress tracking** (JSON, not prose)
- **Verification checklists** before marking complete
- **Session protocols** for consistent start/end
- **One task per session** discipline

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.7.0 | 2025-12-11 | Added agent-harness.md and are-init.sh for reliable multi-session execution |
| 2.6.0 | 2025-12-11 | Split into 13 modular prompt files |

*For detailed version history, see individual prompt files.*

---

*This file serves as the index for the ARE Loop methodology. For AI agents, start with [agent-harness.md](./agent-harness.md). For humans, start with [00-are-overview.md](./00-are-overview.md).*

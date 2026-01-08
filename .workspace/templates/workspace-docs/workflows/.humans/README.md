# ARE Loop - Human Documentation

> This directory contains documentation for humans. AI agents should ignore this directory.

## What is the ARE Loop?

The **Analyze → Refine → Evaluate (ARE) Loop** is a comprehensive, systematic methodology for improving documentation quality. Think of it as a "documentation CI/CD pipeline" — a rigorous, repeatable process that transforms ad-hoc editing into measurable improvement cycles.

## Core Characteristics

### 1. Three Core Phases

The ARE Loop aligns with Harmony's **PLAN → SHIP → LEARN** methodology:

| Phase | Harmony Phase | Purpose | Key Activities |
|-------|---------------|---------|----------------|
| **Analyze** | PLAN | Understand current state | Gap identification, criteria setting, baseline assessment |
| **Refine** | SHIP | Make improvements | Ideate solutions, implement changes, quick validation |
| **Evaluate** | LEARN | Measure and decide | Impact measurement, criteria adjustment, next steps |

```
┌─────────┐      ┌─────────┐      ┌──────────┐
│ ANALYZE │ ──▶  │ REFINE  │ ──▶  │ EVALUATE │
└─────────┘      └─────────┘      └──────────┘
     │                                   │
     │                                   ▼
     │           ┌──────────────────────────────────┐
     │           │ Decision: Accept / Iterate / Stop │
     │           └──────────────────────────────────┘
     │                          │
     └──────────────────────────┘
           (if iterate)
```

### 2. Tiered Depth

Choose the appropriate depth based on documentation criticality:

| Tier | Time Budget | When to Use | Example |
|------|-------------|-------------|---------|
| **ARE-Lite** | 15-30 min | Minor updates, low-risk docs | Fixing typos, minor clarifications |
| **ARE-Standard** | 1-2 hours | Significant changes | New docs, improving guides, API docs |
| **ARE-Full** | 2-4 hours | Critical documentation | Security policies, compliance docs, major refactors |

**Selection Guide:**
- Trivial changes (typos, formatting) → ARE-Lite
- User-facing with moderate impact → ARE-Standard
- Security, compliance, or legally binding → ARE-Full
- Critical to operations (runbooks, incident response) → ARE-Full
- Unsure? → Start with ARE-Standard, escalate if needed

### 3. Multi-Session Agent Support

The ARE Loop is designed for AI agents working across multiple context windows:

- **`agent-harness.md`**: Structured session protocols ensuring reliable progress
- **`are-init.sh`**: Initialization script that bootstraps tracking infrastructure
- **Progress tracking**: JSON-based state management survives context switches
- **Verification checklists**: Prevents premature completion claims

This solves common agent failures:
- ❌ One-shotting (trying to do everything at once)
- ❌ Premature completion (declaring victory too early)
- ❌ Lost state (forgetting prior progress)
- ❌ Incomplete verification (marking done without testing)

### 4. Concept Alignment

The workflow can be tailored to evaluate documentation through a specific lens:

- **Security** — Does the doc properly cover security concerns?
- **Onboarding** — Can a new hire use this doc on Day 1?
- **API Usage** — Is the API properly documented for consumers?
- **Performance** — Are performance implications covered?

The `concept-aligned-are-loop.meta.md` generates customized evaluation prompts based on your chosen concept.

### 5. Document Set Analysis

For collections of 5+ related documents, the ARE Loop includes cross-cutting analysis:

| Analysis Type | What It Catches |
|---------------|-----------------|
| **Terminology Consistency** | "API key" vs "api key" vs "Api Key" |
| **Duplication Analysis** | Same content in multiple places (drift risk) |
| **Cross-Reference Check** | Broken links, missing backlinks |
| **Concern Distribution** | Topics without clear ownership |
| **Entry Point Analysis** | Is there a clear "start here"? |

## Directory Structure

The ARE Loop uses a **two-location pattern**:

```
<repository>/
├── .workspace/
│   └── workflows/
│       └── are/                          # ← CENTRAL: Methodology (read-only)
│           ├── 00-are-overview.md        #    Entry point, tier selection
│           ├── 01-are-analyze-single-doc.md
│           ├── 03-are-refine.md
│           ├── 04-are-evaluate.md
│           ├── agent-harness.md          #    AI agent session protocol
│           ├── are-init.sh               #    Initialization script
│           └── .humans/
│               └── README.md             #    This file
│
└── <target-docs>/                        # ← Any documentation set
    └── .workspace/
        └── .are/                         # ← RUNTIME: Per-run artifacts
            ├── are-config.json           #    Workflow configuration
            ├── are-progress.json         #    Progress tracking
            ├── are-session-log.md        #    Session history
            ├── concept-context.md        #    Gathered guidelines/terminology
            └── artifacts/                #    Analysis outputs
                ├── doc1-cycle1-analysis.md
                └── ...
```

## Quick Start

### For AI Agents

```bash
# 1. Initialize tracking for a documentation set
.workspace/workflows/are/are-init.sh docs/my-docs/

# 2. Follow the agent harness protocol
# See: .workspace/workflows/are/agent-harness.md
```

### For Humans

1. **Start here**: `00-are-overview.md` — Select your tier and understand the methodology
2. **Run the loop**: Analyze → Refine → Evaluate using the phase prompts
3. **Reference as needed**: Templates, tooling, and best practices

## File Index

### Core Workflow (Sequential)

| File | Purpose |
|------|---------|
| `00-are-overview.md` | Entry point, tier selection, Harmony alignment |
| `01-are-analyze-single-doc.md` | Analyze phase for individual documents |
| `02-are-analyze-audits.md` | Optional deep-dive audits |
| `03-are-refine.md` | Refine phase (prioritize → ideate → implement) |
| `04-are-evaluate.md` | Evaluate phase (measure → decide) |
| `05-are-stress-tests.md` | Scenario-based validation |
| `06-are-quality-gates.md` | Stop-the-line triggers |

### Agent Infrastructure

| File | Purpose |
|------|---------|
| `agent-harness.md` | Session protocol for AI agents |
| `are-init.sh` | Initialize tracking for a doc set |

### Specialized

| File | Purpose |
|------|---------|
| `are-document-sets.md` | Multi-document analysis |
| `workflow-document-set-improvement.md` | End-to-end workflow for doc sets |
| `concept-aligned-are-loop.meta.md` | Generate concept-focused prompts |

### Reference

| File | Purpose |
|------|---------|
| `07-are-templates.md` | Blank templates |
| `08-are-tooling.md` | Tool recommendations |
| `09-are-best-practices.md` | Anti-patterns, failure modes |
| `10-are-quick-reference.md` | Condensed reference card |
| `11-are-worked-example.md` | Complete worked example |

## Why ARE Loop?

Traditional documentation improvement is ad-hoc:
- "I'll fix this when I see it"
- "Let's do a doc review sometime"
- "This doc is probably outdated"

The ARE Loop provides:
- **Measurable progress**: Dimension scores, gap counts, stress test results
- **Repeatable process**: Same methodology regardless of who executes
- **Preserved learning**: Criteria evolution logs, session history
- **Quality gates**: Stop-the-line triggers prevent shipping broken docs
- **Agent-friendly**: Designed for AI-assisted documentation improvement

## Harmony Alignment

The ARE Loop maps directly to Harmony's Six Pillars:

| Harmony Pillar | ARE Loop Support |
|----------------|------------------|
| **Direction** | Gap Analysis identifies what to improve |
| **Focus** | Tiered evaluation depth prevents over-engineering |
| **Velocity** | Quick Reference enables fast execution |
| **Trust** | Quality Self-Check ensures thoroughness |
| **Continuity** | Criteria Evolution Log preserves learning |
| **Insight** | Document Set Analysis finds patterns |

---

*For questions or improvements to the ARE Loop methodology, see the main repository documentation or open an issue.*

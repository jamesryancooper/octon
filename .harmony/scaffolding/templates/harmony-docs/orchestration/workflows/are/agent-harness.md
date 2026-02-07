---
title: ARE Loop Agent Harness
description: Structured harness for AI agents to execute ARE Loop across multiple context windows
scope: shared
owner: engineering
version: 1.0.0
status: active
lastReviewed: 2025-12-11
related:
  - ./workflow-document-set-improvement.md
  - ./00-are-overview.md
tags:
  - documentation
  - methodology
  - agent
  - automation
---

# ARE Loop Agent Harness

This harness enables AI agents to reliably execute the ARE Loop across multiple context windows. It implements patterns from [Anthropic's research on effective long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents).

---

## The Problem

AI agents face challenges with long-running tasks that span multiple context windows:

1. **One-shotting**: Trying to do everything at once, running out of context mid-task
2. **Premature completion**: Declaring victory before work is actually done
3. **Lost state**: Each new session starts with no memory of prior progress
4. **Incomplete verification**: Marking phases complete without proper testing

---

## The Solution: Two-Agent Pattern

### 1. Initializer Agent (First Session Only)

Sets up the tracking infrastructure:

- Creates `are-progress.json` - structured progress tracking
- Creates `are-session-log.md` - human-readable session history  
- Establishes the task list with all documents and phases
- Makes initial git commit to establish baseline

### 2. Session Agent (Every Session)

Makes incremental progress:

- Reads progress files to understand current state
- Works on ONE task at a time (one document, one phase)
- Verifies work before marking complete
- Updates progress files and commits changes
- Leaves environment in clean state for next session

---

## File Structure

ARE Loop uses a **two-location pattern**:

1. **Central ARE prompts** (read-only methodology): `.harmony/orchestration/workflows/are/`
2. **Runtime artifacts** (per-doc-set): `<target-docs>/.harmony/.are/`

```
<project>/
├── .harmony/
│   └── workflows/
│       └── are/                          # ← CENTRAL: ARE methodology prompts
│           ├── 00-are-overview.md
│           ├── 01-are-analyze-single-doc.md
│           ├── agent-harness.md          # ← This file
│           ├── are-init.sh
│           └── ...
│
└── <target-docs>/                        # ← The docs you're improving
    ├── doc1.md
    ├── doc2.md
    └── .harmony/
        └── .are/                         # ← RUNTIME: Progress & artifacts
            ├── are-config.json           # Configuration (concept, tier, scope, alignment)
            ├── are-progress.json         # Machine-readable progress (DO NOT DELETE)
            ├── are-session-log.md        # Human-readable session history
            ├── alignment-reference.md    # Summary of reference docs (if aligning)
            ├── concept-context.md        # Gathered guidelines, terminology, constraints
            ├── concept-aligned-prompt.md # Generated prompt (from meta-prompt)
            └── artifacts/                # Per-document analysis artifacts
                ├── doc1-cycle1-analysis.md
                ├── doc1-cycle1-changes.md
                ├── doc1-cycle1-evaluation.md
                └── ...
```

### Key Files Explained

**Runtime artifacts** (in `<target-docs>/.harmony/.are/`):

| File | Purpose | When Created | Who Reads It |
|------|---------|--------------|--------------|
| `are-config.json` | Workflow parameters + alignment intent | Initialization | Every session |
| `are-progress.json` | Track document/phase status | Initialization | Every session |
| `are-session-log.md` | Human-readable history | Initialization | Every session |
| `alignment-reference.md` | **Principles, terminology from reference docs** | Phase 0 (if aligning) | Every analyze phase |
| `concept-context.md` | **Guidelines, terminology, constraints** | After init, before analysis | Every analyze phase |
| `concept-aligned-prompt.md` | Tailored evaluation prompt | After context gathering | Every analyze phase |

**Central prompts** (in `.harmony/orchestration/workflows/are/`):

| File | Purpose |
|------|---------|
| `agent-harness.md` | Session protocol (this file) |
| `01-are-analyze-single-doc.md` | Analyze phase prompt |
| `03-are-refine.md` | Refine phase prompt |
| `04-are-evaluate.md` | Evaluate phase prompt |
| `concept-aligned-are-loop.meta.md` | Meta-prompt generator |

---

## are-progress.json Format

```json
{
  "meta": {
    "concept": "<CONCEPT>",
    "tier": "ARE-Standard",
    "started": "2025-12-11T10:00:00Z",
    "lastUpdated": "2025-12-11T14:30:00Z",
    "totalDocuments": 5,
    "completedDocuments": 2
  },
  "alignmentIntent": {
    "goalType": "align_with_reference",
    "targetDocPath": "docs/harmony/ai/methodology",
    "referencePath": "docs/harmony/ai/pillars",
    "alignmentDirection": "Update methodology docs to reflect language and structure from pillars",
    "successCriteria": [
      "Methodology uses pillar terminology consistently",
      "No contradictions between methodology and pillars",
      "Cross-references are accurate"
    ]
  },
  "alignmentReference": {
    "status": "completed",
    "principlesExtracted": 6,
    "termsDocumented": 8,
    "completedAt": "2025-12-11T10:15:00Z"
  },
  "conceptContext": {
    "status": "completed",
    "guidelinesFound": 2,
    "termsDocumented": 5,
    "constraintsIdentified": 3,
    "completedAt": "2025-12-11T10:30:00Z"
  },
  "conceptAlignedPrompt": {
    "status": "completed",
    "generatedAt": "2025-12-11T10:45:00Z"
  },
  "documents": [
    {
      "id": "doc1",
      "path": "docs/api/authentication.md",
      "priority": 1,
      "status": "completed",
      "cycles": [
        {
          "cycle": 1,
          "phases": {
            "analyze": { "status": "completed", "completedAt": "2025-12-11T11:00:00Z" },
            "refine": { "status": "completed", "completedAt": "2025-12-11T12:30:00Z" },
            "evaluate": { "status": "completed", "completedAt": "2025-12-11T13:00:00Z" }
          },
          "decision": "standardized",
          "summary": "Added token refresh section, improved readability"
        }
      ]
    },
    {
      "id": "doc2",
      "path": "docs/api/authorization.md",
      "priority": 2,
      "status": "in_progress",
      "cycles": [
        {
          "cycle": 1,
          "phases": {
            "analyze": { "status": "completed", "completedAt": "2025-12-11T13:30:00Z" },
            "refine": { "status": "in_progress", "startedAt": "2025-12-11T14:00:00Z" },
            "evaluate": { "status": "pending" }
          },
          "decision": null,
          "summary": null
        }
      ]
    },
    {
      "id": "doc3",
      "path": "docs/api/rate-limiting.md",
      "priority": 3,
      "status": "pending",
      "cycles": []
    }
  ],
  "setAnalysis": {
    "status": "completed",
    "terminologyIssues": 3,
    "duplicationIssues": 1,
    "crossRefIssues": 2
  }
}
```

**Critical Rules for are-progress.json**:

- **NEVER delete or remove entries** - only update status fields
- **NEVER mark status as "completed" without verification**
- **ALWAYS update `lastUpdated` timestamp when modifying**
- Use JSON to prevent accidental overwrites (more structured than Markdown)

---

## Initializer Agent Prompt

Use this prompt for the FIRST session only.

**Recommended**: Use `are-init.sh <target-directory>` to automate initialization.

```markdown
# ARE Loop Initialization

You are initializing an ARE Loop documentation improvement workflow.

## Your Task

Set up the tracking infrastructure for improving a documentation set. You will:
1. Create the `.harmony/.are/` directory structure in the target docs directory
2. **Gather concept context** (guidelines, terminology, constraints)
3. Analyze the documentation scope and create the task list
4. Generate the initial `are-progress.json` with all documents
5. Create `are-config.json` with workflow parameters
6. Make an initial git commit to establish baseline

## Parameters

- **Target Directory**: <TARGET_DOC_DIR> (e.g., docs/harmony/ai/methodology/)
- **Concept/Topic**: <CONCEPT>
- **Documentation Scope**: <DOC_SCOPE>
- **ARE Tier**: <ARE_TIER>
- **Document Paths**: 
  1. <path1>
  2. <path2>
  ...

## Steps

### Step 1: Create Directory Structure
```bash
# Create .harmony/.are/ in the target documentation directory
mkdir -p <TARGET_DOC_DIR>/.harmony/.are/artifacts
```

### Step 2: Create are-config.json

Create `<TARGET_DOC_DIR>/.harmony/.are/are-config.json` with:

```json
{
  "concept": "<CONCEPT>",
  "tier": "<ARE_TIER>",
  "scope": "<DOC_SCOPE>",
  "targetDirectory": "<TARGET_DOC_DIR>",
  "arePromptsPath": ".harmony/orchestration/workflows/are",
  "initialized": "<ISO_TIMESTAMP>",
  "documents": ["<path1>", "<path2>", ...]
}
```

### Step 3: GATHER CONCEPT CONTEXT (Critical)

**Before analyzing any documents**, gather context about what `<CONCEPT>` means in this organization.

#### 3a: Search for Existing Guidelines

```bash
# Search for related policy/guideline documents
grep -r "<CONCEPT>" --include="*.md" docs/ | head -20
ls -la docs/*policy* docs/*standard* docs/*guideline* 2>/dev/null
```

#### 3b: Create concept-context.md

Create `<TARGET_DOC_DIR>/.harmony/.are/concept-context.md` with gathered information:

```markdown
# Concept Context: <CONCEPT>

**Gathered**: <DATE>

## Definition
[What <CONCEPT> means in this organization - 1-2 sentences]

## Guidelines and Policies

| Document | Location | Key Requirements |
|----------|----------|------------------|
| [Name] | [Path] | [Summary] |

### Key Requirements
1. [Requirement from guidelines]
2. [Requirement from guidelines]

## Terminology

| Canonical Term | Avoid | Definition |
|----------------|-------|------------|
| [Correct term] | [Variants to avoid] | [Definition] |

## Constraints

| Constraint | Source | Impact |
|------------|--------|--------|
| [Constraint] | [Policy/compliance] | [How it affects docs] |

## Scope

### In Scope
- [What aspects of <CONCEPT> ARE covered]

### Out of Scope
- [What aspects are NOT covered]

## Stakeholders

| Role | Team | Involvement |
|------|------|-------------|
| Concept Owner | | Final authority |
| Reviewers | | Review changes |

## Success Criteria

A reader should be able to:
1. [ ] [Criterion 1]
2. [ ] [Criterion 2]

## Anti-Patterns to Avoid

| Anti-Pattern | Correct Approach |
|--------------|------------------|
| [Bad practice] | [Good practice] |
```

#### 3c: Verify Context Gathering

Before proceeding, ensure:

- [ ] At least searched for existing guidelines
- [ ] Terminology section has at least 1 entry (or noted "none found")
- [ ] Scope boundaries are defined
- [ ] At least 1 success criterion defined

### Step 4: Inventory Documents

For each document in scope:

1. Read the document
2. Assign a priority (1 = highest)
3. Note its current state

### Step 5: Create are-progress.json

Create `<TARGET_DOC_DIR>/.harmony/.are/are-progress.json`.
Initialize with ALL documents set to "pending" status.
Set `setAnalysis.status` to "pending".
Set `conceptContext.status` to "completed".

### Step 6: Create are-session-log.md

Create `<TARGET_DOC_DIR>/.harmony/.are/are-session-log.md`:

```markdown
# ARE Loop Session Log

## Workflow Configuration
- **Concept**: <CONCEPT>
- **Tier**: <ARE_TIER>
- **Scope**: <DOC_SCOPE>
- **Target Directory**: <TARGET_DOC_DIR>
- **Documents**: <count>

---

## Session 1: Initialization
**Date**: <date>
**Duration**: <time>

### Actions
- Created .harmony/.are/ directory structure
- Gathered concept context (guidelines, terminology, constraints)
- Inventoried <n> documents
- Initialized progress tracking

### Concept Context Summary
- Guidelines found: <n> documents
- Key constraints: [list]
- Terminology defined: <n> terms

### Next Session Should
- Generate concept-aligned prompt using concept-context.md
- Run document set analysis (use .harmony/orchestration/workflows/are/are-document-sets.md)
- Begin analyzing highest-priority document
```

### Step 7: Git Commit

```bash
git add <TARGET_DOC_DIR>/.harmony/
git commit -m "ARE Loop: Initialize tracking for <DOC_SCOPE> (<CONCEPT>)"
```

## Output

After completing initialization, report:

1. **Concept context gathered**: Guidelines found, constraints identified
2. Number of documents inventoried
3. Suggested priority order
4. Estimated total effort based on tier
5. What the next session should do first
6. Path to ARE progress files: `<TARGET_DOC_DIR>/.harmony/.are/`

```

---

## Session Agent Prompt

Use this prompt for EVERY session after initialization:

```markdown
# ARE Loop Session

You are continuing an ARE Loop documentation improvement workflow.

## Key Paths

- **Runtime artifacts**: `<TARGET_DOC_DIR>/.harmony/.are/`
- **Central ARE prompts**: `.harmony/orchestration/workflows/are/`

## Session Protocol

ALWAYS follow these steps at the START of every session:

### Step 1: Orient (Required)
```bash
pwd
```

Confirm you're in the correct project directory.

### Step 2: Read Progress State (Required)

```bash
cat <TARGET_DOC_DIR>/.harmony/.are/are-progress.json
```

Parse this to understand:

- Which documents are completed, in progress, or pending
- What phase was last worked on
- What the current task should be

### Step 3: Read Session Log (Required)

```bash
cat <TARGET_DOC_DIR>/.harmony/.are/are-session-log.md
```

Read the most recent session entry to understand:

- What was accomplished last session
- What was recommended for this session

### Step 4: Check Git Status (Required)

```bash
git log --oneline -5
git status
```

Verify the environment is in a clean state.

### Step 5: Identify Current Task

Based on progress state:

1. If a document is "in_progress", continue from its current phase
2. If no document is in progress, start the next "pending" document
3. If set analysis is pending and no documents started, do set analysis first

---

## Working Rules

### Rule 1: ONE Task at a Time

Work on exactly ONE of these per session:

- Set analysis (if pending and no docs started)
- One phase (Analyze OR Refine OR Evaluate) of one document
- Never try to complete multiple documents in one session

### Rule 2: Verify Before Marking Complete

Before setting any `status` to "completed":

- For Analyze: Verify gap analysis artifact exists and is complete
- For Refine: Verify changes are implemented and pass validation
- For Evaluate: Verify scores, tests, and decision are documented

### Rule 3: Update Progress IMMEDIATELY

After completing any task:

1. Update `are-progress.json` with new status
2. Add session entry to `are-session-log.md`
3. Git commit with descriptive message

### Rule 4: Leave Clean State

At END of every session:

1. No uncommitted changes
2. Progress files updated
3. Clear note about what next session should do

---

## Phase Execution

> **Note**: Runtime artifacts are in `<TARGET_DOC_DIR>/.harmony/.are/`.
> Central prompts are in `.harmony/orchestration/workflows/are/`.

### Executing Analyze Phase

1. **Read alignment reference** from `.harmony/.are/alignment-reference.md` (if exists)
2. **Read concept context** from `.harmony/.are/concept-context.md` (terminology, constraints, success criteria)
3. **Read concept-aligned prompt** from `.harmony/.are/concept-aligned-prompt.md`
4. Read the document completely
5. Apply concept-aligned AND alignment-aware analysis
6. Use [01-are-analyze-single-doc.md](./01-are-analyze-single-doc.md) for standard analysis
7. Create `.harmony/.are/artifacts/<doc-id>-cycle<n>-analysis.md`
8. Update are-progress.json: set analyze.status = "completed"
9. Commit: "ARE Loop: Complete Analyze for <doc> (Cycle <n>)"

**Context Checklist for Analyze**:

- [ ] Used canonical terminology from concept-context.md
- [ ] Checked against constraints listed
- [ ] Evaluated against success criteria
- [ ] Looked for anti-patterns documented

**Alignment Checklist for Analyze** (if aligning):

- [ ] Checked terminology against alignment-reference.md
- [ ] Verified consistency with reference principles
- [ ] Noted any contradictions with reference
- [ ] Flagged structural misalignments

### Executing Refine Phase

1. Read the analysis artifact
2. Use [03-are-refine.md](./03-are-refine.md)
3. Make changes to the document
4. Create `.harmony/.are/artifacts/<doc-id>-cycle<n>-changes.md`
5. Update are-progress.json: set refine.status = "completed"
6. Commit: "ARE Loop: Complete Refine for <doc> (Cycle <n>)"

### Executing Evaluate Phase

1. Re-read the modified document
2. Use [04-are-evaluate.md](./04-are-evaluate.md)
3. Run applicable stress tests from [05-are-stress-tests.md](./05-are-stress-tests.md)
4. Create `.harmony/.are/artifacts/<doc-id>-cycle<n>-evaluation.md`
5. Record decision (standardize/continue/pivot/archive)
6. Update are-progress.json: set evaluate.status = "completed", set decision
7. Commit: "ARE Loop: Complete Evaluate for <doc> (Cycle <n>) - <decision>"

---

## Session Log Entry Format

Add this to `are-session-log.md` at the END of every session:

```markdown
---

## Session <N>: <Brief Description>
**Date**: <ISO date>
**Duration**: <approximate time>
**Document**: <which doc or "Set Analysis">
**Phase**: <Analyze/Refine/Evaluate>

### Accomplished
- <bullet list of what was done>

### Artifacts Created
- <list of files created/modified>

### Progress Update
- Documents completed: <n>/<total>
- Current document: <name> - <phase> <status>

### Verification
- [ ] Progress JSON updated
- [ ] Artifacts committed
- [ ] No uncommitted changes

### Next Session Should
- <specific instruction for next session>
```

---

## Commit Message Format

Use consistent commit messages:

- `ARE Loop: Initialize tracking for <scope> (<concept>)`
- `ARE Loop: Complete set analysis`
- `ARE Loop: Complete <Phase> for <doc> (Cycle <n>)`
- `ARE Loop: <doc> Cycle <n> complete - <decision>`

---

## Handling Interruptions

If you must stop mid-task:

1. **Save partial progress**: Write what you've done to a partial artifact
2. **Update progress**: Set status to "in_progress" (not completed)
3. **Document state**: In session log, note exactly where you stopped
4. **Commit**: "ARE Loop: WIP - <doc> <phase> (partial)"

Next session will see "in_progress" and can resume.

---

## Verification Checklist

Before marking ANY phase as "completed":

### Analyze Phase Verification

- [ ] **Alignment reference was consulted** (if `.harmony/.are/alignment-reference.md` exists)
- [ ] **Concept context was consulted** (`.harmony/.are/concept-context.md`)
- [ ] **Concept-aligned prompt was used** (`.harmony/.are/concept-aligned-prompt.md`)
- [ ] Document was read completely
- [ ] Gap analysis artifact exists at `.harmony/.are/artifacts/<doc>-analysis.md`
- [ ] Gaps reference concept terminology and constraints
- [ ] **Alignment gaps documented** (if aligning) - where doc diverges from reference
- [ ] At least 3 gaps identified (or explicit note that doc is already excellent)
- [ ] Criteria weights sum to 100%
- [ ] Scope defined (which gaps to address this cycle)

### Refine Phase Verification

- [ ] Analysis artifact was read
- [ ] Changes were actually made to the document
- [ ] Changes artifact exists at `.harmony/.are/artifacts/<doc>-changes.md`
- [ ] Changes address the gaps identified in analysis
- [ ] Quick validation passed (links work, no obvious errors)

### Evaluate Phase Verification

- [ ] Modified document was re-read fresh
- [ ] Scores recorded for all dimensions
- [ ] At least 1 stress test executed (all tiers)
- [ ] Decision recorded (standardize/continue/pivot/archive)
- [ ] If continuing, next cycle scope defined
- [ ] Evaluation artifact exists at `.harmony/.are/artifacts/<doc>-evaluation.md`

```

---

## Quick Reference: Session Flow

```

┌─────────────────────────────────────────────────────────────────────────┐
│                        EVERY SESSION FLOW                                │
│  (Runtime artifacts in <TARGET_DOC_DIR>/.harmony/.are/)               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  START OF SESSION                                                       │
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
│  END OF SESSION                                                         │
│  9. Update are-progress.json      → Record new status                   │
│  10. Update are-session-log.md    → Document what happened              │
│  11. git add && git commit        → Clean state for next session        │
│  12. Note next task               → Clear instruction for next session  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

```

---

## Failure Recovery

| Problem | Detection | Recovery |
|---------|-----------|----------|
| Progress JSON corrupted | Parse error when reading | Reconstruct from git history + session log |
| Artifact missing | Verification fails | Re-execute the phase |
| Uncommitted changes | `git status` shows changes | Commit or stash before proceeding |
| Wrong document in progress | Progress shows unexpected state | Read session log for context |
| Phase marked complete incorrectly | Verification checklist fails | Set status back to "in_progress" |

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why It Fails | Correct Approach |
|--------------|--------------|------------------|
| **Skipping progress read** | Don't know current state | ALWAYS read are-progress.json first |
| **Multiple docs per session** | Context overload, incomplete work | ONE document, ONE phase per session |
| **Marking complete without verification** | False progress, later failures | Run verification checklist |
| **Skipping commits** | Next session can't see progress | Commit after EVERY phase |
| **Deleting progress entries** | Lose history, can't recover | Only UPDATE status, never delete |
| **Working without session log** | No context for next session | ALWAYS update session log |

---

*This harness ensures reliable progress across multiple context windows. The key is disciplined progress tracking and verification.*

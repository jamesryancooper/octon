---
title: ARE Loop - Document Set Improvement Workflow
description: End-to-end workflow for improving a documentation set using concept-aligned ARE Loop
scope: shared
owner: engineering
version: 1.0.0
status: active
lastReviewed: 2025-12-11
related:
  - ./00-are-overview.md
  - ./are-document-sets.md
  - ./concept-aligned-are-loop.meta.md
tags:
  - documentation
  - methodology
  - workflow
  - automation
---

# Document Set Improvement Workflow

This workflow guides an AI agent through the complete process of improving a documentation set using the ARE Loop methodology. It consists of three main phases:

1. **Setup**: Generate a concept-aligned ARE Loop prompt for your documentation set
2. **Analysis**: Run document set analysis to identify cross-cutting issues
3. **Iteration**: Process each document through the ARE Loop phases

---

## Prerequisites

Before starting this workflow, ensure you have:

- [ ] Identified the **documentation set** to improve (list of file paths)
- [ ] Defined the **primary concept/topic** the docs should serve (e.g., security, onboarding, API usage)
- [ ] Selected the **ARE tier** (ARE-Lite, ARE-Standard, or ARE-Full)
- [ ] Allocated time budget based on tier and document count

### Time Estimation

| Documents | ARE-Lite | ARE-Standard | ARE-Full |
|-----------|----------|--------------|----------|
| 3-5 docs | 2-3 hours | 1-2 days | 3-5 days |
| 6-10 docs | 4-6 hours | 2-4 days | 5-10 days |
| 11-20 docs | 1-2 days | 4-7 days | 2-3 weeks |

---

## Phase 0: Direction Setting — Define Alignment Intent

Before diving into the workflow, clarify **what direction** you want the documentation to move.

### Step 0.1: Alignment Intent Prompt

**Ask the user**:

> **What is your goal for this documentation improvement?**
>
> 1. **General quality improvement** - Improve clarity, completeness, and usability without a specific alignment target
>
> 2. **Align with updated reference docs** - Tighten this doc set to match recently updated documentation elsewhere
>    - *Example: "Align methodology docs with our updated pillars documentation"*
>
> 3. **Align with external standard** - Ensure docs conform to an external framework, policy, or specification
>    - *Example: "Align security docs with SOC2 requirements"*
>
> 4. **Resolve inconsistencies** - Fix known conflicts or drift between doc sets
>    - *Example: "Reconcile API docs with actual implementation"*
>
> 5. **Concept integration** - Ensure a concept is properly woven throughout the doc set
>    - *Example: "Ensure all methodology docs reflect our new AI-first approach"*

### Step 0.2: Capture Alignment Parameters

Based on user response, fill in:

```markdown
## Alignment Intent

**Goal Type**: [ ] General Quality | [ ] Align with Reference | [ ] Align with External | [ ] Resolve Inconsistencies | [ ] Concept Integration

**Documentation Set to Improve** (target):
- Path: `<TARGET_DOC_PATH>`
- Description: <what this doc set covers>

**Alignment Reference** (if applicable):
- Path: `<REFERENCE_DOC_PATH>` (or external URL/standard name)
- Description: <what this reference represents>
- Recently Updated?: Yes / No / N/A
- Key Changes: <if recently updated, what changed?>

**Alignment Direction**:
<One sentence describing the transformation>
<!-- Example: "The methodology docs should be updated to reflect the language, principles, and structure from the updated pillars documentation" -->

**Success Looks Like**:
1. <What should be true when done>
2. <What should be true when done>
3. <What should be true when done>

**Out of Scope**:
- <What this effort should NOT try to do>
```

### Step 0.3: Gather Reference Documentation (if aligning)

If aligning with reference docs, gather them now:

**Instructions for AI Agent**:

1. Read all reference documents completely
2. Extract key principles, terminology, structure patterns
3. Note any recent changes that triggered this alignment
4. Create `.harmony/.are/alignment-reference.md` summarizing what target docs should align TO

**Template for `.harmony/.are/alignment-reference.md`**:

```markdown
# Alignment Reference Summary

**Reference Source**: <path or name>
**Gathered**: <date>

## Purpose of Reference

<Why this reference is authoritative for the target doc set>

## Key Principles to Align To

| # | Principle | From Reference | Implication for Target Docs |
|---|-----------|----------------|----------------------------|
| 1 | | | |
| 2 | | | |

## Terminology from Reference

| Term | Definition in Reference | Current Usage in Target | Alignment Needed? |
|------|------------------------|------------------------|-------------------|
| | | | Yes/No |

## Structural Patterns from Reference

| Pattern | How Reference Uses It | Should Target Adopt? |
|---------|----------------------|---------------------|
| | | Yes/No/Adapt |

## Recent Changes (if applicable)

| Change | What Was Updated | Impact on Target Docs |
|--------|------------------|----------------------|
| | | |

## Alignment Checklist

When analyzing target docs, check:
- [ ] Uses terminology consistent with reference
- [ ] Reflects principles from reference
- [ ] Structure supports reference concepts
- [ ] No contradictions with reference
- [ ] Cross-references to reference are accurate

## Quotes/Excerpts to Reference

> [Key quote 1 from reference]
> — Source: <file:line>

> [Key quote 2 from reference]
> — Source: <file:line>
```

---

## Phase 1: Setup — Establish Context and Generate Prompt

### Step 1.1: Define Your Parameters

Fill in these values (incorporating alignment intent from Phase 0):

```markdown
## Document Set Improvement Parameters

**Concept/Topic**: <CONCEPT>
<!-- e.g., security, onboarding, performance, reliability, API usage, incident response -->

**Documentation Scope**: <DOC_SCOPE>
<!-- List the documents or describe the scope -->
<!-- e.g., "All files in docs/api/", "The onboarding handbook (5 files)", "Security runbooks" -->

**ARE Tier**: <ARE_TIER>
<!-- ARE-Lite | ARE-Standard | ARE-Full -->

**Alignment Reference** (from Phase 0):
<!-- Leave blank if general quality improvement -->
- Reference: <path or "None">
- Alignment summary created: Yes / No / N/A

**Document List**:
1. path/to/doc1.md
2. path/to/doc2.md
3. path/to/doc3.md
<!-- ... list all documents in the set -->
```

---

### Step 1.2: Gather Concept Context (CRITICAL)

Before analyzing documents, gather context about what `<CONCEPT>` means in THIS organization. This ensures the agent evaluates against the right standards.

**Instructions for AI Agent**:

1. Search the codebase for existing guidelines, policies, and standards related to `<CONCEPT>`
2. Identify reference materials and exemplar documents
3. Document terminology, constraints, and scope boundaries
4. Create `.harmony/.are/concept-context.md` with the gathered information

**Information to Gather**:

#### 1.2.1: Locate Existing Guidelines

Search for files related to `<CONCEPT>`:
```bash
# Search for policy/guideline documents
find . -name "*.md" | xargs grep -l "<CONCEPT>" | head -20

# Look for standards, policies, guidelines
ls -la docs/*policy* docs/*standard* docs/*guideline* 2>/dev/null
```

#### 1.2.2: Identify Reference Materials

| Material Type | Location | Relevance |
|--------------|----------|-----------|
| **Policies** | | Official organizational policies for `<CONCEPT>` |
| **Standards** | | Technical standards to follow |
| **Style Guides** | | Writing/formatting conventions |
| **Exemplar Docs** | | Existing docs that model `<CONCEPT>` well |
| **External References** | | Industry standards, compliance frameworks |

#### 1.2.3: Document Concept Context

Create `.harmony/.are/concept-context.md`:

```markdown
# Concept Context: <CONCEPT>

**Gathered**: <DATE>
**Gathered By**: <AI Agent / Human>

## Definition

**What `<CONCEPT>` means in this organization**:
[1-2 sentence definition specific to this context]

## Guidelines and Policies

| Document | Location | Key Requirements |
|----------|----------|------------------|
| | | |

### Key Requirements Summary
1. [Requirement 1]
2. [Requirement 2]
3. [Requirement 3]

## Terminology

| Canonical Term | Avoid | Definition |
|----------------|-------|------------|
| | | |

## Constraints

| Constraint | Source | Impact on Documentation |
|------------|--------|------------------------|
| | | |

### Compliance Requirements
- [ ] [Compliance framework if applicable]

## Scope and Boundaries

### In Scope
- [What aspects of `<CONCEPT>` ARE covered]

### Out of Scope  
- [What aspects of `<CONCEPT>` are NOT covered]

### Related Concepts
- [Other concepts that interact with this one]

## Stakeholders

| Role | Name/Team | Involvement |
|------|-----------|-------------|
| **Concept Owner** | | Final authority on `<CONCEPT>` guidance |
| **Reviewers** | | Should review `<CONCEPT>` changes |
| **Consumers** | | Primary audience for `<CONCEPT>` docs |

## Best Practices

### Exemplar Documents
| Document | Why It's Good | Patterns to Replicate |
|----------|---------------|----------------------|
| | | |

### Anti-Patterns to Avoid
| Anti-Pattern | Why It's Bad | Correct Approach |
|--------------|--------------|------------------|
| | | |

## Success Criteria for `<CONCEPT>` Documentation

A reader should be able to:
1. [ ] [Success criterion 1]
2. [ ] [Success criterion 2]
3. [ ] [Success criterion 3]

## Notes

[Any additional context, caveats, or considerations]
```

#### 1.2.4: Verification Checklist

Before proceeding, verify:

- [ ] At least 1 policy/guideline document located (or confirmed none exists)
- [ ] Canonical terminology documented
- [ ] Scope boundaries defined
- [ ] At least 1 success criterion defined
- [ ] Concept context file created at `.harmony/.are/concept-context.md`

---

### Step 1.3: Generate Concept-Aligned ARE Loop Prompt

**Now** generate the tailored prompt, informed by concept context AND alignment reference (if applicable).

**Instructions for AI Agent**:

1. Read the concept context from `.harmony/.are/concept-context.md`
2. **If aligning**: Read the alignment reference from `.harmony/.are/alignment-reference.md`
3. Read the meta-prompt at `./concept-aligned-are-loop.meta.md`
4. Generate a concept-aligned ARE Loop prompt that incorporates:
   - The terminology from concept context
   - The constraints and requirements
   - The success criteria
   - The anti-patterns to check for
   - **The alignment principles and patterns from reference docs (if applicable)**
5. Save the generated prompt for use throughout this workflow

**Prompt to use (without alignment reference)**:

```
Using the meta-prompt in concept-aligned-are-loop.meta.md and the concept context 
in .harmony/.are/concept-context.md, generate a concept-aligned ARE Loop prompt for:

- Concept: <CONCEPT>
- Documentation Scope: <DOC_SCOPE>
- ARE Tier: <ARE_TIER>

Incorporate the following from concept-context.md:
- Use the canonical terminology defined there
- Check against the constraints listed
- Evaluate against the success criteria
- Look for the anti-patterns documented

Output only the generated prompt, which I will use to evaluate each document.
```

**Prompt to use (WITH alignment reference)**:

```
Using the meta-prompt in concept-aligned-are-loop.meta.md, the concept context 
in .harmony/.are/concept-context.md, AND the alignment reference in .harmony/.are/alignment-reference.md,
generate a concept-aligned ARE Loop prompt for:

- Concept: <CONCEPT>
- Documentation Scope: <DOC_SCOPE>
- ARE Tier: <ARE_TIER>
- Alignment Target: <REFERENCE_DOC_PATH>

Incorporate the following:
FROM concept-context.md:
- Use the canonical terminology defined there
- Check against the constraints listed
- Evaluate against the success criteria
- Look for the anti-patterns documented

FROM alignment-reference.md:
- Verify alignment with the principles documented
- Check terminology matches the reference
- Evaluate structural patterns against reference
- Flag any contradictions with reference
- Ensure cross-references to reference are accurate

The generated prompt should help identify WHERE target docs diverge from the 
alignment reference and WHAT changes would bring them into alignment.

Output only the generated prompt, which I will use to evaluate each document.
```

### Step 1.4: Save Generated Prompt

Store the generated concept-aligned prompt as a working artifact:

```markdown
## Generated Concept-Aligned ARE Loop Prompt

[Paste the generated prompt here]
```

---

## Phase 2: Document Set Analysis

Before analyzing individual documents, identify cross-cutting issues across the entire set.

### Step 2.1: Create Document Inventory

| # | Document | Purpose | Last Updated | Primary Audience |
|---|----------|---------|--------------|------------------|
| 1 | | | | |
| 2 | | | | |

### Step 2.2: Run Document Set Analysis

Using [are-document-sets.md](./are-document-sets.md), analyze the set for:

**Instructions for AI Agent**:

1. Read all documents in the set (skim for structure, not deep analysis yet)
2. Complete each analysis section below
3. Identify set-level issues before diving into individual documents

#### Terminology Consistency Check

| Term | Variants Found | Preferred | Docs to Update |
|------|----------------|-----------|----------------|
| | | | |

#### Duplication Analysis

| Content | Found In | Action | Priority |
|---------|----------|--------|----------|
| | | Consolidate / Keep / Reconcile | H/M/L |

#### Cross-Reference Check

| Source Doc | Reference | Target Doc | Valid? | Bidirectional? |
|------------|-----------|------------|--------|----------------|
| | | | | |

#### Concept Distribution Check

For your specific `<CONCEPT>`:

| `<CONCEPT>` Aspect | Primary Owner Doc | Secondary Docs | Gap? |
|--------------------|-------------------|----------------|------|
| | | | |

#### Entry Point Analysis

| Question | Answer | Action if No |
|----------|--------|--------------|
| Is there a single "start here" for `<CONCEPT>`? | Yes/No | |
| Is the `<CONCEPT>` reading path clear? | Yes/No | |
| Are `<CONCEPT>` prerequisites stated? | Yes/No | |

#### Minimum Viable Documentation for `<CONCEPT>`

| Document | Purpose for `<CONCEPT>` | Read Time | Day 1 Essential? |
|----------|------------------------|-----------|------------------|
| | | min | Yes/No |

**Day 1 `<CONCEPT>` docs total read time**: ___ min (target: ≤60 min)

### Step 2.3: Prioritize Documents for Improvement

Based on set analysis, prioritize which documents to improve first:

| Priority | Document | Reason | Estimated Effort |
|----------|----------|--------|------------------|
| 1 | | | |
| 2 | | | |
| 3 | | | |

**Prioritization Criteria**:
- Documents with `<CONCEPT>` gaps are higher priority
- Documents referenced by many others are higher priority
- Entry point documents are higher priority
- Documents with stop-the-line issues are highest priority

---

## Phase 3: Individual Document Iteration

Process each document through the ARE Loop, in priority order.

### Step 3.0: Iteration Setup

For each document, you will run through:
1. **Analyze** → Using concept-aligned prompt + standard analysis
2. **Refine** → Make changes based on gaps identified
3. **Evaluate** → Measure impact and decide next steps

**Iteration Tracking**:

| Document | Cycle | Phase | Status | Started | Completed |
|----------|-------|-------|--------|---------|-----------|
| doc1.md | 1 | Analyze | ☐ | | |
| doc1.md | 1 | Refine | ☐ | | |
| doc1.md | 1 | Evaluate | ☐ | | |
| doc2.md | 1 | Analyze | ☐ | | |
| ... | | | | | |

---

### Step 3.1: ANALYZE Phase (per document)

**Instructions for AI Agent**:

For each document in priority order:

1. **Read the document** completely
2. **Apply the concept-aligned prompt** (from Phase 1) to analyze through `<CONCEPT>` lens
3. **Run standard analysis** using [01-are-analyze-single-doc.md](./01-are-analyze-single-doc.md)
4. **Complete optional audits** if relevant using [02-are-analyze-audits.md](./02-are-analyze-audits.md)

**Produce these artifacts**:

```markdown
## Analyze: [Document Name]

### Evaluation Context

| Field | Value |
|-------|-------|
| Document | [path] |
| Version | |
| Cycle | 1 |
| Date | |
| Tier | <ARE_TIER> |

### Concept-Focused Analysis (`<CONCEPT>`)

#### Concept Coverage

| `<CONCEPT>` Aspect | Coverage | Depth | Gap? |
|--------------------|----------|-------|------|
| | Present / Missing / Partial | Superficial / Adequate / Deep | |

#### Concept-Specific Gaps

| ID | `<CONCEPT>` Issue | Severity | Category |
|----|-------------------|----------|----------|
| C1 | | H/M/L | Missing / Outdated / Unclear / Inconsistent |

### Standard Gap Analysis

| ID | Category | Dimension | Description | Severity | Tag |
|----|----------|-----------|-------------|----------|-----|
| G1 | | | | | |

### Combined Priority List

| Rank | Gap ID | Description | Impact | Effort |
|------|--------|-------------|--------|--------|
| 1 | | | H/M/L | H/M/L |

### Cycle Scope

**In Scope for This Cycle**: [List gap IDs]
**Deferred**: [List gap IDs with reasons]
```

---

### Step 3.2: REFINE Phase (per document)

**Instructions for AI Agent**:

1. **Prioritize gaps** from Analyze phase
2. **Generate solutions** using [03-are-refine.md](./03-are-refine.md)
3. **Implement changes** focusing on `<CONCEPT>` improvements
4. **Validate changes** don't break cross-references or consistency

**Produce these artifacts**:

```markdown
## Refine: [Document Name]

### Ideation Summary

| Gap ID | Options Considered | Selected Solution | Rationale |
|--------|-------------------|-------------------|-----------|
| | | | |

### Changes Made

| Gap ID | Change Type | What Changed | Section |
|--------|-------------|--------------|---------|
| | Add/Update/Remove/Restructure | | |

### `<CONCEPT>` Improvements

| Before | After | `<CONCEPT>` Benefit |
|--------|-------|---------------------|
| | | |

### Quick Validation

- [ ] All cross-references still valid
- [ ] Terminology consistent with set
- [ ] No new contradictions introduced
- [ ] `<CONCEPT>` guidance clearer than before
- [ ] Linting passed
- [ ] Links checked
```

---

### Step 3.3: EVALUATE Phase (per document)

**Instructions for AI Agent**:

1. **Re-read the document** fresh
2. **Score dimensions** using [04-are-evaluate.md](./04-are-evaluate.md)
3. **Run concept-specific stress tests** (from generated prompt)
4. **Check quality gates** using [06-are-quality-gates.md](./06-are-quality-gates.md)
5. **Decide** whether to continue, standardize, pivot, or archive

**Produce these artifacts**:

```markdown
## Evaluate: [Document Name]

### Dimension Scores

| Dimension | Before | After | Target | Met? |
|-----------|--------|-------|--------|------|
| Clarity | | | ≥4 | |
| Alignment | | | ≥4 | |
| Leanness | | | ≥3 | |
| Implementability | | | ≥4 | |
| Coherence | | | ≥4 | |

### Concept-Specific Success Criteria

| Criterion | Met? | Evidence |
|-----------|------|----------|
| Tasks easier: [specific task related to `<CONCEPT>`] | ✅/❌ | |
| Questions gone: [specific question about `<CONCEPT>`] | ✅/❌ | |
| Failures prevented: [specific `<CONCEPT>` failure mode] | ✅/❌ | |

### Concept Stress Tests

| Test | Result | Notes |
|------|--------|-------|
| 30-Second Pitch (for `<CONCEPT>`) | Pass/Fail | |
| Day 1 Test (can apply `<CONCEPT>` guidance?) | Pass/Fail | |
| Solo User Test (implement `<CONCEPT>` without help?) | Pass/Fail | |
| [Additional tests based on tier] | | |

### Stop-the-Line Check

| Trigger | Active? |
|---------|---------|
| Broken critical path | ☐ Yes / ☐ No |
| Factual inaccuracy | ☐ Yes / ☐ No |
| Security/safety risk | ☐ Yes / ☐ No |
| `<CONCEPT>`-specific blocker | ☐ Yes / ☐ No |

### Decision

**Verdict**: ☐ Ready | ☐ Needs Work | ☐ Blocked | ☐ Not Viable

**Decision**: ☐ Standardize | ☐ Continue (Cycle 2) | ☐ Pivot | ☐ Archive

**If continuing, next cycle scope**: [Brief description]
```

---

### Step 3.4: Repeat for Each Document

After completing one document:

1. **Update iteration tracking** (Step 3.0)
2. **Move to next priority document**
3. **Repeat Steps 3.1-3.3**

**Batch Processing Tips**:

- Process no more than 2-3 documents in a session before taking a break
- After each document, check if set-level issues need updating
- If you discover new terminology inconsistencies, update the set analysis

---

## Phase 4: Set-Level Reconciliation

After processing all documents individually, reconcile at the set level.

### Step 4.1: Update Set Analysis

Re-run the document set analysis from Phase 2 to verify:

- [ ] Terminology is now consistent across all docs
- [ ] Duplication has been consolidated or reconciled
- [ ] Cross-references are all valid and bidirectional where needed
- [ ] `<CONCEPT>` coverage is complete across the set
- [ ] Entry points and navigation are clear

### Step 4.2: Validate Concept Coverage

Using the concept coverage analysis from Phase 1's generated prompt:

| `<CONCEPT>` Aspect | Primary Doc | Coverage | Depth | Notes |
|--------------------|-------------|----------|-------|-------|
| | | ✅/⚠️/❌ | S/A/D | |

**Overall `<CONCEPT>` Coverage**: ___% of aspects adequately covered

### Step 4.3: Document Set Stress Tests

Run set-level stress tests:

| Test | Result | Notes |
|------|--------|-------|
| Can navigate from any doc to `<CONCEPT>` guidance? | Pass/Fail | |
| Is there one authoritative source for each `<CONCEPT>` aspect? | Pass/Fail | |
| Can complete Day 1 `<CONCEPT>` learning in ≤1 hour? | Pass/Fail | |
| Would a new team member understand `<CONCEPT>` from docs alone? | Pass/Fail | |

### Step 4.4: Final Decision

| Document | Cycles | Final Status | Notes |
|----------|--------|--------------|-------|
| doc1.md | | Standardized / Needs More / Archived | |
| doc2.md | | | |

**Set-Level Verdict**: ☐ Ready for Publication | ☐ Needs More Work | ☐ Major Issues

---

## Phase 5: Documentation and Handoff

### Step 5.1: Create Summary Report

```markdown
## Document Set Improvement Summary

**Set**: <DOC_SCOPE>
**Concept Focus**: <CONCEPT>
**Tier**: <ARE_TIER>
**Date Completed**: YYYY-MM-DD

### Documents Processed

| Document | Cycles | Outcome | Key Changes |
|----------|--------|---------|-------------|
| | | | |

### `<CONCEPT>` Improvements

- Before: [Summary of initial state]
- After: [Summary of improved state]
- Key wins: [List main improvements]

### Remaining Gaps

| Gap | Document | Priority | Recommendation |
|-----|----------|----------|----------------|
| | | H/M/L | |

### Re-Evaluation Triggers

| Trigger | Threshold | Owner |
|---------|-----------|-------|
| Time-based | Every ___ months | |
| `<CONCEPT>` change | When `<CONCEPT>` tooling/standards change | |
| Incident-driven | After `<CONCEPT>`-related incident | |
| Feedback spike | 3+ similar questions about `<CONCEPT>` | |

### Lessons Learned

- [What worked well]
- [What to do differently next time]
```

### Step 5.2: Archive Artifacts

All artifacts are stored during the workflow in `<TARGET_DOC_DIR>/.harmony/.are/`:

```
<TARGET_DOC_DIR>/
└── .harmony/
    └── .are/
        ├── are-config.json               # Workflow configuration
        ├── are-progress.json             # Progress tracking
        ├── are-session-log.md            # Session history
        ├── alignment-reference.md        # Phase 0.3 reference summary (if aligning)
        ├── concept-context.md            # Phase 1.2 guidelines, terminology, constraints
        ├── concept-aligned-prompt.md     # Phase 1.3 generated prompt
        └── artifacts/
            ├── set-analysis.md           # Phase 2 results
            ├── doc1-cycle1-analysis.md   # Per-doc artifacts
            ├── doc1-cycle1-changes.md
            ├── doc1-cycle1-evaluation.md
            ├── doc2-cycle1-analysis.md
            ├── ...
            ├── reconciliation.md         # Phase 4 results
            └── summary.md                # Phase 5 report
```

**Note**: These files are particularly valuable for future use:
- `alignment-reference.md` - Reuse when aligning other doc sets to same reference
- `concept-context.md` - Reuse for future ARE runs on same concept
- Both support onboarding and maintaining consistency

**Archiving completed runs**: After completing an ARE Loop run, you may want to move the
`.harmony/.are/` directory to a dated archive location or keep it in place for reference.

---

## Quick Reference: Workflow Phases

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    DOCUMENT SET IMPROVEMENT WORKFLOW                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  PHASE 0: DIRECTION SETTING                                             │
│  ├─ 0.1 Prompt user for alignment intent                                │
│  ├─ 0.2 Capture alignment parameters                                    │
│  └─ 0.3 Gather alignment reference (if aligning to other docs)          │
│                                                                         │
│  PHASE 1: SETUP                                                         │
│  ├─ 1.1 Define parameters (concept, scope, tier)                        │
│  ├─ 1.2 GATHER CONCEPT CONTEXT ← Guidelines, terminology, constraints   │
│  ├─ 1.3 Generate concept-aligned ARE prompt (using context + reference) │
│  └─ 1.4 Save generated prompt                                           │
│                                                                         │
│  PHASE 2: SET ANALYSIS                                                  │
│  ├─ 2.1 Create document inventory                                       │
│  ├─ 2.2 Run document set analysis                                       │
│  └─ 2.3 Prioritize documents                                            │
│                                                                         │
│  PHASE 3: INDIVIDUAL ITERATION (repeat for each doc)                    │
│  ├─ 3.1 ANALYZE: Concept-focused + alignment-aware analysis             │
│  ├─ 3.2 REFINE: Implement changes                                       │
│  ├─ 3.3 EVALUATE: Score, test, decide                                   │
│  └─ 3.4 Move to next document                                           │
│                                                                         │
│  PHASE 4: SET RECONCILIATION                                            │
│  ├─ 4.1 Update set analysis                                             │
│  ├─ 4.2 Validate concept coverage AND alignment with reference          │
│  ├─ 4.3 Set-level stress tests                                          │
│  └─ 4.4 Final decision                                                  │
│                                                                         │
│  PHASE 5: DOCUMENTATION                                                 │
│  ├─ 5.1 Create summary report                                           │
│  └─ 5.2 Archive artifacts                                               │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Alignment Reference Checklist (if aligning)

Before proceeding past Phase 0, ensure `.harmony/.are/alignment-reference.md` contains:

- [ ] Purpose of reference documented
- [ ] Key principles extracted with implications
- [ ] Terminology from reference documented
- [ ] Structural patterns noted
- [ ] Recent changes documented (if applicable)
- [ ] Alignment checklist created

### Concept Context Checklist

Before proceeding past Phase 1, ensure `.harmony/.are/concept-context.md` contains:

- [ ] Definition of concept in organizational context
- [ ] Located guidelines/policies (or confirmed none exist)
- [ ] Canonical terminology documented
- [ ] Constraints and compliance requirements
- [ ] Scope boundaries (in/out of scope)
- [ ] Stakeholders identified
- [ ] At least 1 exemplar or anti-pattern documented
- [ ] Success criteria for documentation

---

## Prompt Files Used in This Workflow

| Phase | Prompt File | Purpose |
|-------|-------------|---------|
| 1.2 | (Search codebase) | Gather concept context - guidelines, terminology, constraints |
| 1.3 | [concept-aligned-are-loop.meta.md](./concept-aligned-are-loop.meta.md) | Generate tailored prompt |
| 2 | [are-document-sets.md](./are-document-sets.md) | Set-level analysis |
| 3.1 | [01-are-analyze-single-doc.md](./01-are-analyze-single-doc.md) | Standard analysis |
| 3.1 | [02-are-analyze-audits.md](./02-are-analyze-audits.md) | Optional audits |
| 3.2 | [03-are-refine.md](./03-are-refine.md) | Refine phase |
| 3.3 | [04-are-evaluate.md](./04-are-evaluate.md) | Evaluate phase |
| 3.3 | [05-are-stress-tests.md](./05-are-stress-tests.md) | Stress tests |
| 3.3 | [06-are-quality-gates.md](./06-are-quality-gates.md) | Quality gates |
| - | [agent-harness.md](./agent-harness.md) | Session protocol for AI agents |
| - | [07-are-templates.md](./07-are-templates.md) | Blank templates |
| - | [09-are-best-practices.md](./09-are-best-practices.md) | Troubleshooting |

---

*This workflow orchestrates the complete document set improvement process. Start with Phase 1 and proceed sequentially.*

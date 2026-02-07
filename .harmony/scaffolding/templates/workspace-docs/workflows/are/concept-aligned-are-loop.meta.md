# Concept-Aligned ARE Loop Meta Prompt

You are a documentation methodology expert.

This repository includes an ARE Loop methodology in `.harmony/orchestration/workflows/are/`, which defines a generic **Analyze → Refine → Evaluate (ARE) Loop** for documentation improvement. You do **not** need to restate that methodology; instead, you will generate a **concept-aligned prompt** that *supplements* it.

Your job is to produce **one ready-to-use prompt** that another AI assistant can use to run an ARE Loop focused on a specific concept across a given documentation scope.

---

## Inputs (for the prompt you generate)

Assume the user of your generated prompt will provide:

- **Concept/Topic**: `<CONCEPT>`  
  - e.g., security, onboarding, performance, reliability, incident response, experimentation
- **Documentation Scope**: `<DOC_SCOPE>`  
  - e.g., single doc, doc set, handbook section, runbooks, API reference, onboarding guide
- **ARE Tier**: `<ARE_TIER>`  
  - one of: ARE-Lite / ARE-Standard / ARE-Full

The prompt you generate must include these as explicit placeholders.

---

## Requirements for the prompt you generate

### 1. Frame the goal

- Clearly state that the user wants to **apply the ARE Loop through the lens of `<CONCEPT>`** to improve `<DOC_SCOPE>`.
- Instruct the assistant to respect `<ARE_TIER>` when choosing depth, rigor, and time investment.

### 2. Anchor on the ARE phases

Structure the work explicitly into the three phases, mapping to PLAN → SHIP → LEARN:

- **Analyze (PLAN)**  
  - Identify gaps, weaknesses, and opportunities **specifically related to `<CONCEPT>`** in `<DOC_SCOPE>`.
- **Refine (SHIP)**  
  - Propose and prioritize concrete changes to better support `<CONCEPT>`.
- **Evaluate (LEARN)**  
  - Define how to measure whether the changes actually improved how `<DOC_SCOPE>` serves `<CONCEPT>`.

### 3. Make the checks concept-aware

Adapt generic ARE documentation checks to be concept-specific:

#### Core Checks (Always Include)

| ARE Pattern | Concept-Aware Adaptation |
|-------------|--------------------------|
| **Gap Identification** | Missing `<CONCEPT>` coverage, missing `<CONCEPT>` examples, missing guardrails, unclear responsibilities, ambiguous definitions related to `<CONCEPT>` |
| **Completeness Check** | Contradictions about `<CONCEPT>`, inconsistent `<CONCEPT>` terminology, references to `<CONCEPT>` that don't match current practice |
| **Leanness Assessment** | Unnecessary `<CONCEPT>` ceremony or over-complexity that doesn't add value |
| **Coherence Check** | Is `<CONCEPT>` guidance consistent across all docs in scope? |

#### Optional Checks (Include Based on Tier and Relevance)

| ARE Pattern | Concept-Aware Adaptation | When to Include |
|-------------|--------------------------|-----------------|
| **Guarantee/Promise Audit** | Are claims about `<CONCEPT>` (e.g., "this ensures security," "this improves performance by X%") substantiated? | ARE-Full or when `<DOC_SCOPE>` makes bold `<CONCEPT>` claims |
| **Differentiation Check** | If docs claim a unique approach to `<CONCEPT>`, is that differentiation clear and evidenced? | When docs position against alternatives |
| **Process Overhead Audit** | For `<CONCEPT>`-related processes (e.g., security review workflow, performance testing steps), count steps and estimate time—is it proportionate? | When `<DOC_SCOPE>` describes `<CONCEPT>` workflows |
| **Prerequisite Knowledge Check** | What `<CONCEPT>` knowledge is assumed? Is it stated? Are resources linked? | ARE-Standard+ |
| **Tool/Dependency Currency Check** | Are `<CONCEPT>`-related tools mentioned still current best practice? | ARE-Standard+ |

#### Concept Coverage Analysis (Always Include for ARE-Standard+)

Ask the assistant to evaluate whether `<DOC_SCOPE>` covers all aspects of `<CONCEPT>`:

```markdown
| `<CONCEPT>` Aspect | Coverage in `<DOC_SCOPE>` | Depth (Superficial/Adequate/Deep) | Gap? |
|--------------------|---------------------------|-----------------------------------|------|
```

This ensures the concept isn't just mentioned but operationalized.

### 4. Apply stress tests through the `<CONCEPT>` lens

For each relevant ARE stress test, frame it through `<CONCEPT>`:

| Stress Test | Concept-Aware Framing |
|-------------|----------------------|
| **30-Second Pitch** | Can you explain how `<DOC_SCOPE>` handles `<CONCEPT>` in 30 seconds? |
| **Day 1 Test** | Can a new reader apply `<CONCEPT>` guidance on their first day? |
| **Solo User Test** | Can someone implement `<CONCEPT>` without asking colleagues? |
| **Emergency/Hotfix Test** | Can someone follow `<CONCEPT>` guidance under time pressure? |
| **Team Change Test** | Can a new team member understand `<CONCEPT>` practices from docs alone? |
| **Conflict Resolution Test** | If two sections give conflicting `<CONCEPT>` guidance, is resolution clear? |
| **Remote/Async Test** | Does `<CONCEPT>` guidance work without synchronous explanation? |
| **Budget/Constraint Test** | Can `<CONCEPT>` practices be followed with minimal budget/tools? |
| **Legacy/Brownfield Test** | Does `<CONCEPT>` guidance work for existing systems, not just greenfield? |
| **Vendor Dependency Test** | Are `<CONCEPT>`-related tool dependencies (required vs. optional) clear? |
| **Audit/Compliance Test** | Can external parties verify `<CONCEPT>` practices from this doc? |

**Tier Guidance:**
- ARE-Lite: 30-Second Pitch only
- ARE-Standard: Add Day 1, Solo User, Emergency/Hotfix, Team Change
- ARE-Full: Add all remaining tests as relevant to `<CONCEPT>`

### 5. Request concrete outputs

The prompt you generate should ask the assistant to produce:

#### Required Outputs (All Tiers)

1. **Concept-Focused Gap Summary**
   - The key issues in how `<DOC_SCOPE>` handles `<CONCEPT>`
   - Categorized by: Missing content / Outdated content / Unclear content / Inconsistent content

2. **Prioritized Change List**
   - Specific edits or additions to make documentation better for `<CONCEPT>`
   - Grouped by impact/effort or tagged by cycle (this cycle / next cycle / future)

3. **Concept-Specific Success Criteria**
   - **Tasks that should become easier**: e.g., "A developer can threat-model a new feature"
   - **Questions that should disappear**: e.g., "Where do I find the security checklist?"
   - **Failure modes that should be prevented**: e.g., "Shipping without auth review"

#### Optional Outputs (ARE-Standard+)

4. **Concept Coverage Analysis Table**
   - All aspects of `<CONCEPT>` with coverage assessment

5. **Implementation Roadmap** (when 5+ `<CONCEPT>`-related gaps exist)
   - Quick Wins (this cycle)
   - Medium-Term (2-3 cycles)
   - Strategic (future)

6. **Concept-Specific Stress Test Results**
   - Pass/Fail for each relevant test with notes

#### Optional Outputs (ARE-Full)

7. **Concept Depth Evaluation**
   - For each `<CONCEPT>` aspect: Is coverage superficial, adequate, or deep?
   - Recommendations for where depth should increase

8. **Concept Anti-Patterns**
   - What NOT to do regarding `<CONCEPT>` that should be documented?
   - Common mistakes that readers might make

9. **Stop-the-Line Triggers for `<CONCEPT>`**
   - What `<CONCEPT>`-related issues are hard blockers? (e.g., security: "documented password in plaintext")

### 6. Include concept-specific re-evaluation triggers

Ask the assistant to define when `<CONCEPT>` coverage should be re-evaluated:

| Trigger | Example for `<CONCEPT>` |
|---------|-------------------------|
| **Time-based** | Every N months, review `<CONCEPT>` guidance |
| **Major update** | When `<CONCEPT>` tooling or standards change |
| **Incident-driven** | After a `<CONCEPT>`-related incident |
| **Feedback spike** | 3+ similar questions about `<CONCEPT>` |
| **Dependency update** | When `<CONCEPT>`-related tools/APIs change |

### 7. Stay generic and lean

- Do **not** introduce Harmony-specific pillars, kits, or methodology jargon in the generated prompt.
- Keep the instructions applicable to arbitrary documentation or doc sets.
- Avoid adding heavy ceremony; keep it usable in a 1-3 cycle improvement effort.
- Scale rigor to `<ARE_TIER>`—don't require ARE-Full outputs for ARE-Lite runs.

---

## Output format

- Output **only** the final concept-aligned ARE Loop prompt text, with clear placeholders for `<CONCEPT>`, `<DOC_SCOPE>`, and `<ARE_TIER>`.
- Do not include explanations, commentary, or meta-reasoning in your answer—just the prompt another assistant should run.

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.1.0 | 2025-12-10 | **Pattern alignment with ARE v2.5.0**: Added concept-aware adaptations for all optional ARE checks (Guarantee/Promise Audit, Differentiation Check, Process Overhead Audit, Prerequisite Knowledge Check, Tool Currency Check); added Concept Coverage Analysis table template; expanded stress tests with concept-aware framing for all 12 ARE stress tests; added tier guidance for stress test selection; expanded required outputs to include Concept-Specific Success Criteria; added optional outputs: Concept Depth Evaluation, Concept Anti-Patterns, Stop-the-Line Triggers for concept; added concept-specific re-evaluation triggers section |
| 1.0.0 | 2025-12-10 | Initial release |

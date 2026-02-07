---
description: Clear, accurate, human-readable technical documentation
globs:
  - docs/**
  - .harmony/.human/**
alwaysApply: false
---

# Docs for Humans

You are a **technical documentation writer for humans**. Your job is to produce docs that are **easy to understand and easy to use**. Optimize for **readability**, **accuracy**, **conciseness**, **good organization**, and **strong user focus** (help the reader complete a task).

## Task

Write human-facing technical documentation for:

- Document type: **[SYSTEM | FEATURE | API | PROCESS | TUTORIAL | REFERENCE | TROUBLESHOOTING | OTHER]** (choose one)
- Target audience: **[role/persona, experience level, context]**
- Reader goal(s): **[what the reader is trying to accomplish]**
- Success criteria: **[what a reader can do/understand after reading]**
- Canonical sources: **[links, specs, code, notes—all definitive references]**
- Document structure: **[PASTE THE MANDATORY HEADINGS OR TEMPLATE HERE—must follow exactly]**

If any required item above is missing or unclear, ask **up to 5** targeted questions and **STOP** (do not write the documentation yet).

## Non-negotiable constraints

1. **Optimize for the reader**: write for the target audience and their goal; keep “why” only when it changes decisions or prevents mistakes.
2. **Be accurate**: do not guess. If sources conflict or are incomplete, document the conflict and ask for resolution if it blocks correctness.
3. **Be scannable**: use clear headings, short paragraphs, bullet lists, diagrams, and tables where helpful. Put the most important info first.
4. **Define terms once** and use them consistently (no synonym drift). Define acronyms on first use.
5. **Make prerequisites explicit**: required access, environments, versions, permissions, and any setup the reader must have done already.
6. **Use actionable instructions**: steps must be concrete and reproducible (commands, UI paths, exact fields). Include expected outputs or “what you should see” where it prevents confusion.
7. **Include examples** for non-obvious concepts and key workflows. Examples should be minimal, copy/pasteable, and include inputs + outputs.
8. **Call out risk and irreversibility**: clearly label destructive actions, security/privacy concerns, and safe alternatives.
9. **Stay concise without becoming vague**: remove fluff, but keep details needed to prevent misunderstandings and common mistakes.

## Method (must follow)

### Step 1 — Identify missing critical info

- If any required item is missing/unclear (would block a correct doc or create high risk of misunderstanding), ask **up to 5** precise questions.
- Otherwise proceed, but list assumptions explicitly in **“Assumptions & Open Questions”**.

### Step 2 — Write using the provided structure

- Follow the **provided structure exactly** (headings/order/required sections).
- Do not invent new sections or reorder the template, unless the provided structure is missing a required section.
- Within that structure, prioritize: reader goal → prerequisites → procedure/reference → examples → troubleshooting/edge cases.

### Step 3 — Readability + correctness pass (required before finalizing)

Verify:

- A reader can complete the task **without extra context** (no hidden steps or unstated prerequisites).
- Steps are **complete and in the right order**; terminology is consistent.
- All constraints (versions, units, defaults, limits, permissions) are explicit where they matter.
- Any “should/avoid” advice is backed by a concrete reason or scenario.

### Step 4 — Concision + polish pass (only after correctness)

- Tighten wording; replace paragraphs with bullets/tables where it improves scanning.
- Remove redundancy and filler; keep the doc **short, but complete**.

## Output requirements

- If Step 1 finds missing/unclear required info: output **only** your question list (no documentation).
- Otherwise: output **only** the documentation (no meta commentary).
- Use the **provided structure exactly**.
- Include an **“Assumptions & Open Questions”** section at the end **unless** the provided structure already contains it (in that case, fill it there and do not duplicate).

Now write the documentation.

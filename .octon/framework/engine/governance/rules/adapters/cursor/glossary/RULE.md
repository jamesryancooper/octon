---
description: Consistent, unambiguous terminology definitions
globs:
  - "docs/**/*.md"
  - "**/README.md"
  - ".octon/**/*.md"
  - ".octon/**/*.md"
  - "**/GLOSSARY.md"
alwaysApply: false
---

# Glossary & Terminology Consistency

You are a **terminology guardian**. You MUST ensure all documentation uses terms **consistently** according to the canonical glossary at `docs/GLOSSARY.md`. When adding new terms, you MUST define them in the glossary first.

## Scope

This rule applies to:

- **All documentation files**: using terms consistently
- **GLOSSARY.md**: adding or updating term definitions

---

## Part 1: Using Terms in Documentation

When writing or editing any documentation, you MUST:

1. **Use glossary terms exactly as defined.** You MUST NOT paraphrase or use synonyms for defined terms.
   - ✓ "The Driver owns implementation decisions."
   - ✗ "The lead developer owns implementation decisions." (if "Driver" is the glossary term)

2. **Use abbreviations only after they are defined** in the Abbreviations table. On first use in a document, you MAY expand the abbreviation parenthetically: "Architecture Decision Record (ADR)".

3. **Check the glossary before introducing new terminology.** If a term doesn't exist:
   - Search for synonyms that might already be defined.
   - If no match, add the term to the glossary (see Part 2) before using it.

4. **Respect quantitative thresholds.** If the glossary defines thresholds (e.g., tier durations, limits), you MUST use those exact values.

5. **Flag ambiguous terms.** If you encounter a term that could be confused with a glossary term but means something different, you MUST disambiguate explicitly.

---

## Part 2: Adding or Updating Glossary Entries

When editing `**/GLOSSARY.md`, you MUST follow these rules:

### Required inputs

- Term(s) to define: **[term name(s)]**
- Usage context: **[where/how this term is used in the codebase or methodology]**
- Related terms: **[existing glossary terms that interact with this term]**
- Canonical sources: **[specs, code, docs that establish the term's meaning]**

If any required item is missing or unclear, you MUST ask **up to 3** targeted questions and then **STOP**.

### Constraints for glossary entries

1. Each term MUST have **exactly one definition**. You MUST NOT define the same concept under multiple names.
2. Definitions MUST be **operational**: a reader can determine whether something qualifies as the term.
3. Use **Title Case** for term headings; use exact match when referencing in prose.
4. Abbreviations MUST be added to the **Abbreviations** table.
5. Include **quantitative thresholds** (durations, limits, counts) in the definition when they affect meaning.
6. You MUST NOT add standard industry terms unless Octon uses them with a **specific, non-standard meaning**.
7. Definitions MUST NOT include implementation details that could change.

### Glossary structure (MUST follow)

```markdown
---
title: Glossary
description: Definitions of key terms used in the Octon methodology.
---

# Glossary

[One-sentence purpose statement.]

---

## [Category Name]

### [Term]
[Definition: 1-3 sentences, operational, includes thresholds if applicable.]

---

## Abbreviations

| Abbrev | Meaning |
|--------|---------|
| [ABBR] | [Full expansion] |

---

## See Also

- [Link] — [description]
```

### Category order

1. Core Concepts
2. Roles
3. Development Flow
4. Workflow States
5. Quality & Safety
6. Security
7. Deployment
8. AI-Specific
9. [Domain-specific as needed]
10. Abbreviations (always last before See Also)

### Method for adding terms

1. **Check for conflicts**: Search for the term or synonyms. Update existing entries rather than creating duplicates.
2. **Write the definition**: Place in correct category; answer "How do I know if X qualifies?"
3. **Update cross-references**: Verify references to/from other terms; add abbreviation if applicable.
4. **Concision pass**: ≤3 sentences unless a table is required.

---

## Output requirements

- When editing documentation: apply terminology rules silently (no commentary needed).
- When editing GLOSSARY.md with missing info: output **only** your question list.
- When editing GLOSSARY.md successfully: output **only** the updated section(s).

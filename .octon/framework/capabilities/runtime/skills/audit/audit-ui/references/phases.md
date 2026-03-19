---
title: Behavior Phases
description: Phase-by-phase instructions for the audit-ui skill.
---

# Behavior Phases

Detailed instructions for each phase of the UI audit workflow.

## Phase 1: Fetch Ruleset

**Goal:** Retrieve and parse the external design guidelines into structured rules.

### Steps

1. WebFetch the URL specified by `ruleset_url` parameter (or default URL)
2. Parse the markdown content into a structured list of rules
3. For each rule, extract:
   - Rule identifier or heading
   - Category (accessibility, performance, UX, etc.)
   - Priority level (if specified)
   - Description and rationale
   - Code patterns to check for (positive and negative examples)
4. Log the number of rules parsed and their category distribution

### Failure Handling

- If WebFetch fails (network error, 404, timeout): **stop execution** — the skill cannot operate without a ruleset
- If the content is not parseable as a rule set: warn the user, attempt best-effort extraction of any identifiable rules
- Log the fetch result (success/failure, URL, response status, rule count)

## Phase 2: Discover Files

**Goal:** Enumerate all UI files within scope.

### Steps

1. Parse `file_types` parameter into a list of extensions (default: tsx, jsx, html, css, vue, svelte)
2. Glob for matching files within `target` directory
3. Build a scope manifest listing all files to be scanned
4. Check scope size against threshold (500 files)

### Scope Thresholds

| Metric | Threshold | Action |
|--------|-----------|--------|
| Total UI files | >500 | Warn, offer to narrow scope |
| Empty scope | 0 files | Report immediately — no files to audit |

## Phase 3: Scan & Classify

**Goal:** Check each file against parsed rules and record violations.

### Steps

1. For each file in scope:
   a. Read the file content
   b. Check against each applicable rule (filter by file type — CSS rules for CSS files, component rules for JSX/TSX, etc.)
   c. For each violation found, record:
      - File path and line number (`file:line` format)
      - Rule reference (category and rule identifier)
      - Severity (CRITICAL, HIGH, MEDIUM, LOW)
      - Description of the violation
      - Suggested fix (brief)
2. Track clean files (files with no violations) separately
3. Do not modify any source files

### Severity Assignment

Assign severity based on the violation's impact category:

- **CRITICAL:** Accessibility barriers (missing alt text, no keyboard nav, missing labels)
- **HIGH:** Significant UX degradation (no focus states, missing error messages, contrast)
- **MEDIUM:** Design consistency (spacing, dark mode, non-standard patterns)
- **LOW:** Cosmetic (typography, minor spacing, style preferences)

## Phase 4: Report

**Goal:** Generate structured findings report and execution log.

### Report Structure

```markdown
# UI Audit Report — YYYY-MM-DD

## Executive Summary
- Files scanned: N
- Violations found: N (by severity)
- Rules applied: N
- Ruleset source: [URL]

## Findings

### CRITICAL
- file:line — Rule: [rule-id] — Description

### HIGH
...

### MEDIUM
...

### LOW
...

## Clean Files
- List of files with no violations (coverage proof)

## Ruleset Metadata
- Source URL
- Fetch timestamp
- Rule count by category
```

### Log Structure

Write execution log to `/.octon/state/evidence/runs/skills/audit-ui/{run_id}.md`:

```markdown
# audit-ui — {run_id}

- **Date:** YYYY-MM-DD HH:MM
- **Target:** {target}
- **File types:** {file_types}
- **Ruleset URL:** {ruleset_url}
- **Files scanned:** N
- **Violations:** N (C: N, H: N, M: N, L: N)
- **Duration:** estimated
- **Status:** complete | failed | partial
```

Update `/.octon/state/evidence/runs/skills/audit-ui/index.yml` and `/.octon/state/evidence/runs/skills/index.yml` with the new entry.

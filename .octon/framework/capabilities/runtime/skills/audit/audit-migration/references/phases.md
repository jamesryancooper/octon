---
behavior:
  phases:
    - name: "Configure"
      steps:
        - "Parse migration manifest (inline YAML or file path)"
        - "Validate all mappings have old and new fields"
        - "Resolve exclusion zones to concrete paths"
        - "Enumerate scope manifest (complete sorted file list)"
        - "Identify key operational files for cross-reference layer"
        - "Set severity threshold from parameters"
        - "If partition parameter set: apply file_filter to narrow scope manifest"
        - "If partition parameter set: record partition metadata (name, filter, mode)"
    - name: "Grep Sweep"
      isolation: true
      steps:
        - "Generate 8 search variations per mapping"
        - "Run Grep for each variation across scope (sorted file order)"
        - "Record all matches with file:line"
        - "Filter out excluded files"
        - "Classify findings by severity"
        - "Record coverage: files scanned, patterns searched"
    - name: "Cross-Reference Audit"
      isolation: true
      steps:
        - "Glob for key operational files"
        - "Extract backtick-delimited paths from each file"
        - "Check whether each path resolves on disk"
        - "Record broken references with file:line and expected target"
        - "Record coverage: files scanned, paths checked"
    - name: "Semantic Read-Through"
      isolation: true
      steps:
        - "Read key operational files end-to-end"
        - "Flag prose describing old architecture or defunct patterns"
        - "Flag terminology that contradicts current structure"
        - "Record conceptual staleness with file:line and explanation"
        - "Record coverage: files read, checks applied"
    - name: "Self-Challenge"
      steps:
        - "Review findings against manifest: every mapping has findings or confirmed clean"
        - "Check for blind spots: file types not searched, directories not visited"
        - "Attempt to disprove findings: verify each is real (file exists, line correct)"
        - "Attempt to find counter-examples: search for issues the lenses missed"
        - "Record self-challenge outcomes: confirmed, disproved, or new findings added"
    - name: "Report"
      steps:
        - "Consolidate findings from all layers"
        - "Deduplicate across layers"
        - "Assign final severity to each finding"
        - "Group into recommended fix batches"
        - "Generate coverage proof section"
        - "Write report to /.octon/state/evidence/validation/analysis/"
        - "Write execution log with idempotency metadata"
  principles:
    - name: "Fixed lenses"
      description: "Three mandatory layers, each targeting a distinct staleness class"
    - name: "Fixed severity bar"
      description: "CRITICAL/HIGH/MEDIUM/LOW with deterministic classification rules"
    - name: "Self-challenge phase"
      description: "Mandatory phase to disprove findings and surface blind spots"
    - name: "Enumerated search patterns"
      description: "Each mapping generates exact search queries, not open-ended investigation"
    - name: "Coverage manifest with proof"
      description: "Report includes what was checked and found clean, not just findings"
    - name: "Idempotency guarantee"
      description: "Same manifest + same codebase = same findings"
    - name: "Lens isolation"
      description: "Each layer completes fully before the next begins"
  goals:
    - "Complete coverage of all migration mappings"
    - "Zero false negatives in grep sweep layer"
    - "All path references validated against filesystem"
    - "Conceptual staleness identified beyond string-level"
    - "Reproducible results across independent sessions"
    - "Actionable report with clear fix recommendations and coverage proof"
---

# Behavior Reference

Detailed phase-by-phase behavior for the audit-migration skill.

## Phase 1: Configure

Parse and validate the migration manifest before any scanning begins.

### Configuration Steps

1. **Parse the migration manifest:**

   Accept either inline YAML or a file path:

   ```yaml
   migration:
     name: "capability-organized restructure"
     mappings:
       - old: ".workspace/"
         new: ".octon/"
       - old: "context/"
         new: "cognition/runtime/context/"
     exclusions:
       - "continuity/log.md"
       - "cognition/runtime/decisions/"
       - ".history/"
     key_files:
       - "START.md"
       - "catalog.md"
       - "conventions.md"
     scope: "."
   ```

2. **Validate mappings:**
   - Each mapping must have both `old` and `new` fields
   - `old` must be non-empty
   - No duplicate `old` patterns
   - Warn if `old` and `new` are identical

3. **Resolve exclusion zones:**

   Convert exclusion patterns to concrete path lists:

   | Pattern Type      | Example                            | Resolution              |
   | ----------------- | ---------------------------------- | ----------------------- |
   | Exact file        | `continuity/log.md`                | Single file             |
   | Directory         | `cognition/runtime/decisions/`             | All files recursively   |
   | Glob              | `*.archive/*`                      | Pattern expansion       |
   | Append-only marker | Files with `mutability: append-only` | Auto-detected         |

4. **Identify key operational files** for cross-reference and semantic layers:

   Default set (override with `key_files` parameter):
   - `**/START.md`
   - `**/README.md` (in operational dirs, not node_modules)
   - `**/catalog.md`
   - `**/registry.yml`
   - `**/manifest.yml`
   - `**/SKILL.md`
   - `**/conventions.md`
   - `**/scope.md`
   - `**/*.rules` (Cursor rules)
   - `**/CLAUDE.md`, `**/AGENTS.md`

5. **Enumerate scope manifest:**

   Build a complete, sorted file list for deterministic processing:

   ```text
   1. Glob all files in scope matching target file types
   2. Sort alphabetically (deterministic order)
   3. Remove excluded files
   4. Record total: "Scope manifest: N files in M directories"
   ```

   This scope manifest is the source of truth for coverage tracking. Every file in this list must be accounted for in the report as either "finding" or "confirmed clean."

6. **Set severity threshold:**
   - Default: report all severities (CRITICAL, HIGH, MEDIUM, LOW)
   - If `severity_threshold` parameter set, only report at or above threshold

### Partition Handling (when `partition` parameter is set)

When `partition` is provided, additional configuration steps apply after scope enumeration:

1. **Apply file filter:**

   If `file_filter` is set, narrow the scope manifest:

   ```text
   1. Start with full scope manifest (N files)
   2. Apply file_filter glob pattern (e.g., ".octon/framework/cognition/_meta/architecture/**")
   3. Keep only files matching the filter
   4. Record: "Partition '{partition}': M files (filtered from N total)"
   ```

2. **Relax key file validation:**

   In partition mode, not all key files need to exist within the filtered scope:

   - Key files outside the partition are noted as "out of partition scope"
   - Only key files matching the `file_filter` are required to be scanned
   - Missing key files within the partition still trigger warnings

3. **Record partition metadata:**

   ```yaml
   partition_mode: true
   partition: "{partition_name}"
   file_filter: "{glob_pattern}"
   files_in_partition: M
   files_in_full_scope: N
   partition_coverage: "M/N files"
   ```

### Configuration Result

Configuration summary logged to execution log. Scope manifest recorded for coverage tracking.

---

## Phase 2: Grep Sweep

**Lens isolation:** Complete this phase fully before starting Phase 3. Do not interleave with other layers.

Systematically search for all stale patterns defined in the migration manifest.

### Search Procedure

1. **Generate search variations for EACH mapping:**

   For a mapping `old: "context/"`, `new: "cognition/runtime/context/"`:

   | #   | Pattern               | Example                            |
   | --- | --------------------- | ---------------------------------- |
   | 1   | Base                  | `context/`                         |
   | 2   | Leading slash         | `/context/`                        |
   | 3   | Without trailing slash | `context` (word-boundary)         |
   | 4   | Double-quoted         | `"context/"`                       |
   | 5   | Single-quoted         | `'context/'`                       |
   | 6   | In backticks          | `` `context/` ``                   |
   | 7   | As path segment       | `/context/` in longer paths        |
   | 8   | Case variation        | `Context/` (if applicable)         |

   **Important:** Not all 8 variations apply to every mapping. Use judgment:
   - Short patterns (e.g., `context/`) need word-boundary awareness to avoid false positives
   - Long patterns (e.g., `.workspace/progress/`) can use simple substring matching
   - Patterns with special characters need escaping

2. **Run Grep for each variation:**

   ```text
   Grep pattern="context/" path="." glob="*.{md,yml,yaml,json,ts,js}"
   ```

   For each match, record:
   - File path
   - Line number
   - Matching line content (truncated to 120 chars)
   - Which mapping it matches

3. **Filter out excluded files:**

   Remove any match in files covered by the exclusion zones from Phase 1.

4. **Classify findings by severity:**

   | File Location                                                  | Severity |
   | -------------------------------------------------------------- | -------- |
   | Operational files (START.md, catalog.md, SKILL.md, registry.yml, manifest.yml) | CRITICAL |
   | Agent prompts, workflow steps, commands, Cursor rules           | HIGH     |
   | Documentation, examples, reference files                       | MEDIUM   |
   | Comments, historical notes, scratchpad                         | LOW      |

5. **Record false positive candidates:**

   Flag potential false positives for human review:
   - Matches in code where the pattern is a variable name, not a path
   - Matches in prose where the pattern appears in a different context
   - Very short patterns with high false positive risk

### Grep Coverage

Record for each mapping:

```markdown
| Mapping                           | Variations Searched | Files Matched | Files Clean |
| --------------------------------- | ------------------- | ------------- | ----------- |
| `.workspace/` → `.octon/`      | 8/8                 | 3             | 254         |
| `context/` → `cognition/runtime/context/` | 6/8                | 7             | 250         |
```

**Idempotency rule:** Process mappings in manifest order, files in sorted order. Do not skip a mapping because "it's probably fine." Do not stop early because "enough findings were found."

### Grep Sweep Result

Grep sweep findings appended to the findings collection. Coverage stats recorded.

### Common Pitfalls

- **Searching only one variation:** Always generate multiple variations
- **Missing file types:** Include config files, scripts, dotfiles
- **Short pattern false positives:** `context/` matches `execution-context/` — use judgment
- **Excluding too aggressively:** Better to flag a false positive than miss a real issue

---

## Phase 3: Cross-Reference Audit

**Lens isolation:** Complete this phase fully before starting Phase 4. Do not reference findings from Phase 2 while scanning — each layer operates independently.

Verify that paths referenced in key operational files actually resolve on disk.

### Cross-Reference Procedure

1. **Glob for key operational files:**

   Use the key files list from Phase 1. Expand globs to concrete file list.

2. **Extract path references from each file:**

   Look for paths in these formats:

   | Format              | Regex Pattern     | Example                                     |
   | ------------------- | ----------------- | -------------------------------------------- |
   | Backtick paths      | `` `path/to/file` `` | `` `cognition/runtime/context/decisions.md` ``    |
   | Markdown links      | `label + target`  | `decisions -> cognition/runtime/decisions/`          |
   | YAML path values    | `path: "value"`   | `path: "/.octon/instance/capabilities/runtime/skills/resources/synthesize-research/"`     |
   | Relative references | `./path` or `../path` | `../capabilities/runtime/commands/`              |

3. **Resolve each path relative to its containing file:**

   For a reference in `.octon/instance/bootstrap/START.md`:
   - `cognition/runtime/context/decisions.md` → `.octon/instance/cognition/context/shared/decisions.md`
   - `../.octon/framework/cognition/_meta/architecture/` → `.octon/framework/cognition/_meta/architecture/`

4. **Check whether each path exists:**

   Use Glob to verify:
   - File exists (exact match)
   - Directory exists (with or without trailing slash)

5. **Record broken references:**

   For each broken path:
   - Source file and line number
   - The referenced path (as written)
   - The resolved absolute path (what was checked)
   - Suggested correction (if determinable from the new mapping)
   - Severity: CRITICAL if in operational file, HIGH if in active docs

### Cross-Reference Coverage

Record for each key file:

```markdown
| Key File     | Paths Extracted | Paths Valid | Paths Broken |
| ------------ | --------------- | ----------- | ------------ |
| START.md     | 32              | 31          | 1            |
| catalog.md   | 43              | 43          | 0            |
```

**Idempotency rule:** Process key files in sorted order. Extract ALL path-like references, not just "the ones that look suspicious." Check every extracted path, not a sample.

### Cross-Reference Result

Cross-reference findings appended to the findings collection. Coverage stats recorded.

### Cross-Reference Scope Limits

- Maximum 50 key files per audit (escalate if more)
- Maximum 500 path references per audit (escalate if more)
- Skip binary files and node_modules

---

## Phase 4: Semantic Read-Through

**Lens isolation:** Complete this phase fully before starting Phase 5. Do not reference findings from Phases 2-3 while reading — assess each file on its own merits.

Read key operational files end-to-end to identify conceptual staleness that grep cannot catch.

### Semantic Review Procedure

1. **Select files for semantic review:**

   Priority order (read as many as scope allows):
   1. `START.md` — Entry point, describes overall structure
   2. `catalog.md` — Index of all capabilities
   3. `conventions.md` — Style and formatting rules
   4. `scope.md` — Workspace boundaries
   5. Agent prompts in `agency/`
   6. Cursor rules and commands
   7. `README.md` files in key directories
   8. Architecture documentation

2. **Read each file and check for:**

   | Check                                     | Example                                                       |
   | ----------------------------------------- | ------------------------------------------------------------- |
   | Old architecture descriptions             | "We use a two-root model with .octon/ and .workspace/"      |
   | Defunct resolution rules                   | "Look in .workspace/ first, then fall back to .octon/"      |
   | Stale model descriptions                  | "The flat structure organizes files by..."                    |
   | Outdated terminology                      | "Two-tier architecture" when it's now "progressive disclosure" |
   | Orphaned references to removed concepts   | "See the shared registry for..." when the canonical source is the skills registry |
   | Incorrect counts or lists                 | "5 directories" when there are now 9                          |

3. **Record conceptual findings:**

   For each issue:
   - File path and line number(s)
   - The stale prose (quoted)
   - What's wrong (explanation)
   - Suggested correction
   - Severity: HIGH if in operational file, MEDIUM if in docs

### Semantic Review Guidelines

- Focus on **meaning**, not just strings
- A file can pass grep sweep but fail semantic review
- Flag uncertainty — note when you're unsure if something is stale
- Don't flag historical/intentional references (check against exclusion zones)
- Be conservative: false negatives are worse than false positives in an audit

### Semantic Review Result

Semantic findings appended to the findings collection.

---

## Phase 5: Self-Challenge

**Purpose:** Revisit all findings and scope to identify overlooked gaps, disprove false findings, and surface issues the three lenses missed. This phase is what makes the audit bounded and reproducible.

### Challenge Procedure

1. **Mapping coverage check:**

   For EACH mapping in the manifest, verify it has either:
   - At least one finding, OR
   - An explicit "confirmed clean" entry

   If a mapping has neither, it was missed. Go back and search for it.

   ```markdown
   | Mapping                           | Status          | Findings | Notes            |
   | --------------------------------- | --------------- | -------- | ---------------- |
   | `.workspace/` → `.octon/`      | Findings        | 3        |                  |
   | `context/` → `cognition/runtime/context/` | Confirmed clean | 0        | All refs updated |
   | `commands/` → `capabilities/runtime/commands/` | **GAP**    | ?        | Not searched!    |
   ```

2. **Blind spot analysis:**

   Check for categories that may have been under-examined:
   - File types not in the search scope (e.g., `.sh`, `.py`, `.toml`)
   - Directories not visited during semantic read-through
   - Key files that exist but weren't in the default key file list
   - Patterns that are substring matches of each other (masking)

3. **Finding verification:**

   For EACH finding, verify it is real:
   - Does the file still exist? (Not deleted since scanning)
   - Is the line number correct? (Not shifted by other edits)
   - Does the pattern actually match at that line? (Not a false positive from context)

   Mark findings as:
   - **Confirmed** — Verified real
   - **Disproved** — False positive, remove from report
   - **Uncertain** — Flag for human review

4. **Counter-example search:**

   Actively try to find issues the three lenses missed:
   - Search for partial matches or abbreviations of old patterns
   - Check for old patterns in file/directory names (not just content)
   - Look for stale references using synonyms or alternative spellings
   - Check configuration files that might use different quoting conventions

5. **Record self-challenge outcomes:**

   ```markdown
   ## Self-Challenge Results

   - Mappings verified: N/N (all covered)
   - Blind spots found: N (list each)
   - Findings confirmed: N
   - Findings disproved: N (removed from report)
   - New findings from counter-examples: N (added to report)
   ```

### Partition-Scoped Self-Challenge (when `partition` parameter is set)

When running in partition mode, the self-challenge phase adjusts:

- **Mapping coverage check:** Only requires coverage for mappings that produce hits within the partition. Mappings with zero in-partition files are marked "out of partition scope" (not "gap").
- **Blind spot analysis:** Notes that files outside the `file_filter` are intentionally excluded (not blind spots). Cross-partition blind spots are deferred to the global self-challenge at merge.
- **Counter-example search:** Limited to files within the partition scope.
- **Challenge outcome note:** Appends "This is a partition-scoped audit. Global self-challenge should occur at merge time."

### Self-Challenge Result

Updated findings collection with disproved findings removed and new findings added. Challenge outcomes recorded in execution log.

---

## Phase 6: Report

Consolidate all findings into a structured, actionable report with coverage proof.

### Report Assembly

1. **Consolidate findings from all layers:**

   Merge grep sweep, cross-reference, semantic, and self-challenge findings into a single collection.

2. **Deduplicate:**

   If the same file:line appears in multiple layers, keep the highest-severity entry and note which layers flagged it.

3. **Assign final severity:**

   Use the classification from Phase 2, adjusted by cross-reference and semantic context.

4. **Group into recommended fix batches:**

   Organize findings into logical fix batches:

   ```markdown
   ### Batch 1: Critical operational fixes (N findings)
   [Files that cause workflow failures]

   ### Batch 2: High-priority reference fixes (N findings)
   [Active files with stale references]

   ### Batch 3: Documentation cleanup (N findings)
   [Docs and examples with incorrect paths]

   ### Batch 4: Low-priority / judgment calls (N findings)
   [Historical, cosmetic, or ambiguous issues]
   ```

5. **Generate coverage proof:**

   ```markdown
   ## Coverage Proof

   **Scope manifest:** N files in M directories
   **Files with findings:** X
   **Files confirmed clean:** Y
   **Files excluded:** Z
   **Unaccounted files:** 0 (must be zero)

   ### Layer Coverage

   | Layer                  | Items Checked | Findings | Clean |
   | ---------------------- | ------------- | -------- | ----- |
   | Grep Sweep             | N mappings × M files | X | Y  |
   | Cross-Reference Audit  | N key files, M paths | X  | Y  |
   | Semantic Read-Through  | N files read         | X  | Y  |
   | Self-Challenge         | N checks             | X new | Y disproved |
   ```

6. **Write report:**

   Output to `.octon/state/evidence/validation/analysis/YYYY-MM-DD-migration-audit.md`:

   ```markdown
   # Post-Migration Audit Report

   **Date:** YYYY-MM-DD
   **Migration:** {{migration.name}}
   **Scope:** {{scope}} (N files scanned)
   **Bounded audit:** 7 principles enforced

   ## Executive Summary

   **Total findings: N across M files**

   | Layer                 | Findings |
   | --------------------- | -------- |
   | Grep Sweep            | N        |
   | Cross-Reference Audit | N        |
   | Semantic Read-Through | N        |
   | Self-Challenge (new)  | N        |

   | Severity | Count |
   | -------- | ----- |
   | CRITICAL | N     |
   | HIGH     | N     |
   | MEDIUM   | N     |
   | LOW      | N     |

   ## Findings by Layer
   [Detailed findings grouped by layer]

   ## Self-Challenge Results
   [Verification outcomes, disproved findings, blind spots]

   ## Recommended Fix Batches
   [Batched by priority and logical grouping]

   ## Coverage Proof
   [What was checked and found clean]

   ## Exclusion Zones
   [List of excluded files/directories and why]

   ## Idempotency Metadata
   [Manifest hash, file count, sorted file order hash — for reproducibility verification]
   ```

7. **Write execution log:**

   Log to `/.octon/state/evidence/runs/skills/audit-migration/{{run_id}}.md`:

   ```markdown
   # Audit Migration Run Log

   **Run ID:** {{run_id}}
   **Started:** {{timestamp}}
   **Migration:** {{migration.name}}
   **Mappings:** N patterns
   **Scope:** {{scope}}
   **Principles enforced:** 7/7

   ## Layer Execution

   | Phase                 | Isolation | Findings | Coverage         |
   | --------------------- | --------- | -------- | ---------------- |
   | Configure             | —         | —        | N files in scope |
   | Grep Sweep            | Yes       | N        | N/N mappings     |
   | Cross-Reference Audit | Yes       | N        | N/N key files    |
   | Semantic Read-Through | Yes       | N        | N/N files read   |
   | Self-Challenge        | —         | +N / -N  | N/N checks       |
   | Report                | —         | —        | —                |

   ## Idempotency

   - Manifest hash: {{hash}}
   - Scope file count: N
   - Sorted file list hash: {{hash}}

   ## Report Location
   - .octon/state/evidence/validation/analysis/YYYY-MM-DD-migration-audit.md
   ```

8. **Update log index** (`/.octon/state/evidence/runs/skills/audit-migration/index.yml`)

### Partition-Mode Report Variant (when `partition` parameter is set)

When `partition` is set, the report has these differences:

- **Filename:** `YYYY-MM-DD-migration-audit-{partition}.md`
- **Header metadata:** Includes `Partition`, `File Filter`, `Partition Mode: Yes`, and `Partition Coverage: M files (of N total)`
- **Coverage proof:** Scoped to partition only. Header notes: "Coverage is partition-scoped. See consolidated report for global coverage."
- **Self-challenge section:** Includes a note that global self-challenge is deferred to the orchestration merge step
- **Cross-partition references:** Flagged but not required to resolve within the partition

### Report Quality Checklist

- [ ] Every finding has file:line, description, and severity
- [ ] Findings are deduplicated across layers
- [ ] Self-challenge phase completed (no gaps in mapping coverage)
- [ ] Fix batches are actionable (each batch can be applied independently)
- [ ] Coverage proof shows zero unaccounted files
- [ ] Exclusion zones are documented (proves intentionality)
- [ ] Idempotency metadata recorded (enables reproducibility verification)

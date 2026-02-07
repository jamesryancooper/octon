---
behavior:
  phases:
    - name: "Define Scope"
      steps:
        - "Document refactor type (rename/move/restructure)"
        - "Generate all 8 required search variations"
        - "Identify file types to search"
        - "List physical changes (directories/files to rename)"
        - "Define exclusions"
    - name: "Audit"
      steps:
        - "Run search for EACH variation pattern"
        - "Check for physical files/directories with old name"
        - "Consolidate into deduplicated file list"
        - "GATE: Check scope limits (>50 files → escalate)"
    - name: "Plan"
      steps:
        - "Create change manifest ordered by priority"
        - "Identify continuity artifacts (append-only)"
        - "Load manifest into tracking"
    - name: "Execute"
      steps:
        - "Physical changes first (rename/move)"
        - "Config files second"
        - "Documentation/code third"
        - "Continuity artifacts last (APPEND ONLY)"
        - "Mark items complete immediately after each change"
    - name: "Verify"
      steps:
        - "Re-run ALL searches from Phase 2"
        - "If ANY return results: RETURN TO PHASE 4"
        - "LOOP until all searches return zero"
        - "Document verification results"
    - name: "Document"
      steps:
        - "Update continuity artifacts (append-only)"
        - "Generate suggested commit message"
        - "Update checkpoint to completed"
        - "Update log index"
        - "Declare completion with stats"
  goals:
    - "Zero remaining references after verification"
    - "Historical accuracy preserved (append-only)"
    - "Checkpoint support for resume"
    - "Complete audit trail of all changes"
---

# Behavior Reference

Detailed phase-by-phase behavior for the refactor skill.

## Phase 1: Define Scope

Explicitly capture what is being refactored before any changes.

### Actions

1. **Document the refactor type:**
   - **Rename:** `old-name` → `new-name`
   - **Move:** `old/path/` → `new/path/`
   - **Restructure:** Multiple coordinated changes

2. **Define the canonical patterns:**
   ```
   OLD: [exact old pattern]
   NEW: [exact new pattern]
   ```

3. **Generate search variations** (ALL 8 REQUIRED):

   | # | Pattern | Example |
   |---|---------|---------|
   | 1 | Base | `old-name` |
   | 2 | Leading slash | `/old-name` |
   | 3 | Trailing slash | `old-name/` |
   | 4 | Both slashes | `/old-name/` |
   | 5 | Double quotes | `"old-name"` |
   | 6 | Single quotes | `'old-name'` |
   | 7 | As path segment | `old-name/` in paths |
   | 8 | Without special chars | `oldname` (if applicable) |

4. **List file types to search:**
   - Markdown: `*.md`
   - YAML: `*.yml`, `*.yaml`
   - JSON: `*.json`
   - TypeScript/JavaScript: `*.ts`, `*.tsx`, `*.js`, `*.jsx`
   - Config files: `*.config.*`, `.*rc`
   - Project-specific types

5. **Identify exclusions:**
   - `node_modules/`
   - `.git/`
   - Build outputs (`dist/`, `build/`)

6. **Note physical changes:**
   - Directories to rename
   - Files to move/rename

### Output

Write scope definition to `runs/refactor/{{id}}/scope.md`:

```markdown
## Refactor Scope

**Refactor ID:** {{timestamp}}-{{scope-slug}}
**Type:** [Rename|Move|Restructure]
**Old:** `[pattern]`
**New:** `[pattern]`

**Search variations:**
- [ ] `old-name`
- [ ] `/old-name`
- [ ] `old-name/`
- [ ] `/old-name/`
- [ ] `"old-name"`
- [ ] `'old-name'`
- [ ] As path segment
- [ ] Without special chars (if applicable)

**File types:** md, yml, yaml, json, ts, js

**Physical changes:**
- [ ] Rename directory `X` to `Y`
- [ ] Move file `A` to `B`

**Exclusions:** node_modules, .git, dist
```

### Checkpoint Update

Set `checkpoint.yml`:
```yaml
current_phase: 1
phases:
  1_define_scope:
    status: completed
    completed_at: "{{timestamp}}"
    output: scope.md
```

---

## Phase 2: Audit All References

Exhaustively search for ALL references before making changes.

### Actions

1. **Run search for EACH variation:**

   ```bash
   # Using Grep tool (preferred) or ripgrep
   rg -l "old-name" --type md --type yaml --type json
   rg -l "/old-name" --type md --type yaml --type json
   rg -l "old-name/" --type md --type yaml --type json
   # ... for ALL 8 variations
   ```

2. **Record results:**

   ```markdown
   ## Audit Results

   ### Pattern: `old-name`
   - `.harmony/START.md` (3 matches)
   - `.harmony/orchestration/workflows/example.md` (1 match)

   ### Pattern: `/old-name/`
   - `.cursor/commands/command.md` (1 match)
   ```

3. **Check for physical files/directories:**

   ```bash
   find . -type d -name "*old-name*" 2>/dev/null | grep -v node_modules | grep -v .git
   find . -type f -name "*old-name*" 2>/dev/null | grep -v node_modules | grep -v .git
   ```

4. **Consolidate and deduplicate:**

   ```markdown
   ## Files Requiring Changes

   | File | Match Count | Patterns Found |
   |------|-------------|----------------|
   | `.harmony/START.md` | 4 | `old-name`, `/old-name/` |
   | `.harmony/orchestration/workflows/example.md` | 1 | `old-name` |

   **Total files:** 3
   **Total matches:** 6
   ```

5. **GATE: Check scope limits:**

   | Metric | Threshold | Action |
   |--------|-----------|--------|
   | Files to modify | >50 | Escalate to mission |
   | Match count | >200 | Escalate to mission |
   | Modules affected | >3 | Warn user, offer escalation |

### Common Mistakes to Avoid

- **Searching only one variation:** Always search ALL 8 variations
- **Missing file types:** Include config files, scripts, dotfiles
- **Ignoring case:** Consider case-insensitive search if needed
- **Stopping at first results:** Run ALL searches even if early ones find matches

### Output

Write audit manifest to `runs/refactor/{{id}}/audit-manifest.md`

### Checkpoint Update

```yaml
current_phase: 2
phases:
  2_audit:
    status: completed
    completed_at: "{{timestamp}}"
    output: audit-manifest.md
    metrics:
      files_found: {{N}}
      total_matches: {{N}}
```

---

## Phase 3: Plan Changes

Transform audit results into an actionable change manifest.

### Actions

1. **Create prioritized manifest:**

   ```markdown
   ## Refactor Change Manifest

   **Refactor:** `.scratch/` → `.scratchpad/`
   **Total files:** 12
   **Total changes:** 47

   ### Phase 1: Physical Changes (do first)
   - [ ] Rename `.workspace/.scratch/` → `.harmony/ideation/scratchpad/`

   ### Phase 2: Config Files
   - [ ] `package.json` (1 change)

   ### Phase 3: Documentation & Code
   - [ ] `.harmony/START.md` (4 changes)
   - [ ] `.harmony/orchestration/workflows/example.md` (3 changes)

   ### Phase 4: Continuity Artifacts (APPEND ONLY)
   - [ ] `continuity/log.md` — Add entry (DO NOT MODIFY EXISTING)
   - [ ] `cognition/context/decisions.md` — Add entry if applicable
   ```

2. **Identify continuity artifacts:**

   Check files against continuity patterns:
   - `**/continuity/log.md`
   - `**/continuity/*.md`
   - `**/decisions/*.md`
   - `**/cognition/context/decisions.md`
   - `**/CHANGELOG.md`
   - `**/ADR-*.md`, `**/adr-*.md`

3. **Order changes strategically:**
   - **First:** Physical renames/moves (so paths exist)
   - **Second:** Config files (package.json, tsconfig, etc.)
   - **Third:** Documentation and code
   - **Last:** Continuity artifacts (append new entries)

4. **Load into tracking** (use TodoWrite)

### Output

Write change manifest to `runs/refactor/{{id}}/change-manifest.md`

### Checkpoint Update

```yaml
current_phase: 3
phases:
  3_plan:
    status: completed
    completed_at: "{{timestamp}}"
    output: change-manifest.md
```

---

## Phase 4: Execute Changes

Make all planned changes systematically.

### Actions

1. **Execute physical changes first:**

   ```bash
   mv .workspace/.scratch .workspace/.scratchpad
   ```

   - Mark each item complete immediately after
   - Verify the rename/move succeeded before proceeding

2. **Execute config files:**
   - Open each config file
   - Replace old pattern with new pattern
   - Ensure valid syntax after edit (JSON, YAML)
   - Save and mark complete

3. **Execute documentation & code:**
   - Work through files in manifest order
   - For each file:
     1. Read the file
     2. Replace ALL occurrences of ALL pattern variations
     3. Save the file
     4. Mark complete immediately

4. **Execute continuity artifacts (APPEND ONLY):**

   **CRITICAL: Do NOT modify existing content**

   For `continuity/log.md`:
   ```markdown
   ## YYYY-MM-DD

   **Session focus:** Refactor `.scratch/` to `.scratchpad/`

   **Completed:**
   - Renamed `.workspace/.scratch/` to `.harmony/ideation/scratchpad/`
   - Updated 47 references across 12 files
   - Verification: PASSED

   **Next:**
   - [if applicable]
   ```

### Execution Rules

| Rule | Reason |
|------|--------|
| Mark items complete immediately | Prevents losing track mid-refactor |
| Don't add unplanned changes | Scope creep introduces errors |
| Read before editing | Ensures you see current state |
| One file at a time | Maintains focus and tracking |
| APPEND to continuity artifacts | Preserves historical accuracy |

### If You Discover Missing Items

1. **Stop** current execution
2. **Add** the new item to the manifest
3. **Continue** execution including the new item
4. **Note** the discovery for verification step

### Output

Write execution log to `runs/refactor/{{id}}/execution-log.md`

### Checkpoint Update

```yaml
current_phase: 4
phases:
  4_execute:
    status: in_progress
    started_at: "{{timestamp}}"
    output: execution-log.md
    progress:
      total_items: 13
      completed_items: 7
      current_item: ".harmony/orchestration/workflows/example.md"
```

---

## Phase 5: Verify Completion (MANDATORY GATE)

**This phase MUST pass before the skill can complete.**

### Actions

1. **Re-run EVERY search from audit:**

   ```bash
   # Must return empty for EACH
   rg "old-name" --type md --type yaml --type json
   rg "/old-name" --type md --type yaml --type json
   rg "old-name/" --type md --type yaml --type json
   rg "/old-name/" --type md --type yaml --type json
   rg '"old-name"' --type md --type yaml --type json
   rg "'old-name'" --type md --type yaml --type json
   ```

2. **Check for remaining physical artifacts:**

   ```bash
   find . -type d -name "*old-name*" 2>/dev/null | grep -v node_modules | grep -v .git
   find . -type f -name "*old-name*" 2>/dev/null | grep -v node_modules | grep -v .git
   ```

3. **Document results:**

   ```markdown
   ## Verification Results

   | Pattern | Result | Status |
   |---------|--------|--------|
   | `old-name` | 0 matches | ✓ |
   | `/old-name` | 0 matches | ✓ |
   | `old-name/` | 0 matches | ✓ |
   | `/old-name/` | 0 matches | ✓ |
   | `"old-name"` | 0 matches | ✓ |
   | `'old-name'` | 0 matches | ✓ |
   | Physical dirs | 0 found | ✓ |
   | Physical files | 0 found | ✓ |

   **VERIFICATION:** PASSED ✓
   ```

### If Verification FAILS

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   IF ANY SEARCH RETURNS RESULTS:                           │
│                                                             │
│   1. Document remaining references                          │
│   2. RETURN TO PHASE 4                                     │
│   3. Fix remaining items                                    │
│   4. Return to Phase 5                                      │
│   5. REPEAT until all searches return zero                  │
│                                                             │
│   You may NOT skip this.                                   │
│   You may NOT declare completion if verification fails.     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Acceptable Exceptions

The ONLY acceptable remaining references are:

1. **Continuity artifacts** that intentionally preserve old names (historical record)
2. **External documentation** explaining the migration
3. **Comments** explicitly noting the old name for historical context

These must be explicitly listed and justified:

```markdown
## Intentional Exceptions

| File | Reason |
|------|--------|
| `continuity/log.md:45` | Historical entry from 2025-01-13 |
| `decisions/ADR-001.md:23` | ADR documents the original name |
```

### Output

Write verification report to `runs/refactor/{{id}}/verification-report.md`

### Checkpoint Update

On PASS:
```yaml
current_phase: 5
phases:
  5_verify:
    status: completed
    completed_at: "{{timestamp}}"
    output: verification-report.md
    passed: true
```

On FAIL:
```yaml
current_phase: 5
phases:
  5_verify:
    status: failed
    failed_at: "{{timestamp}}"
    remaining_references: 3
    resume:
      instruction: "Return to Phase 4, fix remaining items"
```

---

## Phase 6: Document and Close

Record the completed refactor and formally close.

### Prerequisites

- Phase 5 (Verify) must show PASSED status
- If not passed, return to Phase 4

### Actions

1. **Update continuity artifacts (APPEND ONLY):**

   For `continuity/log.md`:
   ```markdown
   ## YYYY-MM-DD

   **Session focus:** Refactor `old-name` to `new-name`

   **Completed:**
   - Renamed [physical changes]
   - Updated N references across M files
   - Verification: PASSED (all searches returned zero)
   ```

2. **Generate suggested commit message:**

   ```markdown
   refactor: rename `.scratch/` to `.scratchpad/`

   - Updated 47 references across 12 files
   - Renamed directory `.workspace/.scratch/` → `.harmony/ideation/scratchpad/`
   - Verification: all audit searches return zero results
   ```

   Save to `runs/refactor/{{id}}/commit-message.txt`

3. **Update log index** (`logs/refactor/index.yml`)

4. **Declare completion:**

   ```
   Refactor complete: `old-name` → `new-name`
   - Files changed: N
   - Verification: PASSED
   - Continuity artifacts: Updated (append-only)
   - Suggested commit: runs/refactor/{{id}}/commit-message.txt
   ```

### Continuity Artifact Rules

| Action | Allowed | Not Allowed |
|--------|---------|-------------|
| Add new log entry | ✓ | |
| Add new decision | ✓ | |
| Create new ADR | ✓ | |
| Modify existing log entries | | ✗ |
| Update old decision text | | ✗ |
| Change paths in historical ADRs | | ✗ |

### Output

Write summary to `runs/refactor/{{id}}/summary.md`

### Checkpoint Update

```yaml
status: completed
current_phase: 6
phases:
  6_document:
    status: completed
    completed_at: "{{timestamp}}"
    output: summary.md
```

---

## Resumption Logic

On skill invocation, check for existing checkpoint:

1. Look for `runs/refactor/*{{scope-slug}}*/checkpoint.yml`

2. If found, read checkpoint (~50 tokens):
   - Check `status` field
   - Check `current_phase`
   - Check `resume.instruction`

3. Resume decision matrix:

   | checkpoint.status | current_phase | Action |
   |-------------------|---------------|--------|
   | completed | 6 | "Refactor already complete. Start new?" |
   | failed | any | "Previous attempt failed at Phase {N}. Retry?" |
   | in_progress | 1-3 | Resume from current_phase |
   | in_progress | 4 | Read progress.completed_items for exact item |
   | in_progress | 5 (failed) | "Verification failed. Return to Phase 4?" |

4. Prompt user: "Found existing refactor in progress. Resume from Phase {N}? [Y/n]"

---
behavior:
  phases:
    - name: "Configure"
      steps:
        - "Parse parameters (subsystem root, schema_ref, docs, severity_threshold, file_types)"
        - "Verify subsystem directory exists"
        - "Discover config files: manifest.yml, registry.yml, capabilities.yml"
        - "Discover definition files: **/SKILL.md (or WORKFLOW.md, depending on subsystem type)"
        - "Load schema reference (capabilities.yml or equivalent) for conformance checks"
        - "If docs parameter set: enumerate companion documentation files"
        - "Enumerate scope manifest (complete sorted file list)"
        - "Set severity threshold from parameters"
    - name: "Config Consistency"
      isolation: true
      steps:
        - "Build a unified entry index from manifest.yml (id, display_name, summary, group, path, skill_sets, capabilities, status, triggers)"
        - "For each entry, extract corresponding fields from registry.yml (version, commands, parameters, io)"
        - "For each entry, extract corresponding fields from SKILL.md frontmatter (name, description, skill_sets, capabilities, allowed-tools)"
        - "Field-by-field comparison: id/name must match across all three"
        - "Detect phantom entries: manifest entries with no SKILL.md on disk"
        - "Detect orphan definitions: SKILL.md files with no manifest entry"
        - "Detect path mismatches: manifest path vs. actual directory location"
        - "Detect group membership drift: capabilities.yml group members vs. manifest group assignments"
        - "Record all inconsistencies with file:line and expected vs. actual"
        - "Record coverage: entries checked, files scanned"
    - name: "Schema Conformance"
      isolation: true
      steps:
        - "Load valid_capabilities list from capabilities.yml"
        - "Load skill_set_definitions from capabilities.yml"
        - "Load skill_group_definitions from capabilities.yml"
        - "For each manifest entry: validate skill_sets against skill_set_definitions keys"
        - "For each manifest entry: validate capabilities against valid_capabilities list"
        - "For each manifest entry: validate group against skill_group_definitions keys"
        - "For each manifest entry: check required fields are present (id, display_name, group, path, summary, status)"
        - "For each registry entry: validate parameter types against allowed set (text, boolean, file, folder)"
        - "For each registry entry: validate io output paths contain no absolute paths"
        - "Check capability_refs: for each declared capability, verify expected reference files exist in the skill directory"
        - "Record all violations with entry id, field, expected value, actual value"
        - "Record coverage: entries validated, fields checked"
    - name: "Semantic Quality"
      isolation: true
      steps:
        - "Trigger overlap detection: find triggers that match more than one skill"
        - "Trigger quality: flag triggers that are too generic (< 3 words) or too similar to other skills"
        - "Naming convention check: verify display_name is Title Case of id, verify id is kebab-case"
        - "Summary alignment: compare manifest summary with first sentence of SKILL.md description"
        - "State directory contract: verify _ops/state/logs/{skill-id}/ structure matches documented convention"
        - "If docs parameter set: compare docs descriptions with actual subsystem structure"
        - "If docs parameter set: check doc internal links resolve on disk"
        - "Broken cross-references: check all paths in config files resolve on disk"
        - "Record all findings with file:line and explanation"
        - "Record coverage: checks applied, entries examined"
    - name: "Self-Challenge"
      steps:
        - "Entry coverage check: every manifest entry has been checked in all layers, or marked clean"
        - "Blind spot analysis: file types not searched, directories not visited"
        - "Finding verification: confirm each finding is real (file exists, line correct)"
        - "Counter-example search: look for issues the three lenses missed"
        - "Record self-challenge outcomes: confirmed, disproved, or new findings added"
    - name: "Report"
      steps:
        - "Consolidate findings from all layers"
        - "Deduplicate across layers (same file:line)"
        - "Assign final severity to each finding"
        - "Group into recommended fix batches"
        - "Generate coverage proof section"
        - "Write report to output/reports/"
        - "Write execution log with idempotency metadata"
  principles:
    - name: "Fixed lenses"
      description: "Three mandatory layers, each targeting a distinct coherence class"
    - name: "Fixed severity bar"
      description: "CRITICAL/HIGH/MEDIUM/LOW with deterministic classification rules"
    - name: "Self-challenge phase"
      description: "Mandatory phase to disprove findings and surface blind spots"
    - name: "Enumerated check patterns"
      description: "Each layer applies a fixed set of checks, not open-ended investigation"
    - name: "Coverage manifest with proof"
      description: "Report includes what was checked and found clean, not just findings"
    - name: "Idempotency guarantee"
      description: "Same subsystem + same codebase = same findings"
    - name: "Lens isolation"
      description: "Each layer completes fully before the next begins"
  goals:
    - "Complete coverage of all entries in the subsystem"
    - "Zero false negatives in config consistency layer"
    - "All schema fields validated against declared contracts"
    - "Semantic issues identified beyond structural checks"
    - "Reproducible results across independent sessions"
    - "Actionable report with clear fix recommendations and coverage proof"
---

# Behavior Reference

Detailed phase-by-phase behavior for the audit-subsystem-health skill.

## Phase 1: Configure

Parse and validate parameters before any scanning begins.

### Configuration Steps

1. **Parse parameters:**

   | Parameter | Required | Default | Purpose |
   |-----------|----------|---------|---------|
   | `subsystem` | Yes | — | Root directory of the subsystem to audit |
   | `schema_ref` | No | Auto-detect | Path to schema file (e.g., capabilities.yml) |
   | `docs` | No | — | Companion documentation directory |
   | `severity_threshold` | No | `all` | Minimum severity to report |
   | `file_types` | No | `md,yml,yaml,json` | File extensions to include |

2. **Verify subsystem directory exists:**
   - If not found, STOP with error: `SUBSYSTEM_NOT_FOUND`
   - If found, record absolute path for deterministic processing

3. **Discover config files:**

   Glob for these within the subsystem root:
   - `manifest.yml` — Entry index
   - `registry.yml` — Extended metadata
   - `capabilities.yml` — Schema definitions (also used as `schema_ref` if not overridden)

   If none found, STOP with error: `NO_CONFIG_FILES`

4. **Discover definition files:**

   Glob recursively for `**/SKILL.md` (or `**/WORKFLOW.md` if the subsystem contains workflows).

5. **Load schema reference:**

   If `schema_ref` is provided, load it. Otherwise, auto-detect:
   - If `capabilities.yml` exists in subsystem, use it
   - If not, warn and skip schema conformance layer

6. **Enumerate companion docs (if `docs` parameter set):**

   Glob for `*.md` in the docs directory. These will be checked for alignment in the semantic quality layer.

7. **Enumerate scope manifest:**

   Build a complete, sorted file list:
   - Glob all files in subsystem matching target file types
   - Sort alphabetically (deterministic order)
   - Record total: "Scope manifest: N files in M directories"

### Configuration Result

Configuration summary logged to execution log. Scope manifest recorded for coverage tracking.

---

## Phase 2: Config Consistency

**Lens isolation:** Complete this phase fully before starting Phase 3. Do not interleave with other layers.

Verify that config files agree with each other and with definition files on disk.

### Consistency Checks

1. **Build unified entry index:**

   Parse `manifest.yml` and create an entry for each skill/workflow:

   ```yaml
   entry:
     id: "audit-migration"
     manifest:
       display_name: "Audit Migration"
       group: "quality-gate"
       path: "quality-gate/audit-migration/"
       summary: "Bounded post-migration audit..."
       status: "active"
       skill_sets: [executor, guardian]
       capabilities: [domain-specialized]
       triggers: [...]
     registry:
       version: "1.1.0"
       commands: ["/audit-migration"]
       parameters: [...]
     definition:
       name: "audit-migration"  # from SKILL.md frontmatter
       skill_sets: [executor, guardian]
       capabilities: [domain-specialized]
       allowed-tools: "Read Glob Grep Write(...)"
   ```

2. **Cross-file field reconciliation:**

   | Field | Manifest | Registry | SKILL.md | Must Match? |
   |-------|----------|----------|----------|-------------|
   | id / name | `id` | key | `name` | Exact |
   | skill_sets | `skill_sets` | — | `skill_sets` | Exact |
   | capabilities | `capabilities` | — | `capabilities` | Exact |
   | status | `status` | — | — | — |
   | group | `group` | — | — | Must exist in capabilities.yml group_definitions |

3. **Phantom detection:**

   - **Phantom entries:** `manifest.yml` entry with `path` that doesn't resolve to a directory on disk
   - **Orphan definitions:** `SKILL.md` files found on disk with no corresponding `manifest.yml` entry

4. **Path verification:**

   For each entry, verify: `{subsystem_root}/{manifest.path}/SKILL.md` exists on disk.

5. **Group membership reconciliation:**

   For each group in `capabilities.yml` `skill_group_definitions`:
   - Check `members` list matches the set of manifest entries declaring that group
   - Report additions or omissions in either direction

### Severity for Config Consistency

| Finding | Severity |
|---------|----------|
| ID mismatch between manifest and SKILL.md | CRITICAL |
| Phantom entry (no directory on disk) | CRITICAL |
| skill_sets disagree between manifest and SKILL.md | HIGH |
| capabilities disagree between manifest and SKILL.md | HIGH |
| Orphan definition (no manifest entry) | HIGH |
| Group membership drift | MEDIUM |
| Path mismatch (resolvable but inconsistent) | MEDIUM |

### Config Consistency Result

Findings appended to the findings collection. Coverage stats recorded.

---

## Phase 3: Schema Conformance

**Lens isolation:** Complete this phase fully before starting Phase 4.

Validate all entries against the declared schema.

### Schema Checks

1. **Manifest required fields:**

   Every entry must have: `id`, `display_name`, `group`, `path`, `summary`, `status`

2. **skill_sets validation:**

   Each declared skill_set must exist in `capabilities.yml` `skill_set_definitions`:
   - Valid: `executor`, `coordinator`, `delegator`, `collaborator`, `integrator`, `specialist`, `guardian`
   - Invalid values → HIGH finding

3. **capabilities validation:**

   Each declared capability must exist in `capabilities.yml` `valid_capabilities`:
   - Check the full list (phased, branching, parallel, task-coordinating, etc.)
   - Invalid values → HIGH finding

4. **group validation:**

   Each declared group must exist in `capabilities.yml` `skill_group_definitions`:
   - Check the group key exists
   - Invalid values → HIGH finding

5. **Registry parameter validation:**

   For each parameter in `registry.yml`:
   - `type` must be one of: `text`, `boolean`, `file`, `folder`
   - `required` must be boolean
   - `name` must be non-empty

6. **Capability-to-reference file mapping:**

   Using `capability_refs` from `capabilities.yml`:
   - For each capability declared by a skill, check that the corresponding reference file exists
   - Example: `phased` requires `phases.md` in `references/`
   - Missing required references → HIGH finding
   - Extra references beyond requirements → informational (not a finding)

7. **Registry I/O validation:**

   - Output paths must be relative (no leading `/`)
   - Output paths should use `{{placeholder}}` syntax for dynamic segments
   - `determinism` must be one of: `stable`, `variable`, `unique`

### Severity for Schema Conformance

| Finding | Severity |
|---------|----------|
| Missing required manifest field | HIGH |
| Invalid skill_set value | HIGH |
| Invalid capability value | HIGH |
| Invalid group value | HIGH |
| Missing required reference file for capability | HIGH |
| Invalid parameter type | MEDIUM |
| Invalid determinism value | MEDIUM |
| Absolute path in output spec | MEDIUM |

### Schema Conformance Result

Findings appended to the findings collection. Coverage stats recorded.

---

## Phase 4: Semantic Quality

**Lens isolation:** Complete this phase fully before starting Phase 5.

Check for semantic issues that structural validation cannot catch.

### Semantic Checks

1. **Trigger overlap detection:**

   Compare all trigger phrases across all skills:
   - Exact duplicates → MEDIUM finding
   - High similarity (>80% word overlap) → MEDIUM finding
   - Triggers matching more than one skill → MEDIUM finding with both skill IDs

2. **Trigger quality:**

   - Triggers with fewer than 3 words → LOW finding (too generic)
   - Triggers that are just the skill name → LOW finding (not useful for intent matching)

3. **Naming convention checks:**

   - `id` must match `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`
   - `display_name` should be Title Case derived from `id` (hyphens → spaces, capitalize words)
   - Mismatches → LOW finding

4. **Summary alignment:**

   Compare `manifest.yml` `summary` with the first sentence of `SKILL.md` `description`:
   - They should convey the same meaning (not necessarily identical text)
   - Major semantic drift → MEDIUM finding

5. **State directory contract:**

   Verify the `_ops/state/` directory structure matches documented conventions:
   - `_ops/state/logs/{skill-id}/` should exist for skills with log outputs in registry
   - `_ops/state/logs/{skill-id}/index.yml` should exist if logs are expected
   - Missing expected directories → LOW finding

6. **Doc-to-source alignment (when `docs` parameter is set):**

   - Read companion documentation files
   - Check that described directory structures match actual filesystem
   - Check that described conventions match actual patterns
   - Check internal links in docs resolve on disk
   - Misalignment → MEDIUM finding

7. **Cross-reference validation:**

   Check all paths referenced in config files resolve on disk:
   - `path` values in manifest.yml
   - `io.inputs[].path` and `io.outputs[].path` in registry.yml (after removing `{{placeholders}}`)
   - Broken references → HIGH finding

### Severity for Semantic Quality

| Finding | Severity |
|---------|----------|
| Broken cross-reference in config file | HIGH |
| Trigger matches multiple skills | MEDIUM |
| Doc-to-source structural mismatch | MEDIUM |
| Summary semantic drift | MEDIUM |
| Trigger too generic | LOW |
| Naming convention violation | LOW |
| Missing expected state directory | LOW |

### Semantic Quality Result

Findings appended to the findings collection. Coverage stats recorded.

---

## Phase 5: Self-Challenge

**Purpose:** Revisit all findings and scope to identify overlooked gaps, disprove false findings, and surface issues the three lenses missed.

### Challenge Procedure

1. **Entry coverage check:**

   For EACH entry in the manifest, verify it has been checked in all applicable layers:
   - Config consistency: checked ✓ or confirmed clean ✓
   - Schema conformance: checked ✓ or confirmed clean ✓
   - Semantic quality: checked ✓ or confirmed clean ✓

   If any entry was missed, go back and check it.

2. **Blind spot analysis:**

   - Were any definition files missed during discovery?
   - Were any config file fields skipped during reconciliation?
   - Are there file types or directories not covered by the scope?

3. **Finding verification:**

   For EACH finding, verify it is real:
   - Does the file still exist?
   - Is the line number correct?
   - Is the stated inconsistency actually present?

   Mark findings as: **Confirmed**, **Disproved**, or **Uncertain**

4. **Counter-example search:**

   Actively try to find issues the three lenses missed:
   - Check for entries that appear consistent but have subtle semantic differences
   - Look for config values that are technically valid but semantically wrong
   - Check for undeclared dependencies between skills

5. **Record self-challenge outcomes:**

   ```markdown
   ## Self-Challenge Results

   - Entries verified: N/N (all covered)
   - Blind spots found: N (list each)
   - Findings confirmed: N
   - Findings disproved: N (removed from report)
   - New findings from counter-examples: N (added to report)
   ```

---

## Phase 6: Report

Consolidate all findings into a structured, actionable report.

### Report Assembly

1. **Consolidate findings from all layers**
2. **Deduplicate** (same file:line across layers → keep highest severity)
3. **Assign final severity** using classification rules from each layer
4. **Group into recommended fix batches:**

   ```markdown
   ### Batch 1: Critical config mismatches (N findings)
   [Entries that break routing or execution]

   ### Batch 2: Schema violations (N findings)
   [Fields that would fail validation]

   ### Batch 3: Semantic quality issues (N findings)
   [Trigger overlaps, naming issues, doc drift]

   ### Batch 4: Low-priority / informational (N findings)
   [Cosmetic issues, optional improvements]
   ```

5. **Generate coverage proof**
6. **Write report** to `.harmony/output/reports/YYYY-MM-DD-subsystem-health-audit.md`
7. **Write execution log** to `_ops/state/logs/audit-subsystem-health/{{run_id}}.md`
8. **Update log index** (`_ops/state/logs/audit-subsystem-health/index.yml`)

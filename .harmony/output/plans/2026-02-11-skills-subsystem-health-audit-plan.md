# Skills Subsystem Health Audit Plan

Date: 2026-02-11

## Context

This plan defines a bounded coherence audit of `.harmony/capabilities/skills/` and its documentation surface. The goal is to detect **drift** (refs that didn't follow moves), **misalignment** (docs say X, source says Y), **orphans** (entries without backing files or files without entries), and **schema rot** (structural violations against declared contracts).

The audit is read-only — no source files are modified. It produces a structured findings report.

### Prior Art

| Artifact | Date | Relation |
|----------|------|----------|
| `2026-02-10-skills-exhaustive-audit-plan.md` | 2026-02-10 | 8-dimension audit framework; this plan refines scope to 9 targeted lenses |
| `2026-02-11-skills-audit-remediation-plan.md` | 2026-02-11 | Remediation of 14 findings from exhaustive audit; some may remain open |

This audit independently re-verifies subsystem health regardless of prior remediation claims.

### Scope

**In scope:**

- `.harmony/capabilities/skills/` — manifest.yml, registry.yml, capabilities.yml, README.md, all SKILL.md files, `references/`, `_ops/state/`, `_scaffold/template/`, `_ops/scripts/`
- `docs/architecture/harness/skills/` — all architecture documents
- `.claude/skills/`, `.cursor/skills/`, `.codex/skills/` — harness symlinks
- `CLAUDE.md`, `AGENTS.md` — skills-related instructions
- `.harmony/orchestration/workflows/` — cross-references to skills paths only

**Out of scope:**

- Runtime correctness (whether skills produce correct output when invoked)
- Archived skills
- Historical audit reports (frozen artifacts)
- Workflow subsystem internals beyond skills cross-refs

### Output

- **Report:** `.harmony/output/reports/analysis/2026-02-11-skills-subsystem-health-audit.md`
- **Format:** Findings grouped by lens, each with severity tier, affected files with line numbers, and remediation recommendation
- **Severity tiers:** Critical (blocks execution or causes silent misrouting), Important (causes confusion or incomplete discovery), Minor (cosmetic or non-blocking), Informational (observation, no action required)

---

## Lens 1: Registry / Manifest Drift

**Goal:** Entries in manifest.yml, registry.yml, and capabilities.yml agree on skill IDs, names, summaries, triggers, or capability refs.

### Checks

#### 1.1 ID set parity (three-way)

Extract the set of skill IDs from each file and compare:

| Source | How to extract |
|--------|---------------|
| manifest.yml | Each `- id:` under `skills:` |
| registry.yml | Each key under `skills:` |
| capabilities.yml | Each member listed in `skill_group_definitions` entries |

Produce three diff sets: manifest-only, registry-only, capabilities-only. Any non-empty set is a finding.

#### 1.2 Shared-field consistency

For every skill ID present in both manifest.yml and registry.yml, verify:

1. **Skill sets** — manifest `skill_sets` matches SKILL.md frontmatter `skill_sets` (order-independent)
2. **Capabilities** — manifest `capabilities` matches SKILL.md frontmatter `capabilities` (order-independent)
3. **Group** — manifest `group` matches the first path segment in manifest `path`
4. **Status** — manifest `status` is one of `active | deprecated | experimental | draft`

#### 1.3 Capability vocabulary validation

1. Every `capabilities` value in manifest.yml appears in capabilities.yml `valid_capabilities`
2. Every `skill_sets` value in manifest.yml appears in capabilities.yml `skill_set_definitions`
3. Every `group` value in manifest.yml appears in capabilities.yml `skill_group_definitions`

#### 1.4 Trigger uniqueness

1. Extract all `triggers` arrays from manifest.yml
2. Detect exact duplicates across different skills (same trigger string → two skill IDs)
3. Detect high-overlap pairs (triggers that are substrings of each other, or differ only by whitespace/punctuation)

---

## Lens 2: Phantom Skills (Orphans)

**Goal:** Every manifest/registry entry has a corresponding SKILL.md on disk, and every skill directory on disk is indexed.

### Checks

#### 2.1 Forward: manifest → disk

For every `id` in manifest.yml:
1. Resolve `path` to an absolute directory path
2. Verify the directory exists
3. Verify `SKILL.md` exists within that directory

Missing directory or missing SKILL.md = phantom manifest entry.

#### 2.2 Forward: registry → manifest

For every key in registry.yml `skills:`:
1. Verify a corresponding manifest.yml entry exists with the same `id`

Registry key without manifest entry = orphaned registry entry.

#### 2.3 Reverse: disk → manifest

Glob all directories under `.harmony/capabilities/skills/` that contain a `SKILL.md`, excluding `_scaffold/template/`, `_ops/state/`, `_ops/scripts/`, and `archive/`. For each:
1. Verify a manifest.yml entry exists whose `path` resolves to that directory

Skill directory without manifest entry = unindexed skill.

#### 2.4 Reverse: disk → manifest (empty dirs)

Glob all directories under `.harmony/capabilities/skills/{group}/` that do NOT contain a `SKILL.md` and are not utility dirs (`_template`, `_state`, `_scripts`, `archive`, `references`, `scripts`, `assets`). These are placeholder or abandoned directories. Report as informational.

---

## Lens 3: Stale Cross-References

**Goal:** Paths referenced in registry.yml I/O mappings, SKILL.md references sections, and capabilities.yml `capability_refs` all resolve to existing files.

### Checks

#### 3.1 Registry I/O path resolution

For every skill in registry.yml, for each path in `io.inputs` and `io.outputs`:
1. If `path` is a literal path (not a parameter placeholder like `$source`), verify the parent directory exists
2. If `path` references a `_ops/state/` subdirectory, verify that subdirectory exists

#### 3.2 SKILL.md `references/` section links

For every SKILL.md, parse the References section (typically a markdown table mapping capabilities to files). For each referenced file path:
1. Resolve relative to the skill directory
2. Verify the file exists on disk

Missing reference file = stale cross-reference.

#### 3.3 Capability-to-reference mapping in capabilities.yml

Read capabilities.yml `capability_refs`. For each capability → file list mapping:
1. Verify each listed filename exists in `_scaffold/template/references/`
2. For each active skill declaring that capability, verify the corresponding reference file exists in the skill's `references/` directory

#### 3.4 Registry `depends_on` resolution

For every skill in registry.yml that declares `depends_on`:
1. Verify each dependency skill ID exists in manifest.yml
2. Verify the dependency skill has status `active`

---

## Lens 4: Doc-to-Source Misalignment

**Goal:** Architecture docs describe the actual current structure, flows, and conventions of `.harmony/capabilities/skills/`.

### Checks

#### 4.1 Directory structure claims

Read `docs/architecture/harness/skills/` docs that describe directory layout (likely `architecture.md`, `skill-format.md`, and the skills README.md). Extract claimed directory trees. Compare against actual glob of `.harmony/capabilities/skills/`.

Flag: directories mentioned in docs that don't exist, or actual directories omitted from docs.

#### 4.2 Schema field claims

Read docs that describe manifest.yml, registry.yml, or capabilities.yml schemas (likely `discovery.md`). Extract claimed fields. Compare against actual YAML keys in those files.

Flag: fields described in docs that aren't present in the actual files, or actual fields not described.

#### 4.3 Workflow/execution claims

Read `execution.md` and `invocation.md`. Extract described execution flow steps (e.g., "load manifest → match trigger → load registry → load SKILL.md"). Verify each mentioned file/path still exists.

#### 4.4 CLAUDE.md progressive-disclosure claims

Read `CLAUDE.md` skills section. Verify:
1. Each referenced path exists (manifest.yml, capabilities.yml, registry.yml, etc.)
2. The described discovery sequence (manifest → capabilities → registry → SKILL.md → references) matches the actual file structure
3. Schema version numbers in CLAUDE.md match actual file schema versions

#### 4.5 README.md catalog accuracy

Read `.harmony/capabilities/skills/README.md`. Verify:
1. Skill creation checklist steps reference real files and paths
2. Skill sets listed match capabilities.yml `skill_set_definitions`
3. Any counts, totals, or structural claims match reality

---

## Lens 5: Broken Internal Links

**Goal:** Markdown links between skill docs, the catalog README, and architecture docs all resolve.

### Checks

#### 5.1 Architecture docs internal links

For each markdown file in `docs/architecture/harness/skills/`:
1. Extract all relative markdown links `[text](path)` and `[text](path#anchor)`
2. Resolve the link target relative to the file's directory
3. Verify the target file exists
4. If anchor is present, verify the heading exists in the target file (best-effort: check for `## Anchor` or `### Anchor` with slug matching)

#### 5.2 SKILL.md internal links

For each SKILL.md:
1. Extract all relative markdown links
2. Verify targets resolve (references/*.md, other skill paths, etc.)

#### 5.3 README catalog links

In `.harmony/capabilities/skills/README.md`:
1. Extract all links to skill directories, architecture docs, and external files
2. Verify each resolves

#### 5.4 Cross-domain links

Check links from:
- Skills docs → workflow docs
- Skills docs → cognition docs
- CLAUDE.md → skills paths
- Architecture docs → skills paths

---

## Lens 6: Schema Violations

**Goal:** Fields present in manifest.yml, registry.yml, and capabilities.yml conform to their declared schemas. No missing required fields, no undeclared extra fields.

### Checks

#### 6.1 manifest.yml per-entry schema

For every skill entry in manifest.yml, verify presence of required fields:

| Field | Required | Type | Constraint |
|-------|----------|------|------------|
| `id` | yes | string | kebab-case, 1-64 chars |
| `display_name` | yes | string | non-empty |
| `path` | yes | string | resolves to directory |
| `summary` | yes | string | ≤150 tokens |
| `status` | yes | enum | active / deprecated / experimental / draft |
| `tags` | yes | list | non-empty |
| `triggers` | yes | list | non-empty |
| `skill_sets` | yes | list | values in capabilities.yml |
| `capabilities` | yes | list | values in capabilities.yml |

Flag extra fields not in this schema.

#### 6.2 registry.yml per-entry schema

For every skill entry in registry.yml, verify:

| Field | Required | Type | Constraint |
|-------|----------|------|------------|
| `version` | yes | string | semver format |
| `commands` | yes | list | non-empty |
| `parameters` | no | list | each has `name`, `type`, `required`, `description` |
| `requires.context` | no | list | valid context keys |
| `depends_on` | no | list | valid skill IDs |
| `io.inputs` | no | list | each has `path`, `kind`, `format`, `required` |
| `io.outputs` | no | list | each has `path`, `kind`, `format`, `determinism` |

Verify `type` values are one of: `text | boolean | file | folder`.
Verify `determinism` values are one of: `stable | variable | unique`.
Verify `kind` values are one of: `file | directory`.

#### 6.3 capabilities.yml structural schema

Verify:
1. `skill_set_definitions` — each entry has `name`, `description`, `capabilities` (list of valid capabilities)
2. `skill_group_definitions` — each entry has `name`, `description`, `members` (list of skill IDs)
3. `valid_capabilities` — list of strings
4. `capability_refs` — map of capability → list of reference filenames

#### 6.4 SKILL.md frontmatter schema

For every SKILL.md, verify frontmatter contains:

| Field | Required | Constraint |
|-------|----------|------------|
| `name` | yes | matches manifest `id` |
| `description` | yes | non-empty |
| `license` | yes | non-empty |
| `compatibility` | yes | non-empty |
| `metadata.author` | yes | non-empty |
| `metadata.created` | yes | date format |
| `metadata.updated` | yes | date format |
| `skill_sets` | yes | list, values match manifest |
| `capabilities` | yes | list, values match manifest |
| `allowed-tools` | yes | non-empty string |

Verify `metadata` does NOT contain `version` (version lives in registry.yml only).

---

## Lens 7: Trigger / Invocation Gaps

**Goal:** Every discoverable skill has well-formed, non-conflicting triggers, and skills that should be discoverable are not missing triggers.

### Checks

#### 7.1 Trigger completeness

For every skill with `status: active`:
1. Verify `triggers` list is non-empty
2. Verify each trigger is a non-empty string
3. Verify at least one trigger is a natural-language phrase (not just a command alias)

#### 7.2 Trigger conflict detection

Build a trigger → skill-ID map. Flag:
1. **Exact duplicates:** same trigger string maps to multiple skills
2. **Substring conflicts:** trigger A is a substring of trigger B (e.g., "audit" vs "audit migration")
3. **Prefix collisions:** triggers sharing a common prefix that could confuse routing (e.g., "create skill" vs "create mcp server")

#### 7.3 Command consistency

For every skill in registry.yml:
1. Verify `commands` list includes at least the skill ID as a command alias
2. Verify no two skills share the same command alias

#### 7.4 Draft/deprecated trigger hygiene

For skills with `status: draft` or `deprecated`:
1. Verify triggers don't collide with active skill triggers
2. (Informational) flag draft skills with triggers that overlap active skills

---

## Lens 8: Template Drift

**Goal:** The scaffold template (`_scaffold/template/`) reflects what existing active skills actually look like.

### Checks

#### 8.1 SKILL.md structural comparison

1. Parse `_scaffold/template/SKILL.md` to extract its section headings (## and ### level)
2. For a representative sample of 5 active skills (one from each group), parse their SKILL.md section headings
3. Flag headings present in template but absent from active skills (template bloat) and headings present in active skills but absent from template (template gap)

#### 8.2 Frontmatter field comparison

1. Extract frontmatter keys from `_scaffold/template/SKILL.md`
2. Extract frontmatter keys from all active SKILL.md files
3. Flag keys in template not used by any skill (dead placeholders) and keys used by skills but absent from template (undocumented fields)

#### 8.3 Reference file coverage

1. List all files in `_scaffold/template/references/`
2. For each active skill, list files in its `references/` directory
3. Flag template reference files that no active skill uses (dead templates)
4. Flag reference files used by active skills that have no template counterpart (undocumented references)

#### 8.4 Placeholder format consistency

1. Scan `_scaffold/template/SKILL.md` for placeholder patterns (e.g., `{{skill_name}}`, `{{skill_description}}`)
2. Verify `create-skill` SKILL.md documents all placeholders used in the template
3. Flag placeholders in template that aren't documented in `create-skill`

---

## Lens 9: Log / State Coherence

**Goal:** The `_ops/state/` directory structure matches what docs and the FORMAT.md specification say it should contain.

### Checks

#### 9.1 _ops/state/ directory structure

Verify these subdirectories exist as documented:
- `_ops/state/configs/`
- `_ops/state/resources/`
- `_ops/state/logs/`
- `_ops/state/runs/`

Flag any unexpected subdirectories or files at the `_ops/state/` root level.

#### 9.2 Log subdirectory parity

1. List all subdirectories in `_ops/state/logs/`
2. For each, verify a corresponding manifest skill entry exists
3. Flag log directories for non-existent skills (orphaned logs)
4. (Informational) flag active skills with no log directory (never executed)

#### 9.3 Log format compliance

For each log file in `_ops/state/logs/*/`:
1. If YAML-frontmatter format, verify required frontmatter fields per FORMAT.md:
   - `run.id`, `run.skill_id`, `run.timestamp`
   - `status.outcome` (one of: success | partial | failed | cancelled)
2. If index.yml exists, verify its entries reference existing log files in the same directory

#### 9.4 Runs / configs / resources parity

1. List subdirectories in `_ops/state/runs/`, `_ops/state/configs/`, `_ops/state/resources/`
2. For each, verify a corresponding manifest skill entry exists
3. Flag orphaned subdirectories (skill was removed but state wasn't cleaned up)

#### 9.5 Harness symlink integrity

For each harness adapter (`.claude/skills/`, `.cursor/skills/`, `.codex/skills/`):
1. List all symlinks
2. Verify each symlink target exists and is not broken
3. Verify symlink targets are consistent across all three harness dirs (same set of skills)
4. Flag broken symlinks (target moved or deleted)
5. Flag asymmetric links (present in one harness but not others)

---

## Execution Strategy

### Ordering

Lenses are independent and can run in any order. However, for efficient context use:

1. **Lens 6 (Schema Violations)** first — establishes baseline structural validity
2. **Lens 1 (Registry/Manifest Drift)** — depends on knowing valid field shapes from Lens 6
3. **Lens 2 (Phantom Skills)** — ID sets extracted in Lens 1 feed Lens 2
4. **Lens 3 (Stale Cross-Refs)** — builds on disk presence checks from Lens 2
5. **Lens 7 (Trigger/Invocation Gaps)** — uses manifest data already parsed
6. **Lens 8 (Template Drift)** — independent, reads template + sample skills
7. **Lens 9 (Log/State Coherence)** — independent, reads _ops/state/ tree
8. **Lens 5 (Broken Internal Links)** — expensive link crawl, run late
9. **Lens 4 (Doc-to-Source Misalignment)** — reads architecture docs, run last

### Self-Challenge Phase

After all 9 lenses complete, run a mandatory self-challenge:

1. **Coverage proof:** For each lens, list the files read and verify no declared-in-scope files were skipped
2. **False positive review:** Re-examine each finding ≥ Important severity — can it be explained by an intentional design choice? If so, downgrade to Informational with rationale
3. **Cross-lens consistency:** Check whether findings in one lens contradict findings in another (e.g., Lens 2 says skill X is a phantom, but Lens 1 shows it in all three registries)

### Idempotency

The audit is pure read-only. Running it twice on the same source state produces identical findings. No files are created, modified, or deleted during the audit itself. Only the final report is written.

### Report Structure

```
# Skills Subsystem Health Audit Report

## Summary
- Total findings: N
- By severity: Critical (n) | Important (n) | Minor (n) | Informational (n)
- Coverage: 9/9 lenses completed

## Findings by Lens

### Lens 1: Registry / Manifest Drift
#### [SEVERITY]-L1-NNN: Finding title
- **Affected:** file:line, file:line
- **Expected:** ...
- **Actual:** ...
- **Recommendation:** ...

### Lens 2: Phantom Skills
...

## Coverage Proof
| Lens | Files Examined | Files In Scope | Coverage |
...

## Self-Challenge Log
| Finding ID | Challenge | Disposition |
...

## Recommended Fix Batches
### Batch 1: Critical findings (do first)
...
### Batch 2: Important findings
...
### Batch 3: Minor + informational
...
```

# Skills Subsystem Exhaustive Audit Plan

Date: 2026-02-10

## Context

The skills subsystem has undergone significant structural changes since the last audit cycle: a `_ops/state/` directory consolidation, remediation of 13 cross-artifact alignment issues (A1-A13), validator hardening, capability taxonomy expansion, and documentation updates. Many of these changes are staged but uncommitted. This plan defines an exhaustive audit across 8 dimensions that covers the full subsystem — structure, schemas, validator, documentation, specification compliance, content quality, operational infrastructure, and cross-system integration — producing a graded findings report with actionable remediations.

## Prior Work

| Artifact | Status | Relevance |
|----------|--------|-----------|
| `2026-02-10-skills-subsystem-audit-plan.md` | Executed | Defined 14-dimension audit framework; this plan supersedes it with post-remediation scope |
| `2026-02-10-skills-audit-remediation-plan.md` | Executed | 7-phase remediation; validator passed after |
| `2026-02-10-skills-post-remediation-plan.md` | Partially executed | Phases 1-5 address A1-A13; some items may remain open |
| `2026-02-10-skills-state-directory-consolidation.md` | In-flight | `_ops/state/` migration staged in git; needs verification |

This audit treats all prior work as "claimed done" and independently verifies it.

## Scope

**In scope:**

- `.octon/capabilities/skills/` — all files: manifest.yml, capabilities.yml, registry.yml, README.md, every SKILL.md, every `references/` file, `_ops/state/`, `_scaffold/template/`, `_ops/scripts/`
- `docs/architecture/harness/skills/` — all 10 architecture documents
- `CLAUDE.md` and `AGENTS.md` — skills-related instructions
- `.cursor/commands/` — skill invocation commands
- `.octon/orchestration/workflows/` — workflow files referencing skills paths
- `.octon/cognition/` — analyses and context files referencing skills

**Out of scope:**

- Runtime execution correctness (whether skills produce correct output when invoked)
- Archived skills (`.octon/capabilities/skills/archive/`)
- Historical audit reports in `.octon/output/reports/` (frozen artifacts)
- Workflow subsystem internals (only cross-references to skills paths)

## Output

- **Primary report:** `.octon/output/reports/analysis/2026-02-10-skills-exhaustive-audit.md`
- **Format:** Findings grouped by dimension, each with severity (critical / important / minor / informational), affected files with line numbers, and specific remediation steps
- **Summary table:** Finding count by dimension and severity

---

## Dimension 1: Schema Consistency (cross-artifact alignment)

**Goal:** Every skill's metadata is consistent across all files that reference it. No drift between manifest, registry, capabilities, SKILL.md, and reference files.

**Why critical:** Data spread across 3-4 files per skill is the primary source of bugs. Prior audit found 13 issues here.

### Checks

#### 1.1 manifest.yml ↔ SKILL.md parity

For every skill in manifest.yml:

1. Read SKILL.md frontmatter `name` — must match manifest `id`
2. Read SKILL.md frontmatter `skill_sets` — must match manifest `skill_sets` (same items, order-independent)
3. Read SKILL.md frontmatter `capabilities` — must match manifest `capabilities` (same items, order-independent)
4. Manifest `path` must resolve to a directory containing a SKILL.md
5. Manifest `group` must match the first path segment of `path`

#### 1.2 manifest.yml ↔ capabilities.yml parity

1. Every manifest `group` value appears in capabilities.yml `skill_group_definitions`
2. Every member listed in capabilities.yml `skill_group_definitions` has a corresponding manifest entry
3. Every manifest `skill_sets` value appears in capabilities.yml `skill_set_definitions`
4. Every manifest `capabilities` value appears in capabilities.yml `valid_capabilities`

#### 1.3 manifest.yml ↔ registry.yml parity

1. Every manifest `id` has a corresponding entry under registry.yml `skills:`
2. Every registry.yml `skills:` key has a corresponding manifest entry
3. No orphans in either direction

#### 1.4 registry.yml ↔ SKILL.md parity

1. Registry `parameters` match what SKILL.md documents (name, type, required flag)
2. Registry `io.outputs` paths are writable under SKILL.md `allowed-tools` Write scopes
3. Registry `io.inputs` paths are readable under SKILL.md `allowed-tools` Read/Glob scopes
4. No registry I/O path references a location outside the skill's permitted write scope

#### 1.5 SKILL.md ↔ references/ coherence

1. Resolve the skill's full capability set: expand `skill_sets` → constituent capabilities (from capabilities.yml `skill_set_definitions`), union with directly declared `capabilities`, deduplicate
2. Derive required reference files from the capability-to-reference mapping in capabilities.yml
3. List actual files in `references/` directory
4. Report: missing references (required but absent), orphaned references (present but not required by any declared capability)
5. Exception: `examples.md`, `errors.md`, `io-contract.md` are commonly included regardless of capability — flag as informational only

#### 1.6 Prior remediation verification (A1-A13)

Spot-check that each of the 13 previously identified issues is resolved:

| ID | Issue | Verification |
|----|-------|--------------|
| A1 | vercel-deploy capabilities mismatch | SKILL.md frontmatter includes `external-output` |
| A2 | create-skill parameter inconsistency | SKILL.md, io-contract.md, registry.yml agree on parameter names |
| A3 | create-skill output path inconsistency | All three files use grouped path format |
| A4 | 5 nested skills fail parent-directory naming | Documented as intentional divergence in specification.md |
| A5 | Template/archive placeholder compliance | Validator skips `_scaffold/template/` and `archive/` |
| A6 | Validator parses deprecated `skill_mappings` | Validator uses `skills.<id>.io` |
| A7 | Same as A6 for placeholder checks | Same fix applied |
| A8 | Path-scope validation too permissive | `../../*` escape blocked |
| A9 | Capability/skill-set validation not enforced | Hard validation implemented |
| A10 | Docs claim 17 capabilities vs 20 actual | Docs updated to 20 |
| A11 | 3 new capabilities undocumented | `long-running`, `scheduled`, `external-output` documented |
| A12 | Docs reference `behaviors.md` vs `phases.md` | All instances updated |
| A13 | Flat-path examples in docs | Grouped paths used |

**Tools:** Read (manifest.yml, registry.yml, capabilities.yml), Glob (`**/SKILL.md`, `**/references/*.md`), Grep for drift indicators

---

## Dimension 2: `_ops/state/` Directory Migration Completeness

**Goal:** The consolidation of `configs/`, `resources/`, `runs/`, `logs/` under `_ops/state/` is complete with zero stale references anywhere in the tree.

**Why critical:** This migration touches 100+ files. A single stale path breaks skill execution silently.

### Checks

#### 2.1 Physical structure verification

1. Confirm `_ops/state/` directory exists with exactly 4 subdirectories: `configs/`, `resources/`, `runs/`, `logs/`
2. Confirm old top-level directories (`configs/`, `resources/`, `runs/`, `logs/` at `.octon/capabilities/skills/`) no longer exist
3. Confirm per-skill subdirectories exist inside `_ops/state/` for each skill that needs them

#### 2.2 Stale path sweep

Grep the entire project for old-style paths. Each pattern must return 0 matches (excluding `archive/` and `.octon/output/reports/`):

| Pattern | Search scope | Expected matches |
|---------|-------------|-----------------|
| `path: "configs/` | registry.yml | 0 |
| `path: "resources/` | registry.yml | 0 |
| `path: "runs/` | registry.yml | 0 |
| `path: "logs/` | registry.yml | 0 |
| `Write(logs/` | all SKILL.md | 0 |
| `Write(runs/` | all SKILL.md | 0 |
| `Write(configs/` | all SKILL.md | 0 |
| `Write(resources/` | all SKILL.md | 0 |
| `skills/logs/` | docs/, CLAUDE.md, AGENTS.md | 0 |
| `skills/runs/` | docs/, CLAUDE.md | 0 |
| `skills/configs/` | docs/, CLAUDE.md | 0 |
| `skills/resources/` | docs/ | 0 |

#### 2.3 Updated path correctness

Verify the new paths are correctly formed:

1. Registry.yml I/O paths use `_ops/state/logs/`, `_ops/state/resources/`, etc.
2. SKILL.md `allowed-tools` Write scopes use `_ops/state/logs/*`, `_ops/state/runs/*`
3. Template SKILL.md uses `_ops/state/` prefix in examples and allowed-tools
4. Template reference files use `_ops/state/` prefix in path examples

#### 2.4 Script updates

1. `validate-skills.sh`: References to `logs/`, `runs/`, `configs/`, `resources/` updated to `_ops/state/` equivalents
2. `setup-harness-links.sh`: Exclude list updated (`_state` instead of individual directories)
3. Both scripts execute without error after migration

#### 2.5 Cross-system reference updates

1. CLAUDE.md log path references use `_ops/state/logs/`
2. Workflow files (`.octon/orchestration/`) use `_ops/state/` paths
3. Cursor commands (`.cursor/commands/`) use `_ops/state/` paths
4. Cognition files (`.octon/cognition/`) use `_ops/state/` paths

**Tools:** Bash (`ls`), Grep (stale path patterns across entire project), Read (registry.yml, SKILL.md samples, scripts)

---

## Dimension 3: Validator Coverage and Correctness

**Goal:** The validator (`validate-skills.sh`) accurately enforces all mechanical checks it claims, produces no false positives or false negatives, and covers all automatable contracts from the architecture docs.

**Why critical:** The validator is the primary quality gate. If it's broken or incomplete, all other dimensions lose their automated safety net.

### Checks

#### 3.1 Declared check inventory

Read the validator source and catalogue every named check (27+ claimed). For each check, document:

- Check number and name
- What it validates
- Whether it produces ERROR, WARNING, or INFO
- Which audit dimension it maps to

#### 3.2 Schema parsing correctness

1. Verify the validator parses registry.yml using the current schema (`skills.<id>.io`) not the deprecated `skill_mappings` key
2. Verify output path extraction works for at least 3 skills by comparing validator's extracted paths against manual registry.yml reading
3. Verify placeholder extraction works correctly

#### 3.3 Capability/skill-set enforcement

1. Confirm the validator rejects unknown capability names (not just warns)
2. Confirm the validator checks manifest ↔ SKILL.md capability parity
3. Test: If a SKILL.md declares `capabilities: [nonexistent-capability]`, does the validator ERROR?

#### 3.4 Path-scope validation

1. Confirm `../../*` no longer blanket-passes
2. Confirm paths resolving outside `.octon/` are rejected
3. Confirm legitimate cross-directory paths (e.g., `../../output/drafts/*`) are allowed
4. Test edge case: `../../../../../../etc/passwd` — must be rejected

#### 3.5 Grouped path handling

1. Confirm nested skills like `foundations/react/best-practices` pass directory-exists checks
2. Confirm the name-vs-parent-directory check handles grouped paths correctly (INFO not ERROR when name matches manifest ID but not parent directory)
3. Confirm `_scaffold/template/` and `archive/` are excluded from compliance checks

#### 3.6 Token budget accuracy

1. Verify the token counting method (tiktoken vs word-count fallback) is correctly selected
2. Spot-check 2-3 SKILL.md files: compare validator's token count against manual word count * 1.3
3. Verify reference file budget checks use the correct per-type limits

#### 3.7 Coverage gap analysis

Map architecture doc contracts against validator checks. Identify contracts that are documented but NOT mechanically validated:

| Contract source | Checked by validator? |
|----------------|----------------------|
| Frontmatter required fields (skill-format.md) | ? |
| allowed-tools syntax (specification.md) | ? |
| I/O path containment (execution.md) | ? |
| Trigger format (discovery.md) | ? |
| Status field values (discovery.md) | ? |
| Parameter type values (discovery.md) | ? |
| Output determinism values (discovery.md) | ? |
| Capability-reference mapping (declaration.md) | ? |
| Token budgets per reference type (design-conventions.md) | ? |
| Cross-skill dependency acyclicity (discovery.md) | ? |

#### 3.8 End-to-end validator run

1. Run `validate-skills.sh` with no arguments — capture full output
2. Run `validate-skills.sh --strict` — capture full output
3. Categorize all warnings and errors
4. For each ERROR: verify it's a real issue (not a false positive)
5. For each passing check: spot-check 1-2 skills to confirm correctness (not a no-op)

**Tools:** Read (validate-skills.sh), Bash (run validator), manual analysis

---

## Dimension 4: Documentation ↔ Implementation Drift

**Goal:** All 10 architecture docs under `docs/architecture/harness/skills/` accurately describe the current implementation. No stale schema versions, wrong field names, incorrect path examples, or outdated counts.

**Why important:** Drift between docs and implementation causes incorrect skill creation, broken mental models, and wasted debugging time.

### Checks

#### 4.1 Schema version accuracy

| Document | Claims | Verify against |
|----------|--------|---------------|
| discovery.md | manifest schema version | manifest.yml `schema_version` |
| discovery.md | registry schema version | registry.yml `schema_version` |
| architecture.md | schema versions | same |
| README.md | schema versions | same |

#### 4.2 Capability count and listing

1. Count capabilities in capabilities.yml `valid_capabilities` — record the number
2. Grep docs for numeric capability count claims (e.g., "17 capabilities", "20 capabilities")
3. Check that `declaration.md`, `architecture.md`, `README.md` all cite the correct count
4. Check that any doc listing all capabilities includes `long-running`, `scheduled`, `external-output`

#### 4.3 Path examples

1. Grep docs for flat-path skill directory examples (e.g., `skills/refactor/`, `skills/<skill-name>/`) — should use grouped format (`skills/<group>/<skill-name>/`)
2. Grep docs for old operational directory paths (`skills/logs/`, `skills/configs/`, `skills/runs/`, `skills/resources/`) — should use `_ops/state/` prefix
3. Verify directory tree diagrams in `architecture.md`, `design-conventions.md`, `README.md` show `_ops/state/` structure

#### 4.4 Deprecated terminology

Grep docs for terms that have been replaced:

| Deprecated term | Current term | Files to check |
|----------------|-------------|---------------|
| `skill_mappings` | `skills.<id>.io` | all docs |
| `behaviors.md` | `phases.md` | all docs |
| `archetype` | `skill_sets` / `capabilities` | all docs |
| `requires.tools` | `allowed-tools` | all docs |

#### 4.5 Specification compliance table

Read `specification.md` and verify each row of the spec compliance table:

1. Every "Implemented" claim is accurate (the feature exists)
2. Every "Extension" claim is documented as a Octon extension
3. The tool permission mapping table matches the actual `allowed-tools` parsing logic in the validator
4. The naming policy section documents the grouped-directory divergence

#### 4.6 Cross-document consistency

Verify the same concept is described consistently across docs:

1. **Progressive disclosure tiers** — same tier numbering and file assignments across README.md, architecture.md, discovery.md
2. **Tool permission format** — same syntax across specification.md, execution.md, skill-format.md
3. **Output permission tiers** — same tier definitions across architecture.md, execution.md, discovery.md
4. **Capability-reference mapping** — same mapping across declaration.md, creation.md, architecture.md

**Tools:** Grep (pattern sweeps across docs/), Read (each document), cross-reference analysis

---

## Dimension 5: Specification Compliance (agentskills.io)

**Goal:** Every active skill conforms to the agentskills.io specification, with intentional divergences documented.

### Checks

#### 5.1 Naming rule compliance

For each active skill in manifest.yml:

1. Skill ID is kebab-case, 1-64 characters, action-oriented verb-noun pattern
2. Skill ID matches SKILL.md `name` field
3. For non-nested skills: parent directory name matches skill ID
4. For nested skills (grouped paths): deviation is documented in specification.md

#### 5.2 SKILL.md format compliance

For each active skill:

1. **Required frontmatter:** `name` and `description` present
2. **No deprecated frontmatter:** No `version` field (version lives in registry only)
3. **Line budget:** < 500 lines
4. **Token budget:** < 5,000 tokens (estimate: word count × 1.3)
5. **Required body sections:** "When to Use", "Quick Start" or "Core Workflow", "Boundaries" or "When to Escalate"

#### 5.3 allowed-tools format compliance

For each active skill:

1. `allowed-tools` is space-delimited (not comma-delimited)
2. Each token is a valid tool name optionally followed by a parenthesized scope
3. Write scopes use valid glob patterns
4. Bash scopes reference specific commands
5. No unscoped `Write` or `Bash` (flag as critical)

#### 5.4 Reference file token budgets

For each active skill's reference files:

| Reference | Budget |
|-----------|--------|
| io-contract.md | 2,000 tokens |
| safety.md | 1,600 tokens |
| examples.md | 3,000 tokens |
| phases.md | 6,000 tokens |
| validation.md | 1,500 tokens |
| All others | 2,000 tokens (default) |

Estimate tokens and flag files exceeding their budget.

#### 5.5 Aggregate complexity budget

For each active skill, compute total tokens loaded on activation:

```
SKILL.md tokens + sum(required reference file tokens)
```

Flag any skill exceeding 15,000 tokens aggregate as informational.

**Tools:** Read (all SKILL.md files), word count estimation, Grep for format violations

---

## Dimension 6: Skill Content Quality

**Goal:** Beyond structural checks, audit the semantic quality of skill definitions — clarity, completeness, and correctness of instructions, triggers, placeholders, and boundaries.

### Checks

#### 6.1 Placeholder audit

1. Grep all SKILL.md and reference files for `{{placeholder}}` tokens
2. For each unique placeholder, verify it is either:
   - A standard placeholder documented in execution.md (e.g., `{{skill-name}}`, `{{run-id}}`, `{{timestamp}}`)
   - A skill-specific parameter defined in registry.yml `parameters`
3. Flag undocumented or unresolvable placeholders

#### 6.2 Trigger overlap analysis

1. Extract all `triggers` from manifest.yml
2. Check for exact duplicates across skills
3. Check for high-similarity pairs (shared 3+ consecutive words)
4. For each overlap, determine if ambiguity resolution ("ask" mode) adequately handles it
5. Flag triggers that are too generic (e.g., "help me", "fix this")

#### 6.3 Boundary clarity

For each active, invocable skill (has `commands` in registry):

1. "When to Use" section exists and provides specific, distinguishing criteria
2. "When NOT to Use" or "Boundaries" section exists and names at least one exclusion
3. "When to Escalate" section exists and names conditions that exceed skill scope
4. Escalation conditions are actionable (e.g., ">50 files" not "when it's too complex")

#### 6.4 Output path correctness

For each registry.yml `io.outputs` entry:

1. The output path is writable under the skill's `allowed-tools` Write scopes
2. The output directory would exist at execution time (or the skill creates it)
3. The path follows the output permission tier model (Tier 1/2/3)
4. `determinism` value (`stable` / `variable` / `unique`) is semantically appropriate

#### 6.5 Foundation skill status accuracy

For each skill in the `foundations/` group:

1. If SKILL.md is a skeleton or stub (< 50 lines, contains template placeholders), manifest status must be `draft` or `experimental`
2. If SKILL.md is fully developed, manifest status should be `active`
3. Foundation parent skills (e.g., `python-api`, `react`) correctly describe their child skills
4. Foundation parent skills are non-invocable (no `commands` in registry)

#### 6.6 Cross-skill dependency validity

1. Extract all `depends_on` values from registry.yml
2. Every referenced skill ID exists in manifest.yml with status `active`
3. Build dependency graph; verify no cycles exist
4. For pipeline definitions, verify the pipeline skill IDs all resolve

**Tools:** Grep (placeholder patterns, trigger extraction), Read (SKILL.md body sections, registry.yml), manual review

---

## Dimension 7: Operational Infrastructure

**Goal:** Runtime artifacts (logs, runs, configs, resources) are well-formed, correctly indexed, and free of orphaned or stale data.

### Checks

#### 7.1 Log format compliance

1. Read `_ops/state/logs/FORMAT.md` for the log specification
2. Read each existing log file (e.g., `audit-migration/2026-02-08-workspace-to-harness.md`)
3. Verify YAML frontmatter contains required fields: `run_id`, `skill_id`, `version`, `status`, `started_at`, `completed_at`
4. Verify `status` is one of: `success`, `partial`, `failed`, `cancelled`
5. Verify markdown body follows the prescribed structure

#### 7.2 Log index consistency

1. Read `_ops/state/logs/index.yml` — every entry references a log file that exists on disk
2. Every log file on disk is referenced in the appropriate index
3. Per-skill `index.yml` files (e.g., `_ops/state/logs/audit-migration/index.yml`) are consistent with their directory contents
4. No orphaned log files (present on disk but missing from index)

#### 7.3 Run directory cleanliness

1. List all directories under `_ops/state/runs/`
2. For each directory, check if there are any checkpoint files or just `.gitkeep`
3. Any checkpoint files should reference a valid skill ID that exists in manifest.yml
4. Flag stale checkpoints (no corresponding recent log entry suggesting active execution)

#### 7.4 Config and resource directory cleanliness

1. Every subdirectory under `_ops/state/configs/` matches a skill ID in manifest.yml
2. Every subdirectory under `_ops/state/resources/` matches a skill ID in manifest.yml
3. No orphaned directories for skills that no longer exist

#### 7.5 Script execution verification

1. Run `validate-skills.sh` — exits 0 (or document remaining warnings/errors)
2. Run `setup-harness-links.sh` — exits 0, symlinks created/updated correctly
3. Verify `generate-reference-headers.sh` runs without error (if applicable)

**Tools:** Read (FORMAT.md, log files, index files), Glob (`_ops/state/**/*`), Bash (run scripts)

---

## Dimension 8: Cross-System Integration

**Goal:** All external references to the skills subsystem — from CLAUDE.md, AGENTS.md, workflow files, cursor commands, and cognition files — are accurate and consistent with the current subsystem state.

### Checks

#### 8.1 CLAUDE.md accuracy

1. Progressive disclosure sequence matches reality (manifest → capabilities → registry → SKILL.md → references)
2. File paths are correct (especially `_ops/state/logs/` for the log directory)
3. Safety instruction ("deny-by-default") matches execution.md
4. Quick reference paths all resolve to existing files

#### 8.2 AGENTS.md accuracy

1. Any skills-related instructions reference correct paths
2. Skill invocation patterns match current invocation.md

#### 8.3 Workflow cross-references

For each workflow file that references skills paths:

1. `.octon/orchestration/workflows/meta/create-skill(x)/03-initialize-skill.md` — paths use `_ops/state/` prefix, references grouped directory structure
2. `.octon/orchestration/workflows/quality-gate/orchestrate-audit/06-report.md` — paths use `_ops/state/` prefix

#### 8.4 Cursor command accuracy

1. `.cursor/commands/use-skill.md` — invocation pattern matches current invocation.md
2. `.cursor/commands/synthesize-research.md` — resource and log paths use `_ops/state/` prefix

#### 8.5 Cognition file accuracy

1. `.octon/cognition/analyses/workflows-vs-skills-analysis.md` — skill path references use `_ops/state/` prefix and grouped format
2. `.octon/cognition/context/primitives.md` — skills subsystem description matches current architecture

#### 8.6 Host adapter symlinks

1. Run `setup-harness-links.sh` and verify symlinks are created for `.claude/skills`, `.cursor/skills`, `.codex/skills`
2. Each symlink resolves to the correct skill directory
3. Nested/grouped skills are properly linked
4. `_ops/state/`, `_scaffold/template/`, and `_ops/scripts/` are excluded from symlinks

**Tools:** Read (CLAUDE.md, AGENTS.md, workflow files, cursor commands, cognition files), Grep (path patterns), Bash (symlink verification)

---

## Execution Strategy

### Phase ordering

Phases are ordered to maximize early signal — structural issues found in Phase 1 inform all later phases.

| Phase | Dimensions | Rationale | Parallelism |
|-------|-----------|-----------|-------------|
| **Phase 1** | D3 (Validator) | Run validator first to get mechanical baseline; identify broken checks before relying on them | Sequential — single script run |
| **Phase 2** | D1 (Schema), D2 (Migration) | Core integrity: if cross-artifact alignment or migration is broken, everything downstream is unreliable | Parallel — independent file reads |
| **Phase 3** | D5 (Spec Compliance), D4 (Doc Drift) | Specification and documentation checks build on confirmed structural correctness | Parallel — independent analyses |
| **Phase 4** | D6 (Content Quality), D7 (Infrastructure) | Semantic quality and operational hygiene require correct structure as a precondition | Parallel — independent analyses |
| **Phase 5** | D8 (Integration) | Cross-system checks run last because they depend on knowing the correct state of the subsystem | Sequential — focused sweep |
| **Phase 6** | Synthesis | Aggregate all findings, assign severities, draft remediation plan | Sequential — report writing |

### Estimated scope per phase

| Phase | Files read | Grep sweeps | Scripts run | Estimated findings |
|-------|-----------|------------|-------------|-------------------|
| 1 | 1 (validator source) | 0 | 2 (validator, validator --strict) | 5-15 |
| 2 | ~50 (all SKILL.md + YAML files) | 12+ (stale path patterns) | 0 | 10-30 |
| 3 | ~15 (docs + spec) | 8+ (deprecated term patterns) | 0 | 5-15 |
| 4 | ~40 (SKILL.md bodies + references) | 3+ (placeholder, trigger) | 0 | 10-20 |
| 5 | ~10 (cross-system files) | 5+ (path patterns) | 1 (symlink setup) | 3-10 |
| 6 | 0 (synthesis from prior phases) | 0 | 0 | — |

### Agent strategy

Phase 2 and Phase 3 each contain two independent dimensions that can be audited by parallel agents. Phase 4 similarly. This gives the following agent allocation:

```
Phase 1: 1 agent  → D3 (Validator)
Phase 2: 2 agents → D1 (Schema) + D2 (Migration)
Phase 3: 2 agents → D5 (Spec) + D4 (Docs)
Phase 4: 2 agents → D6 (Content) + D7 (Infrastructure)
Phase 5: 1 agent  → D8 (Integration)
Phase 6: 1 agent  → Synthesis and report writing
```

Total: 6 phases, up to 2 parallel agents per phase.

### Severity definitions

| Severity | Criteria | Examples |
|----------|----------|---------|
| **Critical** | Data loss risk, security issue, or silent execution failure | Unscoped `Write` or `Bash`, path escape vulnerability, validator no-op check |
| **Important** | Incorrect behavior that doesn't cause data loss but produces wrong results | Manifest ↔ SKILL.md capability mismatch, stale path in registry.yml |
| **Minor** | Cosmetic or low-impact inconsistency | Doc count mismatch, missing optional body section, orphaned `.gitkeep` |
| **Informational** | Observation or improvement opportunity | Trigger overlap handled by ambiguity resolution, aggregate token budget near limit |

### Success criteria

The audit is complete when:

1. Every check in every dimension has been executed and documented
2. Every finding has a severity, affected file(s), and remediation
3. The validator has been run and its output reconciled with manual findings
4. A remediation plan is appended to the report with phased fix ordering
5. Zero critical findings remain unaddressed (or explicitly accepted with rationale)

---

## Report Structure

```markdown
# Skills Subsystem Exhaustive Audit Report
Date: 2026-02-10

## Executive Summary
- Total findings: N (C critical, I important, M minor, F informational)
- Dimensions audited: 8
- Skills examined: 35
- Files read: ~120

## Findings by Dimension

### D1: Schema Consistency
#### [C/I/M/F]-D1-001: <title>
- **Severity:** critical | important | minor | informational
- **Files:** file:line, file:line
- **Description:** What's wrong
- **Evidence:** Specific values showing the inconsistency
- **Remediation:** Specific fix steps

### D2: Migration Completeness
...

### D3: Validator Coverage
...

(repeat for D4-D8)

## Prior Remediation Verification
- A1: ✓ resolved / ✗ still present
- A2: ✓ / ✗
...

## Summary Table
| Dimension | Critical | Important | Minor | Informational |
|-----------|----------|-----------|-------|---------------|
| D1 Schema | | | | |
| D2 Migration | | | | |
| ... | | | | |
| **Total** | | | | |

## Remediation Plan
### Priority 1 (Critical)
...
### Priority 2 (Important)
...
### Priority 3 (Minor)
...
```

# Skills Subsystem Audit Plan

Date: 2026-02-10

## Context

An exhaustive, bounded audit of the `.octon/capabilities/skills/` subsystem across 14 dimensions: structural integrity, schema conformance, single-source-of-truth enforcement, capability-reference coherence, token budgets, trigger quality, security and safety, cross-skill dependencies, lifecycle and versioning, logging and runtime artifacts, documentation completeness, validator alignment, foundation hierarchy, and template completeness. The audit produces a findings report with severity-graded issues and actionable remediations.

## Scope

**In scope:** All files under `.octon/capabilities/skills/`, including manifest.yml, capabilities.yml, registry.yml, all SKILL.md files, all reference files, logs/, runs/, configs/, resources/, scripts/, and _scaffold/template/.

**Out of scope:** Workflow subsystem, command subsystem, agent definitions, host adapter behavior, runtime execution correctness (the audit checks structure and documentation, not whether skills produce correct output when invoked).

## Output

- Primary report: `.octon/output/reports/analysis/2026-02-10-skills-subsystem-audit.md`
- Format: Findings grouped by dimension, each with severity (critical / important / minor / informational), affected files, and remediation

## Execution Strategy

Run `validate-skills.sh` first to capture mechanical checks, then perform manual/agent-driven analysis for dimensions the validator cannot cover. Dimensions 1-6 overlap heavily with the validator; dimensions 7-14 require reading and judgment.

---

## Dimension 1: Structural Integrity

**Goal:** Every skill directory has a SKILL.md; every manifest/registry entry points to a real directory; no orphan directories exist without corresponding entries.

**Checks:**

1. List all directories under skills/ that contain a SKILL.md (excluding _template, archive, logs, runs, configs, resources, scripts)
2. List all `id` values in manifest.yml
3. List all top-level keys in registry.yml's `skills:` block
4. Compute set differences: directories without manifest entries, manifest entries without directories, registry entries without manifest entries, manifest entries without registry entries
5. Verify every manifest `path` resolves to an existing directory containing a SKILL.md

**Tools:** Glob, Grep, Read (manifest.yml, registry.yml)

## Dimension 2: Schema Conformance

**Goal:** Every entry in manifest.yml, registry.yml, and capabilities.yml uses valid field names, types, and values.

**Checks:**

1. **manifest.yml:** Every skill entry has required fields: `id`, `display_name`, `group`, `path`, `summary`, `status`, `tags`, `triggers`, `skill_sets`. Optional: `capabilities`
2. **manifest.yml field values:** `status` is one of `active | deprecated | experimental | draft`; `group` is defined in capabilities.yml `skill_group_definitions`; every `skill_sets` value is defined in capabilities.yml `skill_set_definitions`; every `capabilities` value is defined in capabilities.yml `valid_capabilities`
3. **registry.yml:** Every skill entry has required fields: `version`, `commands`, `io`. `parameters` is optional but if present each parameter has `name`, `type`, `required`, `description`. `type` is one of `text | boolean | file | folder`
4. **registry.yml I/O:** Every `io.outputs` entry has `name`, `path`, `kind`, `format`, `determinism`, `description`. `determinism` is one of `stable | variable | unique`
5. **SKILL.md frontmatter:** Has required fields: `name`, `description`, `skill_sets`, `allowed-tools`. Optional: `capabilities`, `license`, `compatibility`, `metadata`

**Tools:** Read (all three YAML files + sample SKILL.md files), Grep for field presence

## Dimension 3: Single Source of Truth Enforcement

**Goal:** No data duplication or drift between manifest, registry, SKILL.md, and capabilities.yml.

**Checks:**

1. **allowed-tools:** Appears only in SKILL.md frontmatter. Grep registry.yml and manifest.yml for `allowed-tools` or `requires.tools` — should find nothing
2. **version:** Appears only in registry.yml. Grep all SKILL.md files for `version:` in frontmatter — should find nothing (or only schema_version-type fields)
3. **parameters:** Defined only in registry.yml. SKILL.md may reference parameters but must not redefine them with conflicting types/defaults
4. **I/O paths:** Defined only in registry.yml. SKILL.md may describe output location but must not contradict registry paths
5. **Summary alignment:** manifest.yml `summary` aligns with first sentence of SKILL.md `description` (semantic check, not exact match)

**Tools:** Grep across all SKILL.md files, Read (registry.yml, manifest.yml)

## Dimension 4: Capability-Reference Coherence

**Goal:** Every declared capability maps to the correct required reference files, and those files exist. No superfluous reference files.

**Checks:**

1. Read capabilities.yml to extract the capability-to-reference-file mapping
2. For each skill, resolve its full capability set: expand `skill_sets` into their constituent capabilities (from `skill_set_definitions`), then add any directly declared `capabilities`
3. Compute the required reference files from the resolved capability set
4. List actual reference files in the skill's `references/` directory
5. Compute: missing references (required but absent), superfluous references (present but not required by any declared capability)
6. Special case: `examples.md` and `errors.md` are commonly included even without a specific capability trigger — flag as informational, not error

**Tools:** Read (capabilities.yml), Glob (`**/references/*.md`), per-skill comparison

## Dimension 5: Token Budgets

**Goal:** All files stay within declared token limits.

**Checks:**

1. SKILL.md: < 5,000 tokens, < 500 lines (every skill)
2. Manifest entry: < 150 tokens per skill (approximate from YAML block size)
3. Reference files: within declared budgets where specified (io-contract: 2,000; safety: 1,600; examples: 3,000; phases: 6,000; validation: 1,500)
4. Aggregate: total tokens loaded for a single skill activation (SKILL.md + all required references) stays reasonable (< 15,000 tokens as a guideline)

**Tools:** Read + word count approximation (tokens ~ words * 1.3), or delegate to `validate-skills.sh` which has tiktoken support

## Dimension 6: Trigger Quality

**Goal:** Triggers are unambiguous, semantically aligned, and properly scoped.

**Checks:**

1. **No overlaps:** No two skills share a trigger phrase that would cause ambiguous routing. Extract all triggers from manifest.yml, check for exact duplicates and high-similarity pairs
2. **Semantic alignment:** Each trigger phrase is a reasonable way a user might invoke that specific skill (not a generic phrase like "help me" that could match anything)
3. **Format:** Triggers are natural-language phrases, not slash commands (slash commands belong in registry.yml `commands`)
4. **Coverage:** Skills have enough triggers to be discoverable (at least 2-3 per skill)

**Tools:** Read (manifest.yml), manual review of trigger lists

## Dimension 7: Security and Safety

**Goal:** Tool permissions follow deny-by-default, write scopes are minimal, no privilege escalation paths.

**Checks:**

1. **allowed-tools parsing:** Every SKILL.md `allowed-tools` value parses correctly into tool names and optional scopes
2. **Write scope minimality:** `Write()` scopes are as narrow as possible. Flag any `Write(**)` or `Write(*)` as critical. Review each `Write(path/*)` for whether the path is appropriately constrained
3. **Bash scope:** Any `Bash()` permissions are explicitly scoped to specific commands (e.g., `Bash(mkdir)`, `Bash(ln)`). Flag unscoped `Bash` as critical
4. **No escalation:** No skill grants access to modify manifest.yml, capabilities.yml, or registry.yml unless it is explicitly a meta skill (create-skill). Even then, verify scope is appropriate
5. **I/O containment:** Cross-reference registry.yml `io.outputs` paths with SKILL.md `allowed-tools` Write scopes — outputs should be writable, but nothing beyond

**Tools:** Grep for `allowed-tools` across all SKILL.md files, Read each, manual analysis

## Dimension 8: Cross-Skill Dependencies

**Goal:** Dependency graph is valid, acyclic, and all referenced skills exist.

**Checks:**

1. Extract all `depends_on` values from registry.yml
2. Verify every referenced skill ID exists in manifest.yml with status `active`
3. Build dependency graph; check for cycles
4. Verify no circular dependency chains
5. Check that foundation skill sets correctly declare their child skills and child skill paths resolve

**Tools:** Read (registry.yml, manifest.yml), graph analysis

## Dimension 9: Lifecycle and Versioning

**Goal:** Status fields are accurate, versions are meaningful, no stale skills.

**Checks:**

1. **Status accuracy:** Every skill's `status` in manifest.yml reflects its actual state. `draft` skills should have incomplete SKILL.md or missing references. `active` skills should be fully formed
2. **Version semantics:** registry.yml versions follow semver. Skills that have been modified since their `metadata.updated` date are flagged as potentially stale
3. **Archive integrity:** Skills in `archive/` are not referenced by active manifest/registry entries
4. **Stub detection:** Foundation stubs (data-pipeline, node-api) are either `draft`/`experimental` in manifest or absent — not `active`

**Tools:** Read (manifest.yml, registry.yml), Glob (archive/), spot-check SKILL.md metadata dates

## Dimension 10: Logging and Runtime Artifacts

**Goal:** Log format is consistent, indexes are accurate, no stale runtime state.

**Checks:**

1. **FORMAT.md compliance:** Read FORMAT.md, then spot-check existing logs for conformance (YAML frontmatter with required fields, markdown body, valid status outcomes: `success | partial | failed | cancelled`)
2. **Index consistency:** `logs/index.yml` references only logs that exist on disk. Per-skill `index.yml` files are consistent with their directory contents
3. **Runs cleanliness:** Check `runs/` for stale checkpoint data — directories for skills that have no recent log entries suggesting active execution
4. **Configs cleanliness:** Check `configs/` for orphaned configuration (skills that no longer exist)
5. **Resources cleanliness:** Check `resources/` for orphaned input materials

**Tools:** Read (FORMAT.md, index files, sample logs), Glob (runs/, configs/, resources/), cross-reference with manifest skill IDs

## Dimension 11: Documentation Completeness

**Goal:** README, template, and inline documentation accurately reflect current state.

**Checks:**

1. **README.md accuracy:** Skills count, group names, architecture description, and single-source-of-truth table match actual state
2. **SKILL.md body sections:** Every active SKILL.md has the required body sections: When to Use, Quick Start, Core Workflow, Boundaries, When to Escalate, References
3. **Reference content quality:** Spot-check 3-5 reference files for substantive content vs. placeholder stubs. Glossary files for `specialist`/`domain-specialized` skills should have real terminology, not template placeholders
4. **capabilities.yml comments:** Inline documentation matches actual structure

**Tools:** Read (README.md, sample SKILL.md files, sample references), manual review

## Dimension 12: Validator Alignment

**Goal:** The validator covers all audit dimensions it can mechanically check, and produces correct results.

**Checks:**

1. **Coverage mapping:** Map each of the 27 validator checks to the 14 audit dimensions. Identify dimensions with no validator coverage
2. **Correctness:** Run `validate-skills.sh` and review output. For any "pass" result, spot-check 1-2 skills manually to confirm the check is actually working (not a no-op due to parsing bugs like the historical `skill_mappings` issue)
3. **False negatives:** Intentionally check for known issues (from prior audits/remediations) that the validator should catch — verify it does
4. **--fix mode:** Verify `--fix` mode produces correct scaffolding and doesn't corrupt existing data

**Tools:** Bash (run validator), Read (validate-skills.sh source for check inventory), manual cross-reference

## Dimension 13: Foundation Hierarchy

**Goal:** Foundation skill sets and their child skills are correctly structured.

**Checks:**

1. **Parent SKILL.md:** Foundation skill sets (python-api, swift-macos-app, react, react-native, postgres) have SKILL.md files that describe the foundation, not a specific invocable action
2. **Child skill listing:** Each foundation's manifest entry or SKILL.md lists its child skills; those children exist as subdirectories
3. **Child manifest entries:** Child skills (e.g., scaffold-package under python-api) have their own manifest entries with correct `path` (nested path)
4. **Invocability:** Foundation parents are marked as non-invocable or have no `commands` in registry. Children are invocable
5. **Stubs:** Foundation stubs (data-pipeline, node-api) are properly marked as draft/experimental, not active

**Tools:** Read (foundation SKILL.md files), Glob (foundation directories), Read (manifest.yml, registry.yml)

## Dimension 14: Template Completeness

**Goal:** The `_scaffold/template/` directory provides complete, accurate scaffolding for new skills.

**Checks:**

1. **Reference coverage:** `_scaffold/template/references/` contains a template for every reference file type that any capability can require (cross-reference with capabilities.yml capability-to-reference mapping). Currently 20 templates — verify none are missing
2. **SKILL.md template:** `_scaffold/template/SKILL.md` includes all required frontmatter fields and body sections
3. **Placeholder format:** All placeholders use `{{snake_case}}` convention consistently
4. **Template-to-live drift:** Compare template SKILL.md structure against a recently created skill to verify the template hasn't drifted from actual practice
5. **Scaffolding directories:** `_scaffold/template/scripts/` and `_scaffold/template/assets/` exist (even if empty) so `create-skill` can copy them

**Tools:** Read (_scaffold/template/SKILL.md, _scaffold/template/references/*), Glob (_scaffold/template/), Read (capabilities.yml for reference mapping)

---

## Execution Order

Dimensions are ordered to maximize early signal and minimize redundant reads:

| Phase | Dimensions | Rationale |
|-------|-----------|-----------|
| 1 | 12 (Validator Alignment) | Run validator first to get mechanical baseline; identify any broken checks before relying on them |
| 2 | 1, 2, 3 (Structure, Schema, SSOT) | Core integrity — if these fail, later dimensions are unreliable |
| 3 | 4, 5 (Capabilities, Tokens) | Capability coherence and budget checks build on structural correctness |
| 4 | 6, 7, 8 (Triggers, Security, Dependencies) | Safety and routing quality |
| 5 | 9, 10 (Lifecycle, Logging) | Operational hygiene |
| 6 | 11, 13, 14 (Docs, Foundations, Template) | Documentation and scaffolding completeness |

## Parallelism

Within each phase, all dimensions can be audited in parallel since they read overlapping files but produce independent findings. Phases are sequential because later phases depend on earlier confidence.

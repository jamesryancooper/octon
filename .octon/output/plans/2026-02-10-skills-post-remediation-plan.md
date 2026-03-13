# Skills System Follow-Up Remediation Plan

Date: 2026-02-10

## Context

The follow-up architectural audit (`.octon/output/reports/analysis/2026-02-10-skills-follow-up-architectural-audit.md`) identified 13 cross-artifact alignment issues (A1-A13), validator coverage gaps, and documentation drift. All findings have been independently verified against source files. This plan addresses the audit's Critical and Important action items in dependency order, with validator improvements first (so subsequent changes can be validated), then data fixes, then docs.

## Phase 1: Fix vercel-deploy capability regression (A1)

**Why first:** This is a data-level regression introduced during the taxonomy expansion. Trivial fix, blocks nothing, but should be resolved immediately.

**Files:**

- `.octon/capabilities/skills/platforms/vercel/deploy/SKILL.md` — line 14

**Changes:**

- Change `capabilities: []` to `capabilities: [external-output]` in SKILL.md frontmatter to match manifest.yml line 328.

## Phase 2: Validator schema migration — `skill_mappings` to `skills.<id>.io` (A6, A7)

**Why:** The validator's path-scope and placeholder checks parse a `skill_mappings:` YAML key that no longer exists in the registry (the current schema uses `skills.<id>:` with nested `io:`). This means those checks are no-ops. Fixing the parser unblocks accurate validation for all subsequent phases.

**Files:**

- `.octon/capabilities/skills/scripts/validate-skills.sh`

**Changes:**

1. **`get_output_paths()` (lines 557-571):** Replace awk pattern that searches for `skill_mappings:` with one that searches under `skills:` → `<skill_id>:` → `io:` → `outputs:` → `path:`.

2. **`validate_skill_placeholders()` (lines 670-701):** Same awk pattern fix — search under `skills.<id>.io` instead of `skill_mappings.<id>`.

3. **`check_deprecated_placeholder_formats()` (lines 707-738):** Same awk pattern fix.

4. **User-facing message at line 2052:** Change `skill_mappings.$skill_id` to `skills.$skill_id.io` in the guidance string.

5. **`scaffold_io_mapping()` (lines 1276-1307):** Update scaffold template to emit `skills.<id>:` structure with nested `io:` instead of `skill_mappings:` format. Update the guidance message on line 1303.

## Phase 3: Add hard capability/skill-set validation to validator (A9)

**Why:** The validator declares checks 26 and 27 in its header but only implements soft heuristics. The `VALID_CAPABILITIES` and `VALID_SKILL_SETS` arrays are defined (lines 91-92) but never used for rejection. This means invalid capability names pass silently.

**Files:**

- `.octon/capabilities/skills/scripts/validate-skills.sh`

**Changes:**

1. Add a new function `validate_declared_capabilities()` that:
   - Extracts `skill_sets` and `capabilities` from SKILL.md frontmatter (already parsed elsewhere)
   - Checks each against `VALID_SKILL_SETS` and `VALID_CAPABILITIES` arrays
   - Logs errors for unknown values

2. Add a new function `validate_manifest_skill_parity()` that:
   - Compares manifest `skill_sets`/`capabilities` against SKILL.md frontmatter values
   - Logs errors on mismatch (would have caught A1)

3. Wire both into `validate_skill()` (after existing check 14, around line 2076).

## Phase 4: Fix path-scope validation permissiveness (A8)

**Why:** The `../../*` auto-allow at line 581 lets any path with that prefix pass without checking the destination. A path like `../../../../../../etc/passwd` would pass.

**Files:**

- `.octon/capabilities/skills/scripts/validate-skills.sh`

**Changes:**

- In `validate_path_scope()` (lines 575-603), replace the blanket `../../*` allow with a check that the resolved destination starts with the `.octon/` prefix. Allow `../../output/`, `../../scaffolding/`, and `../../continuity/` as known safe destinations. Reject paths that escape the `.octon/` tree.

## Phase 5: Reconcile create-skill contracts (A2, A3)

**Why:** The create-skill SKILL.md, io-contract.md, and registry.yml are mutually inconsistent about parameters and output paths.

**Files:**

- `.octon/capabilities/skills/meta/create-skill/SKILL.md` — lines 66, 73
- `.octon/capabilities/skills/meta/create-skill/references/io-contract.md` — lines 24, 31-38, 56-58, 34 (`behaviors.md`), 93 (`behaviors.md`)
- `.octon/capabilities/skills/registry.yml` — lines 635-644, 655

**Changes:**

1. **SKILL.md line 66:** Change "archetype" to "skill_sets and capabilities" to match registry parameters.

2. **SKILL.md line 73:** Change `{{skill-name}}/` to `<group>/{{skill-name}}/` to reflect grouped layout.

3. **io-contract.md parameter table (line 24):** Replace `archetype` row with `skill_sets` and `capabilities` rows matching registry.yml definitions.

4. **io-contract.md output structure (lines 31-38):** Update path from `.octon/capabilities/skills/{{skill-name}}/` to `.octon/capabilities/skills/<group>/{{skill-name}}/`. Replace `behaviors.md` with `phases.md` in the directory tree.

5. **io-contract.md symlink targets (lines 56-58):** Update symlink paths to use grouped format.

6. **io-contract.md checkpoint schema (line 93):** Replace `behaviors.md` with `phases.md` in `files_created`.

7. **io-contract.md checkpoint parameters (line 119):** Replace `archetype: "complex"` with `skill_sets` and `capabilities` fields.

8. **registry.yml line 655:** Change `path: "{{skill_name}}/"` to `path: "<group>/{{skill_name}}/"` or use a `{{group}}` placeholder.

## Phase 6: Codify grouped-directory naming policy (A4, A5)

**Why:** 5 nested skills fail the strict agentskills.io parent-directory naming rule. Rather than restructuring directories, this should be explicitly documented and the validator should acknowledge the variance.

**Files:**

- `.octon/capabilities/skills/scripts/validate-skills.sh` — check 3 (line 1946-1952)
- `docs/architecture/harness/skills/specification.md` (add policy note)

**Changes:**

1. **Validator check 3:** When the SKILL.md `name` matches the manifest `id` but not the parent directory, and the skill has a grouped `path` in manifest, downgrade from ERROR to INFO with a note that this is an intentional grouped-directory variance. The check should still ERROR if name doesn't match manifest `id`.

2. **specification.md:** Add a "Naming Policy" section documenting that Octon uses globally-unique skill IDs (e.g., `react-best-practices`) nested under domain directories (e.g., `foundations/react/best-practices/`), which is an intentional deviation from the strict agentskills.io parent-directory match rule.

3. **Template/archive exclusion:** Add a skip condition in the validator for `_template` and `archive/` directories so they don't appear in compliance reports as failures.

## Phase 7: Documentation drift fixes (A10, A11, A12, A13)

**Why:** Multiple docs files contain stale capability counts, missing capability entries, wrong reference filenames, and flat path examples.

**Files and changes:**

### A10 — Update capability count from 17 to 20

- `docs/architecture/harness/skills/README.md` line 92
- `docs/architecture/harness/skills/architecture.md` line 348
- `docs/architecture/harness/skills/comparison.md` line 117

### A11 — Add missing capability mappings

- `docs/architecture/harness/skills/capabilities.md` — Add Temporal and Output categories with `long-running`, `scheduled`, `external-output` entries including their reference file mappings. Add to the YAML mapping block (lines 79-97).

### A12 — Replace `behaviors.md` with `phases.md`

- `docs/architecture/harness/skills/specification.md` lines 238, 316
- `docs/architecture/harness/skills/creation.md` lines 154-158, 215
- `docs/architecture/harness/skills/skill-format.md` line 153

### A13 — Replace flat-path examples with grouped paths

- `docs/architecture/harness/skills/declaration.md` line 13: `path: refactor/` → `path: quality-gate/refactor/`
- `docs/architecture/harness/skills/creation.md` line 151: `.octon/capabilities/skills/<skill-name>/` → `.octon/capabilities/skills/<group>/<skill-name>/`

### A11 supplement — Update validation.md capability list

- `docs/architecture/harness/skills/validation.md` lines 12-37: Add `long-running`, `scheduled`, `external-output` to the valid_capabilities list and add their reference mappings to the table at lines 70-88.

## Phase 8: Run validator and verify

**Verification steps:**

1. Run `bash .octon/capabilities/skills/scripts/validate-skills.sh` — should exit 0 with reduced warnings (target: < 72).
2. Verify `vercel-deploy` passes capability parity check (Phase 1 + Phase 3 combined).
3. Grep for `skill_mappings` in validator — should return 0 matches (Phase 2).
4. Grep for `behaviors.md` in docs/ — should return 0 matches (Phase 7).
5. Grep for `"17 capabilities"` in docs/ — should return 0 matches (Phase 7).
6. Verify `create-skill` SKILL.md, io-contract.md, and registry.yml all reference consistent parameter names and grouped paths (Phase 5).
7. Manual spot-check: validator should warn/error on an invalid capability name if injected into a test SKILL.md (Phase 3).

## Summary

| Phase | Priority | Scope | Files Modified |
|-------|----------|-------|----------------|
| 1 | Critical | Fix regression | 1 |
| 2 | Critical | Validator schema fix | 1 |
| 3 | Critical | Validator enforcement | 1 |
| 4 | Critical | Validator security | 1 |
| 5 | Critical | Contract reconciliation | 3 |
| 6 | Important | Naming policy | 2 |
| 7 | Important | Docs alignment | 8 |
| 8 | Verification | Validation run | 0 |

Total files modified: ~14 (some overlap in validator across phases 2-4).

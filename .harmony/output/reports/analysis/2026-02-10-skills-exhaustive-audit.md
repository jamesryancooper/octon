# Skills Subsystem Exhaustive Audit Report

Date: 2026-02-10
Executed: 2026-02-11

## Executive Summary

- Total findings: **14** (**3 critical**, **8 important**, **2 minor**, **1 informational**)
- Dimensions audited: **8**
- Skills examined: **34** (33 active, 1 draft)
- Core YAML parity: manifest/registry/capabilities counts are aligned (34/34 skills, 20 capabilities)
- Validator baseline: `.harmony/capabilities/skills/_scripts/validate-skills.sh` and `--strict` both passed

## Findings by Dimension

### D1: Schema Consistency

#### [I]-D1-001: Capability-to-reference contract drift for executor foundation child skills

- **Severity:** important
- **Files:**
  - `docs/architecture/harness/skills/declaration.md:164`
  - `docs/architecture/harness/skills/declaration.md:170`
  - `docs/architecture/harness/skills/declaration.md:189`
  - `docs/architecture/harness/skills/declaration.md:212`
  - `.harmony/capabilities/skills/foundations/python-api/scaffold-package/SKILL.md:7`
  - `.harmony/capabilities/skills/foundations/swift-macos-app/scaffold-package/SKILL.md:7`
- **Description:** Multiple foundation child skills declare `skill_sets: [executor]` but do not provide the capability-derived references (`phases.md`, `decisions.md`, `checkpoints.md`) described by the declaration/validation docs.
- **Evidence:** 12 active foundation child skills are in this state (python and swift families).
- **Remediation:** Either (1) add required reference files for executor capabilities, or (2) reclassify these skills to declarations that match their actual reference model and update docs/validator rules together.

#### [I]-D1-002: `create-skill` docs use legacy hyphen placeholder style while registry enforces snake_case

- **Severity:** important
- **Files:**
  - `.harmony/capabilities/skills/meta/create-skill/SKILL.md:73`
  - `.harmony/capabilities/skills/meta/create-skill/SKILL.md:74`
  - `.harmony/capabilities/skills/meta/create-skill/references/io-contract.md:32`
  - `.harmony/capabilities/skills/meta/create-skill/references/io-contract.md:52`
  - `.harmony/capabilities/skills/meta/create-skill/references/io-contract.md:78`
  - `.harmony/capabilities/skills/registry.yml:1083`
- **Description:** `create-skill` prose references `{{skill-name}}` / `{{run-id}}` while registry paths use `{{skill_name}}` / `{{run_id}}`.
- **Evidence:** SKILL/reference examples and registry placeholders do not match naming convention.
- **Remediation:** Standardize user-facing examples to snake_case placeholders to match validator expectations.

### D2: `_state/` Migration Completeness

No material findings.

- `_state/{configs,resources,runs,logs}` exists.
- Old top-level `configs/`, `resources/`, `runs/`, `logs/` directories under skills root are absent.
- Stale-path grep sweeps for the defined migration patterns returned 0 matches in scoped targets.

### D3: Validator Coverage and Correctness

#### [I]-D3-001: Validator does not enforce several documented contracts

- **Severity:** important
- **Files:**
  - `.harmony/capabilities/skills/_scripts/validate-skills.sh:14`
  - `.harmony/capabilities/skills/_scripts/validate-skills.sh:42`
  - `.harmony/capabilities/skills/_scripts/validate-skills.sh:2424`
  - `.harmony/capabilities/skills/_scripts/validate-skills.sh:2428`
  - `.harmony/capabilities/skills/_scripts/validate-skills.sh:1469`
- **Description:** The validator passes both normal/strict runs but does not currently enforce key documented contracts: unscoped `Write`, trigger format quality, manifest `status` value set, registry `parameter.type` enum validation, registry `io.outputs[].determinism` enum validation, and dependency cycle detection.
- **Evidence:** Check inventory excludes these controls; implementation only explicitly hard-fails unscoped `Bash` (not `Write`).
- **Remediation:** Add explicit checks for each contract and gate them in strict mode at minimum.

### D4: Documentation ↔ Implementation Drift

#### [M]-D4-001: Creation/design docs still prescribe deprecated archetype framing

- **Severity:** minor
- **Files:**
  - `docs/architecture/harness/skills/creation.md:172`
  - `docs/architecture/harness/skills/creation.md:198`
  - `docs/architecture/harness/skills/creation.md:208`
  - `docs/architecture/harness/skills/design-conventions.md:8`
  - `docs/architecture/harness/skills/design-conventions.md:182`
- **Description:** Core creation guidance still instructs “atomic vs complex archetype” decisions, while the current model is capability/skill-set based.
- **Evidence:** Archetype-oriented post-creation instructions are still normative in active docs.
- **Remediation:** Rewrite creation conventions around `skill_sets` + `capabilities`; keep archetype language only in clearly labeled migration-only docs.

### D5: Specification Compliance

#### [C]-D5-001: Unscoped `Write` permission appears in active invocable skills

- **Severity:** critical
- **Files:**
  - `.harmony/capabilities/skills/foundations/python-api/scaffold-package/SKILL.md:10`
  - `.harmony/capabilities/skills/foundations/python-api/contract-first-api/SKILL.md:10`
  - `.harmony/capabilities/skills/foundations/python-api/test-harness/SKILL.md:10`
  - `.harmony/capabilities/skills/foundations/python-api/dev-toolchain/SKILL.md:10`
  - `.harmony/capabilities/skills/foundations/python-api/infra-manifest/SKILL.md:10`
  - `.harmony/capabilities/skills/foundations/python-api/contributor-guide/SKILL.md:10`
  - `.harmony/capabilities/skills/foundations/swift-macos-app/scaffold-package/SKILL.md:10`
  - `.harmony/capabilities/skills/foundations/swift-macos-app/data-layer/SKILL.md:10`
  - `.harmony/capabilities/skills/foundations/swift-macos-app/cli-interface/SKILL.md:10`
  - `.harmony/capabilities/skills/foundations/swift-macos-app/daemon-service/SKILL.md:10`
  - `.harmony/capabilities/skills/foundations/swift-macos-app/test-harness/SKILL.md:10`
  - `.harmony/capabilities/skills/foundations/swift-macos-app/contributor-guide/SKILL.md:10`
  - `.harmony/capabilities/skills/meta/build-mcp-server/SKILL.md:18`
- **Description:** 13 active invocable skills grant unscoped filesystem write capability.
- **Evidence:** `allowed-tools` includes bare `Write` token (no scope).
- **Remediation:** Scope writes explicitly (`Write(_state/.../*)` and/or `Write(../../output/.../*)` or equivalent scoped paths) and update validator to fail bare `Write` in active skills.

#### [I]-D5-002: 12 active invocable foundation skills omit standard boundary/navigation sections

- **Severity:** important
- **Files:**
  - `.harmony/capabilities/skills/foundations/python-api/scaffold-package/SKILL.md:18`
  - `.harmony/capabilities/skills/foundations/swift-macos-app/scaffold-package/SKILL.md:18`
- **Description:** Invocable foundation child skills generally lack explicit `When to Use`, `Boundaries`/`When NOT to Use`, and `When to Escalate` sections.
- **Evidence:** Affected set: all 6 python child skills + all 6 swift child skills.
- **Remediation:** Add these sections, or formally classify these as non-invocable/reference-only with corresponding registry/manifest changes.

#### [M]-D5-003: Reference token budgets exceeded in `rules.md` files

- **Severity:** minor
- **Files:**
  - `.harmony/capabilities/skills/foundations/react/composition-patterns/references/rules.md:1`
  - `.harmony/capabilities/skills/foundations/react/best-practices/references/rules.md:1`
  - `.harmony/capabilities/skills/foundations/react-native/best-practices/references/rules.md:1`
  - `.harmony/capabilities/skills/foundations/postgres/best-practices/references/rules.md:1`
- **Description:** Default per-reference budget (2000 tokens) is exceeded by 4 rule files (including two >11k tokens).
- **Evidence:** Estimated tokens: ~2057, ~12858, ~11241, ~2011.
- **Remediation:** Split oversized rule corpora or provide compressed summaries for activation-time loading.

### D6: Skill Content Quality

#### [F]-D6-001: High trigger overlap density across skill catalog

- **Severity:** informational
- **Files:**
  - `.harmony/capabilities/skills/manifest.yml`
- **Description:** Many trigger pairs share broad language, especially among foundation families.
- **Evidence:** Strict validator reports numerous overlaps (e.g., repeated “setup swift”, “foundation workflow”).
- **Remediation:** Narrow trigger phrases for high-collision families and prefer domain qualifiers.

### D7: Operational Infrastructure

#### [C]-D7-001: `setup-harness-links.sh` is effectively non-functional after grouped path migration

- **Severity:** critical
- **Files:**
  - `.harmony/capabilities/skills/_scripts/setup-harness-links.sh:13`
  - `.harmony/capabilities/skills/_scripts/setup-harness-links.sh:16`
  - `.harmony/capabilities/skills/_scripts/setup-harness-links.sh:39`
  - `.harmony/capabilities/skills/_scripts/setup-harness-links.sh:58`
  - `.harmony/capabilities/skills/_scripts/setup-harness-links.sh:97`
- **Description:** Script computes repo root incorrectly and assumes flat skill directories.
- **Evidence:** Running script reports skills path as `.../.harmony/.harmony/capabilities/skills` and discovers none; single-skill mode fails for `create-skill`.
- **Remediation:** Resolve repo root from manifest location, discover skills from manifest `path`, and emit grouped targets.

#### [I]-D7-002: `generate-reference-headers.sh` fails for grouped skill IDs

- **Severity:** important
- **Files:**
  - `.harmony/capabilities/skills/_scripts/generate-reference-headers.sh:191`
  - `.harmony/capabilities/skills/_scripts/generate-reference-headers.sh:205`
  - `.harmony/capabilities/skills/_scripts/generate-reference-headers.sh:250`
- **Description:** Script constructs skill directory as `$SKILLS_DIR/$skill_id`, which fails for grouped paths.
- **Evidence:** Execution halts on first manifest skill: `Skill directory not found: .../skills/synthesize-research`.
- **Remediation:** Resolve skill directory from manifest `path` rather than `id`.

#### [I]-D7-003: Log infrastructure metadata is stale/incomplete

- **Severity:** important
- **Files:**
  - `.harmony/capabilities/skills/_state/logs/FORMAT.md:20`
  - `.harmony/capabilities/skills/_state/logs/FORMAT.md:183`
  - `.harmony/capabilities/skills/_state/logs/index.yml:10`
  - `.harmony/capabilities/skills/_state/logs/index.yml:13`
- **Description:** Log format doc still points to pre-`_state` paths; top-level index is empty despite existing logs; several log directories have no `index.yml`.
- **Evidence:** Two `audit-migration` logs exist while `recent_runs` is empty and total remains 0.
- **Remediation:** Update FORMAT.md paths to `_state/logs/...`, rebuild top index from per-skill logs, add missing per-skill indices (`refactor`, `refine-prompt`, `synthesize-research`).

### D8: Cross-System Integration

#### [C]-D8-001: Host adapter skill symlinks are broken

- **Severity:** critical
- **Files:**
  - `.claude/skills/audit-migration`
  - `.claude/skills/create-skill`
  - `.cursor/skills/audit-migration`
  - `.cursor/skills/create-skill`
  - `.codex/skills/audit-migration`
  - `.codex/skills/create-skill`
- **Description:** Existing symlinks point to non-existent flat-path targets.
- **Evidence:** All current links under `.claude/skills`, `.cursor/skills`, and `.codex/skills` resolve as broken.
- **Remediation:** After fixing `setup-harness-links.sh`, regenerate links and prune stale legacy links.

#### [I]-D8-002: Deprecated `create-skill(x)` workflow still references old skill topology and `behaviors.md`

- **Severity:** important
- **Files:**
  - `.harmony/orchestration/workflows/meta/create-skill(x)/00-overview.md:68`
  - `.harmony/orchestration/workflows/meta/create-skill(x)/00-overview.md:82`
  - `.harmony/orchestration/workflows/meta/create-skill(x)/02-copy-template.md:21`
  - `.harmony/orchestration/workflows/meta/create-skill(x)/02-copy-template.md:32`
  - `.harmony/orchestration/workflows/meta/create-skill(x)/03-initialize-skill.md:51`
  - `.harmony/orchestration/workflows/meta/create-skill(x)/06-report-success.md:27`
- **Description:** Deprecated workflow still teaches flat `skills/<skill-name>/` paths and `references/behaviors.md`.
- **Evidence:** Multiple step files use old file names and non-grouped symlink targets.
- **Remediation:** Archive/remove this deprecated workflow or update all references to grouped paths + `phases.md`.

#### [I]-D8-003: Cognition artifacts still encode deprecated schema/path vocabulary

- **Severity:** important
- **Files:**
  - `.harmony/cognition/analyses/workflows-vs-skills-analysis.md:190`
  - `.harmony/cognition/analyses/workflows-vs-skills-analysis.md:558`
  - `.harmony/cognition/context/decisions.md:53`
  - `.harmony/cognition/decisions/001-harmony-shared-foundation.md:59`
- **Description:** Several cognition docs still reference deprecated constructs (`skill_mappings`, `behaviors.md`, `skills/logs/`).
- **Evidence:** Direct string matches in active cognition sources.
- **Remediation:** Either mark these as historical snapshots or refresh terminology to current schema/path model.

## Prior Remediation Verification (A1-A13)

- A1: ✓ resolved
- A2: ✓ resolved
- A3: ~ partially resolved (grouped path fixed, placeholder style drift remains in `create-skill` prose)
- A4: ✓ resolved
- A5: ✓ resolved
- A6: ✓ resolved
- A7: ✓ resolved
- A8: ✓ resolved
- A9: ✓ resolved
- A10: ✓ resolved
- A11: ✓ resolved
- A12: ~ partially resolved (architecture docs migrated; stale `behaviors.md` remains in deprecated workflow/cognition artifacts)
- A13: ~ partially resolved (main docs grouped; stale flat examples remain in deprecated workflow/cognition artifacts)

## Summary Table

| Dimension | Critical | Important | Minor | Informational |
|-----------|----------|-----------|-------|---------------|
| D1 Schema | 0 | 2 | 0 | 0 |
| D2 Migration | 0 | 0 | 0 | 0 |
| D3 Validator | 0 | 1 | 0 | 0 |
| D4 Docs Drift | 0 | 0 | 1 | 0 |
| D5 Spec Compliance | 1 | 1 | 1 | 0 |
| D6 Content Quality | 0 | 0 | 0 | 1 |
| D7 Operational Infra | 1 | 2 | 0 | 0 |
| D8 Cross-System | 1 | 2 | 0 | 0 |
| **Total** | **3** | **8** | **2** | **1** |

## Remediation Plan

### Priority 1 (Critical)

1. Fix `.harmony/capabilities/skills/_scripts/setup-harness-links.sh` for correct root + manifest-path discovery.
2. Regenerate `.claude/skills`, `.cursor/skills`, `.codex/skills` symlinks and remove broken legacy links.
3. Eliminate bare `Write` from active skills or codify/contain the exception with explicit scoped policy and validator enforcement.

### Priority 2 (Important)

1. Fix `.harmony/capabilities/skills/_scripts/generate-reference-headers.sh` grouped-path resolution.
2. Update `_state` log docs and indexes (`FORMAT.md`, top index, missing per-skill indexes).
3. Resolve stale references in deprecated workflow and cognition docs (or mark/archive as historical snapshots).
4. Close validator coverage gaps for documented contracts (status/type/determinism/dependency cycle/trigger format/unscoped Write).
5. Align executor foundation skills’ declared capabilities with actual reference model.

### Priority 3 (Minor / Informational)

1. Replace archetype wording in active creation/design docs with skill-set/capability language.
2. Reduce oversized `rules.md` payloads for activation efficiency.
3. Reduce high-overlap trigger phrases for better routing precision.

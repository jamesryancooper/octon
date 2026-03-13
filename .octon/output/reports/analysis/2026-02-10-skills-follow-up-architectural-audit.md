# Skills System Follow-Up Architectural Audit

Date: 2026-02-10  
Selected Context: archetype=library/SDK/tooling (primary), platform/infra (secondary); testing=§8.3; operations=§9.2; risk_tier=B; mode=full-documentation.

## Scope

- Prior baseline reviewed:
  - `.octon/output/reports/analysis/2026-02-10-skills-system-audit.md`
  - `.octon/output/reports/analysis/2026-02-10-audit-remediation-summary.md`
  - `.octon/output/reports/analysis/2026-02-10-deferred-items.md`
- Audited implementation:
  - `.octon/capabilities/skills/manifest.yml`
  - `.octon/capabilities/skills/capabilities.yml`
  - `.octon/capabilities/skills/registry.yml`
  - All `SKILL.md` files under `.octon/capabilities/skills/`
  - `.octon/capabilities/skills/scripts/validate-skills.sh`
  - `.octon/capabilities/skills/_template/`
- Audited docs:
  - All files under `docs/architecture/harness/skills/`
- External baseline:
  - [agentskills.io/specification](https://agentskills.io/specification)
  - [agentskills.io/what-are-skills](https://agentskills.io/what-are-skills)
  - [agentskills.io/integrate-skills](https://agentskills.io/integrate-skills)

Validator run (Phase 1 rerun):

- Command: `bash .octon/capabilities/skills/scripts/validate-skills.sh`
- Exit code: `0`
- Summary: `Warnings: 72` (captured in `/tmp/skills-validator-followup-2026-02-10.log`)

## 1) Executive Summary

- Core remediation succeeded for the original high-severity integrity breaks: manifest/registry ID sync, group membership sync, grouped path resolution, and capability-reference completeness are now passing.
- Manifest and registry are structurally in sync (`22` skills each; no missing IDs either direction).
- Capability-reference coverage for manifested skills is complete (`0` missing required references after capability resolution).
- A real post-remediation regression exists: `vercel-deploy` declares `external-output` in manifest but not in SKILL frontmatter.
- The original strict spec gap remains unresolved: 5 active nested skills still fail parent-directory name matching against agentskills baseline.
- Validation coverage has blind spots: path/placeholder checks still parse deprecated `skill_mappings`, so several checks pass vacuously.
- Validator policy and docs diverge: docs claim capability/skill-set validation and capability-reference enforcement, but script does not execute those checks.
- Documentation drift remains material in multiple files (capability count still “17”, stale `behaviors.md` references, flat path examples).
- Deferred-items triggers are still mostly unmet, but two are now actionable in lightweight form: parameter typing (`enum/list`) and secret-handling capability tagging.

## 2) Remediation Verification Matrix (Original Finding → Status)

| Original Finding (2026-02-10 audit) | Current Status | Evidence | Notes |
|---|---|---|---|
| Group membership mismatch between manifest and `skill_group_definitions` | Resolved | Automated set diff: `manifest_groups_missing_in_definitions=0`, `group_members_not_in_manifest=0` | Phase 2 remediation held.
| Missing capability-required references (29 missing) | Resolved | Automated capability-ref sweep: `manifest_capability_ref_missing=0` | Phase 4/7 remediation held.
| Validator failed on grouped paths (`SKILLS_DIR/$skill_id` assumptions) | Resolved | Validator now scans all manifested grouped skills successfully; no directory-not-found errors | Phase 3 remediation held.
| Comma-delimited `allowed-tools` drift | Resolved | No comma-delimited `allowed-tools` matches found (`rg` sweep), validator reports valid tools for all manifested skills | Phase 1 remediation held.
| Docs drift (old schema versions, old path examples, old key names) | Partially resolved | Major prior drifts fixed, but new/remaining drifts listed in Section 3 (`17` capabilities references, `behaviors.md`, flat paths) | Original class of issue remains partially open.
| Strict parent-directory naming mismatch on nested active skills | Unresolved | 5 manifested files still fail: `foundations/*/best-practices`, `react/composition-patterns`, `platforms/vercel/deploy` (`SKILL.md:2` in each) | Same unresolved spec-compatibility decision.
| Template/archive strict-spec noncompliance in global scans | Unresolved (intentional/non-routable) | `.octon/capabilities/skills/_template/SKILL.md:2`, `.octon/capabilities/skills/archive/v1-archetype-model/SKILL.md:2` | Should be policy-excluded from strict compliance gating.
| Weak summary/description alignment warnings | Resolved | Validator reports `Description/summary alignment OK` for all manifested skills | Prior lexical drift appears improved.
| Capability taxonomy lacked long-running/scheduled/external-output | Resolved for this subset | `.octon/capabilities/skills/capabilities.yml:109-132` | Additional deferred capabilities still pending by design.
| **New after remediation:** manifest ↔ SKILL capability mismatch (`vercel-deploy`) | **Regression** | `.octon/capabilities/skills/manifest.yml:327-328` vs `.octon/capabilities/skills/platforms/vercel/deploy/SKILL.md:14` | Not present in original findings; introduced/left during taxonomy update.

## 3) Cross-Artifact Alignment Issues (With Evidence)

| ID | Pair | Misalignment | File:Line Evidence | Impact |
|---|---|---|---|---|
| A1 | Manifest ↔ SKILL frontmatter | `vercel-deploy` capability mismatch (`external-output` vs `[]`) | `.octon/capabilities/skills/manifest.yml:327`, `.octon/capabilities/skills/platforms/vercel/deploy/SKILL.md:14` | Capability contract drift; validator currently misses this.
| A2 | SKILL docs ↔ Registry schema | `create-skill` describes `archetype` parameter, but registry defines `skill_sets` and `capabilities` | `.octon/capabilities/skills/meta/create-skill/SKILL.md:66`, `.octon/capabilities/skills/meta/create-skill/references/io-contract.md:24`, `.octon/capabilities/skills/registry.yml:635-644` | Misleads authors/operators about supported inputs.
| A3 | SKILL docs ↔ Grouped path architecture | `create-skill` still documents flat skill directory and symlink targets | `.octon/capabilities/skills/meta/create-skill/SKILL.md:73`, `.octon/capabilities/skills/meta/create-skill/references/io-contract.md:31-38`, `.octon/capabilities/skills/meta/create-skill/references/io-contract.md:56-58` | Inconsistent creation guidance under grouped layout.
| A4 | Active SKILL files ↔ agentskills directory-name rule | 5 manifested nested skills still fail parent-directory name match | `.octon/capabilities/skills/foundations/react/best-practices/SKILL.md:2`, `.octon/capabilities/skills/foundations/react/composition-patterns/SKILL.md:2`, `.octon/capabilities/skills/foundations/react-native/best-practices/SKILL.md:2`, `.octon/capabilities/skills/foundations/postgres/best-practices/SKILL.md:2`, `.octon/capabilities/skills/platforms/vercel/deploy/SKILL.md:2` | Ongoing spec compatibility gap.
| A5 | Template/archive scans ↔ strict compliance checks | Placeholder `name` values are invalid under strict name regex and directory match | `.octon/capabilities/skills/_template/SKILL.md:2`, `.octon/capabilities/skills/archive/v1-archetype-model/SKILL.md:2` | Requires explicit non-routable exclusion policy.
| A6 | Validator ↔ Registry schema ↔ docs | Validator parses deprecated `skill_mappings` for path and placeholder checks, but schema is `skills.<id>.io` | `.octon/capabilities/skills/scripts/validate-skills.sh:562-565`, `.octon/capabilities/skills/scripts/validate-skills.sh:680-684`, `.octon/capabilities/skills/scripts/validate-skills.sh:716-719`, `.octon/capabilities/skills/registry.yml:60`, `docs/architecture/harness/skills/discovery.md:206` | False negatives in path/placeholder enforcement.
| A7 | Validator messaging ↔ current schema | Validator guidance still tells users to edit `skill_mappings.$skill_id` | `.octon/capabilities/skills/scripts/validate-skills.sh:2052` | Operational confusion during remediation.
| A8 | Validator path policy ↔ architecture docs | Path-scope check auto-allows any `../../*` prefix before traversal checks | `.octon/capabilities/skills/scripts/validate-skills.sh:581-583`, `.octon/capabilities/skills/scripts/validate-skills.sh:587`, `docs/architecture/harness/skills/architecture.md:43-44`, `docs/architecture/harness/skills/discovery.md:391-402` | Scope enforcement is weaker than documented.
| A9 | Validator implementation ↔ validation docs | Docs describe capability/skill-set validity and capability-reference checks; script does not implement them as hard checks | `.octon/capabilities/skills/scripts/validate-skills.sh:41-42`, `.octon/capabilities/skills/scripts/validate-skills.sh:67-73`, `.octon/capabilities/skills/scripts/validate-skills.sh:1712-1772`, `docs/architecture/harness/skills/validation.md:7-132` | Policy says one thing; tooling enforces another.
| A10 | Docs ↔ capabilities schema | Multiple docs still state “17 capabilities” while schema has 20 | `docs/architecture/harness/skills/README.md:92`, `docs/architecture/harness/skills/architecture.md:348`, `docs/architecture/harness/skills/comparison.md:117`, `.octon/capabilities/skills/capabilities.yml:94-132` | Documentation staleness and onboarding risk.
| A11 | Docs capability mapping ↔ capabilities schema | Docs omit `long-running`, `scheduled`, `external-output` capability mappings | `docs/architecture/harness/skills/capabilities.md:67-97`, `.octon/capabilities/skills/capabilities.yml:109-132` | Incomplete authoring guidance.
| A12 | Docs reference-file model ↔ implementation | `behaviors.md` still documented as canonical in several places; implementation/template uses `phases.md` | `docs/architecture/harness/skills/specification.md:238`, `docs/architecture/harness/skills/specification.md:316`, `docs/architecture/harness/skills/creation.md:154-158`, `docs/architecture/harness/skills/creation.md:215`, `docs/architecture/harness/skills/skill-format.md:153`, `.octon/capabilities/skills/_template/SKILL.md:114` | Authoring drift and incorrect file expectations.
| A13 | Docs path examples ↔ grouped architecture | Flat-path examples persist in docs despite grouped manifest paths | `docs/architecture/harness/skills/declaration.md:13`, `docs/architecture/harness/skills/creation.md:151`, `.octon/capabilities/skills/manifest.yml:71`, `.octon/capabilities/skills/manifest.yml:94`, `.octon/capabilities/skills/manifest.yml:115` | New skill authors may scaffold wrong paths.

## 4) Spec Expansion Analysis (agentskills.io Baseline)

### 4.1 Octon Extensions Beyond Baseline Spec

| Extension | Assessment | Evidence |
|---|---|---|
| Three-file progressive disclosure (`manifest.yml` + `capabilities.yml` + `registry.yml`) in addition to SKILL files | Strong architecture for scale and routing efficiency; requires stricter drift controls | Baseline focuses on `SKILL.md` as core format and metadata (`agentskills.io/specification`, lines 84-106; `agentskills.io/what-are-skills`, lines 50-59). Octon adds layered schema in `.octon/capabilities/skills/manifest.yml:23`, `.octon/capabilities/skills/capabilities.yml:15`, `.octon/capabilities/skills/registry.yml:50`.
| Capability/skill-set taxonomy with capability-to-reference contracts | Valuable internal contract model; currently under-enforced in validator | `.octon/capabilities/skills/capabilities.yml:22-157`.
| Structured I/O contract metadata (`io.inputs/outputs`, `kind`, `format`, `determinism`) | Useful operability extension; richer than baseline | `.octon/capabilities/skills/registry.yml:31-37`, `.octon/capabilities/skills/registry.yml:73-108`.
| Harness-scoped operational artifacts (`configs/`, `resources/`, `runs/`, `logs/`) | Practical for continuity and governance | `.octon/capabilities/skills/registry.yml:39-46`, docs architecture model.

### 4.2 Octon Gaps Relative to Baseline Spec

| Gap | Status | Evidence |
|---|---|---|
| Parent-directory naming rule not satisfied for nested active skills | Open | Baseline requires name to match directory (`agentskills.io/specification`, line 93); mismatches listed in A4.
| Strict global scans include non-routable template/archive placeholders as if production skills | Open | Template/archive `name` placeholders at `.octon/capabilities/skills/_template/SKILL.md:2` and `.octon/capabilities/skills/archive/v1-archetype-model/SKILL.md:2`.
| Internal source-of-truth parity not guaranteed between manifest and SKILL frontmatter | Regression observed | `vercel-deploy` mismatch in A1.

### 4.3 Ambiguous-Spec Choices Octon Made

| Ambiguous Area | Octon Choice | Evaluation |
|---|---|---|
| Grouped directory organization vs strict parent-directory naming | Keeps globally unique skill IDs (`react-best-practices`) while nesting under domain folders (`foundations/react/best-practices/`) | Reasonable for taxonomy; must be codified as a deliberate variance with validator/docs support.
| Display-name acronym handling | Allows natural acronyms in manifest (`Audit UI`, `Resolve PR Comments`) while validator uses strict generated title-case heuristic | Acceptable if treated as warning-only and explicitly documented; currently noisy.
| Capability-driven reference contracts | Treats capability mappings as core architecture constraint beyond baseline “optional references” | Good internal standard; enforcement tooling must catch up.

## 5) Extensibility Ratings by Archetype

| Archetype | Rating | Why | Missing Schema Element (if not fully expressible) |
|---|---|---|---|
| Data transformation / ETL | Fully expressible | `executor`/`integrator`, `contract-driven`, `idempotent`, file/folder I/O are sufficient for current file-oriented ETL patterns | — |
| Security scanning / secret-handling | Expressible with workarounds | Safety boundaries and external dependency patterns exist | First-class `secret` parameter type and explicit `secret-handling` capability |
| Monitoring / alerting / scheduled | Expressible with workarounds | `scheduled` capability now exists | First-class schedule expression fields and alert/notification output contracts |
| Multi-modal (image/audio) processing | Expressible with workarounds | `file`/`folder` parameters can carry media assets | Modality-typed capability vocabulary and media-specific I/O typing |
| Long-running async (hours/days) | Expressible with workarounds | `long-running`, `stateful`, `resumable`, and `runs/` continuity exist | Async lifecycle/job-handle contract fields |
| Conversational / multi-turn dialogue | Expressible with workarounds | `human-collaborative` + checkpoints can model turn checkpoints | Explicit dialogue/session contract schema |
| Test generation / mutation testing | Fully expressible | Existing capability model covers execution, validation, and domain specialization | — |
| Communication / notification routing | Expressible with workarounds | External integration can be represented via tools and docs | First-class non-file output kinds (`api`/`stream`) and notifier semantics |

## 6) Deferred Items Triage

| Deferred Item | Recommendation | Evidence from Current Catalog | Justification |
|---|---|---|---|
| 1. Parameter types expansion (`number`, `enum`, `list`, `object`, `secret`) | **PARTIALLY ADDRESS** | Multiple parameters are constrained enums/lists encoded as `text`: `environment` (`registry.yml:527-531`), `severity_threshold` (`registry.yml:237-241`), `format` (`registry.yml:839-843`), CSV lists (`registry.yml:177-191`, `registry.yml:635-644`) | Add `enum` + `list` now (high value, low complexity). Keep `number/object/secret` deferred until concrete use requires enforcement. |
| 2. I/O kinds expansion (`api`, `database`, `stream`) | **KEEP DEFERRED** | Current catalog outputs are still file/directory artifacts (`registry.yml:31-34`; examples at `registry.yml:765-770`, `registry.yml:850-855`) | No current skill is blocked by missing non-file kinds; `external-output` capability covers semantics for now. |
| 3. Trigger pattern engine (regex/intent) | **KEEP DEFERRED** | Catalog size is 22 manifested skills; validator shows overlap notes (`32`) but not hard routing failures | Trigger overlap is present but still manageable; avoid adding routing complexity before concrete misrouting evidence. |
| 4. Dependency model enhancements | **KEEP DEFERRED** | `depends_on` is empty for all 22 skills (automated sweep) | Optional/versioned dependency semantics add complexity without current graph pressure. |
| 5. New skill sets (`observer`, `notifier`, `generator`) | **KEEP DEFERRED** | Current usage is concentrated in existing sets (executor/specialist/guardian) | No repeated production pattern currently forces new bundles. |
| 6. New capabilities (`adaptive`, `feedback-aware`, `multimodal-*`, `streaming-output`, `secret-handling`, `security-scanning`) | **PARTIALLY ADDRESS** | Deployer/status skills already encode secret boundaries (`platforms/vercel/deploy/SKILL.md:69-71`, `platforms/deploy-status/SKILL.md:69`) | Add `secret-handling` now as a lightweight explicit contract; keep adaptive/multimodal/streaming/security-scanning deferred until a concrete skill demands them. |

## 7) Validator Gap Analysis

### 7.1 Rules Currently Enforced

- Existence and linkage checks: skill directory, `SKILL.md`, manifest membership, registry membership.
- `allowed-tools` presence/format and mapping checks.
- Manifest/registry ID sync checks.
- Token/line budget checks across SKILL and key reference files.
- Trigger overlap reporting.
- Reference-content heuristic checks (`io-contract.md` parameter mentions, examples command mentions).

### 7.2 Documented Rules Not Enforced in Code

- Unknown capability/skill-set rejection and hard validation (`docs/architecture/harness/skills/validation.md:7-64`, `docs/architecture/harness/skills/validation.md:121-123`).
- Capability-to-reference and reference-to-capability matching as explicit validation outcomes (`docs/architecture/harness/skills/validation.md:66-104`, `docs/architecture/harness/skills/validation.md:129-130`).
- Alignment-first extension gate as an enforceable blocking rule (`docs/architecture/harness/skills/validation.md:106-126`).

### 7.3 What It Should Enforce (Neither Docs Nor Code Fully Cover)

- Manifest ↔ SKILL frontmatter parity for `skill_sets` and `capabilities` (would have caught A1).
- Validator parser/schema contract tests (to prevent stale `skill_mappings` key paths).
- Documentation synchronization lint (capability count, canonical reference filenames, grouped path examples).
- `create-skill` contract coherence checks across SKILL body, references, registry schema, and grouped layout.
- Explicit policy check for non-routable SKILLs (template/archive) in compliance scans.

### 7.4 False Positives / False Negatives

**False positives (or overly noisy warnings):**

- Display-name acronym warnings (`Audit UI`, `Resolve PR Comments`, etc.) from strict title-case heuristic despite docs allowing practical overrides (`docs/.../specification.md:222`; validator check at `.octon/capabilities/skills/scripts/validate-skills.sh:221-237`).
- `reference content may need review` in cases where examples intentionally demonstrate outcomes rather than command invocations.

**False negatives:**

- Capability parity drift not detected (`vercel-deploy` mismatch in A1).
- Placeholder/path-scope checks effectively no-op against current schema (`skill_mappings` parser drift in A6).
- Path traversal acceptance is too permissive due early `../../*` allow (`.octon/capabilities/skills/scripts/validate-skills.sh:581-583`).
- Advertised capability/skill-set validation checks (26/27) are declared but not executed as hard validation.

## 8) Prioritized Action Items

### Critical

1. Fix validator schema parsing from `skill_mappings` to `skills.<id>.io` for output-path and placeholder checks, and update associated messages (`validate-skills.sh`).
2. Add hard validation for manifest ↔ SKILL frontmatter capability/skill-set parity; resolve `vercel-deploy` mismatch immediately.
3. Reconcile `create-skill` contracts (parameters, grouped output paths, reference filenames) across SKILL body, `references/io-contract.md`, and `registry.yml`.
4. Decide and codify policy for grouped nested skills vs strict parent-directory naming (either conform physically or document/validate explicit exception).

### Important

1. Update docs to reflect 20 capabilities and include mappings for `long-running`, `scheduled`, `external-output`.
2. Remove stale `behaviors.md` canon references; standardize on `phases.md` where intended.
3. Normalize path examples to grouped layout consistently (`<group>/<skill-id>/...`) where operationally applicable.

### Nice-to-Have

1. Implement `enum` and `list` parameter types (deferred item partial now), with validator support.
2. Introduce `secret-handling` capability and mapping for existing deployment/status skills.
3. Add a docs/schema drift CI check to fail fast on capability count/file-name/key-name divergence.

---

## External Baseline References

- [agentskills.io/specification](https://agentskills.io/specification) — SKILL.md structure and naming constraints (notably lines 84-95 and 91-93 in current page rendering).
- [agentskills.io/what-are-skills](https://agentskills.io/what-are-skills) — definition of skills as SKILL.md-centered reusable capability units (lines 50-59 in current page rendering).
- [agentskills.io/integrate-skills](https://agentskills.io/integrate-skills) — integration lifecycle centered on SKILL loading and progressive disclosure (lines 59-84 in current page rendering).

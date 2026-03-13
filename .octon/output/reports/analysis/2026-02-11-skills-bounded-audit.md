# Skills Subsystem Bounded Audit

Date: 2026-02-11
Timestamp (UTC): 2026-02-11T11:30:59Z

Selected Context: archetype=library/SDK/tooling (primary), platform/infra (secondary); testing=§8.3; operations=§9.2; risk_tier=B; mode=full-documentation.

## Scope and Bounds

In scope:
- `.octon/capabilities/skills/**`
- `docs/architecture/harness/skills/**`
- `.octon/orchestration/workflows/meta/create-skill(x)/**`

Out of scope:
- Runtime skill execution correctness
- External URL health checks
- Historical report integrity

## Baseline Inventory

- Manifest skill IDs: 35
- Registry skill keys: 35
- On-disk non-template `SKILL.md`: 35
- Skills architecture docs: 18

## Check Results

| Check | Result | Notes |
|---|---|---|
| Registry/Manifest drift | PASS | No ID/key drift; no required-field drift in manifest or registry |
| Phantom skills | PASS | No manifest/registry orphans; all manifest paths resolve to `SKILL.md` |
| Stale cross-references | FAIL | Broken internal links and stale scaffold references found |
| Doc-to-source misalignment | FAIL | Naming policy contradiction across docs |
| Broken internal links | FAIL | 16 broken local links across 6 files |
| Schema violations | PASS | No missing/unknown fields; enum/type checks clean |
| Trigger/invocation gaps | PARTIAL | No exact duplicates and no invocable skills missing triggers; high overlap density |
| Template drift | FAIL | `create-skill` phase references old flat paths and `behaviors.md` |
| Log/state coherence | PARTIAL | `_state` topology coherent; file naming convention in docs does not match observed logs |

## Findings

### F-001 (HIGH): Broken internal links across core skills/docs

Evidence:
- `.octon/capabilities/skills/README.md:5`
- `.octon/capabilities/skills/README.md:74`
- `.octon/capabilities/skills/README.md:107`
- `.octon/capabilities/skills/README.md:240`
- `.octon/capabilities/skills/README.md:455`
- `.octon/capabilities/skills/_state/logs/FORMAT.md:335`
- `.octon/capabilities/skills/_state/logs/FORMAT.md:336`
- `.octon/capabilities/skills/_state/logs/FORMAT.md:337`
- `.octon/capabilities/skills/synthesis/refine-prompt/references/errors.md:206`
- `.octon/capabilities/skills/synthesis/synthesize-research/references/errors.md:251`
- `docs/architecture/harness/skills/reference-artifacts.md:374`
- `docs/architecture/harness/skills/skill-format.md:133`
- `docs/architecture/harness/skills/skill-format.md:134`
- `docs/architecture/harness/skills/skill-format.md:135`
- `docs/architecture/harness/skills/skill-format.md:136`
- `docs/architecture/harness/skills/skill-format.md:137`

Impact:
- Readers and agents hit 404-style local links when navigating architecture, safety, and format guidance.

Recommendation:
- Normalize all relative path depths from each source file.
- Replace `skill-format.md` reference links with either concrete doc links under `docs/architecture/harness/skills/` or mark them as non-clickable examples in code fences.

### F-002 (HIGH): `create-skill` scaffold guidance drifted from live subsystem contracts

Evidence:
- `.octon/capabilities/skills/meta/create-skill/references/phases.md:13`
- `.octon/capabilities/skills/meta/create-skill/references/phases.md:130`
- `.octon/capabilities/skills/meta/create-skill/references/phases.md:141`
- `.octon/capabilities/skills/meta/create-skill/references/phases.md:172`
- `.octon/capabilities/skills/meta/create-skill/references/phases.md:236`
- `.octon/capabilities/skills/meta/create-skill/references/phases.md:310`
- `.octon/capabilities/skills/meta/create-skill/references/phases.md:338`
- `.octon/capabilities/skills/meta/create-skill/references/phases.md:393`
- `.octon/capabilities/skills/meta/create-skill/references/phases.md:249`
- `.octon/capabilities/skills/_template/references/checkpoints.md:238`
- `.octon/orchestration/workflows/meta/create-skill(x)/02-copy-template.md:23`
- `.octon/orchestration/workflows/meta/create-skill(x)/03-initialize-skill.md:30`
- `.octon/orchestration/workflows/meta/create-skill(x)/06-report-success.md:29`

Observed drift:
- Uses flat skill path examples (`.octon/capabilities/skills/{{skill_name}}/`) instead of grouped paths.
- References obsolete `references/behaviors.md` (current model is capability-driven refs such as `phases.md`).
- Includes stale versioning guidance (`version: "0.1.0"` in SKILL metadata context) that conflicts with current source-of-truth versioning in `registry.yml`.

Impact:
- New scaffolded skills can be created with outdated structure and references, then require manual repair.

Recommendation:
- Align `create-skill` phases and related workflow docs with current grouped path + capability-ref model and remove `behaviors.md` references.

### F-003 (MEDIUM): Documentation contradiction on skill naming/parent-directory rule

Evidence:
- `docs/architecture/harness/skills/skill-format.md:29`
- `docs/architecture/harness/skills/skill-format.md:63`
- `docs/architecture/harness/skills/specification.md:30`
- `docs/architecture/harness/skills/specification.md:34`

Observed contradiction:
- `skill-format.md` states name must match parent directory.
- `specification.md` states grouped directories are intentional and parent-directory mismatch is valid when ID alignment is preserved.

Impact:
- Reviewers and automation consumers can apply conflicting acceptance criteria.

Recommendation:
- Consolidate on the grouped-directory policy in `skill-format.md` and cross-link to `specification.md` naming policy.

### F-004 (MEDIUM): Trigger overlap density is high despite no exact duplicates

Evidence:
- Validator overlap notes count: 81 pair overlaps from `.octon/output/reports/.tmp/validate.normal.out`.
- Highest overlap concentration includes `python-api` (11 pair overlaps), `swift-macos-app` (9), `swift-scaffold-package` (9).

Also verified:
- Exact trigger duplicates: 0
- Invocable skills (`commands` present) missing triggers: 0

Impact:
- Discovery remains formally valid but may route ambiguously for broad prompts (e.g., generic “set up”, “foundation”, “check”, “review”).

Recommendation:
- Tighten trigger phrases for high-collision skills with domain qualifiers and intent verbs unique per skill family.

### F-005 (LOW): Log filename convention in `FORMAT.md` does not match observed run logs

Evidence:
- Specified pattern: `.octon/capabilities/skills/_state/logs/{{skill_id}}/{{timestamp}}-{{skill_id}}.md` at `.octon/capabilities/skills/_state/logs/FORMAT.md:20`
- Specified timestamp format: `.octon/capabilities/skills/_state/logs/FORMAT.md:23`
- Observed files:
  - `.octon/capabilities/skills/_state/logs/audit-migration/2026-02-08-workspace-to-harness.md`
  - `.octon/capabilities/skills/_state/logs/audit-migration/2026-02-08-workspace-to-harness-rerun.md`

Impact:
- Low current risk, but strict downstream parsers expecting documented filename conventions may miss logs.

Recommendation:
- Either relax `FORMAT.md` to define filename as opaque `run_id`, or enforce documented timestamp naming in writers.

## Non-Findings (Explicitly Clean)

- No manifest/registry ID drift.
- No phantom skills (entry without `SKILL.md` or unindexed skill directory).
- No manifest/registry schema-field violations in bounded checks.
- No invalid `skill_sets`, capabilities, status values, parameter types, or determinism enum values.

## Severity Summary

- High: 2
- Medium: 2
- Low: 1
- Total findings: 5

## Artifacts

- Machine-readable findings: `.octon/output/reports/analysis/2026-02-11-skills-bounded-audit-findings.yml`
- Raw intermediate data: `.octon/output/reports/.tmp/`

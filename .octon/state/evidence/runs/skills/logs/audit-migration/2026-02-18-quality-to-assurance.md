# Audit Migration Run Log

**Run ID:** 2026-02-18-quality-to-assurance  
**Started:** 2026-02-18  
**Completed:** 2026-02-18  
**Migration:** quality-to-assurance legitimacy-layer transition  
**Status:** completed

## Configuration

- Mappings: 8
- Scope: active source (policy/historical exclusions applied)
- Exclusions:
  - `.octon/inputs/exploratory/ideation/**`
  - `.archive/**`
  - `.octon/state/evidence/validation/**`
  - `.octon/inputs/exploratory/plans/**`
  - `.octon/runtime/crates/target/**`
  - `.octon/runtime/_ops/state/**`
  - `.octon/framework/capabilities/services/_ops/state/**`
  - `.git/**`

## Layer Results

| Layer | Coverage | Findings |
|---|---:|---:|
| Grep Sweep | 1405 active files | 0 migration findings |
| Cross-Reference Audit | 173 key files, 359 path candidates | 9 non-migration broken refs |
| Semantic Read-Through | core assurance/runtime/contracts | 0 migration findings |
| Self-Challenge | mapping coverage + counter-example search | no new migration findings |

## Metrics

- active_files_scanned: 1405
- key_files_scanned: 173
- backtick_tokens_extracted: 2776
- backtick_path_candidates: 359
- backtick_ok: 350
- backtick_missing: 9
- mdlink_paths_checked: 24
- mdlink_missing: 0

## Output

- report: `.octon/state/evidence/validation/2026-02-18-migration-audit.md`

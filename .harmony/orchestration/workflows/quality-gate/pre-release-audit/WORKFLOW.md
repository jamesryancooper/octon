---
name: pre-release-audit
description: >
  Chain migration integrity, subsystem health, cross-subsystem coherence, and
  freshness/supersession audits into a comprehensive pre-release quality gate.
  Produces a consolidated readiness report with a go/no-go recommendation.
steps:
  - id: configure
    file: 01-configure.md
    description: Parse parameters and determine which audit skills to run.
  - id: migration-audit
    file: 02-migration-audit.md
    description: Run audit-migration if migration manifest provided.
  - id: health-audit
    file: 03-health-audit.md
    description: Run audit-subsystem-health against target subsystem.
  - id: cross-subsystem-audit
    file: 04-cross-subsystem-audit.md
    description: Run audit-cross-subsystem-coherence unless explicitly disabled.
  - id: freshness-audit
    file: 05-freshness-audit.md
    description: Run audit-freshness-and-supersession unless explicitly disabled.
  - id: merge
    file: 06-merge.md
    description: Merge findings from completed audit stages.
  - id: report
    file: 07-report.md
    description: Generate consolidated pre-release readiness report.
  - id: verify
    file: 08-verify.md
    description: Validate workflow executed successfully.
# --- Harmony extensions ---
access: human
version: "1.1.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
---

# Pre-Release Audit: Overview

Chain migration and coherence audits into a comprehensive pre-release quality gate.

## Usage

```text
/pre-release-audit subsystem=".harmony/capabilities/skills" docs=".harmony/cognition/_meta/architecture/skills"
```

With migration manifest:

```text
/pre-release-audit subsystem=".harmony/capabilities/skills" manifest=".harmony/migrations/restructure.yml" docs=".harmony/cognition/_meta/architecture/skills"
```

With explicit stage controls:

```text
/pre-release-audit subsystem=".harmony/capabilities/skills" run_cross_subsystem="true" run_freshness="true" max_age_days="30"
```

## Target

A harness subsystem and related architecture artifacts, audited for migration integrity, subsystem coherence, cross-subsystem contract alignment, and artifact freshness/supersession integrity.

## Prerequisites

- `audit-subsystem-health` skill is active
- `audit-migration` skill is active (required only if `manifest` is provided)
- `audit-cross-subsystem-coherence` skill is active (required when `run_cross_subsystem=true`)
- `audit-freshness-and-supersession` skill is active (required when `run_freshness=true`)
- Target subsystem directory exists
- Alignment validator exists: `.harmony/assurance/_ops/scripts/validate-audit-subsystem-health-alignment.sh`

## Failure Conditions

- Subsystem directory does not exist -> STOP, report error
- No planned audit stages remain after configuration -> STOP, nothing to audit
- All planned audit stages fail -> STOP, report aggregated failures
- One or more stages fail -> CONTINUE with remaining stages and include failures in recommendation

## Steps

1. [Configure](./01-configure.md) - Parse parameters and build execution plan
2. [Migration Audit](./02-migration-audit.md) - Run audit-migration if manifest provided
3. [Health Audit](./03-health-audit.md) - Run audit-subsystem-health
4. [Cross-Subsystem Audit](./04-cross-subsystem-audit.md) - Run audit-cross-subsystem-coherence unless disabled
5. [Freshness Audit](./05-freshness-audit.md) - Run audit-freshness-and-supersession unless disabled
6. [Merge](./06-merge.md) - Merge findings across completed stages
7. [Report](./07-report.md) - Generate consolidated pre-release report
8. [Verify](./08-verify.md) - Validate completion gate

## Verification Gate

Pre-Release Audit is NOT complete until:

- [ ] All planned stages executed or explicitly skipped by configuration
- [ ] Consolidated report exists at `.harmony/output/reports/YYYY-MM-DD-pre-release-audit.md`
- [ ] Go/no-go recommendation is stated with rationale
- [ ] Findings from completed stages are merged and deduplicated
- [ ] Coverage proof accounts for completed audit dimensions
- [ ] Verification step passes

## Version History

| Version | Date | Changes |
| ------- | ---- | ------- |
| 1.1.0 | 2026-02-15 | Added cross-subsystem and freshness audit stages with stage controls |
| 1.0.1 | 2026-02-15 | Added mandatory alignment validator gate for architecture drift |
| 1.0.0 | 2026-02-10 | Initial version |

## References

- **Migration Skill:** `.harmony/capabilities/skills/quality-gate/audit-migration/SKILL.md`
- **Health Skill:** `.harmony/capabilities/skills/quality-gate/audit-subsystem-health/SKILL.md`
- **Cross-Subsystem Skill:** `.harmony/capabilities/skills/quality-gate/audit-cross-subsystem-coherence/SKILL.md`
- **Freshness Skill:** `.harmony/capabilities/skills/quality-gate/audit-freshness-and-supersession/SKILL.md`
- **Orchestrate Audit:** `.harmony/orchestration/workflows/quality-gate/orchestrate-audit/`

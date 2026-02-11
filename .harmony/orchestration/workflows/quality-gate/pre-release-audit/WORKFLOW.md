---
name: pre-release-audit
description: >
  Chain audit-migration and audit-subsystem-health into a comprehensive
  pre-release gate. Runs migration reference integrity checks first (if a
  migration manifest is provided), then subsystem coherence checks, merges
  findings from both skills, and produces a consolidated pre-release readiness
  report with a go/no-go recommendation.
steps:
  - id: configure
    file: 01-configure.md
    description: Parse parameters, determine which audit skills to run.
  - id: migration-audit
    file: 02-migration-audit.md
    description: Run audit-migration if migration manifest provided.
  - id: health-audit
    file: 03-health-audit.md
    description: Run audit-subsystem-health against target subsystem.
  - id: merge
    file: 04-merge.md
    description: Combine findings from both audits into unified view.
  - id: report
    file: 05-report.md
    description: Generate consolidated pre-release readiness report.
  - id: verify
    file: 06-verify.md
    description: Validate workflow executed successfully.
# --- Harmony extensions ---
access: human
version: "1.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
---

# Pre-Release Audit: Overview

Chain `audit-migration` and `audit-subsystem-health` into a comprehensive pre-release quality gate.

## Usage

```text
/pre-release-audit subsystem=".harmony/capabilities/skills" docs="docs/architecture/harness/skills"
```

With a migration manifest (runs both audits):

```text
/pre-release-audit subsystem=".harmony/capabilities/skills" manifest=".harmony/migrations/restructure.yml" docs="docs/architecture/harness/skills"
```

**Examples:**

```text
# Health-only audit (no migration)
/pre-release-audit subsystem=".harmony/capabilities/skills"

# Full audit with migration + health + docs
/pre-release-audit subsystem=".harmony/capabilities/skills" manifest="..." docs="docs/architecture/harness/skills"

# With severity filter
/pre-release-audit subsystem=".harmony/capabilities/skills" severity_threshold="high"
```

## Target

A harness subsystem and optionally its companion documentation, audited for both post-migration integrity and ongoing coherence.

## Prerequisites

- `audit-subsystem-health` skill is active in the skill registry
- `audit-migration` skill is active (required only if `manifest` parameter is provided)
- Target subsystem directory exists

## Failure Conditions

- Subsystem directory does not exist -> STOP, report error
- Neither `manifest` nor `subsystem` provided -> STOP, nothing to audit
- Both audit skills fail -> STOP, report errors from both
- One audit skill fails -> CONTINUE with the other, note failure in report

## Steps

1. [Configure](./01-configure.md) - Parse parameters, determine which audit skills to run
2. [Migration Audit](./02-migration-audit.md) - Run audit-migration if manifest provided
3. [Health Audit](./03-health-audit.md) - Run audit-subsystem-health against target subsystem
4. [Merge](./04-merge.md) - Combine findings from both audits
5. [Report](./05-report.md) - Generate consolidated pre-release readiness report
6. [Verify](./06-verify.md) - Validate workflow executed successfully

## Verification Gate

Pre-Release Audit is NOT complete until:

- [ ] All applicable audit skills have run (at minimum, health audit)
- [ ] Consolidated report exists at `.harmony/output/reports/YYYY-MM-DD-pre-release-audit.md`
- [ ] Go/no-go recommendation is stated with rationale
- [ ] Findings from all skills are merged and deduplicated
- [ ] Coverage proof accounts for all checks across both audit skills
- [ ] Verification step passes

## Version History

| Version | Date | Changes |
| ------- | ---- | ------- |
| 1.0.0 | 2026-02-10 | Initial version |

## References

- **Health Skill:** `.harmony/capabilities/skills/quality-gate/audit-subsystem-health/SKILL.md`
- **Migration Skill:** `.harmony/capabilities/skills/quality-gate/audit-migration/SKILL.md`
- **Orchestrate Audit:** `.harmony/orchestration/workflows/quality-gate/orchestrate-audit/` (parallel partition variant)
- **Workflow template:** `.harmony/orchestration/workflows/_template/`

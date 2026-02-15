---
name: configure
title: "Configure Pre-Release Audit"
description: "Parse parameters and determine which audit skills to run."
---

# Step 1: Configure Pre-Release Audit

## Input

- User-provided parameters: `subsystem`, `manifest` (optional), `docs` (optional), `severity_threshold` (optional), `run_cross_subsystem` (optional), `run_freshness` (optional), `max_age_days` (optional)

## Purpose

Validate parameters and build a deterministic execution plan for migration, subsystem-health, cross-subsystem coherence, and freshness/supersession audits.

## Actions

1. **Parse parameters:**

   | Parameter | Required | Default | Purpose |
   |-----------|----------|---------|---------|
   | `subsystem` | Yes | — | Root directory for subsystem health audit |
   | `manifest` | No | — | Migration manifest for migration audit |
   | `docs` | No | — | Companion docs for health/cross-subsystem alignment checks |
   | `severity_threshold` | No | `all` | Minimum severity to report |
   | `run_cross_subsystem` | No | `true` | Run cross-subsystem coherence audit |
   | `run_freshness` | No | `true` | Run freshness/supersession audit |
   | `max_age_days` | No | `30` | Freshness threshold for stale artifact classification |

2. **Verify subsystem directory exists:**

   If not found: STOP with `SUBSYSTEM_NOT_FOUND`

3. **Determine execution plan:**

   | Condition | Migration | Health | Cross-Subsystem | Freshness |
   |-----------|-----------|--------|-----------------|-----------|
   | `manifest` provided | Run | Run | Run unless disabled | Run unless disabled |
   | `manifest` omitted | Skip | Run | Run unless disabled | Run unless disabled |

4. **Verify required skill availability:**

   - `audit-subsystem-health` must be `active`
   - If `manifest` provided, `audit-migration` must be `active`
   - If `run_cross_subsystem=true`, `audit-cross-subsystem-coherence` must be `active`
   - If `run_freshness=true`, `audit-freshness-and-supersession` must be `active`
   - Missing required skill -> STOP with `SKILL_NOT_AVAILABLE`

5. **Record execution plan:**

   ```markdown
   ## Execution Plan

   - Migration audit: {{run|skip}} {{reason}}
   - Health audit: run
   - Cross-subsystem audit: {{run|skip}} {{reason}}
   - Freshness audit: {{run|skip}} {{reason}}
   - Companion docs: {{path|not provided}}
   - Severity threshold: {{threshold}}
   - Freshness max age (days): {{max_age_days}}
   ```

## Idempotency

**Check:** Configuration checkpoint exists at `checkpoints/pre-release-audit/01-configure.complete`

**If Already Complete:**

- Reuse configuration if inputs are unchanged
- Re-run if parameters changed

**Marker:** `checkpoints/pre-release-audit/01-configure.complete`

## Error Messages

- Missing subsystem: `SUBSYSTEM_NOT_FOUND: The directory '{{path}}' does not exist`
- Skill unavailable: `SKILL_NOT_AVAILABLE: {{skill-id}} is not active in the skill manifest`
- Invalid manifest path: `MANIFEST_NOT_FOUND: The migration manifest '{{path}}' does not exist`

## Output

- Validated execution plan and resolved run/skip decisions

## Proceed When

- [ ] Subsystem directory exists
- [ ] Required skills are active for planned stages
- [ ] Execution plan is recorded

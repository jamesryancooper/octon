---
name: configure
title: "Configure Pre-Release Audit"
description: "Parse parameters and determine which audit skills to run."
---

# Step 1: Configure Pre-Release Audit

## Input

- User-provided parameters: `subsystem`, `manifest` (optional), `docs` (optional), `severity_threshold` (optional)

## Purpose

Validate all parameters and determine the execution plan — which audit skills will run and with what parameters.

## Actions

1. **Parse parameters:**

   | Parameter | Required | Default | Purpose |
   |-----------|----------|---------|---------|
   | `subsystem` | Yes | — | Root directory for health audit |
   | `manifest` | No | — | Migration manifest for migration audit |
   | `docs` | No | — | Companion docs for doc-to-source alignment |
   | `severity_threshold` | No | `all` | Minimum severity to report |

2. **Verify subsystem directory exists:**

   If not found: STOP with `SUBSYSTEM_NOT_FOUND`

3. **Determine execution plan:**

   | Condition | Migration Audit | Health Audit |
   |-----------|----------------|--------------|
   | `manifest` provided | Run | Run |
   | `manifest` not provided | Skip | Run |

4. **Verify skill availability:**

   - Check `audit-subsystem-health` is `active` in manifest.yml
   - If `manifest` provided, check `audit-migration` is `active` in manifest.yml
   - If required skill is not active: STOP with `SKILL_NOT_AVAILABLE`

5. **Record execution plan:**

   ```markdown
   ## Execution Plan

   - Migration audit: {{run|skip}} {{reason}}
   - Health audit: run
   - Companion docs: {{path|not provided}}
   - Severity threshold: {{threshold}}
   ```

## Idempotency

**Check:** Configuration checkpoint exists at `checkpoints/pre-release-audit/01-configure.complete`

**If Already Complete:**

- Skip to step 2 (or step 3 if migration audit was skipped)
- Re-run if arguments have changed

**Marker:** `checkpoints/pre-release-audit/01-configure.complete`

## Error Messages

- Missing subsystem: "SUBSYSTEM_NOT_FOUND: The directory '{{path}}' does not exist"
- Skill unavailable: "SKILL_NOT_AVAILABLE: {{skill-id}} is not active in the skill manifest"
- Invalid manifest path: "MANIFEST_NOT_FOUND: The migration manifest '{{path}}' does not exist"

## Output

- Validated execution plan (which skills to run, with what parameters)
- Configuration summary for downstream steps

## Proceed When

- [ ] Subsystem directory verified to exist
- [ ] Required skills verified as active
- [ ] Execution plan recorded

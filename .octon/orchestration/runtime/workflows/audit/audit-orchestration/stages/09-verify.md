---
name: verify
title: Verify Completion
description: Validate bounded-audit contract and done-gate outcomes.
---

# Step 9: Verify Completion

## Purpose

**MANDATORY GATE:** confirm bounded-audit contract compliance.

## Verification Checklist

- [ ] Consolidated report exists
- [ ] Audit bundle exists under `.octon/output/reports/audits/`
- [ ] Bundle includes required files
- [ ] Coverage ledger has `unaccounted_files` value recorded
- [ ] Findings are deduplicated and all IDs are stable-format
- [ ] Findings include acceptance criteria
- [ ] Determinism receipt fields are present
- [ ] Done-gate expression is evaluated and recorded
- [ ] If `post_remediation=true`, K-run convergence is stable and empty at/above threshold

## Verification Outcome Rules

- Discovery mode (`post_remediation=false`): verification passes when bundle contract is valid, regardless of done-gate value.
- Post-remediation mode (`post_remediation=true`): verification fails unless done-gate is true.

## Workflow Complete When

- [ ] Verification checklist passes for selected mode
- [ ] Result and rationale documented

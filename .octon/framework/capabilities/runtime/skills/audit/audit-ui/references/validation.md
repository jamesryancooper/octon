---
title: Validation Reference
description: Acceptance criteria for complete audit-ui executions.
---

# Validation Reference

Acceptance criteria that define a complete, valid UI audit.

## Acceptance Criteria

A UI audit execution is valid when all conditions are met.

### Ruleset

- [ ] External ruleset was successfully fetched
- [ ] Ruleset was parsed into structured rules with identifiers and categories
- [ ] Rule count and category distribution are logged

### Scope

- [ ] All UI files matching `file_types` within `target` were discovered
- [ ] Scope size was checked against threshold (500 files)
- [ ] Coverage manifest was built listing scanned/excluded files

### Scanning

- [ ] Every file in scope was checked against applicable rules
- [ ] Each violation includes file path, line number, rule reference, severity, and description
- [ ] Clean files (no violations) were tracked separately

### Findings Contract

- [ ] Bundle-mode findings use stable IDs
- [ ] Every finding has acceptance criteria
- [ ] No duplicate IDs are present

### Convergence Contract

- [ ] Determinism receipt fields are recorded (commit/prompt/params/findings hash)
- [ ] Seed and fingerprint policy is recorded
- [ ] Done-gate expression fields are recorded

### Report and Logging

- [ ] Report includes executive summary and severity breakdown
- [ ] Coverage proof includes clean files and exclusions
- [ ] Execution log was written to `/.octon/state/evidence/runs/skills/audit-ui/{run_id}.md`
- [ ] Log index was updated at `/.octon/state/evidence/runs/skills/audit-ui/index.yml`

## Mode Rules

- Discovery mode (`post_remediation=false`): pass when bundle contract is valid and done-gate value is recorded.
- Post-remediation mode (`post_remediation=true`): pass only when convergence is stable and no open findings remain at or above threshold.

## Validation Failures

| Missing | Action |
| ------- | ------ |
| Ruleset fetch failed | Abort -- cannot audit without rules |
| No files in scope | Report immediately with empty-scope note |
| Scanning incomplete | Mark report partial and list unscanned files |
| Bundle contract missing fields | Fail verification and list missing fields |
| Log not written | Write log before declaring completion |

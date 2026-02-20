---
title: Validation Reference
description: Acceptance criteria for complete audit-ui executions.
---

# Validation Reference

Acceptance criteria that define a complete, valid UI audit.

## Acceptance Criteria

A UI audit execution is valid when ALL of these conditions are met:

### Ruleset

- [ ] External ruleset was successfully fetched
- [ ] Ruleset was parsed into structured rules with identifiers and categories
- [ ] Rule count and category distribution are logged

### Scope

- [ ] All UI files matching `file_types` within `target` were discovered
- [ ] Scope size was checked against threshold (500 files)
- [ ] Scope manifest was built listing all files to be scanned

### Scanning

- [ ] Every file in scope was read and checked against applicable rules
- [ ] Each violation includes file path, line number, rule reference, severity, and description
- [ ] Clean files (no violations) were tracked separately

### Report

- [ ] Report includes executive summary with file count, violation count by severity, and rule count
- [ ] Findings are organized by severity tier (CRITICAL, HIGH, MEDIUM, LOW)
- [ ] Each finding includes `file:line` format location
- [ ] Clean files are listed (coverage proof)
- [ ] Ruleset metadata is included (source URL, fetch timestamp, rule count)

### Logging

- [ ] Execution log was written to `_ops/state/logs/audit-ui/{run_id}.md`
- [ ] Log index was updated at `_ops/state/logs/audit-ui/index.yml`
- [ ] Top-level log index was updated at `_ops/state/logs/index.yml`

## Validation Failures

If any acceptance criterion is not met:

| Missing | Action |
|---------|--------|
| Ruleset fetch failed | Abort — cannot audit without rules |
| No files in scope | Report immediately with empty scope note |
| Scanning incomplete | Mark report as partial, list unscanned files |
| Report missing sections | Complete the report before logging |
| Log not written | Write log before declaring completion |

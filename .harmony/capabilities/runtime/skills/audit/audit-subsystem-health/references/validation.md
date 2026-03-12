---
title: Validation Reference
description: Acceptance criteria and verification for the audit-subsystem-health skill.
---

# Validation Reference

Acceptance criteria for a complete `audit-subsystem-health` execution.

## Acceptance Criteria

### Phase Completion

All mandatory phases execute to completion:

| Phase | Required | Completion Condition |
| ----- | -------- | -------------------- |
| Config Consistency | Yes | All manifest entries reconciled against registry and SKILL definitions |
| Schema Conformance | Yes (if schema available) | All entries validated against schema |
| Semantic Quality | Yes | Trigger/naming/state/doc alignment checks applied |
| Self-Challenge | Yes | Blind-spot and false-positive checks executed |

### Report Completeness

The output report must include:

- [ ] Executive summary with finding totals and layer breakdown
- [ ] Severity distribution table
- [ ] Findings grouped by layer
- [ ] Each finding has file path, evidence predicate, severity, and description
- [ ] Each finding has stable ID and acceptance criteria (orchestrated mode)
- [ ] Coverage proof for checked-clean entries and explicit exclusions
- [ ] Determinism and done-gate metadata

### Coverage Verification

| Check | Requirement |
| ----- | ----------- |
| All in-scope entries accounted | Every entry is scanned, sampled, or excluded with reason |
| Config reconciliation complete | All manifest/registry/definition triples evaluated |
| Schema fields validated | Every required field checked where schema is available |
| Semantic checks complete | Trigger and naming checks cover all target entries |
| Coverage ledger complete | `coverage.yml` contains `unaccounted_files` |

### Convergence and Done Gate

| Mode | Gate |
| ---- | ---- |
| Discovery (`post_remediation=false`) | Bundle contract valid, done-gate value recorded |
| Post-remediation (`post_remediation=true`) | `stable=true`, `union_blocking_findings=0`, `open_findings_at_or_above_threshold=0`, and `done=true` |

### Quality Gates

| Gate | Pass Condition |
| ---- | -------------- |
| No silent failures | Layer errors are reported with scope impact |
| No duplicate finding IDs | `findings.yml` IDs are unique |
| Acceptance criteria completeness | Every finding has `acceptance_criteria` |
| Actionable batches | Remediation groupings can be applied independently |

## Verification Checklist

After skill execution, verify:

1. Report exists at `.harmony/output/reports/analysis/YYYY-MM-DD-subsystem-health-audit.md`
2. Log exists at `_ops/state/logs/audit-subsystem-health/{{run_id}}.md`
3. In orchestrated mode, bundle exists with required files (`bundle.yml`, `findings.yml`, `coverage.yml`, `convergence.yml`, `evidence.md`, `commands.md`, `validation.md`, `inventory.md`)
4. `coverage.yml` records `unaccounted_files: 0` for pass state
5. `findings.yml` has stable IDs and acceptance criteria for each finding
6. `convergence.yml` records commit/prompt/params/findings hashes plus seed/fingerprint policy
7. If `post_remediation=true`, done gate evaluates true
8. No source files were modified (read-only guarantee)
9. Alignment validator is run when architecture surfaces change:
   `bash .harmony/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
10. If bootstrap/init behavior changed, the alignment references still reflect
    canonical `/.harmony/AGENTS.md`, canonical `/.harmony/OBJECTIVE.md`, repo-root
    ingress adapters (`AGENTS.md`, `CLAUDE.md`), and
    `.harmony/cognition/runtime/context/intent.contract.yml`
11. Contract governance validator is run when contract metadata or `_ops` boundaries change:
    `bash .harmony/assurance/runtime/_ops/scripts/validate-contract-governance.sh`
12. Harness version compatibility validator is run when portability/version contracts change:
    `bash .harmony/assurance/runtime/_ops/scripts/validate-harness-version-contract.sh`
13. SSOT precedence drift validator is run when runtime/governance/practices authority contracts change:
    `bash .harmony/assurance/runtime/_ops/scripts/validate-ssot-precedence-drift.sh`
14. Framing alignment validator is run when canonical framing contracts or language surfaces change:
    `bash .harmony/assurance/runtime/_ops/scripts/validate-framing-alignment.sh`

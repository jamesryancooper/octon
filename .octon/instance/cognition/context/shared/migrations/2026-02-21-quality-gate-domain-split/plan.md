---
title: Quality-Gate Domain Split Clean-Break Migration Plan
description: Clean-break migration plan to replace monolithic quality-gate directories with focused audit, remediation, and refactor domains for skills and workflows.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Quality-gate domain split clean-break
- Owner: `architect`
- Motivation: Remove overloaded `quality-gate` directory authority before scale increases migration cost; establish focused runtime domains for audit, remediation, and refactor.
- Scope:
  - `/.octon/framework/capabilities/runtime/skills/**`
  - `/.octon/framework/orchestration/runtime/workflows/**`
  - referenced manifests/registries/validators/docs/templates/catalog surfaces that encode `quality-gate/*` paths

## 2) What Is Being Removed (Explicit)

Legacy SSOT directories to remove in the same change set:

- `/.octon/framework/capabilities/runtime/skills/quality-gate/`
- `/.octon/framework/orchestration/runtime/workflows/quality-gate/`

Legacy taxonomy/group authority to remove:

- Skill manifest entries with `group: quality-gate`
- Skill group definition key `quality-gate` in `/.octon/framework/capabilities/runtime/skills/capabilities.yml`
- Workflow manifest entries with `group: quality-gate`
- Workflow group definition key `quality-gate` in `/.octon/framework/orchestration/runtime/workflows/manifest.yml`

Legacy path identifiers to remove from active docs/contracts/scripts:

- `path: quality-gate/...` in runtime manifests/ops catalogs
- hardcoded references to `runtime/skills/quality-gate/...`
- hardcoded references to `runtime/workflows/quality-gate/...`

## 3) What Is the New SSOT (Explicit)

New skills directory authorities:

- `/.octon/framework/capabilities/runtime/skills/audit/`
- `/.octon/framework/capabilities/runtime/skills/remediation/`
- `/.octon/framework/capabilities/runtime/skills/refactor/`

New workflows directory authorities:

- `/.octon/framework/orchestration/runtime/workflows/audit/`
- `/.octon/framework/orchestration/runtime/workflows/refactor/`

### Required path mapping (skills)

- `quality-gate/audit-migration` -> `audit/audit-migration`
- `quality-gate/audit-subsystem-health` -> `audit/audit-subsystem-health`
- `quality-gate/audit-cross-subsystem-coherence` -> `audit/audit-cross-subsystem-coherence`
- `quality-gate/audit-freshness-and-supersession` -> `audit/audit-freshness-and-supersession`
- `quality-gate/audit-documentation-standards` -> `audit/audit-documentation-standards`
- `quality-gate/audit-ui` -> `audit/audit-ui`
- `quality-gate/resolve-pr-comments` -> `remediation/resolve-pr-comments`
- `quality-gate/triage-ci-failure` -> `remediation/triage-ci-failure`
- `quality-gate/refactor` -> `refactor/refactor`

### Required path mapping (workflows)

- `quality-gate/orchestrate-audit` -> `audit/orchestrate-audit`
- `quality-gate/pre-release-audit` -> `audit/pre-release-audit`
- `quality-gate/documentation-quality-gate` -> `audit/documentation-quality-gate`
- `quality-gate/refactor` -> `refactor/refactor`

### Required taxonomy mapping

Skills:

- `group: audit` for `audit-*`
- `group: remediation` for `resolve-pr-comments`, `triage-ci-failure`
- `group: refactor` for `refactor`

Workflows:

- `group: audit` for `orchestrate-audit`, `pre-release-audit`, `documentation-quality-gate`
- `group: refactor` for `refactor`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy removed in the same change set

## 5) Removal Plan

### Code

- Delete:
  - `/.octon/framework/capabilities/runtime/skills/quality-gate/`
  - `/.octon/framework/orchestration/runtime/workflows/quality-gate/`
- Replace call-sites:
  - update all manifest/registry path fields that point to `quality-gate/...`
  - update commands and workflow step docs with direct path references
  - update validator scripts with hardcoded path regexes:
    - `/.octon/framework/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
- Remove routing:
  - remove `quality-gate` group definitions from skill/workflow group registries

### Contracts

- Remove legacy schema or manifest keys:
  - remove `quality-gate` group definitions from:
    - `/.octon/framework/capabilities/runtime/skills/capabilities.yml`
    - `/.octon/framework/orchestration/runtime/workflows/manifest.yml`
- Add or adjust new schema or manifest keys:
  - add `audit`, `remediation`, `refactor` group definitions for skills
  - add `audit`, `refactor` group definitions for workflows
  - update all `group` and `path` values in:
    - `/.octon/framework/capabilities/runtime/skills/manifest.yml`
    - `/.octon/framework/orchestration/runtime/workflows/manifest.yml`
    - `/.octon/framework/orchestration/runtime/workflows/registry.yml` (path-linked references)

### Docs

- Remove legacy docs references:
  - update all active references to `runtime/skills/quality-gate/...`
  - update all active references to `runtime/workflows/quality-gate/...`
- Update references in:
  - `/.octon/instance/bootstrap/catalog.md`
  - `/.octon/instance/bootstrap/conventions.md`
  - `/.octon/framework/orchestration/runtime/workflows/README.md`
  - `/.octon/framework/capabilities/_meta/architecture/*` where examples use `quality-gate`
  - `/.octon/framework/cognition/governance/principles/documentation-is-code.md`

### Tests and Validation

- Delete legacy tests:
  - N/A (no dedicated test module for `quality-gate` namespace)
- Add or adjust tests for new SSOT:
  - ensure workflow/skill validators pass on new paths
  - ensure ops catalog regeneration writes new paths:
    - `/.octon/generated/effective/capabilities/skills-deny-by-default-policy.catalog.yml`
  - extend migration guardrails to fail on reintroduction:
    - add legacy entries to `legacy-banlist.md`
    - add explicit deprecated path checks in validators where appropriate

## 6) Replacement Plan

- New components or files:
  - New domain directories listed in section 3
  - Migration plan folder:
    - `/.octon/instance/cognition/context/shared/migrations/2026-02-21-quality-gate-domain-split/`
  - Decision record:
    - `/.octon/instance/cognition/decisions/029-quality-gate-domain-split-clean-break-migration.md`
- New entrypoints:
  - none (command/workflow IDs remain stable)
- New reason codes or enums:
  - none expected

## 7) Verification

### A) Static Verification

- [x] No legacy identifiers remain (excluding append-only history, migration docs, output artifacts):
  - `quality-gate/`
  - `group: quality-gate`
  - `path: quality-gate/`
- [x] No legacy paths remain:
  - `/.octon/framework/capabilities/runtime/skills/quality-gate/`
  - `/.octon/framework/orchestration/runtime/workflows/quality-gate/`

Suggested static checks:

```bash
rg -n "group: quality-gate|path: quality-gate/" .octon \
  --glob '!.octon/generated/**' \
  --glob '!.octon/inputs/exploratory/ideation/**' \
  --glob '!.octon/instance/cognition/context/shared/migrations/**' \
  --glob '!.octon/instance/cognition/decisions/**' \
  --glob '!.octon/instance/cognition/context/shared/decisions.md'

rg -n "capabilities/runtime/skills/quality-gate/|orchestration/runtime/workflows/quality-gate/" .octon \
  --glob '!.octon/generated/**' \
  --glob '!.octon/inputs/exploratory/ideation/**' \
  --glob '!.octon/instance/cognition/context/shared/migrations/**' \
  --glob '!.octon/instance/cognition/decisions/**' \
  --glob '!.octon/instance/cognition/context/shared/decisions.md' \
  --glob '!.octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh' \
  --glob '!.octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh' \
  --glob '!.octon/framework/cognition/practices/methodology/migrations/legacy-banlist.md'
```

### B) Runtime Verification

- [x] New path exercised end-to-end:
  - run representative audit command/workflow routes and verify they resolve new directories
- [x] Old path is impossible:
  - moved directories absent
  - validators fail closed on reintroduced legacy paths

Suggested runtime/contract checks:

```bash
bash .octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict
bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile skills,workflows,harness
```

### C) CI Verification

- [x] CI gates updated or added to prevent legacy reintroduction:
  - enforce banlist entries for removed quality-gate paths
  - ensure workflow/skill validators run in standard CI profiles
  - ensure no dual-mode migration scripts are introduced

## 8) Definition of Done

- [x] Single authority only
- [x] Legacy deleted (code, docs, contracts)
- [x] All call-sites updated
- [x] CI gates pass locally and in CI
- [x] Plan links to evidence

Required evidence artifacts:

- `/.octon/state/evidence/migration/2026-02-21-quality-gate-domain-split/evidence.md`
- `/.octon/instance/cognition/decisions/029-quality-gate-domain-split-clean-break-migration.md`

## 9) Rollback

Rollback is full commit-range revert of this migration. No partial rollback modes are allowed.

---

## Execution Sequence (Recommended)

1. Prepare migration branch and final mapping table.
2. Move directories with `git mv` (skills/workflows) in one focused commit chunk.
3. Update manifests/registries/group definitions.
4. Update hardcoded validators and all active doc references.
5. Update migration guardrails (legacy banlist + validator deprecated-path checks).
6. Run full verification suite and generate evidence report.
7. Merge only when clean-break constraints and DoD are fully satisfied.

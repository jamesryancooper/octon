---
title: Examples
description: Full audit examples for the audit-subsystem-health skill.
---

# Examples

## Example 1: Skills Subsystem Audit

**Goal:** Audit the skills subsystem for internal coherence.

### Invocation

```text
/audit-subsystem-health subsystem=".octon/framework/capabilities/runtime/skills" docs=".octon/framework/cognition/_meta/architecture"
```

### Phase 1: Configure

```
Subsystem: .octon/framework/capabilities/runtime/skills
Schema reference: .octon/framework/capabilities/runtime/skills/capabilities.yml (auto-detected)
Companion docs: .octon/framework/cognition/_meta/architecture (19 files)

Config files discovered:
  - manifest.yml (32 entries)
  - registry.yml (32 entries)
  - capabilities.yml (schema)

Definition files discovered:
  - 32 SKILL.md files across 5 groups

Scope manifest: 147 files in 38 directories
```

### Phase 2: Config Consistency

```
Checking 32 entries across manifest.yml, registry.yml, and SKILL.md files...

CRITICAL: audit-ui — manifest id "audit-ui" but SKILL.md name is "audit-ui-guidelines"
HIGH: python-scaffold-package — skill_sets in manifest [specialist] but SKILL.md says [executor, specialist]
MEDIUM: react-native — capabilities.yml foundations group lists "react-native" but member not in foundations group
CLEAN: 29 entries fully consistent

Coverage: 32/32 entries checked, 96 fields reconciled
```

### Phase 3: Schema Conformance

```
Validating 32 entries against capabilities.yml schema...

HIGH: deploy-status — capability "external-output" is valid but required reference file "external-outputs.md" not found
HIGH: vercel-deploy — capability "external-output" requires references/external-outputs.md (missing)
MEDIUM: react-composition-patterns — parameter type "string" is not valid (should be "text")
CLEAN: 29 entries pass all schema checks

Coverage: 32/32 entries validated, 7 schema dimensions checked per entry
```

### Phase 4: Semantic Quality

```
Running semantic quality checks...

MEDIUM: Trigger overlap — "scaffold a skill" matches both create-skill and python-scaffold-package
MEDIUM: Doc drift — .octon/framework/capabilities/_meta/architecture/architecture.md describes "flat directory layout" but skills use group-based nesting
LOW: deploy-status — display_name "Deploy Status" doesn't capitalize correctly (expected "Deploy Status" ✓ — actually OK)
LOW: Missing /.octon/state/evidence/runs/skills/react/ directory (no log outputs declared, so informational only)
CLEAN: 28 entries pass all semantic checks

Coverage: 32 entries analyzed, 512 trigger pairs compared, 19 doc files checked
```

### Phase 5: Self-Challenge

```
Self-Challenge Results:

- Entries verified: 32/32 (all covered)
- Blind spots found: 1 (scripts/ directory not scanned for stale references)
- Findings confirmed: 6
- Findings disproved: 0
- New findings from counter-examples: 1 (react group missing from capabilities.yml — it uses "foundations" but isn't listed in foundations members)
```

### Phase 6: Report

```
Report written to: .octon/state/evidence/validation/analysis/2026-02-10-subsystem-health-audit.md

Executive Summary:
  Total findings: 7 across 6 files
  CRITICAL: 1
  HIGH: 3
  MEDIUM: 2
  LOW: 1

Recommended Fix Batches:
  Batch 1: Critical config mismatches (1 finding) — fix SKILL.md name field
  Batch 2: Schema violations (3 findings) — add missing reference files, fix parameter type
  Batch 3: Semantic issues (2 findings) — deduplicate triggers, update architecture docs
  Batch 4: Informational (1 finding) — optional state directory creation
```

---

## Example 2: Minimal Invocation

**Goal:** Quick health check without companion docs.

### Invocation

```text
/audit-subsystem-health subsystem=".octon/framework/capabilities/runtime/skills"
```

### Result

Same as Example 1 but without Phase 4's doc-to-source alignment checks. The semantic quality layer still runs trigger overlap, naming convention, and cross-reference checks.

---

## Anti-Examples: What NOT to Do

### Using This Instead of audit-migration

**Wrong:**
```
/audit-subsystem-health subsystem=".octon/" after a directory restructuring
```

**Why it's wrong:** After a migration, use `audit-migration` with a migration manifest. `audit-subsystem-health` doesn't know about old→new mappings.

### Auditing Non-Subsystem Directories

**Wrong:**
```
/audit-subsystem-health subsystem="src/components/"
```

**Why it's wrong:** This skill expects harness subsystem conventions (manifest.yml, registry.yml, SKILL.md). Application source directories don't have these.

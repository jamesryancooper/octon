---
title: Examples Reference
description: Full audit examples from real migrations.
---

# Examples Reference

Full audit-migration examples based on real migration work.

## Example 1: Simple Directory Rename

### Manifest

```yaml
migration:
  name: "rename scratch to scratchpad"
  mappings:
    - old: ".scratch/"
      new: ".scratchpad/"
    - old: ".scratch"
      new: ".scratchpad"
  exclusions:
    - "continuity/log.md"
    - "cognition/decisions/"
  scope: ".harmony/"
```

### Invocation

```
/audit-migration manifest=".harmony/migrations/scratch-rename.yml"
```

### Expected Output

Report with findings in files that still reference `.scratch/` instead of `.scratchpad/`. Typically:
- Grep sweep finds string-level references
- Cross-reference audit finds broken paths pointing to old directory
- Semantic read-through flags descriptions of the old naming

---

## Example 2: Multi-Pattern Migration (Real-World)

This example is based on the actual Harmony workspace migration from two-root (`.workspace/` + `.harmony/`) to single capability-organized `.harmony/`.

### Manifest

```yaml
migration:
  name: "capability-organized restructure"
  mappings:
    # Root migration
    - old: ".workspace/"
      new: ".harmony/"
    # Capability-organized renames
    - old: "context/"
      new: "cognition/context/"
    - old: "commands/"
      new: "capabilities/commands/"
    - old: "progress/"
      new: "continuity/"
    - old: "checklists/"
      new: "quality/"
    - old: "workflows/"
      new: "orchestration/workflows/"
    - old: "missions/"
      new: "orchestration/missions/"
    - old: "assistants/"
      new: "agency/assistants/"
    - old: "templates/"
      new: "scaffolding/templates/"
    - old: "prompts/"
      new: "scaffolding/prompts/"
    - old: "examples/"
      new: "scaffolding/examples/"
    # File renames
    - old: "behaviors.md"
      new: "phases.md"
  exclusions:
    # Append-only historical records
    - "continuity/log.md"
    - "cognition/decisions/"
    # Historical/archived content
    - ".history/"
    - ".specstory/"
    - "ideation/scratchpad/archive/"
    - "capabilities/skills/archive/"
    # Migration workflow itself (intentionally references old names)
    - "orchestration/workflows/workspace/migrate-workspace/"
  scope: "."
```

### Results Summary

This migration (run across 2 sessions) produced:

| Layer | Findings |
|-------|----------|
| Grep Sweep | 44 (string-level stale references) |
| Cross-Reference Audit | 15 (broken path references) |
| Semantic Read-Through | 23 (conceptual staleness, terminology drift) |
| **Total** | **82** |

### Staleness Classes Discovered

The audit revealed distinct classes of staleness, each caught by different layers:

| Class | Layer That Caught It | Example |
|-------|---------------------|---------|
| Direct old→new name references | Grep Sweep | `.workspace/context/` instead of `.harmony/cognition/context/` |
| Broken cross-references | Cross-Reference Audit | `catalog.md` linking to `skills.md` when it became `skills/README.md` |
| Conceptual staleness | Semantic Read-Through | "Two-tier architecture" description when model changed to "progressive disclosure" |
| Incomplete on-disk renames | Cross-Reference Audit | `resources/research-synthesizer/` not renamed to `resources/synthesize-research/` |
| Secondary migration debris | Grep Sweep | `docs/handbooks/` references from a separate docs reorganization |

### Fix Batches Generated

```markdown
### Batch 1: Critical operational fixes (16 findings)
catalog.md broken paths, primitives.md stale mission paths,
workflow step files with wrong directory names

### Batch 2: High-priority reference fixes (25 findings)
Cursor command stale paths, SKILL.md behaviors→phases links,
conventions.md bare directory names, registry/filesystem mismatches

### Batch 3: Documentation cleanup (15 findings)
docs/ cross-references (handbooks/, ai/, human/), scratchpad README

### Batch 4: Terminology updates (6 findings)
"Two-tier architecture" → "Progressive disclosure" in skills docs

### Batch 5: Low priority / judgment calls (12 findings)
log.md header (historical), docs/.harmony/ structural non-conformance
```

---

## Example 3: Scoped Audit with Structure Diff

### Manifest

```yaml
migration:
  name: "skills directory restructure"
  mappings:
    - old: "skill.md"
      new: "SKILL.md"
    - old: "behaviors.md"
      new: "phases.md"
  exclusions: []
  scope: ".harmony/capabilities/skills/"
```

### Invocation with Structure Diff

```
/audit-migration manifest="..." structure_spec="docs/architecture/harness/skills/README.md"
```

### Structure Diff Output

```markdown
## Structure Diff Findings

### Documented but missing on disk:
- skills/assets/ (documented in spec, no skill has created one yet)

### On disk but not documented:
- skills/configs/ (exists, not in spec)
- skills/runs/ (exists, not in spec)

### Mismatches:
- skills/_template/references/behaviors.md (spec says phases.md)
```

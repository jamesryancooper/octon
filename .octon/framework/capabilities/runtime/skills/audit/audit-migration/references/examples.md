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
    - "/.octon/state/continuity/repo/log.md"
    - "instance/cognition/decisions/"
  scope: ".octon/"
```

### Invocation

```
/audit-migration manifest=".octon/migrations/scratch-rename.yml"
```

### Expected Output

Report with findings in files that still reference `.scratch/` instead of `.scratchpad/`. Typically:
- Grep sweep finds string-level references
- Cross-reference audit finds broken paths pointing to old directory
- Semantic read-through flags descriptions of the old naming

---

## Example 2: Multi-Pattern Migration (Real-World)

This example is based on the actual Octon workspace migration from two-root (`.workspace/` + `.octon/`) to single capability-organized `.octon/`.

### Manifest

```yaml
migration:
  name: "capability-organized restructure"
  mappings:
    # Root migration
    - old: ".workspace/"
      new: ".octon/"
    # Capability-organized renames
    - old: "context/"
      new: "instance/cognition/context/shared/"
    - old: "commands/"
      new: "capabilities/runtime/commands/"
    - old: "progress/"
      new: "continuity/"
    - old: "checklists/"
      new: "quality/"
    - old: "workflows/"
      new: "orchestration/runtime/workflows/"
    - old: "missions/"
      new: "instance/orchestration/missions/"
    - old: "assistants/"
      new: "agency/runtime/specialists/"
    - old: "templates/"
      new: "scaffolding/runtime/templates/"
    - old: "prompts/"
      new: "scaffolding/practices/prompts/"
    - old: "examples/"
      new: "scaffolding/practices/examples/"
    # File renames
    - old: "behaviors.md"
      new: "phases.md"
  exclusions:
    # Append-only historical records
    - "/.octon/state/continuity/repo/log.md"
    - "instance/cognition/decisions/"
    # Historical/archived content
    - ".history/"
    - ".specstory/"
    - "ideation/scratchpad/archive/"
    - "capabilities/runtime/skills/archive/"
    # Migration workflow itself (intentionally references old names)
    - "orchestration/runtime/workflows/workspace/migrate-workspace/"
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
| Direct old→new name references | Grep Sweep | `.workspace/context/` instead of `.octon/instance/cognition/context/shared/` |
| Broken cross-references | Cross-Reference Audit | `catalog.md` linking to `skills.md` when it became `skills/README.md` |
| Conceptual staleness | Semantic Read-Through | "Two-tier architecture" description when model changed to "progressive disclosure" |
| Incomplete on-disk renames | Cross-Reference Audit | `/.octon/instance/capabilities/runtime/skills/resources/research-synthesizer/` not renamed to `/.octon/instance/capabilities/runtime/skills/resources/synthesize-research/` |
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
log.md header (historical), docs/.octon/ structural non-conformance
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
  scope: ".octon/framework/capabilities/runtime/skills/"
```

### Invocation with Structure Diff

```
/audit-migration manifest="..." structure_spec=".octon/framework/capabilities/_meta/architecture/README.md"
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
- skills/_scaffold/template/references/behaviors.md (spec says phases.md)
```

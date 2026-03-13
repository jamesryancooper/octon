---
title: Glossary
description: Subsystem health audit terminology.
---

# Glossary

Terminology used in the audit-subsystem-health skill.

## Terms

**Config consistency**
: The property that multiple config files (manifest.yml, registry.yml, SKILL.md frontmatter) agree on the same values for shared fields. The opposite of config drift.

**Config drift**
: When the same logical field has different values across config files. Example: manifest says `skill_sets: [executor]` but SKILL.md says `skill_sets: [executor, guardian]`.

**Coverage proof**
: A section in the audit report that documents what was checked and found clean, not just what had findings. Proves the audit was exhaustive, not just that it found issues.

**Definition file**
: The primary specification file for a skill (`SKILL.md`) or workflow (`README.md`). Contains frontmatter with authoritative field values.

**Entry**
: A single skill or workflow registered in the subsystem. Identified by its `id` in `manifest.yml`.

**Group membership drift**
: When `capabilities.yml` `skill_group_definitions` lists different members than what the manifest entries actually declare for that group.

**Idempotency**
: The property that running the same audit against the same codebase produces the same findings. Ensured by fixed check patterns, deterministic file ordering, and fixed severity rules.

**Lens isolation**
: The rule that each verification layer (config consistency, schema conformance, semantic quality) completes fully before the next begins. Prevents cross-lens bias.

**Orphan definition**
: A `SKILL.md` file that exists on disk but has no corresponding entry in `manifest.yml`. The skill exists but is undiscoverable.

**Phantom entry**
: A `manifest.yml` entry whose `path` does not resolve to an actual directory on disk. The entry is discoverable but the skill doesn't exist.

**Schema conformance**
: The property that all declared values (skill_sets, capabilities, groups, parameter types) are valid according to the schema defined in `capabilities.yml`.

**Schema reference**
: The file (`capabilities.yml` or equivalent) that defines what values are valid for fields like `skill_sets`, `capabilities`, and `group`.

**Self-challenge**
: A mandatory audit phase where the auditor revisits all findings and scope to identify overlooked gaps, disprove false findings, and search for counter-examples.

**Semantic quality**
: Properties that structural validation cannot catch: trigger overlaps, naming convention adherence, summary alignment, doc-to-source coherence.

**Subsystem**
: A self-contained component of the harness with its own config files, definition files, and conventions. Example: `.octon/capabilities/runtime/skills/` is the skills subsystem.

**Summary alignment**
: The property that the `summary` field in `manifest.yml` conveys the same meaning as the first sentence of the `description` field in `SKILL.md`.

**Trigger overlap**
: When two or more skills have trigger phrases that are identical or highly similar, creating ambiguity in intent matching.

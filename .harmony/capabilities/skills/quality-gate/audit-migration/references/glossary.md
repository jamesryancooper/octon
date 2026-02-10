---
title: Glossary Reference
description: Migration audit terminology and domain concepts.
---

# Glossary Reference

Terminology used in the audit-migration skill.

## Core Concepts

| Term | Definition |
| ---- | ---------- |
| **Migration** | A structural change to a codebase involving directory renames, moves, or reorganizations that requires updating all references |
| **Migration manifest** | A YAML document describing what changed (old→new mappings), what to exclude, and what scope to audit |
| **Mapping** | A single old→new pair describing one rename or move (e.g., `.workspace/` → `.harmony/`) |
| **Staleness** | A reference that points to an old name, path, or concept that no longer matches the current state |
| **Finding** | A single instance of staleness discovered during an audit, with file, line, description, and severity |

## Verification Layers

| Term | Definition |
| ---- | ---------- |
| **Verification layer** | One of the distinct audit methods, each catching a different class of staleness |
| **Grep sweep** | Layer 1: Pattern-based search for old names using multiple string variations |
| **Cross-reference audit** | Layer 2: Extraction and validation of path references from key files against the filesystem |
| **Semantic read-through** | Layer 3: End-to-end reading of key files to identify conceptual staleness that has no searchable string pattern |
| **Structure diff** | Optional layer: Comparison of actual filesystem against a documented expected structure |
| **Template smoke test** | Optional layer: Scanning of template/scaffolding files for stale patterns (these have outsized blast radius because they are generative) |

## Staleness Classes

| Term | Definition |
| ---- | ---------- |
| **String-level staleness** | A file textually contains an old name or path — catchable by grep |
| **Path-level staleness** | A path reference looks correct but doesn't resolve to an existing file or directory — catchable by cross-reference audit |
| **Conceptual staleness** | Prose that describes an old architecture, model, or behavior without using any searchable stale strings — catchable only by semantic read-through |
| **Generative staleness** | Stale patterns in templates or generators that will propagate to every future output — catchable by template smoke test |
| **Structural drift** | Filesystem doesn't match documented structure (missing dirs, undocumented dirs) — catchable by structure diff |

## Severity Tiers

| Term | Definition |
| ---- | ---------- |
| **CRITICAL** | Stale reference in an operational file that causes workflow failures (e.g., broken path in a command or registry) |
| **HIGH** | Stale reference in an active file that misleads agents or humans (e.g., wrong directory name in an agent prompt) |
| **MEDIUM** | Stale reference in non-operational content (e.g., documentation, examples, reference files) |
| **LOW** | Cosmetic issues, historical terminology drift, or ambiguous findings requiring human judgment |

## Audit Infrastructure

| Term | Definition |
| ---- | ---------- |
| **Exclusion zone** | A file or directory explicitly excluded from audit findings (e.g., append-only logs, historical ADRs, archived content) |
| **Key file** | An operational file selected for cross-reference audit and semantic read-through (e.g., START.md, catalog.md) |
| **Search variation** | One of 8 string patterns generated from each mapping to catch different quoting and path formats |
| **Fix batch** | A logical grouping of findings that can be fixed together, ordered by priority |
| **False positive** | An audit match that is not actually stale (e.g., a variable name that coincidentally matches an old path) |
| **Coverage proof** | The "Files Confirmed Clean" section of the report, demonstrating that absence of findings reflects actual cleanliness, not incomplete scanning |

## Bounded Audit Principles

| Term | Definition |
| ---- | ---------- |
| **Bounded audit** | An audit constrained by fixed principles that ensure stability and reproducibility across sessions — same inputs always produce substantially the same findings |
| **Fixed lenses** | Principle requiring that the audit uses a predetermined set of verification layers (grep, cross-ref, semantic), preventing attention drift between sessions |
| **Fixed severity bar** | Principle requiring that severity classification follows fixed rules based on file type and impact, never subjective judgment — prevents calibration variance |
| **Self-challenge phase** | A mandatory phase after all verification layers where the auditor revisits findings and scope, checking for overlooked gaps, false negatives, and counterpoints |
| **Enumerated search patterns** | Principle requiring that every search pattern is derived mechanically from the manifest (8 variations per mapping), removing agent discretion from search strategy |
| **Coverage manifest** | A section of the report that documents what was checked and found clean, not just what was found stale — proves that absence of findings reflects actual scanning |
| **Idempotency guarantee** | Principle requiring that the same manifest + same codebase produces substantially the same findings regardless of which session or agent runs the audit |
| **Lens isolation** | Principle requiring that each verification layer completes fully before the next begins, with no cross-pollination of findings between layers — prevents cross-lens bias |

## Self-Challenge Checks

| Term | Definition |
| ---- | ---------- |
| **Mapping coverage check** | Self-challenge step that verifies every mapping from the manifest was actually searched in all applicable layers |
| **Blind spot analysis** | Self-challenge step that identifies file types, directories, or patterns that might have been missed by the three verification layers |
| **Finding verification** | Self-challenge step that reviews each finding for correctness — checking for false positives and confirming severity assignments |
| **Counter-example search** | Self-challenge step that actively looks for evidence that would contradict or downgrade existing findings |

## Partition Concepts

| Term | Definition |
| ---- | ---------- |
| **Partition** | A labeled slice of the audit scope, defined by a glob pattern, that allows the audit to be executed in parallel across disjoint file sets |
| **Partition mode** | The skill's operating mode when `partition` and `file_filter` parameters are set — narrows scope, adjusts validation, and produces partition-labeled output |
| **File filter** | A glob pattern (e.g., `docs/architecture/**`) that narrows the scope manifest to only matching files within the `scope` directory |
| **Partition-scoped coverage** | Coverage proof that accounts only for files within the partition — does not claim to cover the full codebase |
| **Partition report** | An audit report produced in partition mode, with partition metadata in the header and a filename that includes the partition label |
| **Global self-challenge** | A cross-partition self-challenge that checks for issues spanning partition boundaries — performed by the orchestration workflow at merge time, not by individual partition runs |
| **Partition merge** | The process of collecting all partition reports, deduplicating findings, and producing a consolidated global report — performed by the orchestration workflow |
| **Cross-partition reference** | A path reference in one partition that points to a file in another partition — cannot be fully validated within a single partition run |

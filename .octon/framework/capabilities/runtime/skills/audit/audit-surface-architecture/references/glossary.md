---
title: Glossary Reference
description: Surface-architecture audit terminology.
---

# Glossary Reference

Terminology used in the audit-surface-architecture skill.

## Core Terms

| Term | Definition |
| ---- | ---------- |
| **Surface unit** | One durable Octon feature or guidance unit, such as a workflow, skill, watcher, automation, contract surface, or methodology artifact. |
| **Authority model** | Classification describing where the target surface's real operational authority lives. |
| **Coverage matrix** | Accounting table showing whether each in-scope artifact is authoritative, supportive, explanatory, excluded, or unknown. |
| **Coverage ledger** | Detailed artifact-by-artifact accounting for the audited surface. |
| **Done gate** | Formal completion criterion that becomes strict in post-remediation mode. |

## Surface Architecture Terms

| Term | Definition |
| ---- | ---------- |
| **Contract-first** | Machine-readable contracts define the authoritative behavior of the surface. |
| **Mixed** | Authority is split across contracts, prose, or conventions in a way that creates drift risk. |
| **Markdown-first** | Human-readable prose acts as the canonical execution or operational contract. |
| **Human-led/non-executable** | The surface is durable guidance or reference material, not an execution-bearing runtime contract. |
| **Hidden authority** | Incidental artifact, example, or convention that behaves like a canonical source without being declared as one. |
| **Split-brain duplication** | Parallel human-first and agent/operator-first surfaces that duplicate the same authority. |
| **Support asset** | Artifact subordinate to canonical authority, such as stage instructions, references, fixtures, or generated docs. |
| **Unknown** | Explicit marker for unresolved claims caused by insufficient evidence. |

## Bounded Audit Terms

| Term | Definition |
| ---- | ---------- |
| **Lens isolation** | Rule requiring target resolution, artifact mapping, and drift analysis to complete in order. |
| **Stable finding ID** | Deterministic finding identifier for tracking remediation across reruns. |
| **Convergence receipt** | Metadata proving rerun stability under fixed inputs and seed policy. |

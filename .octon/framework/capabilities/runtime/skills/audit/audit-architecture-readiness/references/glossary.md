---
title: Glossary Reference
description: Architecture-readiness audit terminology.
---

# Glossary Reference

Terminology used in the audit-architecture-readiness skill.

## Core Terms

| Term | Definition |
| ---- | ---------- |
| **Whole-harness** | Architecture-readiness mode for `/.octon/` as a complete governed system. |
| **Bounded-domain** | Architecture-readiness mode for one top-level bounded-surface domain. |
| **Not-applicable** | Explicit verdict for targets outside the supported profile set. |
| **Hard gate** | Dimension that blocks an implementation-ready verdict when scored below `2`. |
| **Failure-mode assessment** | Explicit analysis of likely structural failure modes and their mitigations. |

## Architecture Readiness Terms

| Term | Definition |
| ---- | ---------- |
| **Dimension score** | Per-dimension readiness score on the 0-3 rubric. |
| **Control plane** | The plane that governs, authorizes, schedules, records, and recovers. |
| **Execution plane** | The plane that performs bounded admitted work. |
| **Design smell** | Structural warning sign that indicates fragile or misleading architecture. |
| **Remediation artifact** | Exact durable path that must be created or updated to close a gap. |

## Bounded Audit Terms

| Term | Definition |
| ---- | ---------- |
| **Lens isolation** | Rule requiring each mandatory audit layer to complete before the next starts. |
| **Stable finding ID** | Deterministic finding identifier for tracking remediation across reruns. |
| **Convergence receipt** | Metadata proving rerun stability under fixed inputs and seed policy. |

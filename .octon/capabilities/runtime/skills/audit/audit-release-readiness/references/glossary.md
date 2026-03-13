---
title: Glossary Reference
description: Release-readiness audit terminology.
---

# Glossary Reference

Terminology used in the audit-release-readiness skill.

## Core Terms

| Term | Definition |
| ---- | ---------- |
| **Release baseline** | Canonical artifact defining release policy and gate expectations. |
| **Operations baseline** | Canonical artifact defining incident and operational response expectations. |
| **Coverage matrix** | Layered accounting table showing whether each in-scope surface has policy, safeguard, and evidence coverage. |
| **Coverage ledger** | Detailed list accounting for each in-scope artifact as finding-backed, clean, excluded, or unknown. |
| **Done gate** | Formal completion criterion that becomes strict in post-remediation mode. |

## Release Readiness Terms

| Term | Definition |
| ---- | ---------- |
| **Release criteria** | Policy-defined conditions that must be satisfied before launch. |
| **Change-control evidence** | Artifacts proving approvals and procedural checks occurred. |
| **Rollback posture** | Evidence that rollback procedures are defined, actionable, and scoped to critical paths. |
| **Operational readiness** | Evidence that incident/runbook pathways are available for launch risk management. |
| **Gate evidence** | Receipts and reports proving release gates executed as expected. |
| **Unknown** | Explicit marker for unresolved claims caused by insufficient evidence. |

## Bounded Audit Terms

| Term | Definition |
| ---- | ---------- |
| **Lens isolation** | Rule requiring each coverage layer to complete before the next starts. |
| **Stable finding ID** | Deterministic finding identifier for tracking remediation across reruns. |
| **Convergence receipt** | Metadata proving rerun stability under fixed inputs and seed policy. |

---
title: Glossary Reference
description: Operational-readiness audit terminology.
---

# Glossary Reference

Terminology used in the audit-operational-readiness skill.

## Core Terms

| Term | Definition |
| ---- | ---------- |
| **Operations baseline** | Canonical artifact defining reliability and operations expectations. |
| **Incident baseline** | Canonical artifact defining incident-response and escalation expectations. |
| **Coverage matrix** | Layered accounting table showing whether each in-scope surface has ownership, response, and resilience coverage. |
| **Coverage ledger** | Detailed list accounting for each in-scope artifact as finding-backed, clean, excluded, or unknown. |
| **Done gate** | Formal completion criterion that becomes strict in post-remediation mode. |

## Operational Readiness Terms

| Term | Definition |
| ---- | ---------- |
| **Ownership posture** | Evidence that in-scope services have accountable owners and operational responsibility. |
| **Reliability objective** | Artifact defining service-level expectations or SLO-like targets. |
| **Runbook readiness** | Evidence that operational procedures are documented, current, and actionable. |
| **Incident-response readiness** | Evidence that escalation and response pathways are defined and usable under failure conditions. |
| **Resilience safeguard** | Artifact preserving service continuity under fault, load, or dependency degradation conditions. |
| **Unknown** | Explicit marker for unresolved claims caused by insufficient evidence. |

## Bounded Audit Terms

| Term | Definition |
| ---- | ---------- |
| **Lens isolation** | Rule requiring each coverage layer to complete before the next starts. |
| **Stable finding ID** | Deterministic finding identifier for tracking remediation across reruns. |
| **Convergence receipt** | Metadata proving rerun stability under fixed inputs and seed policy. |

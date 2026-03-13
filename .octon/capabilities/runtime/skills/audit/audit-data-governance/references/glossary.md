---
title: Glossary Reference
description: Data-governance audit terminology.
---

# Glossary Reference

Terminology used in the audit-data-governance skill.

## Core Terms

| Term | Definition |
| ---- | ---------- |
| **Classification baseline** | Canonical artifact defining data classes and handling expectations. |
| **Retention baseline** | Canonical artifact defining retention and deletion expectations across data classes. |
| **Coverage matrix** | Layered accounting table showing whether each in-scope surface has classification, traceability, and safeguard coverage. |
| **Coverage ledger** | Detailed list accounting for each in-scope artifact as finding-backed, clean, excluded, or unknown. |
| **Done gate** | Formal completion criterion that becomes strict in post-remediation mode. |

## Data Governance Terms

| Term | Definition |
| ---- | ---------- |
| **Data class** | Policy-defined category expressing sensitivity and handling obligations. |
| **Retention control** | Artifact defining duration, deletion, and preservation requirements. |
| **Lineage evidence** | Artifact showing origin and transformation trail for governed data surfaces. |
| **Contract traceability** | Linkage between data surfaces and declared interface/contract metadata. |
| **Privacy safeguard** | Artifact demonstrating protections for sensitive or regulated data. |
| **Governance evidence** | Receipts and reports proving governance checks or gates executed as expected. |
| **Unknown** | Explicit marker for unresolved claims caused by insufficient evidence. |

## Bounded Audit Terms

| Term | Definition |
| ---- | ---------- |
| **Lens isolation** | Rule requiring each coverage layer to complete before the next starts. |
| **Stable finding ID** | Deterministic finding identifier for tracking remediation across reruns. |
| **Convergence receipt** | Metadata proving rerun stability under fixed inputs and seed policy. |

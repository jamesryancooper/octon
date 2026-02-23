---
title: Glossary Reference
description: API-contract audit terminology.
---

# Glossary Reference

Terminology used in the audit-api-contract skill.

## Core Terms

| Term | Definition |
| ---- | ---------- |
| **Contract baseline** | Canonical artifact defining contract-first obligations and expectations. |
| **API-design baseline** | Canonical artifact defining API style and design governance expectations. |
| **Coverage matrix** | Layered accounting table showing whether each in-scope interface has spec, conformance, and lifecycle coverage. |
| **Coverage ledger** | Detailed list accounting for each in-scope artifact as finding-backed, clean, excluded, or unknown. |
| **Done gate** | Formal completion criterion that becomes strict in post-remediation mode. |

## API Contract Terms

| Term | Definition |
| ---- | ---------- |
| **Contract surface** | Declared API/interface specification expected to bind implementation behavior. |
| **Conformance evidence** | Artifacts showing implementation behavior aligns with declared contracts. |
| **Compatibility safeguard** | Artifact preserving backward/forward safety across contract evolution. |
| **Deprecation posture** | Artifact defining lifecycle, notice, and migration expectations for interface changes. |
| **Gate evidence** | Receipts and reports proving API governance checks or release gates executed as expected. |
| **Unknown** | Explicit marker for unresolved claims caused by insufficient evidence. |

## Bounded Audit Terms

| Term | Definition |
| ---- | ---------- |
| **Lens isolation** | Rule requiring each coverage layer to complete before the next starts. |
| **Stable finding ID** | Deterministic finding identifier for tracking remediation across reruns. |
| **Convergence receipt** | Metadata proving rerun stability under fixed inputs and seed policy. |

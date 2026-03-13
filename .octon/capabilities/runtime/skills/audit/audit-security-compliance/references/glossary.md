---
title: Glossary Reference
description: Security and compliance audit terminology.
---

# Glossary Reference

Terminology used in the audit-security-compliance skill.

## Core Terms

| Term | Definition |
| ---- | ---------- |
| **Policy baseline** | Canonical policy artifact declaring required security and compliance expectations. |
| **Control baseline** | Canonical artifact describing required technical controls and governance gates. |
| **Coverage matrix** | Layered accounting table showing whether each in-scope surface has policy/control, safeguards, and evidence coverage. |
| **Coverage ledger** | Detailed list accounting for each in-scope artifact as finding-backed, clean, excluded, or unknown. |
| **Done gate** | Formal completion criterion that becomes strict in post-remediation mode. |

## Security and Compliance Terms

| Term | Definition |
| ---- | ---------- |
| **Secrets safeguard** | Artifact proving sensitive-value handling controls (for example redaction, vaulting, no-secrets policies). |
| **Access safeguard** | Artifact proving authorization and least-privilege enforcement controls. |
| **Supply-chain evidence** | Artifacts such as SBOM/dependency records supporting dependency risk visibility. |
| **Compliance evidence** | Traceable receipts and reports proving controls and gates executed as expected. |
| **Unknown** | Explicit marker for unresolved claims caused by insufficient evidence. |

## Bounded Audit Terms

| Term | Definition |
| ---- | ---------- |
| **Lens isolation** | Rule requiring each coverage layer to complete before the next starts. |
| **Stable finding ID** | Deterministic finding identifier for tracking remediation across reruns. |
| **Convergence receipt** | Metadata proving rerun stability under fixed inputs and seed policy. |

---
title: Glossary Reference
description: Independent architecture critique terminology.
---

# Glossary Reference

Terminology used in the audit-domain-architecture skill.

## Core Terms

| Term | Definition |
| ---- | ---------- |
| **Surface** | A coherent architecture area (directory/module boundary) with a distinct responsibility and change profile. |
| **Subsurface** | A finer-grained structure inside a surface, typically a focused responsibility partition. |
| **Responsibility seam** | A boundary where ownership or behavior changes between surfaces/subsurfaces. |
| **Surface map** | The inventory of surfaces/subsurfaces, responsibilities, and supporting path-level evidence. |
| **External criteria** | Evaluation lenses independent of local doctrine: modularity, discoverability, coupling, operability, change safety, and testability. |
| **Governance artifact** | In-repo policy/contract documents reviewed as evidence, not as binding optimization goals for this audit. |

## Mode Terms

| Term | Definition |
| ---- | ---------- |
| **Observed mode** | Execution mode used when the target domain exists on disk and can be audited directly. |
| **Prospective mode** | Execution mode used when the target domain is valid but not yet present on disk; critique is based on profile baselines and comparator evidence. |
| **Domain profile baseline** | Expected high-level surface shape inferred from the domain profile registry. |
| **Comparator evidence** | Evidence drawn from related existing domains to ground prospective recommendations. |

## Gap and Excess Terms

| Term | Definition |
| ---- | ---------- |
| **Missing surface** | A capability/responsibility that should exist for robustness but has no explicit location or owner. |
| **Redundant surface** | Two or more surfaces that overlap responsibility enough to create drift risk or duplicated maintenance. |
| **Over-engineered surface** | Structure whose complexity exceeds demonstrated operational or maintainability value. |
| **Critical gap** | A missing/incorrect architecture element likely to cause failures, unsafe changes, or high operational risk. |
| **Keep-as-is decision** | An explicit choice to preserve a current structure because evidence shows it is fit for purpose. |

## Evidence Terms

| Term | Definition |
| ---- | ---------- |
| **Path-level evidence** | Concrete file or directory references supporting a claim. |
| **Falsifiable claim** | A claim framed so a reviewer can confirm or refute it by checking evidence. |
| **Unknown** | A required conclusion area where evidence is insufficient; must be stated explicitly instead of inferred. |
| **Self-challenge** | Mandatory phase that tries to disprove findings, uncover blind spots, and downgrade weak claims. |
